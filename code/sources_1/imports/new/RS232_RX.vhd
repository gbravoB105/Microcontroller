----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.09.2018 01:42:36
-- Design Name: 
-- Module Name: RS232_RX - Behavioral
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

entity RS232_RX is
    Port ( Reset     : in STD_LOGIC;
           Clk       : in STD_LOGIC;
           LineRD_in : in STD_LOGIC;
           Valid_out : out STD_LOGIC;
           Code_out  : out STD_LOGIC;
           Store_out : out STD_LOGIC);
end RS232_RX;

architecture Behavioral of RS232_RX is

    type State is (Idle, StartBit, RcvData, StopBit);
    
    signal CurrentState, NextState                  : State;
    signal FlagDataCount, FlagBitWidth, FlagHalfBit : std_logic;
    signal BitWidth                                 : unsigned (7 downto 0);
    signal HalfBitWidth                             : unsigned (6 downto 0);
    signal DataCount                                : unsigned(2 downto 0);
    constant PulseEndOfCount                        : integer := 174;

begin

Next_process: process (CurrentState, LineRD_in, FlagBitWidth, FlagDataCount)
    begin
        case CurrentState is
            when Idle =>
                if (LineRD_in = '0') then
                    NextState <= StartBit;
                else
                    NextState <= Idle;
                end if;
            when StartBit =>
                if (FlagBitWidth = '1') then
                    NextState <= RcvData;
                else
                    NextState <= StartBit;
                end if;
            when RcvData =>
                if (FlagDataCount = '1') then
                    NextState <= StopBit;
                else
                    NextState <= RcvData;
                end if;
             when StopBit =>
                if (FlagBitWidth = '1') then
                    NextState <= Idle;
                else
                    NextState <= StopBit;
                end if;
        end case;
    end process;

FFs: process (Reset, Clk) 
    begin
        if (Reset = '0') then
            CurrentState <= Idle;
        elsif (Clk'event and Clk = '1') then
            CurrentState <= NextState;
        end if;
    end process;
   
Outputs: process (CurrentState, DataCount, FlagHalfBit, LineRD_in) 
    begin
        case CurrentState is
            when Idle =>
                Valid_out <= '0';
                Code_out  <= '0';
                Store_out <= '0';
            when StartBit =>
                Valid_out <= '0';
                Code_out  <= '0';
                Store_out <= '0';
            when RcvData =>
                if (FlagHalfBit = '1') then
                    Valid_out <= '1';
                    Code_out <= LineRD_in;
                else
                    Valid_out <= '0';
                    Code_out  <= '0';
                end if;
                Store_out <= '0';
            when StopBit =>
                Valid_out <= '0';
                Code_out  <= '0';
                if (FlagHalfBit = '1' and LineRD_in = '1') then 
                    Store_out <= '1';
                else
                    Store_out <= '0';
                end if;
         end case;
    end process;

BitWidth_HalfWidth_counter: process (Clk, Reset, CurrentState, LineRD_in)
    begin
        if (Reset = '0' or CurrentState = Idle) then
            BitWidth <= (others => '0');
            HalfBitWidth <= (others => '0');
            FlagBitWidth <= '0';
            FlagHalfBit <= '0';
        elsif (Clk'event and Clk = '1') then
            BitWidth <= BitWidth + to_unsigned(1,8);
            HalfBitWidth <= HalfBitWidth + to_unsigned(1,7);
            if (BitWidth = PulseEndOfCount) then 
                BitWidth <= (others => '0');
                HalfBitWidth <= (others => '0');
                FlagBitWidth <= '1';
                FlagHalfBit <= '0';
            else 
                FlagBitWidth <= '0';
            end if;
            if (HalfBitWidth = 87) then
                FlagHalfBit <= '1';
            else
                FlagHalfBit <= '0';
            end if;
        end if;
    end process;
 
DataCounter: process (Clk, Reset, CurrentState, FlagBitWidth)
    begin
        if (Reset = '0' or CurrentState = StartBit) then
            DataCount <= (others => '0');
            FlagDataCount <= '0';
        elsif (Clk'event and Clk='1') then
            if (CurrentState = RcvData and (FlagBitWidth = '1')) then  
                DataCount <= DataCount + to_unsigned(1,3);
                if (DataCount = 7) then
                    DataCount <= (others => '0');
                    FlagDataCount <= '1';
                else
                    FlagDataCount <= '0';
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;