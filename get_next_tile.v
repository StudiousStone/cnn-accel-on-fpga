/*
* Created           : cheng liu
* Date              : 2016-05-28
*
* Description:
* This module assumes all the input/output data are stored in RAM blocks. 
* It schedules the input/output data with the granularity of a tile. Meanwhile 
* it automatically fill zeros when the remaining input/output can't fit into 
* a tile.
* 
*
* Instance example:
    get_next_tile #(
        .N (N),
        .M (M),
        .R (R),
        .C (C),
        .X (X),
        .Y (Y),
        .Tn (Tn),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),
        .K (K),
        .S (S)
    ) get_next_tile (
        .conv_tile_done (),

        .tile_base_n (),
        .tile_base_m (),
        .tile_base_row (),
        .tile_base_col (),

        .next_tile_base_n (),
        .next_tile_base_m (),
        .next_tile_base_row (),
        .next_tile_base_col (),

        .clk (clk),
        .rst (rst)
    );

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module get_next_tile #(
    parameter N = 128,
    parameter M = 256,
    parameter R = 128,
    parameter C = 128,

    parameter Tn = 16,
    parameter Tm = 16,
    parameter Tr = 64,
    parameter Tc = 16,

    parameter X = 4,
    parameter Y = 4,
    parameter K = 3,
    parameter S = 1

)(
    input                              conv_tile_done,

    input                    [AW-1: 0] tile_base_n,
    input                    [AW-1: 0] tile_base_m,
    input                    [AW-1: 0] tile_base_row,
    input                    [AW-1: 0] tile_base_col,

    output                   [AW-1: 0] next_tile_base_n,
    output                   [AW-1: 0] next_tile_base_m,
    output                   [AW-1: 0] next_tile_base_row,
    output                   [AW-1: 0] next_tile_base_col,

    input                              clk,
    input                              rst
);
    localparam tile_row_step = ((Tr + S - K)/S) * S;
    localparam tile_col_step = ((Tc + S - K)/S) * S;
    localparam tile_m_step = Tm;
    localparam tile_n_step = Tn;

    wire                               is_last_row_of_tile;
    wire                               is_last_col_of_tile;
    wire                               is_end_of_in_channel;
    wire                               is_end_of_out_channel;

    assign is_last_col = (tile_base_col + tile_col_step) >= C;
    assign is_last_row = (tile_base_row + tile_row_step) >= R;
    assign is_last_in_channel = (tile_base_m + tile_m_step) >= M;
    assign is_last_out_channel = (tile_base_n + tile_n_step) >= N;
    assign is_end_of_in_channel = compile_tile_done && is_last_row && is_last_col;
    assign is_end_of_out_channel = compile_tile_done && is_last_row

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            tile_base_col <= 0;
        end
        else if(conv_tile_done == 1'b1 && is_last_col == 1'b0) begin
            tile_base_col <= tile_base_col + tile_row_step;
        end
        else if(conv_tile_done == 1'b1 && is_last_col == 1'b1) begin
            tile_base_col <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            tile_base_row <= 0;
        end
        else if(conv_tile_done == 1'b1 && is_last_col == 1'b0) begin
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
        else if(conv_tile_done == 1'b1 && is_last_in_channel == 1'b0) begin
            tile_base_m <= tile_base_m + tile_m_step;
        end
        else if(conv_tile_done == 1'b1 && is_last_in_channel == 1'b1) begin
    end

endmodule

