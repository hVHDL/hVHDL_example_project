-- cyclone 10lp
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package denormalizer_pipeline_pkg is

    constant pipeline_configuration : natural := 2;

end package denormalizer_pipeline_pkg;
------------------------------------------------------------------------
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package normalizer_pipeline_pkg is

    constant normalizer_pipeline_configuration : natural := 3;

end package normalizer_pipeline_pkg;