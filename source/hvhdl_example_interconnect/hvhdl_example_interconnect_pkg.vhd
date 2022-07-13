library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.uart_pkg.all;

package hvhdl_example_interconnect_pkg is

    type hvhdl_example_interconnect_FPGA_input_group is record
        uart_FPGA_in : uart_FPGA_input_group;
    end record;
    
    type hvhdl_example_interconnect_FPGA_output_group is record
        uart_FPGA_out : uart_FPGA_output_group;
    end record;
    
end package hvhdl_example_interconnect_pkg;
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.hvhdl_example_interconnect_pkg.all;
	use work.multiplier_pkg.all;
	use work.sincos_pkg.all;
    use work.uart_pkg.all;

entity hvhdl_example_interconnect is
    port (
        system_clock : in std_logic;
        hvhdl_example_interconnect_FPGA_in  : in hvhdl_example_interconnect_FPGA_input_group;
        hvhdl_example_interconnect_FPGA_out : out hvhdl_example_interconnect_FPGA_output_group
    );
end hvhdl_example_interconnect;

architecture rtl of hvhdl_example_interconnect is

    
    signal multiplier : multiplier_record := init_multiplier;
    signal sincos : sincos_record := init_sincos;
    signal angle : integer  range 0 to 2**16-1;
    signal i : integer range 0 to 2**16-1 := 1199;

    signal uart_clocks   : uart_clock_group;
    signal uart_data_in  : uart_data_input_group;
    signal uart_data_out : uart_data_output_group;

begin

    testi : process(system_clock)
        
    begin
        if rising_edge(system_clock) then
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
            end if;

            
            if sincos_is_ready(sincos) then
                angle <= angle + 55;
                transmit_16_bit_word_with_uart(uart_data_in, get_sine(sincos));
            end if;

        end if; --rising_edge
    end process testi;	
------------------------------------------------------------------------

    uart_clocks <= (clock => system_clock);
    u_uart : uart
    port map(uart_clocks, 
        hvhdl_example_interconnect_FPGA_in.uart_FPGA_in, 
        hvhdl_example_interconnect_FPGA_out.uart_FPGA_out, 
        uart_data_in, uart_data_out);

end rtl;
