/*
* Created           : cheng liu
* Date              : 2016-05-21
*
* Description:
* As there is no guarantee which of the input data loading will be completed last,
* all the three signals are analyzed in this module. The last done signal will be 
* considered as the load_done signal. 
* 
* Instance example
*
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on


module gen_load_done (
    input                              in_fm_load_done,
    input                              weight_load_done,
    input                              out_fm_load_done,

    output                             conv_load_done,

    input                              clk,
    input                              rst
);

    reg                                in_fm_load_done_keep;
    reg                                weight_load_done_keep;
    reg                                out_fm_load_done_keep;
    wire                               conv_load_done_keep;
    reg                                conv_load_done_keep_reg;

    assign conv_load_done_keep = (in_fm_load_done_keep || in_fm_load_done) &&
                                 (weight_load_done_keep || weight_load_done) &&
                                 (out_fm_load_done_keep || out_fm_load_done);

    always@(posedge clk) begin
        conv_load_done_keep_reg <= conv_load_done_keep;
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            in_fm_load_done_keep <= 1'b0;
        end
        else if(in_fm_load_done == 1'b1 && conv_load_done == 1'b0) begin
            in_fm_load_done_keep <= 1'b1;
        end
        else if(conv_load_done == 1'b1) begin
            in_fm_load_done_keep <= 1'b0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            weight_load_done_keep <= 1'b0;
        end
        else if(weight_load_done == 1'b1 && conv_load_done == 1'b0) begin
            weight_load_done_keep <= 1'b1;
        end
        else if(conv_load_done == 1'b1) begin
            weight_load_done_keep <= 1'b0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            out_fm_load_done_keep <= 1'b0;
        end
        else if(out_fm_load_done == 1'b1 && conv_load_done == 1'b0) begin
            out_fm_load_done_keep <= 1'b1;
        end
        else if(conv_load_done == 1'b1) begin
            out_fm_load_done_keep <= 1'b0;
        end
    end

    assign conv_load_done = conv_load_done_keep && (~conv_load_done_keep_reg);

endmodule
