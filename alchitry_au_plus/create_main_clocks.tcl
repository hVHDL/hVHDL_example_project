create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name main_clock
set_property -dict [list CONFIG.PRIM_IN_FREQ {100} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {120} CONFIG.USE_LOCKED {false} CONFIG.USE_RESET {false} CONFIG.CLKIN1_JITTER_PS {312.5} CONFIG.MMCM_DIVCLK_DIVIDE {2} CONFIG.MMCM_CLKFBOUT_MULT_F {61.875} CONFIG.MMCM_CLKIN1_PERIOD {31.250} CONFIG.MMCM_CLKIN2_PERIOD {10.0} CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.250} CONFIG.CLKOUT1_JITTER {281.092} CONFIG.CLKOUT1_PHASE_ERROR {426.595}] [get_ips main_clock]
export_ip_user_files -of_objects [get_files ./hvhdl_example_project.srcs/sources_1/ip/main_clock/main_clock.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ./hvhdl_example_project.srcs/sources_1/ip/main_clock/main_clock.xci]
launch_runs main_clock_synth_1 -jobs 12
