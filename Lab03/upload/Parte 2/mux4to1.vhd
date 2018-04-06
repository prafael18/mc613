library ieee;
use ieee.std_logic_1164.all;

entity mux4to1 is
  port(s: in std_logic_vector(1 downto 0);
		 w: in std_logic_vector(3 downto 0);
       f: out std_logic);
end mux4to1;

architecture rtl of mux4to1 is

	component dec2to4
		port(w: in std_logic_vector(1 downto 0);
			  y: out std_logic_vector(3 downto 0));
	end component;
	
	component extra_logical
		port(w: in std_logic_vector(3 downto 0);
			  y: in std_logic_vector(3 downto 0);
			  f: out std_logic);
	end component;
		
	signal y_out: std_logic_vector(3 downto 0);
	
begin
	MUX_1: dec2to4 port map(s, y_out);
	MUX_2: extra_logical port map (w, y_out, f);
end rtl;
