library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
	
entity top is
    port (
        uart_rx : in std_logic ;
        uart_tx : out std_logic
    );
end entity top;
    
architecture rtl of top is

--------------------------------------------------
	component main_oscillator is
	port (hf_out_en_i : in std_logic; 
        hf_clk_out_o : out std_logic);
	end component;
	
    component main_clock is
        port ( 
            clki_i: in  std_logic; 
            clkop_o: out  std_logic);
    end component;
--------------------------------------------------

    signal clock_120mhz : std_logic := '0';
	signal clk : std_logic;
    
--------------------------------------------------
begin

--------------------------------------------------
    u_main_oscillator : main_oscillator
    port map('1', clk);
	
    u_main_clocks : main_clock
    port map(clk, clock_120mhz);
--------------------------------------------------
    u_hvhdl_example : entity work.efinix_top
    port map(
        clock_120mhz => clock_120mhz,
        uart_rx     => uart_rx,
        uart_tx     => uart_tx);

--------------------------------------------------
end rtl;
