library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity efinix_top is
    port (
        clock_120mhz : in std_logic;
        uart_rx      : in std_logic;
        uart_tx      : out std_logic
    );
end entity efinix_top;

architecture rtl of efinix_top is

begin

--------------------------------------------------
    u_hvhdl_example : entity work.main
    port map(
        system_clock => clock_120mhz,
        main_FPGA_in.communications_FPGA_in.uart_rx   => uart_rx,
        main_FPGA_out.communications_FPGA_out.uart_tx => uart_tx);

end rtl;
