library ieee;
use ieee.std_logic_1164.all;
	
entity bank is
  generic (WORDSIZE : natural := 32);
  port (
    WR_EN, RD_EN,
			clear,
			clock		: IN 	STD_LOGIC;
			WR_ADDR,
			RD_ADDR1,
			RD_ADDR2	: IN	STD_LOGIC_VECTOR (4 DOWNTO 0);
			DATA_IN		: IN	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
			DATA_OUT1,
			DATA_OUT2	: OUT	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0)
  );
end bank;

architecture structural of bank is
	
	component reg is
	generic (WORDSIZE	: natural := 32);
	port (
		clock,
		load,
		clear	: in	std_logic;
		datain	: in	std_logic_vector(WORDSIZE-1 downto 0);
		dataout : out	std_logic_vector(WORDSIZE-1 downto 0)
	);
	end component;
	
	component dec5_to_32 is
	  port(w: in std_logic_vector(4 downto 0);
			 y: out std_logic_vector(31 downto 0));
	end component;
	
	component zbuffer is
		port (x : in std_logic_vector(31 downto 0);
			e : in std_logic;
			f : out std_logic_vector(31 downto 0));
	end component;
	
	signal RD_ENg_rd1_decoded: std_logic_vector (WORDSIZE-1 downto 0);
	signal RD_ENg_rd2_decoded: std_logic_vector (WORDSIZE-1 downto 0);
	signal RD_ENg_wr_decoded: std_logic_vector (WORDSIZE-1 downto 0);
	signal buffer_in: std_logic_vector ((32*WORDSIZE)-1 downto 0);
	
	signal load_vec: std_logic_vector(WORDSIZE-1 downto 0);
	signal clear_vec: std_logic_vector(WORDSIZE-1 downto 0);
	signal RD_ENad1_vec: std_logic_vector(WORDSIZE-1 downto 0);
	signal RD_ENad2_vec: std_logic_vector(WORDSIZE-1 downto 0);
begin

	RD_ENg_rd1_dec: dec5_to_32 port map (rd_addr1, RD_ENg_rd1_decoded);
	RD_ENg_rd2_dec: dec5_to_32 port map (rd_addr2, RD_ENg_rd2_decoded);
	RD_ENg_wr_dec: dec5_to_32 port map (wr_addr, RD_ENg_wr_decoded);

	gen_RD_ENg_bank: 
	for i in 0 to 31 generate
		--if write is enabled and WR_EN should write to RD_ENgister i
		load_vec(i) <=  (RD_ENg_wr_decoded(i) and WR_EN);
		RD_ENad1_vec(i) <= (RD_ENg_rd1_decoded(i) and RD_EN);
		RD_ENad2_vec(i) <= (RD_ENg_rd2_decoded(i) and RD_EN);
		
		clear_vec(i) <= (RD_ENg_wr_decoded(i) and clear);
		
		RD_ENg_map: reg
		generic map (WORDSIZE => 32)
		port map (clock, load_vec(i), clear_vec(i), data_in, buffer_in ((i+1)*32-1 downto i*32));
		
		zbuffer1_out: zbuffer
		port map (buffer_in((i+1)*32-1 downto i*32), RD_ENg_rd1_decoded(i), data_out1);
		
		zbuffer2_out: zbuffer
		port map (buffer_in((i+1)*32-1 downto i*32), RD_ENg_rd2_decoded(i), data_out2);

	end generate;

end structural;