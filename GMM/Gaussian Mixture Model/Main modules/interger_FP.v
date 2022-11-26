//--- edited 22/8/2018 by Linh---
module  interger_FP(
		 in_number,
         fp_number    
   );
   input [7:0] in_number;
   output [31:0] fp_number;
	reg [7:0] Exponent;
	reg [22:0] Fraction;
	wire [22:0] Zero;
	assign Zero = 23'b0;
	wire Sign;
//--sign
assign Sign = 1'b0;	
//--Exponent,Fraction
	always @(in_number)
	begin
		if (in_number[7] == 1'b1)  begin
			Exponent = 8'd127 + 8'd7;
			Fraction = {in_number[6:0],Zero[15:0]} ;
		end
		else if (in_number[6] == 1'b1) begin
			Exponent = 8'd127 + 8'd6;
			Fraction = {in_number[5:0],Zero[16:0]} ;
		end
		else if (in_number[5] == 1'b1) begin
			Exponent = 8'd127 + 8'd5;
			Fraction = {in_number[4:0],Zero[17:0]} ;
		end
		else if (in_number[4] == 1'b1) begin
			Exponent = 8'd127 + 8'd4;	
			Fraction = {in_number[3:0],Zero[18:0]} ;
		end
		else if (in_number[3] == 1'b1) begin
			Exponent = 8'd127 + 8'd3;
			Fraction = {in_number[2:0],Zero[19:0]} ;
		end
		else if (in_number[2] == 1'b1) begin
			Exponent = 8'd127 + 8'd2;
			Fraction = {in_number[1:0],Zero[20:0]} ;
		end
		else if (in_number[1] == 1'b1) begin
			Exponent = 8'd127 + 8'd1;
			Fraction = {in_number[0],Zero[21:0]} ;
		end
		else if (in_number[0] == 1'b1) begin 
			Exponent = 8'd127 + 8'd0;
			Fraction =  Zero[22:0] ;
		end
		else begin 
			Exponent = 8'b0;
			Fraction = 23'b0;
		end 
	end	
assign	fp_number = {Sign,Exponent,Fraction};	
endmodule

	
	
	
	
		
