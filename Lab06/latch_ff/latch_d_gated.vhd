library ieee;
use ieee.std_logic_1164.all;


entity latch_d_gated is
  port (
    D:   in  std_logic;
    Clk: in std_logic;
	 Q:  	out std_logic;
	 Q_n: out std_logic
  );
end latch_d_gated;

architecture structural of latch_d_gated is
begin
	process (D, Clk)
	variable tmp: std_logic;
	begin
		if Clk = '1' then
			tmp := D;
		end if;
		Q <= tmp;
		Q_n <= not(tmp);
	end process;
end structural;