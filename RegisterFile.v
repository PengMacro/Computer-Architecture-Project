module RegisterFile(input clk, input rst, input [3:0] SrcReg1, input [3:0] SrcReg2, input [3:0] DstReg, input WriteReg, input [15:0] DstData, inout [15:0] SrcData1, inout [15:0] SrcData2);

wire [15:0] readLine1, readLine2, writeLine;

wire [15:0] SrcData1Temp, SrcData2Temp;

ReadDecoder_4_16 rd1 (.RegId(SrcReg1), .Wordline(readLine1));
ReadDecoder_4_16 rd2 (.RegId(SrcReg2), .Wordline(readLine2));
WriteDecoder_4_16 wd (.RegId(DstReg), .WriteReg(WriteReg), .Wordline(writeLine));



assign SrcData1 = (WriteReg & ( SrcReg1 == DstReg )) ? DstData : SrcData1Temp; 
assign SrcData2 = (WriteReg & ( SrcReg2 == DstReg )) ? DstData : SrcData2Temp; 



Register r0 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[0]), .ReadEnable1(readLine1[0]), .ReadEnable2(readLine2[0]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r1 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[1]), .ReadEnable1(readLine1[1]), .ReadEnable2(readLine2[1]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r2 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[2]), .ReadEnable1(readLine1[2]), .ReadEnable2(readLine2[2]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r3 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[3]), .ReadEnable1(readLine1[3]), .ReadEnable2(readLine2[3]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r4 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[4]), .ReadEnable1(readLine1[4]), .ReadEnable2(readLine2[4]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r5 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[5]), .ReadEnable1(readLine1[5]), .ReadEnable2(readLine2[5]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r6 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[6]), .ReadEnable1(readLine1[6]), .ReadEnable2(readLine2[6]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r7 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[7]), .ReadEnable1(readLine1[7]), .ReadEnable2(readLine2[7]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r8 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[8]), .ReadEnable1(readLine1[8]), .ReadEnable2(readLine2[8]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r9 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[9]), .ReadEnable1(readLine1[9]), .ReadEnable2(readLine2[9]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r10 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[10]), .ReadEnable1(readLine1[10]), .ReadEnable2(readLine2[10]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r11 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[11]), .ReadEnable1(readLine1[11]), .ReadEnable2(readLine2[11]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r12 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[12]), .ReadEnable1(readLine1[12]), .ReadEnable2(readLine2[12]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r13 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[13]), .ReadEnable1(readLine1[13]), .ReadEnable2(readLine2[13]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r14 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[14]), .ReadEnable1(readLine1[14]), .ReadEnable2(readLine2[14]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));
Register r15 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeLine[15]), .ReadEnable1(readLine1[15]), .ReadEnable2(readLine2[15]), .Bitline1(SrcData1Temp), .Bitline2(SrcData2Temp));


endmodule