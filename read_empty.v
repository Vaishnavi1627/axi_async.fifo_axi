module rptr_empty #(parameter add_size = 3)
(
output reg empty,   // empty flag
output [add_size-1:0] rd_addr,   // read address
output reg [add_size :0] rd_ptr,  // read pointer
input [add_size :0] wr_ptr_sync,  // write pointer after synchronization
input rd_inc, wr_inc ,rd_clk, rd_rst);   // read increment, read clock, read reset
reg [add_size:0] rbin;  // read binary format
wire [add_size:0] rgraynext, rbinnext;   // read gray next, read binary next
wire rempty_val;

assign rd_addr = rbin[add_size-1:0];  
assign rbinnext = rbin + (rd_inc & ~empty);
assign rgraynext = (rbinnext>>1) ^ rbinnext;

assign rempty_val = ((rd_ptr == wr_ptr_sync) | (rd_inc & (wr_ptr_sync == rgraynext )));  // empty value assignment

//	empty <= #1 (wp_s == rp) | (rd_en & (wp_s == rp_pl1));
always @(posedge rd_clk )
begin
if (!rd_rst) 
{rbin, rd_ptr} <= 0;
else 
{rbin, rd_ptr} <= {rbinnext, rgraynext};
end
always @(posedge rd_clk )
begin
if (!rd_rst) 
empty <= 1'b1;
else 
empty <= rempty_val;
end
endmodule
