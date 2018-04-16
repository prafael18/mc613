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
	shared variable y_prev : state_type := A;
begin
	process (reset, clock)
	begin
		if reset = '1' then y <= A;
		elsif clock'event and clock = '1' then
			y_prev := y;
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
			when C =>
				if y_prev = A or y_prev = D then
					z <= '1';
				else
					z <= '0';
				end if;
			when A =>
				z <= '0';
			when D => 
				z <= '1';
			when B =>
				if y_prev = C then
					z <= '0';
				else
					z <= '1';
				end if;
		end case;
	end process;
end behavioral;