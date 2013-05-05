----------------------------------------------------------------------------------
--Derrick Ho
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Generic_reg is
	Generic (Reg_size: integer);
    Port ( clock,reset,enable : in  STD_LOGIC;
		data_in : in STD_LOGIC_VECTOR (reg_size-1 downto 0);
           reg_data : out  STD_LOGIC_VECTOR (reg_size-1 downto 0));
end Generic_reg;
architecture Behavioral of Generic_reg is
	signal reg : std_logic_vector( reg_size-1 downto 0):= (others => '0');
begin
	process(clock,reset,enable, data_in)
		type states is (up, dn);
		variable st: states := dn;
	begin
		
		if (clock'event AND clock ='1') then
			if(reset = '1') then 
				reg <= (others => '0');
			elsif( reset = '0') then
				case st is
					when dn =>
						if enable = '1' then st := up;
							reg <= data_in;
						else st := dn;
						end if;
					when up =>
						if enable = '0' then st := dn;
						else st := up;
						end if;
				end case;
			end if;
		end if;
	end process;
	--------------
	reg_data <= reg;
end Behavioral;

