/*
* Created           : cheng liu
* Date              : 2016-06-01
*
* Description:
* This modules creates a nested counter with three nests particularly 
* for multi-dimentional tile access. It will roll back when the specified 
* amount of counter value is achived
* 
* Instance Example
weight_counter #(
     .CW (),
     .n0_max ()

 ) weight_counter_inst (
     .ena (),
     .sys_rst (),

     .cnt0 (),
     .done (),

     .clk (clk),
     .rst (rst)
 );
*
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module weight_counter #(
    parameter CW = 16,
    parameter n0_max = 64
)(
    input                              ena,
    input                              sys_rst,

    output  [CW-1: 0]                  cnt0,
    output                             done, 
    
    input                              clk,
    input                              rst
);
    wire                               cnt0_full;
    wire                               cnt0_done;
    reg                                cnt0_full_reg;
    reg     [CW-1: 0]                  cnt0;
    
    always@(posedge clk) begin
        cnt0_full_reg <= cnt0_full;
    end

    assign cnt0_done = cnt0_full && (~cnt0_full_reg);
    assign done = cnt0_done;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            cnt0 <= n0_max;
        end
        else if(ena == 1'b1 && cnt0 == n0_max && sys_rst == 1'b0) begin
            cnt0 <= 0;
        end
        else if(ena == 1'b1 && cnt0 < n0_max - 1 && sys_rst == 1'b0) begin
            cnt0 <= cnt0 + 1;
        end
        else if(ena == 1'b1 && cnt0 == n0_max - 1 && sys_rst == 1'b0) begin
            cnt0 <= 0;
        end
        else if(sys_rst == 1'b1) begin
            cnt0 <= n0_max;
        end
    end
 
    assign cnt0_full = (cnt0 == n0_max - 1);

endmodule
 
