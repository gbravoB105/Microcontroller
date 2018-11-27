----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.10.2018 18:21:33
-- Design Name: 
-- Module Name: MAIN_CONTROL - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

USE work.PIC_pkg.all;

entity MAIN_CONTROL is
    Port ( Reset     : in STD_LOGIC;
           Clk       : in STD_LOGIC;
           ROM_Data  : in STD_LOGIC_VECTOR (11 downto 0);
           ROM_Addr  : out STD_LOGIC_VECTOR (11 downto 0);
           RAM_Addr  : out STD_LOGIC_VECTOR (7 downto 0);
           RAM_CS    : out STD_LOGIC;
           RAM_Write : out STD_LOGIC;
           RAM_OE    : out STD_LOGIC;
           Databus   : inout STD_LOGIC_VECTOR (7 downto 0);
           DMA_RQ    : in STD_LOGIC;
           DMA_ACK   : out STD_LOGIC;
           SEND_comm : out STD_LOGIC;
           DMA_READY : in STD_LOGIC;
           ALU_op    : out alu_op;
           Index_Reg : in STD_LOGIC_VECTOR (7 downto 0);
           FlagZ     : in STD_LOGIC;
           FlagC     : in STD_LOGIC;
           FlagN     : in STD_LOGIC;
           FlagE     : in STD_LOGIC);
end MAIN_CONTROL;

architecture Behavioral of MAIN_CONTROL is


    type State is (Idle, Dar_Buses, Fetch1, Fetch2, Decode, Execute1, Execute2, LecturaSalto, 
        DecisionSalto, Execute3, LecturaSegundaPalabra, EscribirEnRam, Execute4, Stall);
    
    signal CurrentState, NextState       : State;
    signal type_instruccion              : std_logic_vector (1 downto 0);
    signal flag_mov_registros            : std_logic;
    signal flag_salto                    : std_logic;
    signal Cuenta_Instruccion            : unsigned(11 downto 0);
    signal instruccion                   : std_logic_vector(5 downto 0);
    signal registro_segunda              : std_logic_vector(11 downto 0);
    
begin

Next_process: process (clk,currentstate) 
    begin
        case CurrentState is
            when Idle =>
                if(dma_rq = '1') then
                    NextState <= dar_buses;
                elsif(dma_rq='0') then
                    NextState <= fetch1;
                else
                    NextState <= Idle;
                end if;
            when dar_buses =>
                if(dma_rq = '0') then
                    NextState <= idle;
                else
                    NextState <= dar_buses;
                end if;
            when fetch1 =>
                NextState <= fetch2;
            when fetch2 =>
                NextState <= decode;
            when decode =>
                case type_instruccion is
                    when TYPE_1 =>
                        NextState <= Execute1;
                    when TYPE_2 =>            
                        NextState <= Execute2;
                    when TYPE_3 =>            
                        NextState <= Execute3;
                    when TYPE_4 =>            
                        NextState <= Execute4;
                    when others =>
                        NextState <= decode;
                end case;
                
            when Execute1 =>
                NextState <= Idle;
                
            when Execute2 =>
                NextState <= LecturaSalto;
            when LecturaSalto =>
                NextState <= DecisionSalto;
            when DecisionSalto =>
                NextState <= Idle;
                
            when Execute3 =>
                if(flag_mov_registros = '1') then
                    NextState <= Idle;
                else
                    NextState <= LecturaSegundaPalabra;
                end if;
            when LecturaSegundaPalabra =>
                if instruccion(5) = '0' then
                    NextState <= Idle;
                else
                    NextState <= EscribirEnRam;
                end if;
            when EscribirEnRam =>
                NextState <= Idle;
            
            when Execute4 =>
                NextState <= Stall;
            when Stall =>
                if (DMA_Ready = '1') then
                    NextState <= Idle;
                else
                    NextState <= Stall;
                end if;
        end case;
    end process;


FFs: process (Reset, Clk, NextState, CurrentState) 
    begin
        if Reset = '0' then
            CurrentState <= Idle;
        elsif Clk'event and Clk = '1' then
            CurrentState <= NextState;
        end if;
    end process;

Outputs: process (Clk) 
    begin
        case CurrentState is
            when Idle =>
                registro_segunda <= (others => '0');
                
                Databus <= (others => 'Z');
                --Rom_Addr <= 
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
                
            when dar_buses =>
                Databus <= (others => 'Z');
                --Rom_Addr <= 
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '1';
                Send_Comm <= '0';
                ALU_OP <= nop;
                
            when fetch1 =>
                Databus <= (others => 'Z');
                Rom_Addr <= std_logic_vector(Cuenta_Instruccion);
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
                
            when fetch2 =>
                Databus <= (others => 'Z');
                --Rom_Addr ;
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
                
                Type_Instruccion <= rom_data(7 downto 6);
                Instruccion <= rom_data(5 downto 0);
                
                if (rom_data(7 downto 6) = type_3) then
                    case rom_data(4 downto 0) is
                        when SRC_ACC & DST_A =>
                            flag_mov_registros <= '1';
                        when src_acc & DST_B =>
                            flag_mov_registros <= '1';
                        when src_ACC & DST_INDX =>
                            flag_mov_registros <= '1';
                        when others =>
                            flag_mov_registros <= '0';
                    end case;
                end if;
                
            when decode =>
                Databus <= (others => 'Z');
                --Rom_Addr <= 
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
                
                flag_salto <= '0'; -- We need to reset it, we previously reseted it just in case there was a jumping instruction, what if there isn't.
                
            when execute1 =>
                Databus <= (others => 'Z');
                --Rom_Addr <= 
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
            
                case Instruccion is
                    when ALU_ADD =>
                        alu_op <= op_add;
                    when ALU_SUB =>  
                        alu_op <= op_sub;   
                    when ALU_SHIFTL => 
                        alu_op <= op_shiftl; 
                    when ALU_SHIFTR =>  
                        alu_op <= op_shiftr;
                    when ALU_AND =>      
                        alu_op <= op_and;
                    when ALU_OR =>
                        alu_op <= op_or;      
                    when ALU_XOR =>
                        alu_op <= op_xor;     
                    when ALU_CMPE =>
                        alu_op <= op_cmpe;    
                    when ALU_CMPG =>
                        alu_op <= op_cmpg;   
                    when ALU_CMPL =>
                        alu_op <= op_cmpl;    
                    when ALU_ASCII2BIN =>
                        alu_op <= op_ascii2bin;
                    when ALU_BIN2ASCII =>
                        alu_op <= op_bin2ascii;
                    when others =>
                        alu_op <= nop;
                end case;
                
            when execute2 =>
                Rom_Addr <= std_logic_vector(Cuenta_Instruccion);
                
                Databus <= (others => 'Z');
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
                
            when LecturaSalto =>
                registro_segunda <= rom_Data;
                
                Databus <= (others => 'Z');
                --Rom_Addr <= 
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
                            
            when DecisionSalto =>
                if (instruccion = JMP_UNCOND) then
                    flag_salto <= '1';
                else
                    if (flagZ = '1') then
                        flag_Salto <= '1';
                    else
                        flag_salto <= '0';
                    end if;
                end if;
            when Execute3 =>
                if(flag_mov_registros = '1') then
                    case instruccion(2 downto 0) is
                        when DST_A => 
                            ALU_op <= op_mvacc2a;
                        when DST_B =>
                            ALU_op <= op_mvacc2b;
                        when DST_INDX =>
                            ALU_op <= op_mvacc2id;
                        when others => 
                            alu_op <= nop;
                    end case;
                else 
                    ROM_Addr <= std_logic_vector(Cuenta_instruccion);
                end if;
                            
            when LecturaSegundaPalabra =>
                case instruccion(5) is
                    when '0' =>
                        case instruccion(4 downto 3) is
                            when SRC_constant =>
                                databus <= rom_data(7 downto 0);
                                case instruccion(2 downto 0) is
                                    when DST_ACC =>
                                        alu_op <= op_ldacc;      
                                    when DST_A =>
                                        alu_op <= op_lda;
                                    when DST_B =>
                                        alu_op <= op_ldb;        
                                    when DST_INDX =>
                                        alu_op <= op_ldid;
                                    when others => 
                                        alu_op <= nop;
                                end case;
                            when SRC_MEM =>
                                ram_addr <= rom_data(7 downto 0);
                                ram_oe <= '0';
                                case instruccion(2 downto 0) is
                                    when DST_ACC =>
                                        alu_op <= op_ldacc;      
                                    when DST_A =>
                                        alu_op <= op_lda;
                                    when DST_B =>
                                        alu_op <= op_ldb;        
                                    when DST_INDX =>
                                        alu_op <= op_ldid;
                                    when others => 
                                        alu_op <= nop;
                                end case;
                            when SRC_INDXD_MEM =>
                                ram_addr <= std_logic_vector(unsigned(rom_data(7 downto 0)) + unsigned(index_reg(7 downto 0)));
                                ram_oe <= '0';
                                case instruccion(2 downto 0) is
                                    when DST_ACC =>
                                        alu_op <= op_ldacc;      
                                    when DST_A =>
                                        alu_op <= op_lda;
                                    when DST_B =>
                                        alu_op <= op_ldb;        
                                    when DST_INDX =>
                                        alu_op <= op_ldid;
                                    when others => 
                                        alu_op <= nop;
                                end case;
                            when others =>
                                Ram_Addr <= (others => 'Z');
                                Ram_OE <= 'Z';
                                alu_op <= nop;
                        end case;
                    when '1' =>
                        alu_op <= op_oeacc;
                    when others =>
                        alu_op <= nop;
                end case;
                
            when EscribirEnRam =>
                case instruccion(2 downto 0) is
                    when DST_MEM =>
                        ram_addr <= rom_data(7 downto 0);
                        ram_write <= '1';      
                    when DST_INDXD_MEM =>
                        ram_addr <= std_logic_vector(unsigned(rom_data(7 downto 0)) + unsigned(index_reg(7 downto 0)));
                        ram_write <= '1';
                    when others =>
                        Ram_Addr <= (others => 'Z');
                        Ram_Write <= 'Z';
                end case;
                
            when Execute4 =>
                Databus <= (others => 'Z');
                --Rom_Addr <= 
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '1';
                ALU_OP <= nop;
                
            when Stall =>
                Databus <= (others => 'Z');
                --Rom_Addr <= 
                Ram_Addr <= (others => 'Z');
                Ram_Write <= 'Z';
                Ram_OE <= 'Z';
                DMA_ACK <= '0';
                Send_Comm <= '0';
                ALU_OP <= nop;
                            
        end case;
    end process;
    
CounterInstrucciones : process(Reset, CurrentState) 
    begin
        if (Reset = '0') then
            Cuenta_Instruccion <= (others => '1');
        elsif (Currentstate = idle and dma_rq = '0') then
            if(flag_salto = '1') then
                Cuenta_Instruccion <= unsigned(registro_segunda);
            else
                Cuenta_Instruccion <= Cuenta_Instruccion + to_unsigned(1,12);
            end if;
        elsif (Currentstate = Decode and type_instruccion = type_2) then
            Cuenta_Instruccion <= Cuenta_Instruccion + to_unsigned(1,12);
        elsif (Currentstate = Decode and flag_mov_registros = '0' and type_instruccion = type_3) then
            Cuenta_Instruccion <= Cuenta_Instruccion + to_unsigned(1,12);
        end if;    
    end process;

end Behavioral;
