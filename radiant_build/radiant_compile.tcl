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


prj_create -name hvhdl_example \
    -dev LFD2NX-40-7BG196C \
    -impl "impl1" \
    -impl_dir $outputDir \
    -synthesis "synplify" \

prj_set_strategy_value -strategy Strategy1 syn_vhdl2008=True
prj_set_strategy_value -strategy Strategy1 {syn_pipelining_retiming=Pipelining and Retiming}

prj_add_source $tcl_path/IP/main_oscillator/main_oscillator.ipx
prj_add_source $tcl_path/IP/main_clock/main_clock.ipx
prj_add_source $tcl_path/certus_nx_top.vhd

proc add_vhdl_file_to_project {vhdl_file} {
    prj_add_source $vhdl_file
}

proc add_vhdl_file_to_library {vhdl_file library} {
    prj_add_source $vhdl_file -work $library
}

source $tcl_path/../vhdl_sources.tcl

prj_set_impl_opt -impl "impl1" "top" "top"
prj_add_source $tcl_path/cruvi_physical_constraints.pdc
prj_run PAR -impl impl1
# prj_strgy set_value -strategy Strategy1 syn_arrange_vhdl_files=True
# prj_strgy set_value -strategy Strategy1 par_pathbased_place=On
# prj_strgy set_value -strategy Strategy1 map_reg_retiming=True
#
#do not change this setting. If retiming is not on, Synplify will crash for some reason
# prj_strgy set_value -strategy Strategy1 {syn_pipelining_retiming=Pipelining and Retiming}

# prj_strgy set_value -strategy Strategy1 par_stop_zero=True


# source $tcl_path/../vhdl_sources.tcl

# prj_src add -exclude $tcl_path/example.lpf
# prj_src enable $tcl_path/example.lpf
# prj_src remove hvhdl_example.lpf
# file delete -force hvhdl_example.lpf
#
# prj_run Synthesis -impl impl1
# prj_run Translate -impl impl1
# prj_run Map -impl impl1
# prj_run PAR -impl impl1
# prj_run Export -impl impl1 -task Bitgen
# prj_run Export -impl impl1 -task Promgen
# prj_project save
prj_close
