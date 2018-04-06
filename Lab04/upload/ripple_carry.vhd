library ieee;
use ieee.std_logic_1164.all;

entity ripple_carry is
  generic (
    N : integer := 4
  );
  port (
    x,y : in std_logic_vector(N-1 downto 0);
    r : out std_logic_vector(N-1 downto 0);
    cin : in std_logic;
    cout : out std_logic;
    overflow : out std_logic
  );
end ripple_carry;

architecture rtl of ripple_carry is

	signal c_vec: std_logic_vector(N downto 0);
			
	component full_adder
		port (
		x, y : in std_logic;
		r : out std_logic;
		cin : in std_logic;
		cout : out std_logic);
	end component;

begin
	c_vec(0) <= cin;

	ripple_carry_gen: for i in 0 to N-1 generate	
		ADDERS: full_adder port map (x(i), y(i), r(i), c_vec(i), c_vec(i+1));
	end generate ripple_carry_gen;
	
	cout <= c_vec(N);
	overflow <= (c_vec(N) XOR c_vec(N-1));
	
end rtl;