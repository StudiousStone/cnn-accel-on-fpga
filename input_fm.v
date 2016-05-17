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
module input_fm_bank #(
    .AW (), 
    .DW (),
    .Tm (),
    .Tr (),
    .Tc (),
    .X () 
) input_fm_bank_inst (
    .rd_data (),
    .rd_addr (),
    .wr_data (),
    .wr_addr (),
    .wr_ena (),

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

    input                    [DW-1: 0] wr_data,
    input                    [AW-1: 0] wr_addr,
    input                              wr_ena,

    input                              clk,
    input                              rst
);
    localparam chunk_size = Tr * Tc;
    localparam chunk_width = (chunk_size == 4096) ? 12 :
                             (chunk_size == 2048) ? 11 :
                             (chunk_size == 1024) ? 10 :
                             (chunk_size == 512) ? 9 :
                             (chunk_size == 256) ? 8 :
                             (chunk_size == 128) ? 7 :
                             (chunk_size == 64) ? 6 :
                             (chunk_size == 32) ? 5 :
                             (chunk_size == 16) ? 4 :
                             (chunk_size == 8) ? 3 : 
                             (chunk_size == 4) ? 2 : 
                             (chunk_size == 1) ? 1: 0;

    reg                                wr_ena0;
    reg                                wr_ena1;
    reg                                wr_ena2;
    reg                                wr_ena3;
    reg                      [DW-1: 0] wr_data_reg;
    reg                      [AW-1: 0] wr_addr_reg;

    wire                        [1: 0] bankid;
    assign bankid = wr_addr[chunk_width+1 : chunk_width];
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wr_ena0 <= 0;
            wr_ena1 <= 0;
            wr_ena2 <= 0;
            wr_ena3 <= 0;
        end
        else if(wr_ena == 1'b1) begin
            wr_ena0 <= (bankid == 2'b00);
            wr_ena1 <= (bankid == 2'b01);
            wr_ena2 <= (bankid == 2'b10);
            wr_ena3 <= (bankid == 2'b11);
        end
        else begin
            wr_ena0 <= 0;
            wr_ena1 <= 0;
            wr_ena2 <= 0;
            wr_ena3 <= 0;
        end
    end

    always@(posedge clk) begin
        wr_data_reg <= wr_data;
        wr_addr_reg <= wr_addr;
    end

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
        .wr_data (wr_data_reg),
        .wr_addr (wr_addr_reg),
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
        .wr_data (wr_data_reg),
        .wr_addr (wr_addr_reg),
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
        .wr_data (wr_data_reg),
        .wr_addr (wr_addr_reg),
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
        .wr_data (wr_data_reg),
        .wr_addr (wr_addr_reg),
        .wr_ena (wr_ena3),

        .clk (clk),
        .rst (rst)
    );

endmodule
