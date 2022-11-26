
//***********************************************************************************************//
//  File name   : background_subtraction_using_delta_sigma_argorithm_project.v
//  Module      : background_subtraction_using_delta_sigma_argorithm_project
//  Project     : background_subtraction_using_delta_sigma_argorithm_project
//  Author      :
//  Email       :
//  Description :
//  ICDREC Confidential
//  All rights reserved
//  Copyright (C) 2016
//***********************************************************************************************//
`timescale 1ns / 1ns
module background_subtraction_using_delta_sigma_argorithm_project_ASM
(
    // System signals
    clk,
    rst_n,

    // Sink side
    data_in,
    valid_in,
    ready_out,
    sop_in,
    eop_in,

    // Source side
    data_out,
    valid_out,
    ready_in,
    sop_out,
    eop_out

    //  RAM1 AMM
    //ram1_waitrequest_in,
    //ram1_address_out,
    //ram1_read_out,
    //ram1_write_out,
    //ram1_write_data_out,
    //ram1_rdata_valid_in,
    //ram1_rdata_in,
    //ram1_size_out
);

    //*******************************************************************************************//
    //                                      Parameters                                           //
    //*******************************************************************************************//
    parameter   DATA_WIDTH          =   8;
    parameter   ADDR_WIDTH          =   23;
    parameter   IMAGE_WIDTH         =   320;
    parameter   IMAGE_HEIGHT        =   240;
    parameter   N_FACTOR            =   4;
    
    //*******************************************************************************************//
    //                                      Localparams                                          //
    //*******************************************************************************************//
    localparam  IN_WIDTH            =   DATA_WIDTH*3;
    localparam  OUT_WIDTH           =   DATA_WIDTH;
    localparam  NUM_PIXEL_EACH_FRAME=   IMAGE_WIDTH*IMAGE_HEIGHT;
    localparam  MAX_COUNTER         =   2*IMAGE_WIDTH*IMAGE_HEIGHT - 1;
    localparam  MAX_WRITE_COUNT     =   NUM_PIXEL_EACH_FRAME - 1;
    localparam  MAX_READ_COUNT      =   NUM_PIXEL_EACH_FRAME - 1;
    
    localparam  ADDRWIDTH_c         = clog2b (2*NUM_PIXEL_EACH_FRAME);
     localparam  ADDRWIDTH2_c         = clog2b (NUM_PIXEL_EACH_FRAME);
    //*******************************************************************************************//
    //                                      Inputs                                               //
    //*******************************************************************************************//
    // System signals
    input                       clk;
    input                       rst_n;
    
    // Sink side
    input   [IN_WIDTH-1:0]      data_in;
    input                       valid_in;
    input                       sop_in,
                                eop_in;

    output                      ready_out;
    
    // Source side
    output  [OUT_WIDTH-1:0]     data_out;
    output                      valid_out;
    input                       ready_in;
    output                      sop_out,
                                eop_out;

    
    //  RAM1 AMM
    //input                       ram1_waitrequest_in;
    //output   [ADDR_WIDTH-1:0]   ram1_address_out;
    //output                      ram1_read_out;
    //output                      ram1_write_out;
    //output  [31:0]              ram1_write_data_out;
    //input                       ram1_rdata_valid_in;
    //input   [31:0]  */+*
 
    //output  [3:0]               ram1_size_out;
    
    //*******************************************************************************************//
    //                                     Outputs                                               //
    //*******************************************************************************************//
    
    
    //*******************************************************************************************//
    //                                     Signal declarations                                   //
    //*******************************************************************************************//
    // Wire declarations
    wire    [DATA_WIDTH-1:0]    out_data_gray_w;
    wire                        out_valid_gray_w;
    wire    [DATA_WIDTH-1:0]    fifo1_data_in_w;
    wire    [DATA_WIDTH-1:0]    fifo1_data_out_w;
    wire                        fifo1_read_in_w;
    wire                        fifo1_write_in_w;
    wire                        fifo1_empty_out_w;
    wire                        fifo1_full_out_w;
    wire    [DATA_WIDTH-1:0]    fifo2_data_out_w;
    wire                        fifo2_read_in_w;
    wire                        fifo2_write_in_w;
    wire                        fifo2_empty_out_w;
    wire                        fifo2_full_out_w;
    wire                        read_enable_w;
    wire    [DATA_WIDTH-1:0 ]   r_data_out_w;
    wire                        result_different_frame_w;
    wire                        result_different_frame_valid_w;
    wire    [DATA_WIDTH-1:0]    result_mt_w;
    wire    [DATA_WIDTH-1:0]    next_frame_in_reg;
    wire    [DATA_WIDTH-1:0]    current_frame_in_reg;
    wire                        valid_frame_in_reg;
    wire    [DATA_WIDTH-1:0]    result_dt_w;
    wire                        result_dt_valid_w;
    wire    [DATA_WIDTH-1:0 ]   r_data_out2_w;
    wire                        result_different_frame_vt_w;
    wire                        result_different_frame_vt_valid_w;
    wire    [DATA_WIDTH-1:0]    next_frame_vt_in_reg;
    wire    [DATA_WIDTH-1:0]    current_frame_vt_in_reg;
    wire    [DATA_WIDTH-1:0]    result_vt_w;
    wire                        result_vt_valid_w;
    wire                        valid_frame_vt_in_reg;

    // Register declarations
    reg     [DATA_WIDTH-1:0]    stage1_out_data_reg;
    reg                         stage1_out_valid_reg;
    reg     [ADDRWIDTH_c-1:0]   counter0_frame_reg;
    reg     [ADDRWIDTH_c-1:0]   w_address_reg;
    reg     [ADDRWIDTH_c-1:0]   r_address_reg;
    reg                         read_enable_reg;
    reg     [DATA_WIDTH-1:0]    result_vt_reg;
    wire    [DATA_WIDTH-1:0]    result_et_w;
    //wire                        result_et_valid_w;
    reg                         result_et_valid_w;
    reg                         second_frame;
    reg     [7:0]               result_et_buf;
    wire    [DATA_WIDTH-1:0]        Mt_update ;
    //*******************************************************************************************//
    //                     Architecture: Converting from the rgb input to grayscale              //
    //*******************************************************************************************//
    background_subtraction_using_delta_sigma_argorithm_project_rbg2gray
    #(
        .DATA_WIDTH     (DATA_WIDTH                             )
    )
    dut_rgb2gray
    (
        // Sink side
        .r_data_in      (data_in[DATA_WIDTH-1:0]                ),
        .g_data_in      (data_in[2*DATA_WIDTH-1:DATA_WIDTH]     ),
        .b_data_in      (data_in[3*DATA_WIDTH-1:2*DATA_WIDTH]   ),
        .valid_in       (valid_in                               ),

        // Source side
        .data_out       (out_data_gray_w                        ),
        .valid_out      (out_valid_gray_w                       )
    );
    
    //*******************************************************************************************//
    //                             Architecture: Fifo for storing the input data                 //
    //*******************************************************************************************//
    background_subtraction_using_delta_sigma_argorithm_project_fifo
    #(
        .WIDTH_IN       (DATA_WIDTH                             ),
        .WIDTH_OUT      (DATA_WIDTH                             ),
        .DEPTH          (8                                      )
    )
    dut_storing_data_in
    (
        // inputs
        .clk            (clk                                    ),
        .reset_n        (rst_n  ),
        .read_en        (fifo1_read_in_w                        ),
        .write_en       (fifo1_write_in_w                       ),
        .datain         (fifo1_data_in_w                        ),

        //outputs
        .dataout        (fifo1_data_out_w                       ),
        .fifo_count     (),
        .empty          (fifo1_empty_out_w                      ),
        .full           (fifo1_full_out_w                       )
    );
    
    assign  fifo1_write_in_w    =   out_valid_gray_w && (~fifo1_full_out_w);
    assign  fifo1_data_in_w     =   out_data_gray_w;
    assign  ready_out           =   ~fifo1_full_out_w;
    assign  fifo1_read_in_w     =   ~fifo1_empty_out_w;
    
    //*******************************************************************************************//
    //                             Architecture: Registerring the output of fifo                 //
    //*******************************************************************************************//
    // Registerring the data
    always@(posedge clk, negedge rst_n)
    begin
        if(rst_n==1'b0) begin
            stage1_out_data_reg     <=  {DATA_WIDTH{1'b0}};
        end
        else if(fifo1_read_in_w==1'b1) begin
            stage1_out_data_reg     <=  fifo1_data_out_w;
        end
    end
    
    // Registerring the valid
    always@(posedge clk, negedge rst_n)
    begin
        if(rst_n==1'b0) begin
            stage1_out_valid_reg    <=  1'b0;
        end
        else begin
            stage1_out_valid_reg    <=  fifo1_read_in_w;
        end
    end
    
    //*******************************************************************************************//
    //            Architecture: Counting the data for controlling the write read operation       //
    //*******************************************************************************************//
    always@(posedge clk, negedge rst_n)
    begin
        if(rst_n==1'b0) begin
            w_address_reg   <=  {ADDRWIDTH_c{1'b0}};
        end
        else if(stage1_out_valid_reg==1'b1) begin
            w_address_reg   <=  (w_address_reg==MAX_COUNTER[ADDRWIDTH_c-1:0])?
                                {ADDRWIDTH_c{1'b0}}: w_address_reg + 1'b1;
        end
    end
    
    //*******************************************************************************************//
    //                                         Architecture: Using for test                      //
    //*******************************************************************************************//
    always@(posedge clk, negedge rst_n)
    begin
        if(rst_n==1'b0) begin
            counter0_frame_reg   <=  {ADDRWIDTH_c{1'b0}};
        end
        else if(fifo1_read_in_w==1'b1) begin
            counter0_frame_reg   <=  (counter0_frame_reg==MAX_COUNTER[ADDRWIDTH_c-1:0])?
                                 NUM_PIXEL_EACH_FRAME[ADDRWIDTH_c-1:0]:counter0_frame_reg + 1'b1;
        end
    end
    assign  read_enable_w   =   (counter0_frame_reg>=NUM_PIXEL_EACH_FRAME[ADDRWIDTH_c-1:0])
                                &&(fifo1_read_in_w==1'b1);
    // Registerring the read_enable_w
    always@(posedge clk, negedge rst_n)
    begin
        if(rst_n==1'b0) begin
            read_enable_reg     <=  1'b0;
        end
        else begin
            read_enable_reg     <=  read_enable_w;
        end
    end

    //*******************************************************************************************//
    //                           Architecture: Controlling the read_address                      //
    //*******************************************************************************************//
    always@(posedge clk, negedge rst_n)
    begin
        if(rst_n==1'b0) begin
            r_address_reg   <=  {ADDRWIDTH_c{1'b0}};
        end
        else if(read_enable_w==1'b1) begin
            r_address_reg   <=  (r_address_reg==MAX_COUNTER[ADDRWIDTH_c-1:0])?
                                {ADDRWIDTH_c{1'b0}}: r_address_reg + 1'b1;
        end
    end
    //*******************************************************************************************//
    //                                 Architecture: Connecting the internal mem                 //
    //*******************************************************************************************//
    background_subtraction_using_delta_sigma_argorithm_project_internal_mem
    #(
        .DATAWIDTH_p        (DATA_WIDTH             ),
        .MEM_DEPTH_p        (NUM_PIXEL_EACH_FRAME*2 ),
        .REGISTER_INPUT_p   (0                      ),
        .REGISTER_OUTPUT_p  (0                      )
    )
    internal_mem_inst 
    (
        // ------------------------------------------------
        .clk_drv            (clk                    ),
        .enable             (1'b1                   ),
        .reset_n            (rst_n                  ),
        // ------------------------------------------------
        .sdpmem_wrena       (stage1_out_valid_reg   ),
        .sdpmem_wraddr      (w_address_reg          ),
        .sdpmem_wrdata      (result_mt_w            ),   //stage1_out_data_reg
        // ------------------------------------------------
        .sdpmem_rdaddr      (r_address_reg          ),
        .sdpmem_rddata      (r_data_out_w           )
    );
    
    // Valid            : stage1_out_valid_reg
    // Next frame       : stage1_out_data_reg
    // Current frame    : r_data_out_w
    // Regiterring the frame
    assign  valid_frame_in_reg  =  stage1_out_valid_reg;
    
    // Next frame reg and current frame reg
    assign  next_frame_in_reg   =  stage1_out_data_reg; //  It
    assign  current_frame_in_reg=  r_data_out_w;        // Mt-1
    
    /*------------------------------------------------------------------------------------------------------------------------*/
    // Calculating the different
    assign  result_different_frame_valid_w  =   valid_frame_in_reg;
    assign  result_different_frame_w        =  /*(result_et_buf[0] == 1'b1) ? 1'b1:*/(next_frame_in_reg == current_frame_in_reg) ? 1'b0:1'b0;
    // Update Mt
    assign  Mt_update =  (next_frame_in_reg > current_frame_in_reg) ? (current_frame_in_reg + result_different_frame_w) : 
    (current_frame_in_reg - result_different_frame_w);
    assign  result_mt_w =   (read_enable_reg == 1'b0) ? stage1_out_data_reg : Mt_update;             
    // Calculating the Ot
    assign  result_dt_w =  (result_mt_w >= stage1_out_data_reg) ? (result_mt_w - stage1_out_data_reg):
                                                             (stage1_out_data_reg - result_mt_w); 
    assign  result_dt_valid_w   = stage1_out_valid_reg;
    //*******************************************************************************************//
    //                                         Architecture: Function clog2b                     //
    //*******************************************************************************************//
    function integer clog2b;
        // ------------------------------------------------
        input integer   depth;
        // ------------------------------------------------
        integer         i;
        // ------------------------------------------------
        begin
            for (i = 0; 2**i < depth; i = i + 1) begin
            end
            clog2b = i;
        end
    endfunction
    
    //*******************************************************************************************//
    //              Architecture: This part calculating the Vt frame of the video                //
    //*******************************************************************************************//
    background_subtraction_using_delta_sigma_argorithm_project_internal_mem
    #(
        .DATAWIDTH_p        (DATA_WIDTH             ),
        .MEM_DEPTH_p        (NUM_PIXEL_EACH_FRAME*2 ),
        .REGISTER_INPUT_p   (0                      ),
        .REGISTER_OUTPUT_p  (0                      )
    )
    mem_Vt_data_inst 
    (
        // ------------------------------------------------
        .clk_drv            (clk                    ),
        .enable             (1'b1                   ),
        .reset_n            (rst_n                  ),
        // ------------------------------------------------
        .sdpmem_wrena       (valid_frame_vt_in_reg  ),
        .sdpmem_wraddr      (w_address_reg          ),
        .sdpmem_wrdata      (result_vt_w            ),   //stage1_out_data_reg
        // ------------------------------------------------
        .sdpmem_rdaddr      (r_address_reg          ),
        .sdpmem_rddata      (r_data_out2_w          )
    );
    assign  valid_frame_vt_in_reg  =  stage1_out_valid_reg;
    
    // Next frame reg and current frame reg for vt
    assign  next_frame_vt_in_reg   =  result_dt_w;
    assign  current_frame_vt_in_reg=  (read_enable_reg==1'b0) ? {DATA_WIDTH{1'b0}}:r_data_out2_w;
    
    // Calculating the different Vt
    assign  result_different_frame_vt_valid_w  =   valid_frame_vt_in_reg;
    assign  result_different_frame_vt_w        =   (next_frame_vt_in_reg*N_FACTOR == current_frame_vt_in_reg)?1'b0:1'b1;
    assign  result_vt_w =    (read_enable_reg==1'b0)?{DATA_WIDTH{1'b0}} : (next_frame_vt_in_reg*N_FACTOR > current_frame_vt_in_reg)?
                                (current_frame_vt_in_reg + result_different_frame_vt_w):(current_frame_vt_in_reg - result_different_frame_vt_w);
    assign  result_vt_valid_w = result_different_frame_vt_valid_w;
    
    always@(result_vt_w)
    begin
        if(result_vt_w>=8'd250) begin
            result_vt_reg   =   8'd250;
        end
        else if(result_vt_w<=8'd2) begin
            result_vt_reg   =   8'd2;
        end
        else begin
            result_vt_reg   =   result_vt_w;
        end
    end
    
    assign  result_et_w         =   (read_enable_reg==1'b0) ? {DATA_WIDTH{1'b0}} : (result_dt_w < result_vt_reg) ? 8'h00:8'hff;
    //assign  result_et_valid_w   =   result_vt_valid_w;
    
    always@(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        result_et_buf <= {DATA_WIDTH{1'b1}};
        result_et_valid_w <= 1'b0;
    end
    else begin
        result_et_buf       <=  result_et_w;
        result_et_valid_w   <=  result_vt_valid_w;
    end
    end
    //*******************************************************************************************//
    //                             Architecture: Fifo for storing the output data                //
    //*******************************************************************************************//
    background_subtraction_using_delta_sigma_argorithm_project_fifo
    #(
        .WIDTH_IN       (DATA_WIDTH                             ),
        .WIDTH_OUT      (DATA_WIDTH                             ),
        .DEPTH          (8                                      )
    )
    dut_storing_data_out
    (
        // inputs
        .clk            (clk                                    ),
        .reset_n        (rst_n                                  ),
        .read_en        (fifo2_read_in_w                        ),
        .write_en       (result_vt_valid_w                      ),
        .datain         (~result_et_w                            ),

        //outputs
        .dataout        (fifo2_data_out_w                       ),
        .fifo_count     (),
        .empty          (fifo2_empty_out_w                      ),
        .full           (fifo2_full_out_w                       )
    );
    assign  fifo2_read_in_w     =   ready_in && (~fifo2_empty_out_w);
    assign  data_out            =   fifo2_data_out_w;
    assign  valid_out           =   fifo2_read_in_w;
    
    //*******************************************************************************************//
    //                                         Architecture: Using for test                      //
    //*******************************************************************************************//
    
    wire    eop_out;
    wire    sop_out;
    reg [ADDRWIDTH2_c-1:0]   counter_frame_reg;
    wire                    active ;    
    always@(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0) begin
            second_frame <= 1'b0;
        end
        else begin
            if(eop_out)second_frame <= 1'b1;
        end
    end
    assign active = (valid_out==1'b1)&&(ready_in==1'b1);
    always@(posedge clk, negedge rst_n)
    begin
        if(rst_n==1'b0) begin
            counter_frame_reg   <=  {ADDRWIDTH2_c{1'b0}};
        end
        else if(active) begin
            counter_frame_reg   <=  (counter_frame_reg==MAX_WRITE_COUNT[ADDRWIDTH2_c-1:0])? {ADDRWIDTH2_c{1'b0}}: (counter_frame_reg + 1);
        end
    end
    assign  eop_out   =(counter_frame_reg==MAX_WRITE_COUNT[ADDRWIDTH2_c-1:0])? active:1'b0;
    assign  sop_out   =(counter_frame_reg==1'b0)? active:1'b0;
    assign  valid_out           =  fifo2_read_in_w;
endmodule 