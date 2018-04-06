library ieee;
use ieee.std_logic_1164.all;

entity alu is
  port (
    a, b : in std_logic_vector(3 downto 0);
    F : out std_logic_vector(3 downto 0);
    s0, s1 : in std_logic;
    Z, C, V, N : out std_logic
  );
end alu;

architecture behavioral of alu is
	signal s: std_logic_vector(1 downto 0);
	signal b_aux: std_logic_vector(3 downto 0);
	signal cin_aux: std_logic;
	signal cout_aux: std_logic;
	signal v_aux: std_logic;
	signal f_aux: std_logic_vector(3 downto 0);
	signal f_out: std_logic_vector(3 downto 0);
	
	component ripple_carry
		generic (N : integer :=4);
		port (
			x,y : in std_logic_vector(N-1 downto 0);
			r : out std_logic_vector(N-1 downto 0);
			cin : in std_logic;
			cout : out std_logic;
			overflow : out std_logic);
	end component;
	
begin
	
	
	ALU: ripple_carry 
		generic map (N => 4)
		port map(a, b_aux, f_aux, cin_aux, cout_aux, v_aux);					
		
	process (a, b, s0, s1)
	begin
		s <= s0 & s1;
		if s = "00" then 
				b_aux <= b;
				cin_aux <= '0';
				C <= cout_aux;
				V <= v_aux;
				N <= f_aux(3);
				f_out <= f_aux;
		elsif s = "10" then 
				b_aux <= not b;
				cin_aux <= '1';
				C <= cout_aux;
				V <= v_aux;
				N <= f_aux(3);
				f_out <= f_aux;
		elsif s = "01" then 
				f_out <= (a AND b);
				C <= '0';
				V <= '0';
				N <= '0';
		else 
				f_out <= (a OR b);
				C <= '0';
				V <= '0';
				N <= '0';
		end if;
		if f_out = "0000" then
			Z <= '1';
		else 
			Z <= '0';
		end if;
		F <= f_out;
	end process;
end behavioral;