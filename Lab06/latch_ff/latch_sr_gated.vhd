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
		SR := S & R;
		if Clk = '1' then
			case(SR) is
				when "01" => tmp := '0';
				when "10" => tmp := '1';
				when others =>	tmp := tmp;
			end case;
		end if;
		Q <= tmp;
		Q_n <= not(tmp);
	end process;
end structural;