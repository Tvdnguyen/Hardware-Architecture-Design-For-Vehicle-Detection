//write by Thang
// 27.05.2019
// edit 28.5
module top_trafficdetect(
	clk,
    rst_n,
    data_in,
    valid_in,
    ready_out,
    sop_in,
    eop_in,
    data_out,
    valid_out,
    ready_in,
	sop_out,
    eop_out
);
	input clk;
    input rst_n ;
    // Sink side
    input [23:0] data_in;
    input valid_in ;
    output reg ready_out;
    input sop_in;
    input eop_in;
    // Source side
    output [7:0] data_out;
    output valid_out;
    input ready_in ;
	output sop_out;
    output eop_out;
	
	//wires
	wire rst;

	wire [7:0] fifo1_data_in_w ;
	wire [7:0] fifo1_data_out_w ;
	wire fifo1_read_in_w ;
	wire fifo1_write_in_w;
	wire fifo1_empty_out_w ; 
	wire fifo1_full_out_w ;
	wire [7:0] fifo2_data_out_w;
	wire fifo2_read_in_w;
	wire fifo2_write_in_w ;
	wire fifo2_empty_out_w;
	wire fifo2_full_out_w ;
	// black white---
	wire out_valid_gray_w;
	wire [7:0] out_data_gray_w;
	// INterger to fp---
	reg stage1_out_valid_reg;
	wire [31:0] fifo1_data_out_w32;
	reg [31:0] stage1_out_data_reg32;

	//------------------------

	wire result_vt_valid_w;
	wire rd_fitgassian;
	wire rd_updateBFM;
	wire [31:0] out_mugrey0;
	wire [31:0] out_mugrey1;
	wire [31:0] out_mugrey2;
	wire [31:0] out_w0;
	wire [31:0] out_w1;
	wire [31:0] out_w2;
	wire isFit;
	wire [7:0] fore;
	wire [7:0] result_fore;

	wire [17:0] MAX_COUNT;
	wire [17:0] NUM_PIXEL;
	reg [17:0] count;
	reg [17:0] w_address_reg;
	reg [17:0] r_address_reg;
	wire first_frame;
	wire first_frame_addr;
	wire rd_fitgassian_pp;
	//constant
	assign MAX_COUNT = 18'b100101011111111111; //153599	
	assign NUM_PIXEL = 18'b010010110000000000;	//76800
	//assign count = 18'd0; //0
	
	
	//---------------------------------------------------------------------------------------------
	assign rst = !rst_n;
	
	do_black_white inst_do_black_white(
		//--- valid_in ( data 1 pixel available)
		.r_data_in (data_in[7:0]),	//-- Sink side
		.g_data_in (data_in[15:8]), 
		.b_data_in (data_in[23:16]), 
		.valid_in  (valid_in), 
		
		.data_out (out_data_gray_w),  //-- Source side
		.valid_out (out_valid_gray_w)
	);
	
	
	//----Architecture: Fifo for storing the input data ---
	//------------------------------------
	background_subtraction_using_GMM_project_fifo
    #(
        .WIDTH_IN       (8                             			),
        .WIDTH_OUT      (8                            			 ),
        .DEPTH          (8                                      )
    )
    inst_fifo
    (
        // inputs
        .clk            (clk                                    ),
        .reset_n        (rst_n	),
        .read_en        (fifo1_read_in_w                        ),
        .write_en       (fifo1_write_in_w                       ),
        .datain         (fifo1_data_in_w                        ),

        //outputs
        .dataout        (fifo1_data_out_w                       ),
        .fifo_count     (),
        .empty          (fifo1_empty_out_w                      ),
        .full           (fifo1_full_out_w                       )
    );
	//---------------------------------------
	
	assign fifo1_write_in_w =  out_valid_gray_w &(! fifo1_full_out_w);
	assign fifo1_data_in_w  =   out_data_gray_w;
	//--ready_out           <=   not fifo1_full_out_w;
	assign fifo1_read_in_w 	=   !fifo1_empty_out_w;	//--- valid_in 1 pixel, read 1 pixel , -> fifo depth = 2??
	always@( posedge clk) begin
			if(rst == 1'b1) ready_out <= !fifo1_full_out_w;
			else ready_out <= rd_fitgassian;
	
	end
	
	interger_FP inst_grey64(
		 .in_number (fifo1_data_out_w),
         .fp_number (fifo1_data_out_w32)
	);
	
	//---Registerring the data
	always @(posedge clk) begin
		if( rst == 1'b1) 
			stage1_out_data_reg32 <= 32'b0;
		else if (fifo1_read_in_w == 1'b1) 
			stage1_out_data_reg32 <=  fifo1_data_out_w32;       
				
	end
	
	
	//-- Registerring the valid
	always @(posedge clk) begin
		if(rst == 1'b1 ) stage1_out_valid_reg    <=  1'b0;	
		else stage1_out_valid_reg    <=  fifo1_read_in_w;
	end
	
	//------------write------

	always @(posedge clk) begin	
		if(rst == 1'b1 ) w_address_reg   <= 18'b0;     
		else if(rd_fitgassian_pp == 1'b1) begin
			if ( w_address_reg == MAX_COUNT ) w_address_reg <= 18'd0;
			else w_address_reg <= w_address_reg + 1;
		end
	end
	
	//-------*****************----
	//-------count first_frame----
	always@(posedge clk) begin
		if(rst == 1'b1) count <= 18'b0;
		else if (rd_fitgassian == 1'b1)
			count <= (count == MAX_COUNT) ? (NUM_PIXEL+1):count +1;
	end
	assign first_frame_addr =  (count <= NUM_PIXEL)? 1'b1 : 1'b0;
	assign first_frame =  (count < NUM_PIXEL)? 1'b1 : 1'b0;
	
	//-----------read data-------
	always @(posedge clk) begin
			if(rst == 1'b1) r_address_reg   <=  18'b0;        
			else if((first_frame_addr == 1'b0) & (rd_fitgassian_pp == 1'b1)) begin
				if (r_address_reg == MAX_COUNT) r_address_reg   <=  18'b0;
				else r_address_reg <= r_address_reg + 1;
			end		
	end 
		
	
	//--- Architecture: Counting the data for controlling the write read operation

	fitgaussian inst_fitgaussian(
			.clk_i (clk),
			.rst_i (rst),
			.waddr (w_address_reg),
			.raddr (r_address_reg),
			.first_frame (first_frame),
			.en_fitgaussian (stage1_out_valid_reg),
			.grey (stage1_out_data_reg32),
			.out_mugrey0 (out_mugrey0),
			.out_mugrey1 (out_mugrey1),
			.out_mugrey2 (out_mugrey2),
			.out_w0 (out_w0),
			.out_w1 (out_w1),
			.out_w2 (out_w2),
			.rd_fitgassian (rd_fitgassian),
			.isFit (isFit)
	);
pp pp_rdfit(.clk_i(clk),.indata(rd_fitgassian),.outdata(rd_fitgassian_pp));		
	updateBFM inst_upBFM(
		.clk_i (clk),
		.rst_i (rst),
		.en_updateBFM (rd_fitgassian),
		.in_w0 (out_w0),
		.in_w1 (out_w1),
		.in_w2 (out_w2),
		.grey (stage1_out_data_reg32),
		.in_mugrey0 (out_mugrey0),
		.in_mugrey1 (out_mugrey1),
		.in_mugrey2 (out_mugrey2),
		.isFit (isFit),
		.fore (fore),
		.rd_updateBFM (rd_updateBFM)
		);
	assign result_vt_valid_w = rd_updateBFM; 
	assign result_fore = fore;
	
	////////////////////////////
	background_subtraction_using_GMM_project_fifo
    #(
        .WIDTH_IN       (8                             ),
        .WIDTH_OUT      (8                             ),
        .DEPTH          (8                                      )
    )
    inst_fifo_out
    (
        // inputs
        .clk            (clk                                    ),
        .reset_n        (rst_n	),
        .read_en        (fifo2_read_in_w                        ),
        .write_en       (result_vt_valid_w                       ),
        .datain         (result_fore                        ),

        //outputs
        .dataout        (fifo2_data_out_w                       ),
        .fifo_count     (),
        .empty          (fifo2_empty_out_w                      ),
        .full           (fifo2_full_out_w                       )
    );
	///////////////////////////
	assign fifo2_read_in_w     =   ready_in & (! fifo2_empty_out_w);
	assign data_out            =   fifo2_data_out_w;
	assign valid_out           =   fifo2_read_in_w;
  
endmodule
