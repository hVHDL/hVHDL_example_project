-- entity example_filter_entity is
--     generic(filter_time_constant : real);
--     port (
--         clock : in std_logic;
--         example_filter_input : in example_filter_input_record;
--         bus_in              : in fpga_interconnect_record;
--         bus_out             : out fpga_interconnect_record
--     );
-- end entity example_filter_entity;

architecture fixed_point of example_filter_entity is

    use work.first_order_filter_pkg.all;
    use work.multiplier_pkg.all;
    use work.example_project_addresses_pkg.all;

    signal filter : first_order_filter_record := init_first_order_filter;
    signal scaled_sine : int := 0;

    signal multiplier2 : multiplier_record := init_multiplier;
    signal process_counter : integer range 0 to 3 := 3;

begin

    fixed_point_filter : process(clock)
    begin
        if rising_edge(clock) then
            init_bus(bus_out);
            connect_read_only_data_to_address(bus_in, bus_out, fixed_point_filter_output_address, get_filter_output(filter)/2 + 32678);
            connect_read_only_data_to_address(bus_in, bus_out, fixed_point_filter_scaled_output_address, scaled_sine/2 + 32678);
            create_multiplier(multiplier2);
            create_first_order_filter(filter => filter , multiplier => multiplier2 , time_constant => filter_time_constant);

            if example_filter_input.filter_is_requested then
                filter_data(filter, example_filter_input.filter_input);
                process_counter <= 0;
            end if;

            CASE process_counter is
                WHEN 0 =>
                    if filter_is_ready(filter) then
                        multiply(multiplier2, get_filter_output(filter), integer(32768.0*3.3942));
                        process_counter <= process_counter + 1;
                    end if;
                WHEN 1 => 
                    if multiplier_is_ready(multiplier2) then
                        scaled_sine <= get_multiplier_result(multiplier2, 15);
                        process_counter <= process_counter + 1;
                    end if;
                WHEN others => -- wait for start
            end CASE;

        end if; --rising_edge
    end process;	

end fixed_point;
