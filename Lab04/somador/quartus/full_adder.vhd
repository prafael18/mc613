library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
  port (
    x, y : in std_logic;
    r : out std_logic;
    cin : in std_logic;
    cout : out std_logic
  );
end full_adder;

architecture structural of full_adder is
begin
	r <= x XOR y XOR cin;
	cout <= (x AND y) OR (cin AND x) OR (Cin AND y);
end structural;
