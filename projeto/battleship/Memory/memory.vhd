-- Quartus Prime VHDL Template
-- True Dual-Port RAM with single clock
--
-- Read-during-write on port A or B returns newly written data
-- 
-- Read-during-write between A and B returns either new or old data depending
-- on the order in which the simulator executes the process statements.
-- Quartus Prime will consider this read-during-write scenario as a 
-- don't care condition to optimize the performance of the RAM.  If you
-- need a read-during-write between ports to return the old data, you
-- must instantiate the altsyncram Megafunction directly.

library ieee;
use ieee.std_logic_1164.all;

entity memory is

	generic 
	(
		DATA_WIDTH : natural := 8;
		ADDR_WIDTH : natural := 15;
		MIF_FILE   : string  := "Memory/initial_map.mif"
	);

	port 
	(
		clk		: in std_logic;
		addr_a	: in natural range 0 to 2**ADDR_WIDTH - 1;
		addr_b	: in natural range 0 to 2**ADDR_WIDTH - 1;
		data_a	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		data_b	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we_a	: in std_logic := '1';
		we_b	: in std_logic := '1';
		q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
		q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end memory;

architecture rtl of memory is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

	-- Declare the RAM 
	shared variable ram: memory_t;

	--Carrega arquivo MIF
	attribute ram_init_file: string;
	attribute ram_init_file of ram: variable is MIF_FILE;

	
begin


	-- Port A
	process(clk)
	begin
	if(rising_edge(clk)) then 
		if(we_a = '1') then
			ram(addr_a) := data_a;
		end if;
		q_a <= ram(addr_a);
	end if;
	end process;



	-- Port B 
	process(clk)
	begin
	if(rising_edge(clk)) then 
		if(we_b = '1') then
			ram(addr_b) := data_b;
		end if;
		q_b <= ram(addr_b);
	end if;
	end process;
	
end rtl;

---- Quartus Prime VHDL Template
---- Simple Dual-Port RAM with different read/write addresses but
---- single read/write clock
--
--library ieee;
--use ieee.std_logic_1164.all;
--
--entity memory is
--
--	generic 
--	(
--		DATA_WIDTH : natural := 8;
--		ADDR_WIDTH : natural := 6;
--		MIF_FILE : string := ""
--	);
--
--	port 
--	(
--		clk		: in std_logic;
--		raddr	: in natural range 0 to 2**ADDR_WIDTH - 1;
--		waddr	: in natural range 0 to 2**ADDR_WIDTH - 1;
--		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
--		we		: in std_logic := '1';
--		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
--	);
--
--end memory;
--
--architecture rtl of memory is
--
--	-- Build a 2-D array type for the RAM
--	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
--	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;
--
--	-- Declare the RAM signal.	
--	signal ram : memory_t;
--
--	--Carrega arquivo MIF
--	attribute ram_init_file: string;
--	attribute ram_init_file of ram: signal is MIF_FILE;
--
--begin
--
--	process(clk)
--	begin
--	if(rising_edge(clk)) then 
--		if(we = '1') then
--			ram(waddr) <= data;
--		end if;
--	end if;
--	end process;
--	
--	q <= ram(raddr);
--
--end rtl;