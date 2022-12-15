create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name main_clock
set_property -dict [list CONFIG.PRIM_IN_FREQ {32} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {120} CONFIG.USE_LOCKED {false} CONFIG.USE_RESET {false} CONFIG.CLKIN1_JITTER_PS {312.5} CONFIG.MMCM_DIVCLK_DIVIDE {2} CONFIG.MMCM_CLKFBOUT_MULT_F {61.875} CONFIG.MMCM_CLKIN1_PERIOD {31.250} CONFIG.MMCM_CLKIN2_PERIOD {10.0} CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.250} CONFIG.CLKOUT1_JITTER {281.092} CONFIG.CLKOUT1_PHASE_ERROR {426.595}] [get_ips main_clock]
generate_target {instantiation_template} [get_files .srcs/sources_1/ip/main_clock/main_clock.xci]
set_property generate_synth_checkpoint false [get_files .srcs/sources_1/ip/main_clock/main_clock.xci]
generate_target all  [get_files .srcs/sources_1/ip/main_clock/main_clock.xci]
export_ip_user_files -of_objects [get_files .srcs/sources_1/ip/main_clock/main_clock.xci] -no_script -sync -force -quiet
export_simulation -of_objects [get_files .srcs/sources_1/ip/main_clock/main_clock.xci] -directory .ip_user_files/sim_scripts -ip_user_files_dir .ip_user_files -ipstatic_source_dir .ip_user_files/ipstatic -lib_map_path [list {modelsim=./.cache/compile_simlib/modelsim} {questa=./.cache/compile_simlib/questa} {riviera=./.cache/compile_simlib/riviera} {activehdl=./.cache/compile_simlib/activehdl}] -use_ip_compiled_libs -force -quiet
