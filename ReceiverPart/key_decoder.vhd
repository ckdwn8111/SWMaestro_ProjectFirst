library ieee;
use ieee.std_logic_1164.all;

entity key_decoder is port(
	key_control : in std_logic_vector(3 downto 0);
	decoder_out : out std_logic_vector(7 downto 0));
end key_decoder;

architecture be of key_decoder is

begin
	process(key_control)
		begin
			case key_control is
				when "0111" => decoder_out <= x"61";
				when "1011" => decoder_out <= x"62";
				when "1101" => decoder_out <= x"63";
				when "1110" => decoder_out <= x"64";
				when "1111" => decoder_out <= x"65";
				when others => decoder_out <= x"65";
			end case;
	end process;
end be;