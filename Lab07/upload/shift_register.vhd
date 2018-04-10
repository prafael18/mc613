library ieee;
use ieee.std_logic_1164.all;

entity shift_register is
generic (N : integer := 6);
port(
    clk     : in  std_logic;
    mode    : in  std_logic_vector(1 downto 0);
    ser_in  : in  std_logic;
    par_in  : in  std_logic_vector((N - 1) downto 0);
    par_out : out std_logic_vector((N - 1) downto 0)
  );
end shift_register;

architecture rtl of shift_register is
begin
	process
	variable tmp_out: std_logic_vector((N-1) downto 0);
	begin
		wait until clk'event and clk='1';
		if mode="11" then
			 tmp_out := par_in;
		elsif mode="01" then
			--shift-left
			left_gen: 
			for i in N-1 downto 1 loop
				tmp_out(i) := tmp_out(i-1);
			end loop;
			tmp_out(0) := ser_in;
		elsif mode="10" then
			--shift-right
			right_gen: 
			for i in 0 to N-2 loop
				tmp_out(i) := tmp_out(i+1);
			end loop;
			tmp_out(N-1) := ser_in;
		end if;
		par_out <= tmp_out;
	end process;
end rtl;