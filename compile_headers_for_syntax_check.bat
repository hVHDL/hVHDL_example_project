echo off

ghdl -a --ieee=synopsys --std=08 source/hVHDL_math_library/multiplier/multiplier_base_types_18bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_math_library/multiplier/multiplier_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_math_library/sincos/sincos_pkg.vhd

ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_transreceiver/uart_transreceiver_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_pkg.vhd
