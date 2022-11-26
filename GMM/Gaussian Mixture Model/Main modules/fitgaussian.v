//--- check fp---
//--- by NTM.Linh---
//--- edited 18/5/2019
//--- edited 19.5
// edit 27.5
module fitgaussian(
		clk_i,
		rst_i,
		waddr,
		raddr,
		first_frame,
		en_fitgaussian,
		grey,
		out_mugrey0 ,
		out_mugrey1 ,
		out_mugrey2 ,
		out_w0 ,
		out_w1 ,
		out_w2 ,
		rd_fitgassian,
		isFit
		);
input clk_i;
input rst_i;
input [17:0] waddr;
input [17:0] raddr;
input first_frame;
input en_fitgaussian;
input [31:0] grey;
output [31:0] out_mugrey0;
output [31:0] out_mugrey1;
output [31:0] out_mugrey2;
output [31:0] out_w0;
output [31:0] out_w1;
output [31:0] out_w2;
output rd_fitgassian;
output isFit;
wire [31:0] constant0_3333 ;
assign constant0_3333 = 32'b00111110101010101010011001001100;
wire [31:0] constant0_1111 ;
assign constant0_1111 = 32'b00111101111000111000100001100110;
wire [31:0] constant6 ;
assign constant6 = 32'b01000000110000000000000000000000;

wire foundmatch;// -- false
wire [1:0] foundnum;
wire  [31:0] grey_r;
//---- match ---
wire en_match0;
wire en_match1;
wire en_match2;

wire rd_match0;
wire rd_match1;
wire rd_match2;

wire out_match0;
wire out_match1;
wire out_match2;

//---- updateMuSigma ---
wire en_updateMuSigma;
reg [31:0]  in_mugreyi_upmusigma;//--- updateMuSigma
reg [31:0] in_sigmai_upmusigma;//--- updateMuSigma 
wire [31:0] out_mugreyi;
wire [31:0] out_sigmai;
wire rd_updateMuSigma;
//---sortByWeights ----
wire en_sortByWeights;
wire rd_sortbyWeights;
wire [31:0] out_sort_mugrey0;//--- out
wire [31:0] out_sort_mugrey1;
wire [31:0] out_sort_mugrey2;
wire [31:0] out_sort_w0;
wire [31:0] out_sort_w1; 
wire [31:0] out_sort_w2;
wire [31:0] out_sort_sigma0;
wire [31:0] out_sort_sigma1;
wire [31:0] out_sort_sigma2;
//--- rho ---
wire en_rho;
wire [31:0] out_rho;
wire done_rho;
//--- updateWeights---
wire [31:0] w2_bf_upWeights;
wire [31:0] out_w0_upWeights;
wire [31:0] out_w1_upWeights;
wire [31:0] out_w2_upWeights;
reg wait_m0;
reg wait_m1;
reg wait_m2;
wire rd_updateWeight;
//reg en_updateWeight;
wire en_updateWeight;
reg	[31:0] final_w0;
reg [31:0] final_w1;
reg	[31:0] final_w2;
reg	[31:0] final_mugrey0;
reg	[31:0] final_mugrey1;
reg	[31:0] final_mugrey2;
reg	[31:0] final_sigma0;
reg	[31:0] final_sigma1;
reg	[31:0] final_sigma2;

wire	[31:0] in_w0;
wire 	[31:0] in_w1;
wire	[31:0] in_w2;
wire	[31:0] in_mugrey0;
wire	[31:0] in_mugrey1;
wire	[31:0] in_mugrey2;
wire	[31:0] in_sigma0;
wire	[31:0] in_sigma1;
wire	[31:0] in_sigma2;

wire	[31:0] w0_bf;
wire 	[31:0] w1_bf;
wire	[31:0] w2_bf;
wire	[31:0] mugrey0_bf;
wire	[31:0] mugrey1_bf;
wire	[31:0] mugrey2_bf;
wire	[31:0] sigma0_bf;
wire	[31:0] sigma1_bf;
wire	[31:0] sigma2_bf;
//reg rd_match0_r;
reg  rd_updateMuSigma_r;
reg  rd_updateWeight_r;
//wire first_frame: STD_LOGIC;
wire wren;
wire no_match;

	//-- state match--
assign en_match0 = en_fitgaussian;
assign en_match1 = en_fitgaussian;
assign en_match2 = en_fitgaussian;
assign grey_r = grey;
match inst_match0(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.en_match(en_match0),
		.in_grey(grey_r),
		.in_mugrey(in_mugrey0),
		.in_sigma(in_sigma0),
		.rd_match(rd_match0),   
		.out_match(out_match0) // -- 1 = match, 0 = not match (k=0 )
		);
match inst_match1(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.en_match(en_match1),
		.in_grey(grey_r),
		.in_mugrey(in_mugrey1),
		.in_sigma(in_sigma1),
		.rd_match(rd_match1),   //-- 1 = match, 0 = not match (k=0 )
		.out_match(out_match1)
		);
match inst_match2(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.en_match(en_match2),
		.in_grey(grey_r),
		.in_mugrey(in_mugrey2),
		.in_sigma(in_sigma2),
		.rd_match(rd_match2),   //-- 1 = match, 0 = not match (k=0 )
		.out_match(out_match2)
		);
assign foundnum = (out_match0 == 1'b1)?2'b00:
				(out_match1 == 1'b1)?2'b01:
				(out_match2 == 1'b1)?2'b10:2'b10;
assign foundmatch = out_match0 | out_match1 | out_match2;
assign no_match = !foundmatch;	
//---updateWeights --
always @(posedge clk_i)
begin
	if (rd_match0)
	wait_m0 <= 1'b1;
	else if(en_updateWeight == 1'b1)
	wait_m0 <= 1'b0;
	
	if (rd_match1)
	wait_m1 <= 1'b1;
	else if(en_updateWeight == 1'b1)
	wait_m1 <= 1'b0;
	
	if (rd_match2)
	wait_m2 <= 1'b1;
	else if(en_updateWeight == 1'b1)
	wait_m2 <= 1'b0;
end
assign en_updateWeight = wait_m0 & wait_m1 & wait_m2; //--- if no_match =1 -> w2 = 0.111, mugrey=grey, sigma=6 -> foundnum = 2, updateWeights
updateWeights	inst_updateweights
(	
	.clk_i(clk_i),
	.rst_i(rst_i),
	.in_w0(in_w0),
	.in_w1(in_w1),
	.in_w2(in_w2),
	.en_updateWeight(en_updateWeight),
	.out_w0(out_w0_upWeights),
	.out_w1(out_w1_upWeights),
	.out_w2(out_w2_upWeights),	
	.num(foundnum),
	.rd_updateWeight(rd_updateWeight)
	);
//---- reset all value of buffer---
assign in_w2 = (foundmatch == 1'b1)?w2_bf_upWeights:constant0_1111;	
assign in_w0 = (first_frame == 1'b0)?w0_bf:constant0_3333;
assign in_w1 = (first_frame == 1'b0)?w1_bf:constant0_3333;
assign w2_bf_upWeights =  (first_frame == 1'b0)?w2_bf:constant0_3333;

assign in_sigma0 =  (first_frame == 1'b0)?sigma0_bf:constant6;
assign in_sigma1 =  (first_frame == 1'b0)?sigma1_bf:constant6;
assign in_sigma2 =  (first_frame == 1'b0)?sigma2_bf:constant6;
assign in_mugrey0 =  (first_frame == 1'b0)?mugrey0_bf:32'b0;
assign in_mugrey1 =  (first_frame == 1'b0)?mugrey1_bf:32'b0;
assign in_mugrey2 =  (first_frame == 1'b0)?mugrey2_bf:32'b0;
assign en_sortByWeights =  (foundmatch == 1'b1)?rd_updateWeight:1'b0;
sortByWeights inst_sortbyweights(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.in_w0(out_w0_upWeights),  //--- from sortByWeights
		.in_w1(out_w1_upWeights),
		.in_w2(out_w2_upWeights),
		.in_sigma0(in_sigma0),		//--- from input
		.in_sigma1(in_sigma1),     
		.in_sigma2(in_sigma2),
		.in_mugrey0(in_mugrey0),
		.in_mugrey1(in_mugrey1),
		.in_mugrey2(in_mugrey2),
		.en_sortByWeights(en_sortByWeights),
		.sort_mugrey0(out_sort_mugrey0),
		.sort_mugrey1(out_sort_mugrey1),
		.sort_mugrey2(out_sort_mugrey2),
		.sort_w0(out_sort_w0),
		.sort_w1(out_sort_w1),
		.sort_w2(out_sort_w2),
		.sort_sigma0(out_sort_sigma0),
		.sort_sigma1(out_sort_sigma1),
		.sort_sigma2(out_sort_sigma2),
		.rd_sortbyWeights(rd_sortbyWeights)
		);
//---- calculate rho ---
always @(posedge clk_i)
begin
	if((foundmatch == 1'b1)&( foundnum == 2'b00)) begin
		in_mugreyi_upmusigma <= out_sort_mugrey0;	
		in_sigmai_upmusigma <= out_sort_sigma0;
	end
	else if((foundmatch == 1'b1)&( foundnum == 2'b01)) begin
		in_mugreyi_upmusigma <= out_sort_mugrey1;	
		in_sigmai_upmusigma <= out_sort_sigma1;
	end
	else if((foundmatch == 1'b1)&( foundnum == 2'b10)) begin
		in_mugreyi_upmusigma <= out_sort_mugrey2;	
		in_sigmai_upmusigma <= out_sort_sigma2;
	end
	else begin
		in_mugreyi_upmusigma <= 32'b0;	
		in_sigmai_upmusigma <= 32'b0;
	end
end	
pp inst_pp(
			.clk_i(clk_i),
			.indata(rd_sortbyWeights),
			.outdata(en_rho)
			);
//assign en_rho = rd_sortbyWeights;	
rho  inst_rho(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.en_rho(en_rho),
		.grey(grey_r),
		.sigma(in_sigmai_upmusigma),
		.mugrey(in_mugreyi_upmusigma),
		.out_rho(out_rho),
		.done_rho(done_rho)
		);
//----- update Mu Sigma---
assign en_updateMuSigma = done_rho;
updateMuSigma inst_updateMuSigma(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.en_updateMuSigma(en_updateMuSigma),
		.rho(out_rho),			//--- from rho
		.grey(grey_r),
		.in_mugreyi(in_mugreyi_upmusigma),
		.in_sigmai(in_sigmai_upmusigma),
		.rd_updateMuSigma(rd_updateMuSigma),
		.out_mugreyi(out_mugreyi),
		.out_sigmai(out_sigmai)
	);
	
always  @(posedge clk_i)
begin
	if(rst_i ==1'b1) begin
		final_w0 <= 32'b0;
		final_w1 <= 32'b0;
		final_w2 <= 32'b0;
		final_mugrey0 <= 32'b0;
		final_mugrey1 <= 32'b0;
		final_mugrey2 <= 32'b0;
		final_sigma0 <= 32'b0;
		final_sigma1 <= 32'b0;
		final_sigma2 <= 32'b0;
	end	
	else if((foundmatch == 1'b1)& (rd_updateMuSigma == 1'b1)) begin
		if( foundnum == 2'b00) begin			
		final_w0 <= out_sort_w0;
		final_w1 <= out_sort_w1;
		final_w2 <= out_sort_w2;
		final_mugrey0 <= out_mugreyi;
		final_mugrey1 <= out_sort_mugrey1;
		final_mugrey2 <= out_sort_mugrey2;
		final_sigma0 <= out_sigmai;
		final_sigma1 <= out_sort_sigma1;
		final_sigma2 <= out_sort_sigma2;
		end		
		else if( foundnum == 2'b01) begin		
		final_w0 <= out_sort_w0;
		final_w1 <= out_sort_w1;
		final_w2 <= out_sort_w2;
		final_mugrey0 <= out_sort_mugrey0;
		final_mugrey1 <= out_mugreyi;
		final_mugrey2 <= out_sort_mugrey2;
		final_sigma0 <= out_sort_sigma0;
		final_sigma1 <= out_sigmai;
		final_sigma2 <= out_sort_sigma2;
		end
		else if( foundnum == 2'b10) begin
		final_w0 <= out_sort_w0;
		final_w1 <= out_sort_w1;
		final_w2 <= out_sort_w2;
		final_mugrey0 <= out_sort_mugrey0;
		final_mugrey1 <= out_sort_mugrey1;
		final_mugrey2 <= out_mugreyi;
		final_sigma0 <= out_sort_sigma0;
		final_sigma1 <= out_sort_sigma1;
		final_sigma2 <= out_sigmai;
		end
	end
	else if ((foundmatch == 1'b0) & (rd_updateWeight == 1'b1)) begin				//---- unmatch w2 = 0.1111 -> updateWeights, mugrey2 = grey, sigma2 = 6
		final_w0 <= out_w0_upWeights;
		final_w1 <= out_w1_upWeights;
		final_w2 <= out_w2_upWeights;
		final_mugrey0 <= in_mugrey0;
		final_mugrey1 <= in_mugrey1;
		final_mugrey2 <= grey_r;
		final_sigma0 <= in_sigma0;
		final_sigma1 <= in_sigma1;
		final_sigma2 <= constant6;
	end
end


always @(posedge clk_i)
begin
	rd_updateMuSigma_r <= rd_updateMuSigma;
	rd_updateWeight_r <= rd_updateWeight;
end


assign isFit = !no_match;
assign rd_fitgassian = (no_match == 1'b1)?rd_updateWeight_r:rd_updateMuSigma_r;

assign out_mugrey0 = final_mugrey0;  //--- for updateBFM
assign out_mugrey1 = final_mugrey1;
assign out_mugrey2 = final_mugrey2;
assign out_w0 = final_w0;
assign out_w1 = final_w1;
assign out_w2 = final_w2;

assign wren = (no_match == 1'b1)?rd_updateWeight_r:rd_updateMuSigma_r;				
	
     memory     inst_1(
        //------------------------------------------------
        .clk_drv(clk_i),
        .enable (1'b1),
        .reset_n(rst_i),
        //------------------------------------------------
        .sdpmem_wrena(wren),
        .sdpmem_wraddr(waddr),
        .sdpmem_wrdata(final_mugrey0),   //--stage1_out_data_reg
        //------------------------------------------------
        .sdpmem_rdaddr(raddr),
        .sdpmem_rddata(mugrey0_bf)
    );
	 memory    inst_2  (
        //------------------------------------------------
        .clk_drv(clk_i),
        .enable (1'b1),
        .reset_n(rst_i),
       // ------------------------------------------------
        .sdpmem_wrena(wren),
        .sdpmem_wraddr(waddr),
        .sdpmem_wrdata(final_mugrey1),   //--stage1_out_data_reg
        //------------------------------------------------
        .sdpmem_rdaddr(raddr),
        .sdpmem_rddata(mugrey1_bf)
    );
	 memory     inst_3(
        //------------------------------------------------
        .clk_drv(clk_i),
        .enable (1'b1),
        .reset_n(rst_i),
        //------------------------------------------------
        .sdpmem_wrena(wren),
        .sdpmem_wraddr(waddr),
        .sdpmem_wrdata(final_mugrey2),   //--stage1_out_data_reg
        //------------------------------------------------
        .sdpmem_rdaddr(raddr),
        .sdpmem_rddata(mugrey2_bf)
    );
	 memory     inst_4(
        //------------------------------------------------
        .clk_drv(clk_i),
        .enable (1'b1),
        .reset_n(rst_i),
        //------------------------------------------------
        .sdpmem_wrena(wren),
        .sdpmem_wraddr(waddr),
        .sdpmem_wrdata(final_sigma0),   //--stage1_out_data_reg
       // ------------------------------------------------
        .sdpmem_rdaddr(raddr),
        .sdpmem_rddata(sigma0_bf)
    );
	 memory     inst_5(
        //------------------------------------------------
        .clk_drv(clk_i),
        .enable (1'b1),
        .reset_n(rst_i),
        //------------------------------------------------
        .sdpmem_wrena(wren),
        .sdpmem_wraddr(waddr),
        .sdpmem_wrdata(final_sigma1),   //--stage1_out_data_reg
        //------------------------------------------------
        .sdpmem_rdaddr(raddr),
        .sdpmem_rddata(sigma1_bf)
    );
	 memory     inst_6(
        //------------------------------------------------
        .clk_drv(clk_i),
        .enable (1'b1),
        .reset_n(rst_i),
        //------------------------------------------------
        .sdpmem_wrena(wren),
        .sdpmem_wraddr(waddr),
        .sdpmem_wrdata(final_sigma2),   //--stage1_out_data_reg
        //------------------------------------------------
        .sdpmem_rdaddr(raddr),
        .sdpmem_rddata(sigma2_bf)
    );
	 memory     inst_7(
        //------------------------------------------------
        .clk_drv(clk_i),
        .enable (1'b1),
        .reset_n(rst_i),
        //------------------------------------------------
        .sdpmem_wrena(wren),
        .sdpmem_wraddr(waddr),
        .sdpmem_wrdata(final_w0),   //--stage1_out_data_reg
        //------------------------------------------------
        .sdpmem_rdaddr(raddr),
        .sdpmem_rddata(w0_bf)
    );
	 memory    inst_8 (
        //------------------------------------------------
        .clk_drv(clk_i),
        .enable (1'b1),
        .reset_n(rst_i),
        //------------------------------------------------
        .sdpmem_wrena(wren),
        .sdpmem_wraddr(waddr),
        .sdpmem_wrdata(final_w1),   //--stage1_out_data_reg
        //------------------------------------------------
        .sdpmem_rdaddr(raddr),
        .sdpmem_rddata(w1_bf)
    );
	 memory     inst_9(
       // ------------------------------------------------
        .clk_drv(clk_i),
        .enable (1'b1),
        .reset_n(rst_i),
       // ------------------------------------------------
        .sdpmem_wrena(wren),
        .sdpmem_wraddr(waddr),
        .sdpmem_wrdata(final_w2),   //--stage1_out_data_reg
       // ------------------------------------------------
        .sdpmem_rdaddr(raddr),
        .sdpmem_rddata(w2_bf)
    );
  
endmodule
