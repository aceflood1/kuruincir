 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--TOP MODULE ENTITY CPU
entity cpu is
port(
input :  IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--edit2
--wr_encpu : in std_logic;
--edit2 end
clk : in std_logic;
output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) );
end cpu;
--TOP MODULE BEHAVIOR
architecture Behavioral of cpu is
--COMPONENT FIFO
COMPONENT fifo_generator_0
 PORT (
   rst : IN STD_LOGIC;
   wr_clk : IN STD_LOGIC;
   rd_clk : IN STD_LOGIC;
   din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
   wr_en : IN STD_LOGIC;
   rd_en : IN STD_LOGIC;
   dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
   full : OUT STD_LOGIC;
   empty : OUT STD_LOGIC
 );
END COMPONENT;

--STATE DECLERATIONS
type state_type is (fetch,decode,execute1,execute2);
signal next_s : state_type;
--SIGNALS INTERNAL
signal dout1 : std_logic_vector(15 downto 0) ; --FIFO1 OUT
signal rd_en1 : std_logic := '0' ; --FIFO1 READ ENABLE
signal wr_en1 : std_logic := '0' ; --FIFO1 WRITE ENABLE

signal instruction : std_logic_vector(7 downto 0) ; --INSTRUCTION
signal data : std_logic_vector(7 downto 0) ; --DATA 8 bit
signal data1 : std_logic_vector(4 downto 0); --DATA1 4 bit 
signal data2 : std_logic_vector(4 downto 0) ; --DATA2 4 bit
signal sum : std_logic_vector(7 downto 0); --DATA1+DATA2 000SUM(3+5-bit) 8 bit


signal din2 : std_logic_vector(15 downto 0) ; --FIFO2 IN
signal rd_en2 : std_logic := '0' ; --FIFO2 READ ENABLE
signal wr_en2 : std_logic := '0' ; --FIFO2 WRITE ENABLE

signal rst1,rst2,wr_clk1,wr_clk2,rd_clk1,rd_clk2,full1,full2,empty1,empty2 : std_logic := '0';


--SIGNAL END

begin
--INSTANTINATE FIFOs

FIFO_1 : fifo_generator_0
 PORT MAP (
   rst => rst1,
   wr_clk => clk,
   rd_clk => clk,
   din => input,
   wr_en => '1',
   rd_en => rd_en1,
   dout => dout1,
   full => full1,
   empty => empty1
 );
 FIFO_2 : fifo_generator_0
   PORT MAP (
     rst => rst2,
     wr_clk => clk,
     rd_clk => clk,
     din => din2,
     wr_en => '1',
     rd_en => '1',
     dout => output,
     full => full2,
     empty => empty2
   );


process(clk)
begin
if(rising_edge(clk)) then
case next_s is
--Fetch
when fetch =>
--din2 <= X"0000";
 if(empty1 = '1') then --FIFO EMPTY, WAIT FOR INSTRUCTION
       --wr_en1 <= '0';
       rd_en1 <= '1';
     next_s <= fetch;
 end if;     
 --  elsif(full1 ='1') then --FIFO FULL, FETCH
       --wr_en1 <= '0';
      rd_en1 <= '1';
      
       instruction <= dout1(15 downto 8);
       data <= dout1(7 downto 0);
       data1 <= "0" & dout1(7 downto 4);
       data2 <= "0" & dout1(3 downto 0);
      
       next_s <= decode;
      
  -- end if;

when decode =>
--din2 <= X"0000";
 --wr_en1 <= '1';
      rd_en1 <= '0';
       if(instruction = X"AA") then
        next_s <= execute1;
       elsif(instruction = x"55") then
        next_s <= execute2;
       else
        next_s <= fetch;
       end if;
      

when execute1 =>
-- wr_en1 <= '1';
     rd_en1 <= '0';
din2 <=instruction & data;
next_s <= fetch;

when execute2 =>
 --wr_en1 <= '1';
rd_en1 <= '0';
sum <= "000" & ( data1 + data2); --3bit + 5bit 
din2 <=instruction & (sum); --8bit & 8bit
next_s <= fetch;


end case;

end if;

end process;
end Behavioral;