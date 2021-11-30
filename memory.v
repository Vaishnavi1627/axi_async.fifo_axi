`define VENDOR_FPGA
//`define VENDOR_XILINX
//`define VENDOR_ALTERA

module generic_dpram(
	// Generic synchronous dual-port RAM interface
	rclk, rce, oe, raddr, do,
	wclk,  wce, wr_en, waddr, di,rd_en,full, empty
);

	//
	// Default address and data buses width
	//
	parameter aw = 3;  // number of bits in address-bus
	parameter dw = 8; // number of bits in data-bus

	//
	// Generic synchronous double-port RAM interface
	//
	// read port
	input           rclk;  // read clock, rising edge trigger	
	input           rce;   // read port chip enable, active high
	input           oe;	   // output enable, active high
	input  [aw-1:0] raddr; // read address
	output [dw-1:0] do;    // data output
    input full, empty;
	// write port
	input          wclk;  // write clock, rising edge trigger
	
	input          wce;   // write port chip enable, active high
	input          wr_en;    // write enable, active high
	input          rd_en;
	input [aw-1:0] waddr; // write address
	input [dw-1:0] di;    // data input


	// Generic dual-port synchronous RAM model
	
	// Generic RAM's registers and wires
	//
	reg	[dw-1:0]	mem [(1<<aw)-1:0]; // RAM content
	reg	[dw-1:0]	do_reg;            // RAM data output register

	//
	// Data output drivers
	//
	assign do = (oe & rce) ? do_reg : {dw{1'bz}};

	// read operation
	always @(posedge rclk)
		if (rce && rd_en && !empty)
          		do_reg <=   mem[raddr];

	// write operation
	always @(posedge wclk)
		if (wce && wr_en && !full)
			mem[waddr] <=  di;


endmodule
