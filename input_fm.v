/*
* Created           : cheng liu
* Date              : 2016-05-16
*
* Description:
* 
* It consists of 4 physical banks allowing 4 input_fm data reading in each cycle, 
* while it has only a single write port. input_fm buffers all the input data of a tile.
* 
* Instance example
input_fm #(
    .AW (), 
    .DW (),
    .Tm (),
    .Tr (),
    .Tc (),
    .X () 

) input_fm_inst (
    .rd_data0 (),
    .rd_addr0 (),

    .rd_data1 (),
    .rd_addr1 (),

    .rd_data2 (),
    .rd_addr2 (),

    .rd_data3 (),
    .rd_addr3 (),

    .in_fm_fifo_data (),
    .in_fm_fifo_empty (),
    .in_fm_fifo_pop (),

    .in_fm_load_start (),
    .in_fm_load_done (),

    .clk (),
    .rst ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module input_fm #(
    parameter AW = 16,  // input_fm bank address width
    parameter DW = 32,  // data width
    parameter Tm = 16,  // input_fm tile size of input channel
    parameter Tr = 64,  // input_fm tile size of row
    parameter Tc = 16,  // input_fm tile size of col
    parameter X = 4     // # of input_fm bank
)(
    output                   [DW-1: 0] rd_data0,
    input                    [AW-1: 0] rd_addr0,

    output                   [DW-1: 0] rd_data1,
    input                    [AW-1: 0] rd_addr1,

    output                   [DW-1: 0] rd_data2,
    input                    [AW-1: 0] rd_addr2,

    output                   [DW-1: 0] rd_data3,
    input                    [AW-1: 0] rd_addr3,

    input                    [DW-1: 0] in_fm_fifo_data,
    input                              in_fm_fifo_empty,
    output                             in_fm_fifo_pop,

    input                              in_fm_load_start,
    output                             in_fm_load_done,

    input                              clk,
    input                              rst
);
    localparam slice_size = Tr * Tc;
    localparam in_fm_size = Tm * Tr * Tc;

    wire                               wr_ena0;
    wire                               wr_ena1;
    wire                               wr_ena2;
    wire                               wr_ena3;

    reg                         [3: 0] bank_sel;
    wire                               slice_done;
    reg                                in_fm_load_on_going;
    reg                                in_fm_fifo_pop_reg;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            in_fm_load_on_going <= 1'b0;
        end
        else if(in_fm_load_start == 1'b1) begin
            in_fm_load_on_going <= 1'b1;
        end
        else if(in_fm_load_done == 1'b1) begin
            in_fm_load_on_going <= 1'b0;
        end
    end

    counter #(
        .CW (DW),
        .MAX (in_fm_size)
    ) in_fm_counter (
        .ena (in_fm_fifo_pop),
        .cnt (),
        .done (in_fm_load_done),

        .clk (clk),
        .rst (rst)
    );

    assign in_fm_fifo_pop = (in_fm_load_on_going == 1'b1) && (in_fm_fifo_empty == 1'b0) && (in_fm_load_done == 1'b0);

    counter #(
        .CW (AW),
        .MAX (slice_size)
    ) slice_counter (
        .ena (in_fm_fifo_pop),
        .cnt (),
        .done (slice_done),

        .clk (clk),
        .rst (rst)
    );

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            bank_sel <= 4'b0001;
        end
        else if(slice_done == 1'b1) begin
            bank_sel <= {bank_sel[2: 0], bank_sel[3]};
        end
        else if(in_fm_load_done == 1'b1) begin
            bank_sel <= 4'b0001;
        end
    end
    
    always@(posedge clk) begin
        in_fm_fifo_pop_reg <= in_fm_fifo_pop;
    end

    assign wr_ena0 = in_fm_fifo_pop_reg && bank_sel[0];
    assign wr_ena1 = in_fm_fifo_pop_reg && bank_sel[1];
    assign wr_ena2 = in_fm_fifo_pop_reg && bank_sel[2];
    assign wr_ena3 = in_fm_fifo_pop_reg && bank_sel[3];

    input_fm_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),
        .X (X) 
    ) input_fm_bank0 (
        .rd_data (rd_data0),
        .rd_addr (rd_addr0),
        .wr_data (in_fm_fifo_data),
        .wr_ena (wr_ena0),

        .clk (clk),
        .rst (rst)
    );

    input_fm_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),
        .X (X) 
    ) input_fm_bank1 (
        .rd_data (rd_data1),
        .rd_addr (rd_addr1),
        .wr_data (in_fm_fifo_data),
        .wr_ena (wr_ena1),

        .clk (clk),
        .rst (rst)
    );

    input_fm_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),
        .X (X) 
    ) input_fm_bank2 (
        .rd_data (rd_data2),
        .rd_addr (rd_addr2),
        .wr_data (in_fm_fifo_data),
        .wr_ena (wr_ena2),

        .clk (clk),
        .rst (rst)
    );

    input_fm_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),
        .X (X) 
    ) input_fm_bank3 (
        .rd_data (rd_data3),
        .rd_addr (rd_addr3),
        .wr_data (in_fm_fifo_data),
        .wr_ena (wr_ena3),

        .clk (clk),
        .rst (rst)
    );

endmodule
