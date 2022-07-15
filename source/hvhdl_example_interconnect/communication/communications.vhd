
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.uart_pkg.all;
    use work.fpga_interconnect_pkg.all;

package communications_pkg is

    type communications_clock_group is record
        clock : std_logic;
    end record;
    
    type communications_FPGA_input_group is record
        uart_FPGA_in  : uart_FPGA_input_group;
    end record;
    
    type communications_FPGA_output_group is record
        uart_FPGA_out : uart_FPGA_output_group;
    end record;
    
    type communications_data_input_group is record
        bus_in : fpga_interconnect_record;
    end record;
    
    type communications_data_output_group is record
        bus_out : fpga_interconnect_record;
    end record;
    
end package communications_pkg;
------------------------------------------------------------------------
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.communications_pkg.all;
    use work.uart_pkg.all;
    use work.fpga_interconnect_pkg.all;

entity communications is
    port (
        communications_clocks   : in communications_clock_group;
        communications_FPGA_in  : in communications_FPGA_input_group;
        communications_FPGA_out : out communications_FPGA_output_group;
        communications_data_in  : in communications_data_input_group;
        communications_data_out : out communications_data_output_group
    );
end entity communications;

architecture rtl of communications is

    alias clock is communications_clocks.clock; 
    alias bus_out is communications_data_out.bus_out;
    alias bus_in  is communications_data_in.bus_in;

    signal uart_clocks   : uart_clock_group;
    signal uart_FPGA_in  : uart_FPGA_input_group;
    signal uart_FPGA_out : uart_FPGA_output_group;
    signal uart_data_in  : uart_data_input_group;
    signal uart_data_out : uart_data_output_group;

    signal counter : integer range 0 to 2**12-1 := 1199; 

    signal data_from_uart : integer range 0 to 2**16-1 :=0;

------------------------------------------------------------------------
    function get_address
    (
        uart_output : integer
    )
    return integer
    is
        variable unsigned_data : unsigned(15 downto 0);
    begin
        unsigned_data := to_unsigned(uart_output,16);
        return to_integer(unsigned_data(15 downto 12));
        
    end get_address;

------------------------------------------------------------------------
    function get_data
    (
        uart_output : integer
    )
    return integer
    is
        variable unsigned_data : unsigned(15 downto 0);
    begin
        unsigned_data := to_unsigned(uart_output,16);
        return to_integer(unsigned_data(11 downto 0));
    end get_data;
------------------------------------------------------------------------
    procedure count_down_from
    (
        signal counter_object : inout integer;
        max_value_for_counter : in integer
    ) is
    begin
        if counter_object > 0 then
            counter_object <= counter_object - 1;
        else
            counter_object <= max_value_for_counter;
        end if;
    end count_down_from;
------------------------------------------------------------------------
begin

------------------------------------------------------------------------
    test_uart : process(clock)
    begin
        if rising_edge(clock) then
            init_uart(uart_data_in);
            init_bus(bus_out);

            receive_data_from_uart(uart_data_out, data_from_uart);

            request_data_from_address(bus_out, data_from_uart);
            count_down_from(counter, 1199);
            if counter = 0 then
                transmit_16_bit_word_with_uart(uart_data_in, get_data(bus_in));
            end if;

            if uart_is_ready(uart_data_out) then
                CASE get_address(get_uart_rx_data(uart_data_out)) is
                    WHEN 0      => write_data_to_address(bus_out , 0 , get_data(get_uart_rx_data(uart_data_out)));
                    WHEN 1      => write_data_to_address(bus_out , 1 , get_data(get_uart_rx_data(uart_data_out)));
                    WHEN others => -- do nothing
                end CASE;
            end if;

        end if; --rising_edge
    end process test_uart;	

------------------------------------------------------------------------
    uart_clocks <=(clock => clock);

    u_uart : uart
    port map( uart_clocks,
          communications_FPGA_in.uart_FPGA_in,
    	  communications_FPGA_out.uart_FPGA_out,
    	  uart_data_in,
    	  uart_data_out);
------------------------------------------------------------------------
end rtl;
