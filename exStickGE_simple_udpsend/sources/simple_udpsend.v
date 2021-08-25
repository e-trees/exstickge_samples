`default_nettype none

module simple_udpsend(
		      input wire clk,
		      input wire reset,

		      input wire UPLin_Reqeust,
		      output wire UPLin_Ack,
		      input wire UPLin_Enable,
		      input wire [31:0] UPLin_Data,

		      output reg UPLout_Reqeust,
		      input wire UPLout_Ack,
		      output reg UPLout_Enable,
		      output reg [31:0] UPLout_Data,

		      input wire [31:0] DST_IP,
		      input wire [31:0] SRC_IP,
		      input wire [15:0] SRC_PORT,
		      input wire [15:0] DST_PORT
		      );

    assign UPLin_Ack = 1'b1;

    reg [31:0] wait_counter = 0;
    reg [31:0] heartbeat_counter = 0;
    reg [7:0] state = 0;

    localparam STATE_IDLE = 8'd0;
    localparam STATE_SEND_SRC_IP = 8'd1;
    localparam STATE_SEND_DST_IP = 8'd2;
    localparam STATE_SEND_SRC_DST_PORT = 8'd3;
    localparam STATE_SEND_BYTES = 8'd4;
    localparam STATE_SEND_DATA1 = 8'd5;
    localparam STATE_SEND_DATA2 = 8'd6;

    always @(posedge clk) begin
	if(reset == 1) begin
	    UPLout_Reqeust <= 1'b0;
	    UPLout_Enable <= 1'b0;
	    UPLout_Data <= 32'h0;
	    wait_counter <= 32'd0;
	    state <= STATE_IDLE;
	    heartbeat_counter <= 0;
	end else begin
	    heartbeat_counter <= heartbeat_counter + 1;

	    case(state)

		STATE_IDLE: begin
		    if(wait_counter < 32'd125000000) begin
			wait_counter <= wait_counter + 1;
			UPLout_Reqeust <= 1'b0;
		    end else begin
			state <= STATE_SEND_SRC_IP;
			wait_counter <= 1'b0;
			UPLout_Reqeust <= 1'b1;
		    end
		    UPLout_Enable <= 1'b0;
		    UPLout_Data <= 32'h0;
		end

		STATE_SEND_SRC_IP : begin
		    if(UPLout_Ack == 1'b1) begin
			state <= STATE_SEND_DST_IP;
			UPLout_Reqeust <= 1'b0;
			UPLout_Enable <= 1'b1;
			UPLout_Data <= SRC_IP;
		    end
		end

		STATE_SEND_DST_IP: begin
		    state <= STATE_SEND_SRC_DST_PORT;
		    UPLout_Enable <= 1'b1;
		    UPLout_Data <= DST_IP;
		end
		
		STATE_SEND_SRC_DST_PORT: begin
		    state <= STATE_SEND_BYTES;
		    UPLout_Enable <= 1'b1;
		    UPLout_Data <= {SRC_PORT, DST_PORT};
		end

		STATE_SEND_BYTES: begin
		    state <= STATE_SEND_DATA1;
		    UPLout_Enable <= 1'b1;
		    UPLout_Data <= 32'd8; // 8 bytes
		end

		STATE_SEND_DATA1: begin
		    state <= STATE_SEND_DATA2;
		    UPLout_Enable <= 1'b1;
		    UPLout_Data <= 32'h53656e64; // (format "32'h%x%x%x%x" ?S ?e ?n ?d)
		end

		STATE_SEND_DATA2: begin
		    state <= STATE_IDLE;
		    UPLout_Enable <= 1'b1;
		    UPLout_Data <= heartbeat_counter;
		end

		default: begin
		    UPLout_Reqeust <= 1'b0;
		    UPLout_Enable <= 1'b0;
		    UPLout_Data <= 32'h0;
		    wait_counter <= 32'd0;
		    state <= STATE_IDLE;
		end

	    endcase // case (state)
	end // else: !if(reset == 1)
    end // always @ (posedge clk)

endmodule // simple_udpsend

`default_nettype wire
