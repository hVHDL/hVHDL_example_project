LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;
    
    use work.sos_pkg.all;

entity filter_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of filter_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 5000;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal filter_in   : real := 1.0;

    signal sos1 : sos_real := init_sos_gains(
        a => (1.00000000e+00, -1.57996840e+00,  9.71493904e-01) ,
        b => (1.00000000e+00,  2.00000000e+00,  1.00000000e+00));

    signal sos2 : sos_real := init_sos_gains(
        a => (1.00000000e+00, -1.61181083e+00,  9.72512711e-01) ,
        b => (1.00000000e+00, -2.00000000e+00,  1.00000000e+00));
    
    signal filter_out2 : real := 0.0;

    signal filter_counter : integer := 0;

    signal filter_out1 : real:= 0.0;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)


    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            create_sos(sos1, filter_in);
            create_sos(sos2, sos1.filter_out);

            if simulation_counter mod 4 = 0 then
                sos1.sos_filter_counter <= 0;
            end if;

            if sos1.sos_filter_counter = 0 then
                sos2.sos_filter_counter <= 0;
            end if;

            -- just to check testbench
            filter_out1 <= sos1.filter_out;
            filter_out2 <= sos2.filter_out;
        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
