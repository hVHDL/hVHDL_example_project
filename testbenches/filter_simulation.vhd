LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity filter_simulation_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of filter_simulation_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 3000;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    type real_array is array (integer range <>) of real;
    signal memory1 : real_array(0 to 1) := (others => 0.0);
    signal memory2 : real_array(0 to 1) := (others => 0.0);
    signal memory3 : real_array(0 to 1) := (others => 0.0);

    constant b1 : real_array(0 to 2) := (1.00000000e+00,  2.00000000e+00,  1.00000000e+00);
    constant b2 : real_array(0 to 2) := (1.00000000e+00, -2.00000000e+00,  1.00000000e+00);
    constant b3 : real_array(0 to 2) := (1.00000000e+00, -2.00000000e+00,  1.00000000e+00);

    constant a1 : real_array(0 to 2) := (1.0 , -1.5799684  , 0.9714939);
    constant a2 : real_array(0 to 2) := (1.0 , -1.61181083 , 0.97251271);
    constant a3 : real_array(0 to 2) := (1.0 , -1.64588207 , 0.98883429);

    signal state_counter : integer := 0;

    signal filter_out : real := 0.0;
    signal filter_out1 : real := 0.0;
    signal filter_out2 : real := 0.0;

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

        constant filter_input : real := 1.0;
    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            state_counter <= simulation_counter mod 5;
            CASE state_counter is
                WHEN 0 => filter_out <= filter_input * b1(0) + memory1(0);
                WHEN 1 => memory1(0) <= filter_input * b1(1) - filter_out * a1(1) + memory1(1);
                WHEN 2 => memory1(1) <= filter_input * b1(2) - filter_out * a1(2);
                WHEN others => -- do nothing
            end CASE;

            CASE state_counter is 
                WHEN 1 => filter_out1 <= filter_out * b2(0) + memory2(0);
                WHEN 2 => memory2(0)  <= filter_out * b2(1) - filter_out1 * a2(1) + memory2(1);
                WHEN 3 => memory2(1)  <= filter_out * b2(2) - filter_out1 * a2(2);
                WHEN others => -- do nothing
            end CASE;

            CASE state_counter is 
                WHEN 2 => filter_out2 <= filter_out1 * b3(0) + memory3(0);
                WHEN 3 => memory3(0)  <= filter_out1 * b3(1) - filter_out2 * a3(1) + memory3(1);
                WHEN 4 => memory3(1)  <= filter_out1 * b3(2) - filter_out2 * a3(2);
                WHEN others => -- do nothing
            end CASE;

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
