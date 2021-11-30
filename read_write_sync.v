module sync_r2w #(parameter add_size = 3)
(
output reg [add_size:0] rd_ptr_sync,   // read pointer after synchronization
input [add_size:0] rd_ptr,   // read pointer before synchronization
input wr_clk, wr_rst);  // write clock, write reset


always @(posedge wr_clk )

if (!wr_rst) 
begin
rd_ptr_sync <=0;  // if reset assign both to zero
end
else
begin

rd_ptr_sync<= rd_ptr;
end
endmodule
