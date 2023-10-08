------------------------------------------------------------------------
LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;


	use work.multiplier_pkg.all;
	use work.sincos_pkg.all;
    use work.fixed_sqrt_pkg.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity sqrt_sine_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of sqrt_sine_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 50000;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----
    signal multiplier : multiplier_record := init_multiplier;
    signal sincos     : sincos_record     := init_sincos;
    signal sqrt : fixed_sqrt_record := init_sqrt;

    signal angle : natural := 0;

    signal result : signed(17 downto 0) := (others => '0');

    signal was_run : boolean := false;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        check(was_run);
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
            create_multiplier(multiplier);
            create_sincos(multiplier , sincos);
            create_sqrt(sqrt,multiplier);

            if sqrt_is_ready(sqrt) or simulation_counter = 10 then
                angle <= (angle + 500) mod 2**16;
                request_sincos(sincos, angle);
            end if;

            if sincos_is_ready(sincos) then
                request_sqrt(sqrt, to_signed(get_sine(sincos)/2+20000, 18));
            end if;

            if sqrt_is_ready(sqrt) then
                result <= get_sqrt_result(sqrt, multiplier, 15);
            end if;
            was_run <= was_run or sqrt_is_ready(sqrt);

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
