library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Mux2to1_tb is
end entity Mux2to1_tb;

architecture sim of Mux2to1_tb is
    
    signal in_mux_0 : std_logic_vector(31 downto 0) := (others => '0');
    signal in_mux_1 : std_logic_vector(31 downto 0) := (others => '1');
    signal out_mux  : std_logic_vector(31 downto 0);
    signal sel_mux  : std_logic;

begin
    DUT : entity work.Mux2to1(rtl)
    port map (
        in_mux_0    => in_mux_0,
        in_mux_1    => in_mux_1,
        out_mux     => out_mux,
        sel_mux     => sel_mux
    );
    

    input_tb: process
    begin

        sel_mux <= '0';
        wait for 10 ns;
        sel_mux <= '1';
        wait;

    end process input_tb;

    output_tb: process
        variable mux_out : std_logic_vector(out_mux' range);
        variable mux_sel : std_logic;
    begin
        wait on sel_mux;
        wait on out_mux;

        mux_out := out_mux;
        mux_sel := sel_mux;

        -- wait for 1 ns;
    
        if mux_sel = '0' then
            if mux_out = (mux_out'range => '0') then
                report "in_mux_0 Corect";
            else
                report "in_mux_0 False";
            end if;

        elsif mux_sel = '1' then
            if mux_out = (mux_out'range => '1') then
                report "in_mux_1 Corect";
            else
                report "in_mux_1 False";
            end if;
        end if;

    end process output_tb;
    
end architecture ;