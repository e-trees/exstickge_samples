library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_udpsend is
  port(
    clk   : in std_logic;
    reset : in std_logic;

    UPLin_Reqeust : in  std_logic;
    UPLin_Ack     : out std_logic;
    UPLin_Enable  : in  std_logic;
    UPLin_Data    : in  std_logic_vector(31 downto 0);

    UPLout_Reqeust : out std_logic;
    UPLout_Ack     : in  std_logic;
    UPLout_Enable  : out std_logic;
    UPLout_Data    : out std_logic_vector(31 downto 0);

    DST_IP : in std_logic_vector(31 downto 0);
    SRC_IP : in std_logic_vector(31 downto 0);
    SRC_PORT : in std_logic_vector(15 downto 0);
    DST_PORT : in std_logic_vector(15 downto 0)
    );
end entity simple_udpsend;

architecture RTL of simple_udpsend is

  signal wait_counter : unsigned(31 downto 0) := (others => '0');
  signal heartbeat_counter : unsigned(31 downto 0) := (others => '0');

  type StateType is (STATE_IDLE,
                     STATE_SEND_SRC_IP,
                     STATE_SEND_DST_IP,
                     STATE_SEND_SRC_DST_PORT,
                     STATE_SEND_BYTES,
                     STATE_SEND_DATA1,
                     STATE_SEND_DATA2);
  signal state : StateType := STATE_IDLE;

begin
  
  UPLin_Ack <= '1';

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        UPLout_Reqeust <= '0';
        UPLout_Enable <= '0';
        UPLout_Data <= (others => '0');
        wait_counter <= (others => '0');
        state <= STATE_IDLE;
        heartbeat_counter <= (others => '0');
      else
        heartbeat_counter <= heartbeat_counter + 1;

        case state is

          when STATE_IDLE =>
            if wait_counter < 125000000 then
              wait_counter <= wait_counter + 1;
              UPLout_Reqeust <= '0';
            else
              state <= STATE_SEND_SRC_IP;
              wait_counter <= (others => '0');
              UPLout_Reqeust <= '1';
            end if;
            UPLout_Enable <= '0';
            UPLout_Data <= (others => '0');

          when STATE_SEND_SRC_IP =>
            if UPLout_Ack = '1' then
              state <= STATE_SEND_DST_IP;
              UPLout_Reqeust <= '0';
              UPLout_Enable <= '1';
              UPLout_Data <= SRC_IP;
            end if;

          when STATE_SEND_DST_IP =>
            state <= STATE_SEND_SRC_DST_PORT;
            UPLout_Enable <= '1';
            UPLout_Data <= DST_IP;
		
          when STATE_SEND_SRC_DST_PORT =>
            state <= STATE_SEND_BYTES;
            UPLout_Enable <= '1';
            UPLout_Data <= SRC_PORT & DST_PORT;

          when STATE_SEND_BYTES =>
            state <= STATE_SEND_DATA1;
            UPLout_Enable <= '1';
            UPLout_Data <= std_logic_vector(to_unsigned(8, 32)); -- 8 bytes

          when STATE_SEND_DATA1 =>
            state <= STATE_SEND_DATA2;
            UPLout_Enable <= '1';
            UPLout_Data <= X"53656e64"; -- (format "%x%x%x%x" ?S ?e ?n ?d)

          when STATE_SEND_DATA2 =>
            state <= STATE_IDLE;
            UPLout_Enable <= '1';
            UPLout_Data <= std_logic_vector(heartbeat_counter);

            when others =>
            UPLout_Reqeust <= '0';
            UPLout_Enable <= '0';
            UPLout_Data <= (others => '0');
            wait_counter <= (others => '0');
            state <= STATE_IDLE;
            
        end case;
      end if;
    end if;
  end process;
  
end RTL;
