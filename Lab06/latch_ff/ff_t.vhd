library ieee;
use ieee.std_logic_1164.all;


entity ff_t is
  port (
    T:   in  std_logic;
    Clk: in std_logic;
	 Q:  	out std_logic;
	 Q_n: out std_logic;
	 Preset: in std_logic;
	 Clear: in std_logic
  );
end ff_t;

architecture structural of ff_t is
begin
	process (T, Clk, Preset, Clear)
	variable tmp: std_logic;
	begin
		if (Clk'event and Clk = '1') then
			if clear = '1' then tmp := '0';
			elsif preset = '1' then tmp := '1';
			else
				case (T) is
					when '0' => tmp := tmp;
					when others => tmp := not tmp;
				end case;
			end if;
		end if;
		Q <= tmp;
		Q_n <= not(tmp);
	end process;
end structural;
