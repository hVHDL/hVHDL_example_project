LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.fpga_interconnect_pkg.all;
    use work.example_filter_entity_pkg.all;
    use work.example_project_addresses_pkg.mcu_filter_output_address;

entity float_mcu_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of float_mcu_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 50000;
    
    signal simulator_clock     : std_logic := '0';
    alias system_clock is simulator_clock;
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----
    signal mcu_in : example_filter_input_record := init_example_filter_input;
    signal bus_from_communications : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_to_communications   : fpga_interconnect_record := init_fpga_interconnect;

    signal bus_from_mcu   : fpga_interconnect_record := init_fpga_interconnect;

    constant filter_time_constant : real := 0.01;

    signal data_was_read_from_mcu : boolean := false;
    signal data_from_filter : real := 32768.0;
    signal input_data : integer := 0;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        check(data_was_read_from_mcu, "data was never read");
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)
        variable filter_input : integer := 0;

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
            filter_input := integer(32768.0*sin(real(simulation_counter mod 10000)/10000.0*2.0*math_pi));

            init_example_filter(mcu_in);
            init_bus(bus_from_communications);
            if simulation_counter mod 100 = 0 then
                request_example_filter(mcu_in, filter_input);
                request_data_from_address(bus_from_communications, mcu_filter_output_address);
                input_data <= filter_input;
            end if;

            data_was_read_from_mcu <= data_was_read_from_mcu or read_is_requested(bus_from_mcu);
            if write_to_address_is_requested(bus_from_mcu,0) then
                data_from_filter <= real(get_data(bus_from_mcu));
            end if;


        end if; -- rising_edge
    end process stimulus;	

    u_mcu : entity work.example_filter_entity(microprogram)
        generic map(filter_time_constant => filter_time_constant)
        port map(system_clock, mcu_in, bus_from_communications, bus_from_mcu);
------------------------------------------------------------------------
end vunit_simulation;
