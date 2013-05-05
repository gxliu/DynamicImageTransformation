--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:34:26 07/26/2012
-- Design Name:   
-- Module Name:   C:/Users/Derrick/Dropbox/Documents/Xilinx_Project/VGA_module/update_obj_mem_tb.vhd
-- Project Name:  VGA_module
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Update_obj_mem_vhdl
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY update_obj_mem_tb IS
END update_obj_mem_tb;
 
ARCHITECTURE behavior OF update_obj_mem_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Update_obj_mem_vhdl
    PORT(
         clock : IN  std_logic;
         page_switch_i : IN  std_logic_vector(7 downto 0);
         buttons_i : IN  std_logic_vector(3 downto 0);
         uart_ready_i : IN  std_logic;
         uart_addr_i : IN  std_logic_vector(10 downto 0);
         uart_data_i : IN  std_logic_vector(7 downto 0);
         sel_header_i : IN  std_logic_vector(31 downto 0);
         sel_addr_o : OUT  std_logic_vector(10 downto 0);
         obj_write_addr_o : OUT  std_logic_vector(10 downto 0);
         obj_write_data_o : OUT  std_logic_vector(31 downto 0);
         obj_we_o : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal page_switch_i : std_logic_vector(7 downto 0) := (others => '0');
   signal buttons_i : std_logic_vector(3 downto 0) := (others => '0');
   signal uart_ready_i : std_logic := '0';
   signal uart_addr_i : std_logic_vector(10 downto 0) := (others => '0');
   signal uart_data_i : std_logic_vector(7 downto 0) := (others => '0');
   signal sel_header_i : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal sel_addr_o : std_logic_vector(10 downto 0);
   signal obj_write_addr_o : std_logic_vector(10 downto 0);
   signal obj_write_data_o : std_logic_vector(31 downto 0);
   signal obj_we_o : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Update_obj_mem_vhdl PORT MAP (
          clock => clock,
          page_switch_i => page_switch_i,
          buttons_i => buttons_i,
          uart_ready_i => uart_ready_i,
          uart_addr_i => uart_addr_i,
          uart_data_i => uart_data_i,
          sel_header_i => sel_header_i,
          sel_addr_o => sel_addr_o,
          obj_write_addr_o => obj_write_addr_o,
          obj_write_data_o => obj_write_data_o,
          obj_we_o => obj_we_o
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		buttons_i <= "0100";
		sel_header_i <= x"dead0000";
		
		for I in 0 to 10 loop
			wait for 100 ms;
			buttons_i <= "0100";
			sel_header_i <= obj_write_data_o;
		end loop;
      -- insert stimulus here 

      wait;
   end process;

END;
