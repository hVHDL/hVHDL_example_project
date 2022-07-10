variable tcl_path [ file dirname [ file normalize [ info script ] ] ] 
puts $tcl_path
set outputDir ./output
set source_folder $tcl_path/../source
file mkdir $outputDir

set files [glob -nocomplain "$outputDir/*"]
if {[llength $files] != 0} {
    # clear folder contents
    puts "deleting contents of $outputDir"
    file delete -force {*}[glob -directory $outputDir *]; 
}


prj_project new -name hvhdl_example \
    -impl "impl1" \
    -dev LFE5U-12F-8BG381C \
    -impl_dir $outputDir \
    -synthesis "synplify" \

prj_src add $tcl_path/IP/IP.sbx

prj_strgy set_value -strategy Strategy1 syn_arrange_vhdl_files=True
prj_strgy set_value -strategy Strategy1 par_pathbased_place=On
prj_strgy set_value -strategy Strategy1 par_stop_zero=True

prj_src add $source_folder/ecp5_top.vhd
prj_src add $source_folder/hVHDL_math_library/multiplier/multiplier_base_types_18bit_pkg.vhd
prj_src add $source_folder/hVHDL_math_library/multiplier/multiplier_pkg.vhd
prj_src add $source_folder/hVHDL_math_library/sincos/sincos_pkg.vhd
prj_src add $source_folder/hVHDL_uart/uart_pkg.vhd
prj_src add $source_folder/hVHDL_uart/uart.vhd
prj_src add $source_folder/hVHDL_uart/uart_transreceiver/uart_transreceiver_pkg.vhd
prj_src add $source_folder/hVHDL_uart/uart_transreceiver/uart_transreceiver.vhd
prj_src add $source_folder/hVHDL_uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
prj_src add $source_folder/hVHDL_uart/uart_transreceiver/uart_rx/uart_rx.vhd
prj_src add $source_folder/hVHDL_uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
prj_src add $source_folder/hVHDL_uart/uart_transreceiver/uart_tx/uart_tx.vhd

prj_src add -exclude $tcl_path/example.lpf
prj_src enable $tcl_path/example.lpf
# prj_src enable $tube_psu_v5_dir/lfe5u/constraints/timing.ldc
prj_src remove hvhdl_example.lpf
file delete -force hvhdl_example.lpf

prj_run Synthesis -impl impl1
prj_run Translate -impl impl1
prj_run Map -impl impl1
prj_run PAR -impl impl1
prj_run Export -impl impl1
prj_project save
