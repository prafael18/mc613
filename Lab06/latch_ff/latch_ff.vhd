library ieee;
use ieee.std_logic_1164.all;


entity ff_d is
  port (
    D:   in  std_logic;
    Clk: in std_logic;
	 Q:  	out std_logic;
	 Q_n: out std_logic;
	 Preset: in std_logic;
	 Clear: in std_logic
  );
end ff_d;

architecture structural of ff_d is
begin
	process (D, Clk, Preset, Clear)
	variable tmp: std_logic;
	begin
		if clear = '1' then tmp := '0';
		elsif preset = '1' then tmp := '1';
		else
			if (Clk'event and Clk = '1') then
				tmp := D;
			end if;
		end if;
		Q <= tmp;
		Q_n <= not(tmp);
	end process;
end structural;


  lff5: ff_jk port map (
    J      => A,
    K      => B,
    Clk    => clock,
    Q      => Q(5), -- << CHANGE HERE
    Q_n    => open,
    Preset => preset,
    Clear  => clear
  );