--
-- Synopsys
-- Vhdl wrapper for top level design, written on Sun Jul 10 10:17:54 2022
--
library ieee;
use ieee.std_logic_1164.all;
library ecp5u;
use ecp5u.components.all;

entity wrapper_for_main_clock is
   port (
      CLKI : in std_logic;
      CLKOP : out std_logic
   );
end wrapper_for_main_clock;

architecture structure of wrapper_for_main_clock is

component main_clock
 port (
   CLKI : in std_logic;
   CLKOP : out std_logic
 );
end component;

signal tmp_CLKI : std_logic;
signal tmp_CLKOP : std_logic;

begin

tmp_CLKI <= CLKI;

CLKOP <= tmp_CLKOP;



u1:   main_clock port map (
		CLKI => tmp_CLKI,
		CLKOP => tmp_CLKOP
       );
end structure;
