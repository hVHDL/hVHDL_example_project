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

proc add_vhdl_file_to_project {vhdl_file} {
    prj_src add $vhdl_file
}

proc add_vhdl_file_to_library {vhdl_file library} {
    prj_src add $vhdl_file -work $library
}

add_vhdl_file_to_project $tcl_path/ecp5_top.vhd

source $tcl_path/../vhdl_sources.tcl

prj_src add -exclude $tcl_path/example.lpf
prj_src enable $tcl_path/example.lpf
prj_src remove hvhdl_example.lpf
file delete -force hvhdl_example.lpf

prj_run Synthesis -impl impl1
prj_run Translate -impl impl1
prj_run Map -impl impl1
prj_run PAR -impl impl1
prj_run Export -impl impl1 -task Bitgen
prj_run Export -impl impl1 -task Promgen
prj_project save
