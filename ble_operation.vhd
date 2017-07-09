library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


package data_pack_out is
	type rx_array is array(0 to 15) of std_logic_vector(7 downto 0);
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_pack_out.all;

entity ble_operation is port(
	clk50, rst, key3, key2, sw1, key0 : in std_logic;
	ps2clk : in std_logic;
	ps2data : in std_logic;
	tx : out std_logic;
	dataout : out std_logic_vector(7 downto 0);
	vga_clk   : out std_logic;
	vga_hs    : out std_logic;
	vga_vs    : out std_logic;
	vga_blank : out std_logic;
	vga_sync  : out std_logic; 
	vga_red   : out std_logic_vector(7 downto 0);
	vga_green : out std_logic_vector(7 downto 0);
	vga_blue  : out std_logic_vector(7 downto 0);
	seg1, seg2, seg3, seg4 : out std_logic_vector(6 downto 0);
	rw,en,rs,v0 : out std_logic;
   lcdout : out std_logic_vector (7 downto 0);
	rx : in std_logic);
end ble_operation;

architecture top of ble_operation is

component ble_tx_rx is port(
	clk9600, clk50, rst, key3, key2, sw1, key0 : in std_logic;	
	data_in : in std_logic_vector(7 downto 0);
	data_at : in std_logic_vector(7 downto 0);
	addr_at : out std_logic_vector(4 downto 0);
	data_rs : in std_logic_vector(7 downto 0);
	addr_rs : out std_logic_vector(2 downto 0);
	tx : out std_logic;
	rx : in std_logic;
	data_out : out rx_array);
end component;


component clk_div is port(
	clk50 : in std_logic;
	clk9600, clk1, clk25, clk2, clk3, clk500 : out std_logic);
end component;

component key_decoder is port(
	clk9600, rst : in std_logic;
	scancode : in std_logic_vector(7 downto 0);
	decoder_out : out std_logic_vector(7 downto 0));
end component;

component ps2_kbd_new is Port (
	clk : in std_logic;									-- 25MHz system clock
	rst : in std_logic;									-- ststem reset
	ps2_clk : in std_logic;								-- PS2 input signal
	ps2_data : in std_logic;							-- PS2 input signal
	scancode : out std_logic_vector(7 downto 0) -- touched keyboard key code
	);
end component;

component VGA is port(
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
end component;

component rom_tree IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	);
end component;

component rom_car IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	);
END component;



component at_com IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;


component id is port(
	clk3 : in std_logic;
	segl1, segl2, segl3, segl4 : out std_logic_vector(6 downto 0));
end component;

component clcd is 
        generic( 
                delay_cnt : integer :=50); --delay_cnt=50
        port (
                clk, clk9600, key3, key2, sw1, key0 : in std_logic;
					 data_in : in rx_array;
					 rw,en,rs,v0 : out std_logic;
					 data_out : out std_logic_vector (7 downto 0));
end component;

component rssi IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;

signal clk9600, clk1, clk25, clk2, clk3, clk500 : std_logic;
signal data_in : std_logic_vector(7 downto 0);
signal scancode : std_logic_vector(7 downto 0);

signal addr_1, addr_2, addr_3, addr_4, addr_5, addr_6, addr_7, addr_8 : std_logic_vector(12 downto 0);
signal data_1, data_2, data_3, data_4, data_5, data_6, data_7, data_8 : std_logic_vector(23 downto 0);

signal addr_11, addr_22, addr_33, addr_44, addr_55, addr_66, addr_77, addr_88 : std_logic_vector(12 downto 0);
signal data_11, data_22, data_33, data_44, data_55, data_66, data_77, data_88 : std_logic_vector(23 downto 0);

-- rom_car
signal addr_car : std_logic_vector(13 downto 0);
signal data_car : std_logic_vector(23 downto 0);

signal addr_at : std_logic_vector(4 downto 0);
signal data_at : std_logic_vector(7 downto 0);

signal addr_rssi : std_logic_vector(2 downto 0);
signal data_rssi : std_logic_vector(7 downto 0);

constant arr_length : integer := 15;
signal rx_arr : rx_array;

begin

		f1 : clcd port map(clk500, clk9600, key3, key2, sw1, key0, rx_arr, rw, en, rs, v0, lcdout);
		I0 : id port map(clk3, seg1, seg2, seg3, seg4); 
		u0 : clk_div port map (clk50, clk9600, clk1, clk25, clk2, clk3, clk500);
		u1 : ble_tx_rx port map(clk9600, clk50, rst, key3, key2, sw1, key0, data_in, data_at, addr_at, data_rssi, addr_rssi, tx, rx, rx_arr);
		u2 : key_decoder port map(clk9600, rst, scancode, data_in);
		u3 : ps2_kbd_new port map(clk25, rst, ps2clk, ps2data, scancode);
		
		a1 : at_com port map(addr_at, clk25, data_at);
		a2 : rssi port map(addr_rssi, clk25, data_rssi);
		
		c1 : rom_car   port map(addr_car, clk25, data_car);

		r1 : rom_tree	port map(addr_1, clk25, data_1);
		r2 : rom_tree	port map(addr_2, clk25, data_2);
		r3 : rom_tree	port map(addr_3, clk25, data_3);
		r4 : rom_tree	port map(addr_4, clk25, data_4);
		r5 : rom_tree	port map(addr_5, clk25, data_5);
		r6 : rom_tree	port map(addr_6, clk25, data_6);
		r7 : rom_tree	port map(addr_7, clk25, data_7);
		r8 : rom_tree	port map(addr_8, clk25, data_8);
		
		l1 : rom_tree	port map(addr_11, clk25, data_11);
		l2 : rom_tree	port map(addr_22, clk25, data_22);
		l3 : rom_tree	port map(addr_33, clk25, data_33);
		l4 : rom_tree	port map(addr_44, clk25, data_44);
		l5 : rom_tree	port map(addr_55, clk25, data_55);
		l6 : rom_tree	port map(addr_66, clk25, data_66);
		l7 : rom_tree	port map(addr_77, clk25, data_77);
		l8 : rom_tree	port map(addr_88, clk25, data_88);
		
		vg0 : VGA port map(
								rst		 => rst,
								clk25		 => clk25,
								clk1		 => clk1,
								clk2		 => clk2,
								scancode  => scancode,
								--rom
								addr_1	 => addr_1,
								addr_2	 => addr_2,
								addr_3	 => addr_3,
								addr_4	 => addr_4,
								addr_5	 => addr_5,
								addr_6	 => addr_6,
								addr_7	 => addr_7,
								addr_8	 => addr_8,
								
								data_1	 => data_1,
								data_2	 => data_2,
								data_3	 => data_3,
								data_4	 => data_4,
								data_5	 => data_5,
								data_6	 => data_6,
								data_7	 => data_7,
								data_8	 => data_8,
								
								addr_11	 => addr_11,
								addr_22	 => addr_22,
								addr_33	 => addr_33,
								addr_44	 => addr_44,
								addr_55	 => addr_55,
								addr_66	 => addr_66,
								addr_77	 => addr_77,
								addr_88	 => addr_88,
								
								data_11	 => data_11,
								data_22	 => data_22,
								data_33	 => data_33,
								data_44	 => data_44,
								data_55	 => data_55,
								data_66	 => data_66,
								data_77	 => data_77,
								data_88	 => data_88,
								
								addr_car => addr_car,
								data_car => data_car,
								
								--vga
								vga_clk   => vga_clk,
								vga_hs    => vga_hs,
								vga_vs    => vga_vs,
								vga_blank => vga_blank,
								vga_sync  => vga_sync,
								vga_red   => vga_red,
								vga_green => vga_green,
								vga_blue  => vga_blue);
			
			dataout <= scancode;
end top;