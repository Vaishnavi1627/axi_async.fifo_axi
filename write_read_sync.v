module sync_w2r #(parameter add_size = 3)(
output reg [add_size:0] wr_ptr_sync,   //  write pointer after synchronization 
input [add_size:0] wr_ptr, //  write pointer before synchronization 
input rd_clk, rd_rst);  // read clock, rad reset


always @(posedge rd_clk)
if (!rd_rst)
begin
wr_ptr_sync<=0;
end
else 
begin

wr_ptr_sync <=wr_ptr;
end
endmodule
