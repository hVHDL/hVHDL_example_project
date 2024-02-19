library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.communications_pkg.all;

package main_pkg is

    type main_FPGA_input_group is record
        communications_FPGA_in : communications_FPGA_input_group;
    end record;
    
    type main_FPGA_output_group is record
        communications_FPGA_out : communications_FPGA_output_group;
    end record;

end package main_pkg;
------------------------------------------------------------------------
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.main_pkg.all;
	use work.multiplier_pkg.all;
	use work.sincos_pkg.all;
    use work.communications_pkg.all;
    use work.fpga_interconnect_pkg.all;
    use work.example_filter_entity_pkg.all;

entity main is
    port (
        system_clock : in std_logic;
        main_FPGA_in  : in main_FPGA_input_group;
        main_FPGA_out : out main_FPGA_output_group
    );
end main;

architecture rtl of main is

    use work.example_project_addresses_pkg.all;

    signal multiplier : multiplier_record := init_multiplier;
    signal sincos     : sincos_record     := init_sincos;

    signal sine_with_noise : int := 0;
    signal angle : integer  range 0 to 2**16-1 := 0;
    signal i     : integer range 0 to 2**16-1 := 1199;
    signal prbs7 : std_logic_vector(6 downto 0) := (0 => '1', others => '0');

    signal communications_clocks   : communications_clock_group;

    signal floating_point_filter_in : example_filter_input_record := init_example_filter_input;
    signal fixed_point_filter_in    : example_filter_input_record := init_example_filter_input;
    signal mcu_in                   : example_filter_input_record := init_example_filter_input;
    signal mcu_in2                  : example_filter_input_record := init_example_filter_input;

    signal bus_from_communications : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_to_communications   : fpga_interconnect_record := init_fpga_interconnect;

    signal bus_from_floating_point_filter : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_fixed_point_filter    : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_mcu                   : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_mcu2                  : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_interconnect          : fpga_interconnect_record := init_fpga_interconnect;

    signal data_in_example_interconnect : integer range 0 to 2**16-1 := 44252;

    constant filter_time_constant : real := 0.024659284639289843679364;
    constant limit_for_100khz : natural := 1199;

begin

    create_noisy_sine : process(system_clock)
        -----------------------------------
        procedure increment_to
        (
            signal counter : inout integer;
            limit : in integer
        ) is
        begin
            if counter < limit then
                counter <= counter + 1;
            else
                counter <= 0;
            end if;
        end increment_to;
        -----------------------------------
        procedure calculate_prbs
        (
            signal prbs : inout std_logic_vector
        ) is
        begin
            prbs    <= prbs(5 downto 0) & prbs(6);
            prbs(6) <= prbs(5) xor prbs(0);
        end calculate_prbs;
        -----------------------------------
    begin
        if rising_edge(system_clock) then
            create_multiplier(multiplier);
            create_sincos(multiplier , sincos);

            init_example_filter(floating_point_filter_in);
            init_example_filter(fixed_point_filter_in);
            init_example_filter(mcu_in);
            init_example_filter(mcu_in2);

            init_bus(bus_from_interconnect);
            connect_read_only_data_to_address(bus_from_communications , bus_from_interconnect , input_sine_address                , get_sine(sincos)/2 + 32768);
            connect_read_only_data_to_address(bus_from_communications , bus_from_interconnect , input_sine_angle_address          , angle);
            connect_read_only_data_to_address(bus_from_communications , bus_from_interconnect , noise_address                     , to_integer(signed(prbs7))+32768);
            connect_read_only_data_to_address(bus_from_communications , bus_from_interconnect , noisy_sine_address                , sine_with_noise/2 + 32768);
            connect_data_to_address(bus_from_communications           , bus_from_interconnect , example_interconnect_data_address , data_in_example_interconnect);

            increment_to(i, limit_for_100khz);

            if i = 0 then
                angle    <= (angle + 10) mod 2**16;
                calculate_prbs(prbs7);

                request_sincos(sincos, angle);

            end if;

            if sincos_is_ready(sincos) then
                sine_with_noise <= get_sine(sincos) + to_integer(signed(prbs7)*64);
                request_example_filter(floating_point_filter_in , sine_with_noise);
                request_example_filter(fixed_point_filter_in    , sine_with_noise);
                request_example_filter(mcu_in                   , sine_with_noise);
                request_example_filter(mcu_in2                  , sine_with_noise);
            end if;

        end if; --rising_edge
    end process;	
------------------------------------------------------------------------
    u_floating_point_filter : entity work.example_filter_entity(float)
        generic map(filter_time_constant => filter_time_constant)
        port map(system_clock, floating_point_filter_in, bus_from_communications, bus_from_floating_point_filter);

---------------
    u_fixed_point_filter : entity work.example_filter_entity(fixed_point)
        generic map(filter_time_constant => filter_time_constant)
        port map(system_clock, fixed_point_filter_in, bus_from_communications, bus_from_fixed_point_filter);
   
---------------
    u_mcu : entity work.example_filter_entity(microprogram)
        generic map(filter_time_constant => filter_time_constant)
        port map(system_clock, mcu_in, bus_from_communications, bus_from_mcu);

---------------
    u_mcu2 : entity work.example_filter_entity(memory_processor)
        generic map(filter_time_constant => filter_time_constant, filter_output_address => 110)
        port map(system_clock, mcu_in2, bus_from_communications, bus_from_mcu2);

------------------------------------------------------------------------
------------------------------------------------------------------------
    combine_buses : process(system_clock)
    begin
        if rising_edge(system_clock) then
            bus_to_communications <= bus_from_interconnect          and
                                     bus_from_floating_point_filter and
                                     bus_from_fixed_point_filter    and
                                     bus_from_mcu                   and
                                     bus_from_mcu2;
        end if; --rising_edge
    end process combine_buses;	

--------------
    communications_clocks <= (clock => system_clock);
    u_communications : entity work.communications
    port map(
        communications_clocks                 ,
        main_FPGA_in.communications_FPGA_in   ,
        main_FPGA_out.communications_FPGA_out ,
        bus_to_communications                 ,
        bus_from_communications);
------------------------------------------------------------------------
end rtl;
