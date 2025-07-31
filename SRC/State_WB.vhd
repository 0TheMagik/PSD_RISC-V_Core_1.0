library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity State_WB is
    port (
        clk_state           : in std_logic;
        rst_state           : in std_logic;
        en_state            : in std_logic;
        data_mem_write_en   : in std_logic;
        data_mem_format     : in std_logic_vector(2 downto 0);
        data_mem_data_in    : in std_logic_vector(31 downto 0);
        data_mem_address    : in std_logic_vector(31 downto 0);
        alu_reslt_in        : in std_logic_vector(31 downto 0);
        reg_addr_dst_in     : in std_logic_vector(4 downto 0);
        wr_back_en_in       : in std_logic;
        mux_2_1_wb_sel      : in std_logic;
        data_out            : out std_logic_vector(31 downto 0);
        reg_addr_dst_out    : out std_logic_vector(4 downto 0);
        wr_back_en_out      : out std_logic
    );
end entity State_WB;

architecture rtl of State_WB is
    component Data_Memory
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        load_en     : in std_logic;
        format      : in std_logic_vector(2 downto 0);
        data_in     : in std_logic_vector(31 downto 0);
        address     : in std_logic_vector(31 downto 0);
        data_out    : out std_logic_vector(31 downto 0)        
    );
    end component;

    component Mux2to1
    port (
        in_mux_0    : in std_logic_vector(31 downto 0);
        in_mux_1    : in std_logic_vector(31 downto 0);
        out_mux     : out std_logic_vector(31 downto 0);
        sel_mux     : in std_logic
    );
    end component;

    -- signal input_mux_0 : std_logic_vector(31 downto 0);
    signal data_mem_input_mux : std_logic_vector(31 downto 0);
begin
    
    Data_Mem_int : Data_Memory
    port map(
        clk         => clk_state,               -- in
        rst         => rst_state,               -- in
        load_en     => data_mem_write_en,       -- in
        format      => data_mem_format,         -- in
        data_in     => data_mem_data_in,        -- in
        address     => data_mem_address,        -- in
        data_out    => data_mem_input_mux       -- out
    );

    Mux_2_1_WB  : Mux2to1
    port map(
        in_mux_0    => alu_reslt_in,            -- in
        in_mux_1    => data_mem_input_mux,      -- in
        out_mux     => data_out,                -- out
        sel_mux     => mux_2_1_wb_sel           -- in
    );
    
    reg_addr_dst_out    <= reg_addr_dst_in;
    wr_back_en_out      <= wr_back_en_in;
end architecture rtl;