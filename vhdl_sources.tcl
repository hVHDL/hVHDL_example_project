add_vhdl_file_to_project $source_folder/../example_project_addresses_pkg.vhd

add_vhdl_file_to_project $source_folder/efinix_top.vhd
add_vhdl_file_to_project $source_folder/hVHDL_math_library/multiplier/configuration/multiply_with_2_input_and_output_registers_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_math_library/multiplier/multiplier_base_types_20bit_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_math_library/multiplier/multiplier_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_math_library/sincos/sincos_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_math_library/first_order_filter/first_order_filter_pkg.vhd

add_vhdl_file_to_project $source_folder/hVHDL_uart/uart_rx/uart_rx_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_uart/uart_tx/uart_tx_pkg.vhd

add_vhdl_file_to_project $source_folder/hVHDL_uart/uart_protocol/uart_protocol_pkg.vhd

add_vhdl_file_to_project $source_folder/hVHDL_fpga_interconnect/interconnect_configuration/data_15_address_15_bit_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_fpga_interconnect/fpga_interconnect_pkg.vhd

# defined in configuration
# add_vhdl_file_to_project $source_folder/hVHDL_floating_point/float_type_definitions/float_word_length_24_bit_pkg.vhd 
add_vhdl_file_to_project $source_folder/hVHDL_floating_point/float_type_definitions/float_type_definitions_pkg.vhd                 
# add_vhdl_file_to_project $source_folder/hVHDL_floating_point/normalizer/normalizer_configuration/normalizer_with_4_stage_pipe_pkg.vhd
# add_vhdl_file_to_project $source_folder/hVHDL_floating_point/denormalizer/denormalizer_configuration/denormalizer_with_4_stage_pipe_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_floating_point/normalizer/normalizer_pkg.vhd                                         
add_vhdl_file_to_project $source_folder/hVHDL_floating_point/denormalizer/denormalizer_pkg.vhd                                     
add_vhdl_file_to_project $source_folder/hVHDL_floating_point/float_to_real_conversions/float_to_real_functions_pkg.vhd             
add_vhdl_file_to_project $source_folder/hVHDL_floating_point/float_to_real_conversions/float_to_real_conversions_pkg.vhd           
add_vhdl_file_to_project $source_folder/hVHDL_floating_point/float_arithmetic_operations/float_arithmetic_operations_pkg.vhd       
add_vhdl_file_to_project $source_folder/hVHDL_floating_point/float_to_integer_converter/float_to_integer_converter_pkg.vhd       
add_vhdl_file_to_project $source_folder/hVHDL_floating_point/float_adder/float_adder_pkg.vhd                                       
add_vhdl_file_to_project $source_folder/hVHDL_floating_point/float_multiplier/float_multiplier_pkg.vhd                             
add_vhdl_file_to_project $source_folder/hVHDL_floating_point/float_alu/float_alu_pkg.vhd                                           
add_vhdl_file_to_project $source_folder/hVHDL_floating_point/float_first_order_filter/float_first_order_filter_pkg.vhd             

add_vhdl_file_to_project $source_folder/hVHDL_microprogram_processor/processor_configuration/float_processor_ram_width_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_memory_library/multi_port_ram/multi_port_ram_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_memory_library/multi_port_ram/ram_read_x2_write_x1.vhd
add_vhdl_file_to_project $source_folder/hVHDL_memory_library/multi_port_ram/arch_rtl_read_x2_write_x1.vhd

add_vhdl_file_to_project $source_folder/hVHDL_memory_library/multi_port_ram/ram_read_x4_write_x1.vhd
add_vhdl_file_to_project $source_folder/hVHDL_memory_library/multi_port_ram/arch_rtl_read_x4_write_x1.vhd

add_vhdl_file_to_project $source_folder/hVHDL_math_library/real_to_fixed/real_to_fixed_pkg.vhd                 
add_vhdl_file_to_project $source_folder/hVHDL_microprogram_processor/processor_configuration/processor_configuration_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_microprogram_processor/processor_configuration/fixed_point_command_pipeline_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_microprogram_processor/vhdl_assembler/microinstruction_pkg.vhd    
add_vhdl_file_to_project $source_folder/hVHDL_microprogram_processor/simple_processor/simple_processor_pkg.vhd

add_vhdl_file_to_project $source_folder/hVHDL_microprogram_processor/vhdl_assembler/float_assembler_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_microprogram_processor/processor_configuration/float_pipeline_pkg.vhd
add_vhdl_file_to_project $source_folder/hVHDL_microprogram_processor/simple_processor/float_example_program_pkg.vhd

# add_vhdl_file_to_project $source_folder/hVHDL_microprogram_processor/memory_processor/memory_processing_pkg.vhd
# add_vhdl_file_to_project $source_folder/hVHDL_microprogram_processor/memory_processor/memory_processor.vhd

add_vhdl_file_to_project $source_folder/main/communication/communications.vhd
add_vhdl_file_to_project $source_folder/main/main.vhd
add_vhdl_file_to_project $source_folder/main/example_filter_entity.vhd
add_vhdl_file_to_project $source_folder/main/arch_fixed_example_filter_entity.vhd
add_vhdl_file_to_project $source_folder/main/arch_float_example_filter_entity.vhd
add_vhdl_file_to_project $source_folder/main/arch_memory_processor.vhd
add_vhdl_file_to_project $source_folder/main/arch_float_processor_entity.vhd
