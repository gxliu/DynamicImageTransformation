----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:17:16 07/11/2012 
-- Design Name: 
-- Module Name:    VGA_module - Behavioral 
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

entity VGA_module is
    Port ( clock : in  STD_LOGIC;
			  --rgb_i  : in std_logic_vector(5 downto 0);
           --rgb_o : out  STD_LOGIC_VECTOR (7 downto 0);
			 -- hstate_o,vstate_o: out std_logic_vector(3 downto 0);
           h_cnt_o,v_cnt_o: out std_logic_vector(hcnt_size -1 downto 0);
			  hsync_o,vsync_o : out  STD_LOGIC);
end VGA_module;

architecture Behavioral of VGA_module is
--	alias red is rgb_i(5 downto 4);
--	alias grn is rgb_i(3 downto 2);
--	alias blu is rgb_i(1 downto 0);

--	signal dina,douta:std_logic_vector(0 downto 0):= (others => '0');
--	signal addra: std_logic_vector(18 downto 0):= (others => '0');
--	signal clk_d1: std_logic:= '0';
	signal h_clk,v_clk,not_v_clk,green_clk : std_logic:='0';
	signal h_cnt_s: std_logic_vector( hcnt_size -1 downto 0):=(others => '0');
	signal v_cnt_s: std_logic_vector( hcnt_size -1 downto 0):=(others => '0');

--	signal grn_yvar_s : integer := 0;
--	signal first_obj: point;
--	signal hsync_s:std_Logic:= '0';
begin
---
h_clk_proc: PES_clock --clock period 80 ns
	 generic map(max_cnt=> 4)--2) -- max_cnt = (period * clock_in_speed)/2
    Port map( clock_in => clock, clock_out => h_clk);
---
h_proc: process (h_clk)
begin
	if h_clk = '1' and h_clk'event then
		if h_cnt_s = (hsync_period-1) then h_cnt_s <= (others => '0');
		else 	h_cnt_s <= h_cnt_s +1;
		end if;
	end if;
end process;
---

v_clk_proc: PES_clock 
	 generic map(max_cnt=> 3200)--1600) -- max_cnt = (period * clock_in_speed)/2
    Port map( clock_in => clock, clock_out => v_clk);

v_proc: process(v_clk)
begin
	if v_clk = '0' and v_clk'event then
		if v_cnt_s = (vsync_period-1) then v_cnt_s <= (others => '0');
		else v_cnt_s <= v_cnt_s +1;
		end if;
	end if;
end process;

hsync_o <= '0' when h_cnt_s  < (hpw_size) else '1';
vsync_o <= '0' when v_cnt_s  < (vpw_size) else '1';

h_cnt_o <= h_cnt_s;
v_cnt_o <= v_cnt_s;

--RGB_o <= red & '1' & grn & '1' & blu when within_bounds(h_cnt_s, v_cnt_s) else (others => '0');
--RGB_o <= (others =>'1') when within_bounds(h_cnt_s, v_cnt_s) else (others => '0');
--red <= "111";grn <= "000";blu<= "11";
--red <= "111" when within_bounds(h_cnt_s,v_cnt_s) else "000";
--	red <= "111" when v_cnt_s >= (10 + voffset)  and v_cnt_s < (11 + voffset)  
--							and h_cnt_s >= (0+ hoffset) and h_cnt_s < (100+ hoffset) 
--							else "000";
--  grn <= "111" when v_cnt_s >= (voffset) and v_cnt_s < (2 + voffset) 
--							and h_cnt_s >= (hoffset) and h_cnt_s < (2 +hoffset)
--							else "000";
--  blu <= "11" when v_cnt_s >= (vdisp_size-2+ voffset) and v_cnt_s < (vdisp_size + voffset) 
--							and h_cnt_s >= (hdisp_size-2 + hoffset) and h_cnt_s < (hdisp_size + hoffset) 
--							else "00";
-----
--grn_clk_proc: PES_clock 
--	 generic map(max_cnt=> 10*10**5) -- max_cnt = (period * clock_in_speed)/2
--    Port map( clock_in => clock, clock_out => green_clk);
-----
--green_proc: process(green_clk, grn_yvar_s)
--	type state is (dn, up);
--	variable st: state:= dn;
--begin
--	if green_clk = '1' and green_clk'event then
--		case st is
--			when dn => 
--				grn_yvar_s <= grn_yvar_s +1;
--				if grn_yvar_s >= 300 then 
--					st:= up;
--				else	
--					st:= dn;
--				end if;
--			when up => 
--				grn_yvar_s <= grn_yvar_s -1;
--				if grn_yvar_s <= 1 then 
--					st:= dn;
--				else 
--					st:= up;
--				end if;
--			when others => st := dn;
--		end case;
--	end if;
--	
--end process;


--hstate_o <= "0001" when h_cnt_s >= conv_std_logic_vector(0,h_cnt_s'length) and h_cnt_s < conv_std_logic_vector(hpw_size,h_cnt_s'length) else
--					"0010" when h_cnt_s >= conv_std_logic_vector(hpw_size,h_cnt_s'length) and h_cnt_s < conv_std_logic_vector(hpw_size+hbp_size,h_cnt_s'length) else
--					"0100" when h_cnt_s >= conv_std_logic_vector(hpw_size+hbp_size,h_cnt_s'length) and h_cnt_s < conv_std_logic_vector(hpw_size+hbp_size+hdisp_size,h_cnt_s'length) else
--					"1000" when h_cnt_s >= conv_std_logic_vector(hpw_size+hbp_size+hdisp_size,h_cnt_s'length) and h_cnt_s < conv_std_logic_vector(hpw_size+hbp_size+hdisp_size+hfp_size,h_cnt_s'length) else
--					"1111";					
--vstate_o <= "0001" when v_cnt_s >= conv_std_logic_vector(0,v_cnt_s'length) and v_cnt_s < conv_std_logic_vector(vpw_size,v_cnt_s'length) else
--					"0010" when v_cnt_s >= conv_std_logic_vector(vpw_size,v_cnt_s'length) and v_cnt_s < conv_std_logic_vector(vpw_size+vbp_size,v_cnt_s'length) else
--					"0100" when v_cnt_s >= conv_std_logic_vector(vpw_size+vbp_size,v_cnt_s'length) and v_cnt_s < conv_std_logic_vector(vpw_size+vbp_size+vdisp_size,v_cnt_s'length) else
--					"1000" when v_cnt_s >= conv_std_logic_vector(vpw_size+vbp_size+vdisp_size,v_cnt_s'length) and v_cnt_s < conv_std_logic_vector(vpw_size+vbp_size+vdisp_size+vfp_size,v_cnt_s'length) else
--					"1111";
--shift_pixel_buffer: process(green_clk)
--begin
--	if green_clk = '1' and green_clk'event then
--		pixel_matrix <= pre_pixel_matrix;
--	end if;
--end process;
--add_layer: process(green_clk)
--	type state is (clear, print);
--	variable st:state:= clear;
--begin
--	if green_clk = '1' and green_clk'event then
--		case st is
--			when clear => st := print;
--				pre_pixel_matrix <= (others => black);
--			when print => st := clear;
--				pre_pixel_matrix(first_obj.x + first_obj.y*hdisp_size) <= first_obj.color; 
--		end case;
--	end if;
--end process;
--move_clk_proc: PES_clock 
--	 generic map(max_cnt=> 100*10**6) -- max_cnt = (period * clock_in_speed)/2
--    Port map( clock_in => clock, clock_out => green_clk);
--move_point:process(green_clk)
--	type state is (init_obj,top, right, down, left);
--	variable st: state:= init_obj;
--	variable cnt: integer:=0;
--begin
--	if green_clk = '1' and green_clk'event then
--		--pre_pixel_matrix <= (others => black);--clear buffer
--		--pixel_matrix(first_obj.x + first_obj.y*hdisp_size) := first_obj.color; --print new stuff;
--		case st is
--			when init_obj =>
--				first_obj.x <= 5;
--				first_obj.y <= 5;
--				first_obj.color(0 downto 0) <= white;
--				st := top;
--			when top => 
--				first_obj.x <= first_obj.x + 1;
--				if cnt >= 100 then st := right;
--					cnt := 0;
--				else st:= st;
--					cnt := cnt + 1;
--				end if;
--			when right => 
--				first_obj.y <= first_obj.y - 1;
--				if cnt >= 100 then st := down;
--					cnt := 0;
--				else st:= st;
--					cnt := cnt + 1;
--				end if;
--			when down =>
--				first_obj.x <= first_obj.x - 1;
--				if cnt >= 100 then st := left;
--					cnt := 0;
--				else st:= st;
--					cnt := cnt + 1;
--				end if;			
--			when left => 
--				first_obj.y <= first_obj.y + 1;
--				if cnt >= 100 then st := top;
--					cnt := 0;
--				else st:= st;
--					cnt := cnt + 1;
--				end if;
--		end case;
--	end if;
--end process;
--process(green_clk)
--	type state is(left,right);
--	variable st:state:= left;
--begin
--	if green_clk='0' and green_clk'event then
--		case st is
--			when left => st := right;
----				width:for X in 0 to (hdisp_size/2)-1 loop
----					height:for Y in 0 to (vdisp_size/2)-1 loop
----						pixel_matrix(x + y*hdisp_size) <= white;
----					end loop height;
----				end loop width;
--				dina <= (others => '0');
--			when right => st := left;
--				dina <= (others => '1');
--		end case;
--	end if;
--end process;

--this is used to extract the correct pixel from the pixel matrix
--offest_matrix:process(clock,h_cnt_s,v_cnt_s)
--	variable hvar,vvar: integer:= 0;
--begin
--	if clock = '0' and clock'event then
--		if h_cnt_s >= hoffset and v_cnt_s >= voffset then
--			hvar := conv_integer(h_cnt_s) - hoffset;
--			vvar := conv_integer(v_cnt_s) - voffset;
--		end if;
--		RGB_o(0 downto 0) <=  douta;
--		RGB_o(1 downto 1) <=  douta;
--		RGB_o(2 downto 2) <=  douta;
--		RGB_o(3 downto 3) <=  douta;
--		RGB_o(4 downto 4) <=  douta;
--		RGB_o(5 downto 5) <=  douta;
--		RGB_o(6 downto 6) <=  douta;
--		RGB_o(7 downto 7) <=  douta;

--		RGB_o(0 downto 0) <=  pixel_matrix(hvar + vvar*hdisp_size);
--		RGB_o(1 downto 1) <=  pixel_matrix(hvar + vvar*hdisp_size);
--		RGB_o(2 downto 2) <=  pixel_matrix(hvar + vvar*hdisp_size);
--		RGB_o(3 downto 3) <=  pixel_matrix(hvar + vvar*hdisp_size);
--		RGB_o(4 downto 4) <=  pixel_matrix(hvar + vvar*hdisp_size);
--		RGB_o(5 downto 5) <=  pixel_matrix(hvar + vvar*hdisp_size);
--		RGB_o(6 downto 6) <=  pixel_matrix(hvar + vvar*hdisp_size);
--		RGB_o(7 downto 7) <=  pixel_matrix(hvar + vvar*hdisp_size);
		--RGB_o(7 downto 0) <= (7=>douta,6=>douta,5=>douta,4=>douta,3=>douta,2=>douta,1=>douta,0 =>douta);
--	end if;


--end process;
--========================================
--	process (clock,h_cnt_s,v_cnt_s)
--		variable hvar,vvar, addrv: integer:= 0;
--	begin
--		if clock = '0' and clock'event then
--			if h_cnt_s >= h_lower_bound and h_cnt_s < h_upper_bound and
--				v_cnt_s >= v_lower_bound and v_cnt_s < v_upper_bound 
--				then
--				hvar := conv_integer(h_cnt_s) - h_lower_bound;
--				vvar := conv_integer(v_cnt_s) - v_lower_bound;
--				addrv :=(hvar + vvar*hdisp_size);
--			else
--				addrv := (0);
--			end if;
--		end if;
--		addra <= conv_std_logic_vector(addrv,addra'length);
--	end process;
--
-------
----addra <= matrix_offset(h_cnt_s,v_cnt_s);
-------
--		RGB_o(0 downto 0) <=  douta when within_bounds(h_cnt_s,v_cnt_s)  else (others => '0');
--		RGB_o(1 downto 1) <=  douta when within_bounds(h_cnt_s,v_cnt_s)  else (others => '0');
--		RGB_o(2 downto 2) <=  douta when within_bounds(h_cnt_s,v_cnt_s)  else (others => '0');
--		RGB_o(3 downto 3) <=  douta when within_bounds(h_cnt_s,v_cnt_s)  else (others => '0');
--		RGB_o(4 downto 4) <=  douta when within_bounds(h_cnt_s,v_cnt_s)  else (others => '0');
--		RGB_o(5 downto 5) <=  douta when within_bounds(h_cnt_s,v_cnt_s)  else (others => '0');
--		RGB_o(6 downto 6) <=  douta when within_bounds(h_cnt_s,v_cnt_s)  else (others => '0');
--		RGB_o(7 downto 7) <=  douta when within_bounds(h_cnt_s,v_cnt_s)  else (others => '0');
-----
--
-----
--your_instance_name : pixel_matrix_mem
--  PORT MAP (
--    clka => clock,
--    wea(0) => h_clk,
--    addra => addra,
--    dina => dina,
--    douta => douta
--  );
--dina(0) <= '1' when h_cnt_s >= (200 + hoffset) and h_cnt_s < (400 + hoffset) and
--								v_cnt_s >= (100 + voffset) and v_cnt_s < (300 + voffset) else '0'; 




end Behavioral;