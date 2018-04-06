library ieee;
use ieee.std_logic_1164.all;

entity barrel_shifter_board is
  port(
    SW  : in  std_logic_vector (5 downto 0);
    LEDR: out std_logic_vector (3 downto 0)
  );
end barrel_shifter_board;

architecture rtl of barrel_shifter_board is
	component barrel_shifter
	  port(
    w : in  std_logic_vector (3 downto 0);
    s : in  std_logic_vector (1 downto 0);
    y : out std_logic_vector (3 downto 0)
  );
	end component;
begin
	b_shifter: barrel_shifter port map(SW(3 downto 0), SW(5 downto 4), LEDR(3 downto 0));
end rtl;
