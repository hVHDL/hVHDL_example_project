#!/usr/bin/env python3

from pathlib import Path
from vunit import VUnit

# ROOT
ROOT = Path(__file__).resolve().parent
VU = VUnit.from_argv()

float_library = VU.add_library("float_library")
float_library.add_source_files(ROOT / "testbenches/filter_simulation.vhd")
float_library.add_source_files(ROOT / "source/hVHDL_floating_point/float_type_definitions/float_word_length_24_bit_pkg.vhd")
float_library.add_source_files(ROOT / "source" / "hVHDL_floating_point" / "float_type_definitions/float_type_definitions_pkg.vhd")
float_library.add_source_files(ROOT / "source" / "hVHDL_floating_point" / "float_arithmetic_operations/*.vhd")

sqrt_lib = VU.add_library("sqrt_lib")
sqrt_lib.add_source_files(ROOT / "source/hVHDL_math_library/sincos/sincos_pkg.vhd") 
sqrt_lib.add_source_files(ROOT / "source/hVHDL_math_library/real_to_fixed/real_to_fixed_pkg.vhd")
sqrt_lib.add_source_files(ROOT / "source/hVHDL_math_library/multiplier/configuration/multiply_with_1_input_and_output_registers_pkg.vhd")
sqrt_lib.add_source_files(ROOT / "source/hVHDL_math_library/multiplier/multiplier_base_types_18bit_pkg.vhd")
sqrt_lib.add_source_files(ROOT / "source/hVHDL_math_library/multiplier/multiplier_pkg.vhd") 

sqrt_lib.add_source_files(ROOT / "source/hVHDL_math_library/fixed_point_scaling/fixed_point_scaling_pkg.vhd")

sqrt_lib.add_source_files(ROOT / "source/hVHDL_math_library/square_root/fixed_isqrt_pkg.vhd")
sqrt_lib.add_source_files(ROOT / "source/hVHDL_math_library/square_root/fixed_sqrt_pkg.vhd")
sqrt_lib.add_source_files(ROOT / "testbenches/sqrt_sine_tb.vhd")

mcu_lib = VU.add_library("mcu_lib")

mcu_lib.add_source_files(ROOT / "source/hVHDL_fpga_interconnect/interconnect_configuration/data_15_address_15_bit_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_fpga_interconnect/fpga_interconnect_pkg.vhd")
mcu_lib.add_source_files(ROOT / "example_project_addresses_pkg.vhd")

mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/float_type_definitions/float_word_length_24_bit_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/float_type_definitions/float_type_definitions_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/normalizer/normalizer_configuration/normalizer_with_1_stage_pipe_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/normalizer/normalizer_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/denormalizer/denormalizer_configuration/denormalizer_with_1_stage_pipe_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/denormalizer/denormalizer_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/float_to_real_conversions/float_to_real_functions_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/float_to_real_conversions/float_to_real_conversions_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/float_arithmetic_operations/float_arithmetic_operations_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/float_to_integer_converter/float_to_integer_converter_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/float_adder/float_adder_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/float_multiplier/float_multiplier_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_floating_point/float_alu/float_alu_pkg.vhd")

mcu_lib.add_source_files(ROOT / "source/hVHDL_microprogram_processor/processor_configuration/float_processor_ram_width_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_memory_library/multi_port_ram/multi_port_ram_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_memory_library/multi_port_ram/ram_read_x2_write_x1.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_memory_library/multi_port_ram/arch_sim_read_x2_write_x1.vhd")

mcu_lib.add_source_files(ROOT / "source/hVHDL_memory_library/multi_port_ram/ram_read_x4_write_x1.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_memory_library/multi_port_ram/arch_sim_read_x4_write_x1.vhd")

mcu_lib.add_source_files(ROOT / "source/hVHDL_math_library/real_to_fixed/real_to_fixed_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_microprogram_processor/processor_configuration/processor_configuration_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_microprogram_processor/processor_configuration/float_pipeline_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_microprogram_processor/vhdl_assembler/microinstruction_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_microprogram_processor/vhdl_assembler/float_assembler_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_microprogram_processor/simple_processor/simple_processor_pkg.vhd")
mcu_lib.add_source_files(ROOT / "source/hVHDL_microprogram_processor/simple_processor/float_example_program_pkg.vhd")

mcu_lib.add_source_files(ROOT / "source/main/example_filter_entity.vhd")
mcu_lib.add_source_files(ROOT / "source/main/arch_float_processor_entity.vhd")
mcu_lib.add_source_files(ROOT / "source/main/arch_memory_processor.vhd")

mcu_lib.add_source_files(ROOT / "testbenches/float_mcu_tb.vhd")

VU.main()
