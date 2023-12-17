-- entity example_filter_entity is
--     generic(filter_time_constant : real);
--     port (
--         clock : in std_logic;
--         example_filter_input : in example_filter_input_record;
--         bus_in              : in fpga_interconnect_record;
--         bus_out             : out fpga_interconnect_record
--     );
-- end entity example_filter_entity;

architecture microprogram of example_filter_entity is

    use work.first_order_filter_pkg.all;
    use work.multiplier_pkg.all;
    use work.example_project_addresses_pkg.all;
    
    use work.microinstruction_pkg.all;
    use work.test_programs_pkg.all;
    use work.real_to_fixed_pkg.all;
    use work.multi_port_ram_pkg.all;
    use work.microcode_processor_pkg.all;

    ------------------------
    signal ram_read_instruction_in  : ram_read_in_record  ;
    signal ram_read_instruction_out : ram_read_out_record ;
    signal ram_read_data_in         : ram_read_in_record  ;
    signal ram_read_data_out        : ram_read_out_record ;
    signal ram_write_port           : ram_write_in_record ;

    signal result : integer range -2**17 to 2**17-1 := 0;
    signal state_counter : natural range 0 to 2**7-1 := 75;

    constant reg_offset : natural := ram_array'high;

    function test_function_calls return program_array
    is
        constant program : program_array := (
            write_instruction(load_registers, reg_offset-reg_array'length*2),
            write_instruction(stall, 12),
            write_instruction(jump, 0));
    begin
        return program;
        
    end test_function_calls;

    constant dummy           : program_array := get_dummy;
    constant low_pass_filter : program_array := get_pipelined_low_pass_filter;
    constant function_calls  : program_array := test_function_calls;
    constant test_program    : program_array := get_pipelined_low_pass_filter & get_dummy & function_calls;

    function build_sw return ram_array
    is
        variable retval : ram_array := (others => (others => '0'));
        constant reg_values1 : reg_array := to_fixed((0.0 , 0.44252 , 0.3 , filter_time_constant ) , 19);
        constant reg_values2 : reg_array := to_fixed((0.0 , 0.44252 , 0.2 , 0.0804166            ) , 19);
        constant reg_values3 : reg_array := to_fixed((0.0 , 0.44252 , 0.1 , 0.0104166            ) , 19);
    begin

        retval := write_register_values_to_ram(init_ram(test_program) , reg_values1 , reg_offset-reg_array'length*2);
        retval := write_register_values_to_ram(retval                 , reg_values2 , reg_offset-reg_array'length*1);
        retval := write_register_values_to_ram(retval                 , reg_values3 , reg_offset-reg_array'length*0);
            
        return retval;
        
    end build_sw;

    signal self : processor_with_ram_record := init_processor(test_program'high);

begin

    fixed_point_filter : process(clock)
        procedure request_low_pass_filter is
            constant temp : program_array := (get_pipelined_low_pass_filter & get_dummy);
        begin
            self.program_counter <= temp'length;
        end request_low_pass_filter;

    begin
        if rising_edge(clock) then
            init_bus(bus_out);
            connect_read_only_data_to_address(bus_in, bus_out, 15165 , result + 32768);
    ------------------------------------------------------------------------

            create_processor_w_ram(
                self                     ,
                ram_read_instruction_in  ,
                ram_read_instruction_out ,
                ram_read_data_in         ,
                ram_read_data_out        ,
                ram_write_port           ,
                ram_array'length);
    ------------------------------------------------------------------------

            CASE state_counter is
                WHEN 0 => 
                    state_counter <= state_counter+1;
                    request_low_pass_filter;
                WHEN 1 =>
                    if register_load_ready(self) then
                        self.registers(1) <= std_logic_vector(to_signed(example_filter_input.filter_input,self.registers(0)'length));
                        state_counter <= state_counter+1;
                    end if;

                WHEN 2 =>
                    if program_is_ready(self) then
                        save_registers(self, reg_offset-reg_array'length*2);
                        state_counter <= state_counter+1;
                    end if;
                WHEN others => -- do nothing
            end CASE;

            if example_filter_input.filter_is_requested then
                state_counter <= 0;
            end if;
            if decode(get_ram_data(ram_read_instruction_out)) = ready then
                result <= to_integer(signed(self.registers(0)))/2;
            end if;


        end if; --rising_edge
    end process;	
------------------------------------------------------------------------
    u_dpram : entity work.ram_read_x2_write_x1
    generic map(build_sw)
    port map(
    clock                    ,
    ram_read_instruction_in  ,
    ram_read_instruction_out ,
    ram_read_data_in         ,
    ram_read_data_out        ,
    ram_write_port);
------------------------------------------------------------------------

end microprogram;
