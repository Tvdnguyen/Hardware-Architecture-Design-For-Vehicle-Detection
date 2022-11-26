//--/////////////////////////////////////////////////////////////////////
// result = 00: opA = opB
//		  01: opA > opB
//		  10: opA < opB
//
//
/////////////////////////////////////////////////////////////////////
//--- edited 11/15/2018
//--- edited 21/5/2019
// done 26.5

module Compare_FP(
		 opA, 
		 opB,
         result 
);
input [31:0] opA;
input [31:0] opB;
output reg [1:0] result;
reg [8:0] Exponent_A;
reg [8:0] Exponent_B;
reg [23:0] Fraction_A;
reg [23:0] Fraction_B;
reg Sign_A;
reg Sign_B;

	always @(opA, opB)
	begin
		Exponent_A = {1'b0,opA[30:23]};
		Exponent_B = {1'b0,opB[30:23]};
		Fraction_A = {1'b0,opA[22:0]};
		Fraction_B = {1'b0,opB[22:0]};
		Sign_A = opA[31];
		Sign_B = opB[31];

		if 	((Exponent_A > Exponent_B) & (Sign_A == 1'b0) & (Sign_B == 1'b0)) 
			result = 2'b01;  //--A>B
		else if 	((Exponent_A > Exponent_B) & (Sign_A == 1'b1) & (Sign_B == 1'b1))
			result = 2'b10; //--A<B
		else if 	((Sign_A == 1'b0) & (Sign_B == 1'b1)) 
			result = 2'b01; 
		else if	((Sign_A == 1'b1) & (Sign_B == 1'b0))  
			result = 2'b10; 		
		else if ((Exponent_A < Exponent_B) & (Sign_A == 1'b0) & (Sign_B == 1'b0))  
			result = 2'b10;
		else if ((Exponent_A < Exponent_B) & (Sign_A == 1'b1) & (Sign_B == 1'b1))  
			result = 2'b01; 		
		else if ((Exponent_A == Exponent_B) & (Sign_A == 1'b1) & (Sign_B == 1'b0)) 
			result = 2'b10; 
		else if ((Exponent_A == Exponent_B) & (Sign_A == 1'b0) & (Sign_B == 1'b1))  
			result = 2'b01; 		
		else if ((Exponent_A == Exponent_B) & (Sign_A == 1'b0) & (Sign_B == 1'b0)) begin 
			if (Fraction_A > Fraction_B ) result = 2'b01; 
			else if (Fraction_A < Fraction_B ) result = 2'b10; 
			else result = 2'b00;
		end			
		else if ((Exponent_A == Exponent_B) & (Sign_A == 1'b1) & (Sign_B == 1'b1)) begin
			result = 2'b10;
			if (Fraction_A > Fraction_B ) result = 2'b10; 
			else if (Fraction_A < Fraction_B)  result = 2'b01; 
			else result = 2'b00; 
		end
		
	end
endmodule
	