library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- * Reminder 


entity Decoder is
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        instruction     : in std_logic_vector(31 downto 0);
        reg_address_0   : out std_logic_vector(4 downto 0);
        reg_address_1   : out std_logic_vector(4 downto 0);
        reg_address_dst : out std_logic_vector(4 downto 0);
        immediate       : out std_logic_vector(31 downto 0);
        alu_op          : out std_logic_vector(3 downto 0);
        mux_2_1_alu_sel : out std_logic;
        wr_back_en      : out std_logic;
        mux_2_1_wb_sel  : out std_logic;

        -- Jump branch unit output
        jump_branch_unit_op  : out std_logic_vector(3 downto 0);
        jump_branch_unit_en  : out std_logic
    );
end entity Decoder;

architecture rtl of Decoder is

    type opcodeMAP is (LOAD, STORE, MADD, BRANCH, LOAD_FP, STORE_FP, MSUB, JALR, custom_0, custom_1, NMSUB, reserved, MISC_MEM, AMO, NMADD, 
        JAL, OP_IMM, OP, OP_FP, SYSTEM, AUIPC, LUI, OP_V, OP_VE, OP_IMM_32, OP_32, custom_2, custom_3, INVALID);
    
    signal opMAP    : opcodeMAP := INVALID;

    type opcodeRV32I is (LUI, AUIPC, JAL, JALR, BEQ, BNE, BLT, BGE, BLTU, BGEU, LB, LH, LW, LBU, LHU, SB, SH, SW, ADDI, SLTI, SLTIU, 
        XORI, ORI, ANDI, SLLI, SRLI, SRAI, opcode_ADD, opcode_SUB, opcode_SLL, opcode_SLT, opcode_SLTU, opcode_XOR, opcode_SRL, opcode_SRA, opcode_OR, opcode_AND, INVALID);

    signal decode_op       : opcodeRV32I := INVALID;


begin
    

    decoding : process(clk, instruction)
    begin
        if rst =  '1' then
            opMAP <= INVALID;
            decode_op <= INVALID;
        elsif rising_edge(clk) then
            
            --OPCODE MAP [4:2]
            case (instruction(4 downto 2)) is
                
                when "000" => 

                    --OPCODE MAP [6:5]
                    case (instruction(6 downto 5)) is
                        when "00" => 
                            opMAP <= LOAD;
                            case (instruction (14 downto 12))  is
                                
                                when "000" =>
                                    decode_op <= LB;
                                
                                when "001" => 
                                    decode_op <= LH;
                                
                                when "010" => 
                                    decode_op <= LW;
                                
                                when "100" => 
                                    decode_op <= LBU;
                                
                                when "101" => 
                                    decode_op <= LHU;
                                                                
                                when others =>
                                    decode_op <= INVALID;

                            end case;


                        when "01" => 
                            opMAP <= STORE;
                            case (instruction (14 downto 12)) is
                                
                                when "000" =>
                                    decode_op <= SB;
                                    
                                when "001" => 
                                    decode_op <= SH;
                                
                                when "010" => 
                                    decode_op <= SW;
                            
                                when others =>
                                    decode_op <=  INVALID;
                            
                            end case;
                        when "11" => 
                            opMAP <= BRANCH;
                            case (instruction (14 downto 12)) is
                                when "000" =>
                                    decode_op <= BEQ;
                                
                                when "001" => 
                                    decode_op <= BNE;

                                when "100" => 
                                    decode_op <= BLT;

                                when "101" => 
                                    decode_op <=  BGE;

                                when "110" => 
                                    decode_op <= BLTU;

                                when "111" => 
                                    decode_op <= BGEU;
                                    
                                when others =>
                                    decode_op <= INVALID;
                            
                            end case;

                        when others => 
                            opMAP <= INVALID;

                        end case; --OPCODE MAP [6:5] END
                
                when "001" => 
                    --OPCODE MAP [6:5]
                    case (instruction(6 downto 5)) is
                        when "11" => 
                            opMAP <= JALR;
                            decode_op <= JALR;

                        when others =>
                            opMAP <= INVALID;
    
                        end case;--OPCODE MAP [6:5] END

                when "010" => 
                    --OPCODE MAP [6:5]
                    case (instruction (6 downto 5)) is
                        when others =>
                            opMAP <= INVALID;
                
                    end case;--OPCODE MAP [6:5] END
                
                
                when "011" => 
                    --OPCODE MAP [6:5]
                    case (instruction(6 downto 5)) is
                        when "11" =>
                            opMAP <= JAL;
                            decode_op <= JAL;
                    
                        when others =>
                            opMAP <= INVALID;
                    
                    end case;--OPCODE MAP [6:5] END

                when "100" => 
                    --OPCODE MAP [6:5]
                    case (instruction (6 downto 5)) is
                        when "00" =>
                            opMAP <= OP_IMM;
                            case (instruction (14 downto 12)) is
                                when "000" =>
                                    decode_op <= ADDI;
                                
                                when "010" => 
                                    decode_op <= SLTI;
                                
                                when "011" => 
                                    decode_op <= SLTIU;

                                when "100" => 
                                    decode_op <= XORI;

                                when "110" => 
                                    decode_op <= ORI;
                                    
                                when "111" => 
                                    decode_op <= ANDI;

                                when "001" => 
                                    decode_op <= SLLI;

                                when "101" => 
                                    case (instruction (31 downto 25)) is
                                        when "0000000" =>
                                            decode_op <= SRLI;

                                        when "0100000" => 
                                            decode_op <= SRAI;
                                    
                                        when others =>
                                            decode_op <= INVALID;        
                                    end case;
                                when others =>
                                    decode_op <= INVALID;
                            end case;
                        
                        when "01" => 
                            opMAP <= OP;
                            case (instruction (14 downto 12)) is
                                when "000" =>
                                    case (instruction (31 downto 25)) is
                                        when "0000000" =>
                                            decode_op <= opcode_ADD;

                                        when "0100000" => 
                                            decode_op <= opcode_SUB;
                                    
                                        when others =>
                                            decode_op <= INVALID;
                                    end case;
                                
                                when "001" => 
                                    decode_op <= opcode_SLL;
                                
                                when "010" => 
                                    decode_op <= opcode_SLT;

                                when "011" => 
                                    decode_op <= opcode_SLTU;

                                when "100" => 
                                    decode_op <= opcode_XOR;

                                when "101" => 
                                    case (instruction(31 downto 25)) is
                                        when "0000000" =>
                                            decode_op <= opcode_SRL;

                                        when "0100000" => 
                                            decode_op <= opcode_SRA;
                                                                         
                                        when others =>
                                            decode_op <= INVALID;                                   
                                    end case;
                                
                                when "110" => 
                                    decode_op <= opcode_OR;

                                when "111" => 
                                    decode_op <= opcode_AND;
                                
                                when others =>
                                    decode_op <= INVALID;
                            end case;
                    
                        when others =>
                            opMAP <= INVALID;
                    
                    end case;--OPCODE MAP [6:5] END

                when "101" => 
                    --OPCODE MAP [6:5]
                    case (instruction (6 downto 5)) is
                        when "00" =>
                            opMAP <= AUIPC;
                            decode_op <= AUIPC;
                            
                        when "01" => 
                            opMAP <= LUI;
                            decode_op <= LUI;
                            
                        when others =>
                            opMAP <= INVALID;
                    
                    end case;--OPCODE MAP [6:5] END
            
                when others =>
                    opMAP <= INVALID;
            
                end case; --OPCODE MAP [4:2] End

        end if;


        
    end process;

    decoding_out: process(clk, rst, opMAP)
    begin
        if rst = '1' then
            reg_address_0       <= (others => '0');
            reg_address_1       <= (others => '0');
            reg_address_dst     <= (others => '0');
            immediate           <= (others => '0');
            alu_op              <= (others => '1');
            mux_2_1_alu_sel     <= '0';
            jump_branch_unit_op <= (others => '0');
            jump_branch_unit_en <= '0';
            wr_back_en          <= '0';
            mux_2_1_wb_sel      <= '0';

        elsif rising_edge(clk) then
            case opMAP is
                when LOAD =>
                    mux_2_1_wb_sel      <= '1';
                    
                
                when STORE => 
                    mux_2_1_wb_sel      <= '0';

                when BRANCH => 
                    reg_address_0       <= instruction(19 downto 15); 
                    reg_address_1       <= instruction(24 downto 20);
                    reg_address_dst     <= (others => '0');
                    jump_branch_unit_op <= '0' & instruction(14 downto 12);
                    jump_branch_unit_en <= '1';
                    immediate           <= std_logic_vector(resize(signed(instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0'),32));
                    alu_op              <= (others => '1');
                    mux_2_1_alu_sel     <= '0';
                    wr_back_en          <= '0';
                    mux_2_1_wb_sel      <= '0';


                when JALR => 
                    reg_address_0       <= instruction(19 downto 15); 
                    reg_address_1       <= (others => '0');
                    reg_address_dst     <= instruction(11 downto 7);
                    jump_branch_unit_op <= "1001";
                    jump_branch_unit_en <= '1';
                    immediate           <=  std_logic_vector(resize(signed(instruction(31 downto 20)), 32));
                    alu_op              <= (others => '1');
                    mux_2_1_alu_sel     <= '1';
                    wr_back_en          <= '1';
                    mux_2_1_wb_sel      <= '0';

                when JAL => 
                    reg_address_0       <= (others => '0');
                    reg_address_1       <= (others => '0');
                    reg_address_dst     <= instruction(11 downto 7);
                    jump_branch_unit_op <= "1000";
                    jump_branch_unit_en <= '1';
                    immediate           <= std_logic_vector(resize(signed(instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0'),32));
                    alu_op              <= (others => '1');
                    mux_2_1_alu_sel     <= '1';
                    wr_back_en          <= '1';
                    mux_2_1_wb_sel      <= '0';

                when OP_IMM => 
                    reg_address_0       <= instruction(19 downto 15);
                    reg_address_dst     <= instruction(11 downto 7);
                    alu_op              <= '0' & instruction(14 downto 12);
                    mux_2_1_alu_sel     <= '1';
                    jump_branch_unit_op <= (others => '0');
                    jump_branch_unit_en <= '0';
                    wr_back_en          <= '1';
                    mux_2_1_wb_sel      <= '0';

                    case decode_op is
                        when ADDI | SLTI | SLTIU | XORI | ORI | ANDI=>
                            immediate   <=  std_logic_vector(resize(signed(instruction(31 downto 20)), 32));

                        -- when SLTIU => 
                        --     immediate <= "00000000000000000000" & instruction(31 downto 20);
                        
                        -- when SLTIU | XORI | ORI | ANDI => 
                        --     immediate <= "00000000000000000000" & instruction(31 downto 20);

                        
                        -- when SLLI => 
                            
                        when SLLI | SRLI | SRAI => 
                            immediate   <= "000000000000000000000000000" & instruction(24 downto 20);
                            
                        when others =>
                            immediate   <= (others => '0');
                    end case;

                when OP => 
                    reg_address_0       <= instruction(19 downto 15); 
                    reg_address_1       <= instruction(24 downto 20); 
                    reg_address_dst     <= instruction(11 downto 7);
                    alu_op              <= instruction(30) & instruction(14 downto 12);
                    mux_2_1_alu_sel     <= '0';
                    jump_branch_unit_op <= (others => '0');
                    jump_branch_unit_en <= '0';
                    wr_back_en          <= '1';
                    mux_2_1_wb_sel      <= '0';

                when AUIPC => 
                    -- reg_address_0   <= (others => '0');
                    -- reg_address_1   <= (others => '0');
                    -- reg_address_dst <= instruction(11 downto 7);
                    -- immediate <= instruction(31 downto 12) & "000000000000";
                    -- alu_op <= "0000";
                    -- mux_2_1_alu_sel <= '1';
                    -- jump_branch_unit_en <= '0';

                when LUI => 

                when INVALID => 
                    reg_address_0       <= (others => '0');
                    reg_address_1       <= (others => '0');
                    reg_address_dst     <= (others => '0');
                    immediate           <= (others => '0');
                    alu_op              <= (others => '1');
                    mux_2_1_alu_sel     <= '0';
                    jump_branch_unit_op <= (others => '0');
                    jump_branch_unit_en <= '0';
                    wr_back_en          <= '0';
                    mux_2_1_wb_sel      <= '0';

                when others =>
                    
            end case;
        end if;
    end process decoding_out;
    

    
    
    
end architecture rtl;