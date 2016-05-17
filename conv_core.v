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
    parameter Y = 4     // # of parallel output_fm port
)(
    input                              conv_start, 
    output                             conv_done,

    // input_fm port
    input                    [DW-1: 0] in_fm_rd_data0,
    output                   [AW-1: 0] in_fm_rd_addr0,

    input                    [DW-1: 0] in_fm_rd_data1,
    output                   [AW-1: 0] in_fm_rd_addr1,

    input                    [DW-1: 0] in_fm_rd_data2,
    output                   [AW-1: 0] in_fm_rd_addr2,

    input                    [DW-1: 0] in_fm_rd_data3,
    output                   [AW-1: 0] in_fm_rd_addr3, 

    // weight of output channel 0
    input                    [DW-1: 0] weight_rd_data00,
    output                   [AW-1: 0] weight_rd_addr00,
    input                    [DW-1: 0] weight_rd_data01,
    output                   [AW-1: 0] weight_rd_addr01,
    input                    [DW-1: 0] weight_rd_data02,
    output                   [AW-1: 0] weight_rd_addr02,
    input                    [DW-1: 0] weight_rd_data03,
    output                   [AW-1: 0] weight_rd_addr03,

    // weight of output channel 1
    input                    [DW-1: 0] weight_rd_data10,
    output                   [AW-1: 0] weight_rd_addr10,
    input                    [DW-1: 0] weight_rd_data11,
    output                   [AW-1: 0] weight_rd_addr11,
    input                    [DW-1: 0] weight_rd_data12,
    output                   [AW-1: 0] weight_rd_addr12,
    input                    [DW-1: 0] weight_rd_data13,
    output                   [AW-1: 0] weight_rd_addr13,

    // weight of output channel 2
    input                    [DW-1: 0] weight_rd_data20,
    output                   [AW-1: 0] weight_rd_addr20,
    input                    [DW-1: 0] weight_rd_data21,
    output                   [AW-1: 0] weight_rd_addr21,
    input                    [DW-1: 0] weight_rd_data22,
    output                   [AW-1: 0] weight_rd_addr22,
    input                    [DW-1: 0] weight_rd_data23,
    output                   [AW-1: 0] weight_rd_addr23,

    // weight of output channel 3
    input                    [DW-1: 0] weight_rd_data30,
    output                   [AW-1: 0] weight_rd_addr30,
    input                    [DW-1: 0] weight_rd_data31,
    output                   [AW-1: 0] weight_rd_addr31,
    input                    [DW-1: 0] weight_rd_data32,
    output                   [AW-1: 0] weight_rd_addr32,
    input                    [DW-1: 0] weight_rd_data33,
    output                   [AW-1: 0] weight_rd_addr33,

    // port to output_fm bank0
    output                   [AW-1: 0] out_fm_wr_addr0,
    output                   [DW-1: 0] out_fm_wr_data0,
    output                             out_fm_wr_ena0,
    output                   [AW-1: 0] out_fm_rd_addr0,
    input                    [DW-1: 0] out_fm_rd_data0,

    output                   [AW-1: 0] out_fm_wr_addr1,
    output                   [DW-1: 0] out_fm_wr_data1,
    output                             out_fm_wr_ena1,
    output                   [AW-1: 0] out_fm_rd_addr1,
    input                    [DW-1: 0] out_fm_rd_data1,

    output                   [AW-1: 0] out_fm_wr_addr2,
    output                   [DW-1: 0] out_fm_wr_data2,
    output                             out_fm_wr_ena2,
    output                   [AW-1: 0] out_fm_rd_addr2,
    input                    [DW-1: 0] out_fm_rd_data2,
  
    output                   [AW-1: 0] out_fm_wr_addr3,
    output                   [DW-1: 0] out_fm_wr_data3,
    output                             out_fm_wr_ena3,
    output                   [AW-1: 0] out_fm_rd_addr3,
    input                    [DW-1: 0] out_fm_rd_data3,

    // system clock
    input                              clk,
    input                              rst
);
    wire                               kernel_start;
    wire                     [AW-1: 0] weight_rd_addr;
    wire                     [AW-1: 0] in_fm_rd_addr;
    wire                     [AW-1: 0] out_fm_wr_addr;
    wire                     [AW-1: 0] out_fm_rd_addr;

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
        .conv_start (conv_start),
        .conv_done (conv_done),

        .kernel_start (kernel_start),
        .weight_rd_addr (weight_rd_addr),
        .in_fm_rd_addr (in_fm_rd_addr),
        .out_fm_wr_addr (out_fm_wr_addr),
        .out_fm_rd_addr (out_fm_rd_addr),
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
        .K (K)
    ) conv_data_path1(
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
        .K (K)
    ) conv_data_path2(
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
        .K (K)
    ) conv_data_path3(
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
