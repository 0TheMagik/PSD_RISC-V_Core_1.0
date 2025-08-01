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
        instruction         : out std_logic_vector(31 downto 0);
        instruction_addr    : out std_logic_vector(31 downto 0)
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
        data_mem_write_en   : out std_logic;
        data_mem_format     : out std_logic_vector(2 downto 0);
        jump_branch_unit_op : out std_logic_vector(3 downto 0);
        jump_branch_unit_en : out std_logic
    );
    end component;

    component State_Execute 
    port (
        clk_state               : in std_logic;
        rst_state               : in std_logic;
        en                      : in std_logic;
        reg_file_in_0           : in std_logic_vector(31 downto 0);
        reg_file_in_1           : in std_logic_vector(31 downto 0);
        reg_addr_dst_in         : in std_logic_vector(4 downto 0);
        immediate               : in std_logic_vector(31 downto 0);
        alu_op                  : in std_logic_vector(3 downto 0);
        mux_2_1_alu_sel         : in std_logic;
        wr_back_en_in           : in std_logic;
        mux_2_1_wb_sel_in       : in std_logic;
        data_mem_write_en_in    : in std_logic;
        data_mem_format_in      : in std_logic_vector(2 downto 0);
        pc_current              : in std_logic_vector(31 downto 0);
        jump_branch_unit_op     : in std_logic_vector(3 downto 0);
        jump_branch_unit_en     : in std_logic;
        alu_out                 : out std_logic_vector(31 downto 0);
        pc_next                 : out std_logic_vector(31 downto 0);
        jump_branch_flag        : out std_logic;
        reg_addr_dst_out        : out std_logic_vector(4 downto 0);
        wr_back_en_out          : out std_logic;
        mux_2_1_wb_sel_out      : out std_logic;
        data_mem_write_en_out   : out std_logic;
        data_mem_format_out     : out std_logic_vector(2 downto 0);
        data_mem_data_in        : out std_logic_vector(31 downto 0)
    );
    end component;

    component State_WB
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
    end component;


    type statetype is (IDLE, LOAD_PC, PIPELINE_RUN);
    signal current_state, next_state : statetype := IDLE;

    signal en_fetch     : std_logic;
    signal en_decode    : std_logic;
    signal en_execute   : std_logic;
    signal en_wb        : std_logic;
    signal rst_pc       : std_logic;

    -- Fetch to Decoder
    signal fetch_decoder_instruction            : std_logic_vector(31 downto 0);
    signal fetch_decoder_instruction_addr       : std_logic_vector(31 downto 0);            -- out-in
    -- Decode to Execute
    signal decode_execute_reg_file_0            : std_logic_vector(31 downto 0);            -- out-in
    signal decode_execute_reg_file_1            : std_logic_vector(31 downto 0);            -- out-in
    signal decode_execute_reg_addr_dst          : std_logic_vector(4 downto 0);             -- out-in
    signal decode_execute_immediate             : std_logic_vector(31 downto 0);            -- out-in
    signal decode_execute_alu_op                : std_logic_vector(3 downto 0);             -- out-in
    signal decode_execute_mux_2_1_alu_sel       : std_logic;                                -- out-in
    signal decode_execute_wrback_en             : std_logic;                                -- out-in
    signal decode_execute_mux_2_1_wb_sel        : std_logic;
    signal decode_execute_data_mem_write_en     : std_logic;
    signal decode_execute_data_mem_format       : std_logic_vector(2 downto 0);
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
    signal execute_wb_data_mem_write_en         : std_logic;                                -- out-in
    signal execute_wb_data_mem_format           : std_logic_vector(2 downto 0);             -- out-in
    signal execute_wb_data_mem_data             : std_logic_vector(31 downto 0);
    
    -- WR_BACK to Register
    signal wb_decode_data                       : std_logic_vector(31 downto 0);
    signal data_load_en                         : std_logic;
    signal wb_decode_load_state_en              : std_logic;                                -- out-in
    signal wb_decode_reg_addr_write_0           : std_logic_vector(4 downto 0);             -- out-in

    signal status_fetch                         : std_logic;
    signal status_decode                        : std_logic;
    signal status_execute                       : std_logic;
    signal status_wb                            : std_logic;




    -- signal for pipeline control
    signal stall                            : std_logic; 
    signal flush                            : std_logic; 

    -- Register for pipeline
    signal REG_FETCH_DECODE_INSTRUCTION             : std_logic_vector(31 downto 0);
    signal REG_FETCH_DECODE_INSTRUCTION_ADDR        : std_logic_vector(31 downto 0);
    signal REG_FETCH_DECODE_DONE                    : std_logic;

    signal REG_DECODE_EXECUTE_REG_FILE_0            : std_logic_vector(31 downto 0);
    signal REG_DECODE_EXECUTE_REG_FILE_1            : std_logic_vector(31 downto 0);
    signal REG_DECODE_EXECUTE_REG_ADDR_DST          : std_logic_vector(4 downto 0);
    signal REG_DECODE_EXECUTE_IMMEDIATE             : std_logic_vector(31 downto 0);
    signal REG_DECODE_EXECUTE_ALU_OP                : std_logic_vector(3 downto 0);
    signal REG_DECODE_EXECUTE_MUX_2_1_ALU_SEL       : std_logic;
    signal REG_DECODE_EXECUTE_WR_BACK_EN            : std_logic;
    signal REG_DECODE_EXECUTE_MUX_2_1_WB_SEL        : std_logic;
    signal REG_DECODE_EXECUTE_DATA_MEM_WRITE_EN     : std_logic;
    signal REG_DECODE_EXECUTE_DATA_MEM_FORMAT       : std_logic_vector(2 downto 0);
    signal REG_DECODE_EXECUTE_JUMP_BRANCH_UNIT_OP   : std_logic_vector(3 downto 0);
    signal REG_DECODE_EXECUTE_JUMP_BRANCH_UNIT_EN   : std_logic;
    signal REG_DECODE_EXECUTE_INSTRUCTION_ADDR      : std_logic_vector(31 downto 0);
    signal REG_DECODE_EXECUTE_DONE                  : std_logic;

    signal REG_EXECUTE_WB_ALU_OUT                   : std_logic_vector(31 downto 0);
    signal REG_EXECUTE_WB_REG_ADDR_DST              : std_logic_vector(4 downto 0);
    signal REG_EXECUTE_WB_WR_BACK_EN                : std_logic;
    signal REG_EXECUTE_WB_MUX_2_1_WB_SEL            : std_logic;
    signal REG_EXECUTE_WB_DATA_MEM_WRITE_EN         : std_logic;
    signal REG_EXECUTE_WB_DATA_MEM_FORMAT           : std_logic_vector(2 downto 0);
    signal REG_EXECUTE_WB_DATA_MEM_DATA             : std_logic_vector(31 downto 0);
    signal REG_EXECUTE_WB_INSTRUCTION_ADDR          : std_logic_vector(31 downto 0);
    signal REG_EXECUTE_WB_DONE                      : std_logic;

    signal REG_WB_DECODE_DATA                        : std_logic_vector(31 downto 0);
    signal REG_WB_DECODE_LOAD_STATE_EN               : std_logic;
    signal REG_WB_DECODE_REG_ADDR_WRITE_0           : std_logic_vector(4 downto 0);
begin

    FETCH_DECODE_pipeline_reg: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or flush = '1' then
                REG_FETCH_DECODE_INSTRUCTION <= (others => '0');
                REG_FETCH_DECODE_INSTRUCTION_ADDR <= (others => '0');
                REG_FETCH_DECODE_DONE <= '0';
                
            elsif en_fetch = '1' then
                REG_FETCH_DECODE_INSTRUCTION <= fetch_decoder_instruction;
                REG_FETCH_DECODE_INSTRUCTION_ADDR <= fetch_decoder_instruction_addr;
                REG_FETCH_DECODE_DONE <= '1';
            end if;
        end if;
    end process FETCH_DECODE_pipeline_reg;

    DECODE_EXECUTE_pipeline_reg: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or flush = '1' then
                REG_DECODE_EXECUTE_REG_FILE_0 <= (others => '0');
                REG_DECODE_EXECUTE_REG_FILE_1 <= (others => '0');
                REG_DECODE_EXECUTE_REG_ADDR_DST <= (others => '0');
                REG_DECODE_EXECUTE_IMMEDIATE <= (others => '0');
                REG_DECODE_EXECUTE_ALU_OP <= (others => '0');
                REG_DECODE_EXECUTE_MUX_2_1_ALU_SEL <= '0';
                REG_DECODE_EXECUTE_WR_BACK_EN <= '0';
                REG_DECODE_EXECUTE_MUX_2_1_WB_SEL <= '0';
                REG_DECODE_EXECUTE_DATA_MEM_WRITE_EN <= '0';
                REG_DECODE_EXECUTE_DATA_MEM_FORMAT <= (others => '0');
                REG_DECODE_EXECUTE_JUMP_BRANCH_UNIT_OP <= (others => '0');
                REG_DECODE_EXECUTE_JUMP_BRANCH_UNIT_EN <= '0';
                REG_DECODE_EXECUTE_INSTRUCTION_ADDR <= (others => '0');
                REG_DECODE_EXECUTE_DONE <= '0';

            elsif en_decode = '1' then
                REG_DECODE_EXECUTE_REG_FILE_0 <= decode_execute_reg_file_0;
                REG_DECODE_EXECUTE_REG_FILE_1 <= decode_execute_reg_file_1;
                REG_DECODE_EXECUTE_REG_ADDR_DST <= decode_execute_reg_addr_dst;
                REG_DECODE_EXECUTE_IMMEDIATE <= decode_execute_immediate;
                REG_DECODE_EXECUTE_ALU_OP <= decode_execute_alu_op;
                REG_DECODE_EXECUTE_MUX_2_1_ALU_SEL <= decode_execute_mux_2_1_alu_sel;
                REG_DECODE_EXECUTE_WR_BACK_EN <= decode_execute_wrback_en;
                REG_DECODE_EXECUTE_MUX_2_1_WB_SEL <= decode_execute_mux_2_1_wb_sel;
                REG_DECODE_EXECUTE_DATA_MEM_WRITE_EN <= decode_execute_data_mem_write_en;
                REG_DECODE_EXECUTE_DATA_MEM_FORMAT <= decode_execute_data_mem_format;
                REG_DECODE_EXECUTE_JUMP_BRANCH_UNIT_OP <= decode_execute_jump_branch_unit_op;
                REG_DECODE_EXECUTE_JUMP_BRANCH_UNIT_EN <= decode_execute_jump_branch_unit_en;        
                REG_DECODE_EXECUTE_INSTRUCTION_ADDR <= REG_FETCH_DECODE_INSTRUCTION_ADDR;
                REG_DECODE_EXECUTE_DONE <= '1';
            end if;
        end if;
    end process DECODE_EXECUTE_pipeline_reg;

    EXECUTE_WB_pipeline_reg: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or flush = '1' then
                REG_EXECUTE_WB_ALU_OUT <= (others => '0');
                REG_EXECUTE_WB_REG_ADDR_DST <= (others => '0');
                REG_EXECUTE_WB_WR_BACK_EN <= '0';
                REG_EXECUTE_WB_MUX_2_1_WB_SEL <= '0';
                REG_EXECUTE_WB_DATA_MEM_WRITE_EN <= '0';
                REG_EXECUTE_WB_DATA_MEM_FORMAT <= (others => '0');
                REG_EXECUTE_WB_DATA_MEM_DATA <= (others => '0');
                REG_EXECUTE_WB_INSTRUCTION_ADDR <= (others => '0');
                REG_EXECUTE_WB_DONE <= '0';
            elsif en_execute = '1' then
                REG_EXECUTE_WB_ALU_OUT <= execute_wb_alu_out;
                REG_EXECUTE_WB_REG_ADDR_DST <= execute_wb_reg_addr_dst;
                REG_EXECUTE_WB_WR_BACK_EN <= execute_wb_wr_back_en;
                REG_EXECUTE_WB_MUX_2_1_WB_SEL <= execute_wb_mux_2_1_wb_sel;
                REG_EXECUTE_WB_DATA_MEM_WRITE_EN <= execute_wb_data_mem_write_en;
                REG_EXECUTE_WB_DATA_MEM_FORMAT <= execute_wb_data_mem_format;
                REG_EXECUTE_WB_DATA_MEM_DATA <= execute_wb_data_mem_data;
                REG_EXECUTE_WB_INSTRUCTION_ADDR <= REG_DECODE_EXECUTE_INSTRUCTION_ADDR;
                REG_EXECUTE_WB_DONE <= '1';
            end if;
        end if;
    end process EXECUTE_WB_pipeline_reg;

    WB_DECODE_pipeline_reg: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1'or flush = '1' then
                REG_WB_DECODE_DATA <= (others => '0');
                REG_WB_DECODE_LOAD_STATE_EN <= '0';
                REG_WB_DECODE_REG_ADDR_WRITE_0 <= (others => '0');
            elsif en_wb = '1' then
                REG_WB_DECODE_DATA <= wb_decode_data;
                REG_WB_DECODE_LOAD_STATE_EN <= wb_decode_load_state_en;
                REG_WB_DECODE_REG_ADDR_WRITE_0 <= wb_decode_reg_addr_write_0;
            end if;
        end if;
    end process WB_DECODE_pipeline_reg;



    Fetch_inst : State_Fetch
    port map(
        clk_state           => clk,
        rst_state           => rst,
        en_state            => en_fetch,
        rst_pc              => rst_pc,
        jmp_branch_flag     => execute_fetch_jump_branch_flag,        -- in
        address_jmp_branch  => execute_fetch_pc_next,        -- in
        en_load             => en_load,                             -- in
        load_data           => load_data,                           -- in
        load_addr           => load_addr,                           -- in
        instruction         => fetch_decoder_instruction,           -- out
        instruction_addr    => fetch_decoder_instruction_addr       -- out
    );

    -- Reg dst still wired direcly in Decode 
    Decode_inst : State_Decode
    port map(
        clk_state           => clk,
        rst_state           => rst,
        en                  => en_decode,
        load_state          => REG_WB_DECODE_LOAD_STATE_EN,             -- in
        reg_data_write_0    => REG_WB_DECODE_DATA,                      -- in this is not final
        reg_addr_write_0    => REG_WB_DECODE_REG_ADDR_WRITE_0,          -- in
        instruction         => REG_FETCH_DECODE_INSTRUCTION,        -- in
        reg_file_out_0      => decode_execute_reg_file_0,           -- out
        reg_file_out_1      => decode_execute_reg_file_1,           -- out
        reg_addr_dst        => decode_execute_reg_addr_dst,         -- out
        immediate           => decode_execute_immediate,            -- out
        alu_op              => decode_execute_alu_op,               -- out
        mux_2_1_alu_sel     => decode_execute_mux_2_1_alu_sel,      -- out
        wr_back_en          => decode_execute_wrback_en,            -- out
        mux_2_1_wb_sel      => decode_execute_mux_2_1_wb_sel,       -- out
        data_mem_write_en   => decode_execute_data_mem_write_en,    -- out
        data_mem_format     => decode_execute_data_mem_format,      -- out
        jump_branch_unit_op => decode_execute_jump_branch_unit_op,  -- out
        jump_branch_unit_en => decode_execute_jump_branch_unit_en   -- out
    );

    Execute_inst : State_Execute 
    port map(
        clk_state               => clk,
        rst_state               => rst,
        en                      => en_execute,
        reg_file_in_0           => REG_DECODE_EXECUTE_REG_FILE_0,           -- in
        reg_file_in_1           => REG_DECODE_EXECUTE_REG_FILE_1,           -- in
        reg_addr_dst_in         => REG_DECODE_EXECUTE_REG_ADDR_DST,         -- in
        immediate               => REG_DECODE_EXECUTE_IMMEDIATE,            -- in
        alu_op                  => REG_DECODE_EXECUTE_ALU_OP,               -- in
        mux_2_1_alu_sel         => REG_DECODE_EXECUTE_MUX_2_1_ALU_SEL,      -- in
        wr_back_en_in           => REG_DECODE_EXECUTE_WR_BACK_EN,           -- in
        mux_2_1_wb_sel_in       => REG_DECODE_EXECUTE_MUX_2_1_WB_SEL,       -- in
        data_mem_write_en_in    => REG_DECODE_EXECUTE_DATA_MEM_WRITE_EN,    -- in
        data_mem_format_in      => REG_DECODE_EXECUTE_DATA_MEM_FORMAT,      -- in
        pc_current              => REG_DECODE_EXECUTE_INSTRUCTION_ADDR,     -- in
        jump_branch_unit_op     => REG_DECODE_EXECUTE_JUMP_BRANCH_UNIT_OP,  -- in
        jump_branch_unit_en     => REG_DECODE_EXECUTE_JUMP_BRANCH_UNIT_EN,  -- in
        alu_out                 => execute_wb_alu_out,                  -- out
        pc_next                 => execute_fetch_pc_next,               -- out
        jump_branch_flag        => execute_fetch_jump_branch_flag,      -- out
        reg_addr_dst_out        => execute_wb_reg_addr_dst,             -- out
        wr_back_en_out          => execute_wb_wr_back_en,               -- out
        mux_2_1_wb_sel_out      => execute_wb_mux_2_1_wb_sel,           -- out
        data_mem_write_en_out   => execute_wb_data_mem_write_en,        -- out 
        data_mem_format_out     => execute_wb_data_mem_format,          -- out
        data_mem_data_in        => execute_wb_data_mem_data             -- out
    );

    WB_inst : State_WB
    port map(
        clk_state           => clk,                                 -- in
        rst_state           => rst,                                 -- in
        en_state            => en_wb,                               -- in
        data_mem_write_en   => REG_EXECUTE_WB_DATA_MEM_WRITE_EN,    -- in 
        data_mem_format     => REG_EXECUTE_WB_DATA_MEM_FORMAT,      -- in 
        data_mem_data_in    => REG_EXECUTE_WB_DATA_MEM_DATA,        -- in 
        data_mem_address    => REG_EXECUTE_WB_ALU_OUT,              -- in 
        alu_reslt_in        => REG_EXECUTE_WB_ALU_OUT,              -- in
        reg_addr_dst_in     => REG_EXECUTE_WB_REG_ADDR_DST,         -- in
        wr_back_en_in       => REG_EXECUTE_WB_WR_BACK_EN,           -- in
        mux_2_1_wb_sel      => REG_EXECUTE_WB_MUX_2_1_WB_SEL,       -- in
        data_out            => wb_decode_data,                      -- out 
        reg_addr_dst_out    => wb_decode_reg_addr_write_0,          -- out
        wr_back_en_out      => wb_decode_load_state_en              -- out
    );
    
    pipeline_control: process(CURRENT_STATE, en_load, en)
    begin
        en_fetch <= '0';
        en_decode <= '0';
        en_execute <= '0';
        en_wb <= '0';
        rst_pc <= '0';
        flush <= '0';
        next_state <= current_state;
        case current_state is
            when IDLE =>
                en_fetch <= '1';
                en_decode <= '1';
                en_execute <= '1';
                en_wb <= '1';
                if en_load = '1' then
                    rst_pc <= '1';
                    flush <= '1';
                    next_state <= LOAD_PC;
                elsif en = '1' then
                    en_fetch <= '1';
                    en_decode <= '1';
                    en_execute <= '1';
                    en_wb <= '1';
                    next_state <= PIPELINE_RUN;
                end if;

            when PIPELINE_RUN => 
                en_fetch <= '1';
                en_decode <= '1';
                en_execute <= '1';
                en_wb <= '1';
                if en_load = '1' then
                    flush <= '1';
                    next_state <= LOAD_PC;
                end if;

            when LOAD_PC =>
                flush <= '0';
                rst_pc <= '1';
                en_wb <= '0';
                if en_load = '0' then
                    rst_pc <= '1';
                    next_state <= IDLE;
                end if;
                        
            when others =>
                flush <= '1';
                next_state <= IDLE;
        end case;    
    end process pipeline_control;

    state_control: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= IDLE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process state_control;
    


end architecture rtl;