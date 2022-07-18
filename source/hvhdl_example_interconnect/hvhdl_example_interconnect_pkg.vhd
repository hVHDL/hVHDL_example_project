library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.communications_pkg.all;

package hvhdl_example_interconnect_pkg is

    type hvhdl_example_interconnect_FPGA_input_group is record
        communications_FPGA_in : communications_FPGA_input_group;
    end record;
    
    type hvhdl_example_interconnect_FPGA_output_group is record
        communications_FPGA_out : communications_FPGA_output_group;
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

entity hvhdl_example_interconnect is
    port (
        system_clock : in std_logic;
        hvhdl_example_interconnect_FPGA_in  : in hvhdl_example_interconnect_FPGA_input_group;
        hvhdl_example_interconnect_FPGA_out : out hvhdl_example_interconnect_FPGA_output_group
    );
end hvhdl_example_interconnect;

architecture rtl of hvhdl_example_interconnect is

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

    constant filter_time_constant : real := 0.001;

begin

    create_noisy_sine : process(system_clock)
    begin
        if rising_edge(system_clock) then
            create_multiplier(multiplier);
            create_sincos(multiplier , sincos);

            init_example_filter(floating_point_filter_in);
            init_example_filter(fixed_point_filter_in);

            init_bus(bus_from_interconnect);
            connect_read_only_data_to_address(bus_from_master, bus_from_interconnect, 100, get_sine(sincos)/2 + 32768);
            connect_read_only_data_to_address(bus_from_master, bus_from_interconnect, 101, angle);
            connect_read_only_data_to_address(bus_from_master, bus_from_interconnect, 102, to_integer(signed(prbs7))+32768);
            connect_read_only_data_to_address(bus_from_master, bus_from_interconnect, 103, sine_with_noise/2 + 32768);

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
