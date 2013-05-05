----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:33:51 07/16/2012 
-- Design Name: 
-- Module Name:    wrapper - Behavioral 
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

entity wrapper is
    Port ( clock : in  STD_LOGIC;
				--button:in std_logic_vector(3 downto 0);
				rst_pixel_matrix_i:in std_logic; -- hold this to fill the screen with white.  it SHOULD properly align everything
				rxd_i : in std_logic;
				switch: in std_logic_vector(7 downto 0);
				pollbuf0_interrupt1_i : in std_logic;
				ps_dat_i: in std_logic;
--				--debug
--				db_obj_write_addr_o: out std_logic_vector(10 downto 0); 
--				db_obj_write_data_o: out std_logic_vector(31 downto 0);
--				db_obj_we_o : out std_logic;
--				db_follow_o : out std_logic_vector(6 downto 0);
				follow_eq_lead_o: out std_logic; 
				lead_next_eq_follow_o: out std_logic;
				seven_seg_o: out std_logic_vector(7 downto 0); --shows the start and stop byte
				column_o: out std_logic_vector(3 downto 0);
				mode_num_o: out std_logic_vector(2 downto 0);--shown on left led's  shows the value of mode num.
				last_page_accessed_o: out std_logic_vector(2 downto 0); --shown on right led's -- helps show the last page written to in the follow fsm.
--				--end debug
				to_pc_o: out std_logic;
				ps_cmd_o: out std_logic;
				ps_att_o: out std_logic;
				ps_clk_o: out std_logic;
				hsync_o,vsync_o : out  STD_LOGIC;
				RGB_o : out  STD_LOGIC_VECTOR (7 downto 0));
end wrapper;

architecture Behavioral of wrapper is
	signal h_cnt_s,v_cnt_s: std_logic_vector (hcnt_size - 1 downto 0):=(others => '0');
	signal sel_header_s : std_logic_vector(31 downto 0) :=(others => '0');
	signal sel_addr_s : std_logic_vector(10 downto 0):=(others => '0');
	signal color_val_s :std_logic_vector(7 downto 0):= (others => '0');
	signal pixel_read_addr_s, pixel_write_addr_s : std_logic_vector(16 downto 0):= (others => '0');
	signal pixel_write_addr_rst_s, pixel_write_addr_mt_s : std_logic_vector(16 downto 0):= (others => '0');
	signal pixel_write_data_rst_s, pixel_write_data_mt_s: std_logic_vector(2 downto 0):=(others => '0');
	signal pixel_read_data_s, pixel_write_data_s: std_logic_vector(2 downto 0):=(others => '0');
	signal obj_read_addr_s, obj_write_addr_s: std_logic_vector(10 downto 0):=(others => '0');
	signal obj_read_data_s, obj_write_data_s: std_logic_vector(31 downto 0):=(others => '0');
	signal pre_data_delay_s,post_data_delay_s:std_logic_vector(27 downto 0):=(others => '0');
	signal old_obj_x_s, old_obj_y_s:std_logic_vector(9 downto 0):=(others => '0');
	signal handle_collision_s: std_logic;
	signal wea_pixel_mem_s,wea_pixel_mem_rst_s,wea_pixel_mem_mt_s: std_logic_vector(0 downto 0):=(others => '0');
	signal wea_obj_mem_s: std_logic:= '0';
	signal rst_pixel_matrix_s: std_logic:= '0';
	signal not_clk, but_clk: std_logic:='0';
	signal x_trans_s, y_trans_s,
				x_pivot_s, y_pivot_s,
				x_pre_s, y_pre_s,
				x_post_s, y_post_s : std_logic_vector(9 downto 0):=(others => '0');
	signal vsync_s,hsync_s: std_logic:= '0';
	signal x_scale_s, y_scale_s: std_logic_vector(2 downto 0):= (others => '0');
	signal theta_s:std_logic_vector(4 downto 0):=(others => '0');
	signal ps_data_arr_s: std_logic_vector(71 downto 0):=(others => '0');
	signal rgb_s :std_logic_vector( 7 downto 0):=(others => '0');
	signal reset_clk: std_logic:= '0';
	signal reset_proc_count: integer:= 0;
	signal toggle_mt_reset_mux:std_logic:= '0';
	signal lead_num_s, lead_next_num_s, follow_num_s : std_logic_vector(6 downto 0) := (others => '0');
	signal rxd_buf_write_data_s : std_logic_vector (47 downto 0) := (others => '0');
	signal lead2rxd_buffer_we : std_logic := '0';
	signal uart_read_s : std_logic_vector (47 downto 0) := (others => '0');
	signal rxd_data2lead_s : std_logic_vector(63 downto 0):= (others => '0');
	signal rxd_valid2lead_s : std_logic := '0';
	signal rxd_correction2rxd_reciever_s: std_logic := '0';
	signal err_correction_valid_s : std_logic := '0';
	signal txd_enable_s : std_logic:= '0';
	--
	alias red is pixel_read_data_s(2);
	alias grn is pixel_read_data_s(1);
	alias blu is pixel_read_data_s(0);
	alias opcode is obj_read_data_s(31 downto 28);
	alias obj_x is obj_write_data_s(19 downto 10);
	alias obj_y is obj_write_data_s(9 downto 0);
	--dpad alias
	alias ps_but_up is ps_data_arr_s(28);
	alias ps_but_down is ps_data_arr_s(30);
	alias ps_but_left is ps_data_arr_s(31);
	alias ps_but_right is ps_data_arr_s(29);
	--R1 and L1
	alias ps_but_scale_up is  ps_data_arr_s(35);
	alias ps_but_scale_down is ps_data_arr_s(34);
	--R2 and L2
	alias ps_but_rotate_up is  ps_data_arr_s(33);
	alias ps_but_rotate_down is  ps_data_arr_s(32);
	--
begin

ps_controller_comp: PS_cntl_wrapper_vhdl 
    Port map(clock => clock,
           ps_dat_i => ps_dat_i,
           ps_cmd_o => ps_cmd_o,
           ps_att_o => ps_att_o,
           ps_clk_o => ps_clk_o,
           ps_data_arr_o(71 downto 0) => ps_data_arr_s-- add scale and rotation to sm.  Link them to the right buttons.
	);
--		---------debug
--				db_obj_write_addr_o <= obj_write_addr_s;
--				db_obj_write_data_o <= obj_write_data_s;
--				db_obj_we_o <= wea_obj_mem_s;
--				db_follow_o <= follow_num_s;
--		---------end debug
update_obj_mem: Update_obj_mem_vhdl 
    Port map( clock => clock ,
           page_switch_i => switch(2 downto 0),
           --DPAD_i => button,--dpad up,down,left,right
			  pollbuf0_interrupt1_i =>  pollbuf0_interrupt1_i,
			  dpad_i(3) => ps_but_up, --up
			  dpad_i(2) => ps_but_down,--down
			  dpad_i(1) => ps_but_left,--left
			  dpad_i(0) => ps_but_right,--right
			  RL1_i(1) => (ps_but_scale_up),
			  RL1_i(0) => (ps_but_scale_down),
			  RL2_i(1) => (ps_but_rotate_up), 
			  RL2_i(0) => (ps_but_rotate_down), 
           --uart_ready_i => '0', --temporarily set here until uart added.
           uart_addr_i => uart_read_s(42 downto 32),
           uart_data_i => uart_read_s(31 downto 0),
			  sel_header_i => sel_header_s,
			  lead_i(6 downto 0) => lead_num_s,
			  follow_o(6 downto 0) => follow_num_s,
			  sel_addr_o => sel_addr_s,
			  last_page_accessed_o => last_page_accessed_o,
           obj_write_addr_o => obj_write_addr_s,
           obj_write_data_o => obj_write_data_s,
           obj_we_o => wea_obj_mem_s);

mt_proc: Matrix_control 
	port map(
		clock => clock,
		obj_read_data_i => obj_read_data_s,
		sel_addr_i => sel_addr_s,
		pixel_write_ack_i => handle_collision_s,
	--	obj_write_we_i => wea_obj_mem_s,
		sel_header_o => sel_header_s,
		obj_read_addr_o => obj_read_addr_s,
		pixel_we_o => wea_pixel_mem_mt_s(0),
		--pixel_rst_o => rst_pixel_matrix_s,
		pixel_write_addr_o => pixel_write_addr_mt_s,
		pixel_write_data_o => pixel_write_data_mt_s
	);

VGA_timer: VGA_module Port map( 
	clock => clock,
   h_cnt_o(9 downto 0) => h_cnt_s,
	v_cnt_o(9 downto 0) => v_cnt_s,
	hsync_o => hsync_s,
	vsync_o => vsync_s		
	);
	hsync_o <= hsync_s;
	vsync_o <= vsync_s;
RGB_s <= color_val_s when within_bounds(h_cnt_s, v_cnt_s) 
					else x"00";
--the undefined rgb_o values may have been causing the artifacts.  Hopefully this will take it away
RGB_o <= x"00" when rgb_s(7) = 'U' or
											rgb_s(6) ='U' or
											rgb_s(5) ='U' or
											rgb_s(4) ='U' or
											rgb_s(3) ='U' or
											rgb_s(2) ='U' or
											rgb_s(1) ='U' or
											rgb_s(0) ='U' 
					else rgb_s;
color_val_s(7 downto 5) <= (others => red);
color_val_s(4 downto 2) <= (others => grn);
color_val_s(1 downto 0) <= (others => blu);
---
handle_collision_s <= '1' when wea_pixel_mem_s(0) = '1' and pixel_write_addr_s /= pixel_read_addr_s
												else '0';
---
PMM : pixel_matrix_memory
  PORT MAP (
    clka => not_clk, --falling
    wea(0) => handle_collision_s,-- wea_pixel_mem_s,
    addra(16 downto 0) => pixel_write_addr_s, -- write addr
    dina => pixel_write_data_s, -- write data
    clkb => clock, --rising
	 rstb => '0',-- rst_pixel_matrix_i,
    addrb(16 downto 0) => pixel_read_addr_s, -- read addr
    doutb => pixel_read_data_s -- read data
  );
pixel_Read_addr_s <= matrix_offset(h_cnt_s,v_cnt_s);

obj_m : obj_memory
  PORT MAP (
    a => obj_write_addr_s,
    d => obj_write_data_s,
    clk => not_clk,
    we => wea_obj_mem_s,
	 dpra => obj_read_addr_s,
    dpo => obj_read_data_s
  );
UART_buffer : UART_Buf
  PORT MAP (
    a(6 downto 0) => lead_num_s, -- write_addr controlled by lead_fsm's lead_o value
    d(47 downto 0) => rxd_buf_write_data_s, -- write_data controlled by lead_fsm.  Only the important data is stored here.  [5 unused bits][11bit addr][32bitimage data] = 48 bits
    dpra(6 downto 0) => follow_num_s,-- read_addr controller by follow_fsm
    clk => clock,--
    we => lead2rxd_buffer_we,-- the lead_fsm controls the writing to this buffer
    dpo(47 downto 0) => UART_read_s-- read_data.  sent to  update obj memory.  Don't forget to split it once it is inside the module.
  );
  
  --///
  follow_eq_lead_o <= '1' when follow_num_s = lead_num_s else '0';
  lead_next_eq_follow_o <= '1' when follow_num_s = lead_next_num_s else '0';
  txd_enable_s <= '0' when follow_num_s = lead_next_num_s else '1';
  -----
  RXD_correction: capture_uart_w_error_correction
  port map(clock => clock, 
				rxd_i =>rxd_i ,
				txd_enable_i => txd_enable_s,
				txd_o => rxd_correction2rxd_reciever_s , 
				valid_o => err_correction_valid_s,
				to_pc_o => to_pc_o);
   	sev_seg: seven_seg_module
	port map(
	clock => clock,
	seven_seg_i(15 downto 8) => rxd_data2lead_s(63 downto 56)  , -- data_out_s(63 downto 48),
	seven_seg_i(7 downto 0) => rxd_data2lead_s(7 downto 0),
	seven_seg_o => seven_seg_o,
	column_o => column_o
	); 
  RXD_reciever: wrapper_rxd 
	  generic map(word_size => 8, buf_size => 8)
     Port map( clock => clock ,enable => '1' ,reset => '0',
           rxd => rxd_correction2rxd_reciever_s, valid_in => err_correction_valid_s,
			  rxd_buffer_o(63 downto 0) => rxd_data2lead_s,
			--  seven_seg_o(7 downto 0) => open,
			--  column_o(3 downto 0) => open,
			  valid_out => rxd_valid2lead_s--,
         --  data_out( 7 downto 0) => open
			  );
  lead_cntl: lead_control --Verilog module
	 port map(
    clock => clock, --input clock,
    rxd_data_i(63 downto 0) => rxd_data2lead_s,--input [63:0] rxd_data_i,
    valid_i => rxd_valid2lead_s,--input valid_i,
	 follow_i(6 downto 0) => follow_num_s,--input [6:0] follow_i,
    lead_o(6 downto 0) => lead_num_s, 
	 lead_next_o(6 downto 0) => lead_next_num_s,--output [6:0] lead_o, lead_next_o,
    data_we_o => lead2RXD_buffer_we, --output reg data_we_o,
	 mode_num_o(2 downto 0) => mode_num_o, 
    write_addr_o(10 downto 0) => rxd_buf_write_data_s(42 downto 32),--output [10:0] write_addr_o, //Write_addr and Write_data are split here, but only for the purposes of being explicit about what is what.  When it is saved on to the buffer,  they will be concatenated.  The concatenated result will be the data and the value of lead_o will be the addr on the buffer.
    write_data_o(31 downto 0) => rxd_buf_write_data_s(31 downto 0)--output [31:0] write_data_o
    );
	 
rxd_buf_write_data_s(47 downto 43) <= (others => '0'); -- set unused parts to zero.	 
not_clk <= not clock;

---
----reset proc
--it will have a pes clock that will run 60hz.  The clock will toggle a "mux"
--The "mux" will decide who gets to write to memory.  It will allow the 
--output of the mt control or it will allow the clearing output of the reset proc
--it might actually have to be faster then 60hz....whatever, you need to make it and test it

--once you have cerified that the transformations are function, go ahead and prepare for your 
--interview tomorrow.  Look at but times for saturday and stay for a few days
--reset_pixel_matrix_clk_gen: pes_clock generic map (max_cnt => 0)
--	port map (clock_in => clock, clock_out => reset_clk);
reset_clk_proc: process(clock)
	variable cnt_v: integer:= 0;
	--variable cnt_v: std_logic_vector(16 downto 0 ):=(others => '0'); --will overflow ~1000 times a second
	--variable cnt_v: std_logic_vector(19 downto 0 ):=(others => '0'); --will over flow ~ 100 times a second
begin
	if (clock ='1' and clock'event) then
--			if cnt_v(14) = '0' then toggle_mt_reset_mux <= '0';
--			else toggle_mt_reset_mux <= '1';
--			end if;
			
			if cnt_v = ((10**8)/(2**6)) then --refresh 64 times a second
				cnt_v := 0;
			else cnt_v := cnt_v + 1;
			end if;
	end if;
	reset_proc_count <= cnt_v;
	--if cnt_v < (hdisp_size*vdisp_size) then toggle_mt_reset_mux <= '0';
--			--if cnt_v < (2**14) then toggle_mt_reset_mux <= '0'; -- if ^ overflow 1000/sec then it should complete
--			--if cnt_v < (2**10) then toggle_mt_reset_mux <= '0'; --if ^ overflow 100/sec then it should complete clearning
		--	else toggle_mt_reset_mux <= '1';
		--	end if;
end process;
toggle_mt_reset_mux <= '0' when reset_proc_count < ((hsync_period*vsync_period)/(2**4)) else '1'; --will clear 1/16 of the screen each refresh.  the screen refreshes 64 times a second. 64/16=4.  this means the whole screen will be cleared 4 times each second.
--toggle_mt_reset_mux <= '0' when reset_proc_count < ((hdisp_size*vdisp_size)/(2**4)) else '1';
--toggle_mt_reset_mux <= '1' when within_bounds(h_cnt_s, v_cnt_s) else '0';--This will reset when it is printing out of bounds
--reset_clk <= hsync_s;
reset_clk <= clock;
reset_proc: process(reset_clk, toggle_mt_reset_mux)
	variable addr_v: std_logic_vector(16 downto 0):=(others => '0');
begin
				pixel_write_addr_rst_s <= addr_v;
				--pixel_write_data_rst_s <= "000";
--				if(rst_pixel_matrix_i = '1') then
--					pixel_write_data_rst_s <= "111";
--				else
--					pixel_write_data_rst_s <= "000";
--				end if;
				wea_pixel_mem_rst_s(0) <= '1';
	if( reset_clk = '1' and reset_clk'event and toggle_mt_reset_mux = '0') then
		addr_v := addr_v + 1;
			if addr_v = (hdisp_size*vdisp_size) then addr_v := (others =>'0');
			end if;
			if(rst_pixel_matrix_i = '1') then
					pixel_write_data_rst_s <= "111";
				else
					pixel_write_data_rst_s <= "000";
				end if;
	end if;
end process;



--mt_reset_toggle_mux_select_line : pes_clock generic map (max_cnt => 10000)
--	port map (clock_in => clock, clock_out => toggle_mt_reset_mux);
--toggle_mt_reset_mux <= vsync_s; --apparently, changing things in the dark pixels results in random colors around the screen;
with toggle_mt_reset_mux select
	pixel_write_addr_s <= pixel_write_addr_rst_s when '0',
									pixel_write_addr_mt_s when others;
with toggle_mt_reset_mux select
	pixel_write_data_s <= pixel_write_data_rst_s when '0',
									 pixel_write_data_mt_s when others;
with toggle_mt_reset_mux select
	wea_pixel_mem_s <= wea_pixel_mem_rst_s when '0',
									wea_pixel_mem_mt_s when others;
												

end Behavioral;
--========================================================================
--library Ieee; use Ieee.std_logic_1164.all;
--entity flip_flop is 
--	Port (	clock,reset,enable : in  STD_LOGIC; 
--				load : in  STD_LOGIC; 
--				Q : out  STD_LOGIC);
--end flip_flop;
--architecture struct of flip_flop is
--	signal preQ: std_logic:= '0';
--begin
-- Q<=preQ;
-- proc:process (Clock,reset, enable, load)begin
--	if(clock'event and clock = '1') then
--		if(reset = '1' and (enable = '1' or enable = '0')) then preQ <= '0';
--		elsif(reset = '0' and enable = '1') then	preQ <= load;
--		end if;	
--	end if;
-- end process;
--end struct;

--===========================================================================
--library Ieee; use Ieee.std_logic_1164.all;
--entity generic_reg is
--	generic (numbits: natural := 4);
--	Port ( clock,reset,enable : in  STD_LOGIC; 
--				load : in  STD_LOGIC_VECTOR(numbits-1 downto 0); 
--				data : out  STD_LOGIC_VECTOR(numbits-1 downto 0));
--end generic_reg;
--architecture struct of generic_reg is
--	component flip_flop 
--		Port (	clock,reset,enable : in  STD_LOGIC; 
--				load : in  STD_LOGIC; 
--				Q : out  STD_LOGIC);
--	end component;
--begin
--	gen_reg: for I in 0 to numbits-1 generate 
--		reg_gen: flip_flop 
--		Port map ( clock=>clock,
--							reset=>reset,
--							enable=>enable,
--							load=>load(I), 
--							Q=>data(I)
--							);
--		end generate;
--end struct;
