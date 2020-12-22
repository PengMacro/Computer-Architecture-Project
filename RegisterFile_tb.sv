
module RegisterFile_tb();
	reg clk, rst, WriteReg;
	reg [3:0] SrcReg1, SrcReg2, DstReg;
	reg[15:0] DstData;
	wire[15:0] SrcData1, SrcData2;
	
	
	wire[15:0] rd1, rd2;
		reg [15:0] regfile [15:0];
	RegisterFile iDUT(.clk(clk), .rst(rst), .SrcReg1(SrcReg1), .SrcReg2(SrcReg2), .DstReg(DstReg), .WriteReg(WriteReg), .DstData(DstData), .SrcData1(SrcData1), .SrcData2(SrcData2));
	
	// Reference register file
	assign rd1 = regfile[SrcReg1];
	assign rd2 = regfile[SrcReg2];
	 
	integer i;
	always @(posedge clk) begin
      if (rst) begin
			for (i = 0; i < 16; i = i + 1) begin
				regfile[i] <= 0;
			end
      end 
	 
	 else begin
		if (WriteReg) regfile[DstReg] <= DstData;
      end 
	end
	
	
	
	initial begin
		rst = 1'b1;
		clk = 1'b1;
		@ (posedge clk) DstData = 16'b0;
		SrcReg1 = 0;
		SrcReg2 = 0;
		DstReg = 0;
		WriteReg = 0;
		// Wait for a cycle
		#1 rst = 1'b0;
		@ (posedge clk);
		
		repeat(1000) begin
			@(negedge clk)
			DstData = $random;
			WriteReg = $random;
			SrcReg1 = $random;
			SrcReg2 = $random;
			DstReg = $random;
			
			@(negedge clk);
			if (rd1 != SrcData1) begin
				$display("Wrong rd1");
				$stop;
			end
			
			if (rd2 != SrcData2) begin
				$display("Wrong rd2");
				$stop;
			end
				
		end
		$display("Test Ended");
		$stop;
		
	end
	
	
	always begin
    #5; 
    clk = ~clk;
end
endmodule