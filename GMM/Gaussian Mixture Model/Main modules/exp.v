//----check---fp---
//--- bo sung wire ---

module exp(
		grey,
		out_rho
		);
input [7:0] grey;
output reg [31:0] out_rho;
wire [31:0] num0;
assign num0 = 32'b00111111100000000000000000000000;
wire [31:0] num1;
assign num1 = 32'b00111111000110110100010110011000;
wire [31:0] num2;
assign num2 = 32'b00111110000010101001010101010000;
wire [31:0] num3;
assign num3 = 32'b00111100001101100000001001111011;
wire [31:0] num4;
assign num4 = 32'b00111001101011111101100010100000;
wire [31:0] num5;
assign num5 = 32'b00110110011110000100110110000100;

always @(grey)
begin
case(grey)
	8'd0:		out_rho = num0;
	8'd1:		out_rho = num1;
	8'd2:		out_rho = num2;
	8'd3:		out_rho = num3;
	8'd4:		out_rho = num4;
	8'd5:		out_rho = num5;
	default:  out_rho = 32'b0;
endcase
end
endmodule