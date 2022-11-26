//***********************************************************************************************//
// File name        : icdrec_specii_home_project_tb.v
// Module           : icdrec_specii_home_project_tb
// Project          : Home Project
// Author           : Khanh Nguyen Quoc (khanh.nguyenquoc@icdrec.edu.vn)
// Description      : This design is used to verify the icdrec_specii_home_project
//
// Referents        : none.
//
// ICDREC Confidential
// All rights reserved
// Copyright (C) 2016
//***********************************************************************************************//
`timescale 1ns/1ns
module top_trafficdetect_tb;
    //*******************************************************************************************//
    //                                      PARAMETER CONFIG                                     //
    //*******************************************************************************************//
    parameter   HF_CYCL             =   10;
    parameter   CYCL                =   HF_CYCL*2;

    //*******************************************************************************************//
    //                                      Parameters                                           //
    //*******************************************************************************************//
    parameter   DATA_WIDTH      =   8;
    parameter   ADDR_WIDTH      =   23;
    parameter   IMAGE_WIDTH     =   320;
    parameter   IMAGE_HEIGHT    =   240;
    parameter   NUM_FRAME       =   100;
    
    //*******************************************************************************************//
    //                                      Localparams                                          //
    //*******************************************************************************************//
    localparam  IN_WIDTH        =   DATA_WIDTH*3;
    localparam  OUT_WIDTH       =   DATA_WIDTH;
    localparam  NUMBER_INPUT    =   IMAGE_WIDTH*IMAGE_HEIGHT*NUM_FRAME;

    /*// Avalon MM wire list
    wire                        mm1_waitrequest_w;
    wire    [22:0]              mm1_address_w;
    wire                        mm1_read_w;
    wire                        mm1_write_w;
    wire    [31:0]              mm1_write_data_w;
    wire    [31:0]              mm1_read_data_w;
    wire                        mm1_read_data_valid_w;
    wire    [3:0]               mm1_size_w;

    */
    // clock - reset declaration
    reg                         sys_clk;
    reg                         rst_n;
    reg                         signal;
    
    wire                        valid_out;
    wire    [DATA_WIDTH-1:0]    data_out;
    wire                        ready_in;

    wire                        ready_out;
    wire                        valid_in;
    assign  valid_in    =   top_trafficdetect_tb.dut.valid_in;
    assign  ready_out   =   top_trafficdetect_tb.dut.ready_out;


    integer                     display_interval;
    integer                     num_of_output_data;

    //System reset, start tb
    initial begin
        rst_n    = 1'b0;
        repeat (5) @(posedge sys_clk); 
        rst_n   = 1'b1;
        repeat (10) @(posedge sys_clk); 
    end
    
    // system clock
    always begin
        sys_clk = 1'b0;#HF_CYCL;
        sys_clk = 1'b1;#HF_CYCL;
    end

    initial begin
        num_of_output_data = 0;
        display_interval = 0;
    end

    //*******************************************************************************************//
    //                            Architecture: Generating the input                             //
    //*******************************************************************************************//
    // Red 
    wire                    tb_ready_w;
    reg [DATA_WIDTH-1:0]    red_data;
    reg [DATA_WIDTH-1:0]    input_r;
    reg                     input_vld;
    integer fid;
    integer status;
    initial begin
    input_vld   =   1'b0;
    @(posedge rst_n);
    fid = $fopen("r.txt","r");
        while(!$feof(fid)) begin
            @(posedge sys_clk) begin
            if(tb_ready_w ==1'b1) begin
                status  = $fscanf(fid,"%d",red_data);
                input_r     <=  red_data;
                input_vld   <=  1'b1;
				end
            else input_vld   <=  1'b0;
			
            end
        end
    $fclose(fid);
    input_vld   <=  1'b0;
    end

    // Green 
    reg [DATA_WIDTH-1:0]    green_data;
    reg [DATA_WIDTH-1:0]    input_g;
    integer fid_g;
    integer status_g;
    initial begin
    @(posedge rst_n);
    fid_g = $fopen("g.txt","r");
        while(!$feof(fid_g)) begin
            @(posedge sys_clk) begin
            if(tb_ready_w ==1'b1) begin
                status_g    = $fscanf(fid_g,"%d",green_data);
                input_g     <=  green_data;
            end
            end
        end
    $fclose(fid);
    end

    // Blue 
    reg [DATA_WIDTH-1:0]    blue_data;
    reg [DATA_WIDTH-1:0]    input_b;
    integer fid_b;
    integer status_b;
    initial begin
    @(posedge rst_n);
    fid_b = $fopen("b.txt","r");
        while(!$feof(fid_b)) begin
            @(posedge sys_clk) begin
            if(tb_ready_w ==1'b1) begin
                status_b    = $fscanf(fid_b,"%d",blue_data);
                input_b     <=  blue_data;
            end
            end
        end
    $fclose(fid);
    end

    //*******************************************************************************************//
    //                                         WAVEFORM                                          //
    //*******************************************************************************************//
	`ifdef USING_VCS
    initial begin
        $vcdplusfile("top_trafficdetect.vpd");
        //$vcdplusmemon;
        $vcdpluson(top_trafficdetect_tb);
    end
	`endif

    //*******************************************************************************************//
    //                              Architecture: Intantiate DUT                                 //
    //*******************************************************************************************//
    top_trafficdetect
   /* #(
        .DATA_WIDTH             (DATA_WIDTH     ),
        .ADDR_WIDTH             (ADDR_WIDTH     ),
        .IMAGE_WIDTH            (IMAGE_WIDTH    ),
        .IMAGE_HEIGHT           (IMAGE_HEIGHT   )
    )*/
    dut
    (
        // System signals
        .clk                    (sys_clk                ),
        .rst_n                  (rst_n                  ),

        // Sink side
        .data_in                ({input_r,input_g,input_b}),
        .valid_in               (input_vld              ),
        .ready_out              (tb_ready_w             ),
		.sop_in					(						),
		.eop_in					(						),
        // Source side
        .data_out               (data_out               ),
        .valid_out              (valid_out              ),
        .ready_in               (ready_in               ),
		.sop_out				(						),
		.eop_out				(						)
		
        
        //  RAM1 AMM
        //.ram1_waitrequest_in    (mm1_waitrequest_w      ),
        //.ram1_address_out       (mm1_address_w          ),
        //.ram1_read_out          (mm1_read_w             ),
        //.ram1_write_out         (mm1_write_w            ),
        //.ram1_write_data_out    (mm1_write_data_w       ),
        //.ram1_rdata_valid_in    (mm1_read_data_valid_w  ),
        //.ram1_rdata_in          (mm1_read_data_w        ),
        //.ram1_size_out          (mm1_size_w             )
    );

    //*******************************************************************************************//
    //                          Check output number valid                                        //
    //*******************************************************************************************//
    always @(posedge sys_clk, negedge rst_n) begin
        if (rst_n == 1'b0) begin
            num_of_output_data <= 0;
        end 
    else begin
            //num_of_output_data <= (valid_out==1'b1&&ready_in==1'b1) ? 
			num_of_output_data <= (valid_out==1'b1)?
                                    num_of_output_data + 1 : num_of_output_data;
            //if(valid_out==1'b1&&ready_in==1'b1) begin
			if(valid_out==1'b1) begin
                if(num_of_output_data%131072 ==0)$display("Counting the number of out data is %d at %d",num_of_output_data,$time);
            end
    end
    end

    //*******************************************************************************************//
    //                          Writing input data into FILE                                     //
    //*******************************************************************************************//
    // Red 
    integer         input_data_r;
    initial begin
        input_data_r    =   $fopen("data_r_in.dmp","w");
            forever@(posedge sys_clk) begin
                //if((valid_in==1'b1)&&(ready_out==1'b1)) begin
				if(valid_in==1'b1) begin
                    $fwrite(input_data_r,"%h\n",input_r);
                end
            end
        $fclose(input_data_r);
    end
    
    // Green
    integer         input_data_g;
    initial begin
        input_data_g    =   $fopen("data_g_in.dmp","w");
            forever@(posedge sys_clk) begin
                //if(valid_in==1'b1&&ready_out==1'b1) begin
				if(valid_in==1'b1) begin
                    $fwrite(input_data_g,"%h\n",input_g);
                end
            end
        $fclose(input_data_g);
    end
    
    // Blue
    integer         input_data_b;
    initial begin
        input_data_b    =   $fopen("data_b_in.dmp","w");
            forever@(posedge sys_clk) begin
                //if((valid_in==1'b1)&&(ready_out==1'b1)) begin
				if(valid_in==1'b1) begin
                    $fwrite(input_data_b,"%h\n",input_b);
                end
            end
        $fclose(input_data_b);
    end
    
    //*******************************************************************************************//
    //                          Writing output data into FILE                                    //
    //*******************************************************************************************//
    //  r
    integer             output_data_r_11;
    initial begin
        output_data_r_11    =   $fopen("t11_r_dut","w");
            forever@(posedge sys_clk) begin
                if((valid_out==1'b1)&&(ready_in==1'b1)) begin
                    $fwrite(output_data_r_11,"%d\n",data_out);
                    end
                end
        $fclose(output_data_r_11);
    end

    //  g
    integer         output_data_g_11;
    initial begin
        output_data_g_11    =   $fopen("t11_g_dut","w");
            forever@(posedge sys_clk) begin
                if((valid_out==1'b1)&&(ready_in==1'b1)) begin
                    $fwrite(output_data_g_11,"%d\n",data_out);
                end
            end
        $fclose(output_data_g_11);
    end

    // b
    integer         output_data_b_11;
    initial begin
        output_data_b_11    =   $fopen("t11_b_dut","w");
            forever@(posedge sys_clk) begin
                if((valid_out==1'b1)&&(ready_in==1'b1)) begin
                    $fwrite(output_data_b_11,"%d\n",data_out);
                end
            end
        $fclose(output_data_b_11);
    end

    //*******************************************************************************************//
    //                               Stop conditional system                                     //
    //*******************************************************************************************//
    integer counter_data_in;
    always@(posedge sys_clk, negedge rst_n)
    begin
        if(rst_n==1'b0) begin
            counter_data_in <=  'd0;
        end
        //else if(valid_in & ready_out ==1'b1)begin
		else if(valid_in ==1'b1)begin
            counter_data_in <=  counter_data_in + 1'b1;
        end
    end
	
    initial begin
        $display("Start simulation:",$time);
        wait(num_of_output_data==NUMBER_INPUT);
        $display("Ended Simulation Process %0d\n",$time);
        # 3000;
        $display("Test finish\n");
        test_complete;
    end
    /*
    initial begin
        //#25000;   //#1000000000;
        #1500000000;
        $display("FAIL.......FAIL......FAIL.......FAIL........FAIL..........FAIL");
        $finish;
    end
    */
    //*******************************************************************************************//
    //                                          TASK FINISH                                      //
    //*******************************************************************************************//
    task test_complete;
    begin
        $display("\n=====> COMPLETE SIMULATION DUT\n\n");
        $finish;
    end
    endtask 

    //*******************************************************************************************//
    //                                    Ready in generator                                     //
    //*******************************************************************************************//
	/*
    initial 
    begin
        signal <= 0;
        forever
        begin
            # 1000 signal <= ~signal;
            if(signal==1'b1)
            #500 signal <= signal;
        end       
    end

    //assign  ready_in    =   signal;
	*/
    assign    ready_in    =   1'b1;

    //*******************************************************************************************//
    //                                        SRAM 1 CONTROLLER                                  //
    //*******************************************************************************************//
    // wires
	/*
    wire   [31:0]   SRAM_DQ1;
    wire   [22:0]   SRAM_ADDR1;
    wire            SRAM_CE_N1;
    wire            SRAM_OE_N1;
    wire            SRAM_WE_N1;
    
    sram_model 
    sram1
    (
        // Inputs
        .clk                    (sys_clk                ),
        .reset_n                (rst_n                  ),
        .address                (mm1_address_w          ),
        .read                   (mm1_read_w             ),
        .write                  (mm1_write_w            ),
        .writedata              (mm1_write_data_w       ),
        // Outputs
        .readdata               (mm1_read_data_w        ),
        .readdatavalid          (mm1_read_data_valid_w  ),
        .waitrequest            (mm1_waitrequest_w      ),
        .size                   (mm1_size_w             ),
        // Bi-Directional
        .SRAM_DQ                (SRAM_DQ1               ),
        .SRAM_ADDR              (SRAM_ADDR1             ),
        .SRAM_CE_N              (SRAM_CE_N1             ),
        .SRAM_OE_N              (SRAM_OE_N1             ),
        .SRAM_WE_N              (SRAM_WE_N1             )
        );
    */
    //*******************************************************************************************//
    //                                          SRAM MODEL                                       //
    //*******************************************************************************************//
	/*
    sram_sample 
    #(
        .addrSize   (23     ),
        .WordSize   (32     )   
    )
    sram_sample1
    (
        .clk                    (sys_clk                ),
        .addr                   (SRAM_ADDR1             ),
        .data                   (SRAM_DQ1               ),
        .oe                     (SRAM_OE_N1             ),
        .ce                     (SRAM_CE_N1             ),
        .we                     (SRAM_WE_N1             )
    );
	*/

    //*******************************************************************************************//
    //            Function Declaration:	Compute maximum bit width of                             //
    //                     unsigned interger number.                                             //
    //*******************************************************************************************//
	/*
    function integer max_bit_width_cal;
        //  Inputs
        input   integer	variable_in;
        //  Internal Variable
        integer inter_variable;
        integer i;
        begin
            inter_variable = variable_in;
            if(inter_variable == 0) begin
                max_bit_width_cal = 1;
            end
            else begin
                for(i = 0; inter_variable != 0; i = i + 1)
                    begin
                        inter_variable = inter_variable >> 1;
                    end
                max_bit_width_cal = i;
            end
        end
    endfunction
	*/
endmodule
