/*
* Created           : cheng liu
* Date              : 2016-05-16
*
* Description:
* As the memory accesses on each bank are mostly the same. 
* The addresses generated in the conv_ctrl_path can be simply reused.
* 
* Instance example
*
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module conv_core #(
    parameter AW = 16,  // input_fm bank address width
    parameter DW = 32,  // data width
    parameter Tn = 16,  // output_fm tile size on output channel dimension
    parameter Tm = 16,  // input_fm tile size on input channel dimension
    parameter Tr = 64,  // input_fm tile size on feature row dimension
    parameter Tc = 16,  // input_fm tile size on feature column dimension
    parameter K = 3,    // kernel scale
    parameter X = 4,    // # of parallel input_fm port
    parameter Y = 4,    // # of parallel output_fm port
    parameter FP_MUL_DELAY = 14, // multiplication delay
    parameter FP_ADD_DELAY = 11, // addition delay
    parameter FP_ACCUM_DELAY = 9 // accumulation delay
)(
    input                              conv_start, 
    output                             conv_done,

    // port to or from outside memory through FIFO
    input                    [DW-1: 0] in_fm_fifo_data_from_mem,
    input                              in_fm_fifo_push,
    output                             in_fm_fifo_almost_full,

    input                    [DW-1: 0] weight_fifo_data_from_mem,
    input                              weight_fifo_push,
    output                             weight_fifo_almost_full,

    input                    [DW-1: 0] out_fm_ld_fifo_data_from_mem,
    input                              out_fm_ld_fifo_push,
    output                             out_fm_ld_fifo_almost_full,

    output                   [DW-1: 0] out_fm_st_fifo_data_to_mem,
    output                             out_fm_st_fifo_empty,
    input                              out_fm_st_fifo_pop,

    // system clock
    input                              clk,
    input                              rst
);
    wire                               kernel_start;
    wire                     [AW-1: 0] weight_rd_addr;
    wire                     [AW-1: 0] in_fm_rd_addr;
    wire                     [AW-1: 0] out_fm_wr_addr;
    wire                     [AW-1: 0] out_fm_rd_addr;

    // input_fm port
    wire                     [DW-1: 0] in_fm_rd_data0,
    wire                     [AW-1: 0] in_fm_rd_addr0,

    wire                     [DW-1: 0] in_fm_rd_data1,
    wire                     [AW-1: 0] in_fm_rd_addr1,

    wire                     [DW-1: 0] in_fm_rd_data2,
    wire                     [AW-1: 0] in_fm_rd_addr2,

    wire                     [DW-1: 0] in_fm_rd_data3,
    wire                     [AW-1: 0] in_fm_rd_addr3, 

    // weight of output channel 0
    wire                     [DW-1: 0] weight_rd_data00; 
    wire                     [AW-1: 0] weight_rd_addr00;
    wire                     [DW-1: 0] weight_rd_data01;
    wire                     [AW-1: 0] weight_rd_addr01;
    wire                     [DW-1: 0] weight_rd_data02;
    wire                     [AW-1: 0] weight_rd_addr02;
    wire                     [DW-1: 0] weight_rd_data03;
    wire                     [AW-1: 0] weight_rd_addr03;

    // weight of output channel 1
    wire                     [DW-1: 0] weight_rd_data10;
    wire                     [AW-1: 0] weight_rd_addr10;
    wire                     [DW-1: 0] weight_rd_data11;
    wire                     [AW-1: 0] weight_rd_addr11;
    wire                     [DW-1: 0] weight_rd_data12;
    wire                     [AW-1: 0] weight_rd_addr12;
    wire                     [DW-1: 0] weight_rd_data13;
    wire                     [AW-1: 0] weight_rd_addr13;

    // weight of output channel 2
    wire                     [DW-1: 0] weight_rd_data20;
    wire                     [AW-1: 0] weight_rd_addr20;
    wire                     [DW-1: 0] weight_rd_data21;
    wire                     [AW-1: 0] weight_rd_addr21;
    wire                     [DW-1: 0] weight_rd_data22;
    wire                     [AW-1: 0] weight_rd_addr22;
    wire                     [DW-1: 0] weight_rd_data23;
    wire                     [AW-1: 0] weight_rd_addr23;

    // weight of output channel 3
    wire                     [DW-1: 0] weight_rd_data30;
    wire                     [AW-1: 0] weight_rd_addr30;
    wire                     [DW-1: 0] weight_rd_data31;
    wire                     [AW-1: 0] weight_rd_addr31;
    wire                     [DW-1: 0] weight_rd_data32;
    wire                     [AW-1: 0] weight_rd_addr32;
    wire                     [DW-1: 0] weight_rd_data33;
    wire                     [AW-1: 0] weight_rd_addr33;

    // port to output_fm bank0
    wire                     [AW-1: 0] out_fm_wr_addr0;
    wire                     [DW-1: 0] out_fm_wr_data0;
    wire                               out_fm_wr_ena0;
    wire                     [AW-1: 0] out_fm_rd_addr0;
    wire                     [DW-1: 0] out_fm_rd_data0;

    wire                     [AW-1: 0] out_fm_wr_addr1;
    wire                     [DW-1: 0] out_fm_wr_data1;
    wire                               out_fm_wr_ena1;
    wire                     [AW-1: 0] out_fm_rd_addr1;
    wire                     [DW-1: 0] out_fm_rd_data1;

    wire                     [AW-1: 0] out_fm_wr_addr2;
    wire                     [DW-1: 0] out_fm_wr_data2;
    wire                               out_fm_wr_ena2;
    wire                     [AW-1: 0] out_fm_rd_addr2;
    wire                     [DW-1: 0] out_fm_rd_data2;
  
    wire                     [AW-1: 0] out_fm_wr_addr3;
    wire                     [DW-1: 0] out_fm_wr_data3;
    wire                               out_fm_wr_ena3;
    wire                     [AW-1: 0] out_fm_rd_addr3;
    wire                     [DW-1: 0] out_fm_rd_data3;


    wire                               in_fm_load_start;
    wire                               weight_load_start;
    wire                               out_fm_load_start;
    wire                               out_fm_store_done;
    wire                               out_fm_load_start;
    wire                               conv_computing_start;
    wire                               conv_computing_done;

    assign in_fm_load_start = conv_start;
    assign weight_load_start = conv_start;
    assign out_fm_load_start = conv_start;
    assign conv_computing_start = conv_load_done;
    assign out_fm_store_start = conv_computing_done;
    assign conv_done = out_fm_store_done;

    gen_load_done gen_load_done (
        .in_fm_load_done (in_fm_load_done),
        .weight_load_done (weight_load_done),
        .out_fm_load_done (out_fm_load_done),
        .conv_load_done (conv_load_done)

        .clk (clk),
        .rst (rst)
    );

    input_fm #(
        .AW (AW),
        .DW (DW),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),
        .X (X) 

    ) input_fm (
        .rd_data0 (in_fm_rd_data0),
        .rd_addr0 (in_fm_rd_addr0),

        .rd_data1 (in_fm_rd_data1),
        .rd_addr1 (in_fm_rd_addr1),

        .rd_data2 (in_fm_rd_data2),
        .rd_addr2 (in_fm_rd_addr2),

        .rd_data3 (in_fm_rd_data3),
        .rd_addr3 (in_fm_rd_addr3),

        .in_fm_fifo_data (in_fm_fifo_data),
        .in_fm_fifo_empty (in_fm_fifo_empty),
        .in_fm_fifo_pop (in_fm_fifo_pop),

        .in_fm_load_start (in_fm_load_start),
        .in_fm_load_done (in_fm_load_done),

        .clk (clk),
        .rst (rst)
    );


    weight #(
        .AW (AW),
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight (
        .rd_data00 (weight_rd_data00),
        .rd_addr00 (weight_rd_addr00),
        .rd_data01 (weight_rd_data01),
        .rd_addr01 (weight_rd_addr01),
        .rd_data02 (weight_rd_data02),
        .rd_addr02 (weight_rd_addr02),
        .rd_data03 (weight_rd_data03),
        .rd_addr03 (weight_rd_addr03),

        .rd_data10 (weight_rd_data10),
        .rd_addr10 (weight_rd_addr10),
        .rd_data11 (weight_rd_data11),
        .rd_addr11 (weight_rd_addr11),
        .rd_data12 (weight_rd_data12),
        .rd_addr12 (weight_rd_addr12),
        .rd_data13 (weight_rd_data13),
        .rd_addr13 (weight_rd_addr13),

        .rd_data20 (weight_rd_data20),
        .rd_addr20 (weight_rd_addr20),
        .rd_data21 (weight_rd_data21),
        .rd_addr21 (weight_rd_addr21),
        .rd_data22 (weight_rd_data22),
        .rd_addr22 (weight_rd_addr22),
        .rd_data23 (weight_rd_data23),
        .rd_addr23 (weight_rd_addr23),

        .rd_data30 (weight_rd_data30),
        .rd_addr30 (weight_rd_addr30),
        .rd_data31 (weight_rd_data31),
        .rd_addr31 (weight_rd_addr31),
        .rd_data32 (weight_rd_data32),
        .rd_addr32 (weight_rd_addr32),
        .rd_data33 (weight_rd_data33),
        .rd_addr33 (weight_rd_addr33),

        .weight_fifo_data (weight_fifo_data),
        .weight_fifo_pop (weight_fifo_pop),
        .weight_fifo_empty (weight_fifo_empty),

        .weight_load_start (weight_load_start),
        .weight_load_done (weight_load_done),

        .clk (clk),
        .rst (rst)
    );

    output_fm #(
        .AW (AW),
        .DW (DW),
    ) output_fm (
        .out_fm_st_fifo_data (out_fm_st_fifo_data),
        .out_fm_st_fifo_push (out_fm_st_fifo_push),
        .out_fm_st_fifo_almost_full (out_fm_st_fifo_almost_full),

        .out_fm_ld_fifo_pop (out_fm_ld_fifo_pop),
        .out_fm_ld_fifo_data (out_fm_ld_fifo_data),
        .out_fm_ld_fifo_empty (out_fm_ld_fifo_empty),

        .inter_rd_data0 (out_fm_rd_data0),
        .inter_rd_addr0 (out_fm_rd_addr0),

        .inter_wr_data0 (out_fm_wr_data0),
        .inter_wr_addr0 (out_fm_wr_addr0),
        .inter_wr_ena0 (out_fm_wr_ena0),

        .inter_rd_data1 (out_fm_rd_data1),
        .inter_rd_addr1 (out_fm_rd_addr1),

        .inter_wr_data1 (out_fm_wr_data1),
        .inter_wr_addr1 (out_fm_wr_addr1),
        .inter_wr_ena1 (out_fm_wr_ena1),

        .inter_rd_data2 (out_fm_rd_data2),
        .inter_rd_addr2 (out_fm_rd_addr2),

        .inter_wr_data2 (out_fm_wr_data2),
        .inter_wr_addr2 (out_fm_wr_addr2),
        .inter_wr_ena2 (out_fm_wr_ena2),

        .inter_rd_data3 (out_fm_rd_data3),
        .inter_rd_addr3 (out_fm_rd_addr3),

        .inter_wr_data3 (out_fm_wr_data3),
        .inter_wr_addr3 (out_fm_wr_addr3),
        .inter_wr_ena3 (out_fm_wr_ena3),

        .out_fm_ld_start (out_fm_load_start),
        .out_fm_ld_done (out_fm_load_done),

        .out_fm_st_start (out_fm_store_start),
        .out_fm_st_done (out_fm_store_done),

        .clk (clk),
        .rst (rst)

    );

    conv_mem_if #(
        .DW (DW) 
    ) conv_mem_if_inst (
        // in_fm FIFO
        .in_fm_to_conv (in_fm_fifo_data),
        .in_fm_empty (in_fm_fifo_empty),
        .in_fm_pop (in_fm_fifo_pop),

        .in_fm_from_mem (in_fm_fifo_data_from_mem),
        .in_fm_almost_full (in_fm_fifo_almost_full),
        .in_fm_push (in_fm_fifo_push),

        // weight FIFO
        .weight_to_conv (weight_fifo_data),
        .weight_empty (weight_fifo_empty),
        .weight_pop (weight_fifo_pop),

        .weight_from_mem (weight_fifo_data_from_mem),
        .weight_almost_full (weight_fifo_almost_full),
        .weight_push (weight_fifo_push),

        // out_fm load FIFO
        .out_fm_ld_to_conv (out_fm_ld_fifo_data),
        .out_fm_ld_empty (out_fm_ld_fifo_empty),
        .out_fm_ld_pop (out_fm_ld_fifo_pop),

        .out_fm_ld_from_mem (out_fm_ld_fifo_data_from_mem),
        .out_fm_ld_almost_full (out_fm_ld_fifo_almost_full),
        .out_fm_ld_push (out_fm_ld_fifo_push),

        // out_fm store FIFO
        .out_fm_st_to_mem (out_fm_st_fifo_data_to_mem),
        .out_fm_st_empty (out_fm_st_fifo_empty),
        .out_fm_st_pop (out_fm_st_fifo_pop),

        .out_fm_st_from_conv (out_fm_st_fifo_data),
        .out_fm_st_almost_full (out_fm_st_fifo_almost_full),
        .out_fm_st_push (out_fm_st_fifo_push),

        .clk (clk),
        .rst (rst)
    );


    conv_ctrl_path #(
        .AW (AW),
        .Tn (Tn),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),
        .K (K),
        .S (S),
        .X (X),
        .Y (Y),
        .FP_MUL_DELAY (FP_MUL_DELAY),
        .FP_ADD_DELAY (FP_ADD_DELAY),
        .FP_ACCUM_DELAY (FP_ACCUM_DELAY)

    ) conv_ctrl_path_inst (
        .conv_load_start (conv_load_start),
        .conv_computing_start (conv_computing_start),
        .conv_computing_done (conv_computing_done),
        .kernel_start (kernel_start),

        .in_fm_rd_addr (in_fm_rd_addr),
        .weight_rd_addr (weight_rd_addr),
        .out_fm_rd_addr (out_fm_rd_addr),
        .out_fm_wr_addr (out_fm_wr_addr),
        .out_fm_wr_ena (out_fm_wr_ena),

        .clk (clk),
        .rst (rst)
    );

    assign in_fm_rd_addr0 = in_fm_rd_addr;
    assign in_fm_rd_addr1 = in_fm_rd_addr;
    assign in_fm_rd_addr2 = in_fm_rd_addr;
    assign in_fm_rd_addr3 = in_fm_rd_addr;

    assign weight_rd_addr00 = weight_rd_addr;
    assign weight_rd_addr01 = weight_rd_addr;
    assign weight_rd_addr02 = weight_rd_addr;
    assign weight_rd_addr03 = weight_rd_addr;

    assign weight_rd_addr10 = weight_rd_addr;
    assign weight_rd_addr11 = weight_rd_addr;
    assign weight_rd_addr12 = weight_rd_addr;
    assign weight_rd_addr13 = weight_rd_addr;

    assign weight_rd_addr20 = weight_rd_addr;
    assign weight_rd_addr21 = weight_rd_addr;
    assign weight_rd_addr22 = weight_rd_addr;
    assign weight_rd_addr23 = weight_rd_addr;

    assign weight_rd_addr30 = weight_rd_addr;
    assign weight_rd_addr31 = weight_rd_addr;
    assign weight_rd_addr32 = weight_rd_addr;
    assign weight_rd_addr33 = weight_rd_addr;

    assign out_fm_wr_addr0 = out_fm_wr_addr;
    assign out_fm_wr_ena0 = out_fm_wr_ena;
    assign out_fm_rd_addr0 = out_fm_rd_addr;

    assign out_fm_wr_addr1 = out_fm_wr_addr;
    assign out_fm_wr_ena1 = out_fm_wr_ena;
    assign out_fm_rd_addr1 = out_fm_rd_addr;

    assign out_fm_wr_addr2 = out_fm_wr_addr;
    assign out_fm_wr_ena2 = out_fm_wr_ena;
    assign out_fm_rd_addr2 = out_fm_rd_addr;
  
    assign out_fm_wr_addr3 = out_fm_wr_addr;
    assign out_fm_wr_ena3 = out_fm_wr_ena;
    assign out_fm_rd_addr3 = out_fm_rd_addr;

    conv_data_path #(
        .DW (DW),
        .FP_MUL_DELAY (FP_MUL_DELAY),
        .FP_ADD_DELAY (FP_ADD_DELAY),
        .FP_ACCUM_DELAY (FP_ACCUM_DELAY)

    ) conv_data_path0 (
        .in_fm_data0 (in_fm_rd_data0),
        .in_fm_data1 (in_fm_rd_data1),
        .in_fm_data2 (in_fm_rd_data2),
        .in_fm_data3 (in_fm_rd_data3),

        .weight0 (weight_rd_data00),
        .weight1 (weight_rd_data10),
        .weight2 (weight_rd_data20),
        .weight3 (weight_rd_data30),

        .out_fm_rd_data (out_fm_rd_data0),
        .out_fm_wr_data (out_fm_wr_data0),

        .kernel_start (kernel_start),

        .clk (clk),
        .rst (rst)
    );

    conv_data_path #(
        .DW (DW),
        .FP_MUL_DELAY (FP_MUL_DELAY),
        .FP_ADD_DELAY (FP_ADD_DELAY),
        .FP_ACCUM_DELAY (FP_ACCUM_DELAY)

    ) conv_data_path1 (
        .in_fm_data0 (in_fm_rd_data0),
        .in_fm_data1 (in_fm_rd_data1),
        .in_fm_data2 (in_fm_rd_data2),
        .in_fm_data3 (in_fm_rd_data3),

        .weight0 (weight_rd_data01),
        .weight1 (weight_rd_data11),
        .weight2 (weight_rd_data21),
        .weight3 (weight_rd_data31),

        .out_fm_rd_data (out_fm_rd_data1),
        .out_fm_wr_data (out_fm_wr_data1),

        .kernel_start (kernel_start),

        .clk (clk),
        .rst (rst)
    );

    conv_data_path #(
        .DW (DW),
        .FP_MUL_DELAY (FP_MUL_DELAY),
        .FP_ADD_DELAY (FP_ADD_DELAY),
        .FP_ACCUM_DELAY (FP_ACCUM_DELAY)

    ) conv_data_path2 (
        .in_fm_data0 (in_fm_rd_data0),
        .in_fm_data1 (in_fm_rd_data1),
        .in_fm_data2 (in_fm_rd_data2),
        .in_fm_data3 (in_fm_rd_data3),

        .weight0 (weight_rd_data02),
        .weight1 (weight_rd_data12),
        .weight2 (weight_rd_data22),
        .weight3 (weight_rd_data32),

        .out_fm_rd_data (out_fm_rd_data2),
        .out_fm_wr_data (out_fm_wr_data2),

        .kernel_start (kernel_start),

        .clk (clk),
        .rst (rst)
    );

    conv_data_path #(
        .DW (DW),
        .FP_MUL_DELAY (FP_MUL_DELAY),
        .FP_ADD_DELAY (FP_ADD_DELAY),
        .FP_ACCUM_DELAY (FP_ACCUM_DELAY)

    ) conv_data_path3 (
        .in_fm_data0 (in_fm_rd_data0),
        .in_fm_data1 (in_fm_rd_data1),
        .in_fm_data2 (in_fm_rd_data2),
        .in_fm_data3 (in_fm_rd_data3),

        .weight0 (weight_rd_data03),
        .weight1 (weight_rd_data13),
        .weight2 (weight_rd_data23),
        .weight3 (weight_rd_data33),

        .out_fm_rd_data (out_fm_rd_data3),
        .out_fm_wr_data (out_fm_wr_data3),

        .kernel_start (kernel_start),

        .clk (clk),
        .rst (rst)
    );

endmodule
