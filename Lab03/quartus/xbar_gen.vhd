library ieee;
use ieee.std_logic_1164.all;

entity xbar_gen is
  generic (N : integer :=1);
  port(s: in std_logic_vector (N-1 downto 0);
       y1, y2: out std_logic);
end xbar_gen;


architecture rtl of xbar_gen is
	signal out1: std_logic_vector(0 to N);
	signal out2: std_logic_vector(0 to N);
	
	component xbar_v1
		port(x1, x2, s: in std_logic;
				y1, y2: out std_logic);
	end component;
	
begin
	out1(0) <= '1';
	out2(0) <= '0'; 
	xbar_gen: for i in 1 to N generate
		XBARS: xbar_v1 port map (out1(i-1), out2(i-1), s(i-1), out1(i), out2(i));
	end generate xbar_gen;
	y1 <= out1(N);
	y2 <= out2(N);

end rtl;
