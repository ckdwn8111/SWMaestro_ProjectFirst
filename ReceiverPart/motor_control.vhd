library ieee;
use ieee.std_logic_1164.all;

entity motor_control is port(
	ascii_data : in std_logic_vector(7 downto 0);
	motor_A1, motor_A2 : out std_logic;
	motor_B1, motor_B2 : out std_logic);
end motor_control;

architecture be of motor_control is

signal temp_data : std_logic_vector(7 downto 0);

begin
	temp_data <= ascii_data;
	
	process(ascii_data)
		begin
			case temp_data is
				when x"61" =>--a/foward
									motor_A1 <= '1';
									motor_A2 <= '0';
									motor_B1 <= '1';
									motor_B2 <= '0';
				when x"62" =>--b/back
									motor_A1 <= '0';
									motor_A2 <= '1';
									motor_B1 <= '0';
									motor_B2 <= '1';
				when x"63" =>--c/right
									motor_A1 <= '1';
									motor_A2 <= '0';
									motor_B1 <= '0';
									motor_B2 <= '1';
				when x"64" =>--d/left
									motor_A1 <= '0';
									motor_A2 <= '1';
									motor_B1 <= '1';
									motor_B2 <= '0';
				when x"65" =>--e/stop
									motor_A1 <= '0';
									motor_A2 <= '0';
									motor_B1 <= '0';
									motor_B2 <= '0';
				when others =>--data_error_stop
									motor_A1 <= '0';
									motor_A2 <= '0';
									motor_B1 <= '0';
									motor_B2 <= '0';
			end case;
	end process;
end be;
									
				