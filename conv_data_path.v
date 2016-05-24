/*
* Created           : cheng liu
* Date              : 2016-05-16
*
* Description:
* Data path that produces one partial pixel result of output_fm
* 
* Instance example
conv_data_path #(
    .DW (),
    .K ()
) conv_data_path_inst (
    .in_fm_data0 (),
    .in_fm_data1 (),
    .in_fm_data2 (),
    .in_fm_data3 (),

    .weight0 (),
    .weight1 (),
    .weight2 (),
    .weight3 (),

    .out_fm_rd_data (),
    .out_fm_wr_data (),

    .kernel_start (),
    .out_fm_wr_ena (),

    .clk (),
    .rst ()
);
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module conv_data_path #(
    parameter DW = 32,
    parameter FP_MUL_DELAY = 11,
    parameter FP_ADD_DELAY = 14,
    parameter FP_ACCUM_DELAY = 9
)(
    input                    [DW-1: 0] in_fm_data0,
    input                    [DW-1: 0] in_fm_data1,
    input                    [DW-1: 0] in_fm_data2,
    input                    [DW-1: 0] in_fm_data3,

    input                    [DW-1: 0] weight0,
    input                    [DW-1: 0] weight1,
    input                    [DW-1: 0] weight2,
    input                    [DW-1: 0] weight3,

    input                    [DW-1: 0] out_fm_rd_data,
    output                   [DW-1: 0] out_fm_wr_data,

    input                              kernel_start,

    input                              clk,
    input                              rst
);

    localparam load_to_accum_delay = FP_MUL_DELAY + 2 * FP_ADD_DELAY;

    wire                     [DW-1: 0] mul0_result;
    wire                     [DW-1: 0] mul1_result;
    wire                     [DW-1: 0] mul2_result;
    wire                     [DW-1: 0] mul3_result;

    wire                     [DW-1: 0] fpadd_L0_0_result;
    wire                     [DW-1: 0] fpadd_L0_1_result;
    wire                     [DW-1: 0] fpadd_top_result;
    wire                     [DW-1: 0] fpacc_result;

    // Multiplication
    fpmul11 fpmul0(
        .clock (clk),
        .dataa (in_fm_data0),
        .datab (weight0),
        .result (mul0_result)
    );

    fpmul11 fpmul1(
        .clock (clk),
        .dataa (in_fm_data1),
        .datab (weight1),
        .result (mul1_result)
    );

    fpmul11 fpmul2(
        .clock (clk),
        .dataa (in_fm_data2),
        .datab (weight2),
        .result (mul2_result)
    );

    fpmul11 fpmul3(
        .clock (clk),
        .dataa (in_fm_data3),
        .datab (weight3),
        .result (mul3_result)
    );


    // Adder tree
    fpadd14 fpadd_L0_0(
        .clock (clk),
        .dataa (mul0_result),
        .datab (mul1_result),
	    .result (fpadd_L0_0_result)
    );

    fpadd14 fpadd_L0_1(	
        .clock (clk),
        .dataa (mul2_result),
        .datab (mul3_result),
        .result (fpadd_L0_1_result)
    );

    fpadd14 fpadd_top(
        .clock (clk),
        .dataa (fpadd_L0_0_result),
        .datab (fpadd_L0_1_result),
        .result (fpadd_top_result)
    );

    // facc
    facc fpacc(
		.clk (clk), 
		.areset (rst),
		.x (fpadd_top_result),
		.n (fpacc_pulse),
		.r (fpacc_result),
		.xo (),
		.xu (),
		.ao ()
	);

    sig_delay #(
        .D (load_to_accum_delay + 3)
    ) sig_delay0 (
        .sig_in (kernel_start),
        .sig_out (fpacc_pulse),
        .clk (clk),
        .rst (rst)
    );

    // add partial out_fm to the result 
    fpadd14 fpadd_out_fm(
        .clock (clk),
        .dataa (fpacc_result),
        .datab (out_fm_rd_data),
        .result (out_fm_wr_data)
    );

endmodule
