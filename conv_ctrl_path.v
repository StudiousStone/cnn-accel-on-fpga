/*
* Created           : cheng liu
* Date              : 2016-05-17
*
* Description:
* 
* It basically divides the convolution into three different levels.
* In the first layer (kernel), 2D convolution over X * Tr * Tc is done.
*
* In the second layer (slice), it repeats the first layer 
* until all the input channels in the tile is convolved (iteration_num = Tm/X).
* 
* In the third layer (block), it repeats the second layer 
* untill all the output channels in the tile is convolved (Tn/Y). 
* 
* Instance example
*
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module conv_ctrl_path #(
    parameter AW = 16,
    parameter Tn = 16,
    parameter Tm = 16,
    parameter Tr = 64,
    parameter Tc = 16,
    parameter K = 3,
    parameter S = 1,
    parameter X = 4,
    parameter Y = 4,
    parameter FP_MUL_DELAY = 11,
    parameter FP_ADD_DELAY = 14,
    parameter FP_ACCUM_DELAY = 9

)(
    input                              conv_start,
    output                             conv_done,
    output                             kernel_start,

    output reg               [AW-1: 0] in_fm_rd_addr,
    output reg               [AW-1: 0] weight_rd_addr,
    output reg               [AW-1: 0] out_fm_rd_addr,
    output                   [AW-1: 0] out_fm_wr_addr,
    output                             out_fm_wr_ena,

    input                              clk,
    input                              rst
);
    // # of computing cycles from the perspective of input_fm
    localparam kernel_size = K * K; 
    localparam slice_size = ((Tr+S-K)/S) * ((Tc+S-K)/S) * kernel_size; 
    localparam block_size = slice_size * (Tm/X);
    localparam tile_size = block_size * (Tn/Y);
    localparam out_rd_to_out_wr = 2;
    localparam in_to_out_rd = FP_MUL_DELAY + 2 * FP_ADD_DELAY 
                              + FP_ACCUM_DELAY + FP_ADD_DELAY + K * K;

    reg                                conv_start_reg;
    wire                               conv_start_edge;
    reg                                conv_done_reg;
    wire                               conv_done_edge;
    reg                                conv_on_going;
    wire                               kernel_done;
    wire                               slice_done;
    wire                               block_done;
    wire                               out_fm_rd_ena;

    reg                         [7: 0] kernel_cnt; // operation counter for each kernel computing
    reg                      [DW-1: 0] slice_cnt;  // operation counter for each slice computing
    reg                      [DW-1: 0] block_cnt;  // operation counter for each block computing
    reg                      [DW-1: 0] tile_cnt;   // operation counter for the whole tile computing
    reg                        [15: 0] row;
    reg                        [15: 0] col;
    reg                        [15: 0] Ti;
    reg                         [7: 0] i;
    reg                         [7: 0] j;
    reg                        [15: 0] slice_id;
    reg                        [15: 0] block_id;

    // The counter can be smaller by creating nested counters, but the dependence makes the debugging slightly difficult.
    // Nested counters will be used when the basic convolution functionality is achived.
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            tile_cnt <= 0;
        end
        else if(conv_on_going == 1'b1 && tile_cnt < tile_size - 1) begin
            tile_cnt <= tile_cnt + 1;
        end
        else if(tile_cnt == tile_size -1) begin
            tile_cnt <= 0;
        end
    end

    assign conv_done = (tile_cnt == tile_size - 1);

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            block_cnt <= 0;
        end
        else if(conv_on_going == 1'b1 && block_cnt < block_size - 1) begin
            block_cnt <= block_cnt + 1;
        end
        else if(block_done == 1'b1 || conv_done_edge == 1'b1) begin
            block_cnt <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            block_id <= 0;
        end
        else if(block_done == 1'b1 && conv_done_edge == 1'b0) begin
            block_id <= block_id + 1;
        end
        else if(conv_done_edge == 1'b1) begin
            block_id <= 0;
        end
    end

    assign block_done = (block_cnt == block_size - 1) && (conv_on_going == 1'b1);

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            col <= 0;
        end
        else if((kernel_done == 1'b1) && (col < Tc - K)) begin
            col <= col + S;
        end
        else if ((kernel_done == 1'b1) && (col == Tc - K)) begin
            col <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            row <= 0;
        end
        else if(kernel_done == 1'b1 && col == Tc - K && block_done == 1'b0) begin
            row <= row + S;
        end
        else if(block_done == 1'b1 || conv_done_edge == 1'b1) begin
            row <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            j <= 0;
        end
        else if(conv_on_going == 1'b1 && j < K - 1) begin
            j <= j + 1;
        end
        else if(j == K - 1 || conv_done_edge == 1'b1) begin
            j <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            i <= 0;
        end
        else if(j == K - 1 && i < K - 1) begin
            i <= i + 1;
        end
        else if(i == K - 1 || conv_done_edge == 1'b1) begin
            i <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            kernel_cnt <= 0;
        end
        else if(conv_on_going == 1'b1 && kernel_cnt < (kernel_size - 1)) begin
            kernel_cnt <= kernel_cnt + 1;
        end
        else if(kernel_cnt == (kernel_size-1) || conv_done_edge == 1'b1) begin
            kernel_cnt <= 0;
        end
    end

    assign kernel_start = (kernel_cnt == 0) && (conv_on_going == 1'b1);
    assign kernel_done = (kernel_cnt == kernel_size - 1);

    always@(posedge clk) begin
        conv_start_reg <= conv_start;
        conv_done_reg <= conv_done;
    end
    assign conv_start_edge = conv_start && (~conv_start_reg);
    assign conv_done_edge = conv_done && (~conv_done_reg);

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            conv_on_going <= 1'b0;
        end
        else if(conv_start_edge == 1'b1) begin
            conv_on_going <= 1'b1;
        end
        else if(conv_done_edge == 1'b1) begin
            conv_on_going <= 1'b0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            slice_cnt <= 0;
        end
        else if(conv_on_going == 1'b1 && slice_cnt < (slice_size - 1)) begin
            slice_cnt <= slice_cnt + 1;
        end
        else if((slice_done == 1'b1) || (conv_done_edge == 1'b1)) begin
            slice_cnt <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            slice_id <= 0;
        end
        else if((slice_done == 1'b1) && (conv_done_edge == 1'b0)) begin
            slice_id <= slice_id + 1;
        end
        else if(conv_done_edge == 1'b1) begin
            slice_id <= 0;
        end
    end

    assign slice_done = (slice_cnt == slice_size - 1) && (conv_on_going == 1'b1);

    // Calculate input_fm buffer read address
    // The address calculation can be further optimized through a numer of methods such as pipelining and constant optimization
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            in_fm_rd_addr <= 0;
        end
        else begin
            in_fm_rd_addr <= (row + i) * Tc + (col + j);
        end
    end

    // calculate weight buffer read address
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            weight_rd_addr <= 0;
        end
        else begin
            weight_rd_addr <= slice_id * kernel_size + i * K + j;
        end
    end

    // Calculate out_fm read and write addresses.
    // As the read and write are done sequentially, the addresses are essentially obtained from a counter.  
    sig_delay # (
        .D (in_to_out_rd)
    ) sig_delay0 (
        .sig_in (kernel_start),
        .sig_out (out_fm_rd_ena),

        .clk (clk),
        .rst (rst)
    );

    sig_delay # (
        .D (out_rd_to_out_wr)
    ) sig_delay1 (
        .sig_in (out_fm_rd_ena),
        .sig_out (out_fm_wr_ena),

        .clk (clk),
        .rst (rst)
    );

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            out_fm_rd_addr <= 0;
        end
        else if(out_fm_rd_ena == 1'b1) begin
            out_fm_rd_addr <= out_fm_rd_addr + 1;
        end
        else if(conv_done_edge == 1'b1) begin
            out_fm_rd_addr <= 0;
        end
    end

    data_delay #(
        .D (out_rd_to_out_wr),
        .DW (16)
    ) data_delay0 (
        .data_in (out_fm_rd_addr),
        .data_out (out_fm_wr_addr),

        .clk (clk)
    );

endmodule
