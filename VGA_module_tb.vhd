--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:46:47 07/11/2012
-- Design Name:   
-- Module Name:   C:/Users/Derrick/Dropbox/Documents/Xilinx_Project/VGA_module/VGA_module_tb.vhd
-- Project Name:  VGA_module
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: VGA_module
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
 
ENTITY VGA_module_tb IS
END VGA_module_tb;
 
ARCHITECTURE behavior OF VGA_module_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT VGA_module
    PORT(
         clock : IN  std_logic;
         rgb_o : OUT  std_logic_vector(7 downto 0);
        -- hstate_o : OUT  std_logic_vector(3 downto 0);
         --vstate_o : OUT  std_logic_vector(3 downto 0);
         hsync_o : OUT  std_logic;
         vsync_o : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';

 	--Outputs
   signal rgb_o : std_logic_vector(7 downto 0);
   signal hstate_o : std_logic_vector(3 downto 0);
   signal vstate_o : std_logic_vector(3 downto 0);
   signal hsync_o : std_logic;
   signal vsync_o : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: VGA_module PORT MAP (
          clock => clock,
          rgb_o => rgb_o,
         -- hstate_o => hstate_o,
          --vstate_o => vstate_o,
          hsync_o => hsync_o,
          vsync_o => vsync_o
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
      wait for clock_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
