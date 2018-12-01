
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

ENTITY RAM IS
    PORT ( Clk      : in    std_logic;
           Reset    : in    std_logic;
           write_en : in    std_logic;
           oe       : in    std_logic;
           address  : in    std_logic_vector(7 downto 0);
           databus  : inout std_logic_vector(7 downto 0);
           Switches : out   std_logic_vector(7 downto 0);
           Temp_L   : out   std_logic_vector(6 downto 0);
           Temp_H   : out   std_logic_vector(6 downto 0));
END RAM;

ARCHITECTURE behavior OF RAM IS

    SIGNAL ram_specific : array8_ram(0 to 63);
    SIGNAL ram_generic : array8_ram(64 to 255);
    SIGNAL chipset : std_logic;
  
BEGIN

-- chipset = 1 para la segunda memoria.
p_chipset : process (Reset, address)
    begin
        if (Reset = '0') then
            chipset <= '0';
        elsif (address = ("ZZZZZZZZ")) then -- solo para que chipset no aparezca en forma de X 
            chipset <= 'Z';
        else
            chipset <= address(7) or address(6); -- Address mayor que 00111111 3F 63dec.
        end if;
    end process;

p_escritura : process (clk, reset) 
    begin
        if (Reset = '0') then
            for I in 0 to 63 loop
                if (I = 49) then  -- La posicion 49 decimal es la x"31" (en hex)
                    ram_specific(49) <= "00100000"; -- Inicializar a 20 grados
                else
                    ram_specific(I) <= (others => '0');
                end if;
            end loop;
        elsif (clk'event and clk = '1') then
            if (write_en = '1') then
                if (chipset = '0') then
                    ram_specific(to_integer(unsigned(address))) <= databus;
                elsif (chipset = '1') then     
                    ram_generic(to_integer(unsigned(address))) <= databus;
                end if;
            end if;
        end if;
    end process;

p_lectura : process (clk, reset, address, chipset, oe) -- la memoria tiene que ser síncrona 
    begin                                       -- para que Xilinx lo sintetice en los bloques reservados
        if (reset = '0') then
            databus <= (others => 'Z');
        elsif (clk'event and clk = '1') then
            if (oe = '0') then
                if (chipset = '0') then
                    databus <= ram_specific(to_integer(unsigned(address)));
                elsif (chipset = '1') then
                    databus <= ram_generic(to_integer(unsigned(address)));
                end if;
            else
                databus <= (others => 'Z');
            end if;
        end if;
    end process;

-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Decodificador de BCD a 7 segmentos
-------------------------------------------------------------------------
with ram_specific(49)(7 downto 4) select
Temp_H <=
    "0111111" when "0000",  -- 0
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
--    "1001111" when "0011",  -- 3
--    "1100110" when "0100",  -- 4
--    "1101101" when "0101",  -- 5
--    "1111101" when "0110",  -- 6
--    "0000111" when "0111",  -- 7
--    "1111111" when "1000",  -- 8
--    "1101111" when "1001",  -- 9
--    "1110111" when "1010",  -- A
--    "1111100" when "1011",  -- B
--    "0111001" when "1100",  -- C
--    "1011110" when "1101",  -- D
    "1111001" when others;  -- E de que hay error  
--    "1110001" when "1111",  -- F

    
with ram_specific(49)(3 downto 0) select
    Temp_L <=
        "0111111" when "0000",  -- 0
        "0000110" when "0001",  -- 1
        "1011011" when "0010",  -- 2
        "1001111" when "0011",  -- 3
        "1100110" when "0100",  -- 4
        "1101101" when "0101",  -- 5
        "1111101" when "0110",  -- 6
        "0000111" when "0111",  -- 7
        "1111111" when "1000",  -- 8
        "1101111" when "1001",  -- 9
--        "1110111" when "1010",  -- A
--        "1111100" when "1011",  -- B
--        "0111001" when "1100",  -- C
--        "1011110" when "1101",  -- D
        "1111001" when others;  -- E
--        "1110001" when "1111",  -- F

-----------------------------------------------------------------------

-------------------------------------------------------------------------
-- Salidas de los Switches
-------------------------------------------------------------------------
-- Seleccionamos el LSB de cada byte de la direccion correspondiente a los switches.

Switches <= ram_specific(23)(0 downto 0) &
            ram_specific(22)(0 downto 0) &
            ram_specific(21)(0 downto 0) &
            ram_specific(20)(0 downto 0) &
            ram_specific(19)(0 downto 0) &
            ram_specific(18)(0 downto 0) &
            ram_specific(17)(0 downto 0) &
            ram_specific(16)(0 downto 0);

END behavior;

