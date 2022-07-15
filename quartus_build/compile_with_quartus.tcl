
package require ::quartus::project
package require ::quartus::flow

set fpga_device 10CL025YU256I7G
set output_dir ./output

variable tcl_path [ file dirname [ file normalize [ info script ] ] ] 
puts $tcl_path
set source_path $tcl_path/../source

if {[project_exists cl10_ac_in_ac_out_power_supply]} \
{
    project_open -revision top cl10_ac_in_ac_out_power_supply
} \
else \
{
    project_new -revision top cl10_ac_in_ac_out_power_supply
}

	set_global_assignment -name QIP_FILE $tcl_path/cyclone_IP/main_clocks.qip

    source $tcl_path/make_assignments.tcl
    source $tcl_path/vhdl_source_files.tcl
    set_global_assignment -name TOP_LEVEL_ENTITY cyclone_top

    set_location_assignment PIN_M15 -to xclk
	set_location_assignment PIN_N16 -to uart_rx
	set_location_assignment PIN_N15 -to uart_tx
	set_location_assignment PIN_L16 -to leds[0]
	set_location_assignment PIN_K16 -to leds[1]
	set_location_assignment PIN_J16 -to leds[2]
	set_location_assignment PIN_G16 -to leds[3]

	export_assignments
    set_global_assignment -name SDC_FILE $tcl_path/cl10_ac_in_ac_out_power_supply.sdc

    execute_flow -compile
