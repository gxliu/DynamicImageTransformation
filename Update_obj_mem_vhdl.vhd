----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Derrick Ho
-- 
-- Create Date:    21:09:26 07/26/2012 
-- Design Name: 
-- Module Name:    Update_obj_mem_vhdl - Behavioral 
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.shape_pkg.all;

entity Update_obj_mem_vhdl is
	generic (button_rate_g: natural:= 25*10**5);-- rate is a about 0.1 seconds
    Port ( clock : in  STD_LOGIC;
           page_switch_i : in  STD_LOGIC_VECTOR (2 downto 0);
			  pollbuf0_interrupt1_i : in STD_logic;
           Dpad_i : in  STD_LOGIC_VECTOR (3 downto 0);
			  RL1_i : in std_logic_vector(1 downto 0);
			  RL2_i : in std_logic_vector(1 downto 0);
           --uart_ready_i : in  STD_LOGIC;
           uart_addr_i : in  STD_LOGIC_VECTOR (10 downto 0);
           uart_data_i : in  STD_LOGIC_VECTOR (31 downto 0);
			  sel_header_i : in  STD_LOGIC_VECTOR (31 downto 0);
			  lead_i : in std_logic_vector(6 downto 0);
			  follow_o : out std_logic_vector(6 downto 0);
			  sel_addr_o : out  STD_LOGIC_VECTOR (10 downto 0);
			  last_page_accessed_o : out std_logic_vector(2 downto 0);
           obj_write_addr_o : out  STD_LOGIC_VECTOR (10 downto 0);
           obj_write_data_o : out  STD_LOGIC_VECTOR (31 downto 0);
           obj_we_o : out  STD_LOGIC);
           
end Update_obj_mem_vhdl;

architecture Behavioral of Update_obj_mem_vhdl is
	signal mux_addr_s:std_logic_vector(10 downto 0):=(others => '0');
	signal u_clk: std_logic:= '0';
	signal follow_s : std_logic_vector (6 downto 0) := (others => '0');
	signal buf_empty_s : std_logic := '1';
begin
---
u_clk_proc : pes_clock generic map(max_cnt => 2) 
	port map (clock_in =>clock ,clock_out => u_clk );
---
-- "next_addr","sel_addr", and "obj_write_addr" have latches
--only because the mux has a limited number of outcomes
--Once you start fleshing it out the latches should reduce in number;
with page_switch_i select 
	mux_addr_s <=  	x"F"&"0000000" when "111",-- x"07",
								x"E"&"0000000" when "110",--x"06",
								x"D"&"0000000" when "101",--x"05",
								x"C"&"0000000" when "100",--x"04",
								x"B"&"0000000" when "011",--x"03",
								x"A"&"0000000" when "010",--x"02",
								x"9"&"0000000" when "001",--x"01", -- the space right after the default
								x"0"&"0000000" when others; -- the first image took 1024 + 2 lines [0,1025]
---
	upobjmem_proc : process( u_clk, mux_addr_s,sel_header_i, Dpad_i, uart_data_i, uart_addr_i)
		variable cnt : integer range 0 to (button_rate_g +1) := 0;
		type states is (init,
									get_page_addr,
									update_sel_addr,
									valid_sel_header,
									button_action,
									scale_action,			scale_big, 		scale_small,	 	scale_none,
									rotate_action, 		rotate_ccw,		rotate_cw, 		rotate_none,
									dpad_action,
									but_none,
									but_up, 				but_down, 		but_left, 		but_right,
									but_up_right, 		but_up_left,
									but_down_right, 	but_down_left,
									update_mem,
									write_update_mem,
									check_uart_ready,
									get_buf_values,
									consume_uart_buf
									);
		variable st: states:= init;
		variable follow_v : std_logic_vector (6 downto 0) := (others => '0');
		variable next_addr_v :std_logic_vector(10 downto 0):=(others => '0');
		variable next_header_v,
				curr_header_v: std_logic_vector(31 downto 0):=(others => '0');
	begin
		if u_clk = '1' and u_clk'event then
			case st is
				when init =>
					sel_addr_o <= (others => '0');
					obj_write_addr_o <=  (others => '0');
					obj_write_data_o <= (others => '0');
					obj_we_o <= '0';
					follow_s(6 downto 0) <= (others => '0');
					follow_v(6 downto 0) := (others => '0');
					st := get_page_addr;
				when get_page_addr =>
					cnt := 0;
					next_addr_v := mux_addr_s;
					obj_we_o <= '0';
					st := update_sel_addr;
				when update_sel_addr => --This is sort of a delay stay and it will stay here until the cnt reaches the button_rate_g
					cnt := cnt + 1;
					sel_addr_o <= next_addr_v;
					if cnt >= button_rate_g then st := button_action;
					elsif (follow_v /= lead_i) AND (pollbuf0_interrupt1_i = '1') then st:=check_uart_ready;
					else st := update_sel_addr;
					end if;
				when valid_sel_header => --checks current location to see if it is allowed to modify it.  if it is blank it can't do anything
					if sel_header_i(31 downto 28) = "1000" or sel_header_i(31 downto 28) = "1100" then
						st := button_action;
						
					else
						st := get_page_addr;
					end if;
				when button_action =>
					curr_header_v := sel_header_i;
					next_header_v(31 downto 28) := curr_header_v(31 downto 28); -- transfering opcode
					st := scale_action;
				when scale_action =>
					if RL1_i = "01" then st := scale_big;
					elsif RL1_i = "10" then st := scale_small;
					else st := scale_none;
					end if;
				when scale_big => --27 to 25
					next_header_v(27 downto 25) := curr_header_v(27 downto 25) + delta_scale;
					st := rotate_action;
				when scale_small => 
					next_header_v(27 downto 25) := curr_header_v(27 downto 25) - delta_scale;					
					st := rotate_action;
				when scale_none => 
					next_header_v(27 downto 25) := curr_header_v(27 downto 25);
					st := rotate_action;
				when rotate_action =>
					-- not entirely sure whether incrementing rotates ccw or not.  so I made a guess.  will find out later
					if RL2_i = "01" then st := rotate_ccw;
					elsif RL2_i = "10" then st := rotate_cw;
					else st := rotate_none;
					end if;
				when rotate_ccw => --24 to 20
					next_header_v(24 downto 20) := curr_header_v(24 downto 20) + delta_rotate;
					st := dpad_action;
				when rotate_cw =>
					next_header_v(24 downto 20) := curr_header_v(24 downto 20) - delta_rotate;				
					st := dpad_action;
				when rotate_none =>
					next_header_v(24 downto 20) := curr_header_v(24 downto 20);
					st := dpad_action;
				when dpad_action  =>
					if		Dpad_i = "0111" then st := but_up;
					elsif 	Dpad_i = "1011" then st := but_down;
					elsif 	Dpad_i = "1101" then st := but_left;
					elsif 	Dpad_i = "1110" then st := but_right;
					elsif 	Dpad_i = "0110" then st := but_up_right;
					elsif 	Dpad_i = "0101" then st := but_up_left;
					elsif 	Dpad_i = "1010" then st := but_down_right;
					elsif 	Dpad_i = "1001" then st := but_down_left;
					else st := but_none;
					end if;
				when but_none =>
					next_header_v(19 downto 0) := curr_header_v(19 downto 0);
					st := update_mem;
				when but_up => 
					next_header_v(19 downto 0) :=(curr_header_v(19 downto 10)) & (curr_header_v(9 downto 0)-delta_trans) ;
					st := update_mem; 
				when but_down =>  
					next_header_v(19 downto 0) :=(curr_header_v(19 downto 10)) & (curr_header_v(9 downto 0)+delta_trans) ;
					st := update_mem;
				when but_left => 
					next_header_v(19 downto 0) :=(curr_header_v(19 downto 10)-delta_trans) & (curr_header_v(9 downto 0)) ;
					st := update_mem;
				when but_right => 
					next_header_v(19 downto 0) :=(curr_header_v(19 downto 10)+delta_trans) & (curr_header_v(9 downto 0)) ;
					st := update_mem;
				when but_up_right => 
					next_header_v(19 downto 0) :=(curr_header_v(19 downto 10)+delta_trans) & (curr_header_v(9 downto 0)-delta_trans) ;
					st := update_mem;
				when but_up_left => 
					next_header_v(19 downto 0) :=(curr_header_v(19 downto 10)-delta_trans) & (curr_header_v(9 downto 0)-delta_trans) ;
					st := update_mem;
				when but_down_right => 
					next_header_v(19 downto 0) :=(curr_header_v(19 downto 10)+delta_trans) & (curr_header_v(9 downto 0)+delta_trans) ;
					st := update_mem;
				when but_down_left => 
					next_header_v(19 downto 0) :=(curr_header_v(19 downto 10)-delta_trans) & (curr_header_v(9 downto 0)+delta_trans) ;
					st := update_mem;
				when update_mem =>
					obj_write_addr_o <= next_addr_v;
					obj_write_data_o(31 downto 20) <= next_header_v (31 downto 20);
					---
					if next_header_v(19 downto 10) = "1111111111" then -- keep in bounds
						next_header_v(19 downto 10) := next_header_v(19 downto 10) +1;
					elsif next_header_v(19 downto 10) >= (hdisp_size-32 ) then --the number 32 is the width ofthe pix
						next_header_v(19 downto 10) := next_header_v(19 downto 10) -1;
					else	
						obj_write_data_o(19 downto 10) <= next_header_v(19 downto 10);
					end if;
					if next_header_v(9 downto 0) = "1111111111" then -- keep in bounds
						next_header_v(9 downto 0) := next_header_v(9 downto 0) +1;
					elsif next_header_v(9 downto 0) >= (vdisp_size-32) then
						next_header_v(9 downto 0) := next_header_v(9 downto 0) -1;
					else	
						obj_write_data_o(9 downto 0) <= next_header_v(9 downto 0);
					end if;
					---
					obj_we_o <= '0';
					st := write_update_mem;
				when write_update_mem =>
					obj_we_o <= '1';
					st := check_uart_ready;
					--st := get_page_addr; --test to see if older stuff still workss
				when check_uart_ready =>
					obj_we_o <= '0';
					follow_s(6 downto 0) <= follow_v;
					if follow_v = lead_i then st := get_page_addr; --buffer is empty when follow_v and lead_i are equal
					else st := get_buf_values; --when buffer is filled get ready to consume....;
					end if;
				when get_buf_values =>
--					follow_s(6 downto 0) <= follow_v;
					obj_write_data_o(31 downto 0) <= uart_data_i;
					obj_write_addr_o(10 downto 0) <= uart_addr_i;
					--obj_write_addr_o(10 downto 0) <= mux_addr_s(10 downto 7)&uart_addr_i(6 downto 0);
					st:= consume_uart_buf;
					if(uart_addr_i(10 downto 7) = x"F") then
						last_page_accessed_o(2 downto 0) <= "111";
					elsif(uart_addr_i(10 downto 7) = x"E") then
						last_page_accessed_o(2 downto 0) <= "110";
					elsif(uart_addr_i(10 downto 7) = x"D") then
						last_page_accessed_o(2 downto 0) <= "101";
					elsif(uart_addr_i(10 downto 7) = x"C") then
						last_page_accessed_o(2 downto 0) <= "100";
					elsif(uart_addr_i(10 downto 7) = x"B") then
						last_page_accessed_o(2 downto 0) <= "011";
					elsif(uart_addr_i(10 downto 7) = x"A") then
						last_page_accessed_o(2 downto 0) <= "010";
					elsif(uart_addr_i(10 downto 7) = x"9") then
						last_page_accessed_o(2 downto 0) <= "001";
					else 
						last_page_accessed_o(2 downto 0) <= "000";
					end if;
				when consume_uart_buf =>
					obj_we_o <= '1';
					follow_v(6 downto 0) := follow_v + 1;
					st := check_uart_ready;
				when others => 
					st := init;
			end case;
		end if;
	end process;
---
--buf_proc : process (u_clk, follow_s, lead_i)
--begin
--	if u_clk = '1' and u_clk'event then
--		if follow_s = lead_i then
--			buf_empty_s <= '1' ;
--		else 
--			buf_empty_s <= '0';
--		end if;
--	end if;
--end process;
--buf_empty_s <= '1' when follow_s = lead_i else '0';
follow_o <= follow_s;

end Behavioral;

