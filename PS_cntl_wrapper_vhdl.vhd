----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:24:10 07/30/2012 
-- Design Name: 
-- Module Name:    PS_cntl_wrapper_vhdl - Behavioral 
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

--guide for data_arr
--...																							|bit ranges in data_arr|
--sel2 -->  if analog off [x1] if analog on [x3]		(11,8)
--sel3 -->  if analog off [x4] if analog on [x7]		(15,12)
--...
--sel6 --> [  start  ][ joy-R ][ joy-L  ][  select]		(27,24)
--sel7 --> [    left  ][ down][  right  ][    up   ]		(31,28)
--sel8 --> [   R1   ][   L1  ][   R2    ][   L2    ]			(35,32)
--sel9 --> [square][   X    ][   circle][triangle]		(39,36)
--selA --> Rjoystick x axis low nibble						(43,40)
--selB --> Rjoystick x axis high nibble						(47,44)
--selC --> Rjoystick y axis low nibble						(51,48)
--selD --> Rjoystick y axis high nibble						(55,52)
--selE --> Ljoystick x axis low nibble						(59,56)
--selF --> Ljoystick x axis high nibble						(63,60)
--sel10 --> Ljoystick y axis low nibble						(67,64)
--sel11 --> Ljoystick y axis high nibble						(71,68)


entity PS_cntl_wrapper_vhdl is
    Port (clock : in  STD_LOGIC;
           ps_dat_i : in  STD_LOGIC;
           ps_cmd_o : out  STD_LOGIC;
           ps_att_o : out  STD_LOGIC;
           ps_clk_o : out  STD_LOGIC;
           ps_data_arr_o : out  STD_LOGIC_VECTOR (71 downto 0));
end PS_cntl_wrapper_vhdl;

architecture Behavioral of PS_cntl_wrapper_vhdl is
	component PlaystationController is
		port (
			A_i :in std_logic_vector(7 downto 0);
			B_o :out std_logic_vector(7 downto 0);
			Data_arr_o: out std_logic_vector(71 downto 0);
			clock, reset, enable : in std_logic
		);
	end component PlaystationController; 
	signal ground : std_logic_vector(4 downto 0):= (others =>'0');
	signal high : std_logic := '1';
	signal low : std_logic := '0';
begin

ps_cntl: PlaystationController
	 port map (
			A_i(7) => ps_dat_i, 
			A_i(6 downto 0) => "0000000",	
			B_o(7) =>ps_cmd_o, 
			B_o(6) => ps_att_o, 
			B_o(5) => ps_clk_o,
			B_o(4 downto 0) => ground ,
			Data_arr_o => ps_data_arr_o,
			clock => clock,
			reset => low,
			enable => high
	);
low <= '0';
high <= '1';
end Behavioral;

