
module background_subtraction_using_GMM_project_fifo 
(
    // inputs
    clk,
    reset_n,
    read_en,
    write_en,
    datain,

    //outputs
    dataout,
    fifo_count,
    empty,
    full
);

    //*******************************************************************************************//
    //                                      Parameters                                           //
    //*******************************************************************************************//
    parameter   WIDTH_IN    = 24;
    parameter   WIDTH_OUT   = 8;
    parameter   DEPTH       = 128;      // D-word

    //*******************************************************************************************//
    //                                      Localparams                                          //
    //*******************************************************************************************//
    localparam  RATIO       =   (WIDTH_IN/WIDTH_OUT);
    localparam  WADD        =   log2(DEPTH);
    localparam  WADDW       =   log2(DEPTH);
    localparam  WADDR       =   log2(DEPTH);
    localparam  WIDTH_C     =   log2(DEPTH*RATIO+1);
    localparam  LATENTCY    =   0;

    //*******************************************************************************************//
    //                                      Function                                             //
    //*******************************************************************************************//
    function integer log2;
        input integer value;
        integer i;
        if (value == 1)
            log2 = 1;
        else
            for (i = 0; i < 16; i = i + 1)
                if (2**i < value)
                    log2 = i + 1;
    endfunction
    `define     DELAY   #0
    //`define LSB_BYTE

    //*******************************************************************************************//
    //                                      Inputs                                               //
    //*******************************************************************************************//
    input                   clk;
    input                   reset_n;
    input                   read_en;
    input                   write_en;
    input [WIDTH_IN-1:0]    datain;

    //*******************************************************************************************//
    //                                      Outputs                                              //
    //*******************************************************************************************//
    output                  empty;
    output                  full;
    output[WIDTH_C-1:0]     fifo_count;
    output[WIDTH_OUT-1:0]   dataout;



    //*******************************************************************************************//
    //                                     Signal declarations                                   //
    //*******************************************************************************************//
    // Wire declarations
    wire                    read_valid;
    wire                    write_valid;
    wire                    read_mem_n;
    wire                    read_mem_last;
    wire                    fifo_count_1;
    wire                    read_last;

    // Register declarations
    reg [WIDTH_C-1:0]   fifo_count;
    reg [WADDR-1:0]     add_rd;
    reg [WADDW-1:0]     add_wr;
    reg [WIDTH_IN-1:0]  mem0[DEPTH-1:0];
    reg [WIDTH_IN-1:0]  mem_buff;
    
    

    assign  fifo_count_1    =   (fifo_count == 1) &  read_valid ;
    assign  read_last       =    read_mem_last & fifo_count_1 ;
    `ifdef LSB_BYTE
    assign  dataout = mem_buff[WIDTH_OUT-1:0];
    `else
    assign  dataout = mem_buff[WIDTH_IN-1:WIDTH_IN - WIDTH_OUT];
    `endif



    assign read_valid = read_en & !empty ;
    assign write_valid = write_en & !full ;

    generate
    if (RATIO==1)begin
        assign  read_mem_n      =   1'b0;
        assign  read_mem_last   =   read_valid;
    end
    else if (RATIO==2)begin
        reg [RATIO-2:0] read_buff;

        assign  read_mem_last   = read_buff;
        assign  read_mem_n      =   read_buff;
        always @ (posedge clk)begin
            if(!reset_n)
                read_buff   <= `DELAY 0;
            else if(read_valid&~read_mem_n)
                read_buff   <= `DELAY 1'b1;
            else if(read_valid)
                read_buff   <= `DELAY 1'b0;
            else
                read_buff   <= `DELAY read_buff;
        end
    end
    else begin

        reg [RATIO-2:0] read_buff;
        //wire  read_mem_last;
        assign  read_mem_last   = read_buff[RATIO-2];
        assign  read_mem_n      =   |read_buff;
        always @ (posedge clk)begin
            if(!reset_n)
                read_buff   <= `DELAY 0;
            else if(read_valid&~|read_buff)
                read_buff   <= `DELAY {read_buff[RATIO-3:0],1'b1};
            else if(read_valid)
                read_buff   <= `DELAY {read_buff[RATIO-3:0],1'b0};
            else
                read_buff   <= `DELAY read_buff;
        end
    end

    endgenerate
    always @ (posedge clk)
    begin
        if (write_valid) begin
            mem0[add_wr] <= `DELAY datain;
        end
    end
    //-----------
    generate 
        if (LATENTCY==1)begin
            if(RATIO==1)begin
                always @ (posedge clk)begin//mem[add_rd];//
                    if (!reset_n)
                        mem_buff    <=  `DELAY 0;
                    else if (read_valid )begin
                        mem_buff    <= `DELAY  mem0[add_rd[WADDR-1:0]];
                    end
                end
            end
            else begin
                always @ (posedge clk)begin//mem[add_rd];//
                    if (!reset_n)
                        mem_buff    <=  `DELAY 0;
                    else if (read_valid & !read_mem_n)begin
                        mem_buff    <= `DELAY  mem0[add_rd[WADDR-1:0]];
                    end
                    else if(read_valid)begin
                        `ifdef LSB_BYTE
                        mem_buff        <= `DELAY  {{WIDTH_OUT{1'b0}},mem_buff[WIDTH_IN - 1:WIDTH_OUT]};
                        `else
                        mem_buff        <= `DELAY  {mem_buff[WIDTH_IN - WIDTH_OUT - 1:0],{WIDTH_OUT{1'b0}}};
                        `endif
                    end
                end
            end
            assign empty = (fifo_count == 0) ? 1'b1 : 1'b0 ;
        end
        else begin//LATENTCY==0
            reg empty_reg;
            always @ (posedge clk)begin
                empty_reg   <=  `DELAY (fifo_count_1) |  (fifo_count==0);
            end
            if(RATIO==1) begin
                always @ (*)begin//mem[add_rd];//
                    mem_buff    = `DELAY  mem0[add_rd[WADDR-1:0]];
                end
            end
            else begin
                always @ (posedge clk)begin//mem[add_rd];//
                    if (!reset_n)
                        mem_buff    <=  `DELAY 0;

                    else if ((!read_mem_n&!read_valid)| (read_valid&read_mem_last&~fifo_count_1) )begin
                        mem_buff    <= `DELAY  mem0[add_rd[WADDR-1:0]];
                    end
                    else if(read_valid)begin
                        `ifdef LSB_BYTE
                        mem_buff    <= `DELAY  {{WIDTH_OUT{1'b0}},mem_buff[WIDTH_IN - 1:WIDTH_OUT]};
                        `else
                        mem_buff    <= `DELAY  {mem_buff[WIDTH_IN - WIDTH_OUT - 1:0],{WIDTH_OUT{1'b0}}};
                        `endif
                    end
                end
            end
            assign empty = empty_reg;
        end
    endgenerate

    always @ (posedge clk) begin
        if (reset_n == 1'b0) begin
            fifo_count  <= `DELAY {WADD{1'b0}};
            add_rd      <= `DELAY {WADDW{1'b0}};
            add_wr      <= `DELAY {WADDW{1'b0}};
        end
        else begin
            add_wr <= `DELAY (write_valid == 1'b1) ? ((add_wr == DEPTH - 1'b1) ? {WADDW{1'b0}} : add_wr + 1'b1) : add_wr;
            add_rd <= `DELAY (read_valid & !read_mem_n/*== 1'b1*/) ? ((add_rd == DEPTH - 1'b1) ? {WADDR{1'b0}} : add_rd + 1'b1) : add_rd;
            casex ({read_valid,read_last, write_valid}) 
                3'b001: begin // only write, not read | write & read last
                    fifo_count <= `DELAY fifo_count + RATIO[WIDTH_C - 1 : 0];
                end
                3'b1x0: begin  // Only read, not write
                    fifo_count <= `DELAY fifo_count - 1'b1;
                end
                3'b1x1: begin  // Both read and write
                    fifo_count <= `DELAY fifo_count + RATIO[WIDTH_C - 1 : 0] -1'b1;
                end
                default: begin
                        fifo_count <= `DELAY fifo_count;
                end
            endcase
        end
    end

    assign full = (fifo_count > ((DEPTH-1)*RATIO)) ? 1'b1 : 1'b0;
endmodule
