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
    type fix_array is array (integer range <>) of integer;

    constant word_length  : integer := 30;
    constant integer_bits : integer := 11;

    constant double_length   : integer := word_length*2+1;
    constant fractional_bits : integer := word_length-integer_bits;

    ------------------------------
    function to_fixed
    (
        number : real
    )
    return integer
    is
    begin
        return integer(number * 2.0**fractional_bits);
    end to_fixed;
    ------------------------------

    function to_fixed
    (
        numbers : real_array
    )
    return fix_array
    is
        variable return_array : fix_array(numbers'range);
    begin
        for i in numbers'range loop
            return_array(i) := to_fixed(numbers(i));
        end loop;

        return return_array;
    end to_fixed;

    ------------------------------
    signal state_counter : integer := 0;

    signal memory1 : real_array(0 to 1) := (others => 0.0);
    signal memory2 : real_array(0 to 1) := (others => 0.0);
    signal memory3 : real_array(0 to 1) := (others => 0.0);

    signal fix_memory1 : fix_array(0 to 1) := (others => 0);
    signal fix_memory2 : fix_array(0 to 1) := (others => 0);
    signal fix_memory3 : fix_array(0 to 1) := (others => 0);

    constant b1 : real_array(0 to 2) := (1.00000000e+00,  2.00000000e+00,  1.00000000e+00);
    constant b2 : real_array(0 to 2) := (1.00000000e+00, -2.00000000e+00,  1.00000000e+00);
    constant b3 : real_array(0 to 2) := (1.00000000e+00, -2.00000000e+00,  1.00000000e+00);

    constant a1 : real_array(0 to 2) := (1.0 , -1.5799684  , 0.9714939);
    constant a2 : real_array(0 to 2) := (1.0 , -1.61181083 , 0.97251271);
    constant a3 : real_array(0 to 2) := (1.0 , -1.64588207 , 0.98883429);

    constant fix_b1 : fix_array(0 to 2) := to_fixed(b1);
    constant fix_b2 : fix_array(0 to 2) := to_fixed(b2);
    constant fix_b3 : fix_array(0 to 2) := to_fixed(b3);

    constant fix_a1 : fix_array(0 to 2) := to_fixed(a1);
    constant fix_a2 : fix_array(0 to 2) := to_fixed(a2);
    constant fix_a3 : fix_array(0 to 2) := to_fixed(a3);

    signal filter_out : real := 0.0;
    signal filter_out1 : real := 0.0;
    signal filter_out2 : real := 0.0;

    signal fix_filter_out  : integer := 0;
    signal fix_filter_out1 : integer := 0;
    signal fix_filter_out2 : integer := 0;

    signal should_be_12 : real := 0.0;

    signal real_filter_output : real := 0.0;
    signal fixed_filter_output : real := 0.0;

    signal filter_error : real := 0.0;
    signal max_calculation_error : real := 0.0;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        check(max_calculation_error < 0.1, "calculation error is " & real'image(max_calculation_error));
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)
    --------------------------
        function "*"
        (
            left, right : integer
        )
        return integer
        is
            variable s_left, s_right : signed(word_length downto 0);
            variable mult_result     : signed(double_length downto 0);
        begin
            s_left  := to_signed(left  , word_length+1);
            s_right := to_signed(right , word_length+1);
            mult_result := s_left * s_right;
            return to_integer(mult_result(word_length + fractional_bits downto fractional_bits));
        end "*";
    --------------------------
        procedure real_testi
        (
            signal memory : inout real_array;
            input         : in real;
            signal output : inout real;
            counter       : in integer;
            b_gains       : in real_array;
            a_gains       : in real_array;
            constant counter_offset : in integer
        ) is
        begin
            if counter = 0 + counter_offset then output    <= input * b_gains(0) + memory(0);                       end if;
            if counter = 1 + counter_offset then memory(0) <= input * b_gains(1) - output * a_gains(1) + memory(1); end if;
            if counter = 2 + counter_offset then memory(1) <= input * b_gains(2) - output * a_gains(2);             end if;
        end real_testi;

    --------------------------
        procedure testi
        (
            signal memory : inout fix_array;
            input         : in integer;
            signal output : inout integer;
            counter       : in integer;
            b_gains       : in fix_array;
            a_gains       : in fix_array;
            constant counter_offset : in integer
        ) is
        begin
            if counter = 0 + counter_offset then output    <= input * b_gains(0) + memory(0);                       end if;
            if counter = 1 + counter_offset then memory(0) <= input * b_gains(1) - output * a_gains(1) + memory(1); end if;
            if counter = 2 + counter_offset then memory(1) <= input * b_gains(2) - output * a_gains(2);             end if;
            
        end testi;

    --------------------------
        constant filter_input : real := 1.0;
    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            state_counter <= simulation_counter mod 5;
            real_testi(memory1 , filter_input , filter_out  , state_counter , b1 , a1 , 0);
            real_testi(memory2 , filter_out   , filter_out1 , state_counter , b2 , a2 , 1);
            real_testi(memory3 , filter_out1  , filter_out2 , state_counter , b3 , a3 , 2);

        ------------------------------------------------------------------------
            testi(fix_memory1 , to_fixed(filter_input) , fix_filter_out  , state_counter , fix_b1 , fix_a1 , 0);
            testi(fix_memory2 , fix_filter_out         , fix_filter_out1 , state_counter , fix_b2 , fix_a2 , 1);
            testi(fix_memory3 , fix_filter_out1        , fix_filter_out2 , state_counter , fix_b3 , fix_a3 , 2);

            -- check values
            real_filter_output  <= filter_out2;
            fixed_filter_output <= real(fix_filter_out2)/2.0**fractional_bits;
            filter_error <= real_filter_output - fixed_filter_output;
            if abs(filter_error) > max_calculation_error then
                max_calculation_error <= abs(filter_error);
            end if;
            should_be_12 <= real(to_fixed(3.0) * to_fixed(4.0))/2.0**fractional_bits;

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
