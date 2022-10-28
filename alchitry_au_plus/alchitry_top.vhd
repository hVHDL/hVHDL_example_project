library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity top is
    port (
        clk : in std_logic	;
        uart_rx : in std_logic ;
        uart_tx : out std_logic;
        leds : out std_logic_vector(0 downto -7)
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

    signal blinker_counter : integer range 0 to 120e6 := 60e6-1;
    signal led_state : std_logic := '0';

begin

    led_blinker : process(clock_120mhz)
        
    begin
        if rising_edge(clock_120mhz) then
            if blinker_counter > 0 then
                blinker_counter <= blinker_counter - 1;
            else
                blinker_counter <= 60e6-1;
                led_state <= not led_state;
            end if;

            leds <= (others => led_state);

        end if; --rising_edge
    end process led_blinker;	

    u_main_clocks : main_clock
    port map(clock_120mhz, clk);

--------------------------------------------------
    u_hvhdl_example : entity work.efinix_top
    port map(
        clock_120mhz => clock_120mhz,
        uart_rx     => uart_rx,
        uart_tx     => uart_tx);
--------------------------------------------------
end rtl;
