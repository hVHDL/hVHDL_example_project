-- cyclone 10lp
package denormalizer_pipeline_pkg is

    constant pipeline_configuration : natural := 2;

end package denormalizer_pipeline_pkg;
------------------------------------------------------------------------
------------------------------------------------------------------------
package normalizer_pipeline_pkg is

    constant normalizer_pipeline_configuration : natural := 3;

end package normalizer_pipeline_pkg;
------------------------------------------------------------------------
------------------------------------------------------------------------
package float_word_length_pkg is

    constant mantissa_bits : integer := 24;
    constant exponent_bits : integer := 8;

end package float_word_length_pkg;
