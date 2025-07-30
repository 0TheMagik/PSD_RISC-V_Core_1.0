library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity State_Fetch is
    port (
        clk_state   : in std_logic;
        rst_state   : in std_logic;
        en_state    : in std_logic;

        -- input to reset pc
        rst_pc      : in std_logic;

        -- input from another state
        jmp_branch_flag     : in std_logic;
        address_jmp_branch  : in std_logic_vector(31 downto 0);
        
        -- input data into progmem
        en_load     : in std_logic;
        load_data   : in std_logic_vector(31 downto 0);
        load_addr   : in std_logic_vector(31 downto 0);

        -- address out
        instruction : out std_logic_vector(31 downto 0)
    );
end entity State_Fetch;

architecture rtl of State_Fetch is
    component Program_Counter
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        en                  : in std_logic;
        en_load             : in std_logic;
        jmp_branch_flag     : in std_logic;
        address             : in std_logic_vector(31 downto 0);
        address_jmp_branch  : in std_logic_vector(31 downto 0);
        address_out         : out std_logic_vector(31 downto 0)
    );
    end component;

    component Program_Memory
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        en_load     : in std_logic;
        load_data   : in std_logic_vector(31 downto 0);
        load_addr   : in std_logic_vector(31 downto 0);
        address     : in std_logic_vector(31 downto 0);
        instruction : out std_logic_vector(31 downto 0)
    );
    end component;

    signal address  : std_logic_vector(31 downto 0);
    signal address_pc_progmem   : std_logic_vector(31 downto 0);
    signal address_pc_feedback  : std_logic_vector(31 downto 0);
begin
    
    PC_inst : Program_Counter
    port map(
        clk                 => clk_state,
        rst                 => rst_pc,
        en                  => en_state,
        en_load             => en_load,
        jmp_branch_flag     => jmp_branch_flag,
        address             => address_pc_progmem,
        address_jmp_branch  => address_jmp_branch,
        address_out         => address_pc_progmem
    );


    Progmem_inst : Program_Memory
    port map(
        clk         => clk_state,
        rst         => rst_state,
        en_load     => en_load,
        load_data   => load_data,
        load_addr   => load_addr,
        address     => address_pc_progmem,
        instruction => instruction
    );
    
    
end architecture rtl;