
module memory (
        // ------------------------------------------------
        clk_drv,
        enable,
        reset_n,
        // ------------------------------------------------
        sdpmem_wrena,
        sdpmem_wraddr,
        sdpmem_wrdata,
        // ------------------------------------------------
        sdpmem_rdaddr,
        sdpmem_rddata
        );

    // ----------------------------------------------------
    // Parameters
    // ----------------------------------------------------
    parameter                       DATAWIDTH_p         = 32;
    parameter                       MEM_DEPTH_p         = 153600;
    parameter                       REGISTER_INPUT_p    = 0;
    parameter                       REGISTER_OUTPUT_p   = 0;

    // ----------------------------------------------------
    // Constant
    // ----------------------------------------------------
    localparam                      ADDRWIDTH_c         = clog2b (MEM_DEPTH_p);

    // ----------------------------------------------------
    // Input Ports
    // ----------------------------------------------------

    // clock and global control signals
    input                           clk_drv;
    input                           enable;
    input                           reset_n;

    input                           sdpmem_wrena;
    input  [ADDRWIDTH_c - 1 : 0]    sdpmem_wraddr;
    input  [DATAWIDTH_p - 1 : 0]    sdpmem_wrdata;

    input  [ADDRWIDTH_c - 1 : 0]    sdpmem_rdaddr;
    output [DATAWIDTH_p - 1 : 0]    sdpmem_rddata;

    // ----------------------------------------------------
    // Signals Declaration
    // ----------------------------------------------------

    // here is mem element
    reg    [DATAWIDTH_p - 1 : 0]    simple_dualp_mem [MEM_DEPTH_p - 1 : 0];

    // register for the input mem (if required)
    reg                             wrena_ff;
    reg    [ADDRWIDTH_c - 1 : 0]    wraddr_ff;
    reg    [DATAWIDTH_p - 1 : 0]    wrdata_ff;
    reg    [ADDRWIDTH_c - 1 : 0]    rdaddr_ff;

    // register for the output mem (if required)
    reg    [DATAWIDTH_p - 1 : 0]    rddata_ff;

    // signals associated directly to the memory ports
    wire                            wrena;
    wire   [ADDRWIDTH_c - 1 : 0]    wraddr;
    wire   [DATAWIDTH_p - 1 : 0]    wrdata;
    wire   [ADDRWIDTH_c - 1 : 0]    rdaddr;
    reg    [DATAWIDTH_p - 1 : 0]    rddata;

    // ----------------------------------------------------
    // Constant Function - clog2b
    // Calculate the ceiling of the log base 2
    // 
    // ----------------------------------------------------
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

    // ----------------------------------------------------
    // END Declaration.
    // ----------------------------------------------------

    // generate register input (if required)
    generate
        if (REGISTER_INPUT_p == 1) begin
            always @ (posedge clk_drv, negedge reset_n)
            begin
                if (reset_n == 1'b0) begin
                    wrena_ff    <= 1'b0;
                    wraddr_ff   <=  'd0;
                    wrdata_ff   <=  'd0;
                    rdaddr_ff   <=  'd0;
                end
                else if (enable == 1'b1) begin
                    wrena_ff    <= sdpmem_wrena;
                    wraddr_ff   <= sdpmem_wraddr;
                    wrdata_ff   <= sdpmem_wrdata;
                    rdaddr_ff   <= sdpmem_rdaddr;
                end
            end
        end
    endgenerate

    // generate connection to the memory input
    generate
        if (REGISTER_INPUT_p == 1) begin
            assign wrena    = wrena_ff;
            assign wraddr   = wraddr_ff;
            assign wrdata   = wrdata_ff;
            assign rdaddr   = rdaddr_ff;
        end
        else begin
            assign wrena    = sdpmem_wrena;
            assign wraddr   = sdpmem_wraddr;
            assign wrdata   = sdpmem_wrdata;
            assign rdaddr   = sdpmem_rdaddr;
        end
    endgenerate

    // implement simple dual port MEM with
    // read old data during write bahavior
        // 11 Mar 2010 : Fix enable, requires enable for reading since no register output used in design
    always @ (posedge clk_drv)
    begin : write_to_mem_blk
        if (enable == 1'b1) begin
                        if (wrena == 1'b1) begin
                                simple_dualp_mem[wraddr]    <= wrdata;
                        end 
                        rddata  <= simple_dualp_mem[rdaddr];
                end
    end

    // generate register output (if required)
    generate
        if (REGISTER_OUTPUT_p == 1) begin
            always @ (posedge clk_drv, negedge reset_n)
            begin
                if (reset_n == 1'b0) begin
                    rddata_ff   <= 'd0;
                end
                else if (enable == 1'b1) begin
                    rddata_ff   <= rddata;
                end
            end
        end
    endgenerate


    // generate connection output
    generate
        if (REGISTER_OUTPUT_p == 1) begin
            assign sdpmem_rddata = rddata_ff;
        end
        else begin
            assign sdpmem_rddata = rddata;
        end
    endgenerate

endmodule
