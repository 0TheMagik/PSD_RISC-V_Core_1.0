library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Program_Counter is
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        en                  : in std_logic;
        en_load             : in std_logic;
        jmp_branch_flag     : in std_logic;
        address             : in std_logic_vector(31 downto 0);
        address_jmp_branch  : in std_logic_vector(31 downto 0);
        address_out         : out std_logic_vector(31 downto 0)
    );
end entity Program_Counter;


architecture rtl of Program_Counter is
    
    signal pc_address : std_logic_vector(31 downto 0);

begin
    pc: process(clk, rst)
    begin
        if rst = '1' then
            pc_address <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' and en_load = '0' then
                if jmp_branch_flag = '1' then
                    pc_address <= address_jmp_branch;
                else
                    pc_address <= std_logic_vector(unsigned(address)+4);
                end if;
            elsif en = '0' and rst = '1' then
                    pc_address <= address;
            end if;
        end if;
    end process pc;
    
    address_out <= pc_address;
    
end architecture rtl;