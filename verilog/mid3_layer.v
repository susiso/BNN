module mid3_layer(
	// Outputs
	output0, output1, output2, output3, output4, output5, output6, output7, output8, output9, rcv_req, snd_ack,
	// Inputs
	clk, xrst, inputs, rcv_ack, snd_req
	);
	
	input		clk;
	input		xrst;
	
	input		rcv_ack;
	input		snd_req;
	input [31:0]	inputs;
	
	output rcv_req;
	output snd_ack;
	output [5:0] output0;
	output [5:0] output1;
	output [5:0] output2;
	output [5:0] output3;
	output [5:0] output4;
	output [5:0] output5;
	output [5:0] output6;
	output [5:0] output7;
	output [5:0] output8;
	output [5:0] output9;
	
	reg [7:0] address;
	reg [7:0] saddress;
	reg [31:0] inputs_mem;
	wire [31:0] w4;
	reg [5:0] outputs_mem [9:0];
	wire b4;
	
	// state machine
   reg [2:0]   st_reg;
   parameter   ST_WAIT    = 3'd0;
   parameter   ST_RCV     = 3'd1;
   parameter   ST_CALC 	  = 3'd2;
   parameter   ST_SND_WAIT     = 3'd3;
	parameter   ST_SND	  = 3'd4;
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			st_reg <= ST_WAIT;
		else case (st_reg)
			ST_WAIT:
				if (rcv_ack == 1'b1)
					st_reg <= ST_RCV;
			ST_RCV:
				if (rcv_req == 1'b0)
					st_reg <= ST_CALC;
			ST_CALC:
				if (address == 9 && saddress == 32)
					st_reg <= ST_SND_WAIT;
			ST_SND_WAIT:
				if (snd_req == 1'b1)
					st_reg <= ST_SND;
			ST_SND:
				if (snd_req == 1'b0)
					st_reg <= ST_WAIT;
		endcase
	end
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			inputs_mem <= 0;
		else if (st_reg == ST_RCV)
			inputs_mem <= inputs;
	end
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			saddress <= 0;
		else if (st_reg == ST_CALC) begin
			if (saddress == 32)
				saddress <= 0;
			else 
				saddress <= saddress + 1;
		end
	end
	
	assign rcv_req = (st_reg == ST_WAIT) ? 1'b1: 1'b0;
	assign snd_ack = (st_reg == ST_SND) ? 1'b1: 1'b0;
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			address <= 8'b0;
		else if (st_reg == ST_CALC && saddress == 32) begin
			if (address == 9)
				address <= 8'b0;
			else
				address <= address + 8'b1;
		end
	end
	
	weight_rom_mid3 Weight_Rom_Mid3(.maddress(address), .mw4(w4), .mb4(b4));
	
	wire [31:0] m1;
	reg [9:0] sum;
	
	assign m1 = inputs_mem ^ w4;
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			sum <= 0;
		else if (saddress == 32)
			sum <= 0;
		else
			sum <= sum + m1[saddress];
	end
	
	wire [5:0] result;
	
	assign result = sum + b4;
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0) begin
			outputs_mem[0] <= 0;
			outputs_mem[1] <= 0;
			outputs_mem[2] <= 0;
			outputs_mem[3] <= 0;
			outputs_mem[4] <= 0;
			outputs_mem[5] <= 0;
			outputs_mem[6] <= 0;
			outputs_mem[7] <= 0;
			outputs_mem[8] <= 0;
			outputs_mem[9] <= 0;		
		end
		else if (st_reg == ST_CALC)
			outputs_mem[address] <= result;
	end
	
	assign output0 = outputs_mem[0];
	assign output1 = outputs_mem[1];
	assign output2 = outputs_mem[2];
	assign output3 = outputs_mem[3];
	assign output4 = outputs_mem[4];
	assign output5 = outputs_mem[5];
	assign output6 = outputs_mem[6];
	assign output7 = outputs_mem[7];
	assign output8 = outputs_mem[8];
	assign output9 = outputs_mem[9];
	
endmodule

module weight_rom_mid3(maddress, mw4, mb4);
	input [7:0] maddress;
	output [31:0] mw4;
	output mb4;

	reg [31:0] memory_w4 [9:0];
	reg memory_b4 [9:0];
	
	assign mw4 = memory_w4[maddress];
	assign mb4 = memory_b4[maddress];

	initial begin
		$readmemb("./w4.txt", memory_w4);
		$readmemb("./b4.txt", memory_b4);
	end
endmodule