LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ps2_mouse is
	port
	(
		------------------------	Clock Input	 	------------------------
		CLOCK_50	: 	in	STD_LOGIC;											--	50 MHz
		------------------------	PS2		--------------------------------
		PS2_DAT 	:		inout	STD_LOGIC;	      --	PS2 Data
		PS2_CLK	:		inout	STD_LOGIC;		--	PS2 Clock
		KEY		:		in STD_LOGIC_VECTOR(0 downto 0);
		left_click  : out std_logic;
		y_coord		: out integer range -2000 to 2000;
		x_coord 		: out integer range -2000 to 2000;
		newdata		: out std_logic
	);
end;

architecture struct of ps2_mouse is

	component mouse_ctrl
		generic(
			clkfreq : integer
		);
		port(
			ps2_data	:	inout	std_logic;
			ps2_clk		:	inout	std_logic;
			clk				:	in 	std_logic;
			en				:	in 	std_logic;
			resetn		:	in 	std_logic;
			newdata		:	out	std_logic;
			bt_on			:	out	std_logic_vector(2 downto 0);
			ox, oy		:	out std_logic;
			dx, dy		:	out	std_logic_vector(8 downto 0);
			wheel			: out	std_logic_vector(3 downto 0)
		);
	end component;
	
	--bt_on(0) is a left_click
	
	signal signewdata, resetn : std_logic;
	signal dx, dy : std_logic_vector(8 downto 0);
--	signal x, y 	: std_logic_vector(7 downto 0);
	signal x, y : integer range -2000 to 2000;
	signal button_click: std_logic_vector(2 downto 0);
	
	constant SENSIBILITY : integer := 16; -- Rise to decrease sensibility
begin 
	-- KEY(0) Reset
	resetn <= KEY(0);
	
	mousectrl : mouse_ctrl generic map (50000) port map(
		PS2_DAT, PS2_CLK, CLOCK_50, '1', '1',
		signewdata, button_click, ox => open, oy => open, dx => dx, dy => dy, wheel => open
	);
	
	-- Read new mouse data	
	process(signewdata, resetn)
		variable xacc, yacc : integer range -10000 to 10000;
	begin
		if(rising_edge(signewdata)) then			
			x <= x + ((xacc + to_integer(signed(dx))) / SENSIBILITY);
			y <= y + ((yacc + to_integer(signed(dy))) / SENSIBILITY);
			xacc := ((xacc + to_integer(signed(dx))) rem SENSIBILITY);
			yacc := ((yacc + to_integer(signed(dy))) rem SENSIBILITY);					
		end if;
		if resetn = '0' then
			xacc := 0;
			yacc := 0;
			x <= 0;
			y <= 0;
		end if;
	end process;

	x_coord <= x;
	y_coord <= y;
	left_click <= button_click(0);
	newdata <= signewdata;

end struct;
