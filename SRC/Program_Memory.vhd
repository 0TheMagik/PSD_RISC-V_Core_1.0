library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Program_Memory is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        en_load     : in std_logic;
        load_data   : in std_logic_vector(31 downto 0);
        load_addr   : in std_logic_vector(31 downto 0);
        address     : in std_logic_vector(31 downto 0);
        instruction : out std_logic_vector(31 downto 0)
    );
end entity Program_Memory;

architecture rtl of Program_Memory is
    
    type memory is array (0 to 1023) of std_logic_vector(7 downto 0);
    signal mem : memory := (others => (others => '0'));

    function convert_addr(addr : std_logic_vector(9 downto 0)) return integer is
    begin
        return to_integer(unsigned(addr));
    end function;

begin

    load_mem: process(clk, rst)
        variable load_addr_int : integer;
    begin
        load_addr_int := convert_addr(load_addr(9 downto 0));
        if rst = '1' then
                mem <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if en_load = '1' then
                mem(load_addr_int) <= load_data(7 downto 0);
                mem(load_addr_int+1) <= load_data(15 downto 8);
                mem(load_addr_int+2) <= load_data(23 downto 16);
                mem(load_addr_int+3) <= load_data(31 downto 24);
            end if;
        end if;
    end process load_mem;
    
    fetch: process(address)
        variable addr_int : integer;
    begin
        addr_int := convert_addr(address(9 downto 0));
        if en_load = '0' then
            if addr_int <= 1023 then
                instruction <= mem(addr_int+3) & mem(addr_int+2) 
                            & mem(addr_int+1) & mem(addr_int);
            else
                instruction <= (others => '0');
            end if;    
        end if;
                
    end process fetch;
    
end architecture rtl;