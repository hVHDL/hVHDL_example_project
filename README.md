This is a test project that uses the main features of hVHDL libraries. The example project is built with Lattice Diamond and Xilinx Vivado and tested with lattice ECP5 fpga. Efinix Efinity, Intel Quartus and Xilinx ISE will be added soon.

Note, tested to NOT work with 3.11 version of Lattice Diamond on a Windoew 11. Either Version of 3.12 works.

To build the lattice project run
> pnmainc <path_to_example_project>/ecp5_build/build_ecp5.tcl

Vivado build can be launched using
> vivado -mode tcl -notrace -source <path_to_example_project>/spartan7_build/vivado_compile.tcl
