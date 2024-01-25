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
    use work.simple_processor_pkg.all;
    use work.command_pipeline_pkg.all;

    ------------------------
    signal ram_read_instruction_in  : ram_read_in_record  ;
    signal ram_read_instruction_out : ram_read_out_record ;
    signal ram_read_data_in         : ram_read_in_record  ;
    signal ram_read_data_out        : ram_read_out_record ;
    signal ram_write_port           : ram_write_in_record ;

    signal result : integer range -2**17 to 2**17-1 := 0;
    signal state_counter : natural range 0 to 2**7-1 := 75;

    signal self             : simple_processor_record                   := init_processor;
    signal command_pipeline : command_pipeline_record                   := init_fixed_point_command_pipeline;
    signal input_buffer     : std_logic_vector(self.registers(0)'range) := (others => '0');

    signal counter : natural range 0 to 7 :=7;
    signal counter2 : natural range 0 to 7 :=7;
    signal result1 : integer range  -2**17 to 2**17-1 := 0;
    signal result2 : integer range  -2**17 to 2**17-1 := 0;
    signal result3 : integer range  -2**17 to 2**17-1 := 0;

    constant final_sw : ram_array := build_sw(filter_time_constant);
    signal request_buffer : boolean := false;

begin

    fixed_point_filter : process(clock)
        variable used_instruction : t_instruction;
    begin
        if rising_edge(clock) then
            init_bus(bus_out);
            connect_read_only_data_to_address(bus_in, bus_out, 15165 , result1 + 32768);
            connect_read_only_data_to_address(bus_in, bus_out, 15166 , result2 + 32768);
            connect_read_only_data_to_address(bus_in, bus_out, 15167 , result3 + 32768);
    ------------------------------------------------------------------------

            create_simple_processor(
                self                     ,
                ram_read_instruction_in  ,
                ram_read_instruction_out ,
                ram_read_data_in         ,
                ram_read_data_out        ,
                ram_write_port           ,
                used_instruction);

            -- create_command_pipeline(
            --     command_pipeline          ,
            --     ram_read_instruction_in   ,
            --     ram_read_instruction_out  ,
            --     ram_read_data_in          ,
            --     ram_read_data_out         ,
            --     ram_write_port            ,
            --     self.registers            ,
            --     self.instruction_pipeline ,
            --     used_instruction);
    ------------------------------------------------------------------------
                
    ------------------------------------------------------------------------

            request_buffer <= example_filter_input.filter_is_requested;
            input_buffer <= std_logic_vector(to_signed(example_filter_input.filter_input,input_buffer'length));
            if request_buffer then
                request_processor(self);
                write_data_to_ram(ram_write_port, 102, input_buffer); 
            end if;

            if program_is_ready(self) then
                counter <= 0;
                counter2 <= 0;
            end if;
            if counter < 7 then
                counter <= counter +1;
            end if;

            CASE counter is
                WHEN 0 => request_data_from_ram(ram_read_data_in, 101);
                WHEN 1 => request_data_from_ram(ram_read_data_in, 104);
                WHEN 2 => request_data_from_ram(ram_read_data_in, 106);
                WHEN others => --do nothing
            end CASE;
            if not processor_is_enabled(self) then
                if ram_read_is_ready(ram_read_data_out) then
                    counter2 <= counter2 + 1;
                    CASE counter2 is
                        WHEN 0 => result1 <= to_integer(signed(get_ram_data(ram_read_data_out))) / 2;
                        WHEN 1 => result2 <= to_integer(signed(get_ram_data(ram_read_data_out))) / 2;
                        WHEN 2 => result3 <= to_integer(signed(get_ram_data(ram_read_data_out))) / 2;
                        WHEN others => -- do nothing
                    end CASE; --counter2
                end if;
            end if;


        end if; --rising_edge
    end process;	
------------------------------------------------------------------------
    u_dpram : entity work.ram_read_x2_write_x1
    generic map(final_sw)
    port map(
    clock                    ,
    ram_read_instruction_in  ,
    ram_read_instruction_out ,
    ram_read_data_in         ,
    ram_read_data_out        ,
    ram_write_port);
------------------------------------------------------------------------

end microprogram;
