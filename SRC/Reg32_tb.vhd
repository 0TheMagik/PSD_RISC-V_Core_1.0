library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use std.env.finish;

entity Reg32_tb is
end entity Reg32_tb;

architecture sim of Reg32_tb is
    
    signal clk          : std_logic;
    signal rst          : std_logic;
    signal load         : std_logic;
    signal reg_data_in  : std_logic_vector(31 downto 0);
    signal reg_data_out : std_logic_vector(31 downto 0);

begin
    DUT: entity work.Reg32(Behavioral)
    port map(
        clk         => clk,
        rst         => rst,
        load        => load,
        reg_data_in => reg_data_in,
        reg_data_out=> reg_data_out
    );

    input_tb: process
    begin
        rst  <= '0';
        load <= '0';

        

        for i in 1 to 700 loop
            reg_data_in <= std_logic_vector(to_unsigned(i, 32));
            wait for 10 ns;
        end loop;

        reg_data_in <= (others => '1');
        
        load <= '1';
        for i in 0 to 700 loop
            reg_data_in <= std_logic_vector(to_unsigned(i, 32));
            wait for 10 ns;
        end loop;

        report "test done";
        finish;
    end process input_tb;
    
    output_tb: process
        variable data_prev : std_logic_vector(31 downto 0);
    begin
        data_prev := reg_data_out;

        wait on reg_data_out;

        case load is
            when '0' =>
                
                if reg_data_out = reg_data_in then
                    report "test failed, data changed when load = "& to_string(load)
                    severity error; 

                end if;

            when '1' =>
                if  reg_data_out = data_prev then
                    report "test failed, data not changed when load = "& to_string(load)
                    severity error; 
                end if;

            when others => 
                report "test failed, input failed"
                severity error;
        end case;


    end process output_tb;
    
end architecture sim;