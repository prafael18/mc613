library ieee;
use ieee.std_logic_1164.all;


entity ff_jk is
  port (
    J:   in  std_logic;
	 K:	in std_logic;
    Clk: in std_logic;
	 Q:  	out std_logic;
	 Q_n: out std_logic;
	 Preset: in std_logic;
	 Clear: in std_logic
  );
end ff_jk;

architecture structural of ff_jk is
begin
	process (J, K, Clk, Preset, Clear)
	variable tmp: std_logic;
	variable JK: std_logic_vector (1 downto 0);
	begin
		JK := J & K;
		if (Clk'event and Clk = '1') then
			if clear = '1' then tmp := '0';
			elsif preset = '1' then tmp := '1';
			else
				case(JK) is 
					when "11" => tmp := not(tmp);
					when "10" => tmp := '1';
					when "01" => tmp := '0';
					when others => tmp := tmp;
				end case;
			end if;
		end if;
		Q <= tmp;
		Q_n <= not(tmp);
	end process;
end structural;