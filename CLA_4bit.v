module CLA_4bit (P, G, Sum, Cout, Cin, A, B);

input Cin;
input [3:0] A, B;
output P, G, Cout;
output [3:0] Sum;

wire P0, P1, P2, P3, G0, G1, G2, G3, C0, C1, C2, C3;
assign C0 = Cin;

assign C1 = G0 | ( P0 & C0);
assign C2 = G1 | (P1 & G0) | (P1 & P0 & C0);
assign C3 = G2 | (P2 & G1) | (P2 & P1 & G0) | (P2 & P1 & P0 & C0);
assign C4 = G3 | (P3 * G2) | (P3 & P2 & G1) | (P3 & P2 & P1 & G0) | (P3 & P2 & P1 & P0 & C0);
assign Cout = C4;

CLA_1bit cla0 (.P(P0), .G(G0), .Sum(Sum[0]), .Cin(C0), .A(A[0]), .B(B[0]));
CLA_1bit cla1 (.P(P1), .G(G1), .Sum(Sum[1]), .Cin(C1), .A(A[1]), .B(B[1]));
CLA_1bit cla2 (.P(P2), .G(G2), .Sum(Sum[2]), .Cin(C2), .A(A[2]), .B(B[2]));
CLA_1bit cla3 (.P(P3), .G(G3), .Sum(Sum[3]), .Cin(C3), .A(A[3]), .B(B[3]));

assign G = C4;
assign P = P0 & P1 & P2 & P3;


endmodule