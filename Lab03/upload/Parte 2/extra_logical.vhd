library ieee;
use ieee.std_logic_1164.all;

entity extra_logical is
  port(w: in std_logic_vector(3 downto 0);
		 y: in std_logic_vector(3 downto 0);
       f: out std_logic);
end extra_logical;

architecture rtl of extra_logical is

begin
	f <= ((((w(0) AND y(0)) OR
			(w(1) AND y(1))) OR
			(w(2) AND y(2))) OR
			(w(3) AND y(3)));
end rtl;
