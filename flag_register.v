module flag_register(clk, rst, flags_from_alu, flags_set, flags);

input clk, rst;
input [1:0] flags_set;
input [2:0] flags_from_alu;
output [2:0] flags;

wire [2:0] new_flags;
wire [15:0] pc_unused, old_flags, new_flags_16bit;

assign one = 1'b1;
assign zero = 1'b0;

assign new_flags = (flags_set == 2'b11) ? flags_from_alu :
                    (flags_set == 2'b01) ? {old_flags[2:1], flags_from_alu[0]}:
                    old_flags[2:0];

assign new_flags_16bit = {13'h0, new_flags};


// The register file storing the alu value
Register flag_regsiter (.clk(clk), .rst(rst), .D(new_flags_16bit), .WriteReg(flags_set[0]), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(old_flags), .Bitline2(pc_unused) );

assign flags = old_flags;

endmodule
