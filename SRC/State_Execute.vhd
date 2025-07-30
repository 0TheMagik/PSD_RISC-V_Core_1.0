library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity State_Execute is
    port (
        clk_state           : in std_logic;
        rst_state           : in std_logic;
        en                  : in std_logic;
        reg_file_in_0       : in std_logic_vector(31 downto 0);
        reg_file_in_1       : in std_logic_vector(31 downto 0);
        reg_addr_dst_in     : in std_logic_vector(4 downto 0);
        immediate           : in std_logic_vector(31 downto 0);
        alu_op              : in std_logic_vector(3 downto 0);
        mux_2_1_alu_sel     : in std_logic;
        wr_back_en_in       : in std_logic;
        mux_2_1_wb_sel_in   : in std_logic;
        pc_current          : in std_logic_vector(31 downto 0);
        jump_branch_unit_op : in std_logic_vector(3 downto 0);
        jump_branch_unit_en : in std_logic;
        alu_out             : out std_logic_vector(31 downto 0);
        pc_next             : out std_logic_vector(31 downto 0);
        jump_branch_flag    : out std_logic;
        reg_addr_dst_out    : out std_logic_vector(4 downto 0);
        wr_back_en_out      : out std_logic;
        mux_2_1_wb_sel_out  : out std_logic
    );
end entity State_Execute;

architecture rtl of State_Execute is
    
    component Mux2to1
    port (
        in_mux_0    : in std_logic_vector(31 downto 0);
        in_mux_1    : in std_logic_vector(31 downto 0);
        out_mux     : out std_logic_vector(31 downto 0);
        sel_mux     : in std_logic
    );
    end component;

    component ALU
    port (
        input_0     : in std_logic_vector(31 downto 0);
        input_1     : in std_logic_vector(31 downto 0);
        op_ALU      : in std_logic_vector(3 downto 0);
        output_ALU  : out std_logic_vector(31 downto 0)
    );
    end component;

    component Jump_Branch_Unit 
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
    end component;

    signal mux2_1_out : std_logic_vector(31 downto 0);

begin

    Mux_2_1_Alu_inst : Mux2to1
    port map(
        in_mux_0    => reg_file_in_1,
        in_mux_1    => immediate,
        out_mux     => mux2_1_out,
        sel_mux     => mux_2_1_alu_sel
    );
    
    ALU_inst : ALU
    port map(
        input_0     => reg_file_in_0,
        input_1     => mux2_1_out,
        op_ALU      => alu_op,
        output_ALU  => alu_out
    );

    Jump_Branch_Unit_inst : Jump_Branch_Unit
    port map(
        en          => en,
        clk         => clk_state,
        rst         => rst_state,
        
        pc_current  => pc_current,
        input_0     => reg_file_in_0,
        input_1     => reg_file_in_1,
        immediate   => immediate,
        jump_branch_op   => jump_branch_unit_op, 
        
        pc_next          => pc_next,
        jump_branch_flag => jump_branch_flag
    );
    
    reg_addr_dst_out    <= reg_addr_dst_in;
    wr_back_en_out      <= wr_back_en_in;
    mux_2_1_wb_sel_out  <= mux_2_1_wb_sel_in;
end architecture rtl;