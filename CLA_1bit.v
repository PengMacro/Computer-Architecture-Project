module CLA_1bit ( P, G, Sum, Cin, A, B);

output P, G, Sum;
input Cin, A, B;

assign G = A & B;
assign P = A ^ B;

assign Sum = A ^ B ^ Cin;


endmodule

