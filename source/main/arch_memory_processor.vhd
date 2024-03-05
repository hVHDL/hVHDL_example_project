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

    signal float_alu : float_alu_record := init_float_alu;

    signal converted_integer : std_logic_vector(15 downto 0);

    constant u_address : natural := 80;
    constant y_address : natural := 90;
    constant g_address : natural := 100;
    constant temp_address : natural := 110;

    constant ram_contents : ram_array := build_nmp_sw(0.05 , u_address , y_address , g_address, temp_address);

    signal self                : simple_processor_record := init_processor;
    signal ram_read_instruction_in  : ram_read_in_record  := (0, '0');
    signal ram_read_instruction_out : ram_read_out_record ;
    signal ram_read_data_in         : ram_read_in_record  := (0, '0');
    signal ram_read_data_out        : ram_read_out_record ;
    signal ram_read_2_data_in       : ram_read_in_record  := (0, '0');
    signal ram_read_2_data_out      : ram_read_out_record ;
    signal ram_read_3_data_in       : ram_read_in_record  := (0, '0');
    signal ram_read_3_data_out      : ram_read_out_record ;
    signal ram_write_port           : ram_write_in_record ;

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

            create_simple_processor (
                self                ,
                ram_read_instruction_in  ,
                ram_read_instruction_out ,
                ram_read_data_in         ,
                ram_read_data_out        ,
                ram_write_port           ,
                used_instruction);

            init_ram_read(ram_read_2_data_in);
            init_ram_read(ram_read_3_data_in);
            create_float_alu(float_alu);

            --stage -1
            CASE decode(used_instruction) is
                -- WHEN load =>
                --     request_data_from_ram(ram_read_data_in , get_sigle_argument(used_instruction));
                WHEN add => 
                    request_data_from_ram(ram_read_data_in   , get_arg1(used_instruction));
                    request_data_from_ram(ram_read_2_data_in , get_arg2(used_instruction));
                WHEN sub =>
                    request_data_from_ram(ram_read_data_in   , get_arg1(used_instruction));
                    request_data_from_ram(ram_read_2_data_in , get_arg2(used_instruction));
                WHEN mpy =>
                    request_data_from_ram(ram_read_data_in   , get_arg1(used_instruction));
                    request_data_from_ram(ram_read_2_data_in , get_arg2(used_instruction));
                WHEN mpy_add =>
                    request_data_from_ram(ram_read_data_in   , get_arg1(used_instruction));
                    request_data_from_ram(ram_read_2_data_in , get_arg2(used_instruction));
                    request_data_from_ram(ram_read_3_data_in , get_arg3(used_instruction));
                WHEN others => -- do nothing
            end CASE;
        ------------------------------------------------------------------------
            --stage 2
            used_instruction := self.instruction_pipeline(2);

            CASE decode(used_instruction) is
                -- WHEN load =>
                --     self.registers(get_dest(used_instruction)) <= get_ram_data(ram_read_data_out);

                WHEN add => 
                    fmac(float_alu                                ,
                        to_float(1.0)                             ,
                        to_float(get_ram_data(ram_read_data_out)) ,
                        to_float(get_ram_data(ram_read_2_data_out)));
                WHEN sub =>
                    fmac(float_alu                                  ,
                        to_float(-1.0)                              ,
                        to_float(get_ram_data(ram_read_2_data_out)) ,
                        to_float(get_ram_data(ram_read_data_out)));
                WHEN mpy =>
                    fmac(float_alu                                  ,
                        to_float(get_ram_data(ram_read_data_out))   ,
                        to_float(get_ram_data(ram_read_2_data_out)) ,
                        to_float(0.0));
                WHEN mpy_add =>
                    fmac(float_alu                                  ,
                        to_float(get_ram_data(ram_read_data_out))   ,
                        to_float(get_ram_data(ram_read_2_data_out)) ,
                        to_float(get_ram_data(ram_read_3_data_out)));
                WHEN others => -- do nothing
            end CASE;
        ----------------------
            used_instruction := self.instruction_pipeline(initial_pipeline_stage + alu_timing.madd_pipeline_depth-1);
            CASE decode(used_instruction) is
                WHEN add | sub | mpy | mpy_add => 
                    write_data_to_ram(ram_write_port, get_dest(used_instruction), to_std_logic_vector(get_add_result(float_alu)));
                WHEN others => -- do nothing
            end CASE;
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------

            if example_filter_input.filter_is_requested then
                convert_integer_to_float(float_alu, example_filter_input.filter_input, 15);
            end if;

            if int_to_float_is_ready(float_alu) then
                request_processor(self);
                write_data_to_ram(ram_write_port, u_address, to_std_logic_vector(get_converted_float(float_alu)));
            end if;

            if program_is_ready(self) then
                request_data_from_ram(ram_read_3_data_in, y_address + filter_index);
            end if;

            if not processor_is_enabled(self) then
                if ram_read_is_ready(ram_read_3_data_out) then
                    convert_float_to_integer(float_alu, to_float(get_ram_data(ram_read_3_data_out)), 14);
                end if;
            end if;

            if float_to_int_is_ready(float_alu) then
                valisignaali <= to_signed(get_converted_integer(float_alu), 16);
            end if;
            converted_integer <= std_logic_vector(valisignaali + 32768);

        end if; --rising_edge
    end process floating_point_filter;	
------------------------------------------------------------------------
    u_mpram : entity work.ram_read_x4_write_x1
    generic map(ram_contents)
    port map(
    clock                    ,
    ram_read_instruction_in  ,
    ram_read_instruction_out ,
    ram_read_data_in         ,
    ram_read_data_out        ,
    ram_read_2_data_in       ,
    ram_read_2_data_out      ,
    ram_read_3_data_in       ,
    ram_read_3_data_out      ,
    ram_write_port);
------------------------------------------------------------------------
end memory_processor;
