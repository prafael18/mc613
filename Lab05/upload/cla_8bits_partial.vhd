-- brief : lab05 - question 2

library ieee;
use ieee.std_logic_1164.all;

entity cla_8bits_partial is
  port(
    x    : in  std_logic_vector(7 downto 0);
    y    : in  std_logic_vector(7 downto 0);
    cin  : in  std_logic;
    sum  : out std_logic_vector(7 downto 0);
    cout : out std_logic
  );
end cla_8bits_partial;

architecture rtl of cla_8bits_partial is
  signal cout_aux: std_logic;
  
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
   cla_8bits_part1: cla_4bits 
		port map(x(3 downto 0), y(3 downto 0), cin, sum(3 downto 0), cout_aux);	
	cla_8bits_part2: cla_4bits 
		port map(x(7 downto 4), y(7 downto 4), cout_aux, sum(7 downto 4), cout);
end rtl;
