library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
package tools is
		--shape_i is the signal that is about to be converted to fit;
		--fit_i is the signal that shape_i will conform to
		--i.e. if shape is a std_logic_vector of 4 bits, it will get changed
		--to an integer and then converted into an std_logic vector of the same
		--size as fit.
		function CSLV (shape_i: std_logic_vector; fit_i:std_logic_vector)return std_logic_vector is
			begin return conv_std_logic_vector(conv_integer(shape_i),fit_i'length);
		end function CSLV;
		function CSLV (shape_i: std_logic; fit_i:std_logic)return std_logic is
			begin return shape_i;
		end function CSLV;
		function CSLV (shape_i: std_logic; fit_i:std_logic_vector)return std_logic_vector is
			begin return conv_std_logic_vector(conv_integer(shape_i),fit_i'length);
		end function CSLV;
		function CSLV (shape_i: integer; fit_i:std_logic_vector)	return std_logic_vector is
			begin return conv_std_logic_vector((shape_i),fit_i'length);
		end function CSLV;
		function CSLV (shape_i: integer; fit_i:std_logic)return std_logic is
			begin
			if shape_i = 0 then return '0';
			else return '1';
			end if;
		end function CSLV;
		function CSLV (shape_i: std_logic_vector; fit_i:std_logic)return std_logic is
			begin
			if shape_i = CSLV(0,shape_i) then return '0';
			else	return '1';
			end if;
		end function CSLV;
		function "not" (s:integer) return std_logic_vector is
			begin return not ( conv_std_logic_vector(s,64));
		end;
		function "=" (s:integer;f:std_logic) return boolean is
			begin return CSLV(s,f) = f;
		end;
		function "=" (f:std_logic;s:integer) return boolean is
			begin return CSLV(s,f) = f;
		end;
		function "=" (s:integer;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) = f;
		end;
		function "=" (f:std_logic_vector;s:integer) return boolean is
			begin return CSLV(s,f) = f;
		end;
		function "=" (s:std_logic;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) = f;
		end;
		function "=" (f:std_logic_vector;s:std_logic) return boolean is
			begin return CSLV(s,f) = f;
		end;
		function "/=" (f:std_logic;s:integer) return boolean is
			begin return CSLV(s,f) /= f;
		end;
		function "/=" (s:integer;f:std_logic) return boolean is
			begin return CSLV(s,f) /= f;
		end;
		function "/=" (s:integer;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) /= f;
		end;
		function "/=" (f:std_logic_vector;s:integer) return boolean is
			begin return CSLV(s,f) /= f;
		end;
		function "/=" (s:std_logic;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) /= f;
		end;
		function "/=" (f:std_logic_vector;s:std_logic) return boolean is
			begin return CSLV(s,f) /= f;
		end;
		function ">=" (f:std_logic;s:integer) return boolean is
			begin return CSLV(s,f) >= f;
		end;
		function ">=" (s:integer;f:std_logic) return boolean is
			begin return CSLV(s,f) >= f;
		end;
		function ">=" (s:integer;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) >= f;
		end;
		function ">=" (f:std_logic_vector;s:integer) return boolean is
			begin return CSLV(s,f) >= f;
		end;
		function ">=" (s:std_logic;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) >= f;
		end;
		function ">=" (f:std_logic_vector;s:std_logic) return boolean is
			begin return CSLV(s,f) >= f;
		end;
		function "<=" (f:std_logic;s:integer) return boolean is
			begin return CSLV(s,f) <= f;
		end;
		function "<=" (s:integer;f:std_logic) return boolean is
			begin return CSLV(s,f) <= f;
		end;
		function "<=" (s:integer;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) <= f;
		end;
		function "<=" (f:std_logic_vector;s:integer) return boolean is
			begin return CSLV(s,f) <= f;
		end;
		function "<=" (s:std_logic;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) <= f;
		end;
		function "<=" (f:std_logic_vector;s:std_logic) return boolean is
			begin return CSLV(s,f) <= f;
		end;
		function ">" (s:integer;f:std_logic) return boolean is
			begin return CSLV(s,f) > f;
		end;
		function ">" (f:std_logic;s:integer) return boolean is
			begin return CSLV(s,f) > f;
		end;
		function ">" (s:integer;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) > f;
		end;
		function ">" (f:std_logic_vector;s:integer) return boolean is
			begin return CSLV(s,f) > f;
		end;
		function ">" (s:std_logic;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) > f;
		end;
		function ">" (f:std_logic_vector;s:std_logic) return boolean is
			begin return CSLV(s,f) > f;
		end;
		function "<" (s:integer;f:std_logic) return boolean is
			begin return CSLV(s,f) < f;
		end;
		function "<" (f:std_logic;s:integer) return boolean is
			begin return CSLV(s,f) < f;
		end;
		function "<" (s:integer;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) < f;
		end;
		function "<" (f:std_logic_vector;s:integer) return boolean is
			begin return CSLV(s,f) < f;
		end;
		function "<" (s:std_logic;f:std_logic_vector) return boolean is
			begin return CSLV(s,f) < f;
		end;
		function "<" (f:std_logic_vector;s:std_logic) return boolean is
			begin return CSLV(s,f) < f;
		end;
		function CSLV (shape_i:std_logic) return boolean is
			begin return shape_i = '1';
		end function CSLV;
		function CSLV (shape_i:std_logic_vector) return boolean is
				constant zeros: std_logic_vector(shape_i'left downto 0):= (others => '0');
			begin return not(shape_i = zeros );			
		end function CSLV;
		function CSLV (shape_i:integer) return boolean is
			begin return CSLV(conv_std_logic_vector(shape_i,64));
		end function CSLV;
		function CSLV (shape_i:boolean) return boolean is
			begin return shape_i;
		end function CSLV;
		function "SLL" (s:std_logic_vector;f:integer) return std_logic_vector is
			variable s_v: std_logic_vector(s'left downto 0);
            begin
			s_v := s;
			if(f > 0) then --left shift
				for I in 0 to (f-1) loop
					 s_v := s_v(s_v'left-1 downto 0)&'0';
				end loop;
			elsif(f <0) then --right shift
				for I in (f+1) to 0 loop		
					s_v := '0'&s_v(s_v'left downto 1);
				end loop;
			end if;
			return s_v; 
		end;
		function "SLL" (s:integer;f:integer) return std_logic_vector is
			variable s_v: std_logic_vector(32 downto 0);
			begin 
			s_v := (conv_std_logic_vector(s,64));
			return 	s_v SLL f;
		end;
		function "SRL" (s:std_logic_vector;f:integer) return std_logic_vector is
			variable s_v: std_logic_vector(s'left downto 0);
            begin
			s_v := s;
			if(f < 0) then --left shift
				for I in 0 to (f-1) loop
					 s_v := s_v(s_v'left-1 downto 0)&'0';
				end loop;
			elsif(f > 0) then --right shift
				for I in (f+1) to 0 loop		
					s_v := '0'&s_v(s_v'left downto 1);
				end loop;
			end if;
			return s_v; 
		end;
		function "SRL" (s:integer;f:integer) return std_logic_vector is
			variable s_v: std_logic_vector(32 downto 0);
			begin 
			s_v := (conv_std_logic_vector(s,64));
			return 	s_v SRL f;
		end;
		function mod_1(s,f:integer)return std_logic_vector is
			begin return conv_std_logic_vector(s mod f,32);
		end mod_1;
		function "mod" (s:std_logic_vector;f:std_logic_vector) return std_logic_vector is
			begin return mod_1(conv_integer(s),conv_integer(f));
		end;
		function "mod" (s:std_logic_vector;f:integer) return std_logic_vector is
			begin return mod_1(conv_integer(s),f);
		end;
		function "mod" (s:integer;f:std_logic_vector) return std_logic_vector is
			begin return mod_1(s,conv_integer(f));
		end;		
		function "mod" (s:integer;f:integer) return std_logic_vector is
			begin return mod_1(s,f);
		end;
		function "+" (s:std_logic;f:integer) return integer is
			begin return conv_integer(s)+f;
		end;
		function "+" (f:integer;s:std_logic) return integer is
			begin return conv_integer(s)+f;
		end;		
		function "-" (s:std_logic;f:integer) return integer is
			begin return conv_integer(s)-f;
		end;
		function "-" (f:integer;s:std_logic) return integer is
			begin return conv_integer(s)-f;
		end;		
		function "*" (s:integer;f:std_logic_vector) return integer is
			begin return s * conv_integer(f);
		end;
		function "*" (f:std_logic_vector;s:integer) return integer is
			begin return s * conv_integer(f);
		end;		
		function "*" (s:integer;f:std_logic) return integer is
			begin return s* conv_integer(f);
		end;
		function "*" (s:std_logic_vector;f:std_logic) return integer is
			begin return conv_integer(s) * conv_integer(f);
		end;
		function "*" (f:std_logic;s:integer) return integer is
			begin return s* conv_integer(f);
		end;
		function "*" (f:std_logic;s:std_logic_vector) return integer is
			begin return conv_integer(s) * conv_integer(f);
		end;		
		function "/" (s:integer;f:std_logic_vector) return integer is
			begin return s / conv_integer(f);
		end;
		function "/" (f:std_logic_vector;s:integer) return integer is
			begin return s / conv_integer(f);
		end;			
		function "/" (s:integer;f:std_logic) return integer is
			begin return s/ conv_integer(f);
		end;
		function "/" (s:std_logic_vector;f:std_logic) return integer is
			begin return conv_integer(s) / conv_integer(f);
		end;
		function "/" (f:std_logic;s:integer) return integer is
			begin return s/ conv_integer(f);
		end;
		function "/" (f:std_logic;s:std_logic_vector) return integer is
			begin return conv_integer(s) / conv_integer(f);
		end;	
		function "and" (shape_i: std_logic; fit_i: std_logic_vector) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones AND fit_i;
			else return zeros AND fit_i;
			end if;
		end ;
		function "and" (fit_i: std_logic_vector;shape_i: std_logic) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones AND fit_i;
			else return zeros AND fit_i;
			end if;
		end ;
		function "and" (shape_i: integer; fit_i: std_logic_vector) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) AND fit_i;
		end ;
		function "and" (fit_i: std_logic_vector;shape_i: integer) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) AND fit_i;
		end ;		
		function "and" (shape_i: integer; fit_i: std_logic) return std_logic is
			begin return CSLV(shape_i, fit_i) AND fit_i;
		end ;
		function "and" (fit_i: std_logic;shape_i: integer) return std_logic is
			begin return CSLV(shape_i, fit_i) AND fit_i;
		end ;
		function "or" (shape_i: std_logic; fit_i: std_logic_vector) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones or fit_i;
			else return zeros or fit_i;
			end if;
		end ;
		function "or" (fit_i: std_logic_vector;shape_i: std_logic) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones or fit_i;
			else return zeros or fit_i;
			end if;
		end ;
		function "or" (shape_i: integer; fit_i: std_logic_vector) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) or fit_i;
		end ;
		function "or" (fit_i: std_logic_vector;shape_i: integer) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) or fit_i;
		end ;		
		function "or" (shape_i: integer; fit_i: std_logic) return std_logic is
			begin return CSLV(shape_i, fit_i) or fit_i;
		end ;
		function "or" (fit_i: std_logic;shape_i: integer) return std_logic is
			begin return CSLV(shape_i, fit_i) or fit_i;
		end ;
		function "xnor" (shape_i: std_logic; fit_i: std_logic_vector) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones xnor fit_i;
			else return zeros xnor fit_i;
			end if;
		end ;
		function "xnor" (fit_i: std_logic_vector;shape_i: std_logic) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones xnor fit_i;
			else return zeros xnor fit_i;
			end if;
		end ;
		function "xnor" (shape_i: integer; fit_i: std_logic_vector) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) xnor fit_i;
		end ;
		function "xnor" (fit_i: std_logic_vector;shape_i: integer) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) xnor fit_i;
		end ;		
		function "xnor" (shape_i: integer; fit_i: std_logic) return std_logic is
			begin return CSLV(shape_i, fit_i) xnor fit_i;
		end ;
		function "xnor" (fit_i: std_logic;shape_i: integer) return std_logic is
			begin return CSLV(shape_i, fit_i) xnor fit_i;
		end ;
		function "nand" (shape_i: std_logic; fit_i: std_logic_vector) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones nand fit_i;
			else return zeros nand fit_i;
			end if;
		end ;
		function "nand" (fit_i: std_logic_vector;shape_i: std_logic) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones nand fit_i;
			else return zeros nand fit_i;
			end if;
		end ;
		function "nand" (shape_i: integer; fit_i: std_logic_vector) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) nand fit_i;
		end ;
		function "nand" (fit_i: std_logic_vector;shape_i: integer) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) nand fit_i;
		end ;		
		function "nand" (shape_i: integer; fit_i: std_logic) return std_logic is
			begin return CSLV(shape_i, fit_i) nand fit_i;
		end ;
		function "nand" (fit_i: std_logic;shape_i: integer) return std_logic is
			begin return CSLV(shape_i, fit_i) nand fit_i;
		end ;	
		function "nor" (shape_i: std_logic; fit_i: std_logic_vector) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones nor fit_i;
			else return zeros nor fit_i;
			end if;
		end ;
		function "nor" (fit_i: std_logic_vector;shape_i: std_logic) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones nor fit_i;
			else return zeros nor fit_i;
			end if;
		end ;
		function "nor" (shape_i: integer; fit_i: std_logic_vector) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) nor fit_i;
		end ;
		function "nor" (fit_i: std_logic_vector;shape_i: integer) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) nor fit_i;
		end ;		
		function "nor" (shape_i: integer; fit_i: std_logic) return std_logic is
			begin return CSLV(shape_i, fit_i) nor fit_i;
		end ;
		function "nor" (fit_i: std_logic;shape_i: integer) return std_logic is
			begin return CSLV(shape_i, fit_i) nor fit_i;
		end ;	
		function "xor" (shape_i: std_logic; fit_i: std_logic_vector) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones xor fit_i;
			else return zeros xor fit_i;
			end if;
		end ;
		function "xor" (fit_i: std_logic_vector;shape_i: std_logic) return std_logic_vector is
			constant zeros : std_logic_vector(fit_i'left downto 0) := (others=>'0');
			constant ones : std_logic_vector(fit_i'left downto 0) := (others => '1');
			begin
			if shape_i = '1' then return ones xor fit_i;
			else return zeros xor fit_i;
			end if;
		end ;
		function "xor" (shape_i: integer; fit_i: std_logic_vector) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) xor fit_i;
		end ;
		function "xor" (fit_i: std_logic_vector;shape_i: integer) return std_logic_vector is
			begin return CSLV(shape_i, fit_i) xor fit_i;
		end ;		
		function "xor" (shape_i: integer; fit_i: std_logic) return std_logic is
			begin return CSLV(shape_i, fit_i) xor fit_i;
		end ;
		function "xor" (fit_i: std_logic;shape_i: integer) return std_logic is
			begin return CSLV(shape_i, fit_i) xor fit_i;
		end ;		
		function "and" (s: boolean;f:std_logic) return std_logic is
			begin 
				if s then return '1' AND f; 
				else return '0' AND f; 
				end if;
		end;
		function "and" (s: boolean;f:std_logic_vector) return std_logic_vector is
			begin 
				if s then return '1' AND f;
				else return '0' AND f;
				end if;
		end;
		function "and" (f:integer;s: boolean) return std_logic is
			begin
				if s then return '1' and f;
				else return  '0' and f; 
				end if;
		end;
		function "and" (s: boolean;f:integer) return std_logic is
			begin
				if s then return '1' and f;
				else return '0' and f; 
				end if;
		end;		
		function "and" (f:std_logic;s: boolean) return std_logic is
			begin 
				if s then return '1' AND f; 
				else return '0' and f; 
				end if;
		end;
		function "and" (f:std_logic_vector;s: boolean) return std_logic_vector is
			begin 
				if s then return '1' AND f;
				else return '0' AND f;
				end if;
		end;
		function "xnor" (s: boolean;f:std_logic) return std_logic is
			begin 
				if s then return '1' xnor f; 
				else return '0' xnor f; 
				end if;
		end;
		function "xnor" (s: boolean;f:std_logic_vector) return std_logic_vector is
			begin 
				if s then return '1' xnor f;
				else return '0' xnor f;
				end if;
		end;
		function "xnor" (f:integer;s: boolean) return std_logic is
			begin
				if s then return '1' xnor f;
				else return  '0' xnor f; 
				end if;
		end;
		function "xnor" (s: boolean;f:integer) return std_logic is
			begin
				if s then return '1' xnor f;
				else return '0' xnor f; 
				end if;
		end;		
		function "xnor" (f:std_logic;s: boolean) return std_logic is
			begin 
				if s then return '1' xnor f; 
				else return '0' xnor f; 
				end if;
		end;
		function "xnor" (f:std_logic_vector;s: boolean) return std_logic_vector is
			begin 
				if s then return '1' xnor f;
				else return '0' xnor f;
				end if;
		end;
		function "or" (s: boolean;f:std_logic) return std_logic is
			begin 
				if s then return '1' or f; 
				else return '0' or f; 
				end if;
		end;
		function "or" (s: boolean;f:std_logic_vector) return std_logic_vector is
			begin 
				if s then return '1' or f;
				else return '0' or f;
				end if;
		end;
		function "or" (f:integer;s: boolean) return std_logic is
			begin
				if s then return '1' or f;
				else return  '0' or f; 
				end if;
		end;
		function "or" (s: boolean;f:integer) return std_logic is
			begin
				if s then return '1' or f;
				else return '0' or f; 
				end if;
		end;		
		function "or" (f:std_logic;s: boolean) return std_logic is
			begin 
				if s then return '1' or f; 
				else return '0' or f; 
				end if;
		end;
		function "or" (f:std_logic_vector;s: boolean) return std_logic_vector is
			begin 
				if s then return '1' or f;
				else return '0' or f;
				end if;
		end;
		function "nand" (s: boolean;f:std_logic) return std_logic is
			begin 
				if s then return '1' nand f; 
				else return '0' nand f; 
				end if;
		end;
		function "nand" (s: boolean;f:std_logic_vector) return std_logic_vector is
			begin 
				if s then return '1' nand f;
				else return '0' nand f;
				end if;
		end;
		function "nand" (f:integer;s: boolean) return std_logic is
			begin
				if s then return '1' nand f;
				else return  '0' nand f; 
				end if;
		end;
		function "nand" (s: boolean;f:integer) return std_logic is
			begin
				if s then return '1' nand f;
				else return '0' nand f; 
				end if;
		end;		
		function "nand" (f:std_logic;s: boolean) return std_logic is
			begin 
				if s then return '1' nand f; 
				else return '0' nand f; 
				end if;
		end;
		function "nand" (f:std_logic_vector;s: boolean) return std_logic_vector is
			begin 
				if s then return '1' nand f;
				else return '0' nand f;
				end if;
		end;
		function "NOR" (s: boolean;f:std_logic) return std_logic is
			begin 
				if s then return '1' NOR f; 
				else return '0' NOR f; 
				end if;
		end;
		function "NOR" (s: boolean;f:std_logic_vector) return std_logic_vector is
			begin 
				if s then return '1' NOR f;
				else return '0' NOR f;
				end if;
		end;
		function "NOR" (f:integer;s: boolean) return std_logic is
			begin
				if s then return '1' NOR f;
				else return  '0' NOR f; 
				end if;
		end;
		function "NOR" (s: boolean;f:integer) return std_logic is
			begin
				if s then return '1' NOR f;
				else return '0' NOR f; 
				end if;
		end;		
		function "NOR" (f:std_logic;s: boolean) return std_logic is
			begin 
				if s then return '1' NOR f; 
				else return '0' NOR f; 
				end if;
		end;
		function "NOR" (f:std_logic_vector;s: boolean) return std_logic_vector is
			begin 
				if s then return '1' NOR f;
				else return '0' NOR f;
				end if;
		end;
		function "XOR" (s: boolean;f:std_logic) return std_logic is
			begin 
				if s then return '1' XOR f; 
				else return '0' XOR f; 
				end if;
		end;
		function "XOR" (s: boolean;f:std_logic_vector) return std_logic_vector is
			begin 
				if s then return '1' XOR f;
				else return '0' XOR f;
				end if;
		end;
		function "XOR" (f:integer;s: boolean) return std_logic is
			begin
				if s then return '1' XOR f;
				else return  '0' XOR f; 
				end if;
		end;
		function "XOR" (s: boolean;f:integer) return std_logic is
			begin
				if s then return '1' XOR f;
				else return '0' XOR f; 
				end if;
		end;		
		function "XOR" (f:std_logic;s: boolean) return std_logic is
			begin 
				if s then return '1' XOR f; 
				else return '0' XOR f; 
				end if;
		end;
		function "XOR" (f:std_logic_vector;s: boolean) return std_logic_vector is
			begin 
				if s then return '1' XOR f;
				else return '0' XOR f;
				end if;
		end;
end tools;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.tools.ALL;

entity PlaystationController is
	 port (
		A_i :in std_logic_vector(7 downto 0);
		B_o :out std_logic_vector(7 downto 0);
		Data_arr_o: out std_logic_vector(71 downto 0);
		clock, reset, enable : in std_logic
	);
end PlaystationController;

architecture beh of PlaystationController is
	shared variable A, B: std_logic_vector(7 downto 0) := (others => '0');
	SHARED VARIABLE data_arr: STD_LOGIC_VECTOR(71 downto 0):=  (others => '0')  ;
		signal PC_clock : STD_LOGIC := '0'; 
	signal SM2_clock : STD_LOGIC := '0'; 
begin
	shared_variable_process: process (clock, A_i)
	begin
		A := A_i;
		B_o <= B;
	end process;
----
	PC_clk: process(clock)
		constant max_cnt: Integer:= 50;
		variable clk_cnt: Integer range 0 to max_cnt := 0;
		variable clock_signal: std_logic:= '0';
	begin
		if(clock= '1' and clock'event) then
			clk_cnt := clk_cnt + 1;
			if (clk_cnt >= max_cnt) then
				clock_signal := not clock_signal;
				clk_cnt := 0;
			end if;
		PC_clock <= clock_signal;
		end if;
	end process;
--------------------------------------------------------------------------
	PC_process : process(PC_clock, reset, enable) 
		ALIAS A0 is A(0);ALIAS A1 is A(1);ALIAS A2 is A(2);ALIAS A3 is A(3);ALIAS A4 is A(4);ALIAS A5 is A(5);ALIAS A6 is A(6);ALIAS A7 is A(7);
		ALIAS B0 is B(0);ALIAS B1 is B(1);ALIAS B2 is B(2);ALIAS B3 is B(3);ALIAS B4 is B(4);ALIAS B5 is B(5);ALIAS B6 is B(6);ALIAS B7 is B(7);
		type PC_States is (PC_ATT_high,PC_delay0,PC_clk_dn0,PC_clk_up0);
		VARIABLE PC_state : PC_States := PC_ATT_high; 
		VARIABLE cnt: STD_LOGIC_VECTOR(3 downto 0):= (others=>'0') ;
		VARIABLE index: STD_LOGIC_VECTOR(2 downto 0):= (others=>'0') ;
		VARIABLE d_index: STD_LOGIC_VECTOR(6 downto 0):= (others=>'0') ;
		CONSTANT cmd_arr: STD_LOGIC_VECTOR(71 downto 0):= x"000000000000004201" ;
		alias ps_dat_i is a7;
		alias ps_cmd_o is b7;
		alias ps_att_o is b6;
		alias ps_clk_o is b5;
		
	begin
	IF( PC_clock = '1' and PC_clock'event )THEN
		IF(reset = '1')then--STATE machine begin
			PC_state := PC_ATT_high;
		ELSIF(enable = '1') then
			case PC_state  is  -- Transitions
				when PC_ATT_high => 
					if (cnt  /=  x"F") then
						PC_state := PC_ATT_high;
						cnt   := CSLV(  cnt  +  1, cnt  );
					elsif (cnt = x"F") then
						PC_state := PC_delay0;
						cnt  := CSLV(  0, cnt );
						d_index  := CSLV(  0, d_index );
					else
						PC_state := PC_ATT_high;
					end if; 
				when PC_delay0 => 
					if (cnt = x"F" and d_index < 71) then
						PC_state := PC_clk_dn0;
						cnt  := CSLV(  0, cnt );
					elsif (cnt  /=  x"F") then
						PC_state := PC_delay0;
						cnt   := CSLV(  cnt  +  1, cnt  );
					elsif (cnt = x"F" and d_index >= 71) then
						PC_state := PC_ATT_high;
						cnt  := CSLV(  0, cnt );
					else
						PC_state := PC_delay0;
					end if; 
				when PC_clk_dn0 => 
					if (cnt  /=  0) then
						PC_state := PC_clk_up0;
						cnt  := CSLV(  0, cnt );
					elsif (cnt = 0) then
						PC_state := PC_clk_dn0;
						cnt   := CSLV(  cnt  +  1, cnt  );
					else
						PC_state := PC_clk_dn0;
					end if; 
				when PC_clk_up0 => 
					if (cnt = 0) then
						PC_state := PC_clk_up0;
						cnt   := CSLV(  cnt  +  1, cnt  );
					elsif (cnt  /=  0 AND index  /=  "111") then
						PC_state := PC_clk_dn0;
						cnt  := CSLV(  0, cnt );
						index   := CSLV(  index  +  1, index  );
						d_index   := CSLV(  d_index  +  1, d_index  );
					elsif (cnt  /=  0 AND index = "111") then
						PC_state := PC_delay0;
						cnt  := CSLV(  0, cnt );
						index  := CSLV(  0, index );
						d_index   := CSLV(  d_index  +  1, d_index  );
					else
						PC_state := PC_clk_up0;
					end if; 
				when others =>
					PC_state := PC_ATT_high;
			 end case; -- endTransitions

			case PC_state is -- State actions
				when  PC_ATT_high =>
						PS_ATT_o := '1';
						PS_CLK_o := '1';
						PS_CMD_o := '1';

				when  PC_delay0 =>
						PS_ATT_o := '0';

				when  PC_clk_dn0 =>
						PS_CLK_o := '0';
						PS_CMD_o := CMD_arr(conv_integer(d_index));

				when  PC_clk_up0 =>
						PS_CLK_o := '1';
						data_arr(conv_integer(d_index)) := PS_DAT_i;

			end case;  -- end State actions

		 end if;--STATE machine end
	END IF;--end clock events 
	end process;
---- 
	SM2_clk: process(clock)
		constant max_cnt: Integer:= 500000;
		variable clk_cnt: Integer range 0 to max_cnt := 0;
		variable clock_signal: std_logic:= '0';
	begin
		if(clock= '1' and clock'event) then
			clk_cnt := clk_cnt + 1;
			if (clk_cnt >= max_cnt) then
				clock_signal := not clock_signal;
				clk_cnt := 0;
			end if;
		SM2_clock <= clock_signal;
		end if;
	end process;
--------------------------------------------------------------------------
	SM2_process : process(SM2_clock, reset, enable) 
		ALIAS A0 is A(0);ALIAS A1 is A(1);ALIAS A2 is A(2);ALIAS A3 is A(3);ALIAS A4 is A(4);ALIAS A5 is A(5);ALIAS A6 is A(6);ALIAS A7 is A(7);
		ALIAS B0 is B(0);ALIAS B1 is B(1);ALIAS B2 is B(2);ALIAS B3 is B(3);ALIAS B4 is B(4);ALIAS B5 is B(5);ALIAS B6 is B(6);ALIAS B7 is B(7);
		type SM2_States is (SM2_s0);
		VARIABLE SM2_state : SM2_States := SM2_s0; 
		VARIABLE sel_v: STD_LOGIC_VECTOR(4 downto 0):= (others=>'0') ;
		alias sel_i is a(4 downto 0);
		alias  reg_value is b(3 downto 0);
		
	begin
	IF( SM2_clock = '1' and SM2_clock'event )THEN
		IF(reset = '1')then--STATE machine begin
			SM2_state := SM2_s0;
		ELSIF(enable = '1') then
			case SM2_state  is  -- Transitions
				when SM2_s0 => 
					if ( TRUE ) then
						SM2_state := SM2_s0;

					else
						SM2_state := SM2_s0;
					end if; 
				when others =>
					SM2_state := SM2_s0;
			 end case; -- endTransitions

			case SM2_state is -- State actions
				when  SM2_s0 =>
						SEL_v := SEL_i;
						REG_Value := Data_arr(conv_integer(((SEL_v+1)* 4)-1) downto conv_integer(SEL_v* 4) ); -- place data 4 bits at a time using mux to see more and more.  This method was used to fulfill the constraint placed by the RIB's program;
						data_arr_o <= data_arr; --outputing the whole thing;
			end case;  -- end State actions

		 end if;--STATE machine end
	END IF;--end clock events 
	end process;
---- 
end beh;
