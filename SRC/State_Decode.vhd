library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity State_Decode is
    port (
        clk_state           : in std_logic;
        rst_state           : in std_logic;
        en                  : in std_logic;
        load_state          : in std_logic;
        reg_data_write_0    : in std_logic_vector(31 downto 0);
        reg_addr_write_0    : in std_logic_vector(4 downto 0);
        instruction         : in std_logic_vector(31 downto 0);
        reg_file_out_0      : out std_logic_vector(31 downto 0);
        reg_file_out_1      : out std_logic_vector(31 downto 0);
        reg_addr_dst        : out std_logic_vector(4 downto 0);
        immediate           : out std_logic_vector(31 downto 0);
        alu_op              : out std_logic_vector(3 downto 0);
        mux_2_1_alu_sel     : out std_logic;
        wr_back_en          : out std_logic;
        mux_2_1_wb_sel      : out std_logic;
        data_mem_write_en   : out std_logic;
        data_mem_format     : out std_logic_vector(2 downto 0);
        jump_branch_unit_op : out std_logic_vector(3 downto 0);
        jump_branch_unit_en : out std_logic
    );
end entity State_Decode;

architecture rtl of State_Decode is
    
    component RegFile 
    port (
        clk             : in std_logic;
        load            : in std_logic;
        rst             : in std_logic;
        addr_read_0     : in std_logic_vector(4 downto 0);
        addr_read_1     : in std_logic_vector(4 downto 0);
        addr_write_0    : in std_logic_vector(4 downto 0);
        data_in         : in std_logic_vector(31 downto 0);
        data_out_0      : out std_logic_vector(31 downto 0);
        data_out_1      : out std_logic_vector(31 downto 0)
    );
    end component;

    component Decoder
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        instruction         : in std_logic_vector(31 downto 0);
        reg_address_0       : out std_logic_vector(4 downto 0);
        reg_address_1       : out std_logic_vector(4 downto 0);
        reg_address_dst     : out std_logic_vector(4 downto 0);
        immediate           : out std_logic_vector(31 downto 0);
        alu_op              : out std_logic_vector(3 downto 0);
        mux_2_1_alu_sel     : out std_logic;
        wr_back_en          : out std_logic;
        mux_2_1_wb_sel      : out std_logic;
        data_mem_write_en   : out std_logic;
        data_mem_format     : out std_logic_vector(2 downto 0);
        jump_branch_unit_op : out std_logic_vector(3 downto 0);
        jump_branch_unit_en : out std_logic
    );
    end component;

    signal decode_regfile_0     : std_logic_vector(4 downto 0);
    signal decode_regfile_1     : std_logic_vector(4 downto 0);
    signal decode_regfile_dst   : std_logic_vector(4 downto 0);
    signal clk_ctrl             : std_logic;
    signal load_ctrl            : std_logic;

begin

    clk_ctrl <= clk_state AND en;
    load_ctrl <= load_state AND en;

    RegFile_inst: RegFile 
    port map(
        clk             => clk_state,                       -- in
        load            => load_ctrl,                       -- in
        rst             => rst_state,                       -- in
        addr_read_0     => decode_regfile_0,                -- in
        addr_read_1     => decode_regfile_1,                -- in
        addr_write_0    => reg_addr_write_0,                -- in
        data_in         => reg_data_write_0,                -- in
        data_out_0      => reg_file_out_0,                  -- out
        data_out_1      => reg_file_out_1                   -- out
    );


    Decoder_inst: Decoder 
    port map(
        clk                 => clk_state,                   -- in
        rst                 => rst_state,                   -- in
        instruction         => instruction,                 -- in
        reg_address_0       => decode_regfile_0,            -- out
        reg_address_1       => decode_regfile_1,            -- out
        reg_address_dst     => reg_addr_dst,                -- out
        immediate           => immediate,                   -- out
        alu_op              => alu_op,                      -- out
        mux_2_1_alu_sel     => mux_2_1_alu_sel,             -- out
        wr_back_en          => wr_back_en,                  -- out
        mux_2_1_wb_sel      => mux_2_1_wb_sel,              -- out
        data_mem_write_en   => data_mem_write_en,           -- out
        data_mem_format     => data_mem_format,             -- out
        jump_branch_unit_op => jump_branch_unit_op,         -- out
        jump_branch_unit_en => jump_branch_unit_en          -- out
    );
    
end architecture rtl;