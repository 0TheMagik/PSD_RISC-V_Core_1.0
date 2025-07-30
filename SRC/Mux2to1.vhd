library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Mux2to1 is
    port (
        in_mux_0    : in std_logic_vector(31 downto 0);
        in_mux_1    : in std_logic_vector(31 downto 0);
        out_mux     : out std_logic_vector(31 downto 0);
        sel_mux     : in std_logic
    );
end entity Mux2to1;

architecture rtl of Mux2to1 is
    
begin
    
    with sel_mux select
        out_mux <= 
        in_mux_0 when '0',
        in_mux_1 when '1',
        (others => 'X') when others;
    
    
end architecture ;