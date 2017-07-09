library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


package data_pack_in is
	type rx_array is array(0 to 15) of std_logic_vector(7 downto 0);
end package;
 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_pack_in.all;

entity clcd is 
        generic( 
                delay_cnt : integer :=50); --delay_cnt=50
        port (
                clk, clk9600, key3, key2, sw1, key0 : in std_logic;
					 data_in : in rx_array;
					 rw,en,rs,v0 : out std_logic;
					 data_out : out std_logic_vector (7 downto 0));
end clcd;

architecture be of clcd is

        subtype WORD is std_logic_vector(7 downto 0); -- Use 8bit to write down the word what i want to type
        type DDRAM is array(0 to 15) of WORD;                   --DDRAM[0] ~ DDRAM[15]

        signal Line0, Line1 : DDRAM;         --Line1,2[0] ~ Line1,2[15] because Line0 and Line1 is DDRAM type
        type STATE is (Wait_V0, Init, Line_0, Set_Add, Line_1, Wait_Vi, Go_Home);  --kinds of STATE
        signal ST : STATE:= Wait_V0;         --ST become State Type, Initial value is Wait_V0
        signal MUX_wire, clk_out, stop_sig : std_logic;  --Role of enable, stop_sig is not used
        signal init_count : integer range 0 to 127 := 0;         -- Initial value is '0'. Range: 0 to 127
		  signal num : integer range 0 to 15;
		  constant arr_length : integer := 15;
		  
begin
        process(clk)
        begin

                if rising_edge(clk) then -- clk_out is [1/10 * clk(50MHz)] = 5MHz
                        case ST is                              --following the State, excute condition. Initial value is Wait_V0
                        
                        when Wait_V0 =>                         --Function set
                                MUX_wire <= '1';          --LCD enable becomes '1'
                                v0 <= '1';                          --LCD Power ON
                                
                                if init_count < delay_cnt then --Wait for more than 40ms after V0 rises to 4.5V, BF can not be checked before this instruction.
                                        init_count <= init_count+1;
                                else 
                                        init_count <= 0;
                                        ST <= Init;          --Present State becomes Init.
                                end if;
                                
                        when Init =>                          --following the Present State(ST), excute condition
                                MUX_wire <= '0';     --LCD enable becomes '1'
                                case init_count is
                                when 0 =>        v0 <= '1'; --LCD Power ON
                                        --Function Set 1
                                                        rs <= '0'; --LCD Select, 0=Command
                                                        rw <= '0'; --Read/Write Select, 0=Write
                                                        data_out <= "00110010"; --Function set 1
                                                        init_count <= init_count+1;
                                                        stop_sig <= '0'; 
                                when 1 =>        v0 <= '1';
                                        -- Function Set 2
                                                        rs <= '0';
                                                        rw <= '0';
                                                        data_out <= "00111000"; --Function set 2
                                                        init_count <= init_count+1;
                                                        stop_sig <= '0';
                                when 2 =>        v0 <= '1';
                                        -- Display ON/OFF contriol
                                                        rs <= '0'; 
                                                        rw <= '0';
                                                        data_out <= "00001100"; --Display ON/OFF control
                                                        init_count <= init_count+1;
                                                        stop_sig <= '0';
                                when 3 =>        v0 <= '1';
                                        -- Display Clear
                                                        rs <= '0';
                                                        rw <= '0';
                                                        data_out <= "00000001"; --Display Clear
                                                        init_count <= init_count+1;
                                                        stop_sig <= '0';
                                when 4 =>        v0 <= '1';
                                        -- Entry Mode
                                                        rs <= '0';
                                                        rw <= '0';
                                                        data_out <= "00000110"; --Entry Mode
                                                        init_count <= 0;
                                                        stop_sig <= '0';
                                        --< end init
                                                        ST <= Line_0; --Present State becomes Line_0
                                when others =>        v0 <= '1';
                                                        rs <= '0'; 
                                                        rw <= '0';
                                                        data_out <= "00000000"; 
                                                        init_count <= 0;
                                                        stop_sig <= '0';    
                                end case; -- end iitialization
                                        
                        when Line_0 =>           --LCD Address set 1
                                v0 <= '1';     --LCD Power ON
                                rs <= '1';           --LCD Select, 1=Data
                                rw <= '0';           --Read/Write Select, 0=Write
                                data_out <= Line0(init_count); --Line0(0)~Line(15), Set each address
                                stop_sig <= '0';
                                
                                if init_count < 16 then
                                        init_count <= init_count+1; --init_count = 0~15
                                else 
                                        init_count <= 0; --init_count = '0'
                                        ST <= Set_Add; --Present State becomes Set_Add
                                end if;
                        when Set_Add =>           --To LCD Address set2
                                v0 <= '1';     --LCD Power ON
                                rs <= '0';           --LCD Select, 0=Command
                                rw <= '0';           --Read/Write Select, 0=Write
                                data_out <= "10101000"; --Use DDRAM Address, Move Cursor to second line
                                stop_sig <= '0';
                                ST <= Line_1;
                        when Line_1 =>           --LCD Address set 2
                                v0 <= '1';     --LCD Power ON
                                rs <= '1';           --LCD Select, 1=Data
                                rw <= '0';           --Read/Write Select, 0=Write
                                data_out <= Line1(init_count);--Line1(0)~Line(15), Set each address
                                stop_sig <= '0';
                        
                                if init_count < 16 then
                                        init_count <= init_count+1;
                                else 
                                        init_count <= 0;  
                                        ST <= Wait_Vi;  --end set and Present State becomes Wait_Vi
                                end if;
                        when Wait_Vi =>                        --delay : excution time 1.53ms
                                MUX_wire <= '1';        --LCD enable becomes '1'
                                v0 <= '1';                        --LCD Power ON
                                
                                if init_count < delay_cnt then
                                        init_count <= init_count+1;
                                else 
                                        init_count <= 0;
                                        ST <= Go_Home;        --Present State becomes Go_Home
                                end if;
                        when Go_Home => --Set DDRAM address to "00H" from AC and return cursor to its original position, contents are not changed
                                MUX_wire <= '0'; 
                                v0 <= '1';     
                                rs <= '0';
                                rw <= '0';
                                data_out <= "00000010";
                                stop_sig <= '0';
                                ST <= Line_0; --Present State becomes Line_0, ST Cycle Line_0 ~ Go_Home
                        when others =>
                                 ST <= Wait_V0; --Excute at the exception, Wait_V0 become Present State, Process renew.
                        end case;

                end if;
        end process;
        
			process(clk)
				begin
					if sw1 = '1' then					
						if key3 = '1' then
							for i in 0 to arr_length loop
								Line0(i) <= "00100000";
								Line1(i) <= "00100000";
							end loop;
						else
							if key2 ='1' then
								Line0(0) <= x"41"; --
								Line0(1) <= x"54"; --
								Line0(2) <= x"2b"; --
								Line0(3) <= x"53"; --
								Line0(4) <= x"54"; --
								Line0(5) <= x"41"; --
								Line0(6) <= x"52"; --
								Line0(7) <= x"54"; --
								for i in 8 to arr_length loop
									Line0(i) <= "00100000";
								end loop;
							else
								if key0 = '1' then
									Line0(0) <= x"41"; --
									Line0(1) <= x"54"; --
									Line0(2) <= x"2b"; --
									Line0(3) <= x"43"; --
									Line0(4) <= x"4f"; --
									Line0(5) <= x"4e"; --
									Line0(6) <= x"5b"; --
									Line0(7) <= x"41"; --
									Line0(8) <= x"44"; --
									Line0(9) <= x"44"; --
									Line0(10) <= x"52"; --
									Line0(11) <= x"5d"; --
									for i in 12 to arr_length loop
										Line0(i) <= "00100000";
									end loop;
								else
									Line0(0) <= x"41"; --
									Line0(1) <= x"54"; --
									Line0(2) <= x"2b"; --
									Line0(3) <= x"52"; --
									Line0(4) <= x"53"; --
									Line0(5) <= x"53"; --
									Line0(6) <= x"49"; --
									Line0(7) <= x"3f"; --
									for i in 8 to arr_length loop
										Line0(i) <= "00100000";
									end loop;
								end if;
									
							end if;
						end if;
					end if;
					
					
	 
					
					for j in 0 to arr_length loop
							Line1(j) <= data_in(j);
					end loop;
			
			end process;
							
	
		en <= clk or stop_sig or MUX_wire; 
		
end be;