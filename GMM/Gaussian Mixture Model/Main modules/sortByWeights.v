//-- check fp---
//-- sort mugreyi, sigmai, weighti, by w/sigma---
//---edited 18/11/2018 by NTM.LINH---
//---- edit 19.5
// done 26.5

module sortByWeights(
		clk_i,
		rst_i,
		in_w0,
		in_w1,
		in_w2,
		in_sigma0,
		in_sigma1,     
		in_sigma2,
		in_mugrey0,
		in_mugrey1,
		in_mugrey2,
		en_sortByWeights,
		sort_mugrey0,
		sort_mugrey1,
		sort_mugrey2,
		sort_w0 ,
		sort_w1 ,
		sort_w2 ,
		sort_sigma0 ,
		sort_sigma1 ,
		sort_sigma2 ,
		rd_sortbyWeights
		);

input clk_i;
input rst_i;
input [31:0] in_w0;
input [31:0] in_w1;
input [31:0] in_w2;
input [31:0] in_sigma0;
input [31:0] in_sigma1;
input [31:0] in_sigma2;
input [31:0] in_mugrey0;
input [31:0] in_mugrey1;
input [31:0] in_mugrey2;
input en_sortByWeights;
output reg [31:0] sort_w0;
output reg [31:0] sort_w1;
output reg [31:0] sort_w2;
output reg [31:0] sort_mugrey0;
output reg [31:0] sort_mugrey1;
output reg [31:0] sort_mugrey2;
output reg [31:0] sort_sigma0;
output reg [31:0] sort_sigma1;
output reg [31:0] sort_sigma2;
output reg rd_sortbyWeights;

wire[31:0]  rate0;
wire[31:0]  rate1;
wire[31:0]  rate2;
wire r0lessr1;
wire r0lessr2;
wire r1lessr2;
wire [1:0] result0;
wire [1:0] result1;
wire [1:0] result2;



wire [31:0] opa0;
wire [31:0] opa1;
wire [31:0] opa2;
wire [31:0] opb0;
wire [31:0] opb1;
wire [31:0] opb2;
wire [31:0] out_fp0;
wire [31:0] out_fp1;
wire [31:0] out_fp2;

reg wait_fp0;
reg wait_fp1;
reg wait_fp2;
wire valid_in;
//reg valid_in_pp;
wire valid_in_pp;
wire valid_in_pp1;
wire valid_in_pp2;
wire valid_in_pp3;

assign opa0 = in_w0;
assign opa1 = in_w1;
assign opa2 = in_w2;
assign opb0 = in_sigma0;
assign opb1 = in_sigma1;
assign opb2 = in_sigma2;
assign valid_in = en_sortByWeights;
divider inst_w0_sigma0
(
        .input_a(opa0),
        .input_b(opb0),
        .input_a_stb(valid_in),
        .input_b_stb(valid_in),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(out_fp0),
        .output_z_stb(rd_out_fp0),
        .input_a_ack(),
        .input_b_ack()
);
divider inst_w1_sigma1
(
        .input_a(opa1),
        .input_b(opb1),
        .input_a_stb(valid_in),
        .input_b_stb(valid_in),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(out_fp1),
        .output_z_stb(rd_out_fp1),
        .input_a_ack(),
        .input_b_ack()
);
divider inst_w2_sigma2
(
        .input_a(opa2),
        .input_b(opb2),
        .input_a_stb(valid_in),
        .input_b_stb(valid_in),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(out_fp2),
        .output_z_stb(rd_out_fp2),
        .input_a_ack(),
        .input_b_ack()
);
always @(posedge clk_i)
begin
	if(rd_out_fp0)
	wait_fp0 <= 1'b1;
	else if (valid_in_pp == 1'b1)
	wait_fp0 <= 1'b0;
	
	if(rd_out_fp1)
	wait_fp1 <= 1'b1;
	else if (valid_in_pp == 1'b1)
	wait_fp1 <= 1'b0;
	
	if(rd_out_fp2)
	wait_fp2 <= 1'b1;
	else if (valid_in_pp == 1'b1)
	wait_fp2 <= 1'b0;
	
end
assign valid_in_pp = wait_fp0&wait_fp1&wait_fp2;
assign rate0 = out_fp0;
assign rate1 = out_fp1;
assign rate2 = out_fp2;
assign valid_in_pp1 = valid_in_pp;

Compare_FP INST_COMPARE01(
		 .opA(rate0),
		 .opB(rate1),
         .result(result0)     
		);
Compare_FP INST_COMPARE12(
		 .opA(rate1),
		 .opB(rate2), 
         .result(result1)      
		);
Compare_FP INST_COMPARE02(
		 .opA(rate0),
		 .opB(rate2),
         .result(result2)     
		);
assign valid_in_pp2 = valid_in_pp1;
assign r0lessr1 = (result0 == 2'b10);
assign r1lessr2 = (result1 == 2'b10);
assign r0lessr2 = (result2 == 2'b10);
assign valid_in_pp3 = valid_in_pp2;

always @(posedge clk_i)
begin
		if(rst_i == 1'b1) begin
			sort_w0 <= 32'b0;
			sort_w1 <= 32'b0;
			sort_w2 <= 32'b0;
			
			sort_mugrey0 <= 32'b0;
			sort_mugrey1 <= 32'b0;
			sort_mugrey2 <= 32'b0;
			
			sort_sigma0 <= 32'b0;
			sort_sigma1 <= 32'b0;
			sort_sigma2 <= 32'b0;	
		end
		else if (valid_in_pp3 == 1'b1) begin
			if(r0lessr1 & r1lessr2) begin
				sort_w0 <= in_w2;
				sort_w1 <= in_w1;
				sort_w2 <= in_w0;
				
				sort_mugrey0 <= in_mugrey2;
				sort_mugrey1 <= in_mugrey1;
				sort_mugrey2 <= in_mugrey0;
				
				sort_sigma0 <= in_sigma2;
				sort_sigma1 <= in_sigma1;
				sort_sigma2 <= in_sigma0;
			end
			else if(r0lessr2 & (! r1lessr2)) begin				
				sort_w0 <= in_w1;
				sort_w1 <= in_w2;
				sort_w2 <= in_w0;
				
				sort_mugrey0 <= in_mugrey1;
				sort_mugrey1 <= in_mugrey2;
				sort_mugrey2 <= in_mugrey0;	
				
				sort_sigma0 <= in_sigma1;
				sort_sigma1 <= in_sigma2;
				sort_sigma2 <= in_sigma0;
			end
			else if( r1lessr2 & (! r0lessr2)) begin
				sort_w0 <= in_w0;
				sort_w1 <= in_w2;
				sort_w2 <= in_w1;
				
				sort_mugrey0 <= in_mugrey0;
				sort_mugrey1 <= in_mugrey2;
				sort_mugrey2 <= in_mugrey1;	
				
				sort_sigma0 <= in_sigma0;
				sort_sigma1 <= in_sigma2;
				sort_sigma2 <= in_sigma1;
			end
			else if((! r0lessr1) & r0lessr2) begin
				sort_w0 <= in_w2;
				sort_w1 <= in_w0;
				sort_w2 <= in_w1;
				
				sort_mugrey0 <= in_mugrey2;
				sort_mugrey1 <= in_mugrey0;
				sort_mugrey2 <= in_mugrey1;	
				
				sort_sigma0 <= in_sigma2;
				sort_sigma1 <= in_sigma0;
				sort_sigma2 <= in_sigma1;
			end
			else if( (! r1lessr2 ) & (! r0lessr1)) begin
				sort_w0 <= in_w0;
				sort_w1 <= in_w1;
				sort_w2 <= in_w2;
				
				sort_mugrey0 <= in_mugrey0;
				sort_mugrey1 <= in_mugrey1;
				sort_mugrey2 <= in_mugrey2;	
				
				sort_sigma0 <= in_sigma0;
				sort_sigma1 <= in_sigma1;
				sort_sigma2 <= in_sigma2;
			end
			else if( (! r0lessr2) & r0lessr1) begin
				sort_w0 <= in_w1;
				sort_w1 <= in_w0;
				sort_w2 <= in_w2;
				
				sort_mugrey0 <= in_mugrey1;
				sort_mugrey1 <= in_mugrey0;
				sort_mugrey2 <= in_mugrey2;	
				
				sort_sigma0 <= in_sigma1;
				sort_sigma1 <= in_sigma0;
				sort_sigma2 <= in_sigma2;
			end
		end
end

always @(posedge clk_i) 
begin
	rd_sortbyWeights <= valid_in_pp3;
end
endmodule
