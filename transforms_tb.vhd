--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:44:10 07/27/2012
-- Design Name:   
-- Module Name:   C:/Users/Derrick/Dropbox/Documents/Xilinx_Project/VGA_module/transforms_tb.vhd
-- Project Name:  VGA_module
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: transformations
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
 
ENTITY transforms_tb IS
END transforms_tb;
 
ARCHITECTURE behavior OF transforms_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT transformations
    PORT(
         x_pre_i : IN  std_logic_vector(9 downto 0);
         y_pre_i : IN  std_logic_vector(9 downto 0);
         x_trans_i : IN  std_logic_vector(9 downto 0);
         y_trans_i : IN  std_logic_vector(9 downto 0);
         x_scale_i : IN  std_logic_vector(2 downto 0);
         y_scale_i : IN  std_logic_vector(2 downto 0);
         x_pivot_i : IN  std_logic_vector(9 downto 0);
         y_pivot_i : IN  std_logic_vector(9 downto 0);
         theta_i : IN  std_logic_vector(4 downto 0);
         x_post_o : OUT  std_logic_vector(9 downto 0);
         y_post_o : OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal x_pre_i : std_logic_vector(9 downto 0) := (others => '0');
   signal y_pre_i : std_logic_vector(9 downto 0) := (others => '0');
   signal x_trans_i : std_logic_vector(9 downto 0) := (others => '0');
   signal y_trans_i : std_logic_vector(9 downto 0) := (others => '0');
   signal x_scale_i : std_logic_vector(2 downto 0) := (others => '0');
   signal y_scale_i : std_logic_vector(2 downto 0) := (others => '0');
   signal x_pivot_i : std_logic_vector(9 downto 0) := (others => '0');
   signal y_pivot_i : std_logic_vector(9 downto 0) := (others => '0');
   signal theta_i : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal x_post_o : std_logic_vector(9 downto 0);
   signal y_post_o : std_logic_vector(9 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
	signal clock: std_logic:= '0';
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: transformations PORT MAP (
          x_pre_i => x_pre_i,
          y_pre_i => y_pre_i,
          x_trans_i => x_trans_i,
          y_trans_i => y_trans_i,
          x_scale_i => x_scale_i,
          y_scale_i => y_scale_i,
          x_pivot_i => x_pivot_i,
          y_pivot_i => y_pivot_i,
          theta_i => theta_i,
          x_post_o => x_post_o,
          y_post_o => y_post_o
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
		x_pre_i <= "00"& x"05";y_pre_i <= "00"& x"07";
		x_scale_i <= "000"; y_scale_i <= "000";
		x_trans_i <= "00"& x"05"; y_trans_i <= "00"&x"00";
		x_pivot_i <= "00"& x"07"; y_pivot_i <= "00" & x"07";
      wait for clock_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
