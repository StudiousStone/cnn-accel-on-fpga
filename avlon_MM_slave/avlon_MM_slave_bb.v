
module avlon_MM_slave (
	clk,
	reset,
	avs_writedata,
	avs_beginbursttransfer,
	avs_burstcount,
	avs_readdata,
	avs_address,
	avs_waitrequest,
	avs_write,
	avs_read,
	avs_readdatavalid);	

	input		clk;
	input		reset;
	input	[127:0]	avs_writedata;
	input		avs_beginbursttransfer;
	input	[9:0]	avs_burstcount;
	output	[127:0]	avs_readdata;
	input	[31:0]	avs_address;
	output		avs_waitrequest;
	input		avs_write;
	input		avs_read;
	output		avs_readdatavalid;
endmodule
