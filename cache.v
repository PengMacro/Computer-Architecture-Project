module Cache (input address, input readFromMem, input data_in, input memory_data_valid, input enable, input writeCache, input clk, input rst, input cacheNeedtoStall, output data_out, output dataToMem, output addrToMem, output fsm_busy, output miss_detected, output writeThrough, output cacheMemBusy, output cacheSendingMemAddress, output cacheReq, output cacheHit);  

input [15:0] address, data_in, readFromMem;
input clk, rst, memory_data_valid, cacheNeedtoStall;
input enable, writeCache; // denote read and write operation
output [15:0] data_out, dataToMem, addrToMem;


output  miss_detected; // assign in Cache module
output fsm_busy; // received from cache_fill_FSM module
output cacheMemBusy; // This is the signal when cache hasn't finished all the processing 
output cacheSendingMemAddress;

wire [15:0] memory_address, realDataIn;
wire [7:0] tag_array_word_enable;
wire write_data_array, write_tag_array; // both received from cache_fill_FSM module

wire [127:0] blockEnable, blockEnable_onehot;
wire [7:0] wordEnable, wordEnable_onehot, meta_data_out, meta_data_in;
wire [3:0] received_counter;

decoder7to128 decoder7 (.index(address[10:4]), .onehot(blockEnable_onehot));
decoder3to8 decoder3 (.index(address[3:1]), .onehot(wordEnable_onehot)); // bit 0 is for byte addressable purpose

assign blockEnable = enable ? blockEnable_onehot : 
                    128'b0;

assign wordEnable =  ~enable ? 8'b0 : // Not enable, then we shutdown cache
                    (fsm_busy) ? tag_array_word_enable :  // WHen storing data into data array, wordEnable will shift along with the counter
                    wordEnable_onehot;                                  // When not storing data, read the data from data array.

wire [15:0] oldPC;
Register PC (.clk(clk), .rst(rst), .D(address), .WriteReg(1'b1), .ReadEnable1(1'b1), .ReadEnable2(zero), .Bitline1(oldPC), .Bitline2() );
assign cacheReq = (oldPC != address) & enable;
assign cacheHit = cacheReq & ~miss_detected;


assign cacheMemBusy =  (fsm_busy | writeThrough | miss_detected) & (~cacheNeedtoStall); // Anything not finished, we consider it busy.

wire FSMSendingMemAddress;

assign cacheSendingMemAddress = FSMSendingMemAddress | writeThrough;  // Sending the real address when FSM sending or SW address to MEM. 


cache_fill_FSM cacheController(.clk(clk), .rst_n(~rst), .miss_detected(miss_detected), .miss_address(address), .cacheNeedtoStall(cacheNeedtoStall), .fsm_busy(fsm_busy), .write_data_array(write_data_array), .write_tag_array(write_tag_array), .memory_address(memory_address), .memory_data_valid(memory_data_valid), .received_counter(received_counter), .FSMSendingMemAddress(FSMSendingMemAddress));


assign tag_array_word_enable = (received_counter == 4'h0) ? 8'b1:
                        (received_counter == 4'h1) ? 8'b10:
                        (received_counter == 4'h2) ? 8'b100:
                        (received_counter == 4'h3) ? 8'b1000:
                        (received_counter == 4'h4) ? 8'b10000:
                        (received_counter == 4'h5) ? 8'b100000:
                        (received_counter == 4'h6) ? 8'b1000000:
                        (received_counter == 4'h7) ? 8'b10000000:
                        8'b0;

//wire [3:0] received_counter_sum;
//CLA_4bit received_counter_Adder(.P(), .G(), .Sum(received_counter_sum), .Cout(), .Cin(4'b0), .A(received_counter), .B(4'b1));


assign miss_detected = (~enable) ? 1'b0 : // If Not enable, skip the cache module 
                        (write_tag_array) ? 1'b0 : // // If writing tag array, no miss_detected assertion 
                        (meta_data_out[0] == 1'b0) ?  1'b1: // assert miss_detected if data is not valid
                            (meta_data_out[5:1] != address[15: 11]) ?  1'b1 : 1'b0; // assert miss_detected if tag bits do not match 

assign miss_address = address; // only matters when miss_detected is asserted

assign meta_data_in = {2'b0, memory_address[15:11], 1'b1}; // last address reference to memory


assign addrToMem = memory_address;

assign dataToMem = data_in;


wire writeThroughMemOnce, newWriteThroughMemOnce;

assign newWriteThroughMemOnce =  writeThrough; //| (  ~writeThroughMemOnce & (received_counter == 4'b0000 & ~miss_detected) ); // This is to make sure write though only is one for one single cycle when the data is fetched from memory.

dff updateMemOnce (.q(writeThroughMemOnce), .d(newWriteThroughMemOnce), .wen(1'b1), .clk(clk), .rst(rst));


assign writeThrough = writeCache & (received_counter[3]  | (received_counter == 4'b0000 & ~miss_detected & ~writeThroughMemOnce))  ; // write through: update data in memory each time cache is written

assign realDataIn = (memory_data_valid)? readFromMem : data_in ; // Only in LW, memory_data_valid could be 1, after reading the memory data, and put into data cache, take data from memmory when cache miss occurs
assign realWrite = (fsm_busy)? write_data_array : writeThrough ; // take write signal from FSM when cache miss occurs (first read memory then write)

DataArray DataArray(.clk(clk), .rst(rst), .DataIn(realDataIn), .Write(realWrite), .BlockEnable(blockEnable), .WordEnable(wordEnable), .DataOut(data_out));

MetaDataArray metaArray(.clk(clk), .rst(rst), .DataIn(meta_data_in), .Write(write_tag_array), .BlockEnable(blockEnable), .DataOut(meta_data_out));


endmodule

