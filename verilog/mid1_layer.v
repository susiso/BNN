module mid1_layer(
	// Outputs
	outputs, rcv_req, snd_ack,
	// Inputs
	clk, xrst, inputs, rcv_ack, snd_req
	);
	
	input		clk;
	input		xrst;
	
	input		rcv_ack;
	input		snd_req;
	input [255:0]	inputs;
	
	output rcv_req;
	output snd_ack;
	output [127:0] outputs;
	
	reg [7:0] address;
	reg [9:0] saddress;
	reg [255:0] inputs_mem;
	wire [255:0] w2;
	reg [127:0] outputs_mem;
	wire b2;
	
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
				if (address == 127 && saddress == 256)
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
			if (saddress == 256)
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
		else if (st_reg == ST_CALC && saddress == 255) begin
			if (address == 127)
				address <= 8'b0;
			else
				address <= address + 8'b1;
		end
	end
	
	weight_rom_mid1 Weight_Rom_Mid1(.maddress(address), .mw2(w2), .mb2(b2));
		
	reg [9:0] sum;
	wire [255:0] m1;
	
	assign m1 = inputs_mem ^ w2;
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			sum <= 0;
		else if (saddress == 256)
			sum <= 0;
		else
			sum <= sum + m1[saddress];
	end
	
	wire result;
	
	assign result = (sum + b2 > 128) ? 1 : 0;
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			outputs_mem <= 0;
		else if (st_reg == ST_CALC)
			outputs_mem[address] <= result;
	end
	
	assign outputs = outputs_mem;
	
endmodule

module weight_rom_mid1(maddress, mw2, mb2);
	input [7:0] maddress;
	output [255:0] mw2;
	output mb2;

	reg [255:0] memory_w2 [127:0];
	reg memory_b2 [127:0];
	
	assign mw2 = memory_w2[maddress];
	assign mb2 = memory_b2[maddress];

	initial begin
		$readmemb("./w2.txt", memory_w2);
		$readmemb("./b2.txt", memory_b2);
	end
endmodule