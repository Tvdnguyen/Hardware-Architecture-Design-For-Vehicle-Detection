//-- match 1 of k GMM
//---check---
//--bat en_match -> run, tat en_match---
//--- edited 22/11/2018
//---edited 23/11/2018 fp32
//--- edit 19.5

// done 27.5
module match(
	clk_i,
	rst_i,
	en_match,
	in_grey,
	in_mugrey,
	in_sigma,
	rd_match,
	out_match
	);
input clk_i;
input rst_i;
input en_match;
input [31:0] in_grey;
input [31:0] in_mugrey;
input [31:0] in_sigma;
output rd_match;
output out_match;
wire rd_done;
reg wait_result_sigma;
reg wait_subgrey;
wire [31:0] sigma;
wire [31:0] grey;
wire [31:0] mugrey;

//---(grey-mugrey)---
wire [31:0] subgrey;
//---2.5*sigma----
wire [31:0] num_2_5;
assign num_2_5 = 32'b01000000001000000000000000000000;
wire [31:0] result_sigma;

//---compare----
wire rd_compare;
wire rd_subgrey;
wire rd_result_sigma;

wire [1:0] compare;
wire [31:0] subgrey_r;
wire [31:0] sigma_r;

assign sigma = in_sigma;
assign grey = in_grey;
assign mugrey[30:0] = in_mugrey[30:0];
assign mugrey[31] = 1'b1; //-- sub
assign rd_compare = en_match;
// ---(grey-mugrey)
adder inst_sub
(
        .input_a(grey),
        .input_b(mugrey),
        .input_a_stb(rd_compare),
        .input_b_stb(rd_compare),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(subgrey),
        .output_z_stb(rd_subgrey),
        .input_a_ack(),
        .input_b_ack()
);

//---(grey-mugrey) < 2.5*sigma , 2.5 = 5/2
multiplier inst_update0
(
        .input_a(sigma),
        .input_b(num_2_5),
        .input_a_stb(rd_compare),
        .input_b_stb(rd_compare),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(result_sigma),
        .output_z_stb(rd_result_sigma),
        .input_a_ack(),
        .input_b_ack()
);

assign subgrey_r[30:0] = subgrey[30:0];// ---abs(subgrey)
assign subgrey_r[31] = 1'b0;
assign sigma_r = result_sigma;
Compare_FP  inst_compare
(
		 .opA(subgrey_r),
		 .opB(sigma_r),
         .result(compare)    
   );
always @(posedge clk_i)
begin
	if (rd_result_sigma)
	wait_result_sigma <= 1'b1;
	else if(rd_done == 1'b1)
	wait_result_sigma <= 1'b0;
	
	if(rd_subgrey) 
	wait_subgrey <= 1'b1;	
	else if(rd_done == 1'b1)
	wait_subgrey <= 1'b0;

end
assign rd_done = wait_result_sigma&wait_subgrey;
assign out_match = (compare == 2'b10)?1'b1: 1'b0;
assign rd_match = rd_done;	
endmodule