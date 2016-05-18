/*
* Created           : cheng liu
* Date              : 2016-05-18
*
* Description:
* 
* out_fm memory, and it accommodates a few output feacture maps of different channels.
* 
* Instance example
module output_fm_bank #(
    .AW (), 
    .DW (),
    .Tn (),
    .Tr (),
    .Tc (),
    .Y () 
) output_fm_bank_inst (
    .rd_data (),
    .rd_addr (),
    .wr_data (),
    .wr_addr (),
    .wr_ena (),

    .inter_rd_data (),
    .inter_rd_addr (),
    .inter_wr_data (),
    .inter_wr_addr (),
    .inter_wr_ena (),

    .ld_init_data_start (),
    .ld_init_data_done (),
    .st_init_data_start (),
    .st_init_data_done (),

    .clk (),
    .rst ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module output_fm #(
    parameter AW = 16,  // input_fm bank address width
    parameter DW = 32,  // data width
    parameter Tn = 16,  // output_fm tile size of input channel
    parameter Tr = 64,  // output_fm tile size of row
    parameter Tc = 16,  // output_fm tile size of col
    parameter Y = 4     // # of out_fm bank
)(
    // port to conv memory access unit
    output                   [DW-1: 0] data_out,
    output                             push,
    input                              downstream_ready,

    input                    [DW-1: 0] data_in,
    input                              pop,

    // port to internal computing logic
    output                   [DW-1: 0] inter_rd_data0,
    input                    [AW-1: 0] inter_rd_addr0,

    input                    [DW-1: 0] inter_wr_data0,
    input                    [AW-1: 0] inter_wr_addr0,
    input                              inter_wr_ena0,

    output                   [DW-1: 0] inter_rd_data1,
    input                    [AW-1: 0] inter_rd_addr1,

    input                    [DW-1: 0] inter_wr_data1,
    input                    [AW-1: 0] inter_wr_addr1,
    input                              inter_wr_ena1,

    output                   [DW-1: 0] inter_rd_data2,
    input                    [AW-1: 0] inter_rd_addr2,

    input                    [DW-1: 0] inter_wr_data2,
    input                    [AW-1: 0] inter_wr_addr2,
    input                              inter_wr_ena2,

    output                   [DW-1: 0] inter_rd_data3,
    input                    [AW-1: 0] inter_rd_addr3,

    input                    [DW-1: 0] inter_wr_data3,
    input                    [AW-1: 0] inter_wr_addr3,
    input                              inter_wr_ena3,

    // Control status
    input                              ld_init_data_start,
    input                              ld_init_data_done,
    input                              st_result_data_start,
    input                              st_result_data_done,

    input                              clk,
    input                              rst
);


   localparam out_slice_size = Tr * Tc;

   reg                       [DW-1: 0] out_slice_cnt;
   reg                                 ld_init_on_going;
   reg                                 st_result_on_going;
   wire                                slice_done;
   reg                          [3: 0] out_lane_sel;

   always@(posedge clk or posedge rst) begin
       if(rst == 1'b1) begin
           ld_init_on_going <= 1'b0;
       end
       else if(ld_init_data_start == 1'b1) begin
           ld_init_on_going <= 1'b1;
       end
       else if(ld_init_data_done == 1'b1) begin
           ld_init_on_going <= 1'b0;
       end
   end

   always@(posedge clk or posedge rst) begin
       if(rst == 1'b1) begin
           st_result_on_going <= 1'b0;
       end
       else if(st_result_data_start == 1'b1) begin
           st_result_on_going <= 1'b1;
       end
       else if(st_result_data_done == 1'b1) begin
           st_result_on_going <= 1'b0;
       end
   end

   // As the load process and store process never overlaps, they share the same slice counter.
   always@(posedge clk or posedge rst) begin
       if(rst == 1'b1) begin
           out_slice_cnt <= 0;
       end
       else if((ld_init_on_going == 1'b1 || st_result_on_going == 1'b1) && out_slice_cnt < out_slice_size - 1) begin
           out_slice_cnt <= out_slice_cnt + 1;
       end
       else if(slice_done == 1'b1 || (ld_init_on_going == 1'b0 && st_result_on_going == 1'b0)) begin
           out_slice_cnt <= 0;
       end
   end

   assign slice_done = (out_slice_cnt == out_slice_size -1);

   always@(posedge clk or posedge rst) begin
       if(rst == 1'b1) begin
           out_lane_sel <= 4'b0001;
       end
       else if(slice_done == 1'b1) begin
           out_lane_sel <= {out_lane_sel[2: 0], out_lane_sel[3]};
       end
       else if(ld_init_data_start == 1'b1 || st_result_data_start == 1'b1) begin
           out_lane_sel <= 4'b0001;
       end
   end

   assign rd_data = out_lane_sel == 4'b0001 ? rd_data0 :
                    out_lane_sel == 4'b0010 ? rd_data1 :
                    out_lane_sel == 4'b0100 ? rd_data2 : rd_data3;

   assign rd_addr0 = rd_addr;
   assign rd_addr1 = rd_addr;
   assign rd_addr2 = rd_addr;
   assign rd_addr3 = rd_addr;

   assign wr_

    // output_fm Bank
    output_fm_bank #(
        .AW (AW), 
        .DW (DW),
        .Tn (Tn),
        .Tr (Tr),
        .Tc (Tc),
        .Y (Y) 
    ) output_fm_bank0 (
        .rd_data (rd_data0),
        .rd_addr (rd_addr0),
        .wr_data (wr_data0),
        .wr_addr (wr_addr0),
        .wr_ena (wr_ena0),

        .inter_rd_data (inter_rd_data0),
        .inter_rd_addr (inter_rd_addr0),
        .inter_wr_data (inter_wr_data0),
        .inter_wr_addr (inter_wr_addr0),
        .inter_wr_ena (inter_wr_ena0),

        .ld_init_data_start (ld_init_data_start),
        .ld_init_data_done (ld_init_data_done),
        .st_init_data_start (st_init_data_start),
        .st_init_data_done (st_init_data_done),

        .clk (clk),
        .rst (rst)
    );

    output_fm_bank #(
        .AW (AW), 
        .DW (DW),
        .Tn (Tn),
        .Tr (Tr),
        .Tc (Tc),
        .Y (Y) 
    ) output_fm_bank1 (
        .rd_data (rd_data1),
        .rd_addr (rd_addr1),
        .wr_data (wr_data1),
        .wr_addr (wr_addr1),
        .wr_ena (wr_ena1),

        .inter_rd_data (inter_rd_data1),
        .inter_rd_addr (inter_rd_addr1),
        .inter_wr_data (inter_wr_data1),
        .inter_wr_addr (inter_wr_addr1),
        .inter_wr_ena (inter_wr_ena1),

        .ld_init_data_start (ld_init_data_start),
        .ld_init_data_done (ld_init_data_done),
        .st_init_data_start (st_init_data_start),
        .st_init_data_done (st_init_data_done),

        .clk (clk),
        .rst (rst)
    );

    output_fm_bank #(
        .AW (AW), 
        .DW (DW),
        .Tn (Tn),
        .Tr (Tr),
        .Tc (Tc),
        .Y (Y) 
    ) output_fm_bank2 (
        .rd_data (rd_data2),
        .rd_addr (rd_addr2),
        .wr_data (wr_data2),
        .wr_addr (wr_addr2),
        .wr_ena (wr_ena2),

        .inter_rd_data (inter_rd_data2),
        .inter_rd_addr (inter_rd_addr2),
        .inter_wr_data (inter_wr_data2),
        .inter_wr_addr (inter_wr_addr2),
        .inter_wr_ena (inter_wr_ena2),

        .ld_init_data_start (ld_init_data_start),
        .ld_init_data_done (ld_init_data_done),
        .st_init_data_start (st_init_data_start),
        .st_init_data_done (st_init_data_done),

        .clk (clk),
        .rst (rst)
    );

    output_fm_bank #(
        .AW (AW), 
        .DW (DW),
        .Tn (Tn),
        .Tr (Tr),
        .Tc (Tc),
        .Y (Y) 
    ) output_fm_bank3 (
        .rd_data (rd_data3),
        .rd_addr (rd_addr3),
        .wr_data (wr_data3),
        .wr_addr (wr_addr3),
        .wr_ena (wr_ena3),

        .inter_rd_data (inter_rd_data3),
        .inter_rd_addr (inter_rd_addr3),
        .inter_wr_data (inter_wr_data3),
        .inter_wr_addr (inter_wr_addr3),
        .inter_wr_ena (inter_wr_ena3),

        .ld_init_data_start (ld_init_data_start),
        .ld_init_data_done (ld_init_data_done),
        .st_init_data_start (st_init_data_start),
        .st_init_data_done (st_init_data_done),

        .clk (clk),
        .rst (rst)
    );

endmodule
