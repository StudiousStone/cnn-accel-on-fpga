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
parameter integer DATA_WIDTH	= 32;
// Width of S_AXI address bus
parameter integer ADDR_WIDTH    = 32;
// Width of the data transfer length
parameter TRANS_WIDTH = 16;

reg clk;
reg rst;

wire cdma_introut;
		// Users to add ports here
reg [ADDR_WIDTH-1: 0]  src_addr;
reg [ADDR_WIDTH-1: 0]  dst_addr;
reg [TRANS_WIDTH-1: 0]         trans_len;
reg                            CDMA_start;
wire                           CDMA_done;

// to AXI Lite 
wire [ADDR_WIDTH-1: 0]     S_AXI_LITE_araddr;
wire                       S_AXI_LITE_arvalid;
wire                            S_AXI_LITE_arready;

wire [ADDR_WIDTH-1:0]      S_AXI_LITE_awaddr;
wire                            S_AXI_LITE_awready;
wire                       S_AXI_LITE_awvalid;

wire                      S_AXI_LITE_bready;
wire [1:0]                      S_AXI_LITE_bresp;
wire                            S_AXI_LITE_bvalid;

wire [DATA_WIDTH-1: 0]  S_AXI_LITE_rdata;
wire                      S_AXI_LITE_rready;
wire [1:0]                      S_AXI_LITE_rresp;
wire                            S_AXI_LITE_rvalid;

wire [DATA_WIDTH-1:0]  S_AXI_LITE_wdata;
wire                            S_AXI_LITE_wready;
wire                      S_AXI_LITE_wvalid;

always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    src_addr = 32'h0;
    dst_addr = 32'h0;
    CDMA_start = 1'b0;
    trans_len = 64;
    repeat(10) begin 
        @(posedge clk);
    end
    rst = 0;
    
    repeat(10) begin
        @(posedge clk);
    end
    src_addr = 32'hC000_0000;
    dst_addr = 32'hC000_1000;
    
    @(posedge clk)
    CDMA_start = 1'b1;
    
    @(posedge clk)
    CDMA_start = 1'b0;
    
    repeat(1000) begin 
        @(posedge clk);
    end
    $stop(2);
end

CDMA_Wrapper #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH),
    .TRANS_WIDTH (TRANS_WIDTH)
) CDMA_Wrapper (
		// Users to add ports here
        .src_addr (src_addr),
        .dst_addr (dst_addr),
        .trans_len (trans_len),
        .CDMA_start (CDMA_start),
        .CDMA_done (CDMA_done),
        .clk (clk),
        .rst (rst),

        // to AXI Lite 
        .S_AXI_LITE_araddr  (S_AXI_LITE_araddr),
        .S_AXI_LITE_arvalid (S_AXI_LITE_arvalid),
        .S_AXI_LITE_arready (S_AXI_LITE_arready),

        .S_AXI_LITE_awaddr (S_AXI_LITE_awaddr),
        .S_AXI_LITE_awready (S_AXI_LITE_awready),
        .S_AXI_LITE_awvalid (S_AXI_LITE_awvalid),

        .S_AXI_LITE_bready (S_AXI_LITE_bready),
        .S_AXI_LITE_bresp  (S_AXI_LITE_bresp),
        .S_AXI_LITE_bvalid (S_AXI_LITE_bvalid),

        .S_AXI_LITE_rdata  (S_AXI_LITE_rdata),
        .S_AXI_LITE_rready (S_AXI_LITE_rready),
        .S_AXI_LITE_rresp  (S_AXI_LITE_rresp),
        .S_AXI_LITE_rvalid (S_AXI_LITE_rvalid),

        .S_AXI_LITE_wdata  (S_AXI_LITE_wdata),
        .S_AXI_LITE_wready (S_AXI_LITE_wready),
        .S_AXI_LITE_wvalid (S_AXI_LITE_wvalid)

	);
	
cdma_sim_wrapper cdma_sim_wrapper (
    .S_AXI_LITE_araddr      (S_AXI_LITE_araddr),
    .S_AXI_LITE_arready     (S_AXI_LITE_arready),
    .S_AXI_LITE_arvalid     (S_AXI_LITE_arvalid),
    .S_AXI_LITE_awaddr      (S_AXI_LITE_awaddr),
    .S_AXI_LITE_awready     (S_AXI_LITE_awready),
    .S_AXI_LITE_awvalid     (S_AXI_LITE_awvalid),
    .S_AXI_LITE_bready      (S_AXI_LITE_bready),
    .S_AXI_LITE_bresp       (S_AXI_LITE_bresp),
    .S_AXI_LITE_bvalid      (S_AXI_LITE_bvalid),
    .S_AXI_LITE_rdata       (S_AXI_LITE_rdata),
    .S_AXI_LITE_rready      (S_AXI_LITE_rready),
    .S_AXI_LITE_rresp       (S_AXI_LITE_rresp),
    .S_AXI_LITE_rvalid      (S_AXI_LITE_rvalid),
    .S_AXI_LITE_wdata       (S_AXI_LITE_wdata),
    .S_AXI_LITE_wready      (S_AXI_LITE_wready),
    .S_AXI_LITE_wvalid      (S_AXI_LITE_wvalid),
    .cdma_introut           (cdma_introut),
    .reset_rtl              (rst),
    .reset_rtl_0            (rst),
    .sys_clock              (clk)
    );
    
endmodule
