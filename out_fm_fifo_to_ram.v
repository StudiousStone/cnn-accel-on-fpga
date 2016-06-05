/*
* Created           : cheng liu
* Date              : 2016-05-23
*
* Description:
* This module moves a specified bulk of data from fifo to RAM when the 
* 'start' signal is asserted. 'done' signal will be asserted when the data 
* movement is completed. 
* 
* Assumption:
* Given pop signal, the data from fifo will be available one cycle later.
*
* Instance example:
out_fm_fifo_to_ram #(
    .CW (),
    .AW (),
    .DW (),
    .N (),
    .R (),
    .C (),
    .K (),
    .S (),
    .Tn (),
    .Tr (),
    .Tc ()

) out_fm_fifo_to_ram_inst(
    .start (),
    .done (),

    .fifo_pop (),
    .fifo_empty (),
    .data_from_fifo (),

    .ram_wena (),
    .ram_addr (),
    .data_to_ram (),

    .tile_base_n (),
    .tile_base_row (),
    .tile_base_col (),

    .clk (),
    .rst ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on


module out_fm_fifo_to_ram #(

    parameter CW = 32,
    parameter AW = 16,
    parameter DW = 32,
    parameter N = 32,
    parameter R = 64,
    parameter C = 32,
    parameter K = 3,
    parameter S = 1,
    parameter Tn = 8,
    parameter Tr = 16,
    parameter Tc = 8

)(
    input                              start,
    output                             done,
    input                              conv_tile_clean,

    output                             fifo_pop,
    input                              fifo_empty,
    input                    [DW-1: 0] data_from_fifo,

    output                             ram_wena,
    output                   [AW-1: 0] ram_addr,
    output                   [DW-1: 0] data_to_ram,

    input                    [AW-1: 0] tile_base_n,
    input                    [AW-1: 0] tile_base_row,
    input                    [AW-1: 0] tile_base_col,

    input                              clk,
    input                              rst
);
    localparam row_step = ((Tr + S - K)/S) * S;
    localparam col_step = ((Tc + S - K)/S) * S;
    localparam R_step = ((R + S - K)/S) * S;
    localparam C_step = ((C + S - K)/S) * S;

    reg                                transfer_on_going_tmp;
    wire                               transfer_on_going;
    wire                     [AW-1: 0] logic_addr;
    wire                               is_addr_legal;
    wire                     [AW-1: 0] tc;
    wire                     [AW-1: 0] tr;
    wire                     [AW-1: 0] tn;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            transfer_on_going_tmp <= 1'b0;
        end
        else if(start == 1'b1) begin
            transfer_on_going_tmp <= 1'b1;
        end
        else if(done == 1'b1) begin
            transfer_on_going_tmp <= 1'b0;
        end
    end
    
    assign transfer_on_going = (transfer_on_going_tmp == 1'b1) && (done == 1'b0);

    assign data_to_ram = data_from_fifo;

    assign fifo_pop = (fifo_empty == 1'b0) && (transfer_on_going == 1'b1);

    nest3_counter #(

        .CW (CW),
        .n0_max (Tc),
        .n1_max (Tr),
        .n2_max (Tn)

    ) nest3_counter_inst (
        .ena (fifo_pop),
        .clean (conv_tile_clean),

        .cnt0 (tc),
        .cnt1 (tr),
        .cnt2 (tn),

        .done (done),

        .clk (clk),
        .rst (rst)
    );
    
    assign ram_addr = logic_addr;

    assign is_addr_legal = (tile_base_n + tn < N) && 
                           (tile_base_row + tr < R_step) && 
                           (tile_base_col + tc < C_step) && (tc < col_step) && (tr < row_step);

    assign logic_addr = (tile_base_n + tn) * R * C +
                        (tile_base_row + tr) * C + tile_base_col + tc;
   
    assign ram_wena = is_addr_legal ? fifo_pop : 1'b0;

endmodule
