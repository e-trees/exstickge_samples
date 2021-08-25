`default_nettype none

module top (
	    output wire [3:0] GEPHY_TD,
	    output wire       GEPHY_TXEN_ER,
	    output wire       GEPHY_TCK,
	    input wire [3:0]  GEPHY_RD,
	    input wire 	      GEPHY_RCK,
	    input wire 	      GEPHY_RXDV_ER,
	    input wire 	      GEPHY_MAC_CLK,
    
	    output wire       GEPHY_MDC,
	    inout wire 	      GEPHY_MDIO,
	    input wire 	      GEPHY_INT_N,
	    input wire 	      GEPHY_PMEB,
	    output wire       GEPHY_RST_N,
    
	    // GPIO
	    inout wire 	      GPIO00,
	    inout wire 	      GPIO01,
	    inout wire 	      GPIO02,
	    inout wire 	      GPIO03,
	    inout wire 	      GPIO04,
	    inout wire 	      GPIO05,
	    inout wire 	      GPIO06,
	    inout wire 	      GPIO07,
	    inout wire 	      GPIO10,
	    inout wire 	      GPIO11,
	    inout wire 	      GPIO12,
	    inout wire 	      GPIO13,
    
	    inout wire 	      GPIO14,
	    inout wire 	      GPIO15,
    
	    inout wire 	      GPIO20,
	    inout wire 	      GPIO21,
	    inout wire 	      GPIO22,
	    inout wire 	      GPIO23,
	    inout wire 	      GPIO24,
	    inout wire 	      GPIO25,
	    inout wire 	      GPIO26,
	    inout wire 	      GPIO27,
	    inout wire 	      GPIO30,
	    inout wire 	      GPIO31,
	    inout wire 	      GPIO32,
	    inout wire 	      GPIO33,
	    inout wire 	      GPIO34,
	    inout wire 	      GPIO35,
    

	    inout wire 	      GPIO40,
	    inout wire 	      GPIO41,
	    inout wire 	      GPIO42,
	    inout wire 	      GPIO43,
	    inout wire 	      GPIO44,
	    inout wire 	      GPIO45,
	    inout wire 	      GPIO46,
	    inout wire 	      GPIO47,
	    inout wire 	      GPIO50,
	    inout wire 	      GPIO51,
	    inout wire 	      GPIO52,
	    inout wire 	      GPIO53,
    
	    inout wire 	      GPIO54,
	    inout wire 	      GPIO55,
    
	    inout wire 	      GPIO60,
	    inout wire 	      GPIO61,
	    inout wire 	      GPIO62,
	    inout wire 	      GPIO63,
	    inout wire 	      GPIO64,
	    inout wire 	      GPIO65,
	    inout wire 	      GPIO66,
	    inout wire 	      GPIO67,
	    inout wire 	      GPIO70,
	    inout wire 	      GPIO71,
	    inout wire 	      GPIO72,
	    inout wire 	      GPIO73,
	    inout wire 	      GPIO74,
	    inout wire 	      GPIO75,
    
	    inout wire 	      HDMI0_D0_P,
	    inout wire 	      HDMI0_D0_N,
	    inout wire 	      HDMI0_D1_P,
	    inout wire 	      HDMI0_D1_N,
	    inout wire 	      HDMI0_D2_P,
	    inout wire 	      HDMI0_D2_N,
	    inout wire 	      HDMI0_SCL ,
	    inout wire 	      HDMI0_SDA ,
	    inout wire 	      HDMI0_CLK_P,
	    inout wire 	      HDMI0_CLK_N,
    
	    inout wire 	      HDMI1_D0_P,
	    inout wire 	      HDMI1_D0_N,
	    inout wire 	      HDMI1_D1_P,
	    inout wire 	      HDMI1_D1_N,
	    inout wire 	      HDMI1_D2_P,
	    inout wire 	      HDMI1_D2_N,
	    inout wire 	      HDMI1_SCL ,
	    inout wire 	      HDMI1_SDA ,
	    inout wire 	      HDMI1_CLK_P,
	    inout wire 	      HDMI1_CLK_N,
    
	    inout wire [3:0]  PMOD,
    
	    // DEBUG
	    output wire       LED0,
	    output wire       LED1,
	    output wire       LED2,
			      
	    // Inputs
	    // Single-ended system clock
	    input wire sys_clk_p,
	    input wire sys_clk_n,
	    input wire sys_rst_n
    );

   wire 	       sys_clk;
   wire 	       clk310M;
   wire 	       clk155M;
   wire 	       clk200M;
   wire 	       clk125M;
   wire 	       clk125M_90;
   wire 	       locked_0;
   wire 	       locked_1;
   wire 	       reset125M;
   wire 	       reset200M;

   wire [31:0] 	       pUdp0Send_Data;
   wire 	       pUdp0Send_Request;
   wire 	       pUdp0Send_Ack;
   wire 	       pUdp0Send_Enable;

   wire [31:0] 	       pUdp1Send_Data;
   wire 	       pUdp1Send_Request;
   wire 	       pUdp1Send_Ack;
   wire 	       pUdp1Send_Enable;

   wire [31:0] 	       pUdp0Receive_Data;
   wire 	       pUdp0Receive_Request;
   wire 	       pUdp0Receive_Ack;
   wire 	       pUdp0Receive_Enable;

   wire [31:0] 	       pUdp1Receive_Data;
   wire 	       pUdp1Receive_Request;
   wire 	       pUdp1Receive_Ack;
   wire 	       pUdp1Receive_Enable;

   // MII interface
   wire [31:0] 	       pMIIInput_Data;
   wire 	       pMIIInput_Request;
   wire 	       pMIIInput_Ack;
   wire 	       pMIIInput_Enable;

   wire [31:0] 	       pMIIOutput_Data;
   wire 	       pMIIOutput_Request;
   wire 	       pMIIOutput_Ack;
   wire 	       pMIIOutput_Enable;

   wire [15:0] 	       status_phy;
   wire 	       sys_rst;
  
   reg [31:0] 	       counter125M;

   assign sys_rst = ~sys_rst_n;

   assign GPIO00 = 1'b0;
   assign GPIO01 = 1'b0;
   assign GPIO02 = 1'b0;
   assign GPIO03 = 1'b0;
   assign GPIO04 = 1'b0;
   assign GPIO05 = 1'b0;
   assign GPIO06 = 1'b0;
   assign GPIO07 = 1'b0;
   assign GPIO10 = 1'b0;
   assign GPIO11 = 1'b0;
   assign GPIO12 = 1'b0;
   assign GPIO13 = 1'b0;
  
   assign GPIO14 = 1'b0;
   assign GPIO15 = 1'b0;

   assign GPIO20 = 1'b0;
   assign GPIO21 = 1'b0;
   assign GPIO22 = 1'b0;
   assign GPIO23 = 1'b0;
   assign GPIO24 = 1'b0;
   assign GPIO25 = 1'b0;
   assign GPIO26 = 1'b0;
   assign GPIO27 = 1'b0;
   assign GPIO30 = 1'b0;
   assign GPIO31 = 1'b0;
   assign GPIO32 = 1'b0;
   assign GPIO33 = 1'b0;
   assign GPIO34 = 1'b0;
   assign GPIO35 = 1'b0;

   assign GPIO40 = 1'b0;
   assign GPIO41 = 1'b0;
   assign GPIO42 = 1'b0;
   assign GPIO43 = 1'b0;
   assign GPIO44 = 1'b0;
   assign GPIO45 = 1'b0;
   assign GPIO46 = 1'b0;
   assign GPIO47 = 1'b0;
   assign GPIO50 = 1'b0;
   assign GPIO51 = 1'b0;
   assign GPIO52 = 1'b0;
   assign GPIO53 = 1'b0;
  
   assign GPIO54 = 1'b0;
   assign GPIO55 = 1'b0;
  
   assign GPIO60 = 1'b0;
   assign GPIO61 = 1'b0;
   assign GPIO62 = 1'b0;
   assign GPIO63 = 1'b0;
   assign GPIO64 = 1'b0;
   assign GPIO65 = 1'b0;
   assign GPIO66 = 1'b0;
   assign GPIO67 = 1'b0;
   assign GPIO70 = 1'b0;
   assign GPIO71 = 1'b0;
   assign GPIO72 = 1'b0;
   assign GPIO73 = 1'b0;
   assign GPIO74 = 1'b0;
   assign GPIO75 = 1'b0;

   assign HDMI0_D0_P = 1'b0;
   assign HDMI0_D0_N = 1'b0;
   assign HDMI0_D1_P = 1'b0;
   assign HDMI0_D1_N = 1'b0;
   assign HDMI0_D2_P = 1'b0;
   assign HDMI0_D2_N = 1'b0;
   assign HDMI0_SCL  = 1'b0;
   assign HDMI0_SDA  = 1'b0;
   assign HDMI0_CLK_P =1'b0;
   assign HDMI0_CLK_N =1'b0;
   
   assign HDMI1_D0_P = 1'b0;
   assign HDMI1_D0_N = 1'b0;
   assign HDMI1_D1_P = 1'b0;
   assign HDMI1_D1_N = 1'b0;
   assign HDMI1_D2_P = 1'b0;
   assign HDMI1_D2_N = 1'b0;
   assign HDMI1_SCL  = 1'b0;
   assign HDMI1_SDA  = 1'b0;
   assign HDMI1_CLK_P =1'b0;
   assign HDMI1_CLK_N =1'b0;

   assign PMOD = 4'h0;
  
   wire 	       idctl_rst, idctl_rdy;
   reg [5:0] 	       idctl_rst_reg = 6'b001111;
   always @(posedge clk200M)
     idctl_rst_reg <= {idctl_rst_reg[4:0],1'b0};
   assign idctl_rst = idctl_rst_reg[5];
   
   assign LED0 = status_phy[0];
   assign LED1 = ~reset125M;
   assign LED2 = pUdp0Receive_Enable || pUdp1Receive_Enable;

   IBUFDS sys_clk_buf(.I(sys_clk_p),
		      .IB(sys_clk_n),
		      .O(sys_clk));

   clk_wiz_0 clk_wiz_0_i(.clk_out1(clk310M),
			 .locked(locked_0),
			 .reset(sys_rst),
			 .clk_in1(sys_clk));

   clk_wiz_1 clk_wiz_1_i(.clk_out1(clk200M),
			 .clk_out2(clk125M),
			 .clk_out3(clk125M_90),
			 .reset(sys_rst),
			 .locked(locked_1),
			 .clk_in1(GEPHY_MAC_CLK));
   
   resetgen resetgen_i_0(.clk(clk125M),
			 .reset_in(~locked_1 || sys_rst),
			 .reset_out(reset125M));
   
   resetgen resetgen_i_1(.clk(clk200M),
			 .reset_in(~locked_1 || sys_rst),
			 .reset_out(reset200M));

   idelayctrl_wrapper#(.CLK_PERIOD(5))(.clk(clk200M), .reset(reset200M), .ready());
   
   assign GEPHY_RST_N = locked_0 && sys_rst_n;

   e7udpip_rgmii_artix7
   u_e7udpip (
	      // GMII PHY
	      .GEPHY_RST_N(),
	      .GEPHY_MAC_CLK(clk125M),
	      .GEPHY_MAC_CLK90(clk125M_90),
	      // TX out
	      .GEPHY_TD(GEPHY_TD),
	      .GEPHY_TXEN_ER(GEPHY_TXEN_ER),
	      .GEPHY_TCK(GEPHY_TCK),
	      // RX in
	      .GEPHY_RD(GEPHY_RD),
	      .GEPHY_RCK(GEPHY_RCK),
	      .GEPHY_RXDV_ER(GEPHY_RXDV_ER),
      
	      .GEPHY_MDC(GEPHY_MDC),
	      .GEPHY_MDIO(GEPHY_MDIO),
	      .GEPHY_INT_N(GEPHY_INT_N),
      
	      // Asynchronous Reset
	      .Reset_n(~reset125M),
      
	      // UPL interface
	      .pUPLGlobalClk(clk125M),
	      
	      // UDP tx input
	      .pUdp0Send_Data(pUdp0Send_Data),
	      .pUdp0Send_Request(pUdp0Send_Request),
	      .pUdp0Send_Ack(pUdp0Send_Ack),
	      .pUdp0Send_Enable(pUdp0Send_Enable),
	      
	      .pUdp1Send_Data(pUdp1Send_Data),
	      .pUdp1Send_Request(pUdp1Send_Request),
	      .pUdp1Send_Ack(pUdp1Send_Ack),
	      .pUdp1Send_Enable(pUdp1Send_Enable),
	      
	      // UDP rx output
	      .pUdp0Receive_Data(pUdp0Receive_Data),
	      .pUdp0Receive_Request(pUdp0Receive_Request),
	      .pUdp0Receive_Ack(pUdp0Receive_Ack),
	      .pUdp0Receive_Enable(pUdp0Receive_Enable),
	      
	      .pUdp1Receive_Data(pUdp1Receive_Data),
	      .pUdp1Receive_Request(pUdp1Receive_Request),
	      .pUdp1Receive_Ack(pUdp1Receive_Ack),
	      .pUdp1Receive_Enable(pUdp1Receive_Enable),
	      
	      // MII interface
	      .pMIIInput_Data(pMIIInput_Data),
	      .pMIIInput_Request(pMIIInput_Request),
	      .pMIIInput_Ack(pMIIInput_Ack),
	      .pMIIInput_Enable(pMIIInput_Enable),
	      
	      .pMIIOutput_Data(pMIIOutput_Data),
	      .pMIIOutput_Request(pMIIOutput_Request),
	      .pMIIOutput_Ack(pMIIOutput_Ack),
	      .pMIIOutput_Enable(pMIIOutput_Enable),
	      
	      // Setup
	      .pMyIpAddr(32'h0a000003),
	      .pMyMacAddr(48'h001b1affffff),
	      .pMyNetmask(32'hff000000),
	      .pDefaultGateway(32'h0a0000fe),
	      .pTargetIPAddr(32'h0a000001),
	      .pMyUdpPort0(16'h4000),
	      .pMyUdpPort1(16'h4001),
	      .pPHYAddr(5'b00001),
	      .pPHYMode(4'b1000),
	      .pConfig_Core(8'b00000000),
	      
	      // Status
	      .pStatus_RxByteCount(),
	      .pStatus_RxPacketCount(),
	      .pStatus_RxErrorPacketCount(),
	      .pStatus_RxDropPacketCount(),
	      .pStatus_RxARPRequestPacketCount(),
	      .pStatus_RxARPReplyPacketCount(),
	      .pStatus_RxICMPPacketCount(),
	      .pStatus_RxUDP0PacketCount(),
	      .pStatus_RxUDP1PacketCount(),
	      .pStatus_RxIPErrorPacketCount(),
	      .pStatus_RxUDPErrorPacketCount(),
	      
	      .pStatus_TxByteCount(),
	      .pStatus_TxPacketCount(),
	      .pStatus_TxARPRequestPacketCount(),
	      .pStatus_TxARPReplyPacketCount(),
	      .pStatus_TxICMPReplyPacketCount(),
	      .pStatus_TxUDP0PacketCount(),
	      .pStatus_TxUDP1PacketCount(),
	      .pStatus_TxMulticastPacketCount(),
	      
	      .pStatus_Phy(status_phy),
	      
	      .pdebug()
	      );

   assign pMIIInput_Data    = 32'h00000000;
   assign pMIIInput_Request = 1'b0;
   assign pMIIInput_Enable  = 1'b0;
   assign pMIIOutput_Ack    = 1'b1;

   //assign pUdp0Send_Data    = pUdp0Receive_Data;
   //assign pUdp0Send_Request = pUdp0Receive_Request;
   //assign pUdp0Receive_Ack  = pUdp0Send_Ack;
   //assign pUdp0Send_Enable  = pUdp0Receive_Enable;
   
   assign pUdp1Send_Data    = pUdp1Receive_Data;
   assign pUdp1Send_Request = pUdp1Receive_Request;
   assign pUdp1Receive_Ack  = pUdp1Send_Ack;
   assign pUdp1Send_Enable  = pUdp1Receive_Enable;

   ila_0 ila_0_i(.clk(clk125M),
		 .probe0({pUdp0Receive_Request, pUdp0Receive_Ack, pUdp0Receive_Enable, pUdp0Receive_Data}),
		 .probe1({pUdp0Send_Request, pUdp0Send_Ack, pUdp0Send_Enable, pUdp0Send_Data})
		 );

    simple_udprecv DUT(
		       .clk(clk125M),
		       .reset(reset125M),
		       
		       .UPLin_Reqeust(pUdp0Receive_Request),
		       .UPLin_Ack(pUdp0Receive_Ack),
		       .UPLin_Enable(pUdp0Receive_Enable),
		       .UPLin_Data(pUdp0Receive_Data),
		       
		       .UPLout_Reqeust(pUdp0Send_Request),
		       .UPLout_Ack(pUdp0Send_Ack),
		       .UPLout_Enable(pUdp0Send_Enable),
		       .UPLout_Data(pUdp0Send_Data)
		       );
    
endmodule // top

`default_nettype wire

