library ieee;
use ieee.std_logic_1164.all;


entity latch_sr_nand is
  port (
    S_n:   in  std_logic;
    R_n:   in  std_logic;
    Qa :   out std_logic;
	 Qb :   out std_logic
  );
end latch_sr_nand;

architecture structural of latch_sr_nand is
	signal Qa_tmp: std_logic;
	signal Qb_tmp: std_logic;
begin
	Qa_tmp <= S_n nand Qb_tmp;
	Qb_tmp <= R_n nand Qa_tmp;
	
	Qa <= Qa_tmp;
	Qb <= Qb_tmp;
end structural;