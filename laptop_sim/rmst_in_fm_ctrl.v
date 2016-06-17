/*
* Created           : Cheng Liu
* Date              : 2016-04-25
*
* Description:
* This module controls the read master to load the input feacture map for the whole convolution. 
* To achieve this goal, it performs avalon burst transmission with the granularity of a row of a tile. 
* Then it goes up to a tile and finally the whole input feacture map.
*
* Instance example:
*
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module rmst_in_fm_ctrl #(
    parameter AW = 12,  // Internal memory address width
    parameter CW = 16,
    parameter DW = 32,  // Internal data width
    parameter XAW = 32,
    parameter XDW = 128,

    parameter N = 32,
    parameter M = 32,
    parameter R = 64,
    parameter C = 32,
    parameter K = 3,
    parameter S = 1,

    parameter Tn = 16,
    parameter Tm = 16,
    parameter Tr = 64,
    parameter Tc = 16,

    parameter TILE_ROW_OFFSET = 2
)(
    input                              load_start,
    output                             load_done,
  
    output  [XAW-1:0]                  param_raddr,
    output  [CW-1:0]                   param_iolen,

    input                              load_trans_done,
    output                             load_trans_start,

    input                              load_fifo_almost_full,

    input   [CW-1: 0]                  tile_base_m,
    input   [CW-1: 0]                  tile_base_row,
    input   [CW-1: 0]                  tile_base_col,

    input                              clk,
    input                              rst
);
    localparam RMST_IDLE = 3'b000;
    localparam RMST_CONFIG = 3'b001;
    localparam RMST_WAIT = 3'b010;
    localparam RMST_TRANS = 3'b011;
    localparam RMST_DONE = 3'b111;
    localparam IN_FM_BASE = 65536;

    reg                                load_done;
    reg     [CW-1:0]                   param_iolen;
    reg                                load_trans_start;
    reg     [2: 0]                     rmst_status;
    wire                               is_last_trans_pulse;
    wire    [XAW-1: 0]                 base_addr;
    wire                               row_burst_ena;
    wire    [CW-1: 0]                  tm;
    wire    [CW-1: 0]                  tr;
    reg                                is_last_trans;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            is_last_trans <= 1'b0;
        end
        else if(is_last_trans_pulse == 1'b1) begin
            is_last_trans <= 1'b1;
        end
        else if(load_done == 1'b1) begin
            is_last_trans <= 1'b0;
        end
    end

    nest2_counter #(
        .CW (CW),
        .n1_max (Tm),
        .n0_max (Tr)
    ) nest2_counter (
        .ena     (row_burst_ena),
        .syn_rst (load_done), // When the whole tile is loaded, the counter will be reset.

        .cnt0    (tr),
        .cnt1    (tm),

        .done    (is_last_trans_pulse), 

        .clk     (clk),
        .rst     (rst)
    );

    assign row_burst_ena = rmst_status == RMST_CONFIG; // it is one cycle ahead of load_trans_start
    assign base_addr = IN_FM_BASE + (tile_base_m + tm) * R * C + (tile_base_row + tr) * C + tile_base_col;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rmst_status <= RMST_IDLE;
        end
        else if(load_done == 1'b1) begin
            rmst_status <= RMST_IDLE;
        end
        else if (rmst_status == RMST_IDLE && load_start == 1'b1 && load_fifo_almost_full == 1'b0) begin
            rmst_status <= RMST_CONFIG;
        end
        else if (rmst_status == RMST_IDLE && load_start == 1'b1 && load_fifo_almost_full == 1'b1) begin
            rmst_status <= RMST_WAIT;
        end
        else if(rmst_status == RMST_WAIT && load_fifo_almost_full == 1'b0) begin
            rmst_status <= RMST_CONFIG;
        end
        else if (rmst_status == RMST_CONFIG) begin
            rmst_status <= RMST_TRANS;
        end
        else if(rmst_status == RMST_TRANS && load_trans_done == 1'b1) begin
            rmst_status <= RMST_DONE;
        end
        else if(rmst_status == RMST_DONE && is_last_trans == 1'b0 && load_fifo_almost_full == 1'b0) begin
            rmst_status <= RMST_CONFIG;
        end
        else if(rmst_status == RMST_DONE && is_last_trans == 1'b0 && load_fifo_almost_full == 1'b1) begin
            rmst_status <= RMST_WAIT;
        end 
        else if(rmst_status == RMST_DONE && is_last_trans == 1'b1) begin
            rmst_status <= RMST_IDLE;
        end
    end

    assign param_raddr = (base_addr << 2);
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            param_iolen <= 0;
        end
        else if(rmst_status == RMST_CONFIG) begin
            param_iolen <= Tc + TILE_ROW_OFFSET;
        end
    end    

   always@(posedge clk or posedge rst) begin
       if(rst == 1'b1) begin
           load_done <= 1'b0;
       end
       else if(rmst_status == RMST_DONE  && is_last_trans == 1'b1) begin
           load_done <= 1'b1;
       end
       else begin
           load_done <= 1'b0;
       end
   end

   // The data transmission can be more aggressive.
   always@(posedge clk or posedge rst) begin
       if(rst == 1'b1) begin
           load_trans_start <= 1'b0;
       end
       else if(rmst_status == RMST_CONFIG) begin
           load_trans_start <= 1'b1;
       end
       else begin
           load_trans_start <= 1'b0;
       end
   end

endmodule

