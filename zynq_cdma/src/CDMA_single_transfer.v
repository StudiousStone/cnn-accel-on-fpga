/*
* Created           : cheng liu
* Date              : 2016-06-23
* Email             : st.liucheng@gmail.com
*
* Description:
* The module is used to wrap the CDMA core to allow user logic 
* doing a single DMA transfer.
* 
*/

`timescale 1 ns / 1 ps

module CDMA_Single_Transfer #(
    // Width of S_AXI data bus
    parameter integer DATA_WIDTH	= 32,
    // Width of S_AXI address bus
    parameter integer ADDR_WIDTH	= 32
    )(
    // Users to add ports here
    input [ADDR_WIDTH-1: 0]            src_addr,
    input [ADDR_WIDTH-1: 0]            dst_addr,
    input [ADDR_WIDTH-1: 0]            trans_len,
    input                              CDMA_start,
    output                             CDMA_done,

    input                              clk,
    input                              rst
);
    localparam AXI_LITE_WIDTH = 6; // Width of the axi_lite register address
    localparam DEFAULT_CDMACR = 'h0000_1000;
    localparam CLEAR_IR_CDMASR = 'h0000_1000;
    localparam MAX_CNT = 24;

    reg [ADDR_WIDTH-1: 0]              src_addr_reg;
    reg [ADDR_WIDTH-1: 0]              dst_addr_reg;
    reg [ADDR_WIDTH-1: 0]              trans_len_reg;
    reg [7: 0]                         counter;
    wire                               CDMA_done_tmp;
    reg                                CDMA_done_reg;
    reg                                CDMA_done_reg2;
    reg                                CDMA_introut_reg;
    wire                               CDMA_introut;

    // to AXI Lite   
    reg [AXI_LITE_WIDTH-1: 0]          S_AXI_LITE_araddr;
    reg                                S_AXI_LITE_arvalid;
    wire                               S_AXI_LITE_arready;

    reg [AXI_LITE_WIDTH-1:0]           S_AXI_LITE_awaddr;
    wire                               S_AXI_LITE_awready;
    reg                                S_AXI_LITE_awvalid;

    wire                               S_AXI_LITE_bready;
    wire [1:0]                         S_AXI_LITE_bresp;
    wire                               S_AXI_LITE_bvalid;

    wire [DATA_WIDTH-1: 0]             S_AXI_LITE_rdata;
    reg                                S_AXI_LITE_rready;
    wire [1:0]                         S_AXI_LITE_rresp;
    wire                               S_AXI_LITE_rvalid;

    reg [DATA_WIDTH-1:0]               S_AXI_LITE_wdata;
    wire                               S_AXI_LITE_wready;
    reg                                S_AXI_LITE_wvalid;

    // Get CDMA posedge of CDMA interruption out
    always@(posedge clk) begin
        CDMA_introut_reg <= CDMA_introut;
        CDMA_done_reg <= CDMA_done_tmp;
        CDMA_done_reg2 <= CDMA_done_reg;
    end
    assign CDMA_done_tmp = CDMA_introut && (~CDMA_introut_reg);
    assign CDMA_done = CDMA_done_reg2;

    // This counter is used to control the CDMA configuration 
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= 0;
        end
        else if(CDMA_start || (counter > 0 && counter < MAX_CNT)) begin
            counter <= counter + 1;
        end 
        else if(counter == MAX_CNT) begin
            counter <= 0;
        end
    end

    // lock the configuration information
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

    assign S_AXI_LITE_bready = 1'b1;

    // Configure the CDMA
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            S_AXI_LITE_awaddr <= 0;
            S_AXI_LITE_awvalid <= 1'b0;
            S_AXI_LITE_wdata <= 0;
            S_AXI_LITE_wvalid <= 1'b0;
        end
        else if(counter == 1) begin
            S_AXI_LITE_awaddr <= 'h0;
            S_AXI_LITE_awvalid <= 1'b1;
            S_AXI_LITE_wdata <= DEFAULT_CDMACR;
            S_AXI_LITE_wvalid <= 1'b1;            
        end
        else if(counter > 1 && counter <= 5) begin
            S_AXI_LITE_awvalid <= 1'b0;
            S_AXI_LITE_wvalid <= 1'b0;
        end
        else if(counter == 6) begin
            S_AXI_LITE_awaddr <= 'h18;
            S_AXI_LITE_awvalid <= 1'b1;
            S_AXI_LITE_wdata <= src_addr_reg;
            S_AXI_LITE_wvalid <= 1'b1;            
        end
        else if(counter > 6 && counter <= 10) begin
            S_AXI_LITE_awvalid <= 1'b0;
            S_AXI_LITE_wvalid <= 1'b0;
        end
        else if(counter == 11) begin
            S_AXI_LITE_awaddr <= 'h20;
            S_AXI_LITE_awvalid <= 1'b1;
            S_AXI_LITE_wdata <= dst_addr_reg;
            S_AXI_LITE_wvalid <= 1'b1;            
        end
        else if(counter > 11 && counter <= 15) begin
            S_AXI_LITE_awvalid <= 1'b0;
            S_AXI_LITE_wvalid <= 1'b0;
        end
        else if(counter == 16) begin
            S_AXI_LITE_awaddr <= 'h28;
            S_AXI_LITE_awvalid <= 1'b1;
            S_AXI_LITE_wdata <= {14'b0, (trans_len_reg << 2)};
            S_AXI_LITE_wvalid <= 1'b1;            
        end
        else if(counter > 16 && counter <= 20) begin
            S_AXI_LITE_awvalid <= 1'b0;
            S_AXI_LITE_wvalid <= 1'b0;            
        end
        
        // Clear the interruption to enable new CDMA interruption
        if(CDMA_done_tmp) begin
            S_AXI_LITE_awaddr <= 'h04;
            S_AXI_LITE_awvalid <= 1'b1;
            S_AXI_LITE_wdata <= CLEAR_IR_CDMASR;
            S_AXI_LITE_wvalid <= 1'b1;
        end
        else if(CDMA_done_reg || CDMA_done_reg2) begin
            S_AXI_LITE_awvalid <= 1'b0;
            S_AXI_LITE_wvalid <= 1'b0;
        end
    end

    // CDMA IP core for verification.
    // the block ram as well as the corresponding AXI controller in this IP 
    // can be removed and the AXI master can be attached to system bus directly.
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

        .cdma_introut           (CDMA_introut),

        .rst                    (rst),
        .rst_n                  (~rst),
        .clk                    (clk)
    );

endmodule
