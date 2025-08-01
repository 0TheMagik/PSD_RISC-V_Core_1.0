library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use std.env.finish;
-- Compile dengan VHDL 2008

entity Core_tb is
end entity Core_tb;

architecture sim of Core_tb is

    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal en          : std_logic := '0';
    
    -- load pc
    signal en_load     : std_logic := '0';
    signal load_data   : std_logic_vector(31 downto 0) := (others => '0');
    signal load_addr   : std_logic_vector(31 downto 0) := (others => '0');

    constant clk_period : time := 10 ns;

begin
    DUT : entity work.Core(rtl)
    port map(
        clk         => clk,
        rst         => rst,
        en          => en,
        
        -- load pc
        en_load     => en_load,
        load_data   => load_data,
        load_addr   => load_addr
    );   
    
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process clk_process;
    
    input: process
    begin
        rst <= '1';
        en <= '0';

        en_load <= '0';
        load_data <= (others => '0');
        load_addr <= (others => '0');
        wait for clk_period * 2;

        -- Commented out test cases for manual testing
        -- Uncomment to run specific test cases
        -- -- Test Case 1
        -- wait until rising_edge(clk);
        -- rst <= '0';
        -- en_load <= '1';
        -- load_data <= x"00000013"; -- addi x0, x0, 0
        -- load_addr <= x"00000000"; -- PC = 0

        -- wait until rising_edge(clk);
        -- load_data <= x"00000013"; -- addi x0, x0, 0
        -- load_addr <= x"00000004"; -- PC = 4

        -- wait until rising_edge(clk);
        -- load_data <= x"00100093"; -- addi x1, x0, 1
        -- load_addr <= x"00000008"; -- PC = 8

        -- wait until rising_edge(clk);
        -- load_data <= x"00200113"; -- addi x2, x0, 2
        -- load_addr <= x"0000000c"; -- PC = 12

        -- wait until rising_edge(clk);
        -- load_data <= x"00300193"; -- addi x3, x0, 3
        -- load_addr <= x"00000010"; -- PC = 16

        -- wait until rising_edge(clk);
        -- load_data <= x"00400213"; -- addi x4, x0, 4
        -- load_addr <= x"00000014"; -- PC = 20

        -- wait until rising_edge(clk);
        -- load_data <= x"00500293"; -- addi x5, x0, 5
        -- load_addr <= x"00000018"; -- PC = 24

        -- wait until rising_edge(clk);
        -- load_data <= x"00600313"; -- addi x6, x0, 6
        -- load_addr <= x"0000001c"; -- PC = 28

        -- wait until rising_edge(clk);
        -- load_data <= x"00700393"; -- addi x7, x0, 7
        -- load_addr <= x"00000020"; -- PC = 32

        -- wait until rising_edge(clk);
        -- load_data <= x"00800413"; -- addi x8, x0, 8
        -- load_addr <= x"00000024"; -- PC = 36

        -- -- Test Case 2
        -- wait until rising_edge(clk);
        -- rst <= '0';
        -- en_load <= '1';
        -- load_data <= x"00000013"; -- addi x0, x0, 0
        -- load_addr <= x"00000000"; -- PC = 0

        -- wait until rising_edge(clk);
        -- load_data <= x"00000013"; -- addi x0, x0, 0
        -- load_addr <= x"00000004"; -- PC = 4

        -- wait until rising_edge(clk);
        -- load_data <= x"00100093"; -- addi x1, x0, 1
        -- load_addr <= x"00000008"; -- PC = 8

        -- wait until rising_edge(clk);
        -- load_data <= x"00200113"; -- addi x2, x0, 2
        -- load_addr <= x"0000000c"; -- PC = 12

        -- wait until rising_edge(clk);
        -- load_data <= x"00300193"; -- addi x3, x0, 3
        -- load_addr <= x"00000010"; -- PC = 16

        -- wait until rising_edge(clk);
        -- load_data <= x"00400213"; -- addi x4, x0, 4
        -- load_addr <= x"00000014"; -- PC = 20

        -- wait until rising_edge(clk);
        -- load_data <= x"0030af13"; -- slti x30, x1, 3
        -- load_addr <= x"00000018"; -- PC = 24

        -- wait until rising_edge(clk);
        -- load_data <= x"00102023"; -- sw x1, 0(x0)
        -- load_addr <= x"0000001c"; -- PC = 28

        -- wait until rising_edge(clk);
        -- load_data <= x"00110eb3"; -- add x29, x2, x1
        -- load_addr <= x"00000020"; -- PC = 32

        -- wait until rising_edge(clk);
        -- load_data <= x"00800413"; -- addi x8, x0, 8
        -- load_addr <= x"00000024"; -- PC = 36

        wait until rising_edge(clk);
        rst <= '0';
        en_load <= '1';
        load_data <= x"00000013"; -- addi x0, x0, 0
        load_addr <= x"00000000"; -- PC = 0

        wait until rising_edge(clk);
        load_data <= x"00000013"; -- addi x0, x0, 0
        load_addr <= x"00000004"; -- PC = 4

        wait until rising_edge(clk);
        load_data <= x"00100093"; -- addi x1, x0, 1
        load_addr <= x"00000008"; -- PC = 8

        wait until rising_edge(clk);
        load_data <= x"00200113"; -- addi x2, x0, 2
        load_addr <= x"0000000c"; -- PC = 12

        wait until rising_edge(clk);
        load_data <= x"00300193"; -- addi x3, x0, 3
        load_addr <= x"00000010"; -- PC = 16

        wait until rising_edge(clk);
        load_data <= x"00110eb3"; -- add x29, x2, x1
        load_addr <= x"00000014"; -- PC = 20

        wait until rising_edge(clk);
        load_data <= x"0030af13"; -- slti x30, x1, 3
        load_addr <= x"00000018"; -- PC = 24

        wait until rising_edge(clk);
        load_data <= x"00110eb3"; -- add x29, x2, x1
        load_addr <= x"0000001c"; -- PC = 28

        wait until rising_edge(clk);
        load_data <= x"00110eb3"; -- add x29, x2, x1
        load_addr <= x"00000020"; -- PC = 32

        wait until rising_edge(clk);
        load_data <= x"fc2014e3"; -- bne x0, x2, -56
        load_addr <= x"00000024"; -- PC = 36

        wait until rising_edge(clk);
        en_load <= '0'; -- stop loading instructions
        en <= '1'; -- enable the core

        for i in 0 to 30 loop
            wait until rising_edge(clk);
        end loop;

        -- wait;

        finish;

    end process input;
    
end architecture sim;