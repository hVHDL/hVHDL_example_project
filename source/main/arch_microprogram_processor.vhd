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
    use work.ram_read_pkg.all;
    use work.ram_write_pkg.all;
    use work.real_to_fixed_pkg.all;
    use work.microcode_processor_pkg.all;

    function init_ram(program : program_array) return ram_array
    is
        variable retval : ram_array := (others => (others => '0'));
    begin

        for i in program'range loop
            retval(i) := program(i);
        end loop;

        return retval;
    end init_ram;
    ------------------------
    constant dummy           : program_array := get_dummy;
    constant low_pass_filter : program_array := get_pipelined_low_pass_filter;
    constant test_program    : program_array := get_dummy & get_pipelined_low_pass_filter;

    signal self                      : processor_with_ram_record := init_processor(test_program'high);
    signal ram_read_instruction_port : ram_read_port_record    := init_ram_read_port ;
    signal ram_read_data_port        : ram_read_port_record    := init_ram_read_port ;
    signal ram_write_port            : ram_write_port_record   := init_ram_write_port;
    signal ram_write_port2           : ram_write_port_record   := init_ram_write_port;

    signal result : integer range -2**15 to 2**15-1 := 0;

    signal ram_contents : ram_array := write_register_values_to_ram(
            init_ram(test_program), 
            to_fixed((0.0 , 0.44252 , 0.1   , 0.1   , 0.1   , 0.1   , 0.1   , 0.0104166 , 0.1)   , 19) , 53-reg_array'length*2);

begin

    fixed_point_filter : process(clock)
        procedure request_low_pass_filter is
        begin
            self.program_counter <= dummy'length;
        end request_low_pass_filter;



        constant register_memory_start_address : integer := ram_contents'length-self.registers'length;
    begin
        if rising_edge(clock) then
            init_bus(bus_out);
            connect_read_only_data_to_address(bus_in, bus_out, 15165 , result/2 + 32768);

            create_ram_read_port(ram_read_instruction_port);
            create_ram_read_port(ram_read_data_port);
            create_ram_write_port(ram_write_port);
            -- create_ram_write_port(ram_write_port2);
            --------------------
            if read_is_requested(ram_read_instruction_port) then
                ram_read_instruction_port.data <= ram_contents(get_ram_address(ram_read_instruction_port));
            end if;
            --------------------
            if read_is_requested(ram_read_data_port) then
                ram_read_data_port.data <= ram_contents(get_ram_address(ram_read_data_port));
            end if;
            --------------------
            if write_is_requested(ram_write_port) then
                ram_contents(get_write_address(ram_write_port)) <= ram_write_port.write_buffer;
            end if;
            --------------------
            -- if write_is_requested(ram_write_port2) then
            --     ram_contents(get_write_address(ram_write_port2)) <= ram_write_port2.write_buffer;
            -- end if;
            --------------------

            create_processor_w_ram(
                self                      ,
                ram_read_instruction_port ,
                ram_read_data_port        ,
                ram_write_port            ,
                ram_write_port2           ,
                ram_array'length);
    ------------------------------------------------------------------------
            if example_filter_input.filter_is_requested then
                request_low_pass_filter;
            end if;
            if decode(get_ram_data(ram_read_instruction_port)) = ready then
               result <= to_integer(signed(self.registers(0)));
            end if;

        end if; --rising_edge
    end process;	

end microprogram;
