/*
* Created           : cheng liu
* Date              : 2016-05-16
* Email             : st.liucheng@gmail.com
*
* Description:
* 
* One bank of weight, and it contains Tm/X kernel weight coefficients.
* 
* Instance example
weight_bank #(
    .AW (), 
    .DW (),
    .Tm (),
    .Tn (),
    .K (),
    .X ()
    .Y () 
) weight_bank_inst (
    .rd_data (),
    .rd_addr (),

    .wr_data (),
    .wr_ena (),

    .clk (),
    .rst ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module weight_bank #(
    parameter AW = 10,  // input_fm bank address width
    parameter DW = 32,  // data width
    parameter Tn = 16,  // output_fm tile size of output channel
    parameter Tm = 16,  // input_fm tile size of input channel
    parameter K = 3,    // kernel parameter
    parameter X = 4,    // # of input_fm bank
    parameter Y = 4     // # of output_fm bank
)(
    output  [DW-1: 0]                  rd_data,
    input   [AW-1: 0]                  rd_addr,
                                       
    input   [DW-1: 0]                  wr_data,
    input                              wr_ena,
    input                              conv_tile_reset,
                                       
    input                              clk,
    input                              rst
);
    localparam BANK_CAPACITY = (Tn/Y) * (Tm/X) * K * K; // # of words

    wire    [AW-1: 0]                  wr_addr;
    reg     [DW-1: 0]                  wr_data_reg;
    reg                                wr_ena_reg;

    always@(posedge clk) begin
        wr_ena_reg <= wr_ena;
        wr_data_reg <= wr_data;
    end

    counter #(
        .CW (AW),
        .MAX (BANK_CAPACITY)
    ) bank_counter (
        .ena     (wr_ena),
        .cnt     (wr_addr),
        .done    (),
        .syn_rst (conv_tile_reset),

        .clk     (clk),
        .rst     (rst)
    );

    // weight Bank
    dp_ram_bhm #(
        .AW (AW),
        .DW (DW),
        .NUM (BANK_CAPACITY)
    ) dp_ram_bhm_inst (
        .clock     (clk),
        .data      (wr_data_reg),
        .rdaddress (rd_addr),
        .wraddress (wr_addr),
        .wren      (wr_ena_reg),
        .q         (rd_data)
    );    

endmodule
