//----check---fp
//--- bo sung constant ---
//--- edited 18/5/2019
// done 26.5
module rho(
		clk_i,
		rst_i,
		en_rho,
		grey,
		sigma,
		mugrey,
		out_rho,
		done_rho
		);	
input clk_i;
input rst_i;
input en_rho;
input [31:0] grey;
input [31:0] sigma;
input [31:0] mugrey;
output [31:0] out_rho;
output done_rho;
wire [31:0] sub_grey;
wire [31:0] bar_mugrey; //--- (- mugrey)
wire [31:0] div_subgrey_sigma;
wire [31:0] result_coef;
wire [31:0] power;
wire [31:0] result_exp;
wire [31:0] out_rho_r;
wire [7:0] power_in;
//---0.04/sqrt(2*3.14)---0.015961
wire [31:0] coef;
wire rd_div_subgrey_sigma;
wire rd_out_rho_r;
wire rd_power;
wire rd_result_coef;
wire rd_sub_grey;
wire rd_power_r;
reg wait_1;
reg wait_2;
//reg rd_power_r;
assign coef = 32'b00111100100000101011100110110100;

assign bar_mugrey = {1'b1,mugrey[30:0]};
divider inst_fpu_double0(
        .input_a(coef),
        .input_b(sigma),
        .input_a_stb(en_rho),
        .input_b_stb(en_rho),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(result_coef),
        .output_z_stb(rd_result_coef), //---(0.04/sqrt(2*3.14))/sigma---
        .input_a_ack(),
        .input_b_ack()
);
adder inst_fpu_double1
(
        .input_a(grey),
        .input_b(bar_mugrey),
        .input_a_stb(en_rho),
        .input_b_stb(en_rho),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(sub_grey),
        .output_z_stb(rd_sub_grey),
        .input_a_ack(),
        .input_b_ack()
);
divider inst_fpu_double2
(
        .input_a(sub_grey),
        .input_b(sigma),
        .input_a_stb(rd_sub_grey),
        .input_b_stb(rd_sub_grey),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(div_subgrey_sigma),
        .output_z_stb(rd_div_subgrey_sigma),
        .input_a_ack(),
        .input_b_ack()
);
multiplier inst_fpu_double3
(
        .input_a(div_subgrey_sigma),
        .input_b(div_subgrey_sigma),
        .input_a_stb(rd_div_subgrey_sigma),
        .input_b_stb(rd_div_subgrey_sigma),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(power),
        .output_z_stb(rd_power),
        .input_a_ack(),
        .input_b_ack()
);
always @(clk_i)
begin
	if(rd_result_coef)
		wait_1 <= 1'b1;
	else if (rd_power_r == 1'b1)
		wait_1 <= 1'b0;
	if(rd_power)
		wait_2 <= 1'b1;
	else if (rd_power_r == 1'b1)
		wait_2 <= 1'b0;
end
assign rd_power_r = wait_1&wait_2;
FP_integer inst_convert_fp2int(
		.fp_number(power),
		.in_number(power_in)
		);
	
exp inst_exp(
			.grey(power_in),
			.out_rho(result_exp)
			);
/*
always @(posedge clk_i)
begin
	rd_power_r <= rd_power;
end
*/
multiplier inst_fpu_double4
(
        .input_a(result_exp),
        .input_b(result_coef),
        .input_a_stb(rd_power_r),
        .input_b_stb(rd_power_r),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(out_rho_r),
        .output_z_stb(rd_out_rho_r),
        .input_a_ack(),
        .input_b_ack()
);
assign out_rho = out_rho_r;
assign done_rho = rd_out_rho_r;
endmodule
