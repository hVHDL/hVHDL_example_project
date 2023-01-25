library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

package sos_pkg is

    type real_array is array (integer range <>) of real;

    type sos_real is record
        memory : real_array(0 to 1);
        a : real_array(0 to 2)     ;
        b : real_array(0 to 2)     ;
        filter_out : real          ;
        sos_filter_counter : integer;
    end record;

    function init_sos_gains ( a, b : real_array)
        return sos_real;

    procedure create_sos (
        signal sos_object : inout sos_real;
        filter_input : real);

end package sos_pkg;

package body sos_pkg is

    function init_sos_gains
    (
        a, b : real_array
    )
    return sos_real
    is
        variable initialized_sos : sos_real;
    begin
        initialized_sos := (
        (others => 0.0) ,
        a               ,
        b               ,
        0.0             ,
        0 );

        return initialized_sos;
    end init_sos_gains;

    procedure create_sos
    (
        signal sos_object : inout sos_real;
        filter_input : real
    ) is
        alias m is sos_object;
    begin
        if m.sos_filter_counter < 2 then 
            m.sos_filter_counter <= m.sos_filter_counter + 1;
        end if;
                                                     
        CASE m.sos_filter_counter is
            WHEN 0 => m.filter_out <= filter_input*m.b(0) + m.memory(0);
            WHEN 1 => m.memory(0)  <= filter_input*m.b(1) - m.a(1) * m.filter_out + m.memory(1);
            WHEN 2 => m.memory(1)  <= filter_input*m.b(2) - m.a(2) * m.filter_out;
            WHEN others => -- do nothing
        end CASE; --filter_counter
    end create_sos;

end package body sos_pkg;

