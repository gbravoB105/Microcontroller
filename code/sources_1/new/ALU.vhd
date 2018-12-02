----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.10.2018 17:28:17
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    port ( Reset       : in std_logic; -- asynnchronous, active low
           Clk         : in std_logic; -- Sys clock, 20MHz, rising_edge
           Command_alu : in alu_op; -- command instruction from CPU
           FlagZ       : out std_logic; -- Zero flag
           FlagC       : out std_logic; -- Carry flag
           FlagN       : out std_logic; -- Nibble carry bit
           FlagE       : out std_logic; -- Error flag
           Index_Reg   : out std_logic_vector(7 downto 0);   -- Index register
           A_sal       : out std_logic_vector(7 downto 0);
           B_sal       : out std_logic_vector(7 downto 0);
           ACC_sal         : out std_logic_vector(7 downto 0);
           Databus     : inout std_logic_vector(7 downto 0)); -- System Data bus
end ALU;

architecture Behavioral of ALU is
    
    signal A, B, ACC, Index : unsigned(7 downto 0);  
      
begin

A_sal <= std_logic_vector(A);
B_sal <= std_logic_vector(B);
ACC_sal <= std_logic_vector(ACC);


Index_reg <= std_logic_vector(Index);

ALU_Process: process(clk, reset) 
    variable ACC_internal : unsigned (8 downto 0);
    
    begin
        if(reset = '0') then
            FlagZ <= '0';
            FlagC <= '0';
            FlagN <= '0';
            FlagE <= '0';
            Databus <= (others => 'Z');
            A <= (others => '0');
            B <= (others => '0');
            ACC <= (others => '0');
            Index <= (others => '0');
            
        elsif (clk'event and clk = '1') then
            case (Command_alu) is
                when nop =>      
                    FlagZ <= '0'; -- If not it was not resetting.
                    FlagC <= '0';
                    FlagN <= '0';
                    FlagE <= '0';
                    Databus <= (others => 'Z');
                when op_lda =>   
                    A <= unsigned(Databus);
                when op_ldb =>   
                    B <= unsigned(Databus);    
                when op_ldacc => 
                    ACC <= unsigned(Databus);
                when op_ldid =>  
                    Index <= unsigned(Databus);
                when op_mvacc2id =>
                    Index <= ACC;
                    Databus <= (others => 'Z');
                when op_mvacc2a =>
                    A <= ACC;
                    Databus <= (others => 'Z');
                when op_mvacc2b =>
                    B <= ACC;
                    Databus <= (others => 'Z');
                when op_add =>
                    ACC_internal := ('0' & A) + ('0' & B);
                    ACC <= ACC_internal(7 downto 0);
                    
                    if (ACC_internal = "000000000") then
                        FlagZ <= '1';
                    else
                        FlagZ <= '0';
                    end if;
                    
                    FlagC <= ACC_internal(8);
                    
                    if (ACC_internal > "000001111") then -- acc >= 16 : acarreo entre nibbles
                        FlagN <= '1';
                    else 
                        FlagN <= '0';
                    end if;
                    
                    Databus <= (others => 'Z');
                when op_sub =>
                    ACC_internal := ('0' & A) - ('0' & B);
                    ACC <= ACC_internal(7 downto 0);
                    
                    if (ACC_internal = "000000000") then
                        FlagZ <= '1';
                    else
                        FlagZ <= '0';
                    end if;
                    
                    FlagC <= ACC_internal(8);
                    
                    if (ACC_internal > "000001111") then   
                        FlagN <= '1';                      
                    else                                   
                        FlagN <= '0';                      
                    end if;   
                    
                    Databus <= (others => 'Z'); 
                when op_shiftl =>
                    ACC <= ACC(6 downto 0) & '0';
                    Databus <= (others => 'Z');
                when op_shiftr =>
                    ACC <= '0' & ACC(7 downto 1);
                    Databus <= (others => 'Z');
                when op_and =>
                    ACC_internal := ('0' & A) and ('0' & B);
                    ACC <= ACC_internal(7 downto 0);
                    if (ACC_internal = "000000000") then
                        FlagZ <= '1';
                    else
                        FlagZ <= '0';
                    end if;
                    
                    Databus <= (others => 'Z');
                when op_or =>
                    ACC_internal := ('0' & A) or ('0' & B);
                    ACC <= ACC_internal(7 downto 0);
                    if (ACC_internal = "000000000") then
                        FlagZ <= '1';
                    else
                        FlagZ <= '0';
                    end if;
                    
                    Databus <= (others => 'Z');
                when op_xor =>
                    ACC_internal := ('0' & A) xor ('0' & B);
                    ACC <= ACC_internal(7 downto 0);
                    if (ACC_internal = "000000000") then
                        FlagZ <= '1';
                    else
                        FlagZ <= '0';
                    end if;
                    
                    Databus <= (others => 'Z');
                when op_cmpe =>            
                    if (A = B) then
                        FlagZ <= '1';
                    else       
                        FlagZ <= '0';
                    end if;
                    
                    Databus <= (others => 'Z');
                when op_cmpg =>                  
                    if (A > B) then  
                        FlagZ <= '1';
                    else             
                        FlagZ <= '0';
                    end if;  
                    
                    Databus <= (others => 'Z');        
                when op_cmpl =>                  
                    if (A < B) then  
                        FlagZ <= '1';
                    else             
                        FlagZ <= '0';
                    end if;  
                    
                    Databus <= (others => 'Z');
                when op_ascii2bin =>
                    if (to_unsigned(48, 8) < A) and (A < to_unsigned(57, 8)) then
                        ACC <= A - to_unsigned(48, 8);
                        FlagE <= '0';
                    else
                        FlagE <= '1';
                    end if;
                    
                    Databus <= (others => 'Z');
                when op_bin2ascii =>
                    if (to_unsigned(0, 8) < A) and (A < to_unsigned(9, 8)) then
                        ACC <= A + to_unsigned(48, 8);                             
                        FlagE <= '0';                                            
                    else                                                         
                        FlagE <= '1';                                            
                    end if;  
                    
                    Databus <= (others => 'Z');                                                    
                when op_oeacc =>
                    Databus <= std_logic_vector(ACC);
            end case;
        end if;
    end process;
      
end Behavioral;
