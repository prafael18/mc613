library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity player  is
	port(
		CLOCK_50 : in std_logic;
		reset:	in std_logic;
		left_click: in std_logic;
		right_click: in std_logic;
		mouse_pos_addr: in integer;
		uart_valid : in std_logic;
		mem_rd_data, uart_rd_data: in std_logic_vector(7 downto 0);
		mem_wr_data, uart_wr_data: out std_logic_vector(7 downto 0);
		mem_we, uart_we: out std_logic;
		mem_addr: out natural range 0 to 2**15-1;
		game_over: out std_logic;
		player_won: out std_logic
	);
end player;

architecture behavior of player is	
	type state_type is (wait_turn, wait_read, read_hit, wait_click, val_click, upd_map, end_game);
	signal y: state_type := wait_click;  --CHANGE HERE!
	
	signal clean_memory: std_logic;
	
	constant MAX_SHIPS : integer := 5; --CHANGE HERE (default should be 20).
begin
	process(reset, CLOCK_50)
		variable ally_ships_hit : integer := 0;
		variable enemy_ships_hit: integer := 0;
		
		variable wait_pulse : integer := 0;
		variable click_addr : integer := 0;
	begin
		if CLOCK_50'event and CLOCK_50 = '1' then
			if reset = '1' then y <= wait_click; --CHANGE HERE
			else
				case y is
					when wait_turn =>
						if uart_valid = '1' then
							y <= wait_read;
						else
							y <= wait_turn;
						end if;
					when wait_read => -- waits for a clock pulse.
						y <= read_hit;
					when read_hit =>
						if mem_rd_data(0) = '1' then --ship
							ally_ships_hit := ally_ships_hit + 1;
							if ally_ships_hit = MAX_SHIPS then
								y <= end_game;
							else
								y <= wait_turn; -- wait for other player to finish turn
							end if;
						else
							y <= wait_click; -- now its my turn and we wait for a click
						end if;
					when wait_click =>
						if left_click = '1' then 
							y <= val_click;
						else 
							y <= wait_click;
						end if;
					when val_click =>
						y <= upd_map; -- waits for data to be read
					when upd_map =>
						if not (mem_rd_data(2) = '1') and not (mem_rd_data(3) = '1') then
							if mem_rd_data(0) = '1' then
								enemy_ships_hit := enemy_ships_hit + 1;
								if enemy_ships_hit = MAX_SHIPS then
									y <= end_game;
								else
									y <= wait_click; --ship
								end if;
							else
								y <= wait_turn; --water
							end if;
						else
							y <= wait_click;
						end if;
					when end_game =>
						if right_click = '1' then
							y <= wait_click;	--CHANGE HERE TO RESTART AFTERWARDS! 
						else
							y <= end_game;
						end if;
--					when restart =>
--						if clean_memory = '1' then
--							y <= wait_click; --CHANGE HERE (in case of player2 we should go to wait_turn)
--						else
--							y <= restart;
--						end if;
				end case;
			end if;
		end if;
	end process;
			
	
	process(y, mem_rd_data, uart_rd_data)
		variable ally_ships_hit : integer := 0;
		variable enemy_ships_hit: integer := 0;

		variable array_i : integer := 0;
		variable wait_pulse: integer := 0;
		
		variable uart_addr_var : integer range 0 to 2**15-1 := 0;
		variable mouse_addr_var: integer range 0 to 2**15-1 := 0;
		variable mem_wr_var: std_logic_vector(7 downto 0);
		variable uart_wr_var: std_logic_vector(7 downto 0);
		variable game_over_var: std_logic_vector(1 downto 0);
	begin
		mem_we <= '0';
		mem_wr_data <= "00000000";
		mem_addr <= 100; --Unused address
		uart_we <= '0';
		uart_wr_data <= "00000000";
		game_over <= '0';
		player_won <= '0';
		clean_memory <= '0';
		case y is
			when wait_turn =>
				uart_wr_data <= uart_wr_var;
				if uart_valid = '1' then
					uart_addr_var := to_integer(unsigned(uart_rd_data));
					mem_addr <= uart_addr_var;
				end if;
			when wait_read => 
				mem_addr <= uart_addr_var; --Waits for read to complete.
			when read_hit =>
				mem_addr <= uart_addr_var;
				mem_we <= '1';
					if mem_rd_data(0) = '1' then -- is ship
						ally_ships_hit := ally_ships_hit + 1;
						mem_wr_data <= "00000101";
						if ally_ships_hit = MAX_SHIPS then --Enemy won
							game_over <= '1';
							player_won <= '1';
						end if;
					else
						mem_wr_data <= "00001010";
					end if;	
			when wait_click =>
				uart_wr_data <= uart_wr_var;
				mouse_addr_var := mouse_pos_addr;
				mem_addr <= 128 + mouse_addr_var;
			when val_click =>
				mem_addr <= 128 + mouse_addr_var;
			when upd_map =>
				mem_addr <= 128 + mouse_addr_var;
				if not (mem_rd_data(2) = '1') and not (mem_rd_data(3) = '1') then
					if mem_rd_data(0) = '1' then
						enemy_ships_hit := enemy_ships_hit + 1;
						mem_wr_var := "00000101"; --ship
						if enemy_ships_hit = MAX_SHIPS then --We won!
							game_over <= '1';
							player_won <= '0';
						end if;
					else
						mem_wr_var := "00001010"; --water
					end if;
					uart_wr_var := std_logic_vector(to_unsigned(mouse_addr_var, uart_wr_var'length));
					mem_wr_data <= mem_wr_var;
					uart_wr_data <= uart_wr_var;
					mem_we <= '1';
					uart_we <= '1';
				end if;
			when end_game =>
				if enemy_ships_hit = MAX_SHIPS then 
					player_won <= '0'; --We won
 				else
					player_won <= '1'; --Enemy won
				end if;
				
				if right_click = '1' then
					game_over <= '0';
				end if;
				game_over <= '1';
--			when restart =>
--				if array_i < 200 then
--					if array_i < 100 then
--						mem_addr <= array_i;
--					else
--						mem_addr <= 128 + (array_i-100);
--					end if;
--					if wait_pulse = 0 then
--						wait_pulse := wait_pulse + 1;
--					else --Data has already been read
--						mem_we <= '1';
--						if mem_rd_data(0) = '1' then -- is ship
-- 							mem_wr_data <= "00000001";
--						else
--							mem_wr_data <= "00000010";
--						end if;
--						array_i := array_i + 1;
--						wait_pulse := 0;
--					end if;
--				else
--					clean_memory <= '1';
--					array_i := 0;
--				end if;
		end case;
	end process;

end behavior;
