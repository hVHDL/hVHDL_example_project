-- entity example_filter_entity is
--     generic(filter_time_constant : real);
--     port (
--         clock : in std_logic;
--         example_filter_input : in example_filter_input_record;
--         bus_in              : in fpga_interconnect_record;
--         bus_out             : out fpga_interconnect_record
--     );
-- end entity example_filter_entity;

architecture memory_processor of example_filter_entity is

    use work.float_to_real_conversions_pkg.all;

    use work.example_project_addresses_pkg.all;

    use work.microinstruction_pkg.all;
    use work.multi_port_ram_pkg.all;
    use work.simple_processor_pkg.all;
    use work.processor_configuration_pkg.all;
    use work.float_alu_pkg.all;
    use work.float_type_definitions_pkg.all;
    use work.float_to_real_conversions_pkg.all;

    use work.float_pipeline_pkg.all;

    use work.normalizer_pkg.all;
    use work.denormalizer_pkg.all;
    use work.float_adder_pkg.all;
    use work.float_arithmetic_operations_pkg.all;
    use work.float_multiplier_pkg.all;
    use work.float_example_program_pkg.all;
    use work.memory_processor_pkg.all;
    signal float_alu : float_alu_record := init_float_alu;

    signal converted_integer : std_logic_vector(15 downto 0);

    constant u_address : natural := 80;
    constant y_address : natural := 90;
    constant g_address : natural := 100;
    constant temp_address : natural := 110;

    constant ram_contents : ram_array := build_nmp_sw(0.05 , u_address , y_address , g_address, temp_address);

    signal self_data_in : memory_processor_data_in_record := init_memory_processor_data_in;
    signal self_data_out : memory_processor_data_out_record;

    signal valisignaali : signed(15 downto 0) := (others => '0');

    signal filter_index : natural range 0 to 9 := 5;
    constant filter_index_address : natural range 0 to 511 := filter_output_address+1;


begin

    floating_point_filter : process(clock)
        variable used_instruction : t_instruction;
        constant initial_pipeline_stage : natural := 3;
    begin
        if rising_edge(clock) then
            init_bus(bus_out);
            connect_read_only_data_to_address(bus_in, bus_out, filter_output_address , converted_integer);
            connect_data_to_address(bus_in, bus_out, filter_index_address , filter_index);
            create_float_alu(float_alu);

            init_memory_processor(self_data_in);
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------

            if example_filter_input.filter_is_requested then
                convert_integer_to_float(float_alu, example_filter_input.filter_input, 15);
            end if;

            if int_to_float_is_ready(float_alu) then
                request_processor(self_data_in);
                write_data_to_ram(self_data_in, u_address, to_std_logic_vector(get_converted_float(float_alu)));
            end if;

            if program_is_ready(self_data_out) then
                request_data_from_ram(self_data_in, y_address + filter_index);
            end if;

            if ram_read_is_ready(self_data_out) then
                convert_float_to_integer(float_alu, to_float(get_ram_data(self_data_out)), 14);
            end if;

            if float_to_int_is_ready(float_alu) then
                valisignaali <= to_signed(get_converted_integer(float_alu), 16);
            end if;
            converted_integer <= std_logic_vector(valisignaali + 32768);

        end if; --rising_edge
    end process floating_point_filter;	
------------------------------------------------------------------------
    u_memory_processor : entity work.memory_processor
    generic map(ram_contents)
    port map(clock, self_data_in, self_data_out);
------------------------------------------------------------------------
end memory_processor;
