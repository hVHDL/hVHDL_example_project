library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.fpga_interconnect_pkg.all;
    use work.multiplier_pkg.radix_multiply;
    use work.sigma_delta_cic_filter_pkg.all;
    use work.iir_filter_pkg.all;

entity sigma_delta_filter is
    port (
        system_clock    : in std_logic;
        bus_from_master : in fpga_interconnect_record;
        bus_to_master   : out fpga_interconnect_record;
        sdm_data        : in std_logic;
        sdm_clock       : out std_logic
    );
end entity sigma_delta_filter;


architecture rtl of sigma_delta_filter is

    constant filter_wordlength : integer := 26;
    type intarray is array (integer range 0 to 4) of integer range -2**filter_wordlength to 2**filter_wordlength-1;


    signal filter_bank : intarray := (others => 0);
    signal cic_filter_data : std_logic;
    signal cic_filter : cic_filter_record := init_cic_filter;

    signal sdm_clock_counter : integer range 0 to 15;
    signal sample_instant : integer range 0 to 7 := 3;

    constant fix_b1 : fix_array(0 to 2) := to_fixed((1.10112824474792e-003  , 2.19578135597009e-003  , 1.09466577037144e-003));
    constant fix_b2 : fix_array(0 to 2) := to_fixed((1.16088276025753e-003  , 2.32172985621810e-003  , 1.16086054728631e-003));
    constant fix_b3 : fix_array(0 to 2) := to_fixed(((42.4644359704529e-003 , 85.1798866651586e-003  , 42.7159465798333e-003) / 58.875768));
    constant fix_a1 : fix_array(0 to 2) := to_fixed((1.00000000000000e+000  , -1.97840025988718e+000 , 987.883963652581e-003));
    constant fix_a2 : fix_array(0 to 2) := to_fixed((1.00000000000000e+000  , -1.96191974906017e+000 , 967.208461633959e-003));
    constant fix_a3 : fix_array(0 to 2) := to_fixed((1.00000000000000e+000  , -1.95425095615658e+000 , 955.427665692536e-003));

    signal fix_memory1 : fix_array(0 to 1) := (others => 0);
    signal fix_memory2 : fix_array(0 to 1) := (others => 0);
    signal fix_memory3 : fix_array(0 to 1) := (others => 0);

    signal filter_outputs : fix_array(0 to 2) := (others => 0);
    alias fix_filter_out  is filter_outputs(0);
    alias fix_filter_out1 is filter_outputs(1);
    alias fix_filter_out2 is filter_outputs(2);

    signal state_counter : integer range 0 to 7;
begin

    sdm_clock_generator : process(system_clock)
    --------------------------------------------------
    function filter_with_bank
    (
        filterbank : intarray;
        input_bit : std_logic
    )
    return intarray
    is
        variable data : unsigned(filter_wordlength downto 0);
        variable filtered_data : intarray;
        ------------------------------
        function "*" ( left: integer; right : real)
        return integer
        is
            constant word_length : integer := filter_wordlength+1;
            constant radix : integer := filter_wordlength;
        begin
            return work.multiplier_pkg.radix_multiply(left,integer(right*2.0**filter_wordlength), word_length, radix);
        end "*";
        ------------------------------

        constant filter_gain : real := 0.1;


    begin
        data := (filter_wordlength=> (not input_bit), others => '0');
        filtered_data(0) := filterbank(0) + (to_integer(data) - filterbank(0))*filter_gain;

        for i in 1 to intarray'high loop
            filtered_data(i) := filterbank(i) + (filterbank(i-1) - filterbank(i))*filter_gain;
        end loop;
        return filtered_data;
    end filter_with_bank;
    --------------------------------------------------
    impure function to_fixed
    (
        sdm_input : std_logic 
    )
    return integer
    is
        variable returned_value : integer;
    begin
        if sdm_input = '1' then
            returned_value := to_fixed(1.0);
        else
            returned_value := to_fixed(0.0);
        end if;

        return returned_value;
        
    end to_fixed;
    begin
        if rising_edge(system_clock) then
            init_bus(bus_to_master);
            connect_read_only_data_to_address(bus_from_master , bus_to_master , 255                , get_cic_filter_output(cic_filter)+32768);
            connect_read_only_data_to_address(bus_from_master , bus_to_master , 256                , filter_bank(2)/2**(filter_wordlength-16));
            connect_read_only_data_to_address(bus_from_master , bus_to_master , 257                , filter_bank(3)/2**(filter_wordlength-16));
            connect_read_only_data_to_address(bus_from_master , bus_to_master , 258                , filter_bank(4)/2**(filter_wordlength-16));

            connect_read_only_data_to_address(bus_from_master , bus_to_master , 259                , fix_filter_out /2**0);
            connect_read_only_data_to_address(bus_from_master , bus_to_master , 260                , fix_filter_out1/2**0);
            connect_read_only_data_to_address(bus_from_master , bus_to_master , 261                , fix_filter_out2/2**0);

            connect_data_to_address(bus_from_master , bus_to_master , 259                , sample_instant);

            if sdm_clock_counter > 0 then
                sdm_clock_counter <= sdm_clock_counter -1;
            else
                sdm_clock_counter <= 5;
            end if;

            if sdm_clock_counter > 5/2 then
                sdm_clock <= '1';
            else
                sdm_clock <= '0';
            end if;

            if state_counter < 5 then
                state_counter <= state_counter + 1;
            end if;
            testi(fix_memory1 , to_fixed(cic_filter_data) , fix_filter_out  , state_counter , fix_b1 , fix_a1 , 0);
            testi(fix_memory2 , fix_filter_out            , fix_filter_out1 , state_counter , fix_b2 , fix_a2 , 1);
            testi(fix_memory3 , fix_filter_out1           , fix_filter_out2 , state_counter , fix_b3 , fix_a3 , 2);

            cic_filter_data <= sdm_data;
            if sample_instant <= 5 then
                if sdm_clock_counter = sample_instant then
                    calculate_cic_filter(cic_filter, cic_filter_data);
                    filter_bank <= filter_with_bank(filter_bank, cic_filter_data);
                    state_counter <= 0;
                end if;
            else
                if sdm_clock_counter = 5 then
                    calculate_cic_filter(cic_filter, cic_filter_data);
                    filter_bank <= filter_with_bank(filter_bank, cic_filter_data);
                end if;
            end if;

        end if; --rising_edge
    end process sdm_clock_generator;	

end rtl;
