module cpu (clk, rst_n, hlt, pc);

input clk, rst_n;
output hlt;
output wire [15:0] pc;

wire rst, one;
wire [15:0] zero_16bit;

wire flush;
//wire flushOrRst;
wire [15:0] not_flush_16bit;

assign rst = ~ rst_n;
assign one = 1'b1;
assign zero = 1'b0;
assign zero_16bit = 16'h0;

localparam ADD=4'b0000;
localparam SUB=4'b0001;
localparam RED=4'b0010;
localparam XOR=4'b0011;
localparam SLL=4'b0100;
localparam SRA=4'b0101;
localparam ROR=4'b0110;
localparam PADDSB=4'b0111;
localparam LW=4'b1000;
localparam SW=4'b1001;
localparam LHB=4'b1010;
localparam LLB=4'b1011;
localparam B=4'b1100;
localparam BR=4'b1101;
localparam PCS=4'b1110;
localparam HLT=4'b1111;


// IF Stage Wires
wire [15:0] IF_new_pc, IF_instruction, IF_PCPlus2;
wire [3:0] IF_RegisterRs, IF_RegisterRt, IF_RegisterRd; //IF_writeReg;
wire IF_RsExists, IF_RtExists, IF_RdExists;

// ID Stage Wires
wire [15:0] ID_new_pc, ID_instruction, ID_PCPlus2, ID_4bit_sign_extended, ID_9bit_sign_extended_shifted, ID_readData1, ID_readData2, ID_4bit_sign_extended_might_left_shift_1bit; // wire used in EX, if SW or LW then shift, if Shift or Rotate then don't shift
wire [3:0] ID_RegisterRs, ID_RegisterRt, ID_RegisterRd, ID_writeReg, id_readReg1, id_readReg2 ;
wire [2:0] ID_ALUOp;
wire [1:0] ID_writeDataSource, ID_flags_set;
wire ID_MemWrite, ID_MemRead, ID_ALUSrc, ID_RegWrite, ID_Branch;
wire ID_RsExists, ID_RtExists, ID_RdExists;

// EX Stage Wires
wire [15:0] EX_new_pc, EX_instruction, EX_PCPlus2, EX_9bit_sign_extended_shifted, EX_readData1, EX_readData2, EX_4bit_sign_extended_might_left_shift_1bit, EX_BranchAddress, EX_ALU_Out, EX_load_immediate_Out, ex_ALU_In1, ex_ALU_In2, ex_PCPlus2PlusI;
wire [7:0] ex_load_immediate_immediate;
wire [3:0] EX_RegisterRs, EX_RegisterRt, EX_RegisterRd, EX_writeReg, ex_opcode;
wire [2:0] EX_ALUOp, EX_flags, ex_flags_from_alu ; // EX_flags: N(2), V, Z(0)
wire [1:0] EX_writeDataSource, EX_flags_set, ex_Forward2, ex_Forward1;  // 2 bit determine whether to enable and write flag register
wire EX_MemWrite, EX_MemRead, EX_ALUSrc, EX_RegWrite, EX_Branch;// In EX stage, destination is WB, isB: 1 is B, 0 is BR
wire EX_RsExists, EX_RtExists, EX_RdExists, ex_isB;
wire ex_EXhazard1, ex_MEMhazard1, ex_EXhazard2, ex_MEMhazard2;

// MEM Stage Wires
wire [15:0] MEM_new_pc, MEM_instruction, MEM_readData2, MEM_BranchAddress, MEM_ALU_Out, MEM_load_immediate_Out, MEM_Mem_Out;
wire [3:0] MEM_RegisterRs, MEM_RegisterRt, MEM_RegisterRd, MEM_writeReg;
wire [2:0] MEM_flags;
wire [1:0] MEM_writeDataSource;  // 2 bit determine whether to enable and write flag register
wire MEM_MemWrite, MEM_MemRead, MEM_RegWrite, MEM_Branch;
wire MEM_RsExists, MEM_RtExists, MEM_RdExists;
wire MEM_PCSrc;

// WB Stage Wires
wire [15:0] WB_new_pc, WB_instruction, WB_ALU_Out, WB_load_immediate_Out, WB_Mem_Out, WB_writeData;
wire [3:0] WB_RegisterRs, WB_RegisterRt, WB_RegisterRd, WB_writeReg;
wire [1:0] WB_writeDataSource;  // 2 bit determine whether to enable and write flag register
wire WB_RegWrite;
wire WB_RsExists, WB_RtExists, WB_RdExists;


// Start of Instruction Fetch (IF)
assign IF_new_pc =  (MEM_PCSrc) ? MEM_BranchAddress :
                    (IF_instruction[15:12] == HLT) ? pc :          // IF HLT then pc doesn't change
                    IF_PCPlus2;



//wire [15:0] ICacheStatus;
wire [15:0] ICacheDataToMem, ICacheAddrToMem, addrToMem, dataToMem, dataFromMem, instructionFromCache;
wire ICacheBusy, ICacheMiss, Mem_Data_Valid;
wire [15:0] DCacheDataToMem, DCacheAddrToMem;
wire DCacheMiss, writeThrough, DCacheBusy; 

// Register PC (.clk(clk), .rst(rst), .D(IF_new_pc), .WriteReg(one), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(pc), .Bitline2() );
wire ICacheNeedtoStall, DCacheNeedtoStall;
wire ICacheMemBusy, DCacheMemBusy;
wire ICacheSendingMemAddress, DCacheSendingMemAddress;  

Register PC (.clk(clk), .rst(rst), .D(IF_new_pc), .WriteReg(~dataStall && !DCacheMemBusy && !ICacheMemBusy), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(pc), .Bitline2() );

CLA_16bit PC2(.Saturated_Sum(IF_PCPlus2), .Overflow(), .Sub(zero), .A(pc), .B(16'h2));

wire ICacheReq, DCacheReq;
wire ICacheHit, DCacheHit;

Cache ICache (.address(pc), .readFromMem(dataFromMem), .data_in(zero_16bit), .memory_data_valid(Mem_Data_Valid), .enable(one), .writeCache(zero), .clk(clk), .rst(rst), .cacheNeedtoStall(ICacheNeedtoStall), .data_out(instructionFromCache), .dataToMem(ICacheDataToMem), .addrToMem(ICacheAddrToMem), .fsm_busy(ICacheBusy), .miss_detected(ICacheMiss), .writeThrough(), .cacheMemBusy(ICacheMemBusy), .cacheSendingMemAddress(ICacheSendingMemAddress), .cacheReq(ICacheReq), .cacheHit(ICacheHit)); // ICache does not write to memory;


wire memoryEnable;
//memory1c IMem (.data_out(IF_instruction), .data_in(zero_16bit), .addr(pc), .enable(one), .wr(zero), .clk(clk), .rst(rst));
ArbitrationToMemory arbitration(.ICacheMiss(ICacheMiss), .DCacheMiss(DCacheMiss), .ICacheDataToMem(ICacheDataToMem), .ICacheAddrToMem(ICacheAddrToMem), .DCacheDataToMem(DCacheDataToMem), .DCacheAddrToMem(DCacheAddrToMem), .addrToMem(addrToMem), .dataToMem(dataToMem), .ICacheMemBusy(ICacheMemBusy), .DCacheMemBusy(DCacheMemBusy), .ICacheNeedtoStall(ICacheNeedtoStall), .DCacheNeedtoStall(DCacheNeedtoStall), .ICacheSendingMemAddress(ICacheSendingMemAddress), .DCacheSendingMemAddress(DCacheSendingMemAddress), .memoryEnable(memoryEnable));

memory4c memory(.data_out(dataFromMem), .data_in(dataToMem), .addr(addrToMem), .enable(memoryEnable), .wr(writeThrough), .clk(clk), .rst(rst), .data_valid(Mem_Data_Valid));

assign IF_instruction = (ICacheBusy == 16'h0) ? instructionFromCache  : zero_16bit;

/////////////////////Control Signal to indicate whether valid Rs, Rt and Rd exists in an instruction////////////////////
assign IF_RsExists = (IF_instruction[15:12] == B)   ? 1'b0 :
                     (IF_instruction[15:12] == PCS) ? 1'b0 :
                    (IF_instruction[15:12] == HLT) ? 1'b0 :
                    1'b1;

assign IF_RtExists = (IF_instruction[15:12] == ADD)    ? 1'b1 :
                    (IF_instruction[15:12] == SUB)    ? 1'b1 :
                    (IF_instruction[15:12] == RED)    ? 1'b1 :
                    (IF_instruction[15:12] == XOR)    ? 1'b1 :
                    (IF_instruction[15:12] == PADDSB) ? 1'b1 :
                    (IF_instruction[15:12] == SW)     ? 1'b1 :
                    1'b0;
                    
assign IF_RdExists =   (IF_instruction[15:12] == B)    ? 1'b0 :
                        (IF_instruction[15:12] == BR)   ? 1'b0 :
                        (IF_instruction[15:12] == HLT)  ? 1'b0 :
                        (IF_instruction[15:12] == SW)     ? 1'b0 :
                        1'b1;

assign IF_RegisterRs = (IF_instruction[15:13] == 3'b101) ? IF_instruction[11:8] : // Only used in the Load immediate
                    IF_instruction[7:4];

assign IF_RegisterRt = (IF_instruction[15:12] == SW) ? IF_instruction[11:8] : // Only used in the SW 
                    IF_instruction[3:0];

assign IF_RegisterRd = IF_instruction[11:8];

//assign IF_writeReg = IF_RegisterRd;

// IF/ID

//assign flushOrRst = flush | rst;
assign not_flush_16bit = flush ? 16'h0000 : 16'hFFFF;


Register IFID_new_pc (.clk(clk), .rst(rst), .D(IF_new_pc & not_flush_16bit), .WriteReg(~dataStall & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(ID_new_pc), .Bitline2());
// !!!!!!!!!!!!!!!!!!!!!! Instruction reset is different 
Register IFID_instruction (.clk(clk), .rst(rst), .D(IF_instruction & not_flush_16bit), .WriteReg(~dataStall & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(ID_instruction), .Bitline2());
Register IFID_PCPlus2 (.clk(clk), .rst(rst), .D(IF_PCPlus2 & not_flush_16bit), .WriteReg(~dataStall & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(ID_PCPlus2), .Bitline2());
Register IFID_RsExists (.clk(clk), .rst(rst), .D(IF_RsExists & not_flush_16bit), .WriteReg(~dataStall & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(ID_RsExists), .Bitline2());
Register IFID_RtExists (.clk(clk), .rst(rst), .D(IF_RtExists & not_flush_16bit), .WriteReg(~dataStall& ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(ID_RtExists), .Bitline2());
Register IFID_RdExists (.clk(clk), .rst(rst), .D(IF_RdExists & not_flush_16bit), .WriteReg(~dataStall & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(ID_RdExists), .Bitline2());
Register IFID_RegisterRs (.clk(clk), .rst(rst), .D(IF_RegisterRs & not_flush_16bit), .WriteReg(~dataStall & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(ID_RegisterRs), .Bitline2());
Register IFID_RegisterRt (.clk(clk), .rst(rst), .D(IF_RegisterRt & not_flush_16bit), .WriteReg(~dataStall & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(ID_RegisterRt), .Bitline2());
Register IFID_RegisterRd (.clk(clk), .rst(rst), .D(IF_RegisterRd & not_flush_16bit), .WriteReg(~dataStall & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(ID_RegisterRd), .Bitline2());
//Register IFID_writeReg (.clk(clk), .rst(rst), .D(IF_writeReg), .WriteReg(one), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(ID_writeReg), .Bitline2());


// Start of Instruction Decode (ID) *************************************************

// dataStall Detection Unit 
//assign dataStall = dataStall | DCacheMemBusy | ICacheMemBusy;

assign cacheStall = DCacheMemBusy | ICacheMemBusy;

assign dataStall = EX_MemRead && ((EX_RdExists && ID_RsExists && (EX_RegisterRd == ID_RegisterRs)) || (EX_RdExists && ID_RtExists && (EX_RegisterRd == ID_RegisterRt)));

//assign dataStall = (EX_MemRead & (EX_instruction[11:8] == ID_instruction[]) | )


assign id_readReg1 = (ID_instruction[15:13] == 3'b101) ? ID_instruction[11:8] : // Only used in the Load immediate
                    ID_instruction[7:4];

assign id_readReg2 = (ID_instruction[15:12] == SW) ? ID_instruction[11:8] : // Only used in the SW 
                    ID_instruction[3:0];

RegisterFile registers (.clk(clk), .rst(rst), .SrcReg1(id_readReg1), .SrcReg2(id_readReg2), .DstReg(WB_writeReg), .WriteReg(WB_RegWrite), .DstData(WB_writeData), .SrcData1(ID_readData1), .SrcData2(ID_readData2));

sign_extend_4to16 sign_extend ( .input_value(ID_instruction[3:0]), .output_value(ID_4bit_sign_extended));

assign ID_4bit_sign_extended_might_left_shift_1bit = ( ID_instruction[15:13] == 3'b100) ? (ID_4bit_sign_extended << 1) :   // SW or LW:left 1 bit immediate
                                        (ID_4bit_sign_extended);  // Shift or Rotate or ... pure offset

assign ID_9bit_sign_extended_shifted = { {6{ID_instruction[8]}}, ID_instruction[8:0], 1'b0 };

control control(.instruction(ID_instruction), .MemRead(ID_MemRead), .ALUOp(ID_ALUOp), .MemWrite(ID_MemWrite), .ALUSrc(ID_ALUSrc), .RegWrite(ID_RegWrite), .flags_set(ID_flags_set), .writeDataSource(ID_writeDataSource), .Branch(ID_Branch));

assign ID_writeReg = ID_RegisterRd;

// IDEX Pipeline
// Start of Execution (EX) stage wire and pipeline

Register IDEX_new_pc (.clk(clk), .rst(rst), .D(ID_new_pc & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_new_pc), .Bitline2());
Register IDEX_instruction (.clk(clk), .rst(rst | (dataStall & ~cacheStall)), .D(ID_instruction & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_instruction), .Bitline2());
Register IDEX_PCPlus2 (.clk(clk), .rst(rst), .D(ID_PCPlus2 & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_PCPlus2), .Bitline2());
Register IDEX_readData1 (.clk(clk), .rst(rst), .D(ID_readData1 & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_readData1), .Bitline2());
Register IDEX_readData2 (.clk(clk), .rst(rst), .D(ID_readData2 & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_readData2), .Bitline2());
Register IDEX_4bit_sign_extended (.clk(clk), .rst(rst), .D(ID_4bit_sign_extended_might_left_shift_1bit & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_4bit_sign_extended_might_left_shift_1bit), .Bitline2());
Register IDEX_9bit_sign_extended (.clk(clk), .rst(rst), .D(ID_9bit_sign_extended_shifted & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_9bit_sign_extended_shifted), .Bitline2());
Register IDEX_RegWrite (.clk(clk), .rst(rst | (dataStall & ~cacheStall)), .D(ID_RegWrite & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_RegWrite), .Bitline2());
Register IDEX_Branch (.clk(clk), .rst(rst | (dataStall & ~cacheStall)), .D(ID_Branch & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_Branch), .Bitline2());
Register IDEX_ALUSrc (.clk(clk), .rst(rst), .D(ID_ALUSrc & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_ALUSrc), .Bitline2());
Register IDEX_ALUOp (.clk(clk), .rst(rst), .D(ID_ALUOp & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_ALUOp), .Bitline2());
Register IDEX_MemRead (.clk(clk), .rst(rst | ((dataStall & ~cacheStall) & ~cacheStall)), .D(ID_MemRead & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_MemRead), .Bitline2());
Register IDEX_flags_set (.clk(clk), .rst(rst | (dataStall & ~cacheStall)), .D(ID_flags_set & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_flags_set), .Bitline2());
Register IDEX_writeDataSource (.clk(clk), .rst(rst), .D(ID_writeDataSource & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_writeDataSource), .Bitline2());

Register IDEX_RsExists (.clk(clk), .rst(rst), .D(ID_RsExists & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_RsExists), .Bitline2());
Register IDEX_RtExists (.clk(clk), .rst(rst), .D(ID_RtExists & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_RtExists), .Bitline2());
Register IDEX_RdExists (.clk(clk), .rst(rst), .D(ID_RdExists & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_RdExists), .Bitline2());
Register IDEX_RegisterRs (.clk(clk), .rst(rst), .D(ID_RegisterRs & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_RegisterRs), .Bitline2());
Register IDEX_RegisterRt (.clk(clk), .rst(rst), .D(ID_RegisterRt & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_RegisterRt), .Bitline2());
Register IDEX_RegisterRd (.clk(clk), .rst(rst), .D(ID_RegisterRd & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_RegisterRd), .Bitline2());
Register IDEX_writeReg (.clk(clk), .rst(rst | (dataStall & ~cacheStall)), .D(ID_writeReg & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_writeReg), .Bitline2());
Register IDEX_MemWrite (.clk(clk), .rst(rst | (dataStall & ~cacheStall)), .D(ID_MemWrite & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(EX_MemWrite), .Bitline2());


assign ex_opcode = EX_instruction[15:12];

assign ex_isB = (ex_opcode == 4'b1100); 
CLA_16bit PC2Final(.Saturated_Sum(ex_PCPlus2PlusI), .Overflow(), .Sub(zero), .A(EX_PCPlus2), .B(EX_9bit_sign_extended_shifted));

assign EX_BranchAddress = ex_isB ? ex_PCPlus2PlusI : EX_readData1;  

assign ex_EXhazard1 = MEM_RegWrite && MEM_RdExists && EX_RsExists && (MEM_RegisterRd == EX_RegisterRs);
assign ex_EXhazard2 = MEM_RegWrite && MEM_RdExists && EX_RtExists && (MEM_RegisterRd == EX_RegisterRt);

assign ex_MEMhazard1 =  WB_RegWrite && WB_RdExists && EX_RsExists && (WB_RegisterRd == EX_RegisterRs);
assign ex_MEMhazard2 =  WB_RegWrite && WB_RdExists && EX_RtExists && (WB_RegisterRd == EX_RegisterRt);



wire [15:0] EX_readData2Forward;
// SW ReadData2 Forward
assign EX_readData2Forward = (ex_Forward2 == 2'b01 && EX_instruction[15:12] == 4'b1001) ? WB_writeData : EX_readData2;

assign ex_Forward1 = ex_EXhazard1 ? 2'b10 :    // EX Forward
                     ex_MEMhazard1 ? 2'b01 :   // MEM Forward
                     2'b00;      // Don't forward

assign ex_Forward2 = ex_EXhazard2 ? 2'b10 :
                     ex_MEMhazard2 ? 2'b01 :
                     2'b00;

assign ex_ALU_In1 = (ex_Forward1 == 2'b00) ? EX_readData1 :
                    (ex_Forward1 == 2'b01) ? WB_writeData :
                    (ex_Forward1 == 2'b10) ? 
                        (MEM_writeDataSource == 2'b11) ? MEM_load_immediate_Out :
                        (MEM_writeDataSource == 2'b01) ? MEM_ALU_Out :
                        EX_readData1 : // Should not happen
                    EX_readData1; 

assign ex_ALU_In2 = (ex_Forward2 == 2'b00) ? EX_ALUSrc ? EX_4bit_sign_extended_might_left_shift_1bit : EX_readData2 :
                    (ex_Forward2 == 2'b01) ? (EX_instruction[15:12] == 4'b1001) ? EX_4bit_sign_extended_might_left_shift_1bit : WB_writeData :
                    (ex_Forward1 == 2'b10) ? MEM_ALU_Out  :
                    MEM_ALU_Out; 

ALU alu(.ALU_Out(EX_ALU_Out), .flags_from_alu(ex_flags_from_alu), .ALU_In1(ex_ALU_In1), .ALU_In2(ex_ALU_In2), .ALUOp(EX_ALUOp));

flag_register flags_module (.clk(clk), .rst(rst), .flags_from_alu(ex_flags_from_alu), .flags_set(EX_flags_set), .flags(EX_flags));

assign ex_load_immediate_immediate = EX_9bit_sign_extended_shifted[8:1];  // = instruction[7:0]

// assign ex_load_immediate_RegisterReadValue = (ex_Forward1 == 2'b00) ? EX_readData1 :
// 											 (ex_Forward1 == 2'b01) ? WB_writeData :
//                                              (ex_Forward1 == 2'b10) ? MEM_load_immediate_Out  :
//                                               EX_readData1; 
load_immediate load_immediate (.RegisterReadValue(ex_ALU_In1), .RegisterWriteValue(EX_load_immediate_Out), .Immediate(ex_load_immediate_immediate), .opcode(ex_opcode));


// EX/MEM

// Start of MEM 
Register EXMEM_PCPlus2 (.clk(clk), .rst(rst), .D(EX_PCPlus2 & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_PCPlus2), .Bitline2());
Register EXMEM_new_pc (.clk(clk), .rst(rst), .D(EX_new_pc & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_new_pc), .Bitline2());
Register EXMEM_instruction (.clk(clk), .rst(rst), .D(EX_instruction & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_instruction), .Bitline2());
Register EXMEM_ALU_Out (.clk(clk), .rst(rst), .D(EX_ALU_Out & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_ALU_Out), .Bitline2());
Register EXMEM_readData2 (.clk(clk), .rst(rst), .D(EX_readData2Forward & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_readData2), .Bitline2());
Register EXMEM_load_immediate_Out (.clk(clk), .rst(rst), .D(EX_load_immediate_Out & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_load_immediate_Out), .Bitline2());
Register EXMEM_flags (.clk(clk), .rst(rst), .D(EX_flags & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_flags), .Bitline2());
Register EXMEM_RegWrite (.clk(clk), .rst(rst), .D(EX_RegWrite & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_RegWrite), .Bitline2());
Register EXMEM_Branch (.clk(clk), .rst(rst), .D(EX_Branch & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_Branch), .Bitline2());
Register EXMEM_MemRead (.clk(clk), .rst(rst), .D(EX_MemRead & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_MemRead), .Bitline2());
Register EXMEM_MemWrite (.clk(clk), .rst(rst), .D(EX_MemWrite & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_MemWrite), .Bitline2());
Register EXMEM_BranchAddress (.clk(clk), .rst(rst), .D(EX_BranchAddress & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_BranchAddress), .Bitline2());
Register EXMEM_writeDataSource (.clk(clk), .rst(rst), .D(EX_writeDataSource & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_writeDataSource), .Bitline2());
Register EXMEM_RsExists (.clk(clk), .rst(rst), .D(EX_RsExists & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_RsExists), .Bitline2());
Register EXMEM_RtExists (.clk(clk), .rst(rst), .D(EX_RtExists & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_RtExists), .Bitline2());
Register EXMEM_RdExists (.clk(clk), .rst(rst), .D(EX_RdExists & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_RdExists), .Bitline2());
Register EXMEM_RegisterRs (.clk(clk), .rst(rst), .D(EX_RegisterRs & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_RegisterRs), .Bitline2());
Register EXMEM_RegisterRt (.clk(clk), .rst(rst), .D(EX_RegisterRt & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_RegisterRt), .Bitline2());
Register EXMEM_RegisterRd (.clk(clk), .rst(rst), .D(EX_RegisterRd & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_RegisterRd), .Bitline2());
Register EXMEM_writeReg (.clk(clk), .rst(rst), .D(EX_writeReg & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(MEM_writeReg), .Bitline2());


assign flush = MEM_PCSrc;

PC_control pc_control (.Branch (MEM_Branch),  .C(MEM_instruction[11:9]) , .F(MEM_flags), .PCSrc(MEM_PCSrc));


//memory1c DMem (.data_out(MEM_Mem_Out), .data_in(MEM_readData2), .addr(MEM_ALU_Out), .enable(MEM_MemRead | MEM_MemWrite), .wr(MEM_MemWrite), .clk(clk), .rst(rst));

Cache DCache (.address(MEM_ALU_Out), .readFromMem(dataFromMem), .data_in(MEM_readData2), .memory_data_valid(Mem_Data_Valid), .enable(MEM_MemRead | MEM_MemWrite), .writeCache(MEM_MemWrite), .clk(clk), .rst(rst), .cacheNeedtoStall(DCacheNeedtoStall), .data_out(MEM_Mem_Out), .dataToMem(DCacheDataToMem), .addrToMem(DCacheAddrToMem), .fsm_busy(DCacheBusy), .miss_detected(DCacheMiss), .writeThrough(writeThrough), .cacheMemBusy(DCacheMemBusy), .cacheSendingMemAddress(DCacheSendingMemAddress), .cacheReq(DCacheReq), .cacheHit(DCacheHit));


// MEM/WB

// Start of WB
Register MEMWB_RegWrite (.clk(clk), .rst(rst), .D(MEM_RegWrite & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_RegWrite), .Bitline2());
Register MEMWB_writeDataSource (.clk(clk), .rst(rst), .D(MEM_writeDataSource & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_writeDataSource), .Bitline2());
Register MEMWB_new_pc (.clk(clk), .rst(rst), .D(MEM_new_pc & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_new_pc), .Bitline2());
Register MEMWB_Mem_Out (.clk(clk), .rst(rst), .D(MEM_Mem_Out & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_Mem_Out), .Bitline2());
Register MEMWB_load_immediate_Out (.clk(clk), .rst(rst), .D(MEM_load_immediate_Out & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_load_immediate_Out), .Bitline2());
Register MEMWB_ALU_Out (.clk(clk), .rst(rst), .D(MEM_ALU_Out & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_ALU_Out), .Bitline2());
Register MEMWB_instruction (.clk(clk), .rst(rst), .D(MEM_instruction & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_instruction), .Bitline2());

Register MEMWB_RegisterRs (.clk(clk), .rst(rst), .D(MEM_RegisterRs & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_RegisterRs), .Bitline2());
Register MEMWB_RegisterRt (.clk(clk), .rst(rst), .D(MEM_RegisterRt & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_RegisterRt), .Bitline2());
Register MEMWB_RegisterRd (.clk(clk), .rst(rst), .D(MEM_RegisterRd & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_RegisterRd), .Bitline2());
Register MEMWB_RsExists (.clk(clk), .rst(rst), .D(MEM_RsExists & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_RsExists), .Bitline2());
Register MEMWB_RtExists (.clk(clk), .rst(rst), .D(MEM_RtExists & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_RtExists), .Bitline2());
Register MEMWB_RdExists (.clk(clk), .rst(rst), .D(MEM_RdExists & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_RdExists), .Bitline2());
Register MEMWB_writeReg (.clk(clk), .rst(rst), .D(MEM_writeReg & not_flush_16bit), .WriteReg(one & ~cacheStall), .ReadEnable1(one), .ReadEnable2(zero), .Bitline1(WB_writeReg), .Bitline2());




assign WB_writeData =  (WB_writeDataSource == 2'b00) ? WB_new_pc :
                    (WB_writeDataSource == 2'b10) ? WB_Mem_Out :
                    (WB_writeDataSource == 2'b11) ? WB_load_immediate_Out :
                    WB_ALU_Out;          //2'b01

assign hlt = (WB_instruction[15:12] == 4'b1111) ? 1 : 0;



endmodule
