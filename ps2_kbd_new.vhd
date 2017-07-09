library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ps2_kbd_new is Port (
	clk : in std_logic;									-- 25MHz system clock
	rst : in std_logic;									-- ststem reset
	ps2_clk : in std_logic;								-- PS2 input signal
	ps2_data : in std_logic;							-- PS2 input signal
	scancode : out std_logic_vector(7 downto 0) -- touched keyboard key code
	);
end ps2_kbd_new;

architecture be of ps2_kbd_new is

constant TIMER_120U_BIT_SIZE : integer := 13;
constant TIMER_120U_TERMINAL_VAL : integer := 3000;
constant FRAME_BIT_NUM : integer := 11; -- [start bit(1) + data(8)+ parity bit(1) + stop bit(1)] = 11bit
constant RELEASE_CODE : std_logic_vector(7 downto 0) := "11110000"; -- "F0"

type state1 is (S_H, S_L, S_H2L, s_L2H);
signal nx_st, st : state1 := S_H;

signal ps2_clk_d, ps2_clk_s, ps2_data_d, ps2_data_s : std_logic;
signal ps2_clk_dd, ps2_data_dd : std_logic;
signal ps2_clk_rising_edge, ps2_clk_falling_edge : std_logic;
signal rst_timer : std_logic;
signal timer_cnt : std_logic_vector(TIMER_120U_BIT_SIZE-1 downto 0);
signal q : std_logic_vector(FRAME_BIT_NUM-1 downto 0);
signal output_strobe, shift_done : std_logic;
signal bit_cnt : std_logic_vector(3 downto 0);
signal reset_bit_cnt, shift : std_logic;
signal timer_timeout : std_logic;
signal got_release   : std_logic;
signal hold_release  : std_logic;
signal flag : std_logic;
signal tmp_cnt : std_logic_vector(3 downto 0);
signal st_2 : integer range 0 to 1 := 0;
signal buffer_clear : std_logic := '0';

begin

-- synchronizing asynchronous input signal from ps2 ports
sync_reg: process(rst,clk)
begin
  if(rst = '1') then
      ps2_clk_d <= '1';
      ps2_data_d <= '1';
	    ps2_clk_s <= '1';
	    ps2_data_s <= '1';
  elsif (rising_edge(clk)) then
      ps2_clk_d <= ps2_clk;
      ps2_data_d <= ps2_data;
	   ps2_clk_s <= ps2_clk_d;
	   ps2_data_s <= ps2_data_d;
  end if;

end process;

------------------------------------------------------------------ 키보드 엣지 발생여부를 파악하기 위한 변수
-- generate pulse signal of one clock period width 
--that informs ps2clk is rising or falling
ps2_clk_rising_edge <= (not ps2_clk_s) and ps2_clk_d;
ps2_clk_falling_edge <= (not ps2_clk_d) and ps2_clk_s;
------------------------------------------------------------------

------------------------------------------------------------------ 키보드 입력을 시리얼로 받을 때 입력받는 상태를 알기위해 FSM을 설계함 
-- state mchine that monitors the ps2clk signal level
state_reg: process(clk, rst) 
begin
  if (rising_edge(clk)) then
    if(rst = '1') then
      st <= S_H;
	 else
      st <= nx_st;
	 end if;
  end if;
end process;

state_logic: process(st, ps2_clk_rising_edge, ps2_clk_falling_edge)
begin
   case st is
   when S_L => 
		if(ps2_clk_rising_edge = '1') then
			nx_st <= S_L2H ;
	   else
	      nx_st <= S_L;
	   end if;
   when S_L2H =>
		nx_st <= S_H;
	when S_H =>
		if(ps2_clk_falling_edge = '1') then
		  nx_st <= S_H2L;
		else
		  nx_st <= S_H;
		end if;
   when S_H2L=>
		 nx_st <= S_L;
   when others =>
	    nx_st <= S_H;
   end case;
end process;
------------------------------------------------------------------

-- output signals for the state mchine
shift <= '1' when st = S_H2L else '0'; --ps2 클락이 하강엣지일 때(키가 눌릴 때) shift는 1
rst_timer <= '1' when (st = S_H2L) or (st = S_L2H) else '0'; --키를 누를 때랑 키를 뗄 때 rst_timer 는 1

-- bit counter
cnt_bit_num: process(clk)
begin
  if(rising_edge(clk)) then
    if((rst = '1') or (shift_done = '1')) then
	   bit_cnt <= (others => '0'); -- normal reset condition
	 elsif(reset_bit_cnt = '1') then
	   bit_cnt <= (others => '0'); -- timer out : no clk signal more than 60 us
	 elsif(shift='1') then
	   bit_cnt <= bit_cnt + 1; --시프트 발생하면 bit_cnt +1, 시프트는 키가 눌렸을 때 발생 (땔 때도 발생, 왜?)
	 end if;
  end if;
end process;

reset_bit_cnt <= '1' when (timer_timeout = '1') and  --timer_timeout 은 키가 눌리거나 떼지면 cnt 0초기화후 3000까지 올라감
(st = S_H) and (ps2_clk_s = '1') else '0';	--reset_bit_cnt가 1이되면 bit_cnt가 0이 됌
-- 120 us timer										-- 120us timer 는 키가 떼졌을때 들어올 비트카운트를 초기화 시켜주기위함 insensable하게 하게위해 imer_timeout 딜레이를 걸어주는 것 같음
timer: process(clk)
begin
  if(rising_edge(clk)) then
    if(rst_timer = '1') then
	   timer_cnt <= (others => '0'); --키를 누를때랑 키를 뗄 때 timer_cnt 는 0
    elsif( timer_timeout = '0') then
	   timer_cnt <= timer_cnt + 1; --키를 누르거나 떼지 않을때는 timer_cnt 는 계속 +1 , timer_cnt는 12 dowonto 0
    end if;
  end if;
end process;

timer_timeout <= '1' when timer_cnt = TIMER_120U_TERMINAL_VAL else '0' ; -- timer_cnt 가 3000이 되면 timer_timeout 은 1
  
-- shift register for SIPO operation (11-bit length) 
shift_R: process(clk) 
begin
  if(rising_edge(clk)) then
    if(rst = '1') then
      q <= (others => '0') ; -- FRAME_BIT_NUM=11 q는 FRAME_BIT_NUM-1 애 downto 0
	 elsif(shift = '1' ) then
	   q <= ps2_data_s & q(FRAME_BIT_NUM-1 downto 1); --q(10~0) <=  ps2_data_s & q(10~1);
	 end if;
  end if;
end process;

shift_done <= '1' when (bit_cnt = FRAME_BIT_NUM) else '0';

blocking_overlap : process(clk)
	begin	
		if falling_edge(shift_done) then
			case st_2 is
				when 0 =>
							buffer_clear <= '1';
							st_2 <= 1;
				when 1 =>
							if got_release = '1' then
								st_2 <= 0;
							else
								buffer_clear <= '0';
								st_2 <= 1;
							end if;
			end case;
		end if;
end process;

got_release <= '1' when (q(8 downto 1) = RELEASE_CODE) and (shift_done= '1') --RELEASE_CODE 11110000 --
else '0'; 

output_strobe <= '1' when (shift_done = '1') and (got_release = '0')  else '0';  --and (shift_pressed = '0')
				
latch_released : process(clk) 
begin
  if(rising_edge(clk)) then
    if(rst = '1' or output_strobe ='1') then
        hold_release <= '0';
    elsif(got_release = '1') then
        hold_release <= '1';
    end if;
  end if;
end process;

-- latch the output signals (scan code data)
send_output: process(clk)
begin
 if(rising_edge(clk)) then
  if(rst='1') then
    scancode <= (others=>'0');
  elsif(output_strobe='1' and hold_release = '0') then
	 tmp_cnt  <= tmp_cnt + '1' ;
    scancode <= '0' & q(7 downto 1) ;
  elsif(output_strobe='1' and hold_release = '1') then
	 scancode <= x"65";
  end if;
 end if;
end process;

end be;