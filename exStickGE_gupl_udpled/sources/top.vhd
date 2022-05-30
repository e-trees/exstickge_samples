library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity top is
  port (
    -- ETHER PHY
    GEPHY_TD      : out   std_logic_vector(3 downto 0);
    GEPHY_TXEN_ER : out   std_logic;
    GEPHY_TCK     : out   std_logic;
    GEPHY_RD      : in    std_logic_vector(3 downto 0);
    GEPHY_RCK     : in    std_logic; 
    GEPHY_RXDV_ER : in    std_logic;
    GEPHY_MAC_CLK : in    std_logic;
    
    GEPHY_MDC     : out   std_logic;
    GEPHY_MDIO    : inout std_logic;
    GEPHY_INT_N   : in    std_logic;
    GEPHY_PMEB    : in  std_logic;
    GEPHY_RST_N   : out std_logic;
    
    LED0 : out std_logic;
    LED1 : out std_logic;
    LED2 : out std_logic;
    
    -- Single-ended system clock
    sys_clk_p : in std_logic;
    sys_clk_n : in std_logic;
    sys_rst_n : in std_logic
    );

end entity top;

architecture RTL of top is

  component clk_wiz_1
    port(
      -- Clock in ports
      -- Clock out ports
      clk_out1 : out std_logic;
      clk_out2 : out std_logic;
      clk_out3 : out std_logic;
      -- Status and control signals
      reset    : in  std_logic;
      locked   : out std_logic;
      clk_in1  : in  std_logic
      );
  end component;

  -- Signal declarations

  signal sys_clk : std_logic;
  
  signal init_calib_complete : std_logic;

  signal clk : std_logic;
  signal rst : std_logic;

  signal device_temp : std_logic_vector(11 downto 0);
  
  signal locked_i                   : std_logic;
  signal clk310M                    : std_logic;

  -- ETHER TEST
  component e7udpip_rgmii_artix7
    port(
      GEPHY_RST_N     : out   std_logic;
      GEPHY_MAC_CLK   : in    std_logic;
      GEPHY_MAC_CLK90 : in    std_logic;
      -- TX out
      GEPHY_TD        : out   std_logic_vector(3 downto 0);
      GEPHY_TXEN_ER   : out   std_logic;
      GEPHY_TCK       : out   std_logic;
      -- RX in
      GEPHY_RD        : in    std_logic_vector(3 downto 0);
      GEPHY_RCK       : in    std_logic;  -- 10M=>2.5MHz, 100M=>25MHz, 1G=>125MHz
      GEPHY_RXDV_ER   : in    std_logic;
      -- Management I/F
      GEPHY_MDC       : out   std_logic;
      GEPHY_MDIO      : inout std_logic;
      GEPHY_INT_N     : in    std_logic;
      
      -- Asynchronous Reset
      Reset_n         : in  std_logic;
      
      -- UPL interface
      pUPLGlobalClk   : in  std_logic;
      
      -- UDP tx input
      pUdp0Send_Data    : in  std_logic_vector(31 downto 0);
      pUdp0Send_Request : in  std_logic;
      pUdp0Send_Ack     : out std_logic;
      pUdp0Send_Enable  : in  std_logic;
      
      pUdp1Send_Data    : in  std_logic_vector(31 downto 0);
      pUdp1Send_Request : in  std_logic;
      pUdp1Send_Ack     : out std_logic;
      pUdp1Send_Enable  : in  std_logic;
      
      -- UDP rx output
      pUdp0Receive_Data    : out std_logic_vector(31 downto 0);
      pUdp0Receive_Request : out std_logic;
      pUdp0Receive_Ack     : in  std_logic;
      pUdp0Receive_Enable  : out std_logic;
      
      pUdp1Receive_Data    : out std_logic_vector(31 downto 0);
      pUdp1Receive_Request : out std_logic;
      pUdp1Receive_Ack     : in  std_logic;
      pUdp1Receive_Enable  : out std_logic;
      
      -- MII interface
      pMIIInput_Data    : in  std_logic_vector(31 downto 0);
      pMIIInput_Request : in  std_logic;
      pMIIInput_Ack     : out std_logic;
      pMIIInput_Enable  : in  std_logic;
      
      pMIIOutput_Data    : out std_logic_vector(31 downto 0);
      pMIIOutput_Request : out std_logic;
      pMIIOutput_Ack     : in  std_logic;
      pMIIOutput_Enable  : out std_logic;
      
      -- Setup
      pMyIpAddr       : in std_logic_vector( 31 downto 0 );
      pMyMacAddr      : in std_logic_vector( 47 downto 0 );
      pMyNetmask      : in std_logic_vector( 31 downto 0 );
      pDefaultGateway : in std_logic_vector( 31 downto 0 );
      pTargetIPAddr   : in std_logic_vector( 31 downto 0 );
      pMyUdpPort0     : in std_logic_vector( 15 downto 0 );
      pMyUdpPort1     : in std_logic_vector( 15 downto 0 );
      pPHYAddr        : in std_logic_vector( 4 downto 0 );
      pPHYMode        : in std_logic_vector( 3 downto 0 );
      pConfig_Core    : in std_logic_vector( 31 downto 0 );
      
      -- Status
      pStatus_RxByteCount             : out std_logic_vector( 31 downto 0 );
      pStatus_RxPacketCount           : out std_logic_vector( 31 downto 0 );
      pStatus_RxErrorPacketCount      : out std_logic_vector( 15 downto 0 );
      pStatus_RxDropPacketCount       : out std_logic_vector( 15 downto 0 );
      pStatus_RxARPRequestPacketCount : out std_logic_vector( 15 downto 0 );
      pStatus_RxARPReplyPacketCount   : out std_logic_vector( 15 downto 0 );
      pStatus_RxICMPPacketCount       : out std_logic_vector( 15 downto 0 );
      pStatus_RxUDP0PacketCount       : out std_logic_vector( 15 downto 0 );
      pStatus_RxUDP1PacketCount       : out std_logic_vector( 15 downto 0 );
      pStatus_RxIPErrorPacketCount    : out std_logic_vector( 15 downto 0 );
      pStatus_RxUDPErrorPacketCount   : out std_logic_vector( 15 downto 0 );
      
      pStatus_TxByteCount             : out std_logic_vector( 31 downto 0 );
      pStatus_TxPacketCount           : out std_logic_vector( 31 downto 0 );
      pStatus_TxARPRequestPacketCount : out std_logic_vector( 15 downto 0 );
      pStatus_TxARPReplyPacketCount   : out std_logic_vector( 15 downto 0 );
      pStatus_TxICMPReplyPacketCount  : out std_logic_vector( 15 downto 0 );
      pStatus_TxUDP0PacketCount       : out std_logic_vector( 15 downto 0 );
      pStatus_TxUDP1PacketCount       : out std_logic_vector( 15 downto 0 );
      pStatus_TxMulticastPacketCount  : out std_logic_vector( 15 downto 0 );
      
      pStatus_Phy : out std_logic_vector(15 downto 0);
      
      pdebug : out std_logic_vector(63 downto 0)
      );
  end component;

  component resetgen
    port (
      clk       : in  std_logic;
      reset_in  : in  std_logic;
      reset_out : out std_logic
      );
  end component resetgen;

  component idelayctrl_wrapper
    generic (
      CLK_PERIOD : integer := 5
      );
    port (
      clk : in std_logic;
      reset : in std_logic;
      ready : out std_logic
      );
  end component idelayctrl_wrapper;

  signal reset_n    : std_logic;
  signal clk200M    : std_logic;
  signal clk125M    : std_logic;
  signal clk125M_90 : std_logic;
  signal locked     : std_logic;
  signal reset200M  : std_logic := '1';
  signal reset125M  : std_logic := '1';

  signal pUdp0Send_Data    : std_logic_vector(31 downto 0);
  signal pUdp0Send_Request : std_logic;
  signal pUdp0Send_Ack     : std_logic;
  signal pUdp0Send_Enable  : std_logic;

  signal pUdp1Send_Data    : std_logic_vector(31 downto 0);
  signal pUdp1Send_Request : std_logic;
  signal pUdp1Send_Ack     : std_logic;
  signal pUdp1Send_Enable  : std_logic;

  -- UDP rx output
  signal pUdp0Receive_Data    : std_logic_vector(31 downto 0);
  signal pUdp0Receive_Request : std_logic;
  signal pUdp0Receive_Ack     : std_logic;
  signal pUdp0Receive_Enable  : std_logic;

  signal pUdp1Receive_Data    : std_logic_vector( 31 downto 0 );
  signal pUdp1Receive_Request : std_logic;
  signal pUdp1Receive_Ack     : std_logic;
  signal pUdp1Receive_Enable  : std_logic;

  signal status_phy : std_logic_vector(15 downto 0);

  signal counter_clk125 : unsigned(31 downto 0) := (others => '0');

  component udpled
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
  end component udpled;

  signal led_w : std_logic_vector(7 downto 0);

begin

  LED0 <= led_w(0);
  LED1 <= led_w(1);
  LED2 <= led_w(2);

  sys_clk_buf : IBUFDS port map (
    I  => sys_clk_p,
    IB => sys_clk_n,
    O  => sys_clk
    );

  clk_wiz_1_i : clk_wiz_1
    port map(
      clk_out1 => clk200M,
      clk_out2 => clk125M,
      clk_out3 => clk125M_90,
      -- Status and con
      reset    => '0',
      locked   => locked,
      -- Clock in ports
      clk_in1  => sys_clk
      );

  resetgen_i_0 : resetgen port map(clk => clk125M, reset_in => not locked, reset_out => reset125M);
  reset_n <= not reset125M;
  resetgen_i_1 : resetgen port map(clk => clk200M, reset_in => not locked, reset_out => reset200M);

  u_udpled : udpled
    port map(
      -- input
      UPL_input_data => pUdp0Receive_Data,
      UPL_input_en   => pUdp0Receive_Enable,
      UPL_input_req  => pUdp0Receive_Request,
      UPL_input_ack  => pUdp0Receive_Ack,

      -- output
      UPL_output_data => pUdp0Send_Data,
      UPL_output_en   => pUdp0Send_Enable,
      UPL_output_req  => pUdp0Send_Request,
      UPL_output_ack  => pUdp0Send_Ack,

      -- user-defiend ports
      led => led_w,

      -- system clock and reset
      clk   => clk125M,
      reset => reset125M
      );
  
  idelayctrl_wrapper_i : idelayctrl_wrapper generic map(CLK_PERIOD => 5)
    port map(clk => clk200M, reset => reset200M, ready => open);
  
  u_e7udpip : e7udpip_rgmii_artix7
    port map(
      -- GMII PHY
      GEPHY_RST_N     => GEPHY_RST_N,
      GEPHY_MAC_CLK   => clk125M,
      GEPHY_MAC_CLK90 => clk125M_90,
      -- TX out
      GEPHY_TD        => GEPHY_TD,
      GEPHY_TXEN_ER   => GEPHY_TXEN_ER,
      GEPHY_TCK       => GEPHY_TCK,
      -- RX in
      GEPHY_RD        => GEPHY_RD,
      GEPHY_RCK       => GEPHY_RCK,
      GEPHY_RXDV_ER   => GEPHY_RXDV_ER,

      GEPHY_MDC   => GEPHY_MDC,
      GEPHY_MDIO  => GEPHY_MDIO,
      GEPHY_INT_N => GEPHY_INT_N,

      -- Asynchronous Reset
      Reset_n => reset_n,

      -- UPL interface
      pUPLGlobalClk => clk125M,

      -- UDP tx input
      pUdp0Send_Data    => pUdp0Send_Data,
      pUdp0Send_Request => pUdp0Send_Request,
      pUdp0Send_Ack     => pUdp0Send_Ack,
      pUdp0Send_Enable  => pUdp0Send_Enable,

      pUdp1Send_Data    => pUdp1Send_Data,
      pUdp1Send_Request => pUdp1Send_Request,
      pUdp1Send_Ack     => pUdp1Send_Ack,
      pUdp1Send_Enable  => pUdp1Send_Enable,

      -- UDP rx output
      pUdp0Receive_Data    => pUdp0Receive_Data,
      pUdp0Receive_Request => pUdp0Receive_Request,
      pUdp0Receive_Ack     => pUdp0Receive_Ack,
      pUdp0Receive_Enable  => pUdp0Receive_Enable,

      pUdp1Receive_Data    => pUdp1Receive_Data,
      pUdp1Receive_Request => pUdp1Receive_Request,
      pUdp1Receive_Ack     => pUdp1Receive_Ack,
      pUdp1Receive_Enable  => pUdp1Receive_Enable,

      -- MII interface
      pMIIInput_Data    => (others => '0'),
      pMIIInput_Request => '0',
      pMIIInput_Ack     => open,
      pMIIInput_Enable  => '0',

      pMIIOutput_Data    => open,
      pMIIOutput_Request => open,
      pMIIOutput_Ack     => '1',
      pMIIOutput_Enable  => open,

      -- Setup
      pMyIpAddr       => X"0a000003",
      pMyMacAddr      => X"001b1affffff",
      pMyNetmask      => X"ff000000",
      pDefaultGateway => X"0a0000fe",
      pTargetIPAddr   => X"0a000001",
      pMyUdpPort0     => X"4000",
      pMyUdpPort1     => X"4001",
      pPHYAddr        => "00001",
      pPHYMode        => "1000",
      pConfig_Core    => X"00000000",

      -- Status
      -- pStatus_RxByteCount             : out std_logic_vector( 31 downto 0 );
      -- pStatus_RxPacketCount           : out std_logic_vector( 31 downto 0 );
      -- pStatus_RxErrorPacketCount      : out std_logic_vector( 15 downto 0 );
      -- pStatus_RxDropPacketCount       : out std_logic_vector( 15 downto 0 );
      -- pStatus_RxARPRequestPacketCount : out std_logic_vector( 15 downto 0 );
      -- pStatus_RxARPReplyPacketCount   : out std_logic_vector( 15 downto 0 );
      -- pStatus_RxICMPPacketCount       : out std_logic_vector( 15 downto 0 );
      -- pStatus_RxUDP0PacketCount       : out std_logic_vector( 15 downto 0 );
      -- pStatus_RxUDP1PacketCount       : out std_logic_vector( 15 downto 0 );
      -- pStatus_RxIPErrorPacketCount    : out std_logic_vector( 15 downto 0 );
      -- pStatus_RxUDPErrorPacketCount   : out std_logic_vector( 15 downto 0 );

      -- pStatus_TxByteCount             : out std_logic_vector( 31 downto 0 );
      -- pStatus_TxPacketCount           : out std_logic_vector( 31 downto 0 );
      -- pStatus_TxARPRequestPacketCount : out std_logic_vector( 15 downto 0 );
      -- pStatus_TxARPReplyPacketCount   : out std_logic_vector( 15 downto 0 );
      -- pStatus_TxICMPReplyPacketCount  : out std_logic_vector( 15 downto 0 );
      -- pStatus_TxUDP0PacketCount       : out std_logic_vector( 15 downto 0 );
      -- pStatus_TxUDP1PacketCount       : out std_logic_vector( 15 downto 0 );
      -- pStatus_TxMulticastPacketCount  : out std_logic_vector( 15 downto 0 );

      pStatus_Phy => status_phy

     -- pdebug : out std_logic_vector(63 downto 0)
      );

  pUdp1Send_Data    <= pUdp1Receive_Data;
  pUdp1Send_Request <= pUdp1Receive_Request;
  pUdp1Receive_Ack  <= pUdp1Send_Ack;
  pUdp1Send_Enable  <= pUdp1Receive_Enable;

end architecture RTL;
