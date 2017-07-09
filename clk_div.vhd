library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clk_div is port(
	clk50 : in std_logic;
	clk9600, clk1, clk25, clk2, clk3, clk500 : out std_logic);
end clk_div;

architecture be of clk_div is


signal cnt : integer range 0 to 5208 := 0;
signal max : integer := 5208;
signal half : integer := max/2;

signal cnt_2 : integer range 0 to 150000 := 0;
signal max_2 : integer := 150000;
signal half_2 : integer := max_2/2;

signal cnt_3 : integer range 0 to 70000000 := 0;
signal max_3 : integer := 70000000;
signal half_3 : integer := max_3/2;

signal cnt33 : integer range 0 to 15000000; --3.3hz
signal max33: integer  := 15000000;
signal half33 : integer  := max33/2;

signal cnt_500  : integer range 0 to 100000; --500hz
signal max_500  : integer := 100000;
signal half_500 : integer := max/2;

signal clk_cnt : std_logic;

begin

	 process(clk50)
        begin
                if falling_edge(clk50) then
                        if (cnt_500 < max_500) then
                                cnt_500 <= cnt_500 + 1;
                        else
                                cnt_500 <= 0;
                        end if;
        
                        if (cnt_500 < half_500) then
                                clk500 <= '0';
                        else
                                clk500 <= '1';
                        end if;
                end if;	
		  end process; 
		  
	process(clk50)
		begin
			if falling_edge(clk50) then
				if (cnt <= max) then
					cnt <= cnt + 1;
				else
					cnt <= 0;
				end if;
				
				if (cnt <= half) then
					clk9600 <= '0';
				else
					clk9600 <= '1';
				end if;
			end if;
   end process;
	
	process(clk50)
		begin
			if falling_edge(clk50) then
				if (cnt_2 <= max_2) then
					cnt_2 <= cnt_2 + 1;
				else
					cnt_2 <= 0;
				end if;
				
				if (cnt_2 <= half_2) then
					clk1 <= '0';
				else
					clk1 <= '1';
				end if;
			end if;
   end process;
	
	process(clk50)
		begin
			if falling_edge(clk50) then
				if (cnt_3 <= max_3) then
					cnt_3 <= cnt_3 + 1;
				else
					cnt_3 <= 0;
				end if;
				
				if (cnt_3 <= half_3) then
					clk2 <= '0';
				else
					clk2 <= '1';
				end if;
			end if;
   end process;
	
	process(clk50) --clk monitor 25MHz
	begin
		if rising_edge(clk50) then
			clk_cnt <= not clk_cnt;
		end if;
		clk25 <= clk_cnt;
	end process;
	
process(clk50)
  begin
			if falling_edge(clk50) then
						if (cnt33 < max33) then
								  cnt33 <= cnt33 + 1;
						else
								  cnt33 <= 0;
						end if;
  
						if (cnt33 < half33) then
								  clk3 <= '0';
						else
								  clk3 <= '1';
						end if;
			 end if;
  end process;
	
end be;