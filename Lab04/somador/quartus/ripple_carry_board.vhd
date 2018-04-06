library ieee;
use ieee.std_logic_1164.all;

entity ripple_carry_board is
  port (
    SW : in std_logic_vector(7 downto 0);
    HEX4 : out std_logic_vector(6 downto 0);
    HEX2 : out std_logic_vector(6 downto 0);
    HEX0 : out std_logic_vector(6 downto 0);
    LEDR : out std_logic_vector(0 downto 0)
    );
end ripple_carry_board;

architecture rtl of ripple_carry_board is

	signal out_vec: std_logic_vector(3 downto 0);
	signal cin: std_logic;
	signal cout: std_logic;
	
	component ripple_carry
		generic (N : integer :=4);
		port (
			x,y : in std_logic_vector(N-1 downto 0);
			r : out std_logic_vector(N-1 downto 0);
			cin : in std_logic;
			cout : out std_logic;
			overflow : out std_logic);
	end component;
	
	component bin2hex
		port (SW: in std_logic_vector(3 downto 0);
				HEX0: out std_logic_vector(6 downto 0));
	end component;
	
begin
	cin <= '0';
	
	RIPPLE_CARRY_BOARD: ripple_carry generic map (N => 4)
								 port map(SW(7 downto 4), SW(3 downto 0), out_vec(3 downto 0), cin, cout, LEDR(0));
	DISPLAY_HEX_1: bin2hex port map(SW(7 downto 4), HEX4(6 downto 0));
	DISPLAY_HEX_2: bin2hex port map(SW(3 downto 0), HEX2(6 downto 0));
	DISPLAY_HEX_3: bin2hex port map(out_vec(3 downto 0), HEX0(6 downto 0));

	
end rtl;