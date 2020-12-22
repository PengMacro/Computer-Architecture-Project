
module decoder3to8 (index, onehot);
input [2:0] index;
output reg [7:0] onehot;

always @(index) begin
    case (index)
        3'd0 : onehot = 8'b1;
        3'd1 : onehot = 8'b10;
        3'd2 : onehot = 8'b100;
        3'd3 : onehot = 8'b1000;
        3'd4 : onehot = 8'b10000;
        3'd5 : onehot = 8'b100000;
        3'd6 : onehot = 8'b1000000;
        default : onehot = 8'b10000000;
    endcase

end


endmodule