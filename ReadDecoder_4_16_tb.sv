
module ReadDecoder_4_16_tb ();
reg [3:0] in;
wire [15:0] out;
ReadDecoder_4_16 iDut(.RegId(in), .Wordline(out));

initial begin
    repeat (100) begin

        in = $random;
        #10;
        if ((1 << in) != out) begin
            $display("Input is: %h Output is: %b", in, out);
            $stop;
        end
    end
end






endmodule