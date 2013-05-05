library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use Ieee.std_logic_unsigned.all;
use Ieee.std_logic_arith.all;
use work.shape_pkg.all;

entity Matrix_control is
	port(
		clock : in std_logic;
		obj_read_data_i: in std_logic_vector(31 downto 0);
		sel_addr_i : in std_logic_vector(10 downto 0);
		pixel_write_ack_i : in std_logic;
		--obj_write_we_i : in std_logic; -- this will be used to halt everything if obj_mem is being written too.  I am doing this because I want to see if a read write collisoin is preventing a line from being written
		sel_header_o : out std_logic_vector(31 downto 0);
		obj_read_addr_o:out std_logic_vector(10 downto 0);
		pixel_we_o: out std_logic;
		--pixel_rst_o: out std_logic;
		pixel_write_addr_o: out std_logic_vector( 16 downto 0);
		pixel_write_data_o: out std_logic_vector(2 downto 0)
	);
end matrix_control;
architecture beh of matrix_control is
	signal m_clk: std_logic:= '0';
	signal x_trans_s, y_trans_s:  std_logic_vector(9 downto 0):=(others => '0');
	signal	x_scale_s, y_scale_s:  std_logic_vector(2 downto 0):=(others => '0');
	signal	x_pivot_s, y_pivot_s:  std_logic_vector(9 downto 0):=(others => '0');
	signal	theta_s					:  std_logic_vector(4 downto 0):=(others => '0');
	signal	x_pre_s, y_pre_s, x_post_s, y_post_s:  std_logic_vector(9 downto 0):=(others => '0');
	signal addr_calc_s:std_logic_vector(16 downto 0):=(others => '0');
	alias opcode is obj_read_data_i(31 downto 28);
	alias color_bar is obj_read_data_i(22 downto 20);
	alias x_bar is obj_read_data_i(19 downto 10);
	alias y_bar is obj_read_data_i(9 downto 0);
begin
transform_comp: transformations
	port map(
			x_pre_i => x_pre_s,
			y_pre_i => y_pre_s,
			x_trans_i => x_trans_s,
			y_trans_i	=> y_trans_s,
			x_scale_i => x_scale_s, 	
			y_scale_i	=> y_scale_s,
			x_pivot_i => x_pivot_s,	
			y_pivot_i	=> y_pivot_s,
			theta_i => theta_s,
			x_post_o => x_post_s,
			y_post_o	=> y_post_s
	);
addr_calc_s <= conv_std_logic_vector(conv_integer(x_post_s) + conv_integer(y_post_s)*hdisp_size, 17);
---
pixel_write_addr_o <= addr_calc_s;
pixel_write_data_o <= color_bar;
----
m_clk_proc : pes_clock generic map(max_cnt => 1) --This timing chosen in order to meet timing.
	port map (clock_in =>clock ,clock_out => m_clk );
--m_clk <= clock;
----
mt_proc: process(m_clk, obj_read_data_i, sel_addr_i)
	variable header_v : std_logic_vector(31 downto 0):=(others => '0');
	variable addr_v : std_logic_vector(10 downto 0):=(others => '0');
	variable x_dim_v, y_dim_v: std_logic_vector(9 downto 0):=(others => '0');
	constant pre_write_count_duration_c:natural:= 1;
	variable pre_write_count_v: natural range 0 to pre_write_count_duration_c:= 0;
	constant max_pixel_addr : std_logic_vector(16 downto 0):=(others => '1');
	alias x_trans_a is header_v(19 downto 10);
	alias y_trans_a is header_v(9 downto 0);
	alias x_scale_a is header_v(27 downto 25);
	alias y_scale_a is header_v(27 downto 25);
	alias theta_a is header_v(24 downto 20) ;
	type states is (init,
								idle,
								reset_pixel_mem,
								update_header,
								get_header,
								get_dimension,
								get_points,
								pre_write_p_mem,
								write_p_mem,
								get_next_point,
								dummy_header
								);
	variable st: states:= init;
	constant max_addr: std_logic_vector(10 downto 0):= (others => '1');
begin
	if m_clk = '1' and m_clk'event then
		--if obj_write_we_i = '0' then --This line was from a hunch from debugging
		case st is
			when init =>
				header_v := (others => '0');
				addr_v := (others => '0');
				sel_header_o <= (others => '0');
				pixel_we_o <= '0';
				st := idle;
			when idle =>
				pixel_we_o <= '0';
				if addr_v = sel_addr_i and (opcode = "1000" or opcode = "1100")then
					st := update_header;
				elsif addr_v /= sel_addr_i and opcode = "1000" then
					st := get_header;
				elsif addr_v /= sel_addr_i and opcode = "1100"then
					st := dummy_header;
				else 
					addr_v := addr_v + 1;
					st:= idle;
				end if;
			when update_header =>
				sel_header_o <= obj_read_data_i;
				st := get_header;
			when get_header =>
				header_v := obj_read_data_i;
				addr_v := addr_v +1;
				st := get_dimension;
			when get_dimension =>
				x_dim_v := x_bar;
				y_dim_v := y_bar;
				addr_v := addr_v + 1;
				st := get_points;
			when get_points =>
				x_pre_s <= x_bar;
				y_pre_s <= y_bar;
				x_trans_s <= x_trans_a;
				y_trans_s <= y_trans_a;
				x_scale_s <= x_scale_a;
				y_scale_s <= y_scale_a;
				x_pivot_s <= '0' & x_dim_v(9 downto 1);
				y_pivot_s <= '0' & y_dim_v(9 downto 1);
				theta_s <= theta_a;
				pixel_we_o <= '0';
				pre_write_count_v := 0; --reset counter to zero;
				st := write_p_mem;-- pre_write_p_mem;
			when pre_write_p_mem => --this state allows the transform to completely stabalize.  The parameters of the transform are done in "get_points" state.  the values stabalize in this state.  In the next state it should be ready to write.
				pixel_we_o <= '0';
				if pre_write_count_v = (pre_write_count_duration_c-1) then
					st := write_p_mem;
				else
					pre_write_count_v := pre_write_count_v + 1;
					st := pre_write_p_mem;
				end if;
			when write_p_mem =>
				pixel_we_o <= '1';
				if pixel_write_ack_i = '1' then
					addr_v := addr_v + 1;
					st := get_next_point;
				else
					st := write_p_mem;
				end if;
			when get_next_point =>
				pixel_we_o <= '0';
				if opcode = "1010" then
					st := get_points;
				else
					st := idle;
				end if;
			when dummy_header =>
				addr_v := addr_v + 1;  --temp
				st := idle; --temp
				--This will allow function ality to deal with non- images such as shapes.
				--filling out the face will have to come later.
			when others =>
				st := init;
		end case;
		--end if;
	end if;
	obj_read_addr_o <= addr_v;
end process;
----

end beh;

--====================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use Ieee.std_logic_unsigned.all;
use Ieee.std_logic_arith.all;
use work.shape_pkg.all;

--This component combines translation, scale, and rotation into 
--one matrix.  This shall work in 2-d space.  The matrix is summarized 
--below.  The meanings of the matrix multiplications can be found inside
--of the architechture.
--
--|x'|	|rs_xx	rs_xy	trs_x	|		|x|
--|y'| =	|rs_yx	rs_yy	trs_y	| .	|y|
--|1 |		|0			0				1			|		|1|


entity transformations is
	port(
			x_pre_i,		y_pre_i 	:in	std_logic_vector(9 downto 0); --The raw position;
			x_trans_i, 	y_trans_i	: in	std_logic_vector(9 downto 0); -- Where the object is translated to;
			x_scale_i, 	y_scale_i	: in	std_logic_vector(2 downto 0); -- ;
			x_pivot_i,	y_pivot_i	: in std_logic_vector(9 downto 0); -- This is the coordinate that the obj will pivot around.  Very help ful when you don't want to use the origin to rotate around.  You should probably just do half the x width and half y height;
			theta_i								: in	std_logic_vector(4 downto 0); -- The amount to rotate in psudo degrees.  360 degrees are divided into 32 slices;
			x_post_o,		y_post_o	: out	std_logic_vector(9 downto 0) -- This is the resulting position after the transformation is complete;
	);
end transformations;

architecture beh of transformations is 
signal pre_pt, post_pt,
			center2scale_pt,
			scale2rotate_pt,
			rotate2trans_pt
			: point := (x => (others => '0'), y => (others => '0'));
signal x_sin_result_s, y_sin_result_s,
			x_cos_result_s, y_cos_result_s
			: std_logic_vector(9 downto 0):= (others => '0');
--signal 
--		x_center2scale_s,	y_center2scale_s,
--		x_scale2rotate_s,		y_scale2rotate_s,
--		x_rotate2trans_s, 	y_rotate2trans_s
--	: std_logic_vector(9 downto 0):=(others => '0');
--	signal 
--		xrs_xx, yrs_xy, trs_x,
--		xrs_yx, yrs_yy, trs_y
--	: std_logic_vector(9 downto 0):=(others => '0');
	function center_pts ( pre_pt:point;
												x_pivot,y_pivot:std_logic_vector) return point is
		begin
		return (x => pre_pt.x - x_pivot,
						y => pre_pt.y - y_pivot);
	end;
	function scale_pts (	pre_pt:point;
											x_scale, y_scale: std_logic_vector) return point is
			variable post_pt: point;
		begin
			if x_scale(x_scale'left-1) = '1' then --x is negative
				post_pt.x := conv_std_logic_vector(conv_integer((not pre_pt.x) + 1) * conv_integer( x_scale),10); -- make pre x into positive in order to achive proper multiplicative value
				post_pt.x := (not post_pt.x) + 1;--since pre x was negative I just add the negative at the end
			else --x is positive
				post_pt.x := conv_std_logic_vector(conv_integer(pre_pt.x) * conv_integer(x_scale),10);
			end if;
			if y_scale(y_scale'left-1) = '1' then --y is negative
				post_pt.y := conv_std_logic_vector(conv_integer((not pre_pt.y) + 1) * conv_integer( x_scale),10); -- make pre y into positive in order to achive proper multiplicative value
				post_pt.y := (not post_pt.y) + 1;--since pre y was negative I just add the negative at the end
			else --y is positive
				post_pt.y := conv_std_logic_vector(conv_integer(pre_pt.y) * conv_integer(y_scale),10);
			end if;
		return post_pt;
--		return (
--		x => conv_std_logic_vector(conv_integer(pre_pt.x) * conv_integer(x_scale),10),
--		y => conv_std_logic_vector(conv_integer(pre_pt.y) * conv_integer(y_scale),10)
--		);
	end;
	
--Rotations will have to make use of fixed point multiplication
--the values of cos and sin will be in fraction form so they will
--need to be saved as fixed points.  You may need to create a 
--fixed point package in order to do this properly.
--first go will have 0, 1 , and -1
--second go will include fixed point calculations;
--	function rotate_pts (	pre_pt:point;
--												theta: std_logic_vector) return point is
--		begin
--		return (
--		x => cos(theta, pre_pt.x) - sin(theta, pre_pt.y), 
--		y => sin(theta, pre_pt.x) + cos(theta, pre_pt.y)
--		);
--	end;
	function trans_pts (	pre_pt:point;
											x_trans,y_trans,
											x_piv,y_piv: std_logic_vector) return point is
		begin
		return (
		x => pre_pt.x + x_trans + x_piv,
		y => pre_pt.y + y_trans + y_piv
		);
	end;
		
begin

	pre_pt <= (x =>x_pre_i,
						y => y_pre_i);
	--
	center2scale_pt <= center_pts(	pre_pt, 
																	x_pivot_i, 
																	y_pivot_i
																);
--	scale2rotate_pt <= center2scale_pt;	
	scale2rotate_pt <= scale_pts(	center2scale_pt, 
																x_scale_i, 
																y_scale_i
															);
	--rotate2trans_pt <= scale2rotate_pt;--fill in function later
--	rotate2trans_pt <= rotate_pts(scale2rotate_pt,
--																theta_i
--																);
--================
rotate2trans_pt.x <= x_cos_result_s - y_sin_result_s;
rotate2trans_pt.y <= x_sin_result_s + y_cos_result_s;
--================
	post_pt <= trans_pts (	rotate2trans_pt, 
													x_trans_i, y_trans_i, 
													x_pivot_i, y_pivot_i
												);
	--
	x_post_o <= post_pt.x;
	y_post_o <= post_pt.y;
--xrs_xx	<= conv_std_logic_vector(conv_integer(x_pre_i * (x_scale_i* cos(theta_i) )), xrs_xx'length);
--yrs_xy	<= conv_std_logic_vector(-conv_integer(y_pre_i * (y_scale_i* sin(theta_i))), yrs_xy'length);
--trs_x		<= conv_std_logic_vector(conv_integer(x_pivot_i * (1-(x_scale_i*cos(theta_i))) + (y_pivot_i*y_scale_i*sin(theta_i)) + x_trans_i), trs_x'length);
--x_post_o <= xrs_xx + yrs_xy + trs_x;
--
--xrs_yx	<= conv_std_logic_vector(conv_integer(x_pre_i * (x_scale_i*sin(theta_i))), xrs_yx'length);
--yrs_yy	<= conv_std_logic_vector(conv_integer(y_pre_i * (y_scale_i *cos(theta_i))), yrs_yy'length) ;
--trs_y		<= conv_std_logic_vector(conv_integer(y_pivot_i * (1-(y_scale_i * cos(theta_i))) - (x_pivot_i * x_scale_i * cos(theta_i)) + y_trans_i), trs_y'length);
--y_post_o <= xrs_yx + yrs_yy + trs_y;
xs_mux: sin_mux 
	 port map(
		 theta_i(4 downto 0) =>theta_i,--The radian angle
		 val_i(9 downto 0) => scale2rotate_pt.x,--the value that will multiply the sin(theta)
		 result_o(9 downto 0) => x_sin_result_s
		 );
xc_mux: cos_mux 
	 port map(
		 theta_i(4 downto 0)=>theta_i,--The radian angle
		 val_i(9 downto 0)=> scale2rotate_pt.x,--the value that will multiply the cos(theta)
		 result_o(9 downto 0)=> x_cos_result_s
		 );
ys_mux: sin_mux 
	 port map(
		 theta_i(4 downto 0) =>theta_i,--The radian angle
		 val_i(9 downto 0) =>scale2rotate_pt.y,--the value that will multiply the sin(theta)
		 result_o(9 downto 0) =>y_sin_result_s
		 );
yc_mux: cos_mux 
	 port map(
		 theta_i(4 downto 0)=>theta_i,--The radian angle
		 val_i(9 downto 0)=>scale2rotate_pt.y,--the value that will multiply the cos(theta)
		 result_o(9 downto 0)=>y_cos_result_s
		 );
		 
end beh;