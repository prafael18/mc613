library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity battleship is 
  port (    
    CLOCK_50                  : in  std_logic;
    KEY                       : in  std_logic_vector(0 downto 0);
    VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS            : out std_logic;
    VGA_BLANK_N, VGA_SYNC_N   : out std_logic;
    VGA_CLK                   : out std_logic
    );
end battleship;

architecture full of battleship is
	signal vga_rd_addr : natural range 0 to 2**15 - 1;
	signal tmp: std_logic_vector(7 downto 0);
	signal vga_data_in : std_logic_vector(7 downto 0);
	
begin

	map_parser: entity work.map_parser 
	port map (
		CLOCK_50,
		KEY,
		VGA_R, VGA_G, VGA_B,
		VGA_HS, VGA_VS,
		VGA_BLANK_N, VGA_SYNC_N,
		VGA_CLK,
      vga_data_in,
      vga_rd_addr);
		
 	main_memory: entity work.memory
	generic map
	  (DATA_WIDTH => 8,
		ADDR_WIDTH => 15,
		MIF_FILE   => "Memory/initial_map.mif")
	port map
	  (clk	=> CLOCK_50,
		raddr	=> vga_rd_addr,
		waddr => 0,
		data	=> "00000000",
		we		=> '0',
		q		=> vga_data_in);
		
--	main_memory: entity work.memory
--	generic map
--	  (DATA_WIDTH => 8,
--		ADDR_WIDTH => 15,
--		MIF_FILE => "Memory/initial_map.mif")
--	port map 
--	  (clk	 => CLOCK_50,
--		addr_a => vga_rd_addr,
--		addr_b => 0,
--		data_a => "00000000",
--		data_b => "00000000",
--		we_a 	 => '0',
--		we_b 	 => '0',
--		q_a	 => vga_data_in,
--		q_b 	 => tmp);
		
end full;