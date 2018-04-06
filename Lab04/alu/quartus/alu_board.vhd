library ieee;
use ieee.std_logic_1164.all;

entity alu_board is
  port (
    SW : in std_logic_vector(9 downto 0);
    HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 : out std_logic_vector(6 downto 0);
    LEDR : out std_logic_vector(3 downto 0)
  );
end alu_board;

architecture behavioral of alu_board is
	signal F_out: std_logic_vector(3 downto 0);
	signal logic_hex_1, logic_hex_2, logic_hex_3: std_logic_vector(6 downto 0);
	signal arith_hex_1, arith_hex_2, arith_hex_3: std_logic_vector(6 downto 0);
	signal sign_hex_1, sign_hex_2, sign_hex_3: std_logic;
	
	component alu
		port (a, b : in std_logic_vector(3 downto 0);
			F : out std_logic_vector(3 downto 0);
			s0, s1 : in std_logic;
			Z, C, V, N : out std_logic);
	end component;
	
	component two_comp_to_7seg
		port (bin : in std_logic_vector(3 downto 0);
			segs : out std_logic_vector(6 downto 0);
			neg : out std_logic);
	end component;

	component bin2hex
		port (SW: in std_logic_vector(3 downto 0);
				HEX0: out std_logic_vector(6 downto 0));
	end component;
	
begin

	g1: for i in 0 to 5 generate
		HEX5(i) <= '1';
		HEX3(i) <= '1';
		HEX1(i) <= '1';
	end generate;
	
	ALU_BOARD: alu port map(SW(7 downto 4), SW(3 downto 0), F_out, SW(9), SW(8), LEDR(3), LEDR(2), LEDR(1), LEDR(0));

	DISPLAY_LOGIC_HEX_1: bin2hex port map (SW(7 downto 4), logic_hex_3);
	DISPLAY_LOGIC_HEX_2: bin2hex port map (SW(3 downto 0), logic_hex_2);
	DISPLAY_LOGIC_HEX_3: bin2hex port map (F_out(3 downto 0), logic_hex_1);
	
	DISPLAY_ARITH_HEX_1: two_comp_to_7seg port map(SW(7 downto 4), arith_hex_3, sign_hex_3);
	DISPLAY_ARITH_HEX_2: two_comp_to_7seg port map(SW(3 downto 0), arith_hex_2, sign_hex_2);
	DISPLAY_ARITH_HEX_3: two_comp_to_7seg port map(F_out(3 downto 0), arith_hex_1, sign_hex_1);
	
	process(SW)
	begin
		if SW(8) = '1' then
			HEX4 <= logic_hex_3;
			HEX2 <= logic_hex_2;
			HEX0 <= logic_hex_1;
			HEX5(6) <= '1';
			HEX3(6) <= '1';
			HEX1(6) <= '1';
		else
			HEX4 <= arith_hex_3;
			HEX2 <= arith_hex_2;
			HEX0 <= arith_hex_1;
			HEX5(6) <= not sign_hex_3;
			HEX3(6) <= not sign_hex_2;
			HEX1(6) <= not sign_hex_1;
		end if;
	end process;
end behavioral;