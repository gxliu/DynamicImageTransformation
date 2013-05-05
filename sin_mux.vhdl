library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity sin_mux is
	 port (
		 theta_i : in std_logic_vector(4 downto 0);--The radian angle
		 val_i: in std_logic_vector(9 downto 0);--the value that will multiply the sin(theta)
		 result_o: out std_logic_vector(9 downto 0)
		 );
end entity sin_mux;
architecture calc of sin_mux is
	signal result_s,result_ss: std_logic_vector(9 downto 0):=(others => '0');
	signal theta_mux2mult_s,
				val_pad_s: std_logic_vector(19 downto 0):=(others => '0');
	signal multiplied_s :std_logic_vector(39 downto 0):=(others => '0');
begin
	with theta_i(3 downto 0) select theta_mux2mult_s(19 downto 0) <= 	
								x"00000"	when x"0",
								x"00"&"00"&x"32"&"00"	when x"1",
								x"00"&"00"&x"62"&"00"	when x"2",
								x"00"&"00"&x"8e"&"00"	when x"3",
								x"00"&"00"&x"B5"&"00"	when x"4",
								x"00"&"00"&x"d4"&"11"	when x"5",
								x"00"&"00"&x"ec"&"10"	when x"6",
								x"00"&"00"&x"fb"&"00"	when x"7",
								x"00400"	when x"8",
								x"00"&"00"&x"fb"&"00"	when x"9",
								x"00"&"00"&x"ec"&"10"	when x"a",
								x"00"&"00"&x"d4"&"11"	when x"b",
								x"00"&"00"&x"b5"&"00"	when x"c",
								x"00"&"00"&x"8e"&"00"	when x"d",
								x"00"&"00"&x"62"&"00"	when x"e",
								x"00"&"00"&x"32"&"00"	when x"f",
								x"00000"	when others;
---
--theta_mux2mult_s(19 downto 10) <= (others => '0');
val_pad_s(9 downto 0) <= (others => '0');
val_pad_s(19 downto 10) <= (val_i) when (val_i(val_i'length-1) = '0') else
										   ((not val_i) +1) ; -- make it positive to get the multiplication correct
---
Multiplied_s <= (theta_mux2mult_s*val_pad_s);
result_ss <= multiplied_s(29 downto 20);
with theta_i(4) select result_s <=
						result_ss when '0',
						(not result_ss )+ 1 when '1',
						x"00"&"00" when others;

result_o <= result_s when (val_i(val_i'length-1) = '0') else
					((not result_s) + 1) ; -- since val_i is a negative, it was fliped posative before entry.  Now it needs to flipped back negative
	
end calc;
