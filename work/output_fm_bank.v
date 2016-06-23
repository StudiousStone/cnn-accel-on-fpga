/*
* Created           : cheng liu
* Date              : 2016-05-18
*
* Description:
* 
* One bank of out_fm, and it accommodates a few output feacture maps of different channels.
* As both the read and write operations happen sequentially, the addresses are generated automatically. 
* Instance example
output_fm_bank #(
    .AW (), 
    .DW (),
    .Tn (),
    .Tr (),
    .Tc (),
    .Y () 
) output_fm_bank_inst (
    .rd_data (),
    .rd_ena (),
    
    .wr_data (),
    .wr_ena (),
    
    .computing_on_going (),

    .inter_rd_data (),
    .inter_rd_addr (),
    .inter_wr_data (),
    .inter_wr_addr (),
    .inter_wr_ena (),


    .clk (),
    .rst ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module output_fm_bank #(
    parameter AW = 16,  // input_fm bank address width
    parameter DW = 32,  // data width
    parameter Tn = 16,  // output_fm tile size of input channel
    parameter Tr = 64,  // output_fm tile size of row
    parameter Tc = 16,  // output_fm tile size of col
    parameter Y = 4     // # of out_fm bank
)(
    // port to out memory
    input                    [DW-1: 0] wr_data,
    input                              wr_ena,

    output                   [DW-1: 0] rd_data,
    input                              rd_ena,

    // port to internal computing logic
    output                   [DW-1: 0] inter_rd_data,
    input                    [AW-1: 0] inter_rd_addr,

    input                    [DW-1: 0] inter_wr_data,
    input                    [AW-1: 0] inter_wr_addr,
    input                              inter_wr_ena,
    input                              conv_tile_clean,

    // Control status
    input                              computing_on_going,

    input                              clk,
    input                              rst
);
    localparam bank_capacity = (Tn/Y) * Tr * Tc; // # of words

    reg                      [DW-1: 0] wr_data_reg;
    wire                     [AW-1: 0] wr_addr;
    reg                                wr_ena_reg;
    wire                     [AW-1: 0] rd_addr;
    wire                     [DW-1: 0] q;
    wire                     [AW-1: 0] wraddress;
    wire                     [AW-1: 0] rdaddress;
    wire                               wren;
    wire                     [DW-1: 0] data;
    
    always @(posedge clk) begin
        wr_ena_reg <= wr_ena;
        wr_data_reg <= wr_data;
    end

    counter #(
        .CW (AW),
        .MAX (bank_capacity)
    ) ld_counter (
        .ena (wr_ena),
        .cnt (wr_addr),
        .done (),
        .clean (conv_tile_clean),

        .clk (clk),
        .rst (rst)
    );

    counter #(
        .CW (AW),
        .MAX (bank_capacity)
    ) st_counter (
        .ena (rd_ena),
        .cnt (rd_addr),
        .done (),
        .clean (conv_tile_clean),

        .clk (clk),
        .rst (rst)
    );

    assign wraddress = computing_on_going ? inter_wr_addr : wr_addr;
    assign data = computing_on_going ? inter_wr_data : wr_data_reg;
    assign wren = computing_on_going ? inter_wr_ena : wr_ena_reg;
    assign rdaddress = computing_on_going ? inter_rd_addr : rd_addr;
    
    assign inter_rd_data = q;
    assign rd_data = q;

    // output_fm Bank
    dp_ram_bhm #(
        .AW (AW),
        .DW (DW),
        .NUM (bank_capacity)
    ) dp_ram_bhm_inst (
        .clock (clk),
        .data (data),
        .rdaddress (rdaddress),
        .wraddress (wraddress),
        .wren (wren),
        .q (q)
    );
    
endmodule
