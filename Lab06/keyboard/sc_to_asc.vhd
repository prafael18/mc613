library ieee;
use ieee.std_logic_1164.all;

entity sc_to_asc is
port (sc: in std_logic_vector(15 downto 0);
		caps: in std_logic;
		shift: in std_logic;
		asc: out std_logic_vector(7 downto 0));
end sc_to_asc;

Architecture behavior of sc_to_asc is
	signal sc_alt: std_logic_vector(11 downto 0);
begin
	sc_alt <= "000" & (caps xor shift) & sc(7 downto 0);
	with sc_alt select
					--Alphabet A-Z
						--upper-case
		asc <=   x"41" when x"11C",
					x"42" when x"132",
					x"43" when x"121",
					x"44" when x"123",
					x"45" when x"124",
					x"46" when x"12B",
					x"47" when x"134",
					x"48" when x"133",
					x"49" when x"143",
					x"4a" when x"13B",
					x"4b" when x"142",
					x"4c" when x"14B",
					x"4d" when x"13A",
					x"4e" when x"131",
					x"4f" when x"144",
					x"50" when x"14D",
					x"51" when x"115",
					x"52" when x"12D",
					x"53" when x"11B",
					x"54" when x"12C",
					x"55" when x"13C",
					x"56" when x"12A",
					x"57" when x"11D",
					x"58" when x"122",
					x"59" when x"135",
					x"5a" when x"11A",
						-- lower-case
					x"61" when x"01C",
					x"62" when x"032",
					x"63" when x"021",
					x"64" when x"023",
					x"65" when x"024",
					x"66" when x"02B",
					x"67" when x"034",
					x"68" when x"033",
					x"69" when x"043",
					x"6a" when x"03B",
					x"6b" when x"042",
					x"6c" when x"04B",
					x"6d" when x"03A",
					x"6e" when x"031",
					x"6f" when x"044",
					x"70" when x"04D",
					x"71" when x"015",
					x"72" when x"02D",
					x"73" when x"01B",
					x"74" when x"02C",
					x"75" when x"03C",
					x"76" when x"02A",
					x"77" when x"01D",
					x"78" when x"022",
					x"79" when x"035",
					x"7a" when x"01A",
					
					--Numbers 0-9
						--Regular (1)
					x"48" when x"045",
					x"49" when x"016",
					x"50" when x"01E",
					x"51" when x"026",
					x"52" when x"025",
					x"53" when x"02E",
					x"54" when x"036",
					x"55" when x"03D",
					x"56" when x"03E",
					x"57" when x"046",
					
						--KP (0)
					x"48" when x"070",
					x"49" when x"069",
					x"50" when x"072",
					x"51" when x"07A",
					x"52" when x"06B",
					x"53" when x"073",
					x"54" when x"074",
					x"55" when x"06C",
					x"56" when x"075",
					x"57" when x"07D",
					
						--Regular (1)
					x"48" when x"145",
					x"49" when x"116",
					x"50" when x"11E",
					x"51" when x"126",
					x"52" when x"125",
					x"53" when x"12E",
					x"54" when x"136",
					x"55" when x"13D",
					x"56" when x"13E",
					x"57" when x"146",
					
						--KP (1)
					x"48" when x"170",
					x"49" when x"169",
					x"50" when x"172",
					x"51" when x"17A",
					x"52" when x"16B",
					x"53" when x"173",
					x"54" when x"174",
					x"55" when x"16C",
					x"56" when x"175",
					x"57" when x"17D",
					
					x"00" when others;
					
end behavior;