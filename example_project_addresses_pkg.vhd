library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package example_project_addresses_pkg is

    constant example_interconnect_data_address : integer := 99;

    constant input_sine_address                            : integer := 100;
    constant input_sine_angle_address                      : integer := 101;
    constant noise_address                                 : integer := 102;
    constant noisy_sine_address                            : integer := 102;

    constant fixed_point_filter_output_address             : integer := 104;
    constant fixed_point_filter_scaled_output_address      : integer := 105;

    constant floating_point_filter_output_mantissa_address : integer := 106;
    constant floating_point_filter_output_exponent_address : integer := 107;
    constant floating_point_filter_integer_output_address  : integer := 108;

end package example_project_addresses_pkg;
