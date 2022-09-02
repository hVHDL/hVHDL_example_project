-- entity example_filter_entity is
--     generic(filter_time_constant : real);
--     port (
--         clock : in std_logic;
--         example_filter_input : in example_filter_input_record;
--         bus_in              : in fpga_interconnect_record;
--         bus_out             : out fpga_interconnect_record
--     );
-- end entity example_filter_entity;

architecture float of example_filter_entity is

    use work.float_type_definitions_pkg.all;
    use work.float_to_real_conversions_pkg.all;
    use work.float_alu_pkg.all;
    use work.float_first_order_filter_pkg.all;
    use work.float_to_integer_converter_pkg.all;
    use work.denormalizer_pkg.all;
    use work.normalizer_pkg.all;

    constant filter_gain : float_record := to_float(filter_time_constant);

    signal float_to_integer_converter : float_to_integer_converter_record := init_float_to_integer_converter;

    signal float_alu : float_alu_record := init_float_alu;
    signal float_filter : first_order_filter_record := init_first_order_filter;

    alias filter_counter  is  float_filter.filter_counter  ;
    alias y               is  float_filter.y               ;
    alias u               is  float_filter.u               ;
    alias filter_is_ready is  float_filter.filter_is_ready;

begin

    floating_point_filter : process(clock)
    begin
        if rising_edge(clock) then
            init_bus(bus_out);
            connect_read_only_data_to_address(bus_in, bus_out, 106, get_mantissa(get_filter_output(float_filter)));
            connect_read_only_data_to_address(bus_in, bus_out, 107, get_exponent(get_filter_output(float_filter)));
            connect_read_only_data_to_address(bus_in, bus_out, 108, get_converted_integer(float_to_integer_converter) + 32768);

            create_float_alu(float_alu);
            create_float_to_integer_converter(float_to_integer_converter);
        ------------------------------------------------------------------------
            create_first_order_filter(float_filter, float_alu, to_float(filter_time_constant));
        ------------------------------------------------------------------------

            if example_filter_input.filter_is_requested then
                convert_integer_to_float(float_to_integer_converter, example_filter_input.filter_input, 15);
            end if;

            if int_to_float_conversion_is_ready(float_to_integer_converter) then
                request_float_filter(float_filter, get_converted_float(float_to_integer_converter));
            end if;

            convert_float_to_integer(float_to_integer_converter, get_filter_output(float_filter), 14);

        end if; --rising_edge
    end process floating_point_filter;	
end float;
