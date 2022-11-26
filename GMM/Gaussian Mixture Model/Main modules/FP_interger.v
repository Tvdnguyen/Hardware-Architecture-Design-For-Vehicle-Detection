//--- edited 22/8/2018 by Linh---



module FP_integer (
		 fp_number,
         in_number    
   );
input [31:0] fp_number;
output reg [7:0] in_number;
	
always @(fp_number)
	begin
		if (fp_number[30:23] > 8'b10000110)  
			in_number = 8'b11111111;
		else if (fp_number[30:23] == 8'b10000110)  
			in_number = {1'b1,fp_number[22:16]};
		else if (fp_number[30:23] == 8'b10000101) 
			in_number = {2'b01,fp_number[22:17]};
		else if (fp_number[30:23] == 8'b10000100) 
			in_number = {3'b001,fp_number[22:18]};
		else if (fp_number[30:23] == 8'b10000011) 
			in_number = {4'b0001,fp_number[22:19]};
		else if (fp_number[30:23] == 8'b10000010) 
			in_number = {5'b00001,fp_number[22:20]};
		else if (fp_number[30:23] == 8'b10000001) 
			in_number = {6'b000001,fp_number[22:21]};
		else if (fp_number[30:23] == 8'b10000000) 
			in_number = {7'b0000001,fp_number[22]};
		else if (fp_number[30:23] == 8'b01111111)  
			in_number = 8'b00000001;
		else in_number = 8'b0;
	end	
endmodule

	
	
	
	
		
