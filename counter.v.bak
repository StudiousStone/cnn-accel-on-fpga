/*
* Created           : cheng liu
* Date              : 2016-05-19
*
* Description:
* The counter automatically increases one by one given enable signal.
* When the counter reaches the pre-defined value, it will go back to zero.
*
* cnt is essentially an FSM, and MAX is used to represent the 'IDLE' state.
* Therefore, the user must make sure 2^CW > MAX.
*/

/*
 * Instance Example
counter #(
     .CW (),
     .MAX ()
 ) counter_inst (
     .ena (),
     .start (),
     .cnt (),
     .done (),

     .clk (clk),
     .rst ()
 );
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module counter #(
    parameter CW = 16,
    parameter MAX = 1024
)(
    input                              ena,
    output reg               [CW-1: 0] cnt,
    output                             done, // It shows when the counter reaches MAX.
    
    input                              clk,
    input                              rst
);
    wire                               cnt_full;
    reg                                cnt_full_reg;

    always@(posedge clk) begin
        cnt_full_reg <= cnt_full;
    end

    assign done = cnt_full && (~cnt_full_reg);

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            cnt <= MAX;
        end
        else if(ena == 1'b1 && cnt == MAX) begin
            cnt <= 0;
        end
        else if(ena == 1'b1 && cnt < MAX - 1) begin
            cnt <= cnt + 1;
        end
        else if(ena == 1'b1 && cnt == MAX - 1) begin
            cnt <= 0;
        end
    end
    
    assign cnt_full = (cnt == MAX - 1);

endmodule
 
