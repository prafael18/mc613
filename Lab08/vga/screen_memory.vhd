library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity screen_memory is
  port (
    clk : in std_logic;
    data_in : in std_logic_vector(2 downto 0);
    data_out : out std_logic_vector(2 downto 0);
    reg_rd : in integer range 0 to 128*96-1;
    reg_wr : in integer range 0 to 128*96-1;
    we : in std_logic;
    clear : in std_logic
  );
end screen_memory;

architecture structural of screen_memory is
	
	component reg is 
	  generic (N : integer := 3);
	  port (
		 clk : in std_logic;
		 data_in : in std_logic_vector(N-1 downto 0);
		 data_out : out std_logic_vector(N-1 downto 0);
		 load : in std_logic; -- Write enable
		 clear : in std_logic
	  );
	end component;
	
	component zbuffer is
		port (x : in std_logic_vector(2 downto 0);
			e : in std_logic;
			f : out std_logic_vector(2 downto 0));
	end component;
	
	signal reg_rd_decoded: std_logic_vector (128*96-1 downto 0);
	signal reg_wr_decoded: std_logic_vector (128*96-1 downto 0);
	signal buffer_in: std_logic_vector (128*96*3-1 downto 0);
	signal load_vec: std_logic_vector(128*96-1 downto 0);
--	signal clear_vec: std_logic_vector(128*96-1 downto 0);
	
begin

	gen_wr_rd_dec:
	for i in 0 to 12287 generate
		reg_wr_decoded(i) <= '1' when reg_wr = i else '0';
		reg_rd_decoded(i) <= '1' when reg_rd = i else '0';
	end generate;

	gen_reg_bank: 
	for i in 0 to 12287 generate
		--if write is enabled and we should write to register i
		load_vec(i) <=  (reg_wr_decoded(i) and we);
--		clear_vec(i) <= (reg_wr_decoded(i) and clear);
		
		reg_map: reg
		generic map (N => 3)
		port map (clk, data_in, buffer_in ((i+1)*3-1 downto i*3), load_vec(i), clear);
		
		zbuffer_out: zbuffer
		port map (buffer_in((i+1)*3-1 downto i*3), reg_rd_decoded(i), data_out);

	end generate;

end structural;