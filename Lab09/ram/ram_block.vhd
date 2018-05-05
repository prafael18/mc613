library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_block is
  port (
    Clock : in std_logic;
    Address : in std_logic_vector(6 downto 0);
    Data : in std_logic_vector(7 downto 0);
    Q : out std_logic_vector(7 downto 0);
    WrEn : in std_logic
  );
end ram_block;

architecture direct of ram_block is
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(7 downto 0);
	type memory_t is array((2**7)-1 downto 0) of word_t;

	-- Declare the RAM signal.	
	signal ram : memory_t;

	-- Register to hold the address 
	signal addr_reg : natural range 0 to (2**7)-1;
	
begin
	process(Clock)
	begin
	if(rising_edge(Clock)) then
		if(WrEn = '1') then
			ram(to_integer(unsigned(Address))) <= Data;
		end if;

		-- Register the address for reading
		addr_reg <= to_integer(unsigned(Address));
	end if;
	end process;

	Q <= ram(addr_reg);

  -- Your code here!
end direct;