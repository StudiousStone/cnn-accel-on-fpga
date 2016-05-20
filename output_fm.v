/*
* Created           : cheng liu
* Date              : 2016-05-18
*
* Description:
* 
* out_fm memory, and it accommodates a few output feacture maps of different channels.
* 
* Instance example
output_fm #(
    .AW (), 
    .DW (),
    .Tn (),
    .Tr (),
    .Tc (),
    .Y () 
) output_fm_inst (
    .out_fm_st_fifo_data (),
    .out_fm_st_fifo_push (),
    .out_fm_st_fifo_almost_full (),

    .out_fm_ld_fifo_pop (),
    .out_fm_ld_fifo_data (),
    .out_fm_ld_fifo_empty (),
    
    .inter_rd_data0 (),
    .inter_rd_addr0 (),
    
    .inter_wr_data0 (),
    .inter_wr_addr0 (),
    .inter_wr_ena0 (),
    
    .inter_rd_data1 (),
    .inter_rd_addr1 (),
    
    .inter_wr_data1 (),
    .inter_wr_addr1 (),
    .inter_wr_ena1 (),
    
    .inter_rd_data2 (),
    .inter_rd_addr2 (),
    
    .inter_wr_data2 (),
    .inter_wr_addr2 (),
    .inter_wr_ena2 (),
    
    .inter_rd_data3 (),
    .inter_rd_addr3 (),
    
    .inter_wr_data3 (),
    .inter_wr_addr3 (),
    .inter_wr_ena3 (),
    
    .ld_init_data_start (),
    .ld_init_data_done (),
    
    .st_result_data_start (),
    .st_result_data_done (),
    
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
    // port to conv memory access interface
    output                   [DW-1: 0] out_fm_st_fifo_data,
    output                             out_fm_st_fifo_push,
    input                              out_fm_st_fifo_almost_full,

    output                   [AW-1: 0] out_fm_ld_fifo_pop,
    input                    [DW-1: 0] out_fm_ld_fifo_data,
    input                              out_fm_ld_fifo_empty,

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

   reg                                 ld_init_on_going;
   reg                                 st_result_on_going;
   reg                          [3: 0] out_lane_sel;
   wire                                slice_done;

   wire                                rd_ena0;
   wire                                rd_ena1;
   wire                                rd_ena2;
   wire                                rd_ena3;

   wire                                wr_ena0;
   wire                                wr_ena1;
   wire                                wr_ena2;
   wire                                wr_ena3;

   wire                                out_fm_st_fifo_push_tmp;
   wire                                out_fm_ld_fifo_pop_tmp;
   reg                                 out_fm_st_fifo_push_reg;
   reg                                 out_fm_ld_fifo_pop_reg;

   wire                      [DW-1: 0] rd_data0;
   wire                      [DW-1: 0] rd_data1;
   wire                      [DW-1: 0] rd_data2;
   wire                      [DW-1: 0] rd_data3;

   always@(posedge clk) begin
       out_fm_st_fifo_push_reg <= out_fm_st_fifo_push_tmp;
       out_fm_ld_fifo_pop_reg <= out_fm_ld_fifo_pop_tmp;
   end

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

   assign out_fm_ld_fifo_pop_tmp = (out_fm_ld_fifo_empty == 1'b0) && (ld_init_on_going == 1'b1) && (ld_init_data_done == 1'b0);
   assign out_fm_ld_fifo_pop = out_fm_ld_fifo_pop_tmp;

   sig_delay #(
       .D (3)
   ) sig_delay1 (
       .sig_in (out_fm_ld_fifo_push_tmp),
       .sig_out (out_fm_ld_fifo_push),

       .clk (clk),
       .rst (rst)
   );

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
   
   assign out_fm_ld_fifo_push_tmp = (out_fm_fifo_almost_full == 1'b0) && (st_result_on_going == 1'b1) && (st_result_data_done == 1'b0);

   // As the load process and store process never overlaps, they share the same slice counter.
   wire                                ena;

   assign ena = out_fm_st_fifo_push_tmp || out_fm_ld_fifo_pop_tmp;

   counter #(
       .CW (AW),
       .MAX (slice_size)
   ) slice_counter (
       .ena (ena),
       .cnt (),
       .done (slice_done),

       .clk (clk),
       .rst (rst)
   );

   always@(posedge clk or posedge rst) begin
       if(rst == 1'b1) begin
           out_lane_sel <= 4'b0001;
       end
       else if(slice_done == 1'b1) begin
           out_lane_sel <= {out_lane_sel[2: 0], out_lane_sel[3]};
       end
   end

   data_delay #(
       .D (2),
       .DW (4)
   ) data_delay0 (
       .data_in (out_lane_sel),
       .data_out (out_lane_sel_d2),

       .clk (clk),
       .rst (rst)
   );

   assign rd_ena0 = out_lane_sel[0] && out_fm_fifo_push_reg;
   assign rd_ena1 = out_lane_sel[1] && out_fm_fifo_push_reg;
   assign rd_ena2 = out_lane_sel[2] && out_fm_fifo_push_reg;
   assign rd_ena3 = out_lane_sel[3] && out_fm_fifo_push_reg;

   assign rd_data = out_lane_sel_d2 == 4'b0001 ? rd_data0 :
                    out_lane_sel_d2 == 4'b0010 ? rd_data1 :
                    out_lane_sel_d2 == 4'b0100 ? rd_data2 : rd_data3;

   assign wr_ena0 = out_lane_sel[0] && out_fm_fifo_pop_reg;
   assign wr_ena1 = out_lane_sel[1] && out_fm_fifo_pop_reg;
   assign wr_ena2 = out_lane_sel[2] && out_fm_fifo_pop_reg;
   assign wr_ena3 = out_lane_sel[3] && out_fm_fifo_pop_reg;


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
        .rd_ena (rd_ena0),
        .wr_data (out_fm_ld_fifo_data),
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
        .rd_ena (rd_ena1),
        .wr_data (out_fm_ld_fifo_data),
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
        .rd_ena (rd_ena2),
        .wr_data (out_fm_ld_fifo_data),
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
        .rd_ena (rd_ena3)
        .wr_data (out_fm_ld_fifo_data),
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
