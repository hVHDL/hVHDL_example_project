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

set target_device xc7a100tftg256-1

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

    proc set_3v3_io {pin_name_from_port package_pin_location} {
        set_property IOSTANDARD LVCMOS33 [get_ports [list $pin_name_from_port]]
        place_ports $pin_name_from_port $package_pin_location
    }


add_vhdl_file_to_project $tcl_path/alchitry_top.vhd
source $tcl_path/../vhdl_sources.tcl

source $tcl_path/create_main_clocks.tcl

wait_on_run main_clock_synth_1

launch_runs synth_1 -jobs 12
wait_on_run synth_1
open_run synth_1 -name synth_1

set_3v3_io clk N14
set_3v3_io uart_rx P15
set_3v3_io uart_tx P16

set_3v3_io leds[0]  K13
set_3v3_io leds[-1] K12
set_3v3_io leds[-2] L14
set_3v3_io leds[-3] L13
set_3v3_io leds[-4] M16
set_3v3_io leds[-5] M14
set_3v3_io leds[-6] M12
set_3v3_io leds[-7] N16

launch_runs impl_1 -to_step write_bitstream -jobs 12
wait_on_run impl_1

open_run impl_1 -name impl_1
#VCCO(zero) = IO = 2.5V || 3.3V, GND IO bank0 = 1.8v
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.Config.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

write_bitstream -force -bin_file hvhdl_example_project_ram_image.bit
write_cfgmem -force  -format mcs -size 32 -interface SPIx4        \
    -loadbit "up 0x0 hvhdl_example_project_ram_image.bit" \
    -file "hvhdl_example_project_flash_image.mcs"


proc program_ram {} {
    open_hw_manager
    connect_hw_server -allow_non_jtag
    open_hw_target
    set_property PROGRAM.FILE "hvhdl_example_project_ram_image.bit" [get_hw_devices xc7a100t_0]
    program_hw_devices [get_hw_devices xc7a100t_0]
    close_hw_manager
}

if {[lsearch -glob $argv *ram*] != -1} {
    program_ram
}

