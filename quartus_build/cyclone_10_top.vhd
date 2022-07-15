library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity top is
    port (
        clk : in std_logic	;
        uart_rx : in std_logic;
        uart_tx : out std_logic 
    );
end entity top;

architecture rtl of top is

    component main_clocks IS
        PORT
        (
            inclk0		: IN STD_LOGIC  := '0';
            c0		: OUT STD_LOGIC 
        );
    END component;

    signal clock_120mhz : std_logic; 

begin

    u_main_clocks : main_clocks
    port map(inclk0 => clk, c0 => clock_120mhz);

--------------------------------------------------
    u_hvhdl_example : entity work.hvhdl_example_interconnect
    port map(
        system_clock => clock_120mhz,
        hvhdl_example_interconnect_FPGA_in.communications_FPGA_in.uart_FPGA_in.uart_transreceiver_FPGA_in.uart_rx_fpga_in.uart_rx      => uart_rx,
        hvhdl_example_interconnect_FPGA_out.communications_FPGA_out.uart_FPGA_out.uart_transreceiver_FPGA_out.uart_tx_fpga_out.uart_tx => uart_tx);

end rtl;
