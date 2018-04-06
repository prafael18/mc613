-- brief : lab05 - question 1

library ieee;
use ieee.std_logic_1164.all;

entity barrel_shifter is
  port(
    w : in  std_logic_vector (3 downto 0);
    s : in  std_logic_vector (1 downto 0);
    y : out std_logic_vector (3 downto 0)
  );
end barrel_shifter;

architecture rtl of barrel_shifter is
begin
	process(w, s)
		variable x: integer;
		begin
			if s = "00" then x := 0;
			elsif s = "01" then x := 1;
			elsif s = "10" then x := 2;
			else x := 3;
			end if;
		for i in 0 to 3 loop
			y(i) <= w((i+x) mod 4);
		end loop;
	end process;
end rtl;
