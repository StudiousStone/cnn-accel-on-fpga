/*
* Created           : cheng liu
* Date              : 20160418
*
* Description:
* The softmax core assumes both a memory-mapped input buffer and an output buffer.
* It can be divided into 4 steps.
* Step1: find max value of the input
* Step2: Normalize the input data by subtracting the max value of input data
* Step3: Calculate expoential value
* Step4: Sum up the expoential value
* Step5: Calculate the resulting probality
* 
* Each step can be parallelized based on the read/write bandwidth. 
* Step2 ~ Step4 can be pipelined while step1 and step 5 must be done independently.
* 
softmax_core #(
    .AW (),
    .DW (),
    .DATA_SIZE (),
    .NORM_DELAY (),
    .EXP_DELAY (),
    .ACC_DELAY (),
    .DIV_DELAY ()
) softmax_core (
    // port connected with input memory
    .data_in (),
    .rd_addr (),

    // port connected with output memory
    .wr_ena (),
    .wr_addr (),
    .data_out (),

    // softmax_core control signals
    .softmax_core_start (), 
    .softmax_core_done (),
    
    .downstream_ready (),

    // global signals
    .clk (),
    .rst ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module softmax_core #(
    parameter AW = 10,
    parameter DW = 32,
    parameter DATA_SIZE = 128,
    parameter NORM_DELAY = 14,
    parameter EXP_DELAY = 17,
    parameter ACC_DELAY = 9,
    parameter DIV_DELAY = 20
)(
    // port connected with input memory
    input                    [DW-1: 0] data_in,
    output                   [AW-1: 0] rd_addr,

    // port connected with output memory
    output                             wr_ena,
    output                   [AW-1: 0] wr_addr,
    output                   [DW-1: 0] data_out,

    // softmax_core control signals
    input                              softmax_core_start, 
    output                             softmax_core_done,
    
    input                              downstream_ready,

    // global signals
    input                              clk,
    input                              rst
);

    reg                          [2:0] pipeline_sel;
    wire                     [DW-1: 0] scale;
    wire                     [DW-1: 0] get_max_rd_data;
    wire                     [AW-1: 0] get_max_rd_addr;

    wire                     [DW-1: 0] get_max_wr_data;
    wire                     [AW-1: 0] get_max_wr_addr;
    wire                               get_max_wr_ena;
    wire                               get_max_done;
    wire                               get_max_ready;

    wire                               norm_exp_sum_ready;
    wire                               norm_exp_sum_done;
    wire                     [DW-1: 0] sum;

    wire                     [DW-1: 0] norm_exp_sum_rd_data;
    wire                     [AW-1: 0] norm_exp_sum_rd_addr;

    wire                     [DW-1: 0] norm_exp_sum_wr_data;
    wire                     [AW-1: 0] norm_exp_sum_wr_addr;
    wire                               norm_exp_sum_wr_ena;

    wire                               proab_calu_ready;
    wire                     [DW-1: 0] proab_calu_rd_data;
    wire                     [AW-1: 0] proab_calu_rd_addr;

    wire                     [DW-1: 0] proab_calu_wr_data;
    wire                     [AW-1: 0] proab_calu_wr_addr;
    wire                               proab_calu_wr_ena;

    // Step1: Find max of input
    get_max #(
        .AW (AW),
        .DW (DW),
        .DATA_SIZE (DATA_SIZE)
    ) get_max_inst (
        // Synchronization with upstream process
        .get_max_start (softmax_core_start),
        .get_max_ready (get_max_ready),

        // Memory read port of input memory
        .rd_data (get_max_rd_data),
        .rd_addr (get_max_rd_addr),

        // Memory wirte port of the following intermediate memory
        .wr_data (get_max_wr_data),
        .wr_addr (get_max_wr_addr),
        .wr_ena (get_max_wr_ena),

        // Data sent to downsteam process (data is valid for only one pusle)
        .scale (scale),

        // Synchronization with the downstream process
        .downstream_ready (norm_exp_sum_ready),
        .get_max_done (get_max_done),

        .clk (clk),
        .rst (rst)
    );

    // Step2: Normalize the input data
    // Step3: calculate expoential value
    // Step4: Sum up the result
    norm_exp_sum #(
        .AW (AW),
        .DW (DW),
        .DATA_SIZE (DATA_SIZE),
        .NORM_DELAY (NORM_DELAY),
        .EXP_DELAY (EXP_DELAY),
        .ACC_DELAY (ACC_DELAY)

    )norm_exp_sum(
        .norm_exp_sum_start (get_max_done),
        .norm_exp_sum_ready (norm_exp_sum_ready),
        .scale (scale),

        // Memory read port of input memory
        .rd_data (norm_exp_sum_rd_data),
        .rd_addr (norm_exp_sum_rd_addr),

        // Memory write port of the following memory
        .wr_data (norm_exp_sum_wr_data),
        .wr_addr (norm_exp_sum_wr_addr),
        .wr_ena (norm_exp_sum_wr_ena),

        // Synchronization with the downstream process
        .downstream_ready (proab_calu_ready),
        .norm_exp_sum_done (norm_exp_sum_done),

        // Sum of the expoential result
        .sum (sum),

        //global signal
        .clk (clk),
        .rst (rst)
    );

    // Step5: Calculate the resulting probality
    proab_calu #(
        .AW (AW),
        .DW (DW),
        .DATA_SIZE (DATA_SIZE),
        .DIV_DELAY (DIV_DELAY)
    ) proab_calu (
        // The results will be written to an output memory.
        .proab_calu_start (norm_exp_sum_done),
        .proab_calu_ready (proab_calu_ready),
        .downstream_ready (downstream_ready),
        .proab_calu_done (softmax_core_done),

        // Memory write port
        .wr_data (proab_calu_wr_data),
        .wr_addr (proab_calu_wr_addr),
        .wr_ena (proab_calu_wr_ena),

        //The input is loaded from previous intermediate memory.
        .rd_data (proab_calu_rd_data),
        .rd_addr (proab_calu_rd_addr),

        .sum (sum),

        .clk (clk),
        .rst (rst)
    );

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            pipeline_sel <= 0;
        end
        else if(softmax_core_start == 1'b1) begin // Start get_max pipeline
            pipeline_sel <= 3'b001;
        end
        else if(get_max_done == 1'b1) begin // Start the norm_exp_sum pipeline
            pipeline_sel <= 3'b010;
        end
        else if(norm_exp_sum_done == 1'b1) begin // Start the proab_calu pipeline
            pipeline_sel <= 3'b100;
        end
        else if(softmax_core_done) begin // disable the selection when softmax core is done
            pipeline_sel <= 0;
        end
    end

    assign get_max_rd_data = pipeline_sel[0] ? data_in : 0;
    assign norm_exp_sum_rd_data = pipeline_sel[1] ? data_in : 0;
    assign proab_calu_rd_data = pipeline_sel[2] ? data_in : 0;

    assign rd_addr = pipeline_sel[0] ? get_max_rd_addr : 
                     pipeline_sel[1] ? norm_exp_sum_rd_addr :
                     pipeline_sel[2] ? proab_calu_rd_addr : 0;

    assign wr_ena = pipeline_sel[0] ? get_max_wr_ena : 
                    pipeline_sel[1] ? norm_exp_sum_wr_ena : 
                    pipeline_sel[2] ? proab_calu_wr_ena : 1'b0;

    assign wr_addr = pipeline_sel[0] ? get_max_wr_addr : 
                     pipeline_sel[1] ? norm_exp_sum_wr_addr : 
                     pipeline_sel[2] ? proab_calu_wr_addr : 0;

    assign data_out = pipeline_sel[0] ? get_max_wr_data : 
                      pipeline_sel[1] ? norm_exp_sum_wr_data : 
                      pipeline_sel[2] ? proab_calu_wr_data : 0;


endmodule
