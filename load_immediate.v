
module load_immediate (RegisterReadValue, RegisterWriteValue, Immediate, opcode);

input [3:0] opcode;
input [7:0] Immediate;
input [15:0] RegisterReadValue;
output [15:0] RegisterWriteValue;
wire [15:0] LHB, LLB;

assign LLB = RegisterReadValue & (16'hFF00) | Immediate;
assign LHB = RegisterReadValue & (16'h00FF) | (Immediate << 8);



assign RegisterWriteValue = opcode[0] ? LLB : LHB;  // 1: LLB, 0 : LHB  



endmodule
