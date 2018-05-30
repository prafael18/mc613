library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity battleship_p2 is 
  port (    
    CLOCK_50                  : in  std_logic;
    KEY                       : in  std_logic_vector(0 downto 0);
	 PS2_DAT 	:		inout	STD_LOGIC;	      --	PS2 Data
    PS2_CLK	:		inout	STD_LOGIC;		--	PS2 Clock
    VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS            : out std_logic;
    VGA_BLANK_N, VGA_SYNC_N   : out std_logic;
    VGA_CLK                   : out std_logic;
	 GPIO_0							: inout std_logic_vector (35 downto 0);
    LEDR								: out std_logic_vector(9 downto 0));
end battleship_p2;

architecture full of battleship_p2 is
	--VGA signals
	signal vga_rd_addr : natural range 0 to 2**15 - 1;
	signal vga_data_in : std_logic_vector(7 downto 0);
	
	--Mouse signals
	signal left_click : std_logic;
	signal right_click: std_logic;
	signal y_coord : integer;
	signal x_coord : integer;
	
	--Map parser signals
	signal mouse_newdata: std_logic;
	signal mouse_pos_addr: integer;
	
	--Player signals
	signal mem_addr: natural range 0 to 2**15 - 1;
	signal mem_we : std_logic;
	signal mem_rd_data: std_logic_vector (7 downto 0);
	signal mem_wr_data: std_logic_vector (7 downto 0);
	signal uart_rd_data: std_logic_vector (7 downto 0);
	signal uart_wr_data: std_logic_vector (7 downto 0);
	signal uart_we: std_logic;
	signal uart_valid: std_logic;
	signal game_over: std_logic;
	signal player_won: std_logic;
	
	signal hexdata : std_logic_vector(15 downto 0);
	signal mouse_pos_addr_log : std_logic_vector(7 downto 0);

begin


--	LEDR(7) <= '0' when game_over = '0' else '1';
--	LEDR(8) <= '1' when player_won = '1' else '0';
--	LEDR(9) <= '1' when player_won = '0' else '0';
	
	uart_i: entity work.UART
	generic map (
	  CLK_FREQ    => 50e6,
	  BAUD_RATE   => 115200,
	  PARITY_BIT  => "none"
	)
	port map (
	  CLK         => CLOCK_50,
	  RST         => '0',  --Reset ativo em alta.
	  -- UART INTERFACE
	  UART_TXD    => GPIO_0(0),  --CHANGE HERE!
	  UART_RXD    => GPIO_0(1),  --CHANGE HERE!
	  -- USER DATA OUTPUT INTERFACE
	  DATA_OUT    => uart_rd_data,
	  DATA_VLD    => uart_valid,
	  FRAME_ERROR => LEDR(1),
	  -- USER DATA INPUT INTERFACE
	  DATA_IN     => uart_wr_data,
	  DATA_SEND   => uart_we,
	  BUSY        => LEDR(2)
	);
 
	player: entity work.player
	port map
		(CLOCK_50,
		 not KEY(0),
		 left_click,
		 right_click,
		 mouse_pos_addr,
		 uart_valid,
		 mem_rd_data,	uart_rd_data,
		 mem_wr_data, 	uart_wr_data,
 		 mem_we, 		uart_we,
 		 mem_addr,
		 game_over, player_won
		 );

	mouse: entity work.ps2_mouse
	port map
	  (CLOCK_50,
		PS2_DAT,
		PS2_CLK,
		KEY,
		left_click,
		right_click,
		y_coord,
		x_coord,
		mouse_newdata);
	
	map_parser: entity work.map_parser 
	port map (
		CLOCK_50,
		KEY,
		VGA_R, VGA_G, VGA_B,
		VGA_HS, VGA_VS,
		VGA_BLANK_N, VGA_SYNC_N,
		VGA_CLK,
      vga_data_in,
      vga_rd_addr,
		y_coord,
		x_coord,
		mouse_newdata,
		mouse_pos_addr,
		game_over, player_won);
		
	main_memory: entity work.memory
	generic map
	  (DATA_WIDTH => 8,
		ADDR_WIDTH => 15,
		MIF_FILE => "Memory/initial_map_p2.mif") ---CHANGE HERE!
	port map 
	  (clk	 => CLOCK_50,
		addr_a => vga_rd_addr,
		addr_b => mem_addr,
		data_a => "00000000",
		data_b => mem_wr_data,
		we_a 	 => '0',
		we_b 	 => mem_we,
		q_a	 => vga_data_in,
		q_b 	 => mem_rd_data);
		
end full;