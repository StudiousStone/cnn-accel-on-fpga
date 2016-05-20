/*
* Created           : cheng liu
* Date              : 2016-05-19
*
* Description:
* Test the counter 
*
* 
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on


module counter_tb;

    parameter CW = 16;
    parameter MAX = 8;
    parameter CLK_PERIOD = 10;

    reg                                clk;
    reg                                rst;
    reg                                ena;
    wire                     [CW-1: 0] cnt;

    always #(CLK_PERIOD/2) clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 1;

        repeat (10) begin
            @(posedge clk);
        end
        rst = 0;
    end

    initial begin
        ena = 0;
        
        repeat (10) begin
            @(posedge clk);
        end
        ena = 1;
        
        repeat (2) begin
            @(posedge clk);
        end
        ena = 0;
        
        repeat (1) begin
          @(posedge clk);
        end
        ena = 1;
        
        repeat (50) begin
          @(posedge clk);
        end
        ena = 0;
        
        repeat (1) begin
          @(posedge clk);
        end
        $stop(2);
        
    end

    counter #(
        .CW (CW),
        .MAX (MAX)
    ) counter (
        .ena (ena),
        .done (done),
        .cnt (cnt),

        .clk (clk),
        .rst (rst)
    );
    
    reg                                 ena_reg;
    always@(posedge clk) begin
        ena_reg <= ena;
    end

endmodule
