library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Hazard_Unit is
    port (
        -- decode-execute
        decode_execute_wrback_en        : in std_logic;
        decode_execute_reg_addr_dst     : in std_logic_vector(4 downto 0);

        execute_wb_wr_back_en           : in std_logic;
        execute_wb_reg_addr_dst         : in std_logic_vector(4 downto 0);

        hold_pc                         : out std_logic;
        stall                           : out std_logic   
    );
end entity Hazard_Unit;


architecture behavioral of Hazard_Unit is
    
begin

    stall_unit: process(decode_execute_wrback_en, decode_execute_reg_addr_dst, execute_wb_wr_back_en, execute_wb_reg_addr_dst)
    begin
        if (decode_execute_wrback_en ='1' and execute_wb_wr_back_en = '1')then
            if (decode_execute_reg_addr_dst = execute_wb_reg_addr_dst) then
                stall <= '1';  
                hold_pc <= '1';
            else
                stall <= '0';
                hold_pc <= '0';
            end if;
        end if;
    end process stall_unit;
    
    
end architecture behavioral;