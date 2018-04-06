library ieee;
use ieee.std_logic_1164.all;

entity mux16to1 is
	port (w : in std_logic_vector(15 downto 0);
			s : in std_logic_vector(3 downto 0);
			f : out std_logic);
end mux16to1;

architecture rt1 of mux16to1 is
	
	component mux4to1
		 port(s: in std_logic_vector(1 downto 0);
		 w: in std_logic_vector(3 downto 0);
       f: out std_logic);
	end component;
	
	signal m: std_logic_vector(3 downto 0);
	
begin
	Mux1: mux4to1 port map (s(1 downto 0), w(3 downto 0), m(0));
	Mux2: mux4to1 port map (s(1 downto 0), w(7 downto 4), m(1));
	Mux3: mux4to1 port map (s(1 downto 0), w(11 downto 8), m(2));
	Mux4: mux4to1 port map (s(1 downto 0), w(15 downto 12), m(3));
	
	Mux5: mux4to1 port map (s(3 downto 2), m(3 downto 0), f);
end rt1;