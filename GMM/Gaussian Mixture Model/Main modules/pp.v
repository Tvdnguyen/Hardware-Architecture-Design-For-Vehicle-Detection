module pp(clk_i,indata, outdata);
input clk_i;
input indata;
output reg outdata;

always @(posedge clk_i)
begin
	outdata <= indata;
end
endmodule