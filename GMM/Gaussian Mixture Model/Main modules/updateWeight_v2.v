//--- bat en_updateWeight -> run -> tat en_updateWeight , tiep tuc run---
//--- check fp32 23/11/2018 --
//--- edit rd_updateWeight 19.5.2019 ---

// done 27.5
module updateWeights
(	
	clk_i, 
	rst_i,
	in_w0,
	in_w1,
	in_w2,
	en_updateWeight,
	out_w0,
	out_w1, 
	out_w2, 
	
	num,  //--- M = 0/1/2 number of model match
	rd_updateWeight
	);



//---fpu_double---
//constant add : std_logic_vector (2 downto 0) := "000";
//--constant sub : std_logic_vector (2 downto 0) := "001";
//constant mul : std_logic_vector (2 downto 0) := "001";
//constant div : std_logic_vector (2 downto 0) := "010";
input clk_i;
input rst_i;
input [31:0] in_w0;
input [31:0] in_w1;
input [31:0] in_w2;
input en_updateWeight;
output [31:0] out_w0;
output [31:0] out_w1;
output [31:0] out_w2;
input [1:0] num;
output rd_updateWeight;

wire [31:0] num_0_04;
assign  num_0_04 = 32'b00111101001000111101011100001010;
wire [31:0] num_0_96;
assign  num_0_96= 32'b00111111011101011100001010001111;
wire en_updateWeight_r;
wire [31:0] sum;
wire [31:0] sum_2of3;

wire [31:0] up_w0;
wire [31:0] up_w1;
wire [31:0] up_w2;

wire [31:0] up_w0_norm;
wire [31:0] up_w1_norm;
wire [31:0] up_w2_norm;

wire [31:0] nonup_w0;
wire [31:0] nonup_w1;
wire [31:0] nonup_w2;

wire out_nonup_w0;
wire out_nonup_w1;
wire out_nonup_w2;

wire out_up_w0;
wire out_up_w1;
wire out_up_w2;
wire out_sum;
wire out_sum_2of3;
wire out_up_w0_norm;
wire out_up_w1_norm;
wire out_up_w2_norm;
wire [31:0] sum_w0;
wire [31:0] sum_w1;
wire [31:0] sum_w2;

reg wait_0;
reg wait_1;
reg wait_2;
wire rd_done;
reg wait_w0;
reg wait_w1;
wire en_sum2of3;

// nonup_w ----
multiplier inst_nonupdate0
(
        .input_a(num_0_96),
        .input_b(in_w0),
        .input_a_stb(en_updateWeight),
        .input_b_stb(en_updateWeight),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(nonup_w0),
        .output_z_stb(out_nonup_w0),
        .input_a_ack(),
        .input_b_ack()
);
multiplier inst_nonupdate1
(
        .input_a(num_0_96),
        .input_b(in_w1),
        .input_a_stb(en_updateWeight),
        .input_b_stb(en_updateWeight),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(nonup_w1),
        .output_z_stb(out_nonup_w1),
        .input_a_ack(),
        .input_b_ack()
);
multiplier inst_nonupdate2
(
        .input_a(num_0_96),
        .input_b(in_w2),
        .input_a_stb(en_updateWeight),
        .input_b_stb(en_updateWeight),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(nonup_w2),
        .output_z_stb(out_nonup_w2),
        .input_a_ack(),
        .input_b_ack()
);

//----up_w----
adder inst_update0
(
        .input_a(num_0_04),
        .input_b(nonup_w0),
        .input_a_stb(out_nonup_w0),
        .input_b_stb(out_nonup_w0),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(up_w0),
        .output_z_stb(out_up_w0),
        .input_a_ack(),
        .input_b_ack()
);
adder inst_update1
(
        .input_a(num_0_04),
        .input_b(nonup_w1),
        .input_a_stb(out_nonup_w1),
        .input_b_stb(out_nonup_w1),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(up_w1),
        .output_z_stb(out_up_w1),
        .input_a_ack(),
        .input_b_ack()
);
adder inst_update2
(
        .input_a(num_0_04),
        .input_b(nonup_w2),
        .input_a_stb(out_nonup_w2),
        .input_b_stb(out_nonup_w2),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(up_w2),
        .output_z_stb(out_up_w2),
        .input_a_ack(),
        .input_b_ack()
);

assign sum_w0 = (num == 2'b00)? up_w0 : nonup_w0;
assign sum_w1 = (num == 2'b01)? up_w1 : nonup_w1;
assign sum_w2 = (num == 2'b10)? up_w2 : nonup_w2;
//---- sum 2 of 3 ---
always @(posedge clk_i)
begin
	if (out_up_w0)
	wait_w0 <= 1'b1;
	else if(en_sum2of3 == 1'b1)
	wait_w0 <= 1'b0;
	if (out_up_w1)
	wait_w1 <= 1'b1;
	else if(en_sum2of3 == 1'b1)
	wait_w1 <= 1'b0;	
end
assign en_sum2of3 = wait_w0&wait_w1;
adder inst_sum2of3
(
        .input_a(sum_w0),
        .input_b(sum_w1),
        .input_a_stb(en_sum2of3),
        .input_b_stb(en_sum2of3),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(sum_2of3),
        .output_z_stb(out_sum_2of3),
        .input_a_ack(),
        .input_b_ack()
);

//---- sum 3 ---
adder inst_sum3
(
        .input_a(sum_2of3),
        .input_b(sum_w2),
        .input_a_stb(out_sum_2of3),
        .input_b_stb(out_sum_2of3),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(sum),
        .output_z_stb(out_sum),
        .input_a_ack(),
        .input_b_ack()
);

//----result NORM---
divider inst_0
(
        .input_a(sum_w0),
        .input_b(sum),
        .input_a_stb(out_sum),
        .input_b_stb(out_sum),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(up_w0_norm),
        .output_z_stb(out_up_w0_norm),
        .input_a_ack(),
        .input_b_ack()
);

divider inst_1
(
        .input_a(sum_w1),
        .input_b(sum),
        .input_a_stb(out_sum),
        .input_b_stb(out_sum),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(up_w1_norm),
        .output_z_stb(out_up_w1_norm),
        .input_a_ack(),
        .input_b_ack()
);
divider inst_2
(
        .input_a(sum_w2),
        .input_b(sum),
        .input_a_stb(out_sum),
        .input_b_stb(out_sum),
        .output_z_ack(1'b1),
        .clk(clk_i),
        .rst(rst_i),
        .output_z(up_w2_norm),
        .output_z_stb(out_up_w2_norm),
        .input_a_ack(),
        .input_b_ack()
);
assign		out_w0 = up_w0_norm;
assign		out_w1 = up_w1_norm;
assign		out_w2 = up_w2_norm;
always @(posedge clk_i)
begin
	if(out_up_w0_norm )
	wait_0 <= 1'b1;
	else if (rd_done == 1'b1)
	wait_0 <= 1'b0;
	if(out_up_w1_norm )
	wait_1 <= 1'b1;
	else if (rd_done == 1'b1)
	wait_1 <= 1'b0;	
	if(out_up_w2_norm )
	wait_2 <= 1'b1;
	else if (rd_done == 1'b1)
	wait_2 <= 1'b0;	
end
assign rd_done = wait_0&wait_1&wait_2;
assign rd_updateWeight = rd_done;
endmodule