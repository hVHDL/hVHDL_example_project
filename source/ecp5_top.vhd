library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
	
	use work.multiplier_pkg.all;
	use work.sincos_pkg.all;
    use work.uart_pkg.all;

    library float;
        use float.float_alu_pkg.all;
        use float.float_type_definitions_pkg.all;
        use float.float_to_real_conversions_pkg.all;
        use float.float_first_order_filter_pkg.all;

entity top is
    port (
        clk     : in std_logic ;
        uart_rx : in std_logic ;
        uart_tx : out std_logic
    );
end entity top;
    
architecture rtl of top is

    component main_clock is
        port ( 
            CLKI: in  std_logic; 
            CLKOP: out  std_logic);
    end component;

    signal clock_120mhz : std_logic := '0';
    
    signal multiplier : multiplier_record := init_multiplier;
    signal sincos : sincos_record := init_sincos;
    signal angle : integer  range 0 to 2**16-1;
    signal i : integer range 0 to 2**16-1 := 1199;

    signal uart_clocks   : uart_clock_group;
    signal uart_FPGA_in  : uart_FPGA_input_group;
    signal uart_FPGA_out : uart_FPGA_output_group;
    signal uart_data_in  : uart_data_input_group;
    signal uart_data_out : uart_data_output_group;
    signal float_alu : float_alu_record := init_float_alu;
    signal test_float : float_record := to_float(0.0);
    signal first_order_filter : first_order_filter_record := init_first_order_filter;

begin

    u_main_clocks : main_clock
    port map(clk, clock_120mhz);

    testi : process(clock_120mhz)
        
    begin
        if rising_edge(clock_120mhz) then
            create_float_alu(float_alu);
            create_first_order_filter(first_order_filter, float_alu, to_float(0.001));
            create_multiplier(multiplier);
            create_sincos(multiplier, sincos);
            init_uart(uart_data_in);
			if i > 0 then
				i <= (i - 1);
			else
				i <= 1199;
			end if;

            if i = 0 then
                request_sincos(sincos, angle);
                request_float_filter(first_order_filter, to_float(1.0));
            end if;

            if float_filter_is_ready(first_order_filter) then
                test_float <= get_filter_output(first_order_filter);
            end if;

            
            if sincos_is_ready(sincos) then
                angle <= angle + 55;
                transmit_16_bit_word_with_uart(uart_data_in, get_mantissa(test_float));
            end if;
        end if; --rising_edge
    end process testi;	
------------------------------------------------------------------------
    uart_FPGA_in.uart_transreceiver_FPGA_in.uart_rx_fpga_in.uart_rx <= uart_rx ;
    uart_tx <= uart_FPGA_out.uart_transreceiver_FPGA_out.uart_tx_fpga_out.uart_tx;

    uart_clocks <= (clock => clock_120mhz);
    u_uart : uart
    port map(uart_clocks, uart_FPGA_in, uart_FPGA_out, uart_data_in, uart_data_out);
end rtl;
