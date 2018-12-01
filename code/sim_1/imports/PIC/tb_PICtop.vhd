LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;
use work.RS232_test.all;

entity tb_PICtop is
end tb_PICtop;

architecture TestBench of tb_PICtop is

  component PICtop
    port (
      Reset     : in  std_logic;
      Clk100MHZ : in  std_logic;
      RS232_RX  : in  std_logic;
      RS232_TX  : out std_logic;
      switches  : out std_logic_vector(7 downto 0);
      Temp      : out std_logic_vector(7 downto 0);
      CuentInst : out std_logic_vector(11 downto 0);
      Disp      : out std_logic_vector(1 downto 0));
  end component;

-----------------------------------------------------------------------------
-- Internal signals
-----------------------------------------------------------------------------

  signal Reset     : std_logic;
  signal Clk100MHZ : std_logic;
  signal RS232_RX  : std_logic;
  signal RS232_TX  : std_logic;
  signal switches  : std_logic_vector(7 downto 0);
  signal Temp      : std_logic_vector(7 downto 0);
  signal Disp      : std_logic_vector(1 downto 0);
  signal CuentInst : std_logic_vector(11 downto 0);
begin  -- TestBench

  UUT: PICtop
    port map (
        Reset     => Reset,
        Clk100MHZ => Clk100MHZ,
        RS232_RX  => RS232_RX,
        RS232_TX  => RS232_TX,
        switches  => switches,
        CuentInst => CuentInst,
        Temp      => Temp,
        Disp      => Disp);

-----------------------------------------------------------------------------
-- Reset & clock generator
-----------------------------------------------------------------------------

  Reset <= '0', '1' after 75 ns;

  p_clk : PROCESS
  BEGIN
     Clk100MHZ <= '1', '0' after 5 ns;
     wait for 10 ns;
  END PROCESS;

-------------------------------------------------------------------------------
-- Sending some stuff through RS232 port
-------------------------------------------------------------------------------

  SEND_STUFF : process
  begin
     RS232_RX <= '1';
     wait for 40 us;
     Transmit(RS232_RX, X"49");
     wait for 40 us;
     Transmit(RS232_RX, X"34");
     wait for 40 us;
     Transmit(RS232_RX, X"31");
     wait;
  end process SEND_STUFF;
   
end TestBench;