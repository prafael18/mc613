library ieee;
use ieee.std_logic_1164.all;

entity shift_register_board is
port(
	 SW		: in  std_logic_vector (8 downto 0);
	 KEY		: in  std_logic_vector (0 downto 0);
	 LEDR		: out std_logic_vector (5 downto 0));
end shift_register_board;

architecture rtl of shift_register_board is
	component shift_register is
		generic (N : integer := 6);
		port(
			 clk     : in  std_logic;
			 mode    : in  std_logic_vector(1 downto 0);
			 ser_in  : in  std_logic;
			 par_in  : in  std_logic_vector((N - 1) downto 0);
			 par_out : out std_logic_vector((N - 1) downto 0));
	end component;
begin
	shift_reg_map:
	shift_register 
	generic map (N => 6)
	port map (not KEY(0), SW(8 downto 7), SW(6), SW(5 downto 0), LEDR);
end rtl;	