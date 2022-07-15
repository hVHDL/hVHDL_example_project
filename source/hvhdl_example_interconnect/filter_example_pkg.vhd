library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

	use work.multiplier_pkg.all;
	use work.sincos_pkg.all;
    use work.first_order_filter_pkg.all;

package filter_example_pkg is

------------------------------------------------------------------------
    type filter_example_record is record
        multiplier       : multiplier_record            ;
        multiplier2      : multiplier_record            ;
        sincos           : sincos_record                ;
        filter           : first_order_filter_record    ;
        angle            : integer  range 0 to 2**16-1  ;
        i                : integer range 0 to 2**16-1   ;
        prbs7            : std_logic_vector(6 downto 0) ;
        harmonic_counter : integer range 0 to 15        ;
        sine_with_noise  : int                          ;
        filtered_sine    : int                          ;
        program_counter  : integer  range 0 to 7        ;
    end record;
------------------------------------------------------------------------
    constant init_filter_example : filter_example_record := (
        multiplier       => init_multiplier           ,
        multiplier2      => init_multiplier           ,
        sincos           => init_sincos               ,
        filter           => init_first_order_filter   ,
        angle            => 0                         ,
        i                => 1199                      ,
        prbs7            => (0 => '1', others => '0') ,
        harmonic_counter => 15                        ,
        sine_with_noise  => 0                         ,
        filtered_sine    => 0                         ,
        program_counter  => 0);
------------------------------------------------------------------------

    procedure create_filter_example (
        signal filter_example_object : inout filter_example_record);

    function get_sine ( filter_example_object : filter_example_record)
        return integer;

    function get_angle ( filter_example_object : filter_example_record)
        return integer;

    function get_noise_signal ( filter_example_object : filter_example_record)
        return integer;

    function get_noisy_sine ( filter_example_object : filter_example_record)
        return integer;

    function get_filtered_sine ( filter_example_object : filter_example_record)
        return integer;

end package filter_example_pkg;

package body filter_example_pkg is

    procedure create_filter_example
    (
        signal filter_example_object : inout filter_example_record
    ) is
        alias m is filter_example_object;
        --------------------------------------------------
        procedure increment_program_counter
        (
            signal counter_object : inout integer
        ) is
        begin
            counter_object <= counter_object + 1;
        end increment_program_counter;
        --------------------------------------------------
        procedure calculate_prbs7
        (
            signal prbs_object : inout std_logic_vector 
        ) is
        begin
            prbs_object    <= prbs_object(5 downto 0) & prbs_object(6);
            prbs_object(6) <= prbs_object(5) xor prbs_object(0);
            
        end calculate_prbs7;
        --------------------------------------------------
    begin
        create_multiplier(m.multiplier);
        create_multiplier(m.multiplier2);
        create_sincos(m.multiplier, m.sincos);
        create_first_order_filter(filter =>m.filter,multiplier => m.multiplier2, time_constant => 0.001);

        if m.i > 0 then
            m.i <= (m.i - 1);
        else
            m.i <= 1199;
        end if;

        if m.i = 0 then
            m.program_counter <= 0;
        end if;

        CASE m.program_counter is
            WHEN 0 =>
                request_sincos(m.sincos, m.angle);
                increment_program_counter(m.program_counter);
            WHEN 1 =>
                if sincos_is_ready(m.sincos) then
                    m.angle    <= (m.angle + 10) mod 2**16;
                    calculate_prbs7(m.prbs7);
                    filter_data(m.filter, m.sine_with_noise);
                    m.sine_with_noise <= get_sine(m.sincos) + to_integer(signed(m.prbs7)*64);

                    increment_program_counter(m.program_counter);
                end if;

            WHEN 2 =>
                if filter_is_ready(m.filter) then
                    multiply(m.multiplier, get_filter_output(m.filter), integer(32768.0*2.3138));

                    increment_program_counter(m.program_counter);
                end if;

            WHEN 3 =>
                if multiplier_is_ready(m.multiplier) then
                    m.filtered_sine <= get_multiplier_result(m.multiplier, 15);

                    increment_program_counter(m.program_counter);
                end if;
            WHEN others => -- hang here and wait for start
        end CASE;
        
    end create_filter_example;
------------------------------------------------------------------------
    function get_sine
    (
        filter_example_object : filter_example_record
    )
    return integer
    is
    begin
        return get_sine(filter_example_object.sincos)/2 +32768;
    end get_sine;

    function get_angle
    (
        filter_example_object : filter_example_record
    )
    return integer
    is
    begin
        return filter_example_object.angle;
    end get_angle;

    function get_noise_signal
    (
        filter_example_object : filter_example_record
    )
    return integer
    is
    begin
        return to_integer(signed(filter_example_object.prbs7))+ 32768;
    end get_noise_signal;

    function get_noisy_sine
    (
        filter_example_object : filter_example_record
    )
    return integer
    is
    begin
        return filter_example_object.sine_with_noise/2 + 32768;
    end get_noisy_sine;

    function get_filtered_sine
    (
        filter_example_object : filter_example_record
    )
    return integer
    is
    begin
        return filter_example_object.filtered_sine/2 + 32768;
    end get_filtered_sine;


end package body filter_example_pkg;
