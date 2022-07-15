
# Efinity Interface Designer SDC
# Version: 2021.2.323.1.8
# Date: 2022-01-19 23:48

# Copyright (C) 2017 - 2021 Efinix Inc. All rights reserved.

# Device: T120F324
# Project: ac_in_ac_out_lab_power_supply
# Timing Model: C4 (final)

# PLL Constraints
#################
create_clock -period 8.33 clock_120mhz

# GPIO Constraints
####################
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {pll_input_clock}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {pll_input_clock}]

# LVDS RX GPIO Constraints
############################
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {leds[0]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {leds[0]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {leds[1]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {leds[1]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {leds[2]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {leds[2]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {leds[3]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {leds[3]}]

# LVDS Rx Constraints
####################
