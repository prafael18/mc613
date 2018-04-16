library ieee;
use ieee.std_logic_1164.all;

entity clk_div is
  port (
    clk : in std_logic;
    clk_hz : out std_logic
  );
end clk_div;

architecture behavioral of clk_div is
--	signal count : std_logic_vector (25 downto 0);
begin
	process
	variable count : integer := 0;
	begin
	wait until clk'event and clk='1';
		if count = 50000000 then
			count := 0;
			clk_hz <= '1';
		else
			count := count + 1;
			clk_hz <= '0';
		end if;
	end process;
end behavioral;