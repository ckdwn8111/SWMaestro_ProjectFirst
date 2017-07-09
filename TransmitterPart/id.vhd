library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity id is port(
	clk3 : in std_logic;
	segl1, segl2, segl3, segl4 : out std_logic_vector(6 downto 0));
end id;

architecture be of id is

signal cnt : integer range 0 to 16 := 0;

begin
	process(clk3)
		begin
--			if sw2 = '1' then
				if falling_edge(clk3) then
					if cnt = 16 then
						cnt <= 0;
					else
						cnt <= cnt + 1;
					end if;
				end if;
				
				case cnt is
					when 0 =>
								segl1 <= "0100100";--2
								segl2 <= "1111111";
								segl3 <= "1111111";
								segl4 <= "1111111";
					when 1 =>
								segl1 <= "1000000";--0
								segl2 <= "0100100";--2
								segl3 <= "1111111";
								segl4 <= "1111111";
					when 2 =>
								segl1 <= "1111001";--1
								segl2 <= "1000000";--0
								segl3 <= "0100100";--2
								segl4 <= "1111111";
					when 3 =>
								segl1 <= "0100100";--2
								segl2 <= "1111001";--1
								segl3 <= "1000000";--0
								segl4 <= "0100100";--2
					when 4 =>
								segl1 <= "1111001";--1 
								segl2 <= "0100100";--2
								segl3 <= "1111001";--1
								segl4 <= "1000000";--0
					when 5 =>
								segl1 <= "0110000";--3 
								segl2 <= "1111001";--1
								segl3 <= "0100100";--2
								segl4 <= "1111001";--1
					when 6 =>
								segl1 <= "0100100";--2
								segl2 <= "0110000";--3 
								segl3 <= "1111001";--1
								segl4 <= "0100100";--2
					when 7 =>
								segl1 <= "0100100";--2
								segl2 <= "0100100";--2
								segl3 <= "0110000";--3
								segl4 <= "1111001";--1
					when 8 =>
								segl1 <= "1111000";--7 
								segl2 <= "0100100";--2
								segl3 <= "0100100";--2
								segl4 <= "0110000";--3
					when 9 =>
								segl1 <= "1111111";
								segl2 <= "1111000";--7
								segl3 <= "0100100";--2
								segl4 <= "0100100";--2
					when 10 =>
								segl1 <= "1111111";
								segl2 <= "1111111";
								segl3 <= "1111000";--7
								segl4 <= "0100100";--2
					when 11 =>
								segl1 <= "1111111";
								segl2 <= "1111111";
								segl3 <= "1111111";
								segl4 <= "1111000";--7
					when 12 =>
								segl1 <= "1111111";
								segl2 <= "1111111";
								segl3 <= "1111111";
								segl4 <= "1111111";
					when 13 =>
								segl1 <= "0100011";--o
								segl2 <= "0010010";--S
								segl3 <= "1100001";--J
								segl4 <= "1000110";--C
					when 14 =>
								segl1 <= "1111111";
								segl2 <= "1111111";
								segl3 <= "1111111";
								segl4 <= "1111111";
					when 15 =>
								segl1 <= "0100011";--o
								segl2 <= "0010010";--S
								segl3 <= "1100001";--J
								segl4 <= "1000110";--C
					when 16 =>
								segl1 <= "1111111";
								segl2 <= "1111111";
								segl3 <= "1111111";
								segl4 <= "1111111";
					when others => null;
				end case;
--			else
--				segl1 <= "1111111";
--				segl2 <= "1111111";
--				segl3 <= "1111111";
--				segl4 <= "1111111";
--				cnt <= 0;
--			end if;
		end process;
end be;				
		