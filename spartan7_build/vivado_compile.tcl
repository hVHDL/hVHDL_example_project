#Define target part and create output directory
variable tcl_path [ file dirname [ file normalize [ info script ] ] ] 
set outputDir ./output
set source_folder $tcl_path/../source
file mkdir $outputDir

set files [glob -nocomplain "$outputDir/*"]
if {[llength $files] != 0} {
    # clear folder contents
    puts "deleting contents of $outputDir"
    file delete -force {*}[glob -directory $outputDir *]; 
}

set target_device xc7s15ftgb196-2

create_project -force hvhdl_example_project

set_property top top [current_fileset]
set_property part $target_device [current_project]
set_property target_language VHDL [current_project]

    proc add_vhdl_file_to_project {vhdl_file} {
        add_files -norecurse $vhdl_file
    }

    proc add_vhdl_file_to_library {vhdl_file library} {
        read_vhdl -library $library $vhdl_file 
    }

add_vhdl_file_to_project $tcl_path/s7_top.vhd
source $tcl_path/../vhdl_sources.tcl

source $tcl_path/create_main_clocks.tcl

wait_on_run main_clock_synth_1

# synth_design -rtl -rtl_skip_mlo -name rtl_1

# file mkdir ./hvhdl_example_project.srcs/constrs_1/new
# close [ open ./hvhdl_example_project.srcs/constrs_1/new/io_placement.xdc w ]
# add_files -fileset constrs_1 ./hvhdl_example_project.srcs/constrs_1/new/io_placement.xdc
# set_property target_constrs_file ./hvhdl_example_project.srcs/constrs_1/new/io_placement.xdc [current_fileset -constrset]
# save_constraints -force

launch_runs synth_1 -jobs 12
wait_on_run synth_1
open_run synth_1 -name synth_1

set_property IOSTANDARD LVCMOS33 [get_ports [list clk]]
place_ports clk H11

set_property IOSTANDARD LVCMOS33 [get_ports [list uart_rx]]
place_ports uart_rx P4

set_property IOSTANDARD LVCMOS33 [get_ports [list uart_tx]]
place_ports uart_tx P3

launch_runs impl_1 -to_step write_bitstream -jobs 12
wait_on_run impl_1

open_run impl_1 -name impl_1
# #VCCO(zero) = IO = 2.5V || 3.3V, GND IO bank0 = 1.8v
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.Config.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
write_bitstream -force $outputDir/testibitstream.bit
# write_cfgmem -format mcs -interface spix4 -size
