library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package iir_filter_pkg is

    type real_array is array (integer range <>) of real;
    type fix_array is array (integer range <>) of integer;

    constant word_length  : integer := 23;
    constant integer_bits : integer := 8;
    constant fractional_bits : integer := word_length-integer_bits;

------------------------------------------------------------------------
    impure function to_fixed ( number : real)
        return integer;
------------------------------------------------------------------------
    impure function to_fixed ( numbers : real_array)
        return fix_array;
------------------------------------------------------------------------
    procedure testi (
        signal memory : inout fix_array;
        input         : in integer;
        signal output : inout integer;
        counter       : in integer;
        b_gains       : in fix_array;
        a_gains       : in fix_array;
        constant counter_offset : in integer);
------------------------------------------------------------------------
    function "*" (
        left : real_array;
        right : real)
    return real_array;
------------------------------------------------------------------------
    function "/" (
        left : real_array;
        right : real)
    return real_array;
------------------------------------------------------------------------

end package iir_filter_pkg;

package body iir_filter_pkg is

    constant double_length   : integer := word_length*2+1;
    ------------------------------
    impure function to_fixed
    (
        number : real
    )
    return integer
    is
    begin
        return integer(number * 2.0**fractional_bits);
    end to_fixed;
    ------------------------------

    impure function to_fixed
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
------------------------------------------------------------------------
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
    begin
        if counter = 0 + counter_offset then output    <= input * b_gains(0) + memory(0);                       end if;
        if counter = 1 + counter_offset then memory(0) <= input * b_gains(1) - output * a_gains(1) + memory(1); end if;
        if counter = 2 + counter_offset then memory(1) <= input * b_gains(2) - output * a_gains(2);             end if;
        
    end testi;

    function "*"
    (
        left : real_array;
        right : real
    )
    return real_array
    is
        variable returned_value : real_array(left'range);
    begin

        for i in left'range loop
            returned_value(i) := left(i) * right;
        end loop;

        return returned_value;
        
    end "*";

    function "/"
    (
        left : real_array;
        right : real
    )
    return real_array
    is
        variable returned_value : real_array(left'range);
    begin
        for i in left'range loop
            returned_value(i) := left(i) / right;
        end loop;

        return returned_value;
    end "/";


end package body iir_filter_pkg;
