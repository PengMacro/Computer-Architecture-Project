
module sign_extend_4to16( input_value, output_value);
input [3:0]input_value;
output [15:0] output_value;

assign output_value = { {12{input_value[3]}},input_value};

endmodule
