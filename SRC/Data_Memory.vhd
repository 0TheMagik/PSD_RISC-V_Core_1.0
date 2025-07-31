library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Data_Memory is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        load_en     : in std_logic;
        format      : in std_logic_vector(2 downto 0);
        data_in     : in std_logic_vector(31 downto 0);
        address     : in std_logic_vector(31 downto 0);
        data_out    : out std_logic_vector(31 downto 0)        
    );
end entity Data_Memory;

architecture rtl of Data_Memory is
    
    type memory is array (0 to 2047) of std_logic_vector(7 downto 0);
    signal mem : memory := (others => (others => '0'));
    
    function convert_addr(addr : std_logic_vector(10 downto 0)) return integer is
    begin
        return to_integer(unsigned(addr));
    end function;

    signal data_read : std_logic_vector(31 downto 0);
begin
    
    access_mem: process(clk, rst, load_en)
        variable addr_mem : integer;
        variable halfword : std_logic_vector(15 downto 0);
    begin
        addr_mem := convert_addr(address(10 downto 0));

        if rst = '1' then
            mem <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if load_en = '1' then
                data_read <= (others => '0');
                case format is
                    when "000" => -- SB
                        mem(addr_mem) <=  data_in(7 downto 0);
                    
                    when "001" => -- SH
                        mem(addr_mem) <=  data_in(7 downto 0);
                        mem(addr_mem+1) <= data_in(15 downto 8);

                    when "010" => -- SW
                        mem(addr_mem) <=  data_in(7 downto 0);
                        mem(addr_mem+1) <=  data_in(15 downto 8);
                        mem(addr_mem+2) <=  data_in(23 downto 16);
                        mem(addr_mem+3) <=  data_in(31 downto 24);

                    when others =>
                
                end case;
            else
                case format is
                    when "000" => -- LB
                        data_read <= std_logic_vector(resize(signed(mem(addr_mem)),32));

                    when "001" => -- LH
                        halfword := mem(addr_mem+1) & mem(addr_mem);
                        data_read <= std_logic_vector(resize(signed(halfword),32));

                    when "010" => -- LW
                        data_read <= mem(addr_mem+3) & mem(addr_mem+2) & mem(addr_mem+1) & mem(addr_mem);
                    when "100" => -- LBU
                        data_read <= x"000000" & mem(addr_mem);
                    
                    when "101" => -- LHU
                        data_read <= x"0000" & mem(addr_mem+1) & mem(addr_mem);
                
                    when others =>
                        data_read <= (others => '0');
                
                end case;
            end if;
        end if;
    end process access_mem;
    
    data_out <= data_read;
    
end architecture rtl;