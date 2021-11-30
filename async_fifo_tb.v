module test;
///////////////////////////////////////////////////////////////////
// Local IOs and Vars
reg		clk;
reg		rd_clk, wr_clk;
reg		rst;

///////////////////////////////////////////////////////////////////
// Misc test Development vars
integer		x,rwd;
reg		    we2, re2;
reg	   [7:0]din2;
wire   [7:0]dout2;
wire		full2, empty2;
reg	   [7:0]buffer[0:1024];
integer		wrp, rdp;

reg  valid_in1;
reg  ready_in2;
wire valid_out2;
wire ready_out1;

///////////////////////////////////////////////////////////////////
// Module Instantiations
generic_fifo_dc #() u1(
		.rd_clk(rd_clk),
		.wr_clk(wr_clk),
		.rst(rst),		
		.data_in(din2),
		.wr_en((we2 & !full2)),
		.data_out(dout2),
		.rd_en((re2 & !empty2)),
		.full(full2),
		.empty(empty2),
		.valid_in1(valid_in1),
        .ready_in2(ready_in2),
        .valid_out2(valid_out2),
        .ready_out1(ready_out1)
		);
		
///////////////////////////////////////////////////////////////////
// Initial Startup and Simulation Begin

real		rcp;

initial
   begin
	$timeformat (-9, 1, " ns", 12);

`ifdef WAVES
  	$shm_open("waves");
	$shm_probe("AS",test,"AS");
	$display("INFO: Signal dump enabled ...\n\n");
`endif

	rcp = 5;   	clk = 0;   	rd_clk = 0;   	wr_clk = 0;   	rst = 1;	

	we2 = 0;	re2 = 0;

	rwd = 0;	    wrp = 0;	  rdp = 0; valid_in1 = 1;   ready_in2 = 1;

   	repeat(10)	@(posedge clk);
   	rst = 0;
   	repeat(10)	@(posedge clk);
   	rst = 1;
   	repeat(10)	@(posedge clk);


	if(1)
	   begin
		test_dc_fifo;
	   end
	else
	   begin

		rwd = 4;
		wr_dc(8);
		rd_dc(8);
		wr_dc(8);
		rd_dc(8);

	   end


   	repeat(500)	@(posedge clk);

$display("rdp=%0d, wrp=%0d delta=%0d", rdp, wrp, wrp-rdp);

   	$finish;
   end

///////////////////////////////////////////////////////////////////
// TASK test_dc_fifo

task test_dc_fifo;
begin

$display("\n\n");
$display("*****************************************************");
$display("*** DC FIFO Sanity Test                           ***");
$display("*****************************************************\n");

for(rwd=0;rwd<5;rwd=rwd+1)	// read write delay
for(rcp=10;rcp<100;rcp=rcp+10.0)
   begin
	$display("rwd=%0d, rcp=%0f",rwd, rcp);

	$display("pass 0 ...");
	for(x=0;x<8;x=x+1)
	   begin
		//rd_wr_dc;
		wr_dc(1);
	   end
	$display("pass 1 ...");
	for(x=0; x<8; x = x + 1)
	   begin
//		rd_wr_dc;
		rd_dc(1);
	   end

   end

$display("");
$display("*****************************************************");
$display("*** DC FIFO Sanity Test DONE                      ***");
$display("*****************************************************\n");
end
endtask
///////////////////////////////////////////////////////////////////
// read and write counters

always @(posedge wr_clk)
	if(we2 & !full2)
	   begin
		buffer[wrp] = din2;
		wrp = wrp+1;
	   end

always @(posedge rd_clk)
	if(re2 & !empty2)
	   begin
		#3;
		if(dout2 != buffer[rdp] | ( ^dout2 )=== 1'bx)
			$display("ERROR: Data (%0d) mismatch, expected %h got %h (%t)", rdp, buffer[rdp], dout2, $time);
		      rdp = rdp + 1;
	   end

///////////////////////////////////////////////////////////////////
//
// Clock generation
//

always #5 clk = ~clk;
always #150 rd_clk = ~rd_clk;
always #50 wr_clk = ~wr_clk;

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
// TASK wr_dc

task wr_dc;
input	cnt;
integer	n, cnt;

begin
@(posedge wr_clk);
for(n=0;n<cnt;n=n+1)
   begin
	#1;
	we2 = 1;
	din2 = $random;
	@(posedge wr_clk);
	#1;
	we2 = 0;
	din2 = 8'hxx;
	repeat(rwd)	@(posedge wr_clk);
   end
end
endtask
///////////////////////////////////////////////////////////////////
// TASK rd_dc


task rd_dc;
input	cnt;
integer	n, cnt;
begin
@(posedge rd_clk);
for(n = 0; n < cnt; n = n + 1)
   begin
	#1;
	re2 = 1;
	@(posedge rd_clk);
	#1;
	re2 = 0;
	repeat(rwd)	@(posedge rd_clk);
   end
end
endtask

///////////////////////////////////////////////////////////////////
// TASK rd_wr_dc

task rd_wr_dc;

integer		n;
begin
   		repeat(10)	@(posedge wr_clk);
		// RD/WR 1
		for(n=0;n<20;n=n+1)
		   fork

			begin
				wr_dc(1);
			end

			begin
				@(posedge wr_clk);
				@(posedge wr_clk);
				rd_dc(1);
			end

		   join

   		repeat(50)	@(posedge wr_clk);

		// RD/WR 2
		for(n=0;n<20;n=n+1)
		   fork

			begin
				wr_dc(2);
			end

			begin
				@(posedge wr_clk);
				@(posedge wr_clk);
				@(posedge wr_clk);
				rd_dc(2);
			end

		   join

   		repeat(50)	@(posedge wr_clk);


end
endtask
    
endmodule
