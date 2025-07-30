library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RegFile is
    port (
        clk             : in std_logic;
        load            : in std_logic;
        rst             : in std_logic;
        addr_read_0     : in std_logic_vector(4 downto 0);
        addr_read_1     : in std_logic_vector(4 downto 0);
        addr_write_0    : in std_logic_vector(4 downto 0);
        data_in         : in std_logic_vector(31 downto 0);
        data_out_0      : out std_logic_vector(31 downto 0);
        data_out_1      : out std_logic_vector(31 downto 0)
    );
end entity RegFile;


architecture Behavioral of RegFile is

    type register_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal x : register_array := (others => (others => '0'));


function convert_addr(addr : std_logic_vector(4 downto 0)) return integer is
begin
    return to_integer(unsigned(addr));
end function;

    -- bounded integer
    signal wr0_int : integer range 0 to 31;
    signal rd0_int : integer range 0 to 31;
    signal rd1_int : integer range 0 to 31;

begin

    -- convertion addres to integer 
    -- improve readability
    wr0_int <= convert_addr(addr_write_0);
    rd0_int <= convert_addr(addr_read_0);
    rd1_int <= convert_addr(addr_read_1);

    write: process(clk, rst)
    begin
        
        if rst = '1' then
            
            for i in 0 to 31  loop
                x(i) <= (others => '0');
            end loop;

        elsif rising_edge(clk) and load = '1' then
            
            if  wr0_int /= 0 then
                x(wr0_int) <= data_in;
            end if;
        
        end if;
    end process write;

    data_out_0 <= (others => '0') when rd0_int = 0 else x(rd0_int);
    data_out_1 <= (others => '0') when rd1_int = 0 else x(rd1_int);

end architecture Behavioral;