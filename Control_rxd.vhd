----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Control_rxd is
	generic( word_size:natural);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           en : in  STD_LOGIC;
           rxd : in  STD_LOGIC;
           load_reg : out  STD_LOGIC;
		 valid_in : in std_logic;
		 write_reg_out: out std_logic;
		 valid_out : out std_logic);
end Control_rxd;

architecture Behavioral of Control_rxd is
	type states is (idle, absorb, stop, set_valid);
	signal cst,nst: states:= idle;
	signal ccnt, ncnt: std_logic_vector(word_size-1 downto 0); 
	signal cload, nload: std_logic;
	constant ones: std_logic_vector( word_size-1 downto 0):= (others => '1');
begin

	load_reg <= cload;
	valid_out <= '1' when cst = set_valid else '0';
	write_reg_out <= '1' when cst = stop else '0';
--	valid_out <= '1' when cst = stop else '0';
	sync: process(clk,rst,en)
	begin
		if(rst = '1') then cst <= idle;cload <= '0'; ccnt <= (others => '0');
		elsif(clk'event AND clk = '1') then
			if(rst = '0' AND en = '1') then
				cst <= nst; cload <= nload; ccnt <= ncnt;
			end if;
		end if;
	end process;
	
	tran: process(cst,ccnt,rxd, valid_in)
	begin
		case cst is
			when idle =>  
				if(RXD = '0' AND valid_in = '1') then 
					nst <= absorb; 
					nload <= '1';
					ncnt <= '1'&ccnt(ccnt'left downto 1);
				else 
					nst <= idle; 
					nload <= '0'; 
					ncnt <= (others => '0');
				end if;
			when absorb => 
				if(ccnt = ones) then 
					nst <= stop; 
					nload <= '0';
					ncnt <= (others => '0'); 
				else 
					nst <= absorb; 
					nload <= '1';
					ncnt <= '1'&ccnt(ccnt'left downto 1);
				end if;
			when stop =>
				nst <= set_valid; 
				nload <= '0';
				ncnt <= (others => '0');
			when set_valid => 
				nst <=idle; 
				nload <= '0'; 
				ncnt <= (others => '0');
		end case;
	end process;

end Behavioral;