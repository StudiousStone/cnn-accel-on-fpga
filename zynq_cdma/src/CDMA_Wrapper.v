/*
* Created           : cheng liu
* Date              : 2016-06-23
* Email             : st.liucheng@gmail.com
*
* Description:
* The module is used to perform multiple CDMA transfers until a 3D cube of data 
* is transmitted.
* 
*/

`timescale 1 ns / 1 ps

module CDMA_wrapper #(
    // Width of S_AXI data bus
    parameter integer DATA_WIDTH	= 32,
    // Width of S_AXI address bus
    parameter integer ADDR_WIDTH	= 32,
    // Width of 3D cube dimension size
    parameter integer CUBE_WIDTH    = 16
    )(
    // Transfer parameters
    input [ADDR_WIDTH-1: 0]            src_base_addr,
    input [ADDR_WIDTH-1: 0]            dst_base_addr,
    input [CUBE_WIDTH-1: 0]            channel,
    input [CUBE_WIDTH-1: 0]            row,
    input [CUBE_WIDTH-1: 0]            col,
    input [CUBE_WIDTH-1: 0]            channel_offset,
    input [CUBE_WIDTH-1: 0]            row_offset,

    // Transfer control signals
    input                              transfer_start,
    output                             transfer_done,

    // System signal
    input                              clk,
    input                              rst

);
    localparam MAX_CNT = 16;

    reg [ADDR_WIDTH-1: 0]              src_base_addr_reg;
    reg [ADDR_WIDTH-1: 0]              dst_base_addr_reg;
    reg [CUBE_WIDTH-1: 0]              channel_reg;
    reg [CUBE_WIDTH-1: 0]              row_reg;
    reg [CUBE_WIDTH-1: 0]              col_reg;
    reg [CUBE_WIDTH-1: 0]              channel_offset_reg;
    reg [CUBE_WIDTH-1: 0]              row_offset_reg;

    reg [ADDR_WIDTH-1: 0]              src_addr;
    reg [ADDR_WIDTH-1: 0]              dst_addr;
    reg [ADDR_WIDTH-1: 0]              trans_len;

    wire                               CDMA_start;
    wire                               CDMA_done;

    reg [CUBE_WIDTH-1: 0]              channel_counter;
    reg [CUBE_WIDTH-1: 0]              row_counter;
    wire                               channel_done;
    reg                                transfer_done_reg;
    reg                                CDMA_done_reg;
    wire                               CDMA_start_tmp;
    reg                                CDMA_start_reg;
    reg                                transfer_start_reg;
    wire [ADDR_WIDTH-1: 0]             addr_offset;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            CDMA_done_reg <= 1'b0;
            transfer_done_reg <= 1'b0;
            CDMA_start_reg <= 1'b0;
            transfer_start_reg <= 1'b0;
        end
        else begin
            CDMA_done_reg <= CDMA_done;
            transfer_done_reg <= transfer_done;
            CDMA_start_reg <= CDMA_start_tmp;
            transfer_start_reg <= transfer_start;
        end
    end

    // Lock input parameters
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            src_base_addr_reg <= 0;
            dst_base_addr_reg <= 0;
            channel_reg <= 0;
            row_reg <= 0;
            col_reg <= 0;
            channel_offset_reg <= 0;
            row_offset_reg <= 0;
        end
        else if(transfer_start) begin
            src_base_addr_reg <= src_base_addr;
            dst_base_addr_reg <= dst_base_addr;
            channel_reg <= channel;
            row_reg <= row;
            col_reg <= col;
            channel_offset_reg <= channel_offset;
            row_offset_reg <= row_offset;
        end
        else if(transfer_done) begin
            src_base_addr_reg <= 0;
            dst_base_addr_reg <= 0;
            channel_reg <= 0;
            row_reg <= 0;
            col_reg <= 0;
            channel_offset_reg <= 0;
            row_offset_reg <= 0;
        end
    end

    // Nested counter that are used to perform channel * row CDMA transfers.
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            row_counter <= 0;
        end
        else if(CDMA_done && (row_counter < (row_reg -1))) begin
            row_counter <= row_counter + 1;
        end 
        else if(CDMA_done && (row_counter == (row_reg -1))) begin
            row_counter <= 0;
        end
    end

    assign channel_done = CDMA_done && row_counter == (row_reg - 1);
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            channel_counter <= 0;
        end
        else if(channel_done && (channel_counter < (channel_reg - 1))) begin
            channel_counter <= channel_counter + 1;
        end
        else if(channel_done && (channel_counter == (channel_reg - 1))) begin
            channel_counter <= 0;
        end
    end

    assign transfer_done = channel_done && (channel_counter == (channel_reg - 1));
    assign CDMA_start_tmp = (transfer_start_reg || (CDMA_done_reg && (~transfer_done_reg)));
    assign CDMA_start = CDMA_start_reg;

    // lock the configuration information
    assign addr_offset = channel_counter * (row_reg * (col_reg + row_offset) + channel_offset) + row_counter * (col_reg + row_offset);
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            src_addr <= 0;
            dst_addr <= 0;
            trans_len <= 0;
        end
        else if(CDMA_start_tmp) begin
            src_addr <= src_base_addr_reg + (addr_offset << 2); 
            dst_addr <= dst_base_addr_reg + (addr_offset << 2);
            trans_len <= col_reg;
        end
        else if(CDMA_done) begin
            src_addr <= 0;
            dst_addr <= 0;
            trans_len <= 0;
        end
    end

    CDMA_Single_Transfer #(
        .DATA_WIDTH	(DATA_WIDTH),
        .ADDR_WIDTH	(ADDR_WIDTH)
    ) CDMA_Single_Transfer (
        .src_addr   (src_addr),
        .dst_addr   (dst_addr),
        .trans_len  (trans_len),

        .CDMA_start (CDMA_start),
        .CDMA_done  (CDMA_done),

        .clk        (clk),
        .rst        (rst)
    );

endmodule
