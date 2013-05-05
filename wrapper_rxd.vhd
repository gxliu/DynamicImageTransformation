----------------------------------------------------------------------------------
--Derrick Ho
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.shape_pkg.all;

entity wrapper_rxd is
	generic(word_size, buf_size : natural:= 8);
    Port ( clock,enable,reset : in  STD_LOGIC;
           rxd, valid_in : in  STD_LOGIC;
			  rxd_buffer_o : out std_logic_vector((buf_size*word_size)-1 downto 0);
			  --rxd_buffer_o : out std_logic_vector(63 downto 0);
			  --seven_seg_o : out std_logic_vector(7 downto 0);
			  --column_o : out std_logic_vector(3 downto 0);
				valid_out : out std_logic--;
           --data_out : out  STD_LOGIC_vector( 7 downto 0)
			  );
end wrapper_rxd;

architecture Behavioral of wrapper_rxd is
component binary2hex is
    Port ( binary_num : in  STD_LOGIC_VECTOR (3 downto 0);
           seven_seg : out  STD_LOGIC_VECTOR (7 downto 0));
end component binary2hex;
	component Generic_reg 
	Generic (Reg_size: integer);
	Port ( clock,reset,enable : in  STD_LOGIC;
		data_in : in STD_LOGIC_VECTOR (reg_size-1 downto 0);
           reg_data : out  STD_LOGIC_VECTOR (reg_size-1 downto 0));
	end component;
	component Control_rxd 
	generic(word_size:natural);
	Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           en : in  STD_LOGIC;
           rxd : in  STD_LOGIC;
		 valid_in : in std_logic;
		 valid_out : out std_logic;
		 write_reg_out: out std_logic;
           load_reg : out  STD_LOGIC);
	end component;
	component data_path_rxd 
	generic ( word_size: natural );
	Port ( clk,rst,load, rxd: in  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (word_size-1 downto 0));
	end component;
	component clock_generator generic (clock_in_speed, clock_out_speed, num_bits: integer);
   port ( clock_in  : in    std_logic; 
             clock_out : out   std_logic);
	end component;
	component seven_seg_module is
	port(
	clock : in std_logic;
	seven_seg_i: in std_logic_vector(15 downto 0);
	seven_seg_o: out std_logic_vector(7 downto 0);
	column_o: out std_logic_vector(3 downto 0)
	);
	end component seven_seg_module;
	--signals
	signal load_s,valid_out_s,write_reg_s,ISR, an_clk_s : std_logic;
	signal load_data : std_logic_vector(word_size-1 downto 0);
	signal column_s, binary_num_s:std_logic_vector(3 downto 0);
	--signal data_out_s:std_logic_vector(71 downto 0):=(others => '0');
	signal data_out_s:std_logic_vector(((buf_size+1)*word_size)-1 downto 0):=(others => '0');
begin
--	   glk_divider: clock_generator generic map (
--		clock_in_speed => 100*10**6,
--		clock_out_speed => 9600,
--		num_bits => 13)
--      port map (clock_in=>clock,
--                clock_out=>ISR);
--ISR <= clock; --Used to bypass the obsolete clock_generator commented out above
	--The above clock divider seemed buggy.  It wasn't setting its clockout value correctly.  To remedy this problem I placed a more modern clock divider below
	glk_div_new: PES_clock 
	 generic map(max_cnt => 5208) -- max_cnt = (period * clock_in_speed)/2 ; i.e ((0.000104166)*(100000000))/2 ; using 104166 ns since that is baud rate
    Port map( clock_in => clock,
					clock_out => ISR);
	
	
	dp: data_path_rxd 	
		generic map (word_size => word_size)
		port map (
			clk =>ISR, 
			rst =>reset, 
			load =>load_s, 
			rxd =>rxd , 
			data_out => load_data);
			
	cntl: Control_rxd 
		generic map (word_size => word_size)
		port map (
			clk => ISR, 
			rst => reset, 
			en => enable, 
			rxd => rxd, 
			load_reg => load_s,
			write_reg_out => write_reg_s,
			valid_in =>valid_in, 
			valid_out=> valid_out_s);
---
	--data_out_s(71 downto 64) <= load_data;		-- This is here to make the generated generic_reg work.  These 8 bytes are the bus that goes into the left most generic_reg. 
		data_out_s(((buf_size+1)*word_size)-1 downto ((buf_size)*word_size)) <= load_data;		-- This is here to make the generated generic_reg work.
---					
---
gen_reg_8_bytes:
for I in 0 to buf_size-1 generate
	ascii_out2: Generic_reg generic map (reg_size => word_size)
		port map (
			clock => clock, 
			reset => reset, 
			enable => write_reg_s,--valid_out_s,
			data_in =>  data_out_s((( I +2)*word_size)-1 downto (I+1)*word_size),
			reg_data => data_out_s((( I +1)*word_size)-1 downto (I)*word_size)
		);
end generate;
--- send buffer into to the ouside world
--rxd_buffer_o(63 downto 0) <= data_out_s(63 downto 0);
rxd_buffer_o((buf_size*word_size)-1 downto 0) <= data_out_s((buf_size*word_size)-1 downto 0);

	---------------------
	--data_out <= data_out_s(7 downto 0);
	valid_out <= valid_out_s;
	--load_reg <= '1' when valid_out_s = '1' else '0';

	--================================
--	sev_seg: seven_seg_module
--	port map(
--	clock => clock,
--	seven_seg_i => data_out_s(63 downto 48),
--	seven_seg_o => seven_seg_o,
--	column_o => column_o
--	);
	--=================================
	--binary to hex
	-----------------
--	b2h: binary2hex 
--    Port map( 
--						binary_num(3 downto 0) => binary_num_s,
--						seven_seg(7 downto 0) => seven_seg_o
--					);
			  
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Derrick Ho
-- email : dho006@ucr.edu--=====================
--seven seg module
-----------------------
library IEEE;use IEEE.STD_LOGIC_1164.ALL;

entity seven_seg_module is
	port(
	clock : in std_logic;
	seven_seg_i: in std_logic_vector(15 downto 0);
	seven_seg_o: out std_logic_vector(7 downto 0);
	column_o: out std_logic_vector(3 downto 0)
	);
end entity seven_seg_module;

architecture beh of seven_seg_module is
	component clock_generator generic (clock_in_speed, clock_out_speed, num_bits: integer);
   port ( clock_in  : in    std_logic; 
             clock_out : out   std_logic);
	end component;
	signal an_clk_s: std_logic:= '0';
	signal column_s,
			binary_num_s
				: std_logic_vector(3 downto 0):= (others => '0');
begin
	--================================
	--column sm
	-----------------
	glk_divider2: clock_generator generic map (
		clock_in_speed => 100*10**6,
		clock_out_speed => 1000,
		num_bits => 16)
      port map (clock_in=>clock,
                clock_out=>an_clk_s);
					 
	column_o <= not column_s;
	process(an_clk_s)
		type state is (an3, an2, an1, an0);
		variable st: state:= an0;
		variable count: integer:= 0;
	begin
		if an_clk_s = '1' and an_clk_s'event then
			case st is
				when an0 =>
					column_s <= "1000";
					st := an1;
				when an1 =>
					column_s <= "0100";
					st := an2;
				when an2 =>
					column_s <= "0010";
					st := an3;
				when an3 =>
					column_s <= "0001";
					st := an0;
			end case;
		end if;
	end process;
	--===============================
	--seven seg mux
	----------------------
	with column_s select
	binary_num_s <= seven_seg_i(3 downto 0) 	when "0001",
							  seven_seg_i(7 downto 4)		when "0010",
							  seven_seg_i(11 downto 8)	when "0100",
							  seven_seg_i(15 downto 12)	when "1000",
												(others => '0') when others;
							 
	---
	with binary_num_s select 
	seven_seg_o <= x"81" when x"0",
							x"CF" when x"1",
							x"92" when x"2",
							x"86" when x"3",
							x"CC" when x"4",
							x"A4" when x"5",
							x"A0" when x"6",
							x"8F" when x"7",
							x"80" when x"8",
							x"8C" when x"9",
							x"88" when x"A",
							x"E0" when x"B",
							x"B1" when x"C",
							x"C2" when x"D",
							x"B0" when x"E",
							x"B8" when x"F";
end beh;