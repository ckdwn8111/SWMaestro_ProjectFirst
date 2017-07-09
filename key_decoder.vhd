library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity key_decoder is port(
	clk9600, rst : in std_logic;
	scancode : in std_logic_vector(7 downto 0);
	decoder_out : out std_logic_vector(7 downto 0));
end key_decoder;

architecture be of key_decoder is

type state is (st0, st1, st2, st3, st4, st5, st6, st7, st8);
signal st : state := st0;
signal cnt : integer range 0 to 12 := 0;
signal clk_at : std_logic;

begin
	process(scancode)
		begin
			case scancode is
				when x"1d" => decoder_out <= x"61";
				when x"1b" => decoder_out <= x"62";
				when x"23" => decoder_out <= x"63";
				when x"1c" => decoder_out <= x"64";
				when x"65" => decoder_out <= x"65";
				when others => decoder_out <= x"65";
			end case;
	end process;
	
end be;