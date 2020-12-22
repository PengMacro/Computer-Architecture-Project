module CSA_1bit (S1, S0, A, B, C);

output S1, S0;
input A, B, C;

assign S0 = A ^ B ^ C;
assign S1 = (A & B) | (A & C) | (B & C);

endmodule

