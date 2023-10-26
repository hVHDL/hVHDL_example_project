package require ::quartus::project
package require ::quartus::flow

set fpga_device 10CL025YU256I7G
set output_dir ./output

variable tcl_path [ file dirname [ file normalize [ info script ] ] ] 
puts $tcl_path
set source_folder $tcl_path/../source

if {[project_exists hvhdl_example_project]} \
{
    project_open -revision top hvhdl_example_project
} \
else \
{
    project_new -revision top hvhdl_example_project
}

	set_global_assignment -name QIP_FILE $tcl_path/cyclone_IP/main_clocks.qip

    source $tcl_path/make_assignments.tcl

    proc add_vhdl_file_to_project {vhdl_file} {
        set_global_assignment -name VHDL_FILE $vhdl_file
    }

    proc add_vhdl_file_to_library {vhdl_file library} {
        set_global_assignment -name VHDL_FILE $vhdl_file -library $library
    }

    add_vhdl_file_to_project $tcl_path/cyclone_10_top.vhd
    set_global_assignment -name VHDL_FILE $source_folder/efinix_top.vhd

    source $tcl_path/../vhdl_sources.tcl

    set_global_assignment -name TOP_LEVEL_ENTITY top

    set_location_assignment PIN_E1 -to clk
	set_location_assignment PIN_P1 -to uart_rx
	set_location_assignment PIN_R1 -to uart_tx

	export_assignments
    set_global_assignment -name SDC_FILE $tcl_path/timing_constraints.sdc

    execute_flow -compile
