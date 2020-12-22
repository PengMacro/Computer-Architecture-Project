module PC_control(input Branch, input [2:0] C , input [2:0] F,  output PCSrc);

// BRegisterValue: the register read from 7:4 in BR operation


    wire Z, V, N, GT, GTE;

    assign Z = F[0];
    assign V = F[1];
    assign N = F[2];

    assign GT =  !(Z | N);
    assign GTE = Z | GT;

    assign PCSrc = (~Branch)   ?  1'b0   :
                ( C == 3'b000) ?  !Z  :
                ( C == 3'b001) ?  Z   :
                ( C == 3'b010) ?  GT  :
                ( C == 3'b011) ?  N   :
                ( C == 3'b100) ?  GTE :
                ( C == 3'b101) ?  !GT :
                ( C == 3'b110) ?  V   :
                ( C == 3'b111) ?  1   :
                1'b0;


    //assign IExtend = { {6{I[8]}}, I[8:0], 1'b0 };

   // CLA_16bit PC2(.Saturated_Sum(PCPlus2), .Overflow(), .Sub(1'b0), .A(PC_in), .B(16'h2));
    
    
   // CLA_16bit PC2Final(.Saturated_Sum(PCPlus2PlusI), .Overflow(), .Sub(1'b0), .A(PCPlus2), .B(IExtend));

    
    // NEEDS TO BE REMOVED, reference only
    // assign PC_out = 
    //         (opcode == HLT) ? PC_in :
    //         ((opcode == B) & jump ) ? PCPlus2PlusI : 
    //         (opcode == BR & jump) ? BRegisterValue :
    //         PCPlus2; 

    

endmodule
