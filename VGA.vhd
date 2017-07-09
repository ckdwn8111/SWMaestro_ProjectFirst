library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity VGA is port(
	rst		 : in  std_logic;
	clk25	    : in  std_logic;
	clk1		 : in	 std_logic;
	clk2		 : in  std_logic;
	scancode  : in std_logic_vector(7 downto 0);
	--rom
	addr_1, addr_2, addr_3, addr_4, addr_5, addr_6, addr_7, addr_8	 : out std_logic_vector(12 downto 0);
	data_1, data_2, data_3, data_4, data_5, data_6, data_7, data_8	 : in  std_logic_vector(23 downto 0);
	addr_11, addr_22, addr_33, addr_44, addr_55, addr_66, addr_77, addr_88	 : out std_logic_vector(12 downto 0);
	data_11, data_22, data_33, data_44, data_55, data_66, data_77, data_88	 : in  std_logic_vector(23 downto 0);
	addr_car : out std_logic_vector(13 downto 0);
	data_car : in std_logic_vector(23 downto 0);
	vga_clk   : out std_logic;
	--vga
	vga_hs    : out std_logic;
	vga_vs    : out std_logic;
	vga_blank : out std_logic;
	vga_sync  : out std_logic; 
	vga_red   : out std_logic_vector(7 downto 0);
	vga_green : out std_logic_vector(7 downto 0);
	vga_blue  : out std_logic_vector(7 downto 0)
);
end VGA;

architecture be of VGA is

-- counting variable
signal H_cnt : std_logic_vector(10 downto 0);
signal V_cnt : std_logic_vector(9 downto 0);

-- Set VGA timing variable
							  -- 640*480
signal H_SYNC: integer := 96;
signal H_BACK: integer := 48;
signal H_FRONT:integer := 16;
signal H_ACT  :integer := 640;
signal H_TOTAL:integer := 800;

constant V_SYNC: integer := 2;
constant V_BACK: integer := 33;
constant V_FRONT:integer := 10;
constant V_ACT  :integer := 480;
constant V_TOTAL:integer := 525;
constant move_max : integer := 525;

signal move_y : integer range 0 to move_max := 0;

-- RGB data_1 bus
signal red, green, blue : std_logic_vector(7 downto 0);

-- rom data_1
signal address_1, address_2, address_3, address_4, address_5, address_6, address_7, address_8 : std_logic_vector(12 downto 0);
signal address_11, address_22, address_33, address_44, address_55, address_66, address_77, address_88 : std_logic_vector(12 downto 0);
signal address_car : std_logic_vector(13 downto 0);


begin

------------------------------------------------------------------------------1. H_cnt, V_cnt counting
	process(rst, clk25) -- counting the size of frame
	begin
		if rst = '1' then
			H_cnt <= (others=>'0');
			V_cnt <= (others=>'0');
		elsif rising_edge(clk25) then
			if(H_cnt>=H_TOTAL-1) then
				H_cnt<=(others=>'0');
				if(V_cnt >=V_TOTAL-1) then
					V_cnt<=(others=>'0');
				else
					V_cnt<=V_cnt+1;
				end if;
			else
				H_cnt<=H_cnt+1;
			end if;
		end if;
	end process;

----------------------------------------------------------------------------------------------------------
	process(clk25)
	begin
		if rising_edge(clk25) then
		
---------------------------------------------------------------------------------------------------------road_line		
			if (H_cnt >= H_SYNC+H_BACK + 150) and (H_cnt <= H_SYNC+H_BACK + 200) then
				red   <= (others => '0');
				green <= (others => '0');
				blue  <= (others => '0');
			elsif (H_cnt >= H_SYNC+H_BACK + 440) and (H_cnt <= H_SYNC+H_BACK + 490) then
				red   <= (others => '0');
				green <= (others => '0');
				blue  <= (others => '0');			
---------------------------------------------------------------------------------------------------------left_tree						
			elsif (H_cnt >= H_SYNC+H_BACK + 30) and (H_cnt < H_SYNC+H_BACK+ 110) and (V_cnt >= V_SYNC+V_BACK + move_y) and (V_cnt < V_SYNC+V_BACK + 80 + move_y) then --rom 1
				red   <= data_1(23 downto 16);
				green <= data_1(15 downto 8);
				blue  <= data_1( 7 downto 0);
				address_1  <= address_1 + '1';
			elsif (H_cnt >= H_SYNC+H_BACK + 30) and (H_cnt < H_SYNC+H_BACK+ 110) and (V_cnt >= V_SYNC+V_BACK - (move_max - move_y)) and (V_cnt < V_SYNC+V_BACK + 80 - (move_max - move_y)) then --rom 1
				red   <= data_2(23 downto 16);
				green <= data_2(15 downto 8);
				blue  <= data_2( 7 downto 0);
				address_2  <= address_2 + '1';	
			elsif (H_cnt >= H_SYNC+H_BACK + 30) and (H_cnt < H_SYNC+H_BACK+ 110) and (V_cnt >= V_SYNC+V_BACK + move_y + 135) and (V_cnt < V_SYNC+V_BACK + 80 + move_y + 135) then --rom 2
				red   <= data_3(23 downto 16);
				green <= data_3(15 downto 8);
				blue  <= data_3( 7 downto 0);
				address_3  <= address_3 + '1';
			elsif (H_cnt >= H_SYNC+H_BACK + 30) and (H_cnt < H_SYNC+H_BACK+ 110) and (V_cnt >= V_SYNC+V_BACK - (move_max - move_y) + 135) and (V_cnt < V_SYNC+V_BACK + 80 - (move_max - move_y) + 135) then --rom 2
				red   <= data_4(23 downto 16);
				green <= data_4(15 downto 8);
				blue  <= data_4( 7 downto 0);
				address_4 <= address_4 + '1';
				
				
			elsif (H_cnt >= H_SYNC+H_BACK + 30) and (H_cnt < H_SYNC+H_BACK+ 110) and (V_cnt >= V_SYNC+V_BACK + move_y + 270) and (V_cnt < V_SYNC+V_BACK + 80 + move_y + 270) then --rom 2
				red   <= data_5(23 downto 16);
				green <= data_5(15 downto 8);
				blue  <= data_5( 7 downto 0);
				address_5  <= address_5 + '1';
			elsif (H_cnt >= H_SYNC+H_BACK + 30) and (H_cnt < H_SYNC+H_BACK+ 110) and (V_cnt >= V_SYNC+V_BACK - (move_max - move_y) + 270) and (V_cnt < V_SYNC+V_BACK + 80 - (move_max - move_y) + 270) then --rom 2
				red   <= data_6(23 downto 16);
				green <= data_6(15 downto 8);
				blue  <= data_6( 7 downto 0);
				address_6  <= address_6 + '1';
				
			elsif (H_cnt >= H_SYNC+H_BACK + 30) and (H_cnt < H_SYNC+H_BACK+ 110) and (V_cnt >= V_SYNC+V_BACK + move_y + 405) and (V_cnt < V_SYNC+V_BACK + 80 + move_y + 405) then --rom 2
				red   <= data_7(23 downto 16);
				green <= data_7(15 downto 8);
				blue  <= data_7( 7 downto 0);
				address_7  <= address_7 + '1';
			elsif (H_cnt >= H_SYNC+H_BACK + 30) and (H_cnt < H_SYNC+H_BACK+ 110) and (V_cnt >= V_SYNC+V_BACK - (move_max - move_y) + 405) and (V_cnt < V_SYNC+V_BACK + 80 - (move_max - move_y) + 405) then --rom 2
				red   <= data_8(23 downto 16);
				green <= data_8(15 downto 8);
				blue  <= data_8( 7 downto 0);
				address_8  <= address_8 + '1';
				
--------------------------------------------------------------------------------------------------right_tree
				
			elsif (H_cnt >= H_SYNC+H_BACK + 530) and (H_cnt < H_SYNC+H_BACK+ 610) and (V_cnt >= V_SYNC+V_BACK + move_y) and (V_cnt < V_SYNC+V_BACK + 80 + move_y) then --rom 1
				red   <= data_11(23 downto 16);
				green <= data_11(15 downto 8);
				blue  <= data_11( 7 downto 0);
				address_11  <= address_11 + '1';
			elsif (H_cnt >= H_SYNC+H_BACK + 530) and (H_cnt < H_SYNC+H_BACK+ 610) and (V_cnt >= V_SYNC+V_BACK - (move_max - move_y)) and (V_cnt < V_SYNC+V_BACK + 80 - (move_max - move_y)) then --rom 1
				red   <= data_22(23 downto 16);
				green <= data_22(15 downto 8);
				blue  <= data_22( 7 downto 0);
				address_22  <= address_22 + '1';	
			elsif (H_cnt >= H_SYNC+H_BACK + 530) and (H_cnt < H_SYNC+H_BACK+ 610) and (V_cnt >= V_SYNC+V_BACK + move_y + 135) and (V_cnt < V_SYNC+V_BACK + 80 + move_y + 135) then --rom 2
				red   <= data_33(23 downto 16);
				green <= data_33(15 downto 8);
				blue  <= data_33( 7 downto 0);
				address_33  <= address_33 + '1';
			elsif (H_cnt >= H_SYNC+H_BACK + 530) and (H_cnt < H_SYNC+H_BACK+ 610) and (V_cnt >= V_SYNC+V_BACK - (move_max - move_y) + 135) and (V_cnt < V_SYNC+V_BACK + 80 - (move_max - move_y) + 135) then --rom 2
				red   <= data_44(23 downto 16);
				green <= data_44(15 downto 8);
				blue  <= data_44( 7 downto 0);
				address_44  <= address_44 + '1';
				
				
			elsif (H_cnt >= H_SYNC+H_BACK + 530) and (H_cnt < H_SYNC+H_BACK+ 610) and (V_cnt >= V_SYNC+V_BACK + move_y + 270) and (V_cnt < V_SYNC+V_BACK + 80 + move_y + 270) then --rom 2
				red   <= data_55(23 downto 16);
				green <= data_55(15 downto 8);
				blue  <= data_55( 7 downto 0);
				address_55  <= address_55 + '1';
			elsif (H_cnt >= H_SYNC+H_BACK + 530) and (H_cnt < H_SYNC+H_BACK+ 610) and (V_cnt >= V_SYNC+V_BACK - (move_max - move_y) + 270) and (V_cnt < V_SYNC+V_BACK + 80 - (move_max - move_y) + 270) then --rom 2
				red   <= data_66(23 downto 16);
				green <= data_66(15 downto 8);
				blue  <= data_66( 7 downto 0);
				address_66  <= address_66 + '1';
				
			elsif (H_cnt >= H_SYNC+H_BACK + 530) and (H_cnt < H_SYNC+H_BACK+ 610) and (V_cnt >= V_SYNC+V_BACK + move_y + 405) and (V_cnt < V_SYNC+V_BACK + 80 + move_y + 405) then --rom 2
				red   <= data_77(23 downto 16);
				green <= data_77(15 downto 8);
				blue  <= data_77( 7 downto 0);
				address_77  <= address_77 + '1';
			elsif (H_cnt >= H_SYNC+H_BACK + 530) and (H_cnt < H_SYNC+H_BACK+ 610) and (V_cnt >= V_SYNC+V_BACK - (move_max - move_y) + 405) and (V_cnt < V_SYNC+V_BACK + 80 - (move_max - move_y) + 405) then --rom 2
				red   <= data_88(23 downto 16);
				green <= data_88(15 downto 8);
				blue  <= data_88( 7 downto 0);
				address_88  <= address_88 + '1';	
----------------------------------------------------------------------------------------------------------car
			
			elsif ((H_cnt >= H_SYNC+H_BACK + 280) and (H_cnt < H_SYNC+H_BACK + 360)) and ((V_cnt >= V_SYNC+V_BACK + 160) and (V_cnt < V_SYNC+V_BACK + 320)) then
				red   <= data_car(23 downto 16);
				green <= data_car(15 downto 8);
				blue  <= data_car( 7 downto 0);
				address_car <= address_car + '1';
			
-----------------------------------------------------------------------------------------------------------central_road_line
			
			elsif (H_cnt >= H_SYNC+H_BACK + 300) and (H_cnt < H_SYNC+H_BACK + 340) and (V_cnt >=  move_y) and (V_cnt < V_SYNC+V_BACK + move_y + 125 ) then
				red   <= (others => '0');
				green <= (others => '0');
				blue  <= (others => '0');
			elsif (H_cnt >= H_SYNC+H_BACK + 300) and (H_cnt < H_SYNC+H_BACK + 340) and (V_cnt >= - (move_max - move_y)) and (V_cnt < - (move_max - move_y) + 125) then
				red   <= (others => '0');
				green <= (others => '0');
				blue  <= (others => '0');	
			
			elsif (H_cnt >= H_SYNC+H_BACK + 300) and (H_cnt < H_SYNC+H_BACK + 340) and (V_cnt >= move_y + 175) and (V_cnt < move_y + 300) then
				red   <= (others => '0');
				green <= (others => '0');
				blue  <= (others => '0');
			elsif (H_cnt >= H_SYNC+H_BACK + 300) and (H_cnt < H_SYNC+H_BACK + 340) and (V_cnt >= 175 - (move_max - move_y)) and (V_cnt < 300 - (move_max - move_y)) then
				red   <= (others => '0');
				green <= (others => '0');
				blue  <= (others => '0');	
			elsif (H_cnt >= H_SYNC+H_BACK + 300) and (H_cnt < H_SYNC+H_BACK + 340) and (V_cnt >= move_y + 350) and (V_cnt < move_y + 475) then
				red   <= (others => '0');
				green <= (others => '0');
				blue  <= (others => '0');
			elsif (H_cnt >= H_SYNC+H_BACK + 300) and (H_cnt < H_SYNC+H_BACK + 340) and (V_cnt >= 350 - (move_max - move_y)) and (V_cnt < 475 - (move_max - move_y)) then
				red   <= (others => '0');
				green <= (others => '0');
				blue  <= (others => '0');	
	
---------------------------------------------------------------------------------------------------------------car_blink	
			elsif (H_cnt >= H_SYNC+H_BACK + 360) and (H_cnt < H_SYNC+H_BACK + 400) and (V_cnt >= V_SYNC+V_BACK + 140) and (V_cnt < V_SYNC+V_BACK + 160) then
				if clk2 = '1' then
					if scancode = x"23" then					
						red   <= (others => '1');
						green <= (others => '1');
						blue  <= (others => '0');
					else
						red   <= (others => '1');
						green <= (others => '1');
						blue  <= (others => '1');
					end if;
				else
					red   <= (others => '1');
					green <= (others => '1');
					blue  <= (others => '1');
				end if;
			elsif (H_cnt >= H_SYNC+H_BACK + 240) and (H_cnt < H_SYNC+H_BACK + 280) and (V_cnt >= V_SYNC+V_BACK + 140) and (V_cnt < V_SYNC+V_BACK + 160) then
				if clk2 = '1' then
					if scancode = x"1c" then					
						red   <= (others => '1');
						green <= (others => '1');
						blue  <= (others => '0');
					else
						red   <= (others => '1');
						green <= (others => '1');
						blue  <= (others => '1');
					end if;
				else
					red   <= (others => '1');
					green <= (others => '1');
					blue  <= (others => '1');
				end if;
---------------------------------------------------------------------------------------------------------------------				
			else
				red   <= (others => '1');
				green <= (others => '1');
				blue  <= (others => '1');
			end if;
			
			
			
			if (V_cnt <= V_SYNC) then
				address_1 <= (others => '0');
				address_2 <= (others => '0');
				address_3 <= (others => '0');
				address_4 <= (others => '0');
				address_5 <= (others => '0');
				address_6 <= (others => '0');
				address_7 <= (others => '0');
				address_8 <= (others => '0');
				
				address_11 <= (others => '0');
				address_22 <= (others => '0');
				address_33 <= (others => '0');
				address_44 <= (others => '0');
				address_55 <= (others => '0');
				address_66 <= (others => '0');
				address_77 <= (others => '0');
				address_88 <= (others => '0');
				address_car <= (others => '0');
			end if;
			addr_1 <= address_1;
			addr_2 <= address_2;
			addr_3 <= address_3;
			addr_4 <= address_4;
			addr_5 <= address_5;
			addr_6 <= address_6;
			addr_7 <= address_7;
			addr_8 <= address_8;
			addr_11 <= address_11;
			addr_22 <= address_22;
			addr_33 <= address_33;
			addr_44 <= address_44;
			addr_55 <= address_55;
			addr_66 <= address_66;
			addr_77 <= address_77;
			addr_88 <= address_88;
			addr_car <= address_car;
		end if;
	end process;

	process(scancode, clk1)
	begin
		if rising_edge(clk1) then
			if scancode = x"1d" then
				if move_y >= move_max then
					move_y <= 0;
				else
					move_y <= move_y + 1;
				end if;
			end if;
			
			if scancode = x"1b" then
				if move_y <= 0 then
					move_y <= move_max;
				else
					move_y <= move_y - 1;
				end if;
			end if;
		end if;
	end process;
	
------------------------------------------------------------------------------3. VGA 출력부 설정
	vga_clk<= clk25;
	vga_hs <= '0' when  (H_cnt <= H_SYNC) else '1';								  -- H sync
	vga_vs <= '0' when  (V_cnt <= V_SYNC) else '1';								  -- V sync
	vga_blank<= '1' when((H_cnt > H_SYNC + H_BACK) and (H_cnt <= H_TOTAL-H_FRONT)) 		 	  -- 출력할 화면은 '1'로 설정 '0' 일경우 출력안됌
					    and ((V_cnt > V_SYNC + V_BACK) and (V_cnt <= V_TOTAL-V_FRONT))else '0';
	--vga_sync <= '0' when (H_cnt >= H_SYNC + H_BACK) and (H_cnt <= H_TOTAL-( (H_ACT/2)+ H_FRONT )) else '1'; -- Sync On Green '1'로 set 되어있으면 이상적인 색의 값이 출력됌
	vga_sync <= '1';
	vga_red   <= red;
	vga_green <= green;
	vga_blue  <= blue;
end be;