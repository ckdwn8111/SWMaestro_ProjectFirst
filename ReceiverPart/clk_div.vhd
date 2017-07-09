library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clk_div is port(
	clk50 : in std_logic;
	clk9600, clk1 : out std_logic);
end clk_div;

architecture be of clk_div is


signal cnt : integer range 0 to 5208 := 0;
signal max : integer := 5208;
signal half : integer := max/2;

signal cnt_2 : integer range 0 to 50000000 := 0;
signal max_2 : integer := 50000000;
signal half_2 : integer := max/2;

begin
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
end be;