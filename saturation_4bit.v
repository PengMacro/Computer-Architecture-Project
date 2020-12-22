module saturation_4bit (A, B, S, Output);
input [3:0] A, B, S;
output [3:0] Output;

wire PosOverflow, NegOverflow;

assign PosOverflow = (~A[3]) & (~B[3]) & S[3] ;
assign NegOverflow = (A[3]) & (B[3]) & (~S[3]) ;


assign Output = PosOverflow ? 4'h7 :
                NegOverflow ? 4'b1000 :
                S;


endmodule
