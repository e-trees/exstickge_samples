library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_udprecv is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    UPLin_Reqeust : in  std_logic;
    UPLin_Ack     : out std_logic;
    UPLin_Enable  : in  std_logic;
    UPLin_Data    : in  std_logic_vector(31 downto 0);

    UPLout_Reqeust : out std_logic;
    UPLout_Ack     : in  std_logic;
    UPLout_Enable  : out std_logic;
    UPLout_Data    : out std_logic_vector(31 downto 0)
    );
end entity simple_udprecv;

architecture RTL of simple_udprecv is

  type StateType is (STATE_IDLE,
                     STATE_RECV_DST_IP,
                     STATE_RECV_SRC_IP,
                     STATE_RECV_DST_SRC_PORT,
                     STATE_RECV_BYTES,
                     STATE_RECV_DATA,
                     STATE_SEND_SRC_IP,
                     STATE_SEND_DST_IP,
                     STATE_SEND_SRC_DST_PORT,
                     STATE_SEND_BYTES,
                     STATE_SEND_DATA1,
                     STATE_SEND_DATA2);

  signal state : StateType := STATE_IDLE;


  signal my_ip_addr    : std_logic_vector(31 downto 0);
  signal host_ip_addr  : std_logic_vector(31 downto 0);
  signal my_port       : std_logic_vector(15 downto 0);
  signal host_port     : std_logic_vector(15 downto 0);
  signal payload_bytes : std_logic_vector(31 downto 0);

  signal summation : unsigned(31 downto 0);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        UPLin_Ack <= '0';
        UPLout_Reqeust <= '0';
        UPLout_Enable <= '0';
        UPLout_Data <= X"00000000";
        state <= STATE_IDLE;
      else
        case(state) is
          
          when STATE_IDLE =>
            if UPLin_Enable = '1' then
              state <= STATE_RECV_SRC_IP;
              UPLin_Ack <= '0'; -- In receiving, this module cannot receive the other packets.
              my_ip_addr <= UPLin_Data; -- receive the 1st word.
            else
              UPLin_Ack <= '1'; -- wait for a packet
            end if;
            summation <= (others => '0');
            UPLout_Enable <= '0';

          when STATE_RECV_SRC_IP =>
            if UPLin_Enable = '0' then
              state <= STATE_IDLE; -- illegal packet
            else
              host_ip_addr <= UPLin_Data;
              state <= STATE_RECV_DST_SRC_PORT;
            end if;

          when STATE_RECV_DST_SRC_PORT =>
            if UPLin_Enable = '0' then
              state <= STATE_IDLE; -- illegal packet
            else
              my_port <= UPLin_Data(31 downto 16);
              host_port <= UPLin_Data(15 downto 0);
              state <= STATE_RECV_BYTES;
            end if;

          when STATE_RECV_BYTES =>
            if UPLin_Enable = '0' then
              state <= STATE_IDLE; -- illegal packet
            else
              payload_bytes <= UPLin_Data;
              state <= STATE_RECV_DATA;
            end if;

          when STATE_RECV_DATA =>
            if UPLin_Enable = '0' then -- end of packet
              state <= STATE_SEND_SRC_IP;
              UPLout_Reqeust <= '1'; -- ready to send a reply packet
            else
              summation <= unsigned(UPLin_Data) + summation;
            end if;
            
          when STATE_SEND_SRC_IP =>
            if UPLout_Ack = '1' then
              state <= STATE_SEND_DST_IP;
              UPLout_Reqeust <= '0';
              UPLout_Enable <= '1';
              UPLout_Data <= my_ip_addr;
            end if;

          when STATE_SEND_DST_IP =>
            state <= STATE_SEND_SRC_DST_PORT;
            UPLout_Enable <= '1';
            UPLout_Data <= host_ip_addr;
		
          when STATE_SEND_SRC_DST_PORT =>
            state <= STATE_SEND_BYTES;
            UPLout_Enable <= '1';
            UPLout_Data <= my_port & host_port;

          when STATE_SEND_BYTES =>
            state <= STATE_SEND_DATA1;
            UPLout_Enable <= '1';
            UPLout_Data <= std_logic_vector(to_unsigned(8, 32)); -- 8 bytes

          when STATE_SEND_DATA1 =>
            state <= STATE_SEND_DATA2;
            UPLout_Enable <= '1';
            UPLout_Data <= X"53756d3a"; -- (format "%x%x%x%x" ?S ?u ?m ?:)

          when STATE_SEND_DATA2 =>
            state <= STATE_IDLE;
            UPLout_Enable <= '1';
            UPLout_Data <= std_logic_vector(summation);

          when others =>
            UPLin_Ack <= '0';
            UPLout_Reqeust <= '0';
            UPLout_Enable <= '0';
            UPLout_Data <= X"00000000";
            state <= STATE_IDLE;
        end case;
      end if;
    end if;
    
  end process;

end RTL;
  
