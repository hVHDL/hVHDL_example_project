This is a test project that uses the main features of hVHDL libraries. The example project is built with Lattice Diamond, Xilinx Vivado, Intel Quartus and Efinix Efinity and tested with lattice ECP5 fpga. Xilinx ISE will be added soon.

Note, tested to NOT work with 3.11 version of Lattice Diamond on a Windoew 11. Either Version of 3.12 works.

Lattice Diamond build can be launched using
> pnmainc <path_to_example_project>/ecp5_build/build_ecp5.tcl

Vivado build can be launched using
> vivado -mode tcl -notrace -source <path_to_example_project>/spartan7_build/vivado_compile.tcl

Quartus build can be launched using
> quartus_sh -t <path_to_example_project>/quartus_build/compile_with_quartus.tcl

In order to build with efinix, go to the efinix build folder <path_to_example_project>/efinix_build, then run
> efx_run.py hvhdl_example_build.xml --output_dir ./output
