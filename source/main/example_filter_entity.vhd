library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.fpga_interconnect_pkg.all;

package example_filter_entity_pkg is

    type example_filter_input_record is record
        filter_is_requested : boolean;
        filter_input        : integer;
    end record;

    constant init_example_filter_input : example_filter_input_record := (false, 0);

--------------------------------------------------
    procedure init_example_filter (
        signal example_filter_input : out example_filter_input_record);

--------------------------------------------------
    procedure request_example_filter (
        signal example_filter_input : out example_filter_input_record;
        data : in integer);
--------------------------------------------------
end package example_filter_entity_pkg;

package body example_filter_entity_pkg is

--------------------------------------------------
    procedure init_example_filter
    (
        signal example_filter_input : out example_filter_input_record
    ) is
    begin
        example_filter_input.filter_is_requested <= false;
    end init_example_filter;

--------------------------------------------------
    procedure request_example_filter
    (
        signal example_filter_input : out example_filter_input_record;
        data : in integer
    ) is
    begin
        example_filter_input.filter_is_requested <= true;
        example_filter_input.filter_input <= data;
        
    end request_example_filter;

--------------------------------------------------
end package body example_filter_entity_pkg;

------------------------------------------------------------------------
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.fpga_interconnect_pkg.all;

    use work.example_filter_entity_pkg.all;

entity example_filter_entity is
    generic(filter_time_constant : real; filter_output_address : natural := 109);
    port (
        clock : in std_logic;
        example_filter_input : in example_filter_input_record;
        bus_in              : in fpga_interconnect_record;
        bus_out             : out fpga_interconnect_record
    );
end entity example_filter_entity;


