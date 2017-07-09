library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ble_rx_nano is port(
	clk50, rst : in std_logic;
	rx : in std_logic;
	motor_A1, motor_A2 : out std_logic;
	motor_B1, motor_B2 : out std_logic;
	dataout : out std_logic_vector(7 downto 0));
end ble_rx_nano;

architecture top of ble_rx_nano is


component ble_receiver is port(
	clk9600, clk50, rst : in std_logic;
	rx : in std_logic;
	data_in : in std_logic_vector(7 downto 0);
	ascii : out std_logic_vector(7 downto 0));
end component;

component motor_control is port(
	ascii_data : in std_logic_vector(7 downto 0);
	motor_A1, motor_A2 : out std_logic;
	motor_B1, motor_B2 : out std_logic);
end component;

component clk_div is port(
	clk50 : in std_logic;
	clk9600, clk1 : out std_logic);
end component;


signal clk9600, clk1 : std_logic;
signal data_in : std_logic_vector(7 downto 0);
signal data_out : std_logic_vector(7 downto 0);

begin

		u0 : clk_div port map (clk50, clk9600, clk1);
		u1 : ble_receiver port map(clk9600, clk50, rst, rx, data_in, data_out);
		u2 : motor_control port map(data_out, motor_A1, motor_A2, motor_B1, motor_B2);
		
		dataout <= data_out;
end top;