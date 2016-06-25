/*
* Created           : cheng liu
* Date              : 2016-06-23
* Email             : st.liucheng@gmail.com
*
* Description:
* CDMA verification top 
* 
* 
*/

`timescale 1 ns / 1 ps
module CDMA_tb;

parameter CLK_PERIOD = 10;
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 32;
parameter CUBE_WIDTH = 6;

reg                                    clk;
reg                                    rst;

reg [ADDR_WIDTH-1: 0]                  src_base_addr;
reg [ADDR_WIDTH-1: 0]                  dst_base_addr;
reg [CUBE_WIDTH-1: 0]                  channel;
reg [CUBE_WIDTH-1: 0]                  row;
reg [CUBE_WIDTH-1: 0]                  col;
reg [CUBE_WIDTH-1: 0]                  channel_offset;
reg [CUBE_WIDTH-1: 0]                  row_offset;

reg                                    transfer_start;
wire                                   transfer_done;

always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    src_base_addr = 32'h0;
    dst_base_addr = 32'h0;
    channel_offset = 'h8;
    row_offset = 'h2;
    channel = 'h2;
    row = 'h4;
    col = 'h6;
    transfer_start = 1'b0;

    repeat(10) begin 
        @(posedge clk);
    end
    rst = 0;
    
    repeat(100) begin
        @(posedge clk);
    end
    src_base_addr = 32'h0000_1000;
    dst_base_addr = 32'h0000_2000;
    
    @(posedge clk)
    transfer_start = 1'b1;
    
    @(posedge clk)
    transfer_start = 1'b0;
    
    #12000

    $finish;
end

CDMA_wrapper #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH),
    .CUBE_WIDTH (CUBE_WIDTH)
) CDMA_wrapper (
		// Users to add ports here
        .src_base_addr       (src_base_addr),
        .dst_base_addr       (dst_base_addr),
        .channel             (channel),
        .row                 (row),
        .col                 (col),
        .channel_offset      (channel_offset),
        .row_offset          (row_offset),

        .transfer_start      (transfer_start),
        .transfer_done       (transfer_done),

        .clk                 (clk),
        .rst                 (rst)
    );	
   
endmodule
