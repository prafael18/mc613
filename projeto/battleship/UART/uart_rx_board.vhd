--------------------------------------------------------------------------------
-- PROJECT: SIMPLE UART FOR FPGA
--------------------------------------------------------------------------------
-- MODULE:  UART LOOPBACK EXAMPLE TOP MODULE
-- AUTHORS: Jakub Cabal <jakubcabal@gmail.com>
-- LICENSE: The MIT License (MIT), please read LICENSE file
-- WEBSITE: https://github.com/jakubcabal/uart_for_fpga
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- UART FOR FPGA REQUIRES: 1 START BIT, 8 DATA BITS, 1 STOP BIT!!!
-- OTHER PARAMETERS CAN BE SET USING GENERICS.

entity uart_rx_board is
  Generic (
     CLK_FREQ   : integer := 50e6;   -- system clock frequency in Hz
	  BAUD_RATE  : integer := 115200; -- baud rate value
	  PARITY_BIT : string  := "none"  -- legal values: "none", "even", "odd", "mark", "space"
  );
  port (
    CLOCK_50 : in std_logic;
    SW : in std_logic_vector(7 downto 0);
    KEY : in std_logic_vector(1 downto 0);
	 LEDR : out std_logic_vector(3 downto 0);
    HEX1, HEX0 : out std_logic_vector(6 downto 0);
	 GPIO_0 :inout std_logic_vector(35 downto 0)
	 );
end uart_rx_board;

architecture FULL of uart_rx_board is

	component bin2hex is
	port (SW: in std_logic_vector(3 downto 0);
			HEX0: out std_logic_vector(6 downto 0));
	end component;

	signal disp_out: std_logic_vector (7 downto 0);
	signal data_out: std_logic_vector (7 downto 0);
	signal data_send: std_logic;
	signal uart_txrx: std_logic;
--	signal uart_rx: std_logic;
	signal clk: std_logic;
	signal reset: std_logic;
	signal valid: std_logic; --don't care for now.
	
begin
--	
--	clk <= NOT KEY(0);

	reset <= NOT KEY(1);
	data_send <= NOT KEY(0);

	uart_i: entity work.UART
    generic map (
        CLK_FREQ    => CLK_FREQ,
        BAUD_RATE   => BAUD_RATE,
        PARITY_BIT  => PARITY_BIT
    )
    port map (
        CLK         => CLOCK_50,
        RST         => reset,  --Reset ativo em alta.
        -- UART INTERFACE
        UART_TXD    => GPIO_0(0),
        UART_RXD    => GPIO_0(1),
        -- USER DATA OUTPUT INTERFACE
        DATA_OUT    => data_out,
        DATA_VLD    => valid,
        FRAME_ERROR => LEDR(1),
        -- USER DATA INPUT INTERFACE
        DATA_IN     => SW(7 downto 0),
        DATA_SEND   => data_send,
        BUSY        => LEDR(2)
    );

	process(CLOCK_50)
		variable tmp: std_logic_vector(7 downto 0) := "00000000";
	begin
		if CLOCK_50'event and CLOCK_50 = '1' then
			if valid = '1' then
				tmp := data_out(7 downto 0);
			end if;
		end if;
		disp_out <= tmp;
	end process;
	
	hex_disp1: bin2hex port map (disp_out(7 downto 4), HEX1);
	hex_disp2: bin2hex port map (disp_out(3 downto 0), HEX0);
		 
end FULL;