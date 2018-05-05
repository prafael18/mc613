library ieee;
use ieee.std_logic_1164.all;

entity ram is
  port (
    Clock : in std_logic;
    Address : in std_logic_vector(9 downto 0);
    DataIn : in std_logic_vector(31 downto 0);
    DataOut : out std_logic_vector(31 downto 0);
    WrEn : in std_logic
  );
end ram;

architecture rtl of ram is

	component ram_block is
	  port (
		 Clock : in std_logic;
		 Address : in std_logic_vector(6 downto 0);
		 Data : in std_logic_vector(7 downto 0);
		 Q : out std_logic_vector(7 downto 0);
		 WrEn : in std_logic
	  );
	end component;

	signal val_addr : std_logic;
	signal we1, we2 : std_logic;
 	signal data_out_1, data_out_2 : std_logic_vector(31 downto 0);
	signal high_z : std_logic_vector (31 downto 0);
begin
	
	val_addr <= '1' when (Address(9) = '0' and Address(8) = '0') else '0';
	
	we1 <= val_addr and WrEn and not Address(7);
	we2 <= val_addr and WrEn and Address(7);
	

	gen_ram_256_by_4B:	
	for i in 0 to 7 generate
		lower_addr: 
		if i < 4 generate
			lower_addr_port:
			ram_block port map (Clock, Address(6 downto 0), DataIn((4-i)*8-1  downto (3-i)*8), data_out_1((4-i)*8-1  downto (3-i)*8), we1);
		end generate;
		higher_addr:
		if i >= 4 generate
			higher_addr_port:
			ram_block port map (Clock, Address(6 downto 0), DataIn((8-i)*8-1  downto (7-i)*8), data_out_2((8-i)*8-1  downto (7-i)*8), we2);
		end generate;
	end generate;
	
	DataOut <= data_out_1 when (val_addr = '1' and Address(7) = '0') else
				  data_out_2 when (val_addr = '1' and Address(7) = '1') else
				  (others => 'Z');		  
end rtl;