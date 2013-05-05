----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:43:08 05/12/2012 
-- Design Name: 
--------------------------------------------------------------------------
-- Module Name:    PES_clock - Behavioral 
--------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity PES_clock is
	 generic (max_cnt: natural:= 500000); -- max_cnt = (period * clock_in_speed)/2
    Port ( clock_in : in  STD_LOGIC;
           clock_out : out  STD_LOGIC);
end PES_clock;
architecture Behavioral of PES_clock is
	
begin
	clk: process(clock_in)
		variable cnt: Integer range 0 to max_cnt := 0;
		variable clock_signal: std_logic:= '0';
	begin
		if(clock_in= '1' and clock_in'event) then
			
			if (cnt >= max_cnt-1) then
				clock_signal := not clock_signal;
				cnt := 0;
			else
				cnt := cnt + 1;
			end if;
		end if;
		clock_out <= clock_signal;
	end process;
end Behavioral;
--------------------------------------------------------------------------