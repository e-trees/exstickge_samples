`default_nettype none

module simple_udprecv(
		      input wire clk,
		      input wire reset,

		      input wire UPLin_Reqeust,
		      output reg UPLin_Ack,
		      input wire UPLin_Enable,
		      input wire [31:0] UPLin_Data,

		      output reg UPLout_Reqeust,
		      input wire UPLout_Ack,
		      output reg UPLout_Enable,
		      output reg [31:0] UPLout_Data
		      );

    reg [7:0] state = 0;

    localparam STATE_IDLE = 8'd0;

    localparam STATE_RECV_DST_IP = 8'd1;
    localparam STATE_RECV_SRC_IP = 8'd2;
    localparam STATE_RECV_DST_SRC_PORT = 8'd3;
    localparam STATE_RECV_BYTES = 8'd4;
    localparam STATE_RECV_DATA = 8'd5;

    localparam STATE_SEND_SRC_IP = 8'd6;
    localparam STATE_SEND_DST_IP = 8'd7;
    localparam STATE_SEND_SRC_DST_PORT = 8'd8;
    localparam STATE_SEND_BYTES = 8'd9;
    localparam STATE_SEND_DATA1 = 8'd10;
    localparam STATE_SEND_DATA2 = 8'd11;

    reg [31:0] my_ip_addr;
    reg [31:0] host_ip_addr;
    reg [15:0] my_port;
    reg [15:0] host_port;
    reg [31:0] payload_bytes;

    reg [31:0] summation;

    always @(posedge clk) begin
	if(reset == 1) begin
	    UPLin_Ack <= 1'b0;
	    UPLout_Reqeust <= 1'b0;
	    UPLout_Enable <= 1'b0;
	    UPLout_Data <= 32'h0;
	    state <= STATE_IDLE;
	end else begin

	    case(state)

		STATE_IDLE: begin
		    if(UPLin_Enable == 1'b1) begin
			state <= STATE_RECV_SRC_IP;
			UPLin_Ack <= 1'b0; // In receiving, this module cannot receive the other packets.
			my_ip_addr <= UPLin_Data; // receive the 1st word.
		    end else begin
			UPLin_Ack <= 1'b1; // wait for a packet
		    end
		    summation <= 0;
		    UPLout_Enable <= 1'b0;
		end

		STATE_RECV_SRC_IP: begin
		    if(UPLin_Enable == 1'b0) begin
			state <= STATE_IDLE; // illegal packet
		    end else begin
			host_ip_addr <= UPLin_Data;
			state <= STATE_RECV_DST_SRC_PORT;
		    end
		end

		STATE_RECV_DST_SRC_PORT: begin
		    if(UPLin_Enable == 1'b0) begin
			state <= STATE_IDLE; // illegal packet
		    end else begin
			my_port <= UPLin_Data[31:16];
			host_port <= UPLin_Data[15:0];
			state <= STATE_RECV_BYTES;
		    end
		end

		STATE_RECV_BYTES: begin
		    if(UPLin_Enable == 1'b0) begin
			state <= STATE_IDLE; // illegal packet
		    end else begin
			payload_bytes <= UPLin_Data;
			state <= STATE_RECV_DATA;
		    end
		end

		STATE_RECV_DATA: begin
		    if(UPLin_Enable == 1'b0) begin // end of packet
			state <= STATE_SEND_SRC_IP;
			UPLout_Reqeust <= 1'b1; // ready to send a reply packet
		    end else begin
			summation <= UPLin_Data + summation;
		    end
		end

		STATE_SEND_SRC_IP : begin
		    if(UPLout_Ack == 1'b1) begin
			state <= STATE_SEND_DST_IP;
			UPLout_Reqeust <= 1'b0;
			UPLout_Enable <= 1'b1;
			UPLout_Data <= my_ip_addr;
		    end
		end

		STATE_SEND_DST_IP: begin
		    state <= STATE_SEND_SRC_DST_PORT;
		    UPLout_Enable <= 1'b1;
		    UPLout_Data <= host_ip_addr;
		end
		
		STATE_SEND_SRC_DST_PORT: begin
		    state <= STATE_SEND_BYTES;
		    UPLout_Enable <= 1'b1;
		    UPLout_Data <= {my_port, host_port};
		end

		STATE_SEND_BYTES: begin
		    state <= STATE_SEND_DATA1;
		    UPLout_Enable <= 1'b1;
		    UPLout_Data <= 32'd8; // 8 bytes
		end

		STATE_SEND_DATA1: begin
		    state <= STATE_SEND_DATA2;
		    UPLout_Enable <= 1'b1;
		    UPLout_Data <= 32'h53756d3a; // (format "32'h%x%x%x%x" ?S ?u ?m ?:)
		end

		STATE_SEND_DATA2: begin
		    state <= STATE_IDLE;
		    UPLout_Enable <= 1'b1;
		    UPLout_Data <= summation;
		end

		default: begin
		    UPLin_Ack <= 1'b0;
		    UPLout_Reqeust <= 1'b0;
		    UPLout_Enable <= 1'b0;
		    UPLout_Data <= 32'h0;
		    state <= STATE_IDLE;
		end

	    endcase // case (state)
	end // else: !if(reset == 1)
    end // always @ (posedge clk)

endmodule // simple_udprecv

`default_nettype wire
