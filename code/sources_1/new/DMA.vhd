----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.10.2018 14:41:38
-- Design Name: 
-- Module Name: DMA - Behavioral
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

entity DMA is
    Port ( Reset     : in STD_LOGIC;
           Clk       : in STD_LOGIC;
           RCVD_Data : in STD_LOGIC_VECTOR (7 downto 0);
           RX_Full   : in STD_LOGIC;
           RX_Empty  : in STD_LOGIC;
           ACK_out   : in STD_LOGIC;
           TX_RDY    : in STD_LOGIC;
           DMA_ACK   : in STD_LOGIC;
           Send_comm : in STD_LOGIC;
           Data_read : out STD_LOGIC;
           Valid_D   : out STD_LOGIC;
           TX_Data   : out STD_LOGIC_VECTOR (7 downto 0);
           Address   : out STD_LOGIC_VECTOR (7 downto 0);
           Databus   : inout STD_LOGIC_VECTOR (7 downto 0);
           Write_en  : out STD_LOGIC;
           OE        : out STD_LOGIC;
           DMA_RQ    : out STD_LOGIC;
           READY     : out STD_LOGIC);
end DMA;

architecture Behavioral of DMA is

    type State is (Idle, Inicio_tx, aviso_envio1, envio1, envio2, aviso_envio2, inicio_rx, espabiladr, recibir, fin_rx, the_end);
    
    signal CurrentState, NextState       : State;
    signal count_rx                      : unsigned(1 downto 0) := "00";
    signal Next_clk                      : unsigned(1 downto 0) := "00";
    --signal RegistroDatos                 : std_logic_vector(23 downto 0) := (others => 'Z'); -- Almacenar  temporalmente los datos a enviar y recibir
    
begin

Next_process: process (clk, CurrentState, RX_Empty, send_comm, tx_rdy, dma_ack, count_rx, next_clk) 
    begin
        case CurrentState is
            when Idle =>
                if(RX_Empty = '0' and send_comm = '0') then
                    NextState <= Inicio_rx;
                elsif(Send_Comm = '1') then
                    NextState <= Inicio_tx;
                else
                    NextState <= Idle;
                end if;
            when Inicio_tx =>
                if(tx_rdy = '1') then
                    NextState <= aviso_envio1;
                else
                    NextState <= Inicio_tx;
                end if;
            when aviso_envio1 =>
                --if(tx_rdy'event and tx_rdy = '1') then
                if (tx_rdy = '0') then   
                    NextState <= envio1;
                else
                    NextState <= aviso_envio1;
                end if;
            when envio1 =>
                --if (tx_rdy'event and tx_rdy = '0') then
                if (tx_rdy = '1') then  
                    NextState <= aviso_envio2;
                else
                    NextState <= envio1;
                end if;
            when aviso_envio2 =>
                --if (tx_rdy'event and tx_rdy = '1') then
                if (tx_rdy = '0') then  
                    NextState <= envio2;
                else
                    NextState <= aviso_envio2;
                end if;
            when envio2 =>
                --if (tx_rdy'event and tx_rdy = '0') then
                if (tx_rdy = '1') then  
                    NextState <= idle;
                else
                    NextState <= envio2;
                end if;
            when Inicio_rx =>
                if(dma_ack = '1') then
                    NextState <= espabiladr;
                else
                    NextState <= Inicio_rx;
                end if;
            when espabiladr =>
                if (Next_clk = "01") then
                    NextState <= recibir;
                else
                    NextState <= espabiladr;
                end if;
            when recibir =>
                if(count_rx < "10") then
                    NextState <= fin_rx;
                elsif (count_rx = "10") then
                    nextstate <= the_end;
                else
                    NextState <= recibir;
                end if;
            when fin_rx =>
                if (dma_ack = '0') then
                    NextState <= idle;
                else
                    NextState <= fin_rx;
                end if;
            when the_end =>
                Nextstate <= fin_rx;
--                if (count_rx = "00") then
--                    NextState <= fin_rx;
--                else
--                    NextState <= the_end;
--                end if;
            when others => 
                NextState <= Idle;
        end case;
    end process;

FFs: process (Reset, Clk, NextState, CurrentState) 
    begin
        if Reset = '0' then
            CurrentState <= Idle;
            --NextState <= Idle;
        elsif Clk'event and Clk = '1' then
            CurrentState <= NextState;
        end if;
    end process;

Outputs: process (Clk, currentstate) 
    begin
        if (Reset = '0') then
                    Count_rx <= (others => '0');
      elsif(clk'event and clk='1') then
        case CurrentState is
            
            when Idle =>
                OE <= 'Z';
                Write_en <= 'Z';
                Address <= (others => 'Z');
                Databus <= (others => 'Z');
                
                DMA_RQ <= '0';
                READY  <= '1';
                
                Data_Read <= '0';

                Valid_D <= '1';
                TX_Data <= (others => 'Z');
            when Inicio_tx =>
                OE <= 'Z';
                Write_en <= 'Z';
                Address <= (others => 'Z');
                Databus <= (others => 'Z');
                
                DMA_RQ <= '0';
                READY  <= '0';
                
                Data_Read <= '0';
    
                Valid_D <= '1';
                TX_Data <= (others => 'Z');
            when aviso_envio1 =>
                OE <= '0';
                Write_en <= 'Z';
                Address <= dma_tx_buffer_msb;
                Databus <= (others => 'Z');
                
                DMA_RQ <= '0';
                READY  <= '0';
                
                Data_Read <= '0';

                Valid_D <= '0';
                TX_Data <= Databus;
            when envio1 =>
                OE <= '0';
                Write_en <= 'Z';
                Address <= dma_tx_buffer_msb;
                Databus <= (others => 'Z');
                
                DMA_RQ <= '0';
                READY  <= '0';
                
                Data_Read <= '0';
    
                Valid_D <= '1';
                TX_Data <= Databus;
            when aviso_envio2 =>
                OE <= '0';                  
                Write_en <= 'Z';            
                Address <= dma_tx_buffer_lsb;
                Databus <= (others => 'Z'); 
                                            
                DMA_RQ <= '0';              
                READY  <= '0';              
                                            
                Data_Read <= '0';           
                                            
                Valid_D <= '0';             
                TX_Data <= Databus;   
            when envio2 =>
                OE <= '0';
                Write_en <= 'Z';
                Address <= dma_tx_buffer_lsb;
                Databus <= (others => 'Z');
                
                DMA_RQ <= '0';
                READY  <= '0';
                
                Data_Read <= '0';
    
                Valid_D <= '1';
                TX_Data <= Databus;         
            when Inicio_rx =>
                if (Count_rx = "11") then
                            Count_rx <= (others => '0');
                end if;
            
                OE <= 'Z';                  
                Write_en <= 'Z';            
                Address <= (others => 'Z'); 
                Databus <= (others => 'Z'); 
                                            
                DMA_RQ <= '1';              
                READY  <= '1';              
                                            
                Data_Read <= '0';           
                                            
                Valid_D <= '1';             
                TX_Data <= (others => 'Z');
            when espabiladr =>
                OE <= 'Z';                  
                Write_en <= 'Z';            
                Address <= (others => 'Z'); 
                Databus <= (others => 'Z'); 
                                            
                DMA_RQ <= '1';              
                READY  <= '1';              
                                            
                Data_Read <= '1';           
                                            
                Valid_D <= '1';             
                TX_Data <= (others => 'Z');  
            when recibir =>
                Count_rx <= Count_rx + to_unsigned(1,2);
                OE <= 'Z';                  
                Write_en <= '1';
                case count_rx is                                  
                    when "00"   =>    Address <= DMA_RX_BUFFER_MSB; 
                    when "01"   =>    Address <= DMA_RX_BUFFER_MID; 
                    when "10"   =>    Address <= DMA_RX_BUFFER_LSB; 
                    when others =>    Address <= (others => 'Z');   
                end case;                                                       
                Databus <= rcvd_data; 
                                            
                DMA_RQ <= '1';              
                READY  <= '1';              
                                            
                Data_Read <= '0';           
                                            
                Valid_D <= '1';             
                TX_Data <= (others => 'Z');  
            when fin_rx =>
                OE <= 'Z';                  
                Write_en <= 'Z';            
                Address <= (others => 'Z'); 
                Databus <= (others => 'Z'); 
                                            
                DMA_RQ <= '0';              
                READY  <= '1';              
                                            
                Data_Read <= '0';           
                                            
                Valid_D <= '1';             
                TX_Data <= (others => 'Z'); 
            when the_end =>
                OE <= 'Z';                  
                Write_en <= '1';            
                Address <= X"03"; 
                Databus <= X"FF"; 
                                            
                DMA_RQ <= '1';              
                READY  <= '1';              
                                            
                Data_Read <= '0';           
                                            
                Valid_D <= '1';             
                TX_Data <= (others => 'Z'); 
             when others =>
                            OE <= 'Z';
                                            Write_en <= 'Z';
                                            Address <= (others => 'Z');
                                            Databus <= (others => 'Z');
                                            
                                            DMA_RQ <= '0';
                                            READY  <= '1';
                                            
                                            Data_Read <= '0';
                            
                                            Valid_D <= '1';
                                            TX_Data <= (others => 'Z');
        end case;
       end if;
    end process;
    
--CounterRecibir : process(clk, Reset, CurrentState) 
--    begin
--        if (Reset = '0') then
--            Count_rx <= (others => '0');
--        elsif (clk'event and clk = '0') then -- estaba en los pulsos de bajada
--            if (Count_rx = "11") then
--                Count_rx <= (others => '0');
--            elsif (CurrentState = recibir) then
--                Count_rx <= Count_rx + to_unsigned(1,2);
--            end if;
--        end if;
--    end process;
    
CounterNextClk : process(clk, Reset, CurrentState) 
        begin
            if (Reset = '0') then
                Next_clk <= (others => '0');
            elsif (clk'event and clk = '1') then
                if (Next_clk = "10") then
                    Next_clk <= (others => '0');
                elsif (CurrentState = espabiladr) then
                    Next_clk <= Next_clk + to_unsigned(1,2);
                else
                    Next_clk <= (others => '0');
                end if;
            end if;
        end process;    

end Behavioral;
