`timescale 1ps / 1ps

module test_top();

   parameter CLK = 1000000/10; // 10MHz

   parameter PIXEL_NUM = 28 * 28;

   reg imem [0:PIXEL_NUM-1];
   reg [3:0] omem ;

   // receive port (SLAVE)
   reg 			inputs;
   wire      rcv_req;
   reg 	     rcv_ack;

   // send port (MASTER)
   wire [3:0]	outputs;
   reg 	      snd_req;
   wire       snd_ack;

   // clock, reset
   reg 	      clk;
   reg 	      xrst;

   integer start_time;
   integer i;
	integer j;
   integer fin;
	integer fout;
   reg val;
   integer c;
   reg [127:0] str;

   // clock generation
   always begin
      clk = 1'b1;
      #(CLK/2);
      clk = 1'b0;
      #(CLK/2);
   end
	

   // test senario
   initial begin
   fout = $fopen("result.txt", "a");
	for (j = 0; j < 10000; j = j + 1) begin
	
	 fin = $fopen($sformatf("%0d.pbm", j), "r");
	 // skip header lines
	 c = $fgets(str, fin);
	 c = $fgets(str, fin);
	 // c = $fgets(str, fd);
	 // read pixels
	 for (i = 0; i < PIXEL_NUM; i = i + 1) begin
			if ((i % 28 == 0) && (i != 0))
			c = $fgetc(fin);
			c = $fgetc(fin);
			$swriteb(val, c);
			imem[i] = val;
         end
	 $fclose(fin);
		
      // reset
      #(CLK/2);
      xrst = 1'b0;
      // read_image;
      #(CLK);
      xrst = 1'b1;
      rcv_ack = 1'b0;
      snd_req = 1'b0;

      start_time = $time;

      // data input
      while (rcv_req == 1'b0) #(CLK);
      #(CLK);
      for (i = 0; i < PIXEL_NUM; i = i + 1) begin
			rcv_ack = 1'b1;
			inputs = imem[i];
		#(CLK);
      end
      rcv_ack = 1'b0;
      
      // data output
      snd_req = 1'b1;
      while (snd_ack == 1'b0) #(CLK);
      omem = outputs;
		#(CLK)
		snd_req = 1'b0;

      $display("Simulation time: %d ns", ($time-start_time)/1000);
      #(CLK*10);
      $fdisplay(fout, "%d", omem);
		
		end
		$fclose(fout);
      $finish;
   end

   // module
   BinarizedNeuralNetwork top(
		.outputs(outputs), 
		.rcv_req(rcv_req), 
		.snd_ack(snd_ack), 
		.clk(clk), 
		.xrst(xrst), 
		.inputs(inputs), 
		.rcv_ack(rcv_ack), 
		.snd_req(snd_req)
	);

   task read_image;
      reg val;
      integer fd;
      integer i;
      integer c;
      reg [127:0] str;
      begin
	 fd = $fopen("00100.pbm", "r");
	 // skip header lines
	 c = $fgets(str, fd);
	 c = $fgets(str, fd);
	 // c = $fgets(str, fd);
	 // read pixels
	 for (i = 0; i < PIXEL_NUM; i = i + 1) begin
			if ((i % 28 == 0) && (i != 0))
			c = $fgetc(fd);
			c = $fgetc(fd);
			$swriteb(val, c);
			imem[i] = val;
         end
	 $fclose(fd);
      end
   endtask

   task save_image;
      integer fd;
      integer i;
      reg [127:0] str;
      begin
	 fd = $fopen("result.txt", "a");
	 // write headers
	 //$fdisplay(fd, "P2");
	 //$fdisplay(fd, "28 28");
	 // write pixels
	 //for (i = 0; i < PIXEL_NUM; i = i + 1) begin
	    $fdisplay(fd, "%d", omem);
      //   end
	 $fclose(fd);
      end
   endtask

endmodule
