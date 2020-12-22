
module ArbitrationToMemory(input ICacheMiss, input DCacheMiss, input  ICacheDataToMem, input ICacheAddrToMem, input  DCacheDataToMem, input DCacheAddrToMem, output addrToMem, output dataToMem, output ICacheNeedtoStall, output DCacheNeedtoStall, input ICacheMemBusy, input DCacheMemBusy, input ICacheSendingMemAddress, input DCacheSendingMemAddress, output memoryEnable);

input ICacheMiss, DCacheMiss;
input [15:0] ICacheAddrToMem, DCacheAddrToMem, ICacheDataToMem, DCacheDataToMem;
output [15:0] addrToMem, dataToMem;
output ICacheNeedtoStall, DCacheNeedtoStall;


assign addrToMem =  (ICacheMemBusy & DCacheMemBusy) ? DCacheAddrToMem :
                    DCacheMemBusy ? DCacheAddrToMem : 
                    ICacheMemBusy ? ICacheAddrToMem :
                    16'b0;

        

assign dataToMem = (ICacheMemBusy & DCacheMemBusy) ? DCacheDataToMem :
                    DCacheMemBusy ? DCacheDataToMem : 
                    ICacheMemBusy ? ICacheDataToMem :
                    16'b0;


assign ICacheNeedtoStall = (ICacheMemBusy & DCacheMemBusy) ? 1'b1 :
                    DCacheMemBusy ? 1'b1 : 
                    1'b0;

assign DCacheNeedtoStall = (ICacheMemBusy & DCacheMemBusy) ? 1'b0 :
                    ICacheMemBusy ? 1'b1 : 
                    1'b0;

assign memoryEnable = (ICacheMemBusy & DCacheMemBusy) ? DCacheSendingMemAddress :
                       DCacheMemBusy ? DCacheSendingMemAddress : 
                        ICacheMemBusy ? ICacheSendingMemAddress :
                        1'b0;
endmodule