/*
* Created           : cheng liu
* Date              : 2016-06-01
*
* Description:
* This modules creates a nested counter with three nests particularly 
* for multi-dimentional tile access. It will roll back when the specified 
* amount of counter value is achived
* 
*/

/*
 * Instance Example
nest4_counter #(
     .CW (),
     .n0_max (),
     .n1_max (),
     .n2_max (),
     .n3_max ()
 ) nest4_counter_inst (
     .ena (),
     .syn_rst (),

     .cnt0 (),
     .cnt1 (),
     .cnt2 (),
     .cnt3 (),

     .done (),

     .clk (clk),
     .rst (rst)
 );
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module nest4_counter #(
    parameter CW = 16,
    parameter n0_max = 4,
    parameter n1_max = 2,
    parameter n2_max = 2,
    parameter n3_max = 3
)(
    input                              ena,
    input                              syn_rst,

    output reg               [CW-1: 0] cnt0,
    output reg               [CW-1: 0] cnt1,
    output reg               [CW-1: 0] cnt2,
    output reg               [CW-1: 0] cnt3,

    output                             done, // It shows when the counter reaches MAX.
    
    input                              clk,
    input                              rst
);
    wire                               cnt0_full;
    wire                               cnt1_full;
    wire                               cnt2_full;
    wire                               cnt3_full;

    wire                               cnt0_done;
    wire                               cnt1_done;
    wire                               cnt2_done;
    wire                               cnt3_done;

    reg                                cnt0_full_reg;
    reg                                cnt1_full_reg;
    reg                                cnt2_full_reg;
    reg                                cnt3_full_reg;
    
    always@(posedge clk) begin
        cnt0_full_reg <= cnt0_full;
        cnt1_full_reg <= cnt1_full;
        cnt2_full_reg <= cnt2_full;
        cnt3_full_reg <= cnt3_full;
    end

    assign cnt0_done = cnt0_full && (~cnt0_full_reg);
    assign cnt1_done = cnt1_full && (~cnt1_full_reg);
    assign cnt2_done = cnt2_full && (~cnt2_full_reg);
    assign cnt3_done = cnt3_full && (~cnt3_full_reg);

    assign done = cnt3_done;

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

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            cnt1 <= n1_max;
        end
        else if(ena == 1'b1 && cnt1 == n1_max && sys_rst == 1'b0) begin
            cnt1 <= 0;
        end
        else if(ena == 1'b1 && cnt0_full == 1'b1 && cnt1 < n1_max - 1 && sys_rst == 1'b0) begin
            cnt1 <= cnt1 + 1;
        end
        else if(ena == 1'b1 && cnt0_full == 1'b1 && cnt1 == n1_max - 1 && sys_rst == 1'b0) begin
            cnt1 <= 0;
        end
        else if(sys_rst == 1'b1) begin
            cnt1 <= n1_max;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            cnt2 <= n2_max;
        end
        else if(ena == 1'b1 && cnt2 == n2_max && sys_rst == 1'b0) begin
            cnt2 <= 0;
        end
        else if(ena == 1'b1 && cnt1_full == 1'b1 && cnt2 < n2_max - 1 && sys_rst == 1'b0) begin
            cnt2 <= cnt2 + 1;
        end
        else if(ena == 1'b1 && cnt1_full == 1'b1 && cnt2 == n2_max - 1 && sys_rst == 1'b0) begin
            cnt2 <= 0;
        end
        else if(sys_rst == 1'b1) begin
            cnt2 <= n2_max;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            cnt3 <= n3_max;
        end
        else if(ena == 1'b1 && cnt3 == n3_max && sys_rst == 1'b0) begin
            cnt3 <= 0;
        end
        else if(ena == 1'b1 && cnt2_full == 1'b1 && cnt3 < n3_max - 1 && sys_rst == 1'b0) begin
            cnt3 <= cnt3 + 1;
        end
        else if(ena == 1'b1 && cnt2_full == 1'b1 && cnt3 == n3_max - 1 && sys_rst == 1'b0) begin
            cnt3 <= 0;
        end
        else if(sys_rst == 1'b1) begin
            cnt3 <= n3_max;
        end
    end
    
    assign cnt0_full = (cnt0 == n0_max - 1);
    assign cnt1_full = (cnt1 == n1_max - 1) && (cnt0_full == 1'b1);
    assign cnt2_full = (cnt2 == n2_max - 1) && (cnt1_full == 1'b1);
    assign cnt3_full = (cnt3 == n3_max - 1) && (cnt2_full == 1'b1);

endmodule
 
