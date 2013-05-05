--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
package shape_pkg is
	constant hdisp_size : natural := 320;--320;--640/2;
	constant hpw_size : natural := 48;--40;--80;--96/2;
	constant hbp_size : natural := 28;--20;--200;--48/2;
	constant hfp_size : natural := 4;--20;--200;--16/2;
	
	constant vdisp_size : natural := 240;--480/2;
	constant vpw_size : natural := 1;--2;--2/2;
	constant vbp_size : natural := 15;--16;--139;--29/2;
	constant vfp_size : natural := 4;--4;--139;--10/2;
	
	constant hcnt_size, vcnt_size : natural := 10;
	constant hsync_period :	natural:=(	hfp_size +	hbp_size +	hdisp_size + hpw_size);
	constant vsync_period :	natural:=(	vfp_size +	vbp_size +	vdisp_size + vpw_size);
	constant vsync_tick :	natural:=(						hbp_size +	hdisp_size + hpw_size);	
	constant v_lower_bound,voffset: natural:=( vpw_size + vbp_size);
	constant h_lower_bound,hoffset: natural:=( hpw_size + hbp_size);
	constant h_upper_bound: natural := hbp_size +	hdisp_size + hpw_size ;
	constant v_upper_bound: natural := vbp_size +	vdisp_size + vpw_size ;
	
	constant delta_trans : std_logic_vector(9 downto 0) := "0000000011"; -- The amount should it be translated per tick
	constant delta_scale : std_logic_vector(2 downto 0) := "001";-- The amount should it be scaled per tick
	constant delta_rotate : std_logic_vector(4 downto 0) := "00001";-- The amount should it be rotate per tick
--=================
-- object package
-------------------
	subtype pixel is std_logic_vector(2 downto 0);

	constant red_c			: pixel:="100"	;--array[7] --red
	constant green_c		: pixel:="010";--array[6] --green
	constant blue_c			: pixel:="001";--array[5] --blue
	constant magenta_c	: pixel:="101";--array[4] --magenta
	constant yellow_c		: pixel:="110";--array[3] --yellow
	constant cyan_c			: pixel:="011";--array[2] --cyan
	constant black_c		: pixel:="000";--array[1] --black
	constant white_c		: pixel:="111";--array[0] -- white
	
	type point is
	record 
		x:std_logic_vector(9 downto 0);
		y:std_logic_vector(9 downto 0);
	end record;
	
	type line is
	record
		start_pt: point;
		end_pt: point;
	end record;
	--===================
	--components declaration
	--
	component generic_reg is generic (numbits: natural := 4);
	Port ( clock,reset,enable : in  STD_LOGIC; 
				load : in  STD_LOGIC_VECTOR(numbits-1 downto 0); 
				data : out  STD_LOGIC_VECTOR(numbits-1 downto 0));
	end component generic_reg;
	component VGA_module is
    Port ( clock : in  STD_LOGIC;
           h_cnt_o,v_cnt_o: out std_logic_vector(hcnt_size -1 downto 0);
			  hsync_o,vsync_o : out  STD_LOGIC);
	end component VGA_module;
	component PES_clock is
		generic (max_cnt: natural); -- max_cnt = (period * clock_in_speed)/2
		Port ( clock_in : in  STD_LOGIC;
				clock_out : out  STD_LOGIC);
	end component PES_clock;
	COMPONENT pixel_matrix_memory
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    clkb : IN STD_LOGIC;
	 rstb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;
COMPONENT obj_memory
  PORT (
    a : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    dpra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    dpo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
component transformations is
	port(
			x_pre_i,		y_pre_i 	:in	std_logic_vector(9 downto 0); --The raw position;
			x_trans_i, 	y_trans_i	: in	std_logic_vector(9 downto 0); -- Where the object is translated to;
			x_scale_i, 	y_scale_i	: in	std_logic_vector(2 downto 0); -- ;
			x_pivot_i,	y_pivot_i	: in std_logic_vector(9 downto 0); -- This is the coordinate that the obj will pivot around.  Very help ful when you don't want to use the origin to rotate around.  You should probably just do half the x width and half y height;
			theta_i								: in	std_logic_vector(4 downto 0); -- The amount to rotate in psudo degrees.  360 degrees are divided into 32 slices;
			x_post_o,		y_post_o	: out	std_logic_vector(9 downto 0) -- This is the resulting position after the transformation is complete;
	);
end component transformations;
component Matrix_control is
	port(
		clock : in std_logic;
		obj_read_data_i: in std_logic_vector(31 downto 0);
		sel_addr_i : in std_logic_vector(10 downto 0);
		pixel_write_ack_i: in std_logic;
		--obj_write_we_i : in std_logic;
		sel_header_o : out std_logic_vector(31 downto 0);
		obj_read_addr_o:out std_logic_vector(10 downto 0);
		pixel_we_o: out std_logic;
		--pixel_rst_o: out std_logic;
		pixel_write_addr_o: out std_logic_vector( 16 downto 0);
		pixel_write_data_o: out std_logic_vector(2 downto 0)
	);
end component matrix_control;
component Update_obj_mem_vhdl is
	generic (button_rate_g: natural:= 25*10**5);-- rate is a about 0.1 seconds
    Port ( clock : in  STD_LOGIC;
           page_switch_i : in  STD_LOGIC_VECTOR (2 downto 0);
			  pollbuf0_interrupt1_i: in std_logic;
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
			  last_page_accessed_o: out std_logic_vector (2 downto 0);
           obj_write_addr_o : out  STD_LOGIC_VECTOR (10 downto 0);
           obj_write_data_o : out  STD_LOGIC_VECTOR (31 downto 0);
           obj_we_o : out  STD_LOGIC);
           
end component Update_obj_mem_vhdl;
component PS_cntl_wrapper_vhdl is
    Port (clock : in  STD_LOGIC;
           ps_dat_i : in  STD_LOGIC;
           ps_cmd_o : out  STD_LOGIC;
           ps_att_o : out  STD_LOGIC;
           ps_clk_o : out  STD_LOGIC;
           ps_data_arr_o : out  STD_LOGIC_VECTOR (71 downto 0));
end component PS_cntl_wrapper_vhdl;
component sin_mux is
	 port (
		 theta_i : in std_logic_vector(4 downto 0);--The radian angle
		 val_i: in std_logic_vector(9 downto 0);--the value that will multiply the sin(theta)
		 result_o: out std_logic_vector(9 downto 0)
		 );
end component sin_mux;
component cos_mux is
	 port (
		 theta_i : in std_logic_vector(4 downto 0);--The radian angle
		 val_i: in std_logic_vector(9 downto 0);--the value that will multiply the cos(theta)
		 result_o: out std_logic_vector(9 downto 0)
		 );
end component cos_mux;
component lead_control --Verilog module
	port(
    clock : in std_logic; --input clock,
    rxd_data_i : in std_logic_vector(63 downto 0);--input [63:0] rxd_data_i,
    valid_i : in std_logic;--input valid_i,
	 follow_i : in std_logic_vector(6 downto 0);--input [6:0] follow_i,
    lead_o, lead_next_o : out std_logic_vector(6 downto 0);--output [6:0] lead_o, lead_next_o,
    data_we_o : out std_logic;--output reg data_we_o,
	 mode_num_o: out std_logic_vector(2 downto 0);
    write_addr_o : out std_logic_vector(10 downto 0);--output [10:0] write_addr_o, //Write_addr and Write_data are split here, but only for the purposes of being explicit about what is what.  When it is saved on to the buffer,  they will be concatenated.  The concatenated result will be the data and the value of lead_o will be the addr on the buffer.
    write_data_o : out std_logic_vector(31 downto 0)--output [31:0] write_data_o
    );
end component lead_control;
COMPONENT UART_Buf
  PORT (
    a : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
    dpra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    dpo : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
  );
END COMPONENT;
component wrapper_rxd 
	generic(word_size, buf_size : natural:= 8);
    Port ( clock,enable,reset : in  STD_LOGIC;
           rxd, valid_in : in  STD_LOGIC;
			  rxd_buffer_o : out std_logic_vector((buf_size*word_size)-1 downto 0);
			  --rxd_buffer_o : out std_logic_vector(63 downto 0);
			  ---seven_seg_o : out std_logic_vector(7 downto 0);
			  --column_o : out std_logic_vector(3 downto 0);
				valid_out : out std_logic--;
           --data_out : out  STD_LOGIC_vector( 7 downto 0)
			  );
end component;
component capture_uart_w_error_correction port(
    clock : in std_logic;
    rxd_i : in std_logic;
	 txd_enable_i: in std_logic;
    txd_o : out std_logic;
	 valid_o: out std_logic;
	 to_pc_o: out std_logic
    );
end component;
component seven_seg_module is
	port(
	clock : in std_logic;
	seven_seg_i: in std_logic_vector(15 downto 0);
	seven_seg_o: out std_logic_vector(7 downto 0);
	column_o: out std_logic_vector(3 downto 0)
	);
end component;
	--===================
	-- Functions
	----------------------
	
	function within_bounds(h,v:std_logic_vector) return boolean is
	begin
		return 	h >= h_lower_bound and h < h_upper_bound and
					v >= v_lower_bound and v < v_upper_bound ;
	end;
	function matrix_offset (h,v:std_logic_vector) return std_logic_vector is
		variable hvar,vvar: integer;
	begin
		if within_bounds (h,v) then
			hvar := conv_integer(h) - hoffset;
			vvar := conv_integer(v) - voffset;
			return conv_std_logic_vector(hvar + vvar*hdisp_size,17);
		else
			return conv_std_logic_vector(0,17);
		end if;
	end;

--	function sin( theta, val: std_logic_vector) return std_logic_vector is
--	begin
--		if theta = 0 and  val = 0 then return conv_std_logic_vector(conv_integer(0), 10);-- hardcode the results of val*sin(theta)
--		else return conv_std_logic_vector(conv_integer(0), 10); -- assume zero degrees
--		end if;
--	end;	
--	function cos( theta, val: std_logic_vector) return std_logic_vector is
--	begin
--		if theta = 0 and  val = 0 then return conv_std_logic_vector(conv_integer(val), 10);-- hardcode the results of val*cos(theta)
--		else return conv_std_logic_vector(conv_integer(val), 10); -- assume zero degrees
--		end if;
--	end;
	
end shape_pkg;

