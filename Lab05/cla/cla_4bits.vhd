-- brief : lab05 - question 2
library ieee;
use ieee.std_logic_1164.all;

entity cla_4bits is
  port(
    x    : in  std_logic_vector(3 downto 0);
    y    : in  std_logic_vector(3 downto 0);
    cin  : in  std_logic;
    sum  : out std_logic_vector(3 downto 0);
    cout : out std_logic
  );
end cla_4bits;

architecture rtl of cla_4bits is
	signal p: std_logic_vector(3 downto 0);
	signal g: std_logic_vector(3 downto 0);
	signal c_vec: std_logic_vector(4 downto 0);
	
	begin
		p(0) <= x(0) or y(0);
		p(1) <= x(1) or y(1);
		p(2) <= x(2) or y(2);
		p(3) <= x(3) or y(3);
		
		g(0) <= x(0) and y(0);
		g(1) <= x(1) and y(1);
		g(2) <= x(2) and y(2);
		g(3) <= x(3) and y(3);
		
		c_vec(0) <= cin;
		c_vec(1) <= g(0) or (p(0) and c_vec(0));	
		c_vec(2) <= g(1) or (p(1) and (g(0) or (p(0) and c_vec(0))));	
		c_vec(3) <= g(2) or (p(2) and (g(1) or (p(1) and (g(0) or (p(0) and c_vec(0))))));
		c_vec(4) <= g(3) or (p(3) and (g(2) or (p(2) and (g(1) or (p(1) and (g(0) or (p(0) and c_vec(0))))))));
		
		g1: for i in 0 to 3 generate
			sum(i) <= (x(i) xor y(i)) xor c_vec(i);
		end generate;
		
		cout <= c_vec(4);
end rtl;