library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


package data_pack is
	type rx_array is array(0 to 15) of std_logic_vector(7 downto 0);
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.data_pack.all;

entity ble_tx_rx is port(
	clk9600, clk50, rst, key3, key2, sw1, key0 : in std_logic;	
	data_in : in std_logic_vector(7 downto 0);
	data_at : in std_logic_vector(7 downto 0);
	addr_at : out std_logic_vector(4 downto 0);
	data_rs : in std_logic_vector(7 downto 0);
	addr_rs : out std_logic_vector(2 downto 0);
	tx : out std_logic;
	rx : in std_logic;
	data_out : out rx_array);
end ble_tx_rx;

architecture be of ble_tx_rx is

constant ble_bit : integer := 11;


type state is (st_init, st0, st1, st2, st3);
signal st : state := st0;


signal data_buffer_rx : std_logic_vector(7 downto 0);
signal init_data : std_logic_vector(7 downto 0);
signal cnt : integer range 0 to 10 := 0;
signal q : std_logic;
signal count : integer range 0 to 100 := 0;

constant arr_length : integer := 15;

type rx_array_buf is array(0 to arr_length) of std_logic_vector(7 downto 0);
signal rx_arr : rx_array_buf;


type state_t is (st_0, st_1, st_2, st_3, st_4, st_5);
signal st_t : state_t := st_0;

type state_at is (at_0, at_1, at_2, at_3, at_4);
signal at : state_at := at_0;

type state_rs is (rs_0, rs_1, rs_2, rs_3, rs_4);
signal rs : state_rs := rs_0;

signal data_buffer_tx : std_logic_vector(7 downto 0);
signal data_compare_buf : std_logic_vector(7 downto 0);
signal p, p_2, p_3 : std_logic := '1';
signal address_at : std_logic_vector(4 downto 0);
signal address_rs : std_logic_vector(2 downto 0);



begin

	data_buffer_tx <= data_in;
	q <= rx;
	addr_at <= address_at;
	addr_rs <= address_rs;
	
	process(clk9600)
		begin
			if key0 = '1' then
				case sw1 is
					when '1' =>	tx <= p_2;
					when '0' => tx <= p;
				end case;
			else
				tx <= p_3;
			end if;
	end process;
	
	
	ble_tx : process(clk9600)
	variable num : integer range 0 to 7 := 0;
		begin
			if rst = '1' then
				p <= '1';
				st_t <= st_0;
			else
				if falling_edge(clk9600) then
					case st_t is
						when st_0 =>
										p <= '1';
										st_t <= st_1;
						when st_1 =>
										p <= '0';
										st_t <= st_2;
						when st_2 =>
										p <= data_buffer_tx(num);
										num := num + 1;
										if num = 7 then
											num := 0;
											st_t <= st_3;
										else
											st_t <= st_2;
										end if;
						when st_3 =>
										p <= '0';
										st_t <= st_4;
						when st_4 =>
										p <= '1';
										st_t <= st_5;
						when st_5 =>
										data_compare_buf <= data_in;
										if data_compare_buf = data_buffer_tx then
											st_t <= st_5;
										else
											st_t <= st_0;
										end if;
					end case;
				end if;
			end if;
	end process;
	
	ble_at : process(clk9600)
	variable num : integer range 0 to 7 := 0;
		begin
			if rst = '1' then
				p_2 <= '1';
				at <= at_0;
				address_at <= (others => '0');
			else
				if key3 = '0' then
					if falling_edge(clk9600) then
						case at is
							when at_0 =>
											p_2 <= '1';
											at <= at_1;
											
							when at_1 =>
											p_2 <= '0';
											at <= at_2;
											address_at <= address_at + '1';
							when at_2 =>
											p_2 <= data_at(num);
											num := num + 1;
											if num = 7 then
												num := 0;
												at <= at_3;
											else
												at <= at_2;
											end if;
							when at_3 =>
											p_2 <= '0';
											at <= at_4;
							when at_4 =>
											p_2 <= '1';
											if address_at = "00111" then
												if key2 = '1' then
													at <= at_4;
												else
													at <= at_0;
												end if;
											elsif address_at = "11001" then
												at <= at_4;
											else
												at <= at_0;
											end if;
						end case;
					end if;
				else
					at <= at_0;
					address_at <= (others => '0');
				end if;
			end if;
	end process;
	
	ble_rs : process(clk9600)
	variable num_r : integer range 0 to 7 := 0;
		begin
--			if rst = '1' then
--				p_3 <= '1';
--				rs <= rs_0;
--				address_rs <= (others => '0');
--			else
				if key0 = '0' then
					if falling_edge(clk9600) then
						case rs is
							when rs_0 =>
											p_3 <= '1';
											rs <= rs_1;
											
							when rs_1 =>
											p_3 <= '0';
											rs <= rs_2;
											address_rs <= address_rs + '1';
							when rs_2 =>
											p_3 <= data_rs(num_r);
											num_r := num_r + 1;
											if num_r = 7 then
												num_r := 0;
												rs <= rs_3;
											else
												rs <= rs_2;
											end if;
							when rs_3 =>
											p_3 <= '0';
											rs <= rs_4;
							when rs_4 =>
											p_3 <= '1';
											if address_rs = "111" then
												if key2 = '1' then
													rs <= rs_4;
												else
													rs <= rs_0;
												end if;
											elsif address_rs = "11001" then
												rs <= rs_4;
											else
												rs <= rs_0;
											end if;
						end case;
					end if;
				else
					p_3 <= '1';
					rs <= rs_0;
					address_rs <= (others => '0');
				end if;
--				else
--					rs <= rs_0;
--					address_rs <= (others => '0');
--				end if;
--			end if;
	end process;
	
	process(clk9600)
		variable num : integer range 0 to arr_length := 0;
		begin
			if falling_edge(clk9600) then
				if rst = '1' then
					st <= st_init;
					data_buffer_rx <= (others => '0');
					for i in 0 to arr_length loop
						rx_arr(i) <= "00100000";
					end loop;
					num := 0;
					init_data <= (others => '0');
				else
					case st is
						when st_init =>
											data_buffer_rx <= (others => '0');
											for i in 0 to arr_length loop
												rx_arr(i) <= "00100000";
											end loop;
											num := 0;
											init_data <= (others => '0');
											if count = 100 then
												count <= 0;
												st <= st0;
											else
												count <= count + 1;
												st <= st_init;
											end if;
						when st0 =>	
										if q = '0' then
											st <= st1;
											if (init_data = "00000000") then
												num := num;
											else
												num := num + 1;
											end if;
											if count = 100 then
												init_data <= (others => '0');
												data_buffer_rx <=(others => '0');
												for i in 0 to arr_length loop
												rx_arr(i) <= "00100000";
												end loop;
												count <= 0;
											end if;
										else
											data_buffer_rx <= (others => '0');
											st <= st0;
											if count = 100 then
												init_data <= (others => '0');
												num := 0;
											else
												count <= count + 1;
											end if;
												
										end if;
										
						when st1 =>
										if cnt > 7 then
											cnt <= 0;
											st <= st0;
											init_data <= data_buffer_rx;
											rx_arr(num) <= data_buffer_rx;
										else
											cnt <= cnt + 1;
											data_buffer_rx <= q & data_buffer_rx(7 downto 1);
											st <= st1;
										end if;
						when others => null;
					end case;
				end if;
			end if;
			
	end process;
	
	process(clk50)
		begin
					for i in 0 to arr_length loop
						data_out(i) <= rx_arr(i);
					end loop;
	end process;
	

	
end be;
										
										