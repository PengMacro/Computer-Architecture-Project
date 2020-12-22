
module ALU (ALU_Out, flags_from_alu, ALU_In1, ALU_In2, ALUOp);
output [15:0] ALU_Out;
output [2:0] flags_from_alu;
input [15:0] ALU_In1, ALU_In2;
input [2:0] ALUOp;



// Shifter:
wire [1:0] shifter_mode;
wire [15:0] Shift_Out;

assign shifter_mode = ALUOp[1:0];
                    //(ALUOp == 3'b100) ? 2'b00 :
                    //(ALUOp == 3'b101) ? 2'b01 :
                    //(ALUOp == 3'b110) ? 2'b10 :

Shifter shifter (.Shift_Out(Shift_Out), .Shift_In(ALU_In1), .Shift_Val(ALU_In2[3:0]), .Mode(shifter_mode));


// XOR:
wire[15:0] xor_Out;
assign xor_Out = ALU_In1 ^ ALU_In2;

// CLA: 
wire [15:0] CLA_Out;  
wire CLA_Overflow, Sub;

assign Sub = ALUOp[0];
CLA_16bit CLA (.Saturated_Sum(CLA_Out), .Overflow(CLA_Overflow), .Sub(Sub), .A(ALU_In1), .B(ALU_In2));


// PAD & RED
wire zero;
wire P0, P1, P2, P3, G0, G1, G2, G3, Cm, Cn, Cp, Cq;
wire [15:0] PAD_Sum, PAD_Sum_Saturated;
assign zero = 1'b0;


CLA_4bit cla0 (.P(P0), .G(Cq),  .Sum(PAD_Sum[3:0]), .Cin(zero), .A(ALU_In1[3:0]), .B(ALU_In2[3:0]));
CLA_4bit cla1 (.P(P1), .G(Cp),  .Sum(PAD_Sum[7:4]), .Cin(zero), .A(ALU_In1[7:4]), .B(ALU_In2[7:4]));
CLA_4bit cla2 (.P(P2), .G(Cn),  .Sum(PAD_Sum[11:8]), .Cin(zero), .A(ALU_In1[11:8]), .B(ALU_In2[11:8]));
CLA_4bit cla3 (.P(P3), .G(Cm), .Sum(PAD_Sum[15:12]), .Cin(zero), .A(ALU_In1[15:12]), .B(ALU_In2[15:12]));

saturation_4bit sat0 (.A(ALU_In1[3:0]), .B(ALU_In2[3:0]), .S(PAD_Sum[3:0]), .Output(PAD_Sum_Saturated[3:0]));
saturation_4bit sat1 (.A(ALU_In1[7:4]), .B(ALU_In2[7:4]), .S(PAD_Sum[7:4]), .Output(PAD_Sum_Saturated[7:4]));
saturation_4bit sat2 (.A(ALU_In1[11:8]), .B(ALU_In2[11:8]), .S(PAD_Sum[11:8]), .Output(PAD_Sum_Saturated[11:8]));
saturation_4bit sat3 (.A(ALU_In1[15:12]), .B(ALU_In2[15:12]), .S(PAD_Sum[15:12]), .Output(PAD_Sum_Saturated[15:12]));

// Now RED:
wire P4, P5, P6, G4, G5, G6, Cx, Cy, Cz;
wire [15:0] RED;
wire[3:0] Sx, Sy, Sz;
assign Cx = G4 ;
assign Cy = G5 ;
assign Cz = G6 ;

CLA_4bit cla4 (.P(P4), .G(G4),  .Sum(Sx), .Cin(zero), .A(PAD_Sum[15:12]), .B(PAD_Sum[11:8]));
CLA_4bit cla5 (.P(P5), .G(G5),  .Sum(Sy), .Cin(zero), .A(PAD_Sum[7:4]), .B(PAD_Sum[3:0]));
CLA_4bit cla6 (.P(P6), .G(G6),  .Sum(Sz), .Cin(zero), .A(Sx), .B(Sy));


wire s1t, s0t, s1u, s0u, s1v, s0v, s1w, s0w;
CSA_1bit t (.S1(s1t), .S0(s0t), .A(~Cm), .B(~Cn), .C(~Cp));
CSA_1bit u (.S1(s1u), .S0(s0u), .A(~Cq), .B(Cx), .C(Cy));
CSA_1bit v (.S1(s1v), .S0(s0v), .A(s0t), .B(Cz), .C(s0u));
CSA_1bit w (.S1(s1w), .S0(s0w), .A(s1t), .B(s1u), .C(s1v));

wire [3:0] REDSign;
CLA_4bit finalAdd (.Sum(REDSign), .Cin(zero), .A({s1w, s1w, s0w, s0v}), .B(4'b0100));


assign RED = { {9{REDSign[3]}},REDSign[2:0], Sz};



assign ALU_Out = (ALUOp == 3'b011) ? xor_Out :
                 (ALUOp == 3'b100) ? Shift_Out :
                 (ALUOp == 3'b101) ? Shift_Out :
                 (ALUOp == 3'b110) ? Shift_Out :
                 (ALUOp == 3'b010) ? RED :
                 (ALUOp == 3'b111) ? PAD_Sum_Saturated:
                 CLA_Out;
        
// Flags
wire N, Z, V;

assign N = ALU_Out[15];
assign Z = (ALU_Out == 0); 
assign V = CLA_Overflow;

assign flags_from_alu = {N, V, Z};



endmodule