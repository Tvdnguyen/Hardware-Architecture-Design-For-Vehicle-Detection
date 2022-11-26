//---- check fp  ----
//---- 20/11/2018 by NTM.Linh ---
/// edit inv sqrt 26.5
// done 27.5
module updateMuSigma 
(
		clk_i,
		rst_i,
		en_updateMuSigma,
		rho,
		grey,
		in_mugreyi,
		in_sigmai,
		rd_updateMuSigma,
		out_mugreyi,
		out_sigmai
	);
input clk_i;
input rst_i;
input en_updateMuSigma;
input [31:0] rho;
input [31:0] grey;
input [31:0] in_mugreyi;
input [31:0] in_sigmai;
output rd_updateMuSigma;
output [31:0] out_mugreyi;
output [31:0] out_sigmai;
wire [31:0] constant1;
assign constant1 = 32'b00111111100000000000000000000000;
//--- state0---
wire [31:0] sub_rho;
wire [31:0] mul_grey_rho;
wire [31:0] out_mugreyi_r;
//--- state1---
reg start_sqrt;
wire start_sqrt_pp;
wire [31:0]  mul_greypow_rho;
wire [31:0]  sigmai_pow2 ;
wire [31:0]  mul_sigmai_pow2;
wire [31:0]  sub_grey ; //-- unsigned
wire [31:0] upsigma_pow ;
wire [31:0] result_sigma; //--- sqrt_fp
wire [31:0] bar_in_mugreyi;
wire [31:0] bar_rho;
//wire [31:0] upsigma_pow_r;
wire [31:0] inv_upsigma_pow;
wire rd_mul_grey_rho;
wire rd_mul_greypow_rho;
wire rd_mul_sigmai_pow2;
wire rd_out_mugreyi_r;
wire rd_sigmai_pow2;
wire rd_sub_grey;
wire rd_sub_rho;
wire rd_upsigma_pow;
wire rd_inv_upsigma_pow;

wire start_sqrt_pp1;
wire start_sqrt_pp2;
wire start_sqrt_pp3;
wire en_inst_updatesigma_4;
reg wait_1;
reg wait_2;
//-- TYPE DECLARATION
//--- sub 
assign bar_in_mugreyi[30:0] = in_mugreyi[30:0];
assign bar_in_mugreyi[31] = 1'b1;  //--sub
adder inst_updateMu_1
(
        .input_a(grey),
        .input_b(bar_in_mugreyi),
        .input_a_stb(en_updateMuSigma),
        .input_b_stb(en_updateMuSigma),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(sub_grey),
        .output_z_stb(rd_sub_grey),
        .input_a_ack(),
        .input_b_ack()
);
//--- rho*subgrey---
multiplier inst_updateMU_2
(
        .input_a(sub_grey),
        .input_b(rho),
        .input_a_stb(rd_sub_grey),
        .input_b_stb(rd_sub_grey),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(mul_grey_rho),
        .output_z_stb(rd_mul_grey_rho),
        .input_a_ack(),
        .input_b_ack()
);

//---rho*subgrey^2---
multiplier inst_updateSigmaMu_0
(
        .input_a(mul_grey_rho),
        .input_b(sub_grey),
        .input_a_stb(rd_mul_grey_rho),
        .input_b_stb(rd_mul_grey_rho),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(mul_greypow_rho),
        .output_z_stb(rd_mul_greypow_rho),
        .input_a_ack(),
        .input_b_ack()
);

//----in_mugreyi + rho*subgrey ---
adder inst_updateMU_3
(
        .input_a(mul_grey_rho),
        .input_b(in_mugreyi),
        .input_a_stb(rd_mul_grey_rho),
        .input_b_stb(rd_mul_grey_rho),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(out_mugreyi_r),
        .output_z_stb(rd_out_mugreyi_r),
        .input_a_ack(),
        .input_b_ack()
);


//--------------------------------------
//--------------------------------------	
assign bar_rho[30:0] = rho[30:0];
assign bar_rho[31] = 1'b1;
/// 1-rho
adder inst_updatesigma_1
(
        .input_a(constant1),
        .input_b(bar_rho),
        .input_a_stb(en_updateMuSigma),
        .input_b_stb(en_updateMuSigma),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(sub_rho),
        .output_z_stb(rd_sub_rho),
        .input_a_ack(),
        .input_b_ack()
);
		
//---- sigma^2---	
multiplier inst_updatesigma_2
(
        .input_a(in_sigmai),
        .input_b(in_sigmai),
        .input_a_stb(en_updateMuSigma),
        .input_b_stb(en_updateMuSigma),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(sigmai_pow2),
        .output_z_stb(rd_sigmai_pow2),
        .input_a_ack(),
        .input_b_ack()
);

//---(1-rho)*sigma^2-----
multiplier inst_updatesigma_3
(
        .input_a(sub_rho),
        .input_b(sigmai_pow2),
        .input_a_stb(rd_sub_rho),
        .input_b_stb(rd_sub_rho),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(mul_sigmai_pow2),
        .output_z_stb(rd_mul_sigmai_pow2),
        .input_a_ack(),
        .input_b_ack()
);
always @(posedge clk_i)
begin	
	if (rd_mul_greypow_rho)
		wait_1 <= 1'b1;
	else if( en_inst_updatesigma_4 == 1'b1)
		wait_1 <= 1'b0;	
	if (rd_mul_sigmai_pow2)
		wait_2 <= 1'b1;
	else if( en_inst_updatesigma_4 == 1'b1)
		wait_2 <= 1'b0;	
end
assign en_inst_updatesigma_4 = wait_1&wait_2;
//--- 
adder inst_updatesigma_4
(
        .input_a(mul_sigmai_pow2),
        .input_b(mul_greypow_rho),
        .input_a_stb(en_inst_updatesigma_4),
        .input_b_stb(en_inst_updatesigma_4),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(upsigma_pow),
        .output_z_stb(rd_upsigma_pow),
        .input_a_ack(),
        .input_b_ack()
);
divider inst_updatesigma_5
(
        .input_a(constant1),
        .input_b(upsigma_pow),
        .input_a_stb(rd_upsigma_pow),
        .input_b_stb(rd_upsigma_pow),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(inv_upsigma_pow),   //---- 1/upsigma_pow
        .output_z_stb(rd_inv_upsigma_pow),
        .input_a_ack(),
        .input_b_ack()
);
assign out_mugreyi = out_mugreyi_r;		
always @(posedge clk_i)
begin
	start_sqrt <= rd_inv_upsigma_pow;
end
FpInvSqrt invsqrt(      //27 bit (delete 5 bit )---1/sqrt_fp
    .iCLK(clk_i),
    .iA(inv_upsigma_pow[31:5]),
    .oInvSqrt(result_sigma[31:5])		//
);
pp pp1 (.clk_i(clk_i),.indata(start_sqrt),.outdata(start_sqrt_pp)); 
pp pp2 (.clk_i(clk_i),.indata(start_sqrt_pp),.outdata(start_sqrt_pp1)); 
pp pp3 (.clk_i(clk_i),.indata(start_sqrt_pp1),.outdata(start_sqrt_pp2));
pp pp4 (.clk_i(clk_i),.indata(start_sqrt_pp2),.outdata(start_sqrt_pp3));  
assign result_sigma[4:0] = 4'b0;
assign out_sigmai = result_sigma;
assign rd_updateMuSigma = start_sqrt_pp3;

endmodule