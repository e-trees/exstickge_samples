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

   wire 	       idctl_rst, idctl_rdy;
   reg [5:0] 	       idctl_rst_reg = 6'b001111;
   always @(posedge clk200M)
     idctl_rst_reg <= {idctl_rst_reg[4:0],1'b0};
   assign idctl_rst = idctl_rst_reg[5];

   wire [7:0] led_w;

   assign LED0 = led_w[0];
   assign LED1 = led_w[1];
   assign LED2 = led_w[2];

   IBUFDS sys_clk_buf(.I(sys_clk_p),
		      .IB(sys_clk_n),
		      .O(sys_clk));

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
   
   assign GEPHY_RST_N = sys_rst_n;

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

    udpled DUT(
	       .UPL_input_data(pUdp0Receive_Data),
	       .UPL_input_en(pUdp0Receive_Enable),
	       .UPL_input_req(pUdp0Receive_Request),
	       .UPL_input_ack(pUdp0Receive_Ack),
	       .UPL_output_data(pUdp0Send_Data),
	       .UPL_output_en(pUdp0Send_Enable),
	       .UPL_output_req(pUdp0Send_Request),
	       .UPL_output_ack(pUdp0Send_Ack),
	       .led(led_w),
	       .clk(clk125M),
	       .reset(reset125M)
	       );

    
endmodule // top

`default_nettype wire

