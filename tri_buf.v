module tri_buf (in,out,enable);
input in, enable;
output out;

assign out = enable ? in : 1'bz;
   	  	 
endmodule