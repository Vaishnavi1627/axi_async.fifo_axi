module generic_fifo_dc(
rd_clk, //read clock
wr_clk, // write clock
rst, // reset
data_in, // data input to fifo
wr_en, // write enable 
data_out,  // data output
rd_en,  // read enable
full,  // full flag
empty ,
  valid_in1,
  ready_in2,
  valid_out2,
  ready_out1
 );  

parameter data_size=8;  // number of bits in data
parameter add_size=3;  // number of bits in address-bus
parameter n=32;
parameter max_size = 1<<add_size;

input   rd_clk;
input   wr_clk;
input   rst;
input [data_size-1:0]data_in;
input   wr_en;
output [data_size-1:0]data_out;
input	rd_en;
output	full; 
output	empty;
input  valid_in1;
input  ready_in2;
output valid_out2;
output ready_out1;


assign ready_out1 = ~full ;
assign valid_out2 = ~ empty ;
////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire	[add_size:0]		wr_ptr;  // write pointer 
wire	[add_size:0]		rd_ptr;   // read pointer
wire	[add_size:0]		wr_ptr_s;  // write pointer after synchronization
wire	[add_size:0]        rd_ptr_s;  // read pointer after synchronization
wire		                full, empty;
wire    [add_size-1:0]      wr_addr, rd_addr;  

////////////////////////////////////////////////////////////////////
//
// Memory Block
//

generic_dpram  #(add_size,data_size) u0(
	.rclk(rd_clk),	
	.rce(1'b1),
	.oe(1'b1),
	.rd_en( rd_en),
	.raddr(rd_addr[add_size-1:0]),
	.do(data_out),
	.wclk(wr_clk),	
	.wce(1'b1),
	.wr_en(wr_en),
	.waddr(wr_addr[add_size-1:0]),
	.di(data_in), 
	.full(full),
	.empty(empty)
	);

////////////////////////////////////////////////////////////////////
//
// Read/Write Pointers Logic
//
// ---------- full flag logic module------

wptr_full  wptr_full(.full(full), .wr_addr(wr_addr),.wr_ptr(wr_ptr), .rd_ptr_sync(rd_ptr_s),.wr_inc(wr_en), .wr_clk(wr_clk),.wr_rst(rst));
//  ----- synchronizer read to write module----
sync_r2w sync_r2w (.rd_ptr_sync(rd_ptr_s), .rd_ptr(rd_ptr), .wr_clk(wr_clk), .wr_rst(rst));
//------ synchronizer write to read module-------
sync_w2r sync_w2r (.wr_ptr_sync(wr_ptr_s), .wr_ptr(wr_ptr),.rd_clk(rd_clk), .rd_rst(rst));
//------- assign empty flag module--------
rptr_empty  rptr_empty(.empty(empty),.rd_addr(rd_addr),.rd_ptr(rd_ptr), .wr_ptr_sync(wr_ptr_s),.rd_inc(rd_en),.wr_inc(wr_en), 
                       .rd_clk(rd_clk),.rd_rst(rst));



//
// Sanity Check
//
// synopsys translate_off
always @(posedge wr_clk)
	if(wr_en & full)
		$display("%m WARNING: Writing while fifo is FULL (%t)",$time);

always @(posedge rd_clk)
	if(rd_en & empty)
		$display("%m WARNING: Reading while fifo is EMPTY (%t)",$time);
// synopsys translate_on

endmodule
