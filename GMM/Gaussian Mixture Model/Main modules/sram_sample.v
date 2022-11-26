
module sram_sample (clk, addr, data, ce, we, oe);

parameter addrSize = 23;
parameter WordSize = 32;
input clk;
input [addrSize-1:0] addr;
inout [WordSize-1:0] data;
input ce, we, oe;

reg [WordSize-1:0] Mem [0:1<<addrSize];

assign data = (!ce & !oe) ? Mem[addr] : {WordSize{1'bz}};

always @(posedge clk)
  if (!ce & !we)
    Mem[addr] <= data;

always @(we or oe)
  if (!we && !oe)
    $display("Operational error in RamChip: oe and we both active");

endmodule 
