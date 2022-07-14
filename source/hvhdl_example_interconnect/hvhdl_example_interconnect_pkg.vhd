library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.communications_pkg.all;
    use work.first_order_filter_pkg.all;

package hvhdl_example_interconnect_pkg is

    type hvhdl_example_interconnect_FPGA_input_group is record
        communications_FPGA_in : communications_FPGA_input_group;
    end record;
    
    type hvhdl_example_interconnect_FPGA_output_group is record
        communications_FPGA_out : communications_FPGA_output_group;
    end record;
    
end package hvhdl_example_interconnect_pkg;
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.hvhdl_example_interconnect_pkg.all;
	use work.multiplier_pkg.all;
	use work.sincos_pkg.all;
    use work.communications_pkg.all;
    use work.fpga_interconnect_pkg.all;
    use work.first_order_filter_pkg.all;

entity hvhdl_example_interconnect is
    port (
        system_clock : in std_logic;
        hvhdl_example_interconnect_FPGA_in  : in hvhdl_example_interconnect_FPGA_input_group;
        hvhdl_example_interconnect_FPGA_out : out hvhdl_example_interconnect_FPGA_output_group
    );
end hvhdl_example_interconnect;

architecture rtl of hvhdl_example_interconnect is

    
    signal multiplier : multiplier_record := init_multiplier;
    signal sincos : sincos_record := init_sincos;
    signal angle : integer  range 0 to 2**16-1;
    signal i : integer range 0 to 2**16-1 := 1199;

    signal communications_clocks   : communications_clock_group;
    signal communications_data_in  : communications_data_input_group;
    signal communications_data_out : communications_data_output_group;

    -- connec
    alias bus_in is communications_data_out.bus_out;
    alias bus_out is communications_data_in.bus_in;

    signal filter : first_order_filter_record := init_first_order_filter;
    signal prbs7 : std_logic_vector(6 downto 0) := (0 => '1', others => '0');

begin

    testi : process(system_clock)
        
    begin
        if rising_edge(system_clock) then
            create_multiplier(multiplier);
            create_sincos(multiplier, sincos);
            create_first_order_filter(filter =>filter,multiplier => multiplier, time_constant => 0.001);


            init_bus(bus_out);
            connect_read_only_data_to_address(bus_in, bus_out, 100, get_sine(sincos));
            connect_read_only_data_to_address(bus_in, bus_out, 101, angle);
            connect_read_only_data_to_address(bus_in, bus_out, 102, to_integer(unsigned(prbs7)));
            connect_read_only_data_to_address(bus_in, bus_out, 103, get_sine(sincos) + to_integer(signed(prbs7)));
            connect_read_only_data_to_address(bus_in, bus_out, 104, get_filter_output(filter));

			if i > 0 then
				i <= (i - 1);
			else
				i <= 1199;
			end if;

            if i = 0 then
                request_sincos(sincos, angle);
            end if;

            
            if sincos_is_ready(sincos) then
                angle <= (angle + 55) mod 2**16;
                prbs7 <= prbs7(5 downto 0) & prbs7(6);
                prbs7(6) <= prbs7(5) xor prbs7(0);
                filter_data(filter, get_sine(sincos) + to_integer(signed(prbs7)));
            end if;

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
