----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:20:05 12/05/2011 
-- Design Name: 
-- Module Name:    data_path_rxd - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_path_rxd is
	generic(word_size: natural:= 8);
    Port ( clk,rst,load, rxd: in  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (word_size-1 downto 0));
end data_path_rxd;

architecture Behavioral of data_path_rxd is
	signal reg : std_logic_vector( word_size-1 downto 0):= (others => '0') ;
	--signal d7,d6,d5,d4,d3,d2,d1,d0: std_logic:= '0';
begin
	
	process(clk,rst,load,rxd, reg)
	begin
		if (rst = '1') then reg <= (others => '0');
		elsif( clk'event AND clk = '1') then
			if(rst = '0' AND load = '1') then
			reg <= RXD&reg(word_size-1 downto 1);
			end if;
		end if;
	data_out <= reg;
	end process;
end Behavioral;

