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
    constant dummy           : program_array := get_dummy;
    constant low_pass_filter : program_array := get_pipelined_low_pass_filter;
    constant test_program    : program_array := get_dummy & get_pipelined_low_pass_filter;

    signal self                      : processor_with_ram_record := init_processor(test_program'high);
    signal ram_read_instruction_in  : ram_read_in_record  ;
    signal ram_read_instruction_out : ram_read_out_record ;
    signal ram_read_data_in         : ram_read_in_record  ;
    signal ram_read_data_out        : ram_read_out_record ;
    signal ram_write_port           : ram_write_in_record ;
    signal ram_write_port2          : ram_write_in_record := (0,(others => '0'), '0');


    signal result : integer range -2**17 to 2**17-1 := 0;
    signal test_counter : natural range 0 to 2**7-1 := 75;

    constant ram_contents : ram_array := write_register_values_to_ram(
            init_ram(test_program), 
            to_fixed((0.0 , 0.44252 , 0.1   , 0.1   , 0.1   , 0.1   , 0.1   , 0.0104166 , 0.1)   , 19) , 53-reg_array'length*2);

begin

    fixed_point_filter : process(clock)
        procedure request_low_pass_filter is
        begin
            self.program_counter <= dummy'length;
        end request_low_pass_filter;

    begin
        if rising_edge(clock) then
            init_bus(bus_out);
            connect_read_only_data_to_address(bus_in, bus_out, 15165 , result + 32768);
            create_processor_w_ram(
                self                     ,
                ram_read_instruction_in  ,
                ram_read_instruction_out ,
                ram_read_data_in         ,
                ram_read_data_out        ,
                ram_write_port           ,
                ram_array'length);
    ------------------------------------------------------------------------

            test_counter <= test_counter + 1;
            CASE test_counter is
                WHEN 0 => load_registers(self, 53-reg_array'length*2);
                WHEN 15 => request_low_pass_filter;
                           self.registers(1) <= std_logic_vector(to_signed(example_filter_input.filter_input,self.registers(0)'length));
                WHEN 45 => save_registers(self, 53-reg_array'length*2);
                WHEN 60 => load_registers(self, 15);
                WHEN 75 => test_counter <= 75;
                WHEN others => --do nothing
            end CASE;

            if example_filter_input.filter_is_requested then
                test_counter <= 0;
            end if;
            if decode(get_ram_data(ram_read_instruction_out)) = ready then
               result <= to_integer(signed(self.registers(0)))/2;
            end if;


        end if; --rising_edge
    end process;	
------------------------------------------------------------------------
    u_dpram : entity work.ram_read_x2_write_x1
    generic map(ram_contents)
    port map(
    clock                    ,
    ram_read_instruction_in  ,
    ram_read_instruction_out ,
    ram_read_data_in         ,
    ram_read_data_out        ,
    ram_write_port);
------------------------------------------------------------------------

end microprogram;
