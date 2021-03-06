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
    use work.denormalizer_pkg.all;
    use work.normalizer_pkg.all;

    constant filter_gain : float_record := to_float(filter_time_constant);

    signal denormalizer : denormalizer_record := init_denormalizer;
    signal normalizer : normalizer_record := init_normalizer;

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
            connect_read_only_data_to_address(bus_in, bus_out, 108, get_integer(denormalizer) + 32768);

            create_float_alu(float_alu);
        ------------------------------------------------------------------------
            filter_is_ready <= false;
            CASE filter_counter is
                WHEN 0 => 
                    subtract(float_alu, u, y);
                    filter_counter <= filter_counter + 1;
                WHEN 1 =>
                    if add_is_ready(float_alu) then
                        multiply(float_alu  , get_add_result(float_alu) , filter_gain);
                        filter_counter <= filter_counter + 1;
                    end if;

                WHEN 2 =>
                    if multiplier_is_ready(float_alu) then
                        add(float_alu, get_multiplier_result(float_alu), y);
                        filter_counter <= filter_counter + 1;
                    end if;
                WHEN 3 => 
                    if add_is_ready(float_alu) then
                        y <= get_add_result(float_alu);
                        filter_counter <= filter_counter + 1;
                        filter_is_ready <= true;
                    end if;
                WHEN others =>  -- wait for start
            end CASE;
        ------------------------------------------------------------------------
            create_denormalizer(denormalizer);
            create_normalizer(normalizer);

            if example_filter_input.filter_is_requested then
                to_float(normalizer, example_filter_input.filter_input, 15);
            end if;

            if normalizer_is_ready(normalizer) then
                request_float_filter(float_filter, get_normalizer_result(normalizer));
            end if;

            request_scaling(denormalizer, get_filter_output(float_filter), 14);


        end if; --rising_edge
    end process floating_point_filter;	
end float;
