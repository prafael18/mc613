-- brief : lab05 - question 2
library ieee;
use ieee.std_logic_1164.all;

entity cla_4bits_board is
  port(
    SW : in  std_logic_vector(8 downto 0);
    LEDR : out std_logic_vector(4 downto 0)
  );
end cla_4bits_board;

architecture rtl of cla_4bits_board is
	component cla_4bits
	port(
		 x    : in  std_logic_vector(3 downto 0);
		 y    : in  std_logic_vector(3 downto 0);
		 cin  : in  std_logic;
		 sum  : out std_logic_vector(3 downto 0);
		 cout : out std_logic
		);
	end component;
	
	begin
		cla_board: cla_4bits
			port map(SW(3 downto 0), SW(7 downto 4), SW(8), LEDR(3 downto 0), LEDR(4));
		
end rtl;