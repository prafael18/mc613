library ieee;
use ieee.std_logic_1164.all;

entity xbar_gen is
  port(s: in std_logic_vector (N-1 downto 0);
       y1, y2: out std_logic);
end xbar_gen;

architecture rtl of xbar_gen is
begin
  -- add your code
end rtl;

