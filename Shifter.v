module Shifter (Shift_Out, Shift_In, Shift_Val, Mode);
input [15:0] Shift_In; //This is the number to perform shift operation on

input [3:0] Shift_Val; //Shift amount (used to shift the ‘Shift_In’)
input [1:0] Mode; // To indicate SLL or SRA , 00 is SLL, 01 is SRA,  10: Rotate right
output [15:0] Shift_Out; //Shifter value

wire [15:0] shift_0, shift_1, shift_2;


assign shift_0 = 
                Shift_Val[0] ?  
                    Mode[1] ? {Shift_In[0], Shift_In[15:1]} : 
                        Mode[0] ? 
                            {Shift_In[15], Shift_In[15:1]} :   // Shift right 1 bit
                            {Shift_In[14:0], 1'b0}    // Shift left 1 bit
                : Shift_In;


assign shift_1 = 
                Shift_Val[1] ?  
                    Mode[1] ? {shift_0[1:0], shift_0[15:2]} : 
                        Mode[0] ? 
                            { {2{shift_0[15]}}, shift_0[15:2]} :   // Shift right 2 bit
                            {shift_0[13:0], 2'b00}    // Shift left 2 bit
                : shift_0;

assign shift_2 = 
                Shift_Val[2] ?  
                    Mode[1] ? {shift_1[3:0], shift_1[15:4]} : 
                        Mode[0] ? 
                            { {4{shift_1[15]}}, shift_1[15:4]} :   // Shift right 4 bit
                            {shift_1[11:0], 4'b0000}    // Shift left 4 bit
                : shift_1;


assign Shift_Out = 
                Shift_Val[3] ?  
                    Mode[1] ? {shift_2[7:0], shift_2[15:8]} : 
                        Mode[0] ? 
                            { {8{shift_2[15]}}, shift_2[15:8]} :   // Shift right 8 bit
                            {shift_2[7:0], 8'b00000000}    // Shift left 8 bit
                : shift_2;






endmodule

