echo off
ghdl -a --ieee=synopsys --std=08 source/hVHDL_fpga_interconnect/interconnect_configuration/data_15_address_15_bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_fpga_interconnect/fpga_interconnect_pkg.vhd

ghdl -a --ieee=synopsys --std=08 source/hVHDL_floating_point/float_type_definitions/float_word_length_16_bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_floating_point/float_type_definitions/float_type_definitions_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_floating_point/normalizer/normalizer_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_floating_point/denormalizer/denormalizer_pkg.vhd

ghdl -a --ieee=synopsys --std=08 source/hVHDL_floating_point/float_to_real_conversions/float_to_real_functions_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_floating_point/float_to_real_conversions/float_to_real_conversions_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_floating_point/float_arithmetic_operations/float_arithmetic_operations_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_floating_point/float_adder/float_adder_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_floating_point/float_multiplier/float_multiplier_pkg.vhd

ghdl -a --ieee=synopsys --std=08 source/hVHDL_floating_point/float_alu/float_alu_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_floating_point/float_first_order_filter/float_first_order_filter_pkg.vhd

ghdl -a --ieee=synopsys --std=08 source/hvhdl_example_interconnect/example_filter_entity.vhd

ghdl -a --ieee=synopsys --std=08 source/hVHDL_memory_library/fpga_ram/ram_configuration/ram_configuration_16x1024_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_memory_library/fpga_ram/ram_read_port_pkg.vhd

ghdl -a --ieee=synopsys --std=08 source/hVHDL_math_library/multiplier/multiplier_base_types_18bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_math_library/multiplier/multiplier_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_math_library/sincos/sincos_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_math_library/first_order_filter/first_order_filter_pkg.vhd

ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_transreceiver/uart_transreceiver_pkg.vhd
ghdl -a --ieee=synopsys --std=08 source/hVHDL_uart/uart_pkg.vhd


ghdl -a --ieee=synopsys --std=08 source/hvhdl_example_interconnect/communication/communications.vhd
ghdl -a --ieee=synopsys --std=08 source/hvhdl_example_interconnect/hvhdl_example_interconnect_pkg.vhd


ghdl -a --ieee=synopsys --std=08 source/efinix_top.vhd
