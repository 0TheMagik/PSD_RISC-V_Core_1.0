library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Reg32 is
    port (
        clk     : in std_logic;
        rst     : in std_logic;
        load    : in std_logic;
        reg_data_in : in std_logic_vector(31 downto 0);
        reg_data_out: out std_logic_vector(31 downto 0)
    );
end entity Reg32;

architecture Behavioral of Reg32 is
    
    signal data : std_logic_vector(31 downto 0) := (others => '0');

begin

    process(clk, rst)
    begin
        if rst = '1' then
            data <= (others => '0');

        elsif rising_edge(clk) then

            if load = '1' then
                data <= reg_data_in;            
            else
                data <= data;
            end if;

        end if;
    end process;
    
    reg_data_out <= data;
    
    
end architecture Behavioral;