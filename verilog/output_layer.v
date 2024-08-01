module output_layer(
	// Outputs
	outputs, rcv_req, snd_ack,
	// Inputs
	clk, xrst, input0, input1, input2, input3, input4, input5, input6, input7, input8, input9, rcv_ack, snd_req
	);
	
	input		clk;
	input		xrst;
	
	input		rcv_ack;
	input		snd_req;
	input [5:0] input0;
	input [5:0] input1;
	input [5:0] input2;
	input [5:0] input3;
	input [5:0] input4;
	input [5:0] input5;
	input [5:0] input6;
	input [5:0] input7;
	input [5:0] input8;
	input [5:0] input9;
	
	output rcv_req;
	output snd_ack;
	output [3:0] outputs;

	reg [5:0] inputs_mem [9:0];
	reg [3:0] outputs_mem;
	
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
		if (xrst == 1'b0) begin
			inputs_mem[0] <= 0;
			inputs_mem[1] <= 0;
			inputs_mem[2] <= 0;
			inputs_mem[3] <= 0;
			inputs_mem[4] <= 0;
			inputs_mem[5] <= 0;
			inputs_mem[6] <= 0;
			inputs_mem[7] <= 0;
			inputs_mem[8] <= 0;
			inputs_mem[9] <= 0;
			end
		else if (st_reg == ST_RCV)
			inputs_mem[0] <= input0;
			inputs_mem[1] <= input1;
			inputs_mem[2] <= input2;
			inputs_mem[3] <= input3;
			inputs_mem[4] <= input4;
			inputs_mem[5] <= input5;
			inputs_mem[6] <= input6;
			inputs_mem[7] <= input7;
			inputs_mem[8] <= input8;
			inputs_mem[9] <= input9;
	end
	
	assign rcv_req = (st_reg == ST_WAIT) ? 1'b1: 1'b0;
	assign snd_ack = (st_reg == ST_SND) ? 1'b1: 1'b0;
		
	wire [3:0] result1;
	wire [3:0] result2;
	wire [3:0] result3;
	wire [3:0] result4;
	wire [3:0] result5;
	wire [3:0] result6;
	wire [3:0] result7;
	wire [3:0] result8;
	wire [3:0] result9;
	
	
	assign result1 = (inputs_mem[0] < inputs_mem[1]) ? 0 : 1;
	assign result2 = (inputs_mem[2] < inputs_mem[3]) ? 2 : 3;
	assign result3 = (inputs_mem[4] < inputs_mem[5]) ? 4 : 5;
	assign result4 = (inputs_mem[6] < inputs_mem[7]) ? 6 : 7;
	assign result5 = (inputs_mem[8] < inputs_mem[9]) ? 8 : 9;
	assign result6 = (inputs_mem[result1] < inputs_mem[result2]) ? result1 : result2;
	assign result7 = (inputs_mem[result3] < inputs_mem[result4]) ? result3 : result4;
	assign result8 = (inputs_mem[result5] < inputs_mem[result6]) ? result5 : result6;
	assign result9 = (inputs_mem[result7] < inputs_mem[result8]) ? result7 : result8;

	
	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			outputs_mem <= 0;
		else if(st_reg == ST_CALC)
			outputs_mem <= result9;
	end
	
	assign outputs = outputs_mem;
	
endmodule