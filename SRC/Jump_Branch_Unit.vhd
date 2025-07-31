library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Jump_Branch_Unit is
    port (
        en          : in std_logic;
        clk         : in std_logic;
        rst         : in std_logic;
        
        pc_current  : in std_logic_vector(31 downto 0);
        input_0     : in std_logic_vector(31 downto 0);        
        input_1     : in std_logic_vector(31 downto 0);
        immediate   : in std_logic_vector(31 downto 0);
        jump_branch_op   : in std_logic_vector(3 downto 0); 
        
        pc_next          : out std_logic_vector(31 downto 0);
        jump_branch_flag : out std_logic
    );
end entity Jump_Branch_Unit;

architecture rtl of Jump_Branch_Unit is

    signal address_target : std_logic_vector(31 downto 0);
    
begin
--     logic: process(pc_current, input_0, input_1, immediate, jump_branch_op)
--     begin
--         jump_branch_flag <= '0';
--         -- address_target <= std_logic_vector(unsigned(pc_current) + 4);


--     end process logic;


    output: process(clk, rst)
    begin
        if rst = '1' then
            pc_next <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                case jump_branch_op is
                    when "0000" => -- BEQ 
                        if input_0 = input_1 then
                            jump_branch_flag <= '1';
                            address_target <= std_logic_vector(unsigned(pc_current)+ unsigned(immediate));
                        else
                            jump_branch_flag <= '0';
                        end if;

                    when "0001" => -- BNE
                        if input_0 /= input_1 then
                            jump_branch_flag <= '1';
                            address_target <= std_logic_vector(unsigned(pc_current)+ unsigned(immediate));
                        else
                            jump_branch_flag <= '0';
                        end if;
        
                    when "0100" => -- BLT
                        if signed(input_0) < signed(input_1) then
                            jump_branch_flag <= '1';
                            address_target <= std_logic_vector(unsigned(pc_current)+ unsigned(immediate));
                        else
                            jump_branch_flag <= '0';
                        end if;

                    when "0101" => -- BGE
                        if signed(input_0) >= signed(input_1) then
                            jump_branch_flag <= '1';
                            address_target <= std_logic_vector(unsigned(pc_current)+ unsigned(immediate));
                        else
                            jump_branch_flag <= '0';
                        end if;

                    when "0110" => -- BLTU
                        if unsigned(input_0) < unsigned(input_1) then
                            jump_branch_flag <= '1';
                            address_target <= std_logic_vector(unsigned(pc_current)+ unsigned(immediate));
                        else
                            jump_branch_flag <= '0';
                        end if;

                    when "0111" => -- BGEU 
                        if unsigned(input_0) >= unsigned(input_1) then
                            jump_branch_flag <= '1';
                            address_target <= std_logic_vector(unsigned(pc_current)+ unsigned(immediate));
                        else
                            jump_branch_flag <= '0';
                        end if;

                    when "1000" => -- JAL
                        jump_branch_flag <= '1';
                        address_target <= std_logic_vector(unsigned(pc_current)+ unsigned(immediate));
                        address_target(0) <= '0'; 
                    
                    when "1001" => -- JALR
                        jump_branch_flag <= '1';
                        address_target <= std_logic_vector(unsigned(input_0)+ unsigned(immediate));
                        address_target(0) <= '0'; 
                            
                    when others =>
                        jump_branch_flag <= '0';
                        address_target <= std_logic_vector(unsigned(pc_current) + 4);
                end case;

                pc_next <= address_target;

            else
                pc_next <= std_logic_vector(unsigned(pc_current) + 4);
                jump_branch_flag <= '0';

            end if;
        end if;
    end process output;

    
end architecture rtl;