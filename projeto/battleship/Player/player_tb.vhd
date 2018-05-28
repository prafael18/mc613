--------------------------------------------------------------------------------
-- PROJECT: SIMPLE UART FOR FPGA
--------------------------------------------------------------------------------
-- MODULE:  TESTBANCH OF UART TOP MODULE
-- AUTHORS: Jakub Cabal <jakubcabal@gmail.com>
-- LICENSE: The MIT License (MIT), please read LICENSE file
-- WEBSITE: https://github.com/jakubcabal/uart_for_fpga
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity player_tb is
end player_tb;

architecture FULL of player_tb is

	signal CLK           : std_logic := '0';
	
	--Player signals
	signal mem_addr: natural range 0 to 2**15 - 1;
	signal mem_we : std_logic;
	signal mem_rd_data: std_logic_vector (7 downto 0);
	signal mem_wr_data: std_logic_vector (7 downto 0);
	signal uart_rd_data: std_logic_vector (7 downto 0);
	signal uart_wr_data: std_logic_vector (7 downto 0);
	signal uart_we: std_logic;
	signal uart_valid: std_logic;
	
	signal left_click : std_logic;
	signal mouse_pos_addr : integer range 0 to 2**15-1;
	
   constant clk_period  : time := 20 ns;
	constant uart_period : time := 8680.56 ns;

begin

	player: entity work.player
	port map
		(CLK,
		 '0',
		 left_click,
		 mouse_pos_addr,
		 uart_valid,
		 mem_rd_data,	uart_rd_data,
		 mem_wr_data, 	uart_wr_data,
 		 mem_we, 		uart_we,
 		 mem_addr
		 );

	clk_process : process
	begin
		CLK <= '0';
		wait for clk_period/2;
		CLK <= '1';
		wait for clk_period/2;
	end process;

	test_wait_turn : process
	begin
	
		wait until rising_edge(CLK);

		uart_valid <= '1';
		uart_rd_data <= "11111111";
		
		wait until rising_edge(CLK);
		
		left_click <= '0';
		
		wait until rising_edge(CLK);
		
		left_click <= '1';
		
		wait until rising_edge(CLK);
		
		left_click <= '0';
		
		wait until rising_edge(CLK);
		
		mem_rd_data <= "00000010";
		
		wait until rising_edge(CLK);
		
		

		wait;
		
		
	end process;

end FULL;