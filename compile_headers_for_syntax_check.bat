echo off

ghdl -a --ieee=synopsys --std=08 source/hVHDL_math_library/multiplier/multiplier_base_types_18bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_math_library/multiplier/multiplier_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_math_library/sincos/sincos_pkg.vhd

ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_transreceiver/uart_transreceiver_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_pkg.vhd

ghdl -a --ieee=synopsys --std=08 source/hVHDL_fpga_interconnect/interconnect_configuration/data_15_address_15_bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_fpga_interconnect/fpga_interconnect_pkg.vhd

ghdl -a --ieee=synopsys --std=08 source/hvhdl_example_interconnect/communication/communications.vhd
ghdl -a --ieee=synopsys --std=08 source/hvhdl_example_interconnect/hvhdl_example_interconnect_pkg.vhd
