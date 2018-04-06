library ieee;
use ieee.std_logic_1164.all;

entity dec2to4 is
  port(w: in std_logic_vector(1 downto 0);
       y: out std_logic_vector(3 downto 0));
end dec2to4;

architecture rtl of dec2to4 is
	signal Enw: std_logic_vector(2 downto 0);
begin
	Enw  <= '1' & w;
	with Enw select
	y <= "0001" WHEN "100",
			"0010" WHEN "101",
			"0100" WHEN "110",
			"1000" WHEN OTHERS;
end rtl;
