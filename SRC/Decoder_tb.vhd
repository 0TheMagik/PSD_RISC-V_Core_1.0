-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;
-- use IEEE.std_logic_textio.all;

-- use std.env.finish;

-- entity Decoder_tb is
-- end entity Decoder_tb;

-- architecture sim of Decoder_tb is
    
--     signal clk              : std_logic := '1';
--     signal rst              : std_logic := '0';
--     signal instruction      : std_logic_vector(31 downto 0) := (others => '0');
--     signal opcode           : std_logic_vector(6 downto 0) := (others => '0');
--     signal reg_address_0    : std_logic_vector(4 downto 0) := (others => '0');
--     signal reg_address_1    : std_logic_vector(4 downto 0) := (others => '0');
--     signal reg_address_dst  : std_logic_vector(4 downto 0) := (others => '0');
--     signal immediate        : std_logic_vector(31 downto 0) := (others => '0');
--     signal alu_op           : std_logic_vector(3 downto 0); -- := (others => '0');
--     signal mux2_1_sel       : std_logic;

-- begin
--     DUT: entity work.Decoder(rtl) 
--     port map(
--         clk             => clk,
--         rst             => rst,
--         instruction     => instruction,
--         opcode          => opcode,
--         reg_address_0   => reg_address_0,
--         reg_address_1   => reg_address_1,
--         reg_address_dst => reg_address_dst,
--         immediate       => immediate,
--         alu_op          => alu_op,
--         mux2_1_sel      => mux2_1_sel
--     );
    
--     input_tb: process
--     begin
--         instruction <= "01000000001100010000000010110011";
--         wait for 50 ns;

--         instruction <= "00000110010000010000000010010011"; -- addi
--         wait for 50 ns;

--         instruction <= "00000011001000010010000010010011";-- SLTI
--         wait for 50 ns;

--         instruction <= "00000011001000010011000010010011";-- SLTIU
--         wait for 50 ns;

--         instruction <= "00001111111100010100000010010011";-- XORI
--         wait for 50 ns;

--         instruction <= "00001111111100010110000010010011";-- ORI
--         wait for 50 ns;

--         instruction <= "00001111111100010111000010010011";-- ANDI
--         wait for 50 ns;

--         instruction <= "00000000001100010001000010010011";-- SLLI
--         wait for 50 ns;

--         instruction <= "00000000001100010101000010010011";-- SRLI
--         wait for 50 ns;

--         instruction <= "01000000001100010101000010010011";-- SRAI
--         wait for 50 ns;

--         finish;
--         -- wait;
--     end process input_tb;
    
--     output_tb: process
--         -- variable tb_alu_op : std_logic_vector(alu_op' range);
--         -- variable tb_instruction : std_logic_vector(instruction' range);

--     begin
--         -- tb_instruction := instruction;

--         wait on instruction;

--         case instruction(6 downto 2) is
--             when "01100" =>
--                 wait on alu_op;
--                 -- tb_alu_op := alu_op;
--                     if alu_op = instruction(30) & instruction(14 downto 12) then
--                         report "test correct ALU OP is " & to_string(alu_op);
--                     else
--                         report "test failed ALU OP is "& to_string(alu_op);
--                     end if;
                
--             when others =>
--                 report "no test";
                
--         end case;
--     end process output_tb;
    
-- end architecture sim;