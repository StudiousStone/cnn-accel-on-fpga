/*
* Created           : cheng liu
* Date              : 2016-05-23
*
* Description:
* 
* This module moves a specified bulk of data from RAM to fifo when the 
* 'start' signal is asserted. 'done' signal will be asserted when the data 
* movement is completed. 
* 
* Assumption:
* Given read address, the data from RAM will be available 2 cycles later.
*
* Instance example
ram_to_fifo #(
    .CW (CW),
    .AW (AW),
    .DW (DW),
    .DATA_SIZE (DATA_SIZE)
) ram_to_fifo_inst (
    .start (),
    .done (),

    .fifo_push (),
    .fifo_almost_full (),
    .data_to_fifo (),

    .ram_addr (),
    .data_from_ram (),

    .clk (),
    .rst ()
);
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module ram_to_fifo #(
    parameter CW = 16,
    parameter AW = 16,
    parameter DW = 32,
    parameter DATA_SIZE = 1024
)(
    input                              start,
    output                             done,

    output                             fifo_push,
    input                              fifo_almost_full,
    output                   [DW-1: 0] data_to_fifo,

    output                   [AW-1: 0] ram_addr,
    input                    [DW-1: 0] data_from_ram,

    input                              clk,
    input                              rst
);
    reg                                transfer_on_going_tmp;
    wire                               transfer_on_going;
    wire                               fifo_push_tmp;

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

    assign data_to_fifo = data_from_ram;

    assign fifo_push_tmp = (fifo_almost_full == 1'b0) && (transfer_on_going == 1'b1);

    sig_delay #(
        .D (3)
    ) sig_delay (
        .sig_in (fifo_push_tmp),
        .sig_out (fifo_push),

        .clk (clk),
        .rst (rst)
    );

    counter #(
        .CW (CW),
        .MAX (DATA_SIZE)
    ) counter (
        .ena (fifo_push_tmp),
        .cnt (ram_addr),
        .done (done),

        .clk (clk),
        .rst (rst)
    );

endmodule
