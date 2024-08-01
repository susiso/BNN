module image_reg(
	// Outputs
	outputs, rcv_req, snd_ack,
	// Inputs
	clk, xrst, inputs, rcv_ack, snd_req
	);
	
	parameter INPUT_NUM = 784;
	
	input		clk;
	input		xrst;
	
	input		rcv_ack;
	input		snd_req;
	input    inputs;
	
	output rcv_req;
	output snd_ack;
	output [783:0] outputs;
	
	reg [9:0] address;
	reg [783:0] mem;

	
	// state machine
   reg [1:0]   st_reg;
   parameter   ST_WAIT    = 2'd0;
   parameter   ST_RCV     = 2'd1;
   parameter   ST_SND_WAIT     = 2'd2;
	parameter   ST_SND	  = 2'd3;
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			st_reg <= ST_WAIT;
		else case (st_reg)
			ST_WAIT:
				if (rcv_ack == 1'b1)
					st_reg <= ST_RCV;
			ST_RCV:
				if (address == INPUT_NUM - 1)
					st_reg <= ST_SND_WAIT;
			ST_SND_WAIT:
				if (snd_req == 1'b1)
					st_reg <= ST_SND;
			ST_SND:
				if (snd_req == 1'b0)
					st_reg <= ST_WAIT;
		endcase
	end
	
	assign rcv_req = ((st_reg == ST_WAIT) || (st_reg == ST_RCV))? 1'b1: 1'b0;
	assign snd_ack = (st_reg == ST_SND) ? 1'b1: 1'b0;
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			address <= 9'b0;
		else if (st_reg == ST_RCV) begin
			if (address == INPUT_NUM - 1)
				address <= 9'b0;
			else
				address <= address + 9'b1;
		end
		else
			address <= 8'b0;
	end
	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			mem <= 0;
		else if (st_reg == ST_RCV)
			mem[address] <= inputs;
	end
	
	assign outputs = mem;
	
endmodule