library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Core is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        en          : in std_logic;
        
        -- load pc
        en_load     : in std_logic;
        load_data   : in std_logic_vector(31 downto 0);
        load_addr   : in std_logic_vector(31 downto 0)

    );
end entity Core;


architecture rtl of Core is

    component State_Fetch is
    port (
        clk_state           : in std_logic;
        rst_state           : in std_logic;
        en_state            : in std_logic;

        -- input to reset pc
        rst_pc              : in std_logic;

        -- input from another state
        jmp_branch_flag     : in std_logic;
        address_jmp_branch  : in std_logic_vector(31 downto 0);
        
        -- input data into progmem
        en_load             : in std_logic;
        load_data           : in std_logic_vector(31 downto 0);
        load_addr           : in std_logic_vector(31 downto 0);

        -- address out
        instruction         : out std_logic_vector(31 downto 0)
    );
    end component;


    component State_Decode
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
        jump_branch_unit_op : out std_logic_vector(3 downto 0);
        jump_branch_unit_en : out std_logic
    );
    end component;

    component State_Execute 
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
    end component;

    component State_WB
    port (
        clk_state           : in std_logic;
        rst_state           : in std_logic;
        en_state            : in std_logic;
        data_mem_load_en    : in std_logic;
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
    end component;


    type statetype is (IDLE, LOAD_PC, FETCH, DECODE, EXECUTE, WR_BACK);
    signal current_state, next_state : statetype := IDLE;

    signal en_fetch     : std_logic;
    signal en_decode    : std_logic;
    signal en_execute   : std_logic;
    signal en_wb        : std_logic;
    signal rst_pc       : std_logic;

    -- Fetch to Decoder
    signal fetch_decoder_instruction            : std_logic_vector(31 downto 0);

    -- Decode to Execute
    signal decode_execute_reg_file_0            : std_logic_vector(31 downto 0);            -- out-in
    signal decode_execute_reg_file_1            : std_logic_vector(31 downto 0);            -- out-in
    signal decode_execute_reg_addr_dst          : std_logic_vector(4 downto 0);             -- out-in
    signal decode_execute_immediate             : std_logic_vector(31 downto 0);            -- out-in
    signal decode_execute_alu_op                : std_logic_vector(3 downto 0);             -- out-in
    signal decode_execute_mux_2_1_alu_sel       : std_logic;                                -- out-in
    signal decode_execute_wrback_en             : std_logic;                                -- out-in
    signal decode_execute_mux_2_1_wb_sel        : std_logic;

    signal decode_execute_jump_branch_unit_op   : std_logic_vector(3 downto 0);             -- out-in
    signal decode_execute_jump_branch_unit_en   : std_logic;                                -- out-in

    signal decode_execute_pc_current            : std_logic_vector(31 downto 0);

    -- Execute to Fetch
    signal execute_fetch_pc_next                : std_logic_vector(31 downto 0);
    signal execute_fetch_jump_branch_flag       : std_logic;

    -- Execute to WR_Back
    signal execute_wb_alu_out                   : std_logic_vector(31 downto 0);
    signal execute_wb_reg_addr_dst              : std_logic_vector(4 downto 0);
    signal execute_wb_wr_back_en                : std_logic;                                -- out-in
    signal execute_wb_mux_2_1_wb_sel            : std_logic;                                -- out-in
    
    -- WR_BACK to Register
    signal wb_decode_data                       : std_logic_vector(31 downto 0);
    signal data_load_en                         : std_logic;
    signal wb_decode_load_state_en              : std_logic;                                -- out-in
    signal wb_decode_reg_addr_write_0           : std_logic_vector(4 downto 0);             -- out-in
begin

    Fetch_inst : State_Fetch
    port map(
        clk_state           => clk,
        rst_state           => rst,
        en_state            => en_fetch,
        rst_pc              => rst_pc,
        jmp_branch_flag     => execute_fetch_jump_branch_flag,      -- in
        address_jmp_branch  => execute_fetch_pc_next,               -- in
        en_load             => en_load,                             -- in
        load_data           => load_data,                           -- in
        load_addr           => load_addr,                           -- in
        instruction         => fetch_decoder_instruction            -- out
    );

    -- Reg dst still wired direcly in Decode 
    Decode_inst : State_Decode
    port map(
        clk_state           => clk,
        rst_state           => rst,
        en                  => en_decode,
        load_state          => wb_decode_load_state_en,             -- in
        reg_data_write_0    => wb_decode_data,                      -- in this is not final
        reg_addr_write_0    => wb_decode_reg_addr_write_0,          -- in
        instruction         => fetch_decoder_instruction,           -- in
        reg_file_out_0      => decode_execute_reg_file_0,           -- out
        reg_file_out_1      => decode_execute_reg_file_1,           -- out
        reg_addr_dst        => decode_execute_reg_addr_dst,         -- out
        immediate           => decode_execute_immediate,            -- out
        alu_op              => decode_execute_alu_op,               -- out
        mux_2_1_alu_sel     => decode_execute_mux_2_1_alu_sel,      -- out
        wr_back_en          => decode_execute_wrback_en,            -- out
        mux_2_1_wb_sel      => decode_execute_mux_2_1_wb_sel,       -- out
        jump_branch_unit_op => decode_execute_jump_branch_unit_op,  -- out
        jump_branch_unit_en => decode_execute_jump_branch_unit_en   -- out
    );

    Execute_inst : State_Execute 
    port map(
        clk_state           => clk,
        rst_state           => rst,
        en                  => en_execute,
        reg_file_in_0       => decode_execute_reg_file_0,           -- in
        reg_file_in_1       => decode_execute_reg_file_1,           -- in
        reg_addr_dst_in     => decode_execute_reg_addr_dst,         -- in
        immediate           => decode_execute_immediate,            -- in
        alu_op              => decode_execute_alu_op,               -- in
        mux_2_1_alu_sel     => decode_execute_mux_2_1_alu_sel,      -- in
        wr_back_en_in       => decode_execute_wrback_en,            -- in
        mux_2_1_wb_sel_in   => decode_execute_mux_2_1_wb_sel,       -- in
        pc_current          => decode_execute_pc_current,           -- in
        jump_branch_unit_op => decode_execute_jump_branch_unit_op,  -- in
        jump_branch_unit_en => decode_execute_jump_branch_unit_en,  -- in
        alu_out             => execute_wb_alu_out,                  -- out
        pc_next             => execute_fetch_pc_next,               -- out
        jump_branch_flag    => execute_fetch_jump_branch_flag,      -- out
        reg_addr_dst_out    => execute_wb_reg_addr_dst,             -- out
        wr_back_en_out      => execute_wb_wr_back_en,               -- out
        mux_2_1_wb_sel_out  => execute_wb_mux_2_1_wb_sel            -- out
    );

    WB_inst : State_WB
    port map(
        clk_state           => clk,                                 -- in
        rst_state           => rst,                                 -- in
        en_state            => en_wb,                               -- in
        data_mem_load_en    => '0',                                 -- in this is not final
        data_mem_format     => "000",                               -- in this is not final
        data_mem_data_in    => x"00000000",                         -- in this is not final
        data_mem_address    => x"00000000",                         -- in this is not final
        alu_reslt_in        => execute_wb_alu_out,                  -- in
        reg_addr_dst_in     => execute_wb_reg_addr_dst,             -- in
        wr_back_en_in       => execute_wb_wr_back_en,               -- in
        mux_2_1_wb_sel      => execute_wb_mux_2_1_wb_sel,           -- in
        data_out            => wb_decode_data,                      -- out this is not final
        reg_addr_dst_out    => wb_decode_reg_addr_write_0,          -- out
        wr_back_en_out      => wb_decode_load_state_en              -- out
    );
    
    state : process(current_state, en_load, en)
    begin
        en_fetch <= '0';
        en_decode <= '0';
        en_execute <= '0';
        en_wb <= '0';
        rst_pc <= '0';
        
        case current_state is
            when LOAD_PC => 
                en_fetch <= '0';
                if en_load = '0' then
                    rst_pc <= '1';
                    next_state <= IDLE;
                else
                    next_state <= LOAD_PC;
                end if;


            when IDLE =>
                if en_load = '1' then
                    next_state <= LOAD_PC;
                else
                    rst_pc <= '0';
                    next_state <= FETCH;                
                end if;

            when FETCH =>
                -- rst_pc <= '0';
                en_fetch <= '1';
                if en_load = '1' then
                    next_state <= LOAD_PC;
                else
                    next_state <= DECODE;
                end if;

            when DECODE => 
                en_decode <= '1';
                if en_load = '1' then
                    next_state <= LOAD_PC;
                else
                    next_state <= EXECUTE;                
                end if;

            when EXECUTE => 
                en_execute <= '1';
                if en_load = '1' then
                    next_state <= LOAD_PC;
                else
                    next_state <= WR_BACK;
                end if;

            when WR_BACK => 
                en_wb <= '1';
                if en_load = '1' then
                    next_state <= LOAD_PC;
                else
                    next_state <= FETCH;                
                end if;
            when others =>
                next_state <= IDLE;
        
        end case;
    end process state;


    FSM: process(clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) and en = '1' then
            current_state <= next_state;
        end if;
    end process FSM;
    


end architecture rtl;