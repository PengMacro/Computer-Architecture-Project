module Register_tb();
reg clk, rst, WriteReg, ReadEnable1, ReadEnable2;
reg[15:0] D;
wire[15:0] Bitline1, Bitline2;
	Register iDUT(clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1, Bitline2);
initial begin
	rst = 1'b1;
	clk = 1'b1;
	@ (posedge clk) D = 1'b0;
	ReadEnable1 = 0;
	ReadEnable2 = 0;
	WriteReg = 0;
	#1 rst = 1'b0;
	
	/* Test Input */
	// wait for 1 cycle
	@(negedge clk);
	D = 16'hFFFF;
	WriteReg = 1;
	
	@(negedge clk) WriteReg = 0;
	
	/* Test Output */
	@(negedge clk) begin
		ReadEnable1 = 1;
		if (Bitline1 != 16'hFFFF)
			$display("The input was all 1s but the output was not");
	end
	
	@(negedge clk) begin
		ReadEnable2 = 1;
		if (Bitline2 != 16'hFFFF)
			$display("The input was all 1s but the output was not");
	end
	
	@(negedge clk) begin 
		ReadEnable1 = 0;
	end
	
	#2;
	if (Bitline1 != 1'bz) 
			$display("The expected output is all zs but the output was %h", Bitline1);
	
	@(negedge clk) begin
		ReadEnable2 = 0;
	end
	
	#2;
	if (Bitline2 != 1'bz)
			$display("The expected output is all zs but the output was %h", Bitline2);
	
	/* Test input */
	// Wait for one cycle
	@(negedge clk);
	D = 1'b0;
	WriteReg = 1;
	
	@(negedge clk) WriteReg = 0;
	
	/* Test output */
	@(negedge clk) begin 
		ReadEnable1 = 1;
		if (Bitline1 != 0) 
			$display("The input was 0 but the output was not");
	end
	
	@(negedge clk) begin
		ReadEnable2 = 1;
		if (Bitline2 != 0)
			$display("The input was 0 but the output was not");
	end
	
	@(negedge clk) begin 
		ReadEnable1 = 0;
		if (Bitline1 != 1'bz) 
			$display("The expected output is z but the output was not");
	end
	
	@(negedge clk) begin
		ReadEnable2 = 0;
		if (Bitline2 != 1'bz)
			$display("The expected output is z but the output was not");
	end
	
	
	
	#10
	$display("Test Ended");
	$stop;
	
end	

always begin
    #5; 
    clk = ~clk;
end

endmodule
