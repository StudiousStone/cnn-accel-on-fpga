/*
* Created           : cheng liu
* Date              : 2016-05-28
*
* Description:
* It updates the cordination of the tile when a tile of computing is done. 
* 
*
* Instance example:
    gen_tile_cord #(
        .AW (AW),
        .N (N),
        .M (M),
        .R (R),
        .C (C),
        .Tn (Tn),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),
        .K (K),
        .S (S)
    ) gen_tile_cord (
        .conv_tile_done (),

        .tile_base_n (),
        .tile_base_m (),
        .tile_base_row (),
        .tile_base_col (),

        .clk (clk),
        .rst (rst)
    );

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module gen_tile_cord #(
    parameter AW = 16,
    parameter N = 128,
    parameter M = 256,
    parameter R = 128,
    parameter C = 128,

    parameter Tn = 16,
    parameter Tm = 16,
    parameter Tr = 64,
    parameter Tc = 16,

    parameter K = 3,
    parameter S = 1

)(
    input                              conv_tile_done,

    output reg               [AW-1: 0] tile_base_n,
    output reg               [AW-1: 0] tile_base_m,
    output reg               [AW-1: 0] tile_base_row,
    output reg               [AW-1: 0] tile_base_col,

    input                              clk,
    input                              rst
);
    localparam tile_row_step = ((Tr + S - K) / S) * S;
    localparam tile_col_step = ((Tc + S - K) / S) * S;
    localparam R_step = ((R + S - K) / S) * S;
    localparam C_step = ((C + S - K) / S) * S;

    wire                               is_last_row;
    wire                               is_last_col;
    wire                               is_last_in_channel;
    wire                               is_last_out_channel;

    assign is_last_col = (tile_base_col + tile_col_step) >= C_step;
    assign is_last_row = (tile_base_row + tile_row_step) >= R_step;
    assign is_last_in_channel = (tile_base_m + Tm) >= M;
    assign is_last_out_channel = (tile_base_n + Tn) >= N;

    // Update cordination of the tile given conv_tile_done signal
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            tile_base_col <= 0;
        end
        else if(conv_tile_done == 1'b1 && is_last_col == 1'b0) begin
            tile_base_col <= tile_base_col + tile_col_step;
        end
        else if(conv_tile_done == 1'b1 && is_last_col == 1'b1) begin
            tile_base_col <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            tile_base_row <= 0;
        end
        else if(conv_tile_done == 1'b1 && is_last_col == 1'b0 && is_last_row == 1'b0) begin
            tile_base_row <= tile_base_row;
        end
        else if(conv_tile_done == 1'b1 && is_last_col == 1'b1 && is_last_row == 1'b0) begin
            tile_base_row <= tile_base_row + tile_row_step;
        end
        else if(conv_tile_done == 1'b1 && is_last_col == 1'b1 && is_last_row == 1'b1) begin
            tile_base_row <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            tile_base_m <= 0;
        end
        else if(conv_tile_done == 1'b1 && ((is_last_col == 1'b0) || (is_last_row == 1'b0))) begin
            tile_base_m <= tile_base_m;
        end
        else if(conv_tile_done == 1'b1 && (is_last_row == 1'b1) && (is_last_col == 1'b1) && (is_last_in_channel == 1'b0)) begin
            tile_base_m <= tile_base_m + Tm;
        end
        else if(conv_tile_done == 1'b1 && (is_last_row == 1'b1) && (is_last_col == 1'b1) && (is_last_in_channel == 1'b1)) begin
            tile_base_m <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            tile_base_n <= 0;
        end
        else if(conv_tile_done == 1'b1 && ((is_last_row == 1'b0) || (is_last_col == 1'b0) || (is_last_in_channel == 1'b0))) begin
            tile_base_n <= tile_base_n;
        end
        else if(conv_tile_done == 1'b1 && (is_last_row == 1'b1) && (is_last_col == 1'b1) && (is_last_in_channel == 1'b1) && (is_last_out_channel == 1'b0)) begin
            tile_base_n <= tile_base_n + Tn;
        end
        else if(conv_tile_done == 1'b1 && (is_last_row == 1'b1) && (is_last_col == 1'b1) && (is_last_in_channel == 1'b1) && (is_last_out_channel == 1'b1)) begin
            tile_base_n <= 0;
        end
    end

endmodule

