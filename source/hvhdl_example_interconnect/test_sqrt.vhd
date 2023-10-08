LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

	use work.multiplier_pkg.all;
	use work.sincos_pkg.all;
    use work.fixed_sqrt_pkg.all;
    use work.fpga_interconnect_pkg.all;

entity test_sqrt is
    port (
        clk                      : in std_logic;
        input_number             : in integer range 0 to 2**16-1;
        request_sqrt_calculation : in boolean;
        bus_in                   : in fpga_interconnect_record;
        bus_out                  : out fpga_interconnect_record
    );
end entity test_sqrt;

architecture rtl of test_sqrt is

    signal multiplier : multiplier_record := init_multiplier;
    signal sqrt : fixed_sqrt_record := init_sqrt;

    signal result : signed(17 downto 0) := (others => '0');

begin

    test : process(clk)
    begin
        if rising_edge(clk) then
            create_multiplier(multiplier);
            create_sqrt(sqrt,multiplier);
            init_bus(bus_out);
            connect_read_only_data_to_address(bus_in, bus_out, 15357, to_integer(result));

            if request_sqrt_calculation then
                request_sqrt(sqrt, to_signed(input_number, 18));
            end if;

            if sqrt_is_ready(sqrt) then
                result <= get_sqrt_result(sqrt, multiplier, 15);
            end if;
        end if; --rising_edge
    end process test;	

end rtl;
