library ieee;
use ieee.std_logic_1164.all;

entity fsm_table is
  port (
    clock : in std_logic;
	 reset: in std_logic;
	 w: in std_logic;
    z : out std_logic
  );
end fsm_table;

architecture behavioral of fsm_table is
	type state_type is (A, B, C, D);
	signal y: state_type;
begin
	process (reset, clock)
	begin
		if reset = '1' then y <= A;
		elsif clock'event and clock = '1' then
			case y is
				when A =>
					if w = '0' then y <= C;
					else y <= B;
					end if;
				when B =>
					if w = '0' then y <= D;
					else y <= C;
					end if;
				when C =>
					if w = '0' then y <= B;
					else y <= C;
					end if;
				when D =>
					if w = '0' then y <= A;
					else y <= C;
					end if;
			end case;
		end if;
	end process;
	
	process (y, w)
	begin
		case y is
			when A =>
				z <= '1';
			when B =>
				z <= not w;
			when C => 
				z <= '0';
			when D =>
				z <= w;
		end case;
	end process;
end behavioral;