
module sram_model (
    // Inputs
    clk,
    reset_n,

    address,
    //byteenable,
    read,
    write,
    writedata,

    // Bi-Directional
    SRAM_DQ,

    // Outputs
    readdata,
    readdatavalid,
    waitrequest,
        size,

    SRAM_ADDR,
    //SRAM_LB_N,
    //SRAM_UB_N,
    SRAM_CE_N,
    SRAM_OE_N,
    SRAM_WE_N
);


/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
parameter   DATA = 32;
parameter   ADDR  = 23;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input                       clk;
input                       reset_n;
input           [ADDR-1: 0] address;
input                       read;
input                       write;
input           [DATA-1: 0] writedata;
input           [3:0]       size;
// Bi-Directional
inout           [DATA-1: 0] SRAM_DQ;    // SRAM Data bus 16 Bits
// Outputs
output reg      [DATA-1: 0] readdata;
output                      readdatavalid;
output                      waitrequest;
output reg      [ADDR-1: 0] SRAM_ADDR;  // SRAM Address bus 18 Bits
output reg                  SRAM_CE_N;  // SRAM Chip chipselect
output reg                  SRAM_OE_N;  // SRAM Output chipselect
output reg                  SRAM_WE_N;  // SRAM Write chipselect

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires

// Internal Registers
reg						is_read;
reg		 	[1:0]		read_state;
//reg         [7:0]       write_state;
reg         [1:0]       write_state;
reg						is_write;
reg			[DATA-1: 0]	writedata_reg;
//reg		readdatavalid;
// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
//assign	waitrequest = (write & (write_state!=8'd255));
assign  waitrequest = (write & (write_state!=2'd3));
//assign	waitrequest =   1'b0;
//assign 	readdatavalid	= read & read_state[1];

reg is_read_reg;
assign 	readdatavalid	= is_read_reg;
always@(posedge clk)
begin
    is_read_reg <=  is_read;
end
//assign 	readdatavalid	= is_read;
// Output Registers
always @(posedge clk)
begin
	readdata		<= SRAM_DQ;
	//readdatavalid	<= is_read;
	
	SRAM_ADDR		<= address;
	//SRAM_LB_N		<= 1'b0;//~(byteenable[0] & (read | write));
	//SRAM_UB_N		<= 1'b0;//~(byteenable[1] & (read | write));
	SRAM_CE_N		<= ~(read | write);
	SRAM_OE_N		<= ~read;
	SRAM_WE_N		<= ~write;
end

// Internal Registers
always @(posedge clk)
begin
	if (!reset_n | read_state[1])
		read_state		<= 2'h0;
	else if (read)
		read_state		<= read_state + 2'h1;
	else 
		read_state		<=  2'h0;
end

always @(posedge clk)
begin
	if (!reset_n)
		is_read		<= 1'b0;
	else
		is_read		<= read;
end


// Internal Registers
always @(posedge clk)
begin
	if (!reset_n)
		write_state		<= 2'h0;
	else if (write)
		write_state		<= write_state + 2'h1;
	else 
		write_state		<=  2'h0;
end

always @(posedge clk)
begin
	if (!reset_n)
		is_write		<= 1'b0;
	else
		is_write		<= write;
end

always @(posedge clk)
begin
	writedata_reg	<= writedata;
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

// Output Assignments
assign SRAM_DQ	= (is_write) ? writedata_reg : {DATA{1'hz}};

// Internal Assignments

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

