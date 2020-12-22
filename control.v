module control(instruction, MemRead, ALUOp, MemWrite, ALUSrc, RegWrite, flags_set, writeDataSource, Branch);
 // Reference book P264 (287 real page) Fig 4.17
input[15:0] instruction;


output  MemRead, MemWrite, ALUSrc, RegWrite, Branch;
output [1:0] flags_set, writeDataSource; // Whether to update Z, V, N
                        // WriteSource: 00 : new_pc
                                  //      01 : ALU
                                  //      10 : Mem
                                  //      11 : LHB / LLB
output [2:0]ALUOp;
wire [3:0] opcode;

assign opcode = instruction[15:12];


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

/////////////////////Control Signal to indicate whether valid Rs, Rt and Rd exists in an instruction////////////////////
// assign RsExists = (opcode == B)   ? 1'b0 :
//                   (opcode == PCS) ? 1'b0 :
//                   (opcode == HLT) ? 1'b0 :
//                    1'b1;

// assign RtExists = (opcode == ADD)    ? 1'b1 :
//                   (opcode == SUB)    ? 1'b1 :
//                   (opcode == RED)    ? 1'b1 :
//                   (opcode == XOR)    ? 1'b1 :
//                   (opcode == PADDSB) ? 1'b1 :
//                   (opcode == SW)     ? 1'b1 :
//                   1'b0;
                  
// assign RdExists =   (opcode == B)    ? 1'b0 :
//                     (opcode == BR)   ? 1'b0 :
//                     (opcode == HLT)  ? 1'b0 :
//                     1'b1;


wire emptyInstruction;

// RegDST is not needed because we always write to the bits [11:8]
assign Branch =     (emptyInstruction == 1'b1) ? 0 :  
                    (opcode[3:1] == 3'b110);

assign writeDataSource =
                (opcode == LW) ? 2'b10 :
                (opcode == LHB) ? 2'b11 :
                (opcode == LLB) ? 2'b11 :
                (opcode == PCS) ? 2'b00 : 2'b01;    // ALU



assign emptyInstruction = (instruction == 16'h0) ? 1'b1 : 1'b0; 

assign RegWrite =   (emptyInstruction == 1'b1) ? 0 :  
                    (opcode == SW) ? 0 : 
                    (opcode == B) ? 0 :
                    (opcode == BR) ? 0 :
                    (opcode == HLT) ? 0 : 1;



assign MemRead = (emptyInstruction == 1'b1) ? 0 :  
                 (opcode == LW) ? 1 : 
                 0 ;

assign ALUOp = (opcode == PADDSB) ? 3'b111 : 
                (opcode == ROR) ? 3'b110 :
                (opcode == SRA) ? 3'b101 :
                (opcode == SLL) ? 3'b100 :
                (opcode == XOR) ? 3'b011 :
                (opcode == RED) ? 3'b010 :
                (opcode == SUB) ? 3'b001 :
                (opcode == BR) ? 3'b001 :
                (opcode == B) ? 3'b001 :
                3'b000;

assign flags_set = (opcode == ADD) ? 2'b11 :
                (opcode == SUB) ? 2'b11 : 
                (opcode == XOR) ? 2'b01 :
                (opcode == SLL) ? 2'b01 :
                (opcode == SRA) ? 2'b01 :
                (opcode == ROR) ? 2'b01 :
                2'b00;



assign MemWrite = (emptyInstruction == 1'b1) ? 0 :   
                (opcode == SW) ? 1 : 0 ;

assign ALUSrc = (opcode == PCS) ? 0 :
                (opcode == ADD) ? 0 :
                (opcode == PADDSB) ? 0 :
                (opcode == SUB) ? 0 : 
                (opcode == RED) ? 0 : 
                (opcode == XOR) ? 0 :
                1;




endmodule

