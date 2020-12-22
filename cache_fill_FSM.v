module cache_fill_FSM(input clk, input rst_n, input miss_detected, input miss_address, input cacheNeedtoStall, output fsm_busy, output write_data_array, output write_tag_array, output memory_address, input memory_data_valid, output received_counter, output FSMSendingMemAddress);
input clk, rst_n;
input miss_detected; // active high when tag match logic detects a miss
input [15:0] miss_address; // address that missed the cache
output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
output write_data_array; // write enable to cache data array to signal when filling with memory_data
output write_tag_array; // write enable to cache tag array to write tag and valid bit once all words are filled in to data array

output [15:0] memory_address; // address to read from memory
//input [15:0] memory_data; // data returned by memory (after  delay)
input memory_data_valid; // active high indicates valid data returning on memory bus
output [3:0] received_counter;  // the number to be received
output FSMSendingMemAddress;  // Total of 8 cycles of 1, only active when the data currently send is supposed to go to memory


localparam IDLE = 1'b0;
localparam WAIT = 1'b1;

wire rst, curr_state, next_state;
wire[3:0] dataCount, newDataCount, memPipeCount, newMemPipeCount, dataSum, memPipeSum, memSendingAddressCounter;  // memsendingaddresscounter can be removed
assign rst = ~rst_n;

assign newDataCount = (dataCount == 4'b1000 | ~memory_data_valid | cacheNeedtoStall) ? 4'b0 : dataSum; // clear the counter when eight bytes are collected
assign newMemPipeCount = (~fsm_busy | cacheNeedtoStall)? 4'b0 : memPipeSum; // clear the counter when eight addresses are sent

// State register
dff state (.q(curr_state), .d(next_state), .wen(1'b1), .clk(clk), .rst(rst));

// data burst counter (number of 2 bytes received)
dff counter_0(.q(dataCount[0]), .d(newDataCount[0]), .wen(1'b1), .clk(clk), .rst(rst));
dff counter_1(.q(dataCount[1]), .d(newDataCount[1]), .wen(1'b1), .clk(clk), .rst(rst));
dff counter_2(.q(dataCount[2]), .d(newDataCount[2]), .wen(1'b1), .clk(clk), .rst(rst));
dff counter_3(.q(dataCount[3]), .d(newDataCount[3]), .wen(1'b1), .clk(clk), .rst(rst));

assign received_counter = dataCount;


// memory pipeline counter (number of addresses sent to Mem)
dff pipeCount_0(.q(memPipeCount[0]), .d(newMemPipeCount[0]), .wen(1'b1), .clk(clk), .rst(rst));
dff pipeCount_1(.q(memPipeCount[1]), .d(newMemPipeCount[1]), .wen(1'b1), .clk(clk), .rst(rst));
dff pipeCount_2(.q(memPipeCount[2]), .d(newMemPipeCount[2]), .wen(1'b1), .clk(clk), .rst(rst));
dff pipeCount_3(.q(memPipeCount[3]), .d(newMemPipeCount[3]), .wen(1'b1), .clk(clk), .rst(rst));

CLA_4bit dataAdder(.P(), .G(), .Sum(dataSum), .Cout(), .Cin(4'b0), .A(dataCount), .B(4'b1));
CLA_4bit memPipeAdder(.P(), .G(), .Sum(memPipeSum), .Cout(), .Cin(4'b0), .A(memPipeCount), .B(4'b1));

// memory pipeline counter (number of addresses sent to Mem)
// Counter adder = pipecount + 1

//CLA_4bit counterAdder(.P(), .G(), .Sum(memSendingAddressCounter), .Cout(), .Cin(4'b0), .A(memPipeCount), .B(4'b1));

assign FSMSendingMemAddress = (memPipeCount[3] != 1'b1); // = 1 when pipecount <= 7

assign next_state = ( curr_state == IDLE) ? 
                        miss_detected ? WAIT : IDLE :
                    // not IDLE must be WAIT
                    memory_data_valid ? 
						(dataCount != 4'b0111) ? WAIT : IDLE :
						WAIT;

assign fsm_busy = (curr_state == IDLE && next_state == IDLE) ? 1'b0 : 1'b1;

// read memory at eight consecutive locations when a miss occurs
// note that each of the eight memory addresses is sent consecutively in eight clock cycles to realize pipeline memory reading
assign memory_address = (memPipeCount == 4'h0) ? {miss_address[15:4],4'b0000}:
                        (memPipeCount == 4'h1) ? {miss_address[15:4],4'b0010}:
                        (memPipeCount == 4'h2) ? {miss_address[15:4],4'b0100}:
                        (memPipeCount == 4'h3) ? {miss_address[15:4],4'b0110}:
                        (memPipeCount == 4'h4) ? {miss_address[15:4],4'b1000}:
                        (memPipeCount == 4'h5) ? {miss_address[15:4],4'b1010}:
                        (memPipeCount == 4'h6) ? {miss_address[15:4],4'b1100}:
                        (memPipeCount == 4'h7) ? {miss_address[15:4],4'b1110}:
                        miss_address;  // used to be 0, changed to miss address for write through after all 8 bytes are received
// assign memory_address =  (curr_state == IDLE && next_state == WAIT) ? miss_address : 16'b0;

assign write_data_array = (memory_data_valid && curr_state == WAIT ) ? 1'b1: 1'b0;

assign write_tag_array = (dataCount == 4'b0111 ) ? 1'b1: 1'b0;




endmodule