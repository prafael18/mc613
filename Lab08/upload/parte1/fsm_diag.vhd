library ieee;
use ieee.std_logic_1164.all;

entity fsm_diag is
  port (
    clock : in std_logic;
	 reset: in std_logic;
	 w: in std_logic;
    z : out std_logic
  );
end fsm_diag;

architecture behavioral of fsm_diag is
	type state_type is (A, B, C, D);
	signal y: state_type;
begin
	process (reset, clock)
	begin
		if reset = '1' then y <= A;
		elsif clock'event and clock = '1' then
			case y is
				when A =>
					if w = '0' then y <= A;
					else y <= B;
					end if;
				when B =>
					if w = '0' then y <= C;
					else y <= B;
					end if;
				when C =>
					if w = '0' then y <= C;
					else y <= D;
					end if;
				when D =>
					if w = '0' then y <= A;
					else y <= D;
					end if;
			end case;
		end if;
	end process;
	 z <= '1' when y = B else '0';
end behavioral;