library ieee;
use ieee.std_logic_1164.all;


entity latch_sr_gated is
  port (
    S:   in  std_logic;
    R:   in  std_logic;
    Clk: in std_logic;
	 Q:  	out std_logic;
	 Q_n: out std_logic
  );
end latch_sr_gated;

architecture structural of latch_sr_gated is
begin
	process (S, R, Clk)
	variable tmp: std_logic;
	variable SR: std_logic_vector(1 downto 0);
	begin
		if Clk = '1' then
			SR := S & R;
			if SR = "01" then
				Q <= '0';
				Q_n <= '1';
			elsif SR = "10" then
				Q <= '1';
				Q_n <= '0';
			end if;
		end if;
	end process;
end structural;