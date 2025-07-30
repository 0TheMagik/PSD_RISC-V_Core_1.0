library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
    port (
        input_0     : in std_logic_vector(31 downto 0);
        input_1     : in std_logic_vector(31 downto 0);
        op_ALU      : in std_logic_vector(3 downto 0);
        output_ALU  : out std_logic_vector(31 downto 0)
    );
end entity ALU;


architecture rtl of ALU is

    -- signal temp_ALU : std_logic_vector(32 downto 0);
    
begin
    process(input_0, input_1, op_ALU) is
        variable temp_ALU : std_logic_vector(32 downto 0);
    begin
        case op_ALU is
            when "0000" => --ADD
                temp_ALU := std_logic_vector(signed(input_0(31) & input_0) + signed(input_1(31) & input_1));
                output_ALU <= temp_ALU(31 downto 0);   

            when "1000" => --SUB
                temp_ALU := std_logic_vector(signed(input_0(31) & input_0) - signed(input_1(31) & input_1));
                output_ALU <= temp_ALU(31 downto 0);

            when "0001" => --SLL
                output_ALU <= std_logic_vector(shift_left(unsigned(input_0), to_integer(unsigned(input_1))));
                                
            when "0010" => --SLT
                if (signed(input_0(31) & input_0) < signed(input_1(31) & input_1)) then
                    output_ALU <= "00000000000000000000000000000001";
                else
                    output_ALU <= "00000000000000000000000000000000";
                end if;

            when "0011" => --SLTU
                if (unsigned('0' & input_0) < unsigned('0' & input_1))then
                    output_ALU <= "00000000000000000000000000000001";
                else
                    output_ALU <= "00000000000000000000000000000000";
                end if;

            when "0100" => --XOR
                output_ALU <= input_0 XOR input_1;

            when "0101" => --SRL
                output_ALU <= std_logic_vector(shift_right(unsigned(input_0), to_integer(unsigned(input_1))));

            when "1101" => --SRA
                output_ALU <= std_logic_vector(shift_right(signed(input_0), to_integer(unsigned(input_1))));

            when "0110" => 
                output_ALU <= input_0 OR input_1;

            when "0111" => 
                output_ALU <= input_0 AND input_1;

            when others =>
                output_ALU <= (others => '0');
                
        
        end case;
    end process;     
    
end architecture rtl;