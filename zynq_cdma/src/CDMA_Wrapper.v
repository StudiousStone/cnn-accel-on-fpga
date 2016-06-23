/*
* Created           : cheng liu
* Date              : 2016-06-23
* Email             : st.liucheng@gmail.com
*
* Description:
* The module is used to pack the CDMA core to allow user logic 
* doing multiple DMA transfers for a 3D data block. This could be 
* further optimized by enabling the SG functionality of the CDMA core.
* 
*/

`timescale 1 ns / 1 ps

	module CDMA_Wrapper #(
		// Width of S_AXI data bus
		parameter integer DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer ADDR_WIDTH	= 32,
        // Width of the data transfer length
        parameter TRANS_WIDTH = 16
	)(
		// Users to add ports here
        input [ADDR_WIDTH-1: 0]  src_addr,
        input [ADDR_WIDTH-1: 0]  dst_addr,
        input [TRANS_WIDTH-1: 0]         trans_len,
        input                            CDMA_start,
        output                           CDMA_done,
        input                            clk,
        input                            rst,

        // to AXI Lite 
        output   [ADDR_WIDTH-1: 0]     S_AXI_LITE_araddr,
        output                        S_AXI_LITE_arvalid,
        input                            S_AXI_LITE_arready,

        output reg [ADDR_WIDTH-1:0]      S_AXI_LITE_awaddr,
        input                            S_AXI_LITE_awready,
        output reg                       S_AXI_LITE_awvalid,

        output wire                      S_AXI_LITE_bready,
        input [1:0]                      S_AXI_LITE_bresp,
        input                            S_AXI_LITE_bvalid,

        input [DATA_WIDTH-1: 0]  S_AXI_LITE_rdata,
        output wire                      S_AXI_LITE_rready,
        input [1:0]                      S_AXI_LITE_rresp,
        input                            S_AXI_LITE_rvalid,

        output reg [DATA_WIDTH-1:0]  S_AXI_LITE_wdata,
        input                            S_AXI_LITE_wready,
        output reg                      S_AXI_LITE_wvalid

	);

    localparam integer ADDR_LSB = (DATA_WIDTH/32) + 1;
    localparam DEFAULT_CDMACR = 32'h0;
    
    reg [ADDR_WIDTH-1: 0]      src_addr_reg;
    reg [ADDR_WIDTH-1: 0]      dst_addr_reg;
    reg [TRANS_WIDTH-1: 0]             trans_len_reg;
    reg                                CDMA_start_d1;
    reg                                CDMA_start_d2;
    reg                                CDMA_start_d3;
    reg                                CDMA_start_d4;

    always@(posedge clk) begin
        CDMA_start_d1 <= CDMA_start;
        CDMA_start_d2 <= CDMA_start_d1;
        CDMA_start_d3 <= CDMA_start_d2;
        CDMA_start_d4 <= CDMA_start_d3;
    end
    assign CDMA_done = CDMA_start_d4;

    // local data movement addresses
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            src_addr_reg <= 0;
            dst_addr_reg <= 0;
            trans_len_reg <= 0;
        end
        else if(CDMA_start) begin
            src_addr_reg <= src_addr;
            dst_addr_reg <= dst_addr;
            trans_len_reg <= trans_len;
        end
        else if(CDMA_done) begin
            src_addr_reg <= 0;
            dst_addr_reg <= 0;
            trans_len_reg <= 0;
        end
    end

    //    output [REG_NUM_WIDTH-1:0]       S_AXI_LITE_awaddr,
    //    input                            S_AXI_LITE_awready,
    //    output                           S_AXI_LITE_awvalid,
    //    output                           S_AXI_LITE_bready,
    //    input [1:0]                      S_AXI_LITE_bresp,
    //    input                            S_AXI_LITE_bvalid,
    //    output [C_S_AXI_DATA_WIDTH-1:0]  S_AXI_LITE_wdata,
    //    input                            S_AXI_LITE_wready,
    //    output                           S_AXI_LITE_wvalid

    assign S_AXI_LITE_bready = 1'b1;
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            S_AXI_LITE_awaddr <= 0;
            S_AXI_LITE_awvalid <= 0;
        end
        else if(S_AXI_LITE_awready && CDMA_start) begin
            S_AXI_LITE_awaddr <= 32'h0;
            S_AXI_LITE_awvalid <= 1'b1;
        end
        else if(S_AXI_LITE_awready && CDMA_start_d1) begin
            S_AXI_LITE_awaddr <= 32'h18;
        end
        else if(S_AXI_LITE_awready && CDMA_start_d2) begin
            S_AXI_LITE_awaddr <= 32'h20;
        end
        else if(S_AXI_LITE_awready && CDMA_start_d3) begin
            S_AXI_LITE_awaddr <= 32'h28;
        end
        else if(CDMA_done) begin
            S_AXI_LITE_awaddr <= 0;
            S_AXI_LITE_awvalid <= 1'b0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            S_AXI_LITE_wdata <= 0;
            S_AXI_LITE_wvalid <= 1'b0;
        end
        else if(S_AXI_LITE_wready && CDMA_start) begin
            S_AXI_LITE_wdata <= DEFAULT_CDMACR;
            S_AXI_LITE_wvalid <= 1'b1;
        end
        else if(S_AXI_LITE_wready && CDMA_start_d1) begin
            S_AXI_LITE_wdata <= src_addr_reg;
            S_AXI_LITE_wvalid <= 1'b1;
        end        
        else if(S_AXI_LITE_wready && CDMA_start_d2) begin
            S_AXI_LITE_wdata <= dst_addr_reg;
            S_AXI_LITE_wvalid <= 1'b1;
        end        
        else if(S_AXI_LITE_wready && CDMA_start_d3) begin
            S_AXI_LITE_wdata <= {14'b0, (trans_len_reg << 2)};
            S_AXI_LITE_wvalid <= 1'b1;
        end        
        else if(CDMA_done) begin
            S_AXI_LITE_wdata <= 0;
            S_AXI_LITE_wvalid <= 1'b0;
        end
    end


    //    output [REG_NUM_WIDTH-1: 0]      S_AXI_LITE_araddr,
    //    output                           S_AXI_LITE_arvalid,
    //    input                            S_AXI_LITE_arready,
    //    input [C_S_AXI_DATA_WIDTH-1: 0]  S_AXI_LITE_rdata,
    //    output                           S_AXI_LITE_rready,
    //    input [1:0]                      S_AXI_LITE_rresp,
    //    input                            S_AXI_LITE_rvalid,
    assign S_AXI_LITE_araddr = 0;
    assign S_AXI_LITE_arvalid = 1'b0;
    assign S_AXI_LITE_rready = 1'b0;

endmodule
