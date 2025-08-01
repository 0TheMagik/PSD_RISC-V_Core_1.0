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

        wait until rising_edge(clk);
        rst <= '0';
        en_load <= '1';
        load_data <= x"00000013"; -- addi x0, x0, 0
        load_addr <= x"00000000"; -- PC = 0

        wait until rising_edge(clk);
        load_data <= x"00000013"; -- addi x0, x0, 0
        load_addr <= x"00000004"; -- PC = 4

        wait until rising_edge(clk);
        load_data <= x"00a00113"; -- addi x2, x0, 10
        load_addr <= x"00000008"; -- PC = 8

        wait until rising_edge(clk);
        load_data <= x"00a00193"; -- addi x3, x0, 10
        load_addr <= x"0000000c"; -- PC = 12

        wait until rising_edge(clk);
        load_data <= x"00a00213"; -- addi x4, x0, 10
        load_addr <= x"00000010"; -- PC = 16

        wait until rising_edge(clk);
        load_data <= x"00202023"; -- sw x2, 0(0)
        load_addr <= x"00000014"; -- PC = 20

        wait until rising_edge(clk);
        load_data <= x"003100b3"; -- add x1, x2, x3
        load_addr <= x"00000018"; -- PC = 24

        wait until rising_edge(clk);
        load_data <= x"00000013"; -- addi x0, x0, 0
        load_addr <= x"0000001c"; -- PC = 28

        wait until rising_edge(clk);
        load_data <= x"0051c293"; -- xori x5, x3, 5
        load_addr <= x"00000020"; -- PC = 3

        wait until rising_edge(clk);
        load_data <= x"00202023"; -- sw x2, 0(0)
        load_addr <= x"00000024"; -- PC = 24

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