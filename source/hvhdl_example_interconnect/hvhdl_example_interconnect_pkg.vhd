library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.communications_pkg.all;

package hvhdl_example_interconnect_pkg is

    type hvhdl_example_interconnect_FPGA_input_group is record
        communications_FPGA_in : communications_FPGA_input_group;
        sdm_data : std_logic;
    end record;
    
    type hvhdl_example_interconnect_FPGA_output_group is record
        communications_FPGA_out : communications_FPGA_output_group;
        sdm_clock : std_logic;
    end record;
    
end package hvhdl_example_interconnect_pkg;
------------------------------------------------------------------------
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.hvhdl_example_interconnect_pkg.all;
	use work.multiplier_pkg.all;
	use work.sincos_pkg.all;
    use work.communications_pkg.all;
    use work.fpga_interconnect_pkg.all;
    use work.first_order_filter_pkg.all;
    use work.example_filter_entity_pkg.all;

    use work.sigma_delta_cic_filter_pkg.all;

entity hvhdl_example_interconnect is
    port (
        system_clock : in std_logic;
        hvhdl_example_interconnect_FPGA_in  : in hvhdl_example_interconnect_FPGA_input_group;
        hvhdl_example_interconnect_FPGA_out : out hvhdl_example_interconnect_FPGA_output_group
    );
end hvhdl_example_interconnect;

architecture rtl of hvhdl_example_interconnect is

    use work.example_project_addresses_pkg.all;

    signal multiplier : multiplier_record := init_multiplier;
    signal sincos     : sincos_record     := init_sincos;

    signal prbs7 : std_logic_vector(6 downto 0) := (0 => '1', others => '0');
    signal sine_with_noise : int := 0;
    signal angle : integer  range 0 to 2**16-1 := 0;
    signal i     : integer range 0 to 2**16-1 := 1199;

    signal communications_clocks   : communications_clock_group;
    signal communications_data_in  : communications_data_input_group;
    signal communications_data_out : communications_data_output_group;

    signal floating_point_filter_in : example_filter_input_record := init_example_filter_input;
    signal fixed_point_filter_in    : example_filter_input_record := init_example_filter_input;

    alias bus_from_master is communications_data_out.bus_out;
    alias bus_to_master   is communications_data_in.bus_in;

    signal bus_from_floating_point_filter : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_fixed_point_filter    : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_interconnect          : fpga_interconnect_record := init_fpga_interconnect;

    signal data_in_example_interconnect : integer range 0 to 2**16-1 := 44252;

    constant filter_time_constant : real := 0.001;
    signal sdm_clock_counter : integer range 0 to 15;

    signal cic_filter : cic_filter_record := init_cic_filter;

    type intarray is array (integer range 0 to 2) of integer range -2**22 to 2**22-1;
    signal filter_bank : intarray := (others => 0);

    function filter_with_bank
    (
        filterbank : intarray;
        input_bit : std_logic
    )
    return intarray
    is
        variable data : unsigned(22 downto 0);
        variable filtered_data : intarray;
    begin
        data := (22=>input_bit, others => '0');
        filtered_data(0) := filterbank(0) + (to_integer(data) - filterbank(0))/32;

        for i in 1 to intarray'high loop
            filtered_data(i) := filterbank(i) + (filterbank(i-1) - filterbank(i))/32;
        end loop;
        return filtered_data;
    end filter_with_bank;

begin

    sdm_clock_generator : process(system_clock)
    begin
        if rising_edge(system_clock) then
            if sdm_clock_counter > 0 then
                sdm_clock_counter <= sdm_clock_counter -1;
            else
                sdm_clock_counter <= 5;
            end if;

            if sdm_clock_counter > 5/2 then
                hvhdl_example_interconnect_FPGA_out.sdm_clock <= '1';
            else
                hvhdl_example_interconnect_FPGA_out.sdm_clock <= '0';
            end if;

            if sdm_clock_counter = 4 then
                calculate_cic_filter(cic_filter, hvhdl_example_interconnect_FPGA_in.sdm_data);
                filter_bank <= filter_with_bank(filter_bank, hvhdl_example_interconnect_FPGA_in.sdm_data);
            end if;

        end if; --rising_edge
    end process sdm_clock_generator;	


    create_noisy_sine : process(system_clock)
    begin
        if rising_edge(system_clock) then
            create_multiplier(multiplier);
            create_sincos(multiplier , sincos);

            init_example_filter(floating_point_filter_in);
            init_example_filter(fixed_point_filter_in);

            init_bus(bus_from_interconnect);
            connect_read_only_data_to_address(bus_from_master , bus_from_interconnect , input_sine_address                , get_sine(sincos)/2 + 32768);
            connect_read_only_data_to_address(bus_from_master , bus_from_interconnect , input_sine_angle_address          , angle);
            connect_read_only_data_to_address(bus_from_master , bus_from_interconnect , noise_address                     , to_integer(signed(prbs7))+32768);
            connect_read_only_data_to_address(bus_from_master , bus_from_interconnect , noisy_sine_address                , sine_with_noise/2 + 32768);

            connect_read_only_data_to_address(bus_from_master , bus_from_interconnect , 255                , get_cic_filter_output(cic_filter)+32768);
            connect_read_only_data_to_address(bus_from_master , bus_from_interconnect , 256                , filter_bank(2)/2**(22-16));
            connect_data_to_address(bus_from_master           , bus_from_interconnect , example_interconnect_data_address , data_in_example_interconnect);

            if i > 0 then
                i <= (i - 1);
            else
                i <= 1199;
            end if;

            if i = 0 then
                request_sincos(sincos, angle);
                angle    <= (angle + 10) mod 2**16;
                prbs7    <= prbs7(5 downto 0) & prbs7(6);
                prbs7(6) <= prbs7(5) xor prbs7(0);
            end if;

            if sincos_is_ready(sincos) then
                sine_with_noise <= get_sine(sincos) + to_integer(signed(prbs7)*64);
                request_example_filter(floating_point_filter_in, sine_with_noise);
                request_example_filter(fixed_point_filter_in, sine_with_noise);
            end if;

        end if; --rising_edge
    end process;	
---------------
    u_floating_point_filter : entity work.example_filter_entity(float)
        generic map(filter_time_constant => filter_time_constant)
        port map(system_clock, floating_point_filter_in, bus_from_master, bus_from_floating_point_filter);

---------------
    u_fixed_point_filter : entity work.example_filter_entity(fixed_point)
        generic map(filter_time_constant => filter_time_constant)
        port map(system_clock, fixed_point_filter_in, bus_from_master, bus_from_fixed_point_filter);

------------------------------------------------------------------------
------------------------------------------------------------------------
    combine_buses : process(system_clock)
    begin
        if rising_edge(system_clock) then
            bus_to_master <= bus_from_interconnect and bus_from_floating_point_filter and bus_from_fixed_point_filter;
        end if; --rising_edge
    end process combine_buses;	

--------------
    communications_clocks <= (clock => system_clock);
    u_communications : entity work.communications
    port map(
        communications_clocks,
        hvhdl_example_interconnect_FPGA_in.communications_FPGA_in,
        hvhdl_example_interconnect_FPGA_out.communications_FPGA_out,
        communications_data_in ,
        communications_data_out);
------------------------------------------------------------------------
end rtl;
