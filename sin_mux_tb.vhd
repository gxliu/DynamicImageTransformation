--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:37:41 08/01/2012
-- Design Name:   
-- Module Name:   C:/Users/Derrick/Dropbox/Documents/Xilinx_Project/VGA_module/sin_mux_tb.vhd
-- Project Name:  VGA_module
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sin_mux
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
 use ieee.std_logic_arith.all;
 use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY sin_mux_tb IS
END sin_mux_tb;
 
ARCHITECTURE behavior OF sin_mux_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sin_mux
    PORT(
         theta_i : IN  std_logic_vector(4 downto 0);
         val_i : IN  std_logic_vector(9 downto 0);
         result_o : OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
        COMPONENT cos_mux
    PORT(
         theta_i : IN  std_logic_vector(4 downto 0);
         val_i : IN  std_logic_vector(9 downto 0);
         result_o : OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;

   --Inputs
   signal theta_i : std_logic_vector(4 downto 0) := (others => '0');
   signal val_i : std_logic_vector(9 downto 0) := (others => '0');
signal clock : std_logic;
 	--Outputs
   signal result_o : std_logic_vector(9 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
--   uut: sin_mux PORT MAP (
 uut: cos_mux PORT MAP (
          theta_i => theta_i,
          val_i => val_i,
          result_o => result_o
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
		theta_i <= "00000";
		val_i <= conv_std_logic_vector(400, 10);
      wait for 100 ns;	
		
		for I in 0 to 31 loop
			theta_i <= theta_i + 1;
			wait for clock_period;
		end loop;
      wait for clock_period;
--
      -- insert stimulus here 

      wait;
   end process;

END;
