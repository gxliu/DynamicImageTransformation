-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY mt_tb IS
  END mt_tb;

  ARCHITECTURE behavior OF mt_tb IS 

  -- Component Declaration
          COMPONENT Matrix_control is
				port(
					clock : in std_logic;
					obj_read_data_i: in std_logic_vector(31 downto 0);
					sel_addr_i : in std_logic_vector(10 downto 0);
					sel_header_o : out std_logic_vector(31 downto 0);
					obj_read_addr_o: out std_logic_vector(10 downto 0);
					pixel_we_o: out std_logic;
					pixel_rst_o: out std_logic;
					pixel_write_addr_o: out std_logic_vector( 10 downto 0);
					pixel_write_data_o: out std_logic_vector(2 downto 0)
					);
          END COMPONENT;

					signal clock : std_logic;
					signal obj_read_data_i: std_logic_vector(31 downto 0);
					signal sel_addr_i : std_logic_vector(10 downto 0);
					signal sel_header_o :  std_logic_vector(31 downto 0);
					signal obj_read_addr_o :  std_logic_vector(10 downto 0);
					signal pixel_we_o:  std_logic;
					signal pixel_rst_o:  std_logic;
					signal pixel_write_addr_o:  std_logic_vector( 10 downto 0);
					signal pixel_write_data_o:  std_logic_vector(2 downto 0);
          
					constant clock_period : time := 10 ns;

  BEGIN

  -- Component Instantiation
          uut: Matrix_control 
				port map(
					clock ,
					obj_read_data_i,
					sel_addr_i,
					sel_header_o,
					obj_read_addr_o,
					pixel_we_o,
					pixel_rst_o,
					pixel_write_addr_o,
					pixel_write_data_o
					);
          

   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
  --  Test Bench Statements
     tb : PROCESS
     BEGIN
	  
		 
				obj_read_data_i <= "1000" &
														"001" & 
														"00000" & 
														"00"& x"05" &
														"00"&x"06";
				wait for clock_period;
				wait until obj_read_addr_o(1 downto 0) = "01";
        				obj_read_data_i <= "1001" &
														"000" & 
														"00000" & 
														"00"& x"0A" &
														"00"&x"0A";
				wait for clock_period;
				wait until obj_read_addr_o(1 downto 0) = "10";
								obj_read_data_i <= "1010" &
														"000" & 
														"00111" & 
														"00"& x"00" &
														"00"&x"00";
				wait for clock_period;
				wait until obj_read_addr_o(1 downto 0) = "11";
		  
		  
		  -- Add user defined stimulus here

        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;
