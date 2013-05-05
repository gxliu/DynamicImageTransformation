-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  --use ieee.std_logic_arith.all;
  --use ieee.std_logic_unsigned.all;
  USE ieee.math_real.ALL;   -- for UNIFORM, TRUNC functions
  USE ieee.numeric_std.ALL;
	--use work.test_pkg_body.all;
  ENTITY wrapper_tb IS
  END wrapper_tb;

  ARCHITECTURE behavior OF wrapper_tb IS 

  -- Component Declaration
          COMPONENT wrapper
					Port ( clock : in  STD_LOGIC;
								--button:in std_logic_vector(3 downto 0);
								rst_pixel_matrix_i:in std_logic;
								rxd_i : in std_logic;
								switch: in std_logic_vector(7 downto 0);
								ps_dat_i: in std_logic;
--								--debug
--				db_obj_write_addr_o: out std_logic_vector(10 downto 0); 
--				db_obj_write_data_o: out std_logic_vector(31 downto 0);
--				db_obj_we_o : out std_logic;
--				db_follow_o : out std_logic_vector(6 downto 0);
--				--end debug
								to_pc_o: out std_logic;
								ps_cmd_o: out std_logic;
								ps_att_o: out std_logic;
								ps_clk_o: out std_logic;
								hsync_o,vsync_o : out  STD_LOGIC;
								RGB_o : out  STD_LOGIC_VECTOR (7 downto 0));
				end component;
			
			 signal	rxd_i,to_pc_o,
						ps_dat_i,
						ps_cmd_o,
						ps_att_o,
						ps_clk_o: std_logic := '0';
--						--debug
--			signal	db_obj_write_addr_o:  std_logic_vector(10 downto 0); 
--			signal	db_obj_write_data_o:  std_logic_vector(31 downto 0);
--			signal	db_obj_we_o :  std_logic;
--			signal db_follow_o :  std_logic_vector(6 downto 0);
--				--end debug
			 type hard_code_arr is array (0 to 1) of std_logic_vector(63 downto 0);
				constant hard_code: hard_code_arr :=  
					(	
						x"00D23300CC980000",--modified --x"00D23300CC990000",--original
				  -- x"FF"&x"FF"&x"00"&x"CC"&x"00"&x"00"&x"E1"&x"55"--original
						x"F7"&x"EF"&x"08"&x"C4"&x"40"&x"00"&x"E9"&x"51"--1 bit per byte modified.  parity 8 untouched aka bit zero in each byte.
--						x"FFF"&x"8FA"&x"DEADBEEF" & x"00",
--						x"FFF"&x"8B0"&x"12ED0177" & x"00",
--						x"FFF"&x"812"&x"EADB012E" & x"00"
					);
          SIGNAL clock, hsync_o, vsync_o :  std_logic;
          SIGNAL RGB_o:  std_logic_vector(7 downto 0);
         --- signal button :std_logic_vector(3 downto 0);
			 signal switch:std_logic_vector(7 downto 0);
			 signal clock_period: time := 10 ns;
--	signal in_var_s, out_var_s: std_logic_vector(63 downto 0);
	signal rand_clock, rand_clock2 : time;
  BEGIN
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
  -- Component Instantiation
          uut: wrapper PORT MAP(
                 clock => clock,
					  --button => button,
						rst_pixel_matrix_i => '0',
						rxd_i => rxd_i,
						switch => switch,
						ps_dat_i => '1',
						--debug
--				db_obj_write_addr_o => db_obj_write_addr_o,
--				db_obj_write_data_o => db_obj_write_data_o,
--				db_obj_we_o => db_obj_we_o,
--				db_follow_o => db_follow_o,
				--end debug
				to_pc_o => to_pc_o,
						ps_cmd_o => ps_cmd_o,
						ps_att_o => ps_att_o,
						ps_clk_o => ps_clk_o,
						hsync_o => hsync_o,
						vsync_o => vsync_o,
						RGB_o => rgb_o
          );


  --  Test Bench Statements
     tb : PROCESS
		VARIABLE seed1, seed2: positive;               -- Seed values for random generator
		VARIABLE rand: real;                           -- Random real-number value in range 0 to 1.0
		VARIABLE int_rand: integer;                    -- Random integer value in range 0..4095
		--VARIABLE stim: std_logic_vector(11 DOWNTO 0);  -- Random 12-bit stimulus
		variable time_var1, time_var2: time ;
     BEGIN
			switch <= x"00";
			rxd_i <= '1';  --as per rs_232 protocol... it all starts high
        wait for 100 ns; -- wait until global set/reset completes
		  
			--button <= "0100";
        -- Add user defined stimulus here
		 
		arr_i: for arr_index in 0 to (hard_code'length-1) loop
			--in_var_s := hard_code(arr_index);
			byte_index : for J in 0 to 7 loop	
				uniform(seed1, seed2,rand); -- generate random number
				int_rand := INTEGER(trunc(rand*4096.0)); -- rescale to 0..4069, find integer part
				int_rand := to_integer((to_unsigned(int_rand, 14)) );
				time_var1 := (1 ms + (int_rand*1 us)); --save random time n a variable
				rand_clock <= time_var1; --Save time to a signal so I can see it in waveform
				wait for time_var1; --wait for duration random time
				--stim := std_logic_vector(to_unsigned(int_rand, stim'LENGTH)); -- convert to std_logic_vector
				--wait for 1 ms; --represents the delay the happens between each sent byte
				rxd_i <= '0'; --this is the "start bit"
				wait for 104166 ns; --represents the 9600 baud rate delay
				bit_index: for I in 0 to 7 loop
					rxd_i <= hard_code(arr_index)(I + (J*8));			
					wait for 104166 ns; --represents the 9600 baud rate delay 
				end loop bit_index;
				rxd_i <= '1'; --this is the "stop bit"
				-----reset when byte is x98.  this is the fake error I made.  resend a better byte
				if arr_index = 0 and j = 2 then
					wait for 1 ms;
					rxd_i <= '0'; --start bit
					wait for 104166 ns;
					rxd_i <= '1'; --bit 0
					wait for 104166 ns;
					rxd_i <= '0'; --bit1
					wait for 104166 ns;
					rxd_i <= '0'; --bit2
					wait for 104166 ns;
					rxd_i <= '1'; --bit3
					wait for 104166 ns;
					rxd_i <= '1'; --bit4
					wait for 104166 ns;
					rxd_i <= '0';--bit5
					wait for 104166 ns;
					rxd_i <= '0';--bit6
					wait for 104166 ns;
					rxd_i <= '1';--bit7
					wait for 104166 ns;
					rxd_i <= '1';--stopbit
				end if;
				---end resent;
			end loop byte_index;
			
				--validate data
--				wait until (db_obj_we_o = '1');
--				assert (x"ff0"&db_obj_write_addr_o&db_obj_write_data_o&x"00" =
--							hard_code(arr_index)) report "Data in out miss match "  severity ERROR;
				--end validate data
				uniform(seed1, seed2,rand); -- generate random number
				int_rand := INTEGER(trunc(rand*4096.0)); -- rescale to 0..4069, find integer part
				int_rand := to_integer((to_unsigned(int_rand, 14)) );
				time_var2 := (10 ms + (int_rand*1 us)); --save random time n a variable
				rand_clock2 <= time_var2; --Save time to a signal so I can see it in waveform
				wait for time_var2; --wait for duration random time
			--wait for 10 ms;
		end loop arr_i;
        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 
--in_var_s <= hard_code(to_integer(unsigned(db_follow_o)));
--out_var_s <= x"ff0" & '0' & db_obj_write_addr_o & db_obj_write_data_o & x"00";
--tb2: process
--begin
----validate data
--while(TRUE) loop
--				wait until (db_obj_we_o = '1' and db_obj_we_o'event AND db_obj_write_addr_o /= "000"&x"00");
--				assert ( in_var_s = out_var_s) report "Data in out miss match. expected: " 
--				& integer'image(to_integer(unsigned(in_var_s))) 
--				& " received: "
--				& integer'image(to_integer(unsigned(out_var_s)))
--				severity ERROR;
--end loop;
----end validate data
--end process tb2;


  END;
