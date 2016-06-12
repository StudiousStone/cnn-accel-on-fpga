/*
* Created           : Cheng Liu
* Date              : 2016-04-30
*
* Description:
* Behavioral model of dual port RAM module.
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on
module dp_mem #(
    parameter AW = 12,
    parameter DW = 32,
    parameter DATA_SIZE = 128
)(
    input                              clk,
    input                              rst,
    input                    [AW-1: 0] raddr,
    input                    [AW-1: 0] waddr,
    input                    [DW-1: 0] data_in,
    input                              wena,
    output reg               [DW-1: 0] data_out
);
    localparam DP = 4096;
    reg                      [DW-1: 0] mem [0: DP-1];
    reg                      [DW-1: 0] data_reg;
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            data_reg <= 0;
        end
        else begin
            data_reg <= mem[raddr];
        end
    end
    
    always@(posedge clk) begin
        data_out <= data_reg;
    end
    
    always@(posedge clk) begin
        if(wena == 1'b1) begin
            mem[waddr] <= data_in;
        end
    end
    
    //Initialize the dp_mem

initial begin
  $readmemh("init.txt", mem, 0, DATA_SIZE - 1);
  #800000
  $writememh("result.txt", mem, 0, DATA_SIZE - 1);
  $stop(2);
end
    
endmodule