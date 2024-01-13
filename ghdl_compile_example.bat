echo off
ghdl -a --ieee=synopsys --std=08 example_project_addresses_pkg.vhd

call source/hVHDL_fpga_interconnect/ghdl_compile_fpga_interconnect.bat source/hVHDL_fpga_interconnect
call source/hVHDL_math_library/ghdl_compile_math_library.bat source/hVHDL_math_library
call source/hVHDL_uart/ghdl_compile_uart.bat source/hVHDL_uart
call source/hVHDL_microprogram_processor/ghdl_compile.bat source/hVHDL_microprogram_processor

ghdl -a --ieee=synopsys --std=08 source/main/example_filter_entity.vhd

ghdl -a --ieee=synopsys --std=08 source/main/communication/communications.vhd
ghdl -a --ieee=synopsys --std=08 source/main/main.vhd

ghdl -a --ieee=synopsys --std=08 source/efinix_top.vhd
