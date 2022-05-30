library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udpled is
port(
  -- input
  UPL_input_data : in std_logic_vector(32-1 downto 0);
  UPL_input_en : in std_logic;
  UPL_input_req : in std_logic;
  UPL_input_ack : out std_logic;

  -- output
  UPL_output_data : out std_logic_vector(32-1 downto 0);
  UPL_output_en : out std_logic;
  UPL_output_req : out std_logic;
  UPL_output_ack : in std_logic;

  -- user-defiend ports
  led : out std_logic_vector(8-1 downto 0);

  -- system clock and reset
  clk : in std_logic;
  reset : in std_logic
);
end entity udpled;

architecture RTL of udpled is

  -- statemachine type and signal
  type StateType is (
      IDLE,
      udpled,
      output_send_0,
      output_send_1,
      output_send_2,
      output_send_3,
      output_send_4,
      output_send_5,
      output_send_6,
      input_recv_0,
      input_recv_1,
      input_recv_2,
      input_recv_3,
      input_recv_4,
      input_recv_5
  );
  signal gupl_state : StateType := IDLE;
  signal gupl_state_next : StateType := IDLE;

  -- UPL signals
  signal myIpAddr : std_logic_vector(32-1 downto 0);
  signal dstIpAddr : std_logic_vector(32-1 downto 0);
  signal myPort : std_logic_vector(16-1 downto 0);
  signal dstPort : std_logic_vector(16-1 downto 0);
  signal payloadBytes : std_logic_vector(32-1 downto 0);
  signal led_value : std_logic_vector(32-1 downto 0);

  -- user-defiend signals

  -- ip-cores

begin

  -- add async


process(clk)
begin
  if rising_edge(clk) then
    if reset = '1' then
      UPL_output_en <= '0';
      UPL_output_req <= '0';
      UPL_output_data <= (others => '0');
      UPL_input_ack <= '0';
      gupl_state <= IDLE;
      gupl_state_next <= IDLE;
    else
      case gupl_state is
        when IDLE =>
          gupl_state <= input_recv_0;
          gupl_state_next <= udpled;
          UPL_output_en <= '0';
          UPL_output_req <= '0';
          UPL_output_data <= (others => '0');
          UPL_input_ack <= '0';
        when udpled =>
  led <= led_value(7 downto 0);
          gupl_state <= output_send_0;
          gupl_state_next <= IDLE;
        when output_send_0 =>
          UPL_output_req <= '1';
          if UPL_output_ack = '1' then
            gupl_state <= output_send_1;
          end if;
        when output_send_1 =>
          gupl_state <= output_send_2;
        when output_send_2 =>
          UPL_output_req <= '0';
          UPL_output_data(31 downto 0) <= myIpAddr;
          UPL_output_en <= '1';
          gupl_state <= output_send_3;
        when output_send_3 =>
          UPL_output_req <= '0';
          UPL_output_data(31 downto 0) <= dstIpAddr;
          UPL_output_en <= '1';
          gupl_state <= output_send_4;
        when output_send_4 =>
          UPL_output_req <= '0';
          UPL_output_data(31 downto 16) <= myPort;
          UPL_output_data(15 downto 0) <= dstPort;
          UPL_output_en <= '1';
          gupl_state <= output_send_5;
        when output_send_5 =>
          UPL_output_req <= '0';
          UPL_output_data(31 downto 0) <= payloadBytes;
          UPL_output_en <= '1';
          gupl_state <= output_send_6;
        when output_send_6 =>
          UPL_output_req <= '0';
          UPL_output_data(31 downto 0) <= led_value;
          UPL_output_en <= '1';
          gupl_state <= gupl_state_next;
        when input_recv_0 =>
          if UPL_input_en = '1' then
            UPL_input_ack <= '0';
          else
            UPL_input_ack <= '1';
          end if;
          myIpAddr <= UPL_input_data(31 downto 0);
          if UPL_input_en = '1' then
            gupl_state <= input_recv_1;
          end if;
        when input_recv_1 =>
          UPL_input_ack <= '0';
          dstIpAddr <= UPL_input_data(31 downto 0);
          gupl_state <= input_recv_2;
        when input_recv_2 =>
          UPL_input_ack <= '0';
          myPort <= UPL_input_data(31 downto 16);
          dstPort <= UPL_input_data(15 downto 0);
          gupl_state <= input_recv_3;
        when input_recv_3 =>
          UPL_input_ack <= '0';
          payloadBytes <= UPL_input_data(31 downto 0);
          gupl_state <= input_recv_4;
        when input_recv_4 =>
          UPL_input_ack <= '0';
          led_value <= UPL_input_data(31 downto 0);
          gupl_state <= input_recv_5;
        when input_recv_5 =>
          if UPL_input_en = '0' then
            gupl_state <= gupl_state_next;
          end if;
        when others => gupl_state <= IDLE;
      end case;
    end if;
  end if;
end process;


end RTL;
