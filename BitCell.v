 module BitCell( input clk,  input rst, input D, input WriteEnable, input ReadEnable1, input ReadEnable2, inout Bitline1, inout Bitline2);
    wire Q; // Between FF and Tri-Bufs
    // First create a DFF
    dff DFF(.q(Q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

    // // Have bypass 
    // wire bypassInput;
    // assign bypassInput = (WriteEnable & ( ReadEnable1 | ReadEnable2 )) ? D : Q; 


    tri_buf triBuf1 (.in(Q), .out(Bitline1), .enable(ReadEnable1));
    tri_buf triBuf2 (.in(Q), .out(Bitline2), .enable(ReadEnable2));

endmodule
