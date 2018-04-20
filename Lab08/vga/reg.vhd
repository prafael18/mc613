library ieee;
use ieee.std_logic_1164.all;

entity reg is
  generic (
    N : integer := 3
  );
  port (
    clk : in std_logic;
    data_in : in std_logic_vector(N-1 downto 0);
    data_out : out std_logic_vector(N-1 downto 0);
    load : in std_logic; -- Write enable
    clear : in std_logic
  );
end reg;

architecture rtl of reg is
	signal zeros : std_logic_vector(N-1 downto 0);
begin
	gen_zeros: 
	for i in 0 to N-1 generate
		zeros(i) <= '0';
	end generate;
	process(clk, clear)
	begin
		if clear = '1' then
			data_out <= zeros;
		elsif clk'EVENT and clk = '1' then
			if load = '1' then 
				data_out <= data_in;
			end if;
		end if;
	end process;
end rtl;