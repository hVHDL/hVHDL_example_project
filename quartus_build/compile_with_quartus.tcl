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
    # source $tcl_path/vhdl_source_files.tcl

    set_global_assignment -name VHDL_FILE $tcl_path/cyclone_10_top.vhd

    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_math_library/multiplier/multiplier_base_types_18bit_pkg.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_math_library/multiplier/multiplier_pkg.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_math_library/sincos/sincos_pkg.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_math_library/first_order_filter/first_order_filter_pkg.vhd

    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_uart/uart_pkg.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_uart/uart.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_uart/uart_transreceiver/uart_transreceiver_pkg.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_uart/uart_transreceiver/uart_transreceiver.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_uart/uart_transreceiver/uart_rx/uart_rx.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_uart/uart_transreceiver/uart_tx/uart_tx.vhd

    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_fpga_interconnect/interconnect_configuration/data_15_address_15_bit_pkg.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hVHDL_fpga_interconnect/fpga_interconnect_pkg.vhd

    set_global_assignment -name VHDL_FILE $source_folder/hvhdl_example_interconnect/communication/communications.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hvhdl_example_interconnect//filter_example_pkg.vhd
    set_global_assignment -name VHDL_FILE $source_folder/hvhdl_example_interconnect/hvhdl_example_interconnect_pkg.vhd

    set_global_assignment -name TOP_LEVEL_ENTITY top

    set_location_assignment PIN_M15 -to xclk
	set_location_assignment PIN_N16 -to uart_rx
	set_location_assignment PIN_N15 -to uart_tx

	export_assignments
    set_global_assignment -name SDC_FILE $tcl_path/timing_constraints.sdc

    execute_flow -compile
