library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock is
  port (
    clk : in std_logic;
    decimal : in std_logic_vector(3 downto 0);
    unity : in std_logic_vector(3 downto 0);
    set_hour : in std_logic;
    set_minute : in std_logic;
    set_second : in std_logic;
    hour_dec, hour_un : out std_logic_vector(6 downto 0);
    min_dec, min_un : out std_logic_vector(6 downto 0);
    sec_dec, sec_un : out std_logic_vector(6 downto 0)
  );
end clock;

architecture rtl of clock is
  component clk_div is
    port (
      clk : in std_logic;
      clk_hz : out std_logic
    );
  end component;
  
	component bin2dec is
		port (SW: in std_logic_vector(3 downto 0);
				HEX0: out std_logic_vector(6 downto 0));
	end component;

	signal clk_hz : std_logic;
	signal sig_hour_dec, sig_hour_un : std_logic_vector (3 downto 0);
	signal sig_min_dec, sig_min_un : std_logic_vector (3 downto 0);
	signal sig_sec_dec, sig_sec_un : std_logic_vector (3 downto 0);
	
begin
	clock_divider : clk_div port map (clk, clk_hz);
	
	process
		variable var_set_sec_un  : std_logic_vector(3 downto 0) := "0000";
		variable var_set_sec_dec : std_logic_vector(3 downto 0) := "0000";
		variable var_set_min_un  : std_logic_vector(3 downto 0) := "0000";
		variable var_set_min_dec : std_logic_vector(3 downto 0) := "0000";
		variable var_set_hour_un : std_logic_vector(3 downto 0) := "0000";
		variable var_set_hour_dec: std_logic_vector(3 downto 0) := "0000";
		
		variable un_tmp : std_logic_vector(3 downto 0) := "0000";
		variable dec_tmp: std_logic_vector(3 downto 0) := "0000";
	begin
		wait until clk'event and clk = '1';
		if set_hour='1' then
			un_tmp  := unity;
			dec_tmp := decimal;
			if (dec_tmp = "0010" and un_tmp <= "0011") or (dec_tmp <= "0001" and un_tmp <= "1001") then
				var_set_hour_un  := un_tmp;
				var_set_hour_dec := dec_tmp;
			end if;
		elsif set_minute = '1' then
			un_tmp := unity;
			dec_tmp := decimal;
			if dec_tmp <= "0101" and un_tmp <= "1001" then
				var_set_min_un  := un_tmp;
				var_set_min_dec := dec_tmp;
			end if;
		elsif set_second = '1' then
			un_tmp := unity;
			dec_tmp := decimal;
			if dec_tmp <= "0101" and un_tmp <= "1001" then
				var_set_sec_un  := un_tmp;
				var_set_sec_dec := dec_tmp;
			end if;
		elsif clk_hz = '1' then
			var_set_sec_un := std_logic_vector(unsigned(var_set_sec_un) + 1 );
			if var_set_sec_un = "1010" then
				var_set_sec_un := "0000";
				var_set_sec_dec := std_logic_vector(unsigned(var_set_sec_dec) + 1 );
			end if;
			
			if var_set_sec_dec = "0110" then
				var_set_sec_dec := "0000";
				var_set_min_un := std_logic_vector(unsigned(var_set_min_un) + 1 );
			end if;
			
			if var_set_min_un = "1010" then
				var_set_min_un := "0000";
				var_set_min_dec := std_logic_vector(unsigned(var_set_min_dec) + 1 );
			end if;
			
			if var_set_min_dec = "0110" then
				var_set_min_dec := "0000";
				var_set_hour_un := std_logic_vector(unsigned(var_set_hour_un) + 1 );
			end if;
			
			if var_set_hour_un = "1010" then
				var_set_hour_un := "0000";
				var_set_hour_dec := std_logic_vector(unsigned(var_set_hour_dec) + 1 );
			end if;
				
			if var_set_hour_dec = "0010" and var_set_hour_un = "0100" then
				var_set_hour_un := "0000";
				var_set_hour_dec := "0000";
			end if;
		end if;
		sig_sec_un <= var_set_sec_un;
		sig_sec_dec <= var_set_sec_dec;
		sig_min_un <= var_set_min_un;
		sig_min_dec <= var_set_min_dec;
		sig_hour_un <= var_set_hour_un;
		sig_hour_dec <= var_set_hour_dec;
	end process;
	

	
	sec_un_map: bin2dec port map (sig_sec_un, sec_un);
	sec_dec_map: bin2dec port map (sig_sec_dec, sec_dec);
	min_un_map: bin2dec port map (sig_min_un, min_un);
	min_dec_map: bin2dec port map (sig_min_dec, min_dec);
	hour_un_map: bin2dec port map (sig_hour_un, hour_un);
	hour_dec_map: bin2dec port map (sig_hour_dec, hour_dec);

end rtl;