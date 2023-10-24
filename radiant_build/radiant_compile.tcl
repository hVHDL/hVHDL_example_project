variable tcl_path [ file dirname [ file normalize [ info script ] ] ] 
puts $tcl_path
set outputDir ./output
set source_folder $tcl_path/../source
set project_name hvhdl_example

puts $source_folder

prj_create -name $project_name \
    -dev LFD2NX-40-7BG196C \
    -impl "impl1" \
    -impl_dir $outputDir \
    -synthesis "synplify" 

puts $tcl_path
puts $source_folder

# setting this true will break the floating point filter for some reason
# prj_set_strategy_value -strategy Strategy1 syn_vhdl2008=True
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
prj_run Export -impl impl1
