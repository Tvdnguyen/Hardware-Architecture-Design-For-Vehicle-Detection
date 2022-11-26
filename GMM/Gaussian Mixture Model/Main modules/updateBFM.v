//--- 11/18/ 2019 By NTM.Linh
//---check fp ---
//---check fp 2---
//--- updateBFM----
//--- edited 22/11/2019 By NTM.Linh
//--- edit rd_done ----
// - 27.5
// edit 31.5
module updateBFM(
	clk_i,
	rst_i,
	en_updateBFM,
	in_w0,
	in_w1,
	in_w2,
	grey,
	in_mugrey0,
	in_mugrey1,
	in_mugrey2,
	isFit,
	fore,
	rd_updateBFM
	);
input clk_i;
input en_updateBFM;
input rst_i;
input [31:0] in_w0;
input [31:0] in_w1;
input [31:0] in_w2;
input [31:0] grey;
input [31:0] in_mugrey0;
input [31:0] in_mugrey1;
input [31:0] in_mugrey2;
input isFit;
output [7:0] fore;
output rd_updateBFM;
wire [31:0] constant30;
wire [31:0] constant0_5; 
wire [31:0] add_w0w1;
wire [31:0] add_w0w1w2;
//---- compare w ---

wire [1:0] result_w0;
wire [1:0] result_w0w1;
//---- compare grey ---
wire [31:0] grey_bar;
wire [31:0] sub_grey;
wire [1:0] result_updateBFM;
wire rd_sub;
wire [31:0] greyVal0;
wire [31:0] greyVal1;
wire [31:0] greyVal2; 
wire [31:0] greyVal01;
wire [31:0] greyVal012;
wire [31:0] greyVal;
wire [31:0] final_w0w1;
wire [31:0] final_w0w1w2;
reg en_updateBFM_r;
wire rd_add_w0w1;
wire rd_add_w0w1w2;
wire rd_final_w0w1;
wire rd_final_w0w1w2;
wire rd_sub_grey;
reg rd_done;
reg wait_greyVal0;
reg wait_greyVal1;
wire en_sum2of3;
reg wait_greyVal01;
reg wait_w1w0;
reg wait_w1w0w2;
reg wait_greyVal012;
wire en_w1w0;
wire en_w1w0w2;
assign constant30 = 32'b01000001111100000000000000000000;
assign constant0_5 = 32'b00111111000000000000000000000000;
multiplier w0mugrey //--- --- w*mugrey
(
        .input_a(in_w0),
        .input_b(in_mugrey0),
        .input_a_stb(en_updateBFM_r),
        .input_b_stb(en_updateBFM_r),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(greyVal0),
        .output_z_stb(rd_greyVal0),
        .input_a_ack(),
        .input_b_ack()
);

multiplier w1mugrey //--- --- w*mugrey
(
        .input_a(in_w1),
        .input_b(in_mugrey1),
        .input_a_stb(en_updateBFM_r),
        .input_b_stb(en_updateBFM_r),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(greyVal1),
        .output_z_stb(rd_greyVal1),
        .input_a_ack(),
        .input_b_ack()
);
multiplier w2mugrey //--- --- w*mugrey
(
        .input_a(in_w2),
        .input_b(in_mugrey2),
        .input_a_stb(en_updateBFM_r),
        .input_b_stb(en_updateBFM_r),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(greyVal2),
        .output_z_stb(rd_greyVal2),
        .input_a_ack(),
        .input_b_ack()
);
//---- mul w*mugrey + w*mugrey---
always @(posedge clk_i)
begin
	if (rst_i == 1'b1) begin
		wait_greyVal0 <= 1'b0;
		wait_greyVal1 <= 1'b0;
	end
	else begin
		if (rd_greyVal0)
		wait_greyVal0 <= 1'b1;
		else if(en_sum2of3 == 1'b1)
		wait_greyVal0 <= 1'b0;
		if (rd_greyVal1)   // first (rd_greyVal0 | rd_greyVal1) = 1-> en_sum2of3 =0, wait_1 =1
		wait_greyVal1 <= 1'b1;
		else if(en_sum2of3 == 1'b1)
		wait_greyVal1 <= 1'b0;
	end
end
assign en_sum2of3 = wait_greyVal0&wait_greyVal1;
adder sum2of3
(
        .input_a(greyVal0),
        .input_b(greyVal1),
        .input_a_stb(en_sum2of3),
        .input_b_stb(en_sum2of3),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(greyVal01),
        .output_z_stb(rd_greyVal01),
        .input_a_ack(),
        .input_b_ack()
);

adder sum3
(
        .input_a(greyVal01),
        .input_b(greyVal2),
        .input_a_stb(rd_greyVal01),
        .input_b_stb(rd_greyVal01),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(greyVal012),
        .output_z_stb(rd_greyVal012),
        .input_a_ack(),
        .input_b_ack()
);
// w0+w1
adder w0w1
(
        .input_a(in_w0),
        .input_b(in_w1),
        .input_a_stb(en_updateBFM_r),
        .input_b_stb(en_updateBFM_r),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(add_w0w1),
        .output_z_stb(rd_add_w0w1),
        .input_a_ack(),
        .input_b_ack()
);
always @(posedge clk_i)
begin
	if (rst_i == 1'b1) begin
		wait_greyVal01 <= 1'b0;
		wait_w1w0 <= 1'b0;
	end
	else begin
		if (rd_greyVal01)
		wait_greyVal01 <= 1'b1;
		else if(en_w1w0 == 1'b1)
		wait_greyVal01 <= 1'b0;
		
		if (rd_add_w0w1)
		wait_w1w0 <= 1'b1;
		else if(en_w1w0 == 1'b1)
		wait_w1w0 <= 1'b0;
	end
end
assign en_w1w0 = wait_greyVal01&wait_w1w0;
divider w1w0  //--- (w*mugrey + w*mugrey )/(w+w)
(
        .input_a(greyVal01),
        .input_b(add_w0w1),
        .input_a_stb(en_w1w0),
        .input_b_stb(en_w1w0),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(final_w0w1),
        .output_z_stb(rd_final_w0w1),
        .input_a_ack(),
        .input_b_ack()
);

adder w0w1w2
(
        .input_a(add_w0w1),
        .input_b(in_w2),
        .input_a_stb(rd_add_w0w1),
        .input_b_stb(rd_add_w0w1),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(add_w0w1w2),
        .output_z_stb(rd_add_w0w1w2),
        .input_a_ack(),
        .input_b_ack()
);
always @(posedge clk_i)
begin
	if (rst_i == 1'b1) begin
		wait_w1w0w2 <= 1'b0;
		wait_greyVal012 <= 1'b0;
	end
	else begin
		if (rd_add_w0w1w2 )
		wait_w1w0w2 <= 1'b1;
		else if(en_w1w0w2 == 1'b1) 
		wait_w1w0w2 <= 1'b0;
		if (rd_greyVal012 )
		wait_greyVal012 <= 1'b1;
		else if(en_w1w0w2 == 1'b1) 
		wait_greyVal012 <= 1'b0;
	end
end
assign en_w1w0w2 = wait_w1w0w2&wait_greyVal012;
divider w1w0w2  //--- (w*mugrey + w*mugrey + w*mugrey )/(w+w+w)
(
        .input_a(greyVal012),
        .input_b(add_w0w1w2),
        .input_a_stb(en_w1w0w2),
        .input_b_stb(en_w1w0w2),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(final_w0w1w2),
        .output_z_stb(rd_final_w0w1w2),
        .input_a_ack(),
        .input_b_ack()
);
Compare_FP compw0(
		 .opA(in_w0),
		 .opB(constant0_5),
         .result(result_w0)     
		);
Compare_FP compw0w1(
		 .opA(add_w0w1),
		 .opB(constant0_5),
         .result(result_w0w1)     
		);

assign greyVal = ((result_w0 == 2'b01) | (result_w0 == 2'b00))?in_mugrey0: 
				((result_w0w1 == 2'b01) | (result_w0w1 == 2'b00))?final_w0w1:final_w0w1w2;
assign 	grey_bar = {1'b1,grey[30:0]};		
adder subgrey
(
        .input_a(greyVal),
        .input_b(grey_bar),
        .input_a_stb(rd_final_w0w1w2),
        .input_b_stb(rd_final_w0w1w2),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(sub_grey),
        .output_z_stb(rd_sub_grey),
        .input_a_ack(),
        .input_b_ack()
);
Compare_FP INST_COMPARE30(
		 .opA({1'b0,sub_grey[30:0]}),
		 .opB(constant30),		 
         .result(result_updateBFM)     
	);
always @(posedge clk_i)
begin
	if (rst_i == 1'b1) begin
		rd_done <= 1'b0;
		en_updateBFM_r <= 1'b0;
	end
	else if (en_updateBFM == 1'b1)	begin
		rd_done <= !isFit;
		en_updateBFM_r <= (isFit)&en_updateBFM;
	end
	else begin
		rd_done <= 1'b0;
		en_updateBFM_r <= 1'b0;
	end 
end 
assign rd_sub = rd_sub_grey;
assign fore = ((rd_done == 1'b1) |(result_updateBFM == 2'b01))? 8'b11111111: 8'b00000000;
assign rd_updateBFM = rd_sub | rd_done; 
endmodule

