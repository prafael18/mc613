library ieee;
use ieee.std_logic_1164.all;

entity kbd_alphanum is
  port (
    clk : in std_logic;
    key_on : in std_logic_vector(2 downto 0);
    key_code : in std_logic_vector(47 downto 0);
    HEX1 : out std_logic_vector(6 downto 0); -- GFEDCBA
    HEX0 : out std_logic_vector(6 downto 0) -- GFEDCBA
  );
end kbd_alphanum;

architecture rtl of kbd_alphanum is
	
	component sc_to_asc is
		port (sc: in std_logic_vector(15 downto 0);
			caps: in std_logic;
			shift: in std_logic;
			asc: out std_logic_vector(7 downto 0));
	end component;
	
	component bin2hex is
		port (En: in std_logic;
			SW: in std_logic_vector(3 downto 0);
			HEX0: out std_logic_vector(6 downto 0));
	end component;

	signal asc_code: std_logic_vector (7 downto 0);
	
	signal caps_in: std_logic;
	signal caps: std_logic;
	
	signal shift: std_logic;
	signal asc_key1: std_logic_vector (7 downto 0);
	signal asc_key2: std_logic_vector (7 downto 0);
	signal en: std_logic;
	
begin

	hexseg0: bin2hex 
	port map(en, asc_code(3 downto 0), HEX0);
	
	hexseg1: bin2hex 
	port map(en, asc_code(7 downto 4), HEX1);
	
	keypress1: sc_to_asc
	port map(key_code(15 downto 0), caps, shift, asc_key1);
	
	keypress2: sc_to_asc
	port map(key_code(31 downto 16), caps, shift, asc_key2);
	
	process(caps_in)
	begin
		if caps_in = '1' then
			caps <= not caps;
		end if;
	end process;

	caps_in <=  '1' when key_code(15 downto 0)  = x"0058" else
					'1' when key_code(31 downto 16) = x"0058" else
					'0';
	
	with key_code(15 downto 0) select
		shift <= '1' when x"0012",
					'1' when x"0059",
					'0' when others;
	
	with shift select
		asc_code <= asc_key1 when '0',
						asc_key2 when others;
						
	with asc_code select
		en <= '0' when x"00",
				'1' when others;
	
end rtl;
