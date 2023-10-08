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

VU.main()
