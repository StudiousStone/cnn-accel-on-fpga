/*
* Created           : cheng liu
* Date              : 2016-06-014
*
* Description:
* 
* This module specifies the invalid data element of in_fm tile and replaces them with zero. 
* 
*
* Instance example

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module in_fm_filter #(

    parameter AW = 16,
    parameter CW = 16,
    parameter DW = 32,

    parameter N = 32,
    parameter M = 32,
    parameter R = 64,
    parameter C = 32,

    parameter Tn = 16,
    parameter Tm = 16,
    parameter Tr = 64,
    parameter Tc = 16,
    parameter K = 3,
    parameter S = 1,

    parameter TILE_ROW_OFFSET = 2

)(
    input                              fifo_push_tmp,
    input   [DW-1: 0]                  data_to_fifo_tmp,
    
    output                             fifo_push,
    output  [DW-1: 0]                  data_to_fifo,

    input   [CW-1: 0]                  tile_base_m,
    input   [CW-1: 0]                  tile_base_row,
    input   [CW-1: 0]                  tile_base_col,

    input                              clk,
    input                              rst
);
    localparam READ_LENGTH = Tc + TILE_ROW_OFFSET;

    wire                               is_data_legal;
    wire                               is_push_legal;
    reg     [DW-1: 0]                  data_to_fifo_reg;
    wire                               done;
    reg                                done_reg;
    reg                                fifo_push_reg;

    wire    [CW-1: 0]                  tc;
    wire    [CW-1: 0]                  tr;
    wire    [CW-1: 0]                  tm;

    assign data_to_fifo = is_data_legal ? data_to_fifo_reg : 0;
    assign fifo_push = is_push_legal ? fifo_push_reg : 0;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            fifo_push_reg <= 0;
            data_to_fifo_reg <= 0;
            done_reg <= 0;
        end
        else begin
            fifo_push_reg <= fifo_push_tmp;
            data_to_fifo_reg <= data_to_fifo_tmp;
            done_reg <= done;
        end
    end

    nest3_counter #(
        .CW (CW),
        .n0_max (READ_LENGTH),
        .n1_max (Tr),
        .n2_max (Tm)

    ) nest3_counter_inst (
        .ena      (fifo_push_tmp),
        .syn_rst  (done_reg),

        .cnt0     (tc),
        .cnt1     (tr),
        .cnt2     (tm),

        .done     (done),

        .clk      (clk),
        .rst      (rst)
    );

    assign is_data_legal = (tile_base_m + tm < M) && (tm < Tm) &&
                           (tile_base_row + tr < R) && (tr < Tr) &&
                           (tile_base_col + tc < C) && (tc < Tc);

    assign is_push_legal = (tm < Tm) && (tr < Tr) && (tc < Tc);

endmodule
