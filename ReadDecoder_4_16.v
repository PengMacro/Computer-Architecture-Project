module ReadDecoder_4_16(input [3:0] RegId, output [15:0] Wordline);

assign Wordline = 
    (RegId ==  4'h0 ) ? 16'h0001:
    (RegId ==  4'h1 ) ? 16'h0002:
    (RegId ==  4'h2 ) ? 16'h0004:
    (RegId ==  4'h3 ) ? 16'h0008:
    (RegId ==  4'h4 ) ? 16'h0010:
    (RegId ==  4'h5 ) ? 16'h0020:
    (RegId ==  4'h6 ) ? 16'h0040:
    (RegId ==  4'h7 ) ? 16'h0080:
    (RegId ==  4'h8 ) ? 16'h0100:
    (RegId ==  4'h9 ) ? 16'h0200:
    (RegId ==  4'hA ) ? 16'h0400:
    (RegId ==  4'hB ) ? 16'h0800:
    (RegId ==  4'hC ) ? 16'h1000:
    (RegId ==  4'hD ) ? 16'h2000:
    (RegId ==  4'hE ) ? 16'h4000:
    (RegId ==  4'hF ) ? 16'h8000: 
    16'h0;

endmodule
