module BinarizedNeuralNetwork(
	// Outputs
	outputs, rcv_req, snd_ack, 
	// Inputs
	clk, xrst, inputs, rcv_ack, snd_req
);
	
	input inputs;
	input clk;
	input xrst;
	input rcv_ack;
	input snd_req;
	
	output [3:0] outputs;
	output rcv_req;
	output snd_ack;
	
	wire [783:0] image_reg_out;
	wire image_reg_snd_req;
	wire image_reg_snd_ack;
	
	wire [255:0] input_layer_out;
	wire input_layer_snd_req;
	wire input_layer_snd_ack;
	
	wire [127:0] mid1_layer_out;
	wire mid1_layer_snd_req;
	wire mid1_layer_snd_ack;
	
	wire [31:0] mid2_layer_out;
	wire mid2_layer_snd_req;
	wire mid2_layer_snd_ack;

	wire [5:0] mid3_layer_out0;
	wire [5:0] mid3_layer_out1;
	wire [5:0] mid3_layer_out2;
	wire [5:0] mid3_layer_out3;
	wire [5:0] mid3_layer_out4;
	wire [5:0] mid3_layer_out5;
	wire [5:0] mid3_layer_out6;
	wire [5:0] mid3_layer_out7;
	wire [5:0] mid3_layer_out8;
	wire [5:0] mid3_layer_out9;
	wire mid3_layer_snd_req;
	wire mid3_layer_snd_ack;
	
	image_reg Image_Reg(
		.outputs(image_reg_out), 
		.rcv_req(rcv_req), 
		.snd_ack(image_reg_snd_ack),
		.clk(clk),	
		.xrst(xrst), 
		.inputs(inputs), 
		.rcv_ack(rcv_ack), 
		.snd_req(image_reg_snd_req)
	);
	
	input_layer Input_Layer(
		.outputs(input_layer_out), 
		.rcv_req(image_reg_snd_req),
		.snd_ack(input_layer_snd_ack),
		.clk(clk), 
		.xrst(xrst), 
		.inputs(image_reg_out), 
		.rcv_ack(image_reg_snd_ack), 
		.snd_req(input_layer_snd_req)
	);
	

	mid1_layer Mid1_Layer(
		.outputs(mid1_layer_out), 
		.rcv_req(input_layer_snd_req),
		.snd_ack(mid1_layer_snd_ack),
		.clk(clk), 
		.xrst(xrst), 
		.inputs(input_layer_out), 
		.rcv_ack(input_layer_snd_ack), 
		.snd_req(mid1_layer_snd_req)
	);
	
	mid2_layer Mid2_Layer(
		.outputs(mid2_layer_out), 
		.rcv_req(mid1_layer_snd_req),
		.snd_ack(mid2_layer_snd_ack),
		.clk(clk), 
		.xrst(xrst), 
		.inputs(mid1_layer_out), 
		.rcv_ack(mid1_layer_snd_ack), 
		.snd_req(mid2_layer_snd_req)
	);

	mid3_layer Mid3_Layer(
		.output0(mid3_layer_out0),
		.output1(mid3_layer_out1),
		.output2(mid3_layer_out2),
		.output3(mid3_layer_out3),
		.output4(mid3_layer_out4),
		.output5(mid3_layer_out5),
		.output6(mid3_layer_out6),
		.output7(mid3_layer_out7),
		.output8(mid3_layer_out8),
		.output9(mid3_layer_out9),
		.rcv_req(mid2_layer_snd_req),
		.snd_ack(mid3_layer_snd_ack),
		.clk(clk), 
		.xrst(xrst), 
		.inputs(mid2_layer_out), 
		.rcv_ack(mid2_layer_snd_ack), 
		.snd_req(mid3_layer_snd_req)
	);
	
	output_layer Output_Layer(
		.outputs(outputs), 
		.rcv_req(mid3_layer_snd_req),
		.snd_ack(snd_ack),
		.clk(clk), 
		.xrst(xrst), 
		.input0(mid3_layer_out0),
		.input1(mid3_layer_out1),
		.input2(mid3_layer_out2),
		.input3(mid3_layer_out3),
		.input4(mid3_layer_out4),
		.input5(mid3_layer_out5),
		.input6(mid3_layer_out6),
		.input7(mid3_layer_out7),
		.input8(mid3_layer_out8),
		.input9(mid3_layer_out9),
		.rcv_ack(mid3_layer_snd_ack), 
		.snd_req(snd_req)
	);
endmodule