echo off
ghdl -a --ieee=synopsys --std=08 example_project_addresses_pkg.vhd

call source/hVHDL_fpga_interconnect/ghdl_compile_fpga_interconnect.bat source/hVHDL_fpga_interconnect
call source/hVHDL_floating_point/ghdl_compile_vhdl_float.bat source/hVHDL_floating_point
call source/hVHDL_math_library/ghdl_compile_math_library.bat source/hVHDL_math_library
call source/hVHDL_uart/ghdl_compile_uart.bat source/hVHDL_uart

ghdl -a --ieee=synopsys --std=08 source/hvhdl_example_interconnect/example_filter_entity.vhd

ghdl -a --ieee=synopsys --std=08 source/hvhdl_example_interconnect/communication/communications.vhd
ghdl -a --ieee=synopsys --std=08 source/hvhdl_example_interconnect/hvhdl_example_interconnect_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hvhdl_example_interconnect/test_sqrt.vhd

ghdl -a --ieee=synopsys --std=08 source/efinix_top.vhd
