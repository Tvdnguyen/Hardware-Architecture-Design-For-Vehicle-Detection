//***********************************************************************************************//
//  File name   : icdrec_specii_home_project_rgb2gray.v
//  Module      : icdrec_specii_home_project_rgb2gray
//  Project     : Home Project
//  Author      :
//  Email       :
//  Description :
//  ICDREC Confidential
//  All rights reserved
//  Copyright (C) 2016
//***********************************************************************************************//
`timescale 1ns / 1ns
module background_subtraction_using_delta_sigma_argorithm_project_rbg2gray
(
    // Sink side
    r_data_in,
    g_data_in,
    b_data_in,
    valid_in,

    // Source side
    data_out,
    valid_out
);

    //*******************************************************************************************//
    //                                      Parameters                                           //
    //*******************************************************************************************//
    parameter   DATA_WIDTH      =   8;
    
    //*******************************************************************************************//
    //                                      Localparams                                          //
    //*******************************************************************************************//
    localparam  IN_WIDTH         =   DATA_WIDTH;
    localparam  OUT_WIDTH        =   DATA_WIDTH;
    
    //*******************************************************************************************//
    //                                      Inputs                                               //
    //*******************************************************************************************//
    // Sink side
    input   [IN_WIDTH-1:0]      r_data_in;
    input   [IN_WIDTH-1:0]      g_data_in;
    input   [IN_WIDTH-1:0]      b_data_in;
    input                       valid_in;
    
    //*******************************************************************************************//
    //                                     Outputs                                               //
    //*******************************************************************************************//
    // Source side
    output  [OUT_WIDTH-1:0]     data_out;
    output                      valid_out;

    
    //*******************************************************************************************//
    //                                     Signal declarations                                   //
    //*******************************************************************************************//
    // Register declarations
    //reg     [OUT_WIDTH-1:0]     out_data;
	wire		[ 9: 0]	r;
	wire		[ 9: 0]	g;
	wire		[ 9: 0]	b;
	wire		[11: 0]	average_color;	
    //*******************************************************************************************//
    //                         Architecture: Connecting the input/output ports                   //
    //*******************************************************************************************//
	assign r = {r_data_in[7: 0], r_data_in [7: 6]};
	assign g = {g_data_in[ 7: 0], g_data_in [7: 6]};
	assign b = {b_data_in[ 7: 0], b_data_in[ 7: 6]};
	assign average_color = {2'h0, r} + {1'b0, g, 1'b0} + {2'h0, b};
	assign data_out = average_color[11:4];
    /*always@(r_data_in,g_data_in,b_data_in,valid_in)
    begin
        if(valid_in==1'b1) begin
            out_data    <=  average_color[11:4];//(r_data_in + g_data_in + b_data_in)/3;
        end
        else begin
            out_data    <=  {OUT_WIDTH{1'b0}};
        end
    end
*/
    //*******************************************************************************************//
    //                   Architecture: Connecting the output port                                //
    //*******************************************************************************************//
    //assign  data_out    = out_data;
    assign  valid_out   = valid_in;
endmodule 
