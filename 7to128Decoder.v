module decoder7to128 (index, onehot);
input [6:0] index;
output reg [127:0] onehot;

always @(index) begin
    case (index)
7'd0 : onehot = 128'b1;
7'd1 : onehot = 128'b10;
7'd2 : onehot = 128'b100;
7'd3 : onehot = 128'b1000;
7'd4 : onehot = 128'b10000;
7'd5 : onehot = 128'b100000;
7'd6 : onehot = 128'b1000000;
7'd7 : onehot = 128'b10000000;
7'd8 : onehot = 128'b100000000;
7'd9 : onehot = 128'b1000000000;
7'd10 : onehot = 128'b10000000000;
7'd11 : onehot = 128'b100000000000;
7'd12 : onehot = 128'b1000000000000;
7'd13 : onehot = 128'b10000000000000;
7'd14 : onehot = 128'b100000000000000;
7'd15 : onehot = 128'b1000000000000000;
7'd16 : onehot = 128'b10000000000000000;
7'd17 : onehot = 128'b100000000000000000;
7'd18 : onehot = 128'b1000000000000000000;
7'd19 : onehot = 128'b10000000000000000000;
7'd20 : onehot = 128'b100000000000000000000;
7'd21 : onehot = 128'b1000000000000000000000;
7'd22 : onehot = 128'b10000000000000000000000;
7'd23 : onehot = 128'b100000000000000000000000;
7'd24 : onehot = 128'b1000000000000000000000000;
7'd25 : onehot = 128'b10000000000000000000000000;
7'd26 : onehot = 128'b100000000000000000000000000;
7'd27 : onehot = 128'b1000000000000000000000000000;
7'd28 : onehot = 128'b10000000000000000000000000000;
7'd29 : onehot = 128'b100000000000000000000000000000;
7'd30 : onehot = 128'b1000000000000000000000000000000;
7'd31 : onehot = 128'b10000000000000000000000000000000;
7'd32 : onehot = 128'b100000000000000000000000000000000;
7'd33 : onehot = 128'b1000000000000000000000000000000000;
7'd34 : onehot = 128'b10000000000000000000000000000000000;
7'd35 : onehot = 128'b100000000000000000000000000000000000;
7'd36 : onehot = 128'b1000000000000000000000000000000000000;
7'd37 : onehot = 128'b10000000000000000000000000000000000000;
7'd38 : onehot = 128'b100000000000000000000000000000000000000;
7'd39 : onehot = 128'b1000000000000000000000000000000000000000;
7'd40 : onehot = 128'b10000000000000000000000000000000000000000;
7'd41 : onehot = 128'b100000000000000000000000000000000000000000;
7'd42 : onehot = 128'b1000000000000000000000000000000000000000000;
7'd43 : onehot = 128'b10000000000000000000000000000000000000000000;
7'd44 : onehot = 128'b100000000000000000000000000000000000000000000;
7'd45 : onehot = 128'b1000000000000000000000000000000000000000000000;
7'd46 : onehot = 128'b10000000000000000000000000000000000000000000000;
7'd47 : onehot = 128'b100000000000000000000000000000000000000000000000;
7'd48 : onehot = 128'b1000000000000000000000000000000000000000000000000;
7'd49 : onehot = 128'b10000000000000000000000000000000000000000000000000;
7'd50 : onehot = 128'b100000000000000000000000000000000000000000000000000;
7'd51 : onehot = 128'b1000000000000000000000000000000000000000000000000000;
7'd52 : onehot = 128'b10000000000000000000000000000000000000000000000000000;
7'd53 : onehot = 128'b100000000000000000000000000000000000000000000000000000;
7'd54 : onehot = 128'b1000000000000000000000000000000000000000000000000000000;
7'd55 : onehot = 128'b10000000000000000000000000000000000000000000000000000000;
7'd56 : onehot = 128'b100000000000000000000000000000000000000000000000000000000;
7'd57 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000;
7'd58 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000;
7'd59 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000;
7'd60 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000;
7'd61 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000;
7'd62 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000;
7'd63 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000;
7'd64 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000;
7'd65 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000;
7'd66 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000;
7'd67 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000;
7'd68 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000;
7'd69 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000;
7'd70 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000;
7'd71 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000;
7'd72 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000;
7'd73 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000;
7'd74 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000;
7'd75 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd76 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd77 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd78 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd79 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd80 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd81 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd82 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd83 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd84 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd85 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd86 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd87 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd88 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd89 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd90 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd91 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd92 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd93 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd94 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd95 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd96 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd97 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd98 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd99 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd100 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd101 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd102 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd103 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd104 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd105 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd106 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd107 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd108 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd109 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd110 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd111 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd112 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd113 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd114 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd115 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd116 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd117 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd118 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd119 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd120 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd121 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd122 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd123 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd124 : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd125 : onehot = 128'b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
7'd126 : onehot = 128'b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
default : onehot = 128'b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
endcase

end


endmodule