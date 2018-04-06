library ieee;
use ieee.std_logic_1164.all;


entity latch_sr_nand is
  port (
    S_n:   in  std_logic;
    R_n:   in  std_logic;
    Qa :   out std_logic;
	 Qb :   out std_logic
  );
end latch_sr_nand;

architecture structural of latch_sr_nand is
begin
	process (S_n, R_n)
	variable tmp: std_logic;
	variable SR: std_logic_vector(1 downto 0);
	begin
		SR := S_n & R_n;
		case(SR) is 
			when "01" => tmp := '1';
			when "10" => tmp := '0';
			when others =>	tmp := tmp;
		end case;
		Qa <= tmp;
		Qb <= not(tmp);
	end process;
end structural;