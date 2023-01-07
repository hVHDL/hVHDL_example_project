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

------------------------------------------------------------------------
    function fixed_point
    (
        number : real; fractional_bits : natural
    )
    return integer
    is
        variable returned_value : integer;
    begin
        returned_value := integer(number*2.0**fractional_bits);
        return returned_value;
    end fixed_point;
------------------------------------------------------------------------
    function fraction_length
    (
        number_of_bits : natural
    )
    return natural
    is
    begin
        return number_of_bits;
    end fraction_length;

------------------------------------------------------------------------
    function integer_bit_length
    (
        number_of_integer_bits : natural
    )
    return natural
    is
    begin

        return 17 - number_of_integer_bits;
        
    end integer_bit_length;

begin

    fixed_point_filter : process(clock)
        variable radix : integer := 15;

        impure function "*" ( left, right : integer)
        return integer
        is
            constant word_length : integer := 18;
        begin
            return work.multiplier_pkg.radix_multiply(left,right, word_length, radix);
        end "*";

    begin
        if rising_edge(clock) then
            init_bus(bus_out);
            radix := 12;
            connect_read_only_data_to_address(bus_in , bus_out , fixed_point_filter_output_address        , get_filter_output(filter)*fixed_point(1.8, fraction_length(12)) + fixed_point(0.5, integer_bit_length(1)));
            connect_read_only_data_to_address(bus_in , bus_out , fixed_point_filter_scaled_output_address , scaled_sine/2 + fixed_point(0.5, integer_bit_length(1)));
            create_multiplier(multiplier2);
            create_first_order_filter(filter => filter , multiplier => multiplier2 , time_constant => filter_time_constant);

            if example_filter_input.filter_is_requested then
                filter_data(filter, example_filter_input.filter_input);
                process_counter <= 0;
            end if;

            radix := 15;
            scaled_sine <= get_filter_output(filter) * fixed_point(2.10644572391518, integer_bit_length(2));

        end if; --rising_edge
    end process;	

end fixed_point;
