library ieee;
use ieee.std_logic_1164.all;

entity register_bank is
  port (
    clk : in std_logic;
    data_in : in std_logic_vector(3 downto 0);
    data_out : out std_logic_vector(3 downto 0);
    reg_rd : in std_logic_vector(2 downto 0);
    reg_wr : in std_logic_vector(2 downto 0);
    we : in std_logic;
    clear : in std_logic
  );
end register_bank;

architecture structural of register_bank is
	
	component reg is 
	  generic (N : integer := 4);
	  port (
		 clk : in std_logic;
		 data_in : in std_logic_vector(N-1 downto 0);
		 data_out : out std_logic_vector(N-1 downto 0);
		 load : in std_logic; -- Write enable
		 clear : in std_logic
	  );
	end component;
	
	component dec3_to_8 is
	  port(w: in std_logic_vector(2 downto 0);
       y: out std_logic_vector(7 downto 0));
	end component;
	
	component zbuffer is
		port (x : in std_logic_vector(3 downto 0);
			e : in std_logic;
			f : out std_logic_vector(3 downto 0));
	end component;
	
	signal reg_rd_decoded: std_logic_vector (7 downto 0);
	signal reg_wr_decoded: std_logic_vector (7 downto 0);
	signal f_in: std_logic_vector (3 downto 0);
	signal load_i: std_logic;
	signal clear_i: std_logic;
	
begin

	reg_rd_dec: dec3_to_8 port map (reg_rd, reg_rd_decoded);
	reg_wr_dec: dec3_to_8 port map (reg_wr, reg_wr_decoded);
	
	gen_reg_bank: 
	for i in 0 to 7 generate
		--if write is enabled and we should write to register i
		load_i <= (reg_wr_decoded(i) and we);
		clear_i <= reg_wr_decoded(i) and clear;
		
		reg_map: reg
		generic map (N => 4)
		port map (clk, data_in, f_in, load_i, clear_i);
		
		zbuffer_out: zbuffer
		port map (f_in, not(reg_rd_decoded(i)), data_out);

	end generate;

end structural;