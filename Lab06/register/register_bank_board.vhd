library ieee;
use ieee.std_logic_1164.all;

entity register_bank_board is
	port (SW: in std_logic_vector(9 downto 0);
			KEY: in std_logic_vector(2 downto 0);
			HEX0: out std_logic_vector(6 downto 0));
end register_bank_board;

architecture structural of register_bank_board is

	component register_bank
		  port (
			 clk : in std_logic;
			 data_in : in std_logic_vector(3 downto 0);
			 data_out : out std_logic_vector(3 downto 0);
			 reg_rd : in std_logic_vector(2 downto 0);
			 reg_wr : in std_logic_vector(2 downto 0);
			 we : in std_logic;
			 clear : in std_logic);
	end component;
	
	component bin_2_hex is
		port (x: in std_logic_vector(3 downto 0);
			hex: out std_logic_vector(6 downto 0));
	end component;

	signal reg_bank_out: std_logic_vector (3 downto 0);
begin
	reg_bank:
	register_bank port map (not KEY(0), SW(3 downto 0), reg_bank_out, 
				 SW(6 downto 4), SW(9 downto 7), not KEY(1), not KEY(2));
	hex_disp:
	bin_2_hex port map (reg_bank_out, HEX0);
end structural;