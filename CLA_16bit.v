
module CLA_16bit (Saturated_Sum, Overflow, Sub, A, B);

input Sub;
input [15:0] A, B;
output Overflow;
output [15:0] Saturated_Sum;

wire[15:0] Sum, new_B;

wire P0, P1, P2, P3, G0, G1, G2, G3, C0, C1, C2, C3;
assign C0 = Sub;

assign C1 = G0 | ( P0 & C0);
assign C2 = G1 | (P1 & G0) | (P1 & P0 & C0);
assign C3 = G2 | (P2 & G1) | (P2 & P1 & G0) | (P2 & P1 & P0 & C0);
assign C4 = G3 | (P3 * G2) | (P3 & P2 & G1) | (P3 & P2 & P1 & G0) | (P3 & P2 & P1 & P0 & C0);
assign Cout = C4;

assign new_B = Sub ? ~B : B;

CLA_4bit cla0 (.P(P0), .G(G0), .Sum(Sum[3:0]), .Cin(C0), .A(A[3:0]), .B(new_B[3:0]));
CLA_4bit cla1 (.P(P1), .G(G1), .Sum(Sum[7:4]), .Cin(C1), .A(A[7:4]), .B(new_B[7:4]));
CLA_4bit cla2 (.P(P2), .G(G2), .Sum(Sum[11:8]), .Cin(C2), .A(A[11:8]), .B(new_B[11:8]));
CLA_4bit cla3 (.P(P3), .G(G3), .Sum(Sum[15:12]), .Cin(C3), .A(A[15:12]), .B(new_B[15:12]));

assign PosOverflow = ((~A[15]) & (~B[15]) & Sum[15] & (~Sub) )  | ((~A[15]) & (B[15]) & Sum[15] & Sub);
assign NegOverflow = (A[15] & B[15] & (~Sum[15]) & (~Sub) ) | (A[15] & ~B[15] & (~Sum[15]) & Sub );


assign Saturated_Sum = PosOverflow ? 16'h7fff :
                NegOverflow ? 16'h1000 :
                Sum;

assign Overflow = PosOverflow | NegOverflow;

endmodule