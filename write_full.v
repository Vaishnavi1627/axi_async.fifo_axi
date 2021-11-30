module wptr_full #(parameter add_size = 3)
(output reg full,
output [add_size-1:0] wr_addr,  // write address
output reg [add_size :0] wr_ptr,  //  write pointer
input [add_size :0] rd_ptr_sync,  // read pointer after synchronization
input wr_inc, wr_clk, wr_rst);   // write increment, write clock, write reset
reg [add_size:0] wbin; // write pointer in binary format
wire [add_size:0] wgraynext, wbinnext;  //write gray next, write binary next
wire wfull_val;

assign wr_addr = wbin[add_size-1:0];
assign wbinnext = wbin + (wr_inc & ~full);
assign wgraynext = (wbinnext>>1) ^ wbinnext;

assign wfull_val=(((wgraynext[add_size] !=rd_ptr_sync[add_size] ) && (wgraynext[add_size-1] !=rd_ptr_sync[add_size-1]) 
                    && (wgraynext[add_size-2:0]==rd_ptr_sync[add_size-2:0]) && wr_inc) );  // full flag assignment logic
 
always @(posedge wr_clk or posedge wr_rst)
begin
if (!wr_rst) 
{wbin, wr_ptr} <= 0;
else 
{wbin, wr_ptr} <= {wbinnext, wgraynext};
end

always @(posedge wr_clk or posedge wr_rst)
begin
if (!wr_rst) 
full <= 1'b0;
else 
full <= wfull_val;
end
endmodule
