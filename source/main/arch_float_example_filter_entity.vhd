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

    use work.example_project_addresses_pkg.all;

    constant filter_gain : float_record := to_float(filter_time_constant);

    signal float_to_integer_converter : float_to_integer_converter_record := init_float_to_integer_converter;

    signal float_alu : float_alu_record := init_float_alu;
    signal float_filter : first_order_filter_record := init_first_order_filter;

    alias self is float_filter;

begin

    floating_point_filter : process(clock)
    begin
        if rising_edge(clock) then
            init_bus(bus_out);
            connect_read_only_data_to_address(bus_in, bus_out, floating_point_filter_output_mantissa_address, get_mantissa(get_filter_output(float_filter)));
            connect_read_only_data_to_address(bus_in, bus_out, floating_point_filter_output_exponent_address, get_exponent(get_filter_output(float_filter)));
            connect_read_only_data_to_address(bus_in, bus_out, floating_point_filter_integer_output_address , get_converted_integer(float_to_integer_converter) + 32768);

            create_float_alu(float_alu);
            create_float_to_integer_converter(float_to_integer_converter);
            -- create_first_order_filter(float_filter, float_alu, filter_gain);
        ------------------------------------------------------------------------
            -- floating point filter implementation
            self.filter_is_ready <= false;
            CASE self.filter_counter is
                WHEN 0 => 
                    subtract(float_alu, self.u, self.y);
                    self.filter_counter <= self.filter_counter + 1;
                WHEN 1 =>
                    if add_is_ready(float_alu) then
                        multiply(float_alu  , get_add_result(float_alu) , filter_gain);
                        self.filter_counter <= self.filter_counter + 1;
                    end if;

                WHEN 2 =>
                    if multiplier_is_ready(float_alu) then
                        add(float_alu, get_multiplier_result(float_alu), self.y);
                        self.filter_counter <= self.filter_counter + 1;
                    end if;
                WHEN 3 => 
                    if add_is_ready(float_alu) then
                        self.filter_is_ready <= true;
                        self.y <= get_add_result(float_alu);
                        self.filter_counter <= self.filter_counter + 1;
                    end if;
                WHEN others =>  -- wait for start
            end CASE;
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
