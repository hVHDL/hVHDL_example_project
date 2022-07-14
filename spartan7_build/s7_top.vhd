library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity top is
    port (
        clk : in std_logic	;
        led : out std_logic
    );
end entity top;


architecture rtl of top is

    signal counter : integer range 0 to 2**20-1 := 0;
    signal led_state : std_logic := '0';
    signal clock_120mhz : std_logic;

    component main_clock is
      Port ( 
        clk_out1 : out STD_LOGIC;
        clk_in1 : in STD_LOGIC
      );
    end component;

begin

    u_main_clocks : main_clock
    port map(clock_120mhz, clk);


    led <= led_state;

    blink_led : process(clock_120mhz)
        
    begin
        if rising_edge(clock_120mhz) then
            if counter > 0 then
                counter <= counter - 1;
                led_state <= not led_state;
            else
                counter <= 1e6;
            end if;
        end if; --rising_edge
    end process blink_led;	


end rtl;
