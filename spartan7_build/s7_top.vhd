library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.hvhdl_example_interconnect_pkg.all;

entity top is
    port (
        clk : in std_logic	;
        uart_rx : in std_logic ;
        uart_tx : out std_logic
    );
end entity top;


architecture rtl of top is


    component main_clock is
      Port ( 
        clk_out1 : out STD_LOGIC;
        clk_in1 : in STD_LOGIC
      );
    end component;

    signal clock_120mhz : std_logic;

begin

    u_main_clocks : main_clock
    port map(clock_120mhz, clk);

--------------------------------------------------
    u_hvhdl_example : entity work.hvhdl_example_interconnect
    port map(
        system_clock => clock_120mhz,
        hvhdl_example_interconnect_FPGA_in.communications_FPGA_in.uart_FPGA_in.uart_transreceiver_FPGA_in.uart_rx_fpga_in.uart_rx     => uart_rx,
        hvhdl_example_interconnect_FPGA_out.communications_FPGA_out.uart_FPGA_out.uart_transreceiver_FPGA_out.uart_tx_fpga_out.uart_tx => uart_tx);


end rtl;
