module input_layer(
	// Outputs
	outputs, rcv_req, snd_ack,
	// Inputs
	clk, xrst, inputs, rcv_ack, snd_req
	);
	
	input		clk;
	input		xrst;
	
	input		rcv_ack;
	input		snd_req;
	input [783:0]	inputs;
	
	output rcv_req;
	output snd_ack;
	output [255:0] outputs;
	
	reg [7:0] address;
	reg [9:0] saddress;
	reg [783:0] inputs_mem;
	wire [783:0] w1;
	reg [255:0] outputs_mem;
	wire b1;
	
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
				if (address == 255 && saddress == 784)
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
	
	assign rcv_req = (st_reg == ST_WAIT) ? 1'b1: 1'b0;
	assign snd_ack = (st_reg == ST_SND) ? 1'b1: 1'b0;
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			address <= 8'b0;
		else if (st_reg == ST_CALC && saddress == 784) begin
			if (address == 255)
				address <= 8'b0;
			else
				address <= address + 8'b1;
		end
	end
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			saddress <= 0;
		else if (st_reg == ST_CALC) begin
			if (saddress == 784)
				saddress <= 0;
			else 
				saddress <= saddress + 1;
		end
	end
	
	weight_rom_input Weight_Rom_Input(.maddress(address), .mw1(w1), .mb1(b1));
	
	reg [9:0] sum;
	wire [783:0] m1;
	
	assign m1 = inputs_mem ^ w1;
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			sum <= 0;
		else if (saddress == 784)
			sum <= 0;
		else
			sum <= sum + m1[saddress];
	end
	
	wire result;
	
	assign result = (sum + b1 > 392) ? 1 : 0;
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			outputs_mem <= 0;
		else if (st_reg == ST_CALC)
			outputs_mem[address] <= result;
	end
	
	assign outputs = outputs_mem;
	
endmodule

module weight_rom_input(maddress, mw1, mb1);
	input [7:0] maddress;
	output [783:0] mw1;
	output mb1;

	reg [783:0] memory_w1 [255:0];
	reg memory_b1 [255:0];
	
	assign mw1 = memory_w1[maddress];
	assign mb1 = memory_b1[maddress];

	initial begin
		$readmemb("./w1.txt", memory_w1);
		$readmemb("./b1.txt", memory_b1);
	end
endmodule