library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ble_receiver is port(
	clk9600, clk50, rst : in std_logic;
	rx : in std_logic;
	data_in : in std_logic_vector(7 downto 0);
	ascii : out std_logic_vector(7 downto 0));
end ble_receiver;

architecture be of ble_receiver is

constant ble_bit : integer := 11;

type state is (st0, st1, st2);
signal st : state := st0;

type state_t is (st_0, st_1, st_2);
signal st_t : state_t := st_0;

signal data_buffer_rx : std_logic_vector(ble_bit-1 downto 0);
signal cnt : integer range 0 to 10 := 0;
signal q : std_logic;



begin
	q <= rx;
	
	process(clk9600)
		begin
				if falling_edge(clk9600) then
					case st is
						when st0 =>
										if q = '0' then
											st <= st1;
										else
											data_buffer_rx <= (others => '0');
											st <= st0;
										end if;
						when st1 =>
										if cnt = 10 then
											cnt <= 0;
											ascii <= data_buffer_rx(8 downto 1);
											st <= st2;
										else
											cnt <= cnt + 1;
											data_buffer_rx <= q & data_buffer_rx(ble_bit-1 downto 1);
											st <= st1;
										end if;
						when st2 =>
										data_buffer_rx <= (others => '0');
										st <= st0;
					end case;
				end if;
	end process;
		

	
end be;
										
										