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
fifo_to_ram #(
    .CW (),
    .AW (),
    .DW (),
    .DATA_SIZE ()
) fifo_to_ram_inst(
    .start (),
    .done (),

    .fifo_pop (),
    .fifo_empty (),
    .data_from_fifo (),

    .ram_wena (),
    .ram_addr (),
    .data_to_ram (),

    .clk (),
    .rst ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on


module fifo_to_ram #(
    parameter CW = 32,
    parameter AW = 16,
    parameter DW = 32,
    parameter DATA_SIZE = 1024
)(
    input                              start,
    output                             done,

    output                             fifo_pop,
    input                              fifo_empty,
    input                    [DW-1: 0] data_from_fifo,

    output                             ram_wena,
    output                   [AW-1: 0] ram_addr,
    output                   [DW-1: 0] data_to_ram,

    input                              clk,
    input                              rst
);
    reg                                transfer_on_going_tmp;
    wire                               transfer_on_going;

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

    counter #(
        .CW (CW),
        .MAX (DATA_SIZE)
    ) counter (
        .ena (fifo_pop),
        .cnt (ram_addr),
        .done (done),

        .clk (clk),
        .rst (rst)
    );
    
    assign ram_wena = fifo_pop;

endmodule
