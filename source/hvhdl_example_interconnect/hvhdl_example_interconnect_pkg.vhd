library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package hvhdl_example_interconnect_pkg is

    use work.communications_pkg.all;

    type hvhdl_example_interconnect_FPGA_input_group is record
        communications_FPGA_in : communications_FPGA_input_group;
    end record;
    
    type hvhdl_example_interconnect_FPGA_output_group is record
        communications_FPGA_out : communications_FPGA_output_group;
    end record;
    
end package hvhdl_example_interconnect_pkg;

------------------------------------------------------------------------
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.hvhdl_example_interconnect_pkg.all;
    use work.communications_pkg.all;
    use work.fpga_interconnect_pkg.all;
    use work.filter_example_pkg.all;

entity hvhdl_example_interconnect is
    port (
        system_clock : in std_logic;
        hvhdl_example_interconnect_FPGA_in  : in hvhdl_example_interconnect_FPGA_input_group;
        hvhdl_example_interconnect_FPGA_out : out hvhdl_example_interconnect_FPGA_output_group
    );
end hvhdl_example_interconnect;

architecture rtl of hvhdl_example_interconnect is
    
    signal communications_clocks   : communications_clock_group;
    signal communications_data_in  : communications_data_input_group;
    signal communications_data_out : communications_data_output_group;

    alias bus_in is communications_data_out.bus_out;
    alias bus_out is communications_data_in.bus_in;

------------------------------------------------------------------------
    signal filter_example : filter_example_record := init_filter_example;

begin

    testi : process(system_clock)
    begin
        if rising_edge(system_clock) then

            create_filter_example(filter_example);

            init_bus(bus_out);
            connect_read_only_data_to_address(bus_in, bus_out, 100, get_sine(filter_example));
            connect_read_only_data_to_address(bus_in, bus_out, 101, get_angle(filter_example));
            connect_read_only_data_to_address(bus_in, bus_out, 102, get_noise_signal(filter_example));
            connect_read_only_data_to_address(bus_in, bus_out, 103, get_noisy_sine(filter_example));
            connect_read_only_data_to_address(bus_in, bus_out, 104, get_filtered_sine(filter_example));

        end if; --rising_edge
    end process testi;	
------------------------------------------------------------------------
    communications_clocks <= (clock => system_clock);
    u_communications : entity work.communications
    port map(
        communications_clocks,
        hvhdl_example_interconnect_FPGA_in.communications_FPGA_in,
        hvhdl_example_interconnect_FPGA_out.communications_FPGA_out,
        communications_data_in ,
        communications_data_out);
------------------------------------------------------------------------
end rtl;
