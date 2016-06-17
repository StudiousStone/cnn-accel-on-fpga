/*
* Created           : Cheng Liu
* Date              : 2016-04-25
*
* Description:
* Control the read master to load convolution weight from a row to a tile, 
* and then from a tile to the whole input. 
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module rmst_weight_ctrl #(
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
    parameter Tc = 16
)(
    input                              load_start,
    output                             load_done,
  
    output  [XAW-1: 0]                 param_raddr, // aligned by byte
    output  [CW-1: 0]                  param_iolen, // aligned by word

    input                              load_trans_done,
    output                             load_trans_start,

    input                              load_fifo_almost_full,

    input   [CW-1: 0]                  tile_base_m,
    input   [CW-1: 0]                  tile_base_n,

    input                              rst,
    input                              clk
);
    localparam RMST_IDLE = 3'b000;
    localparam RMST_CONFIG = 3'b001;
    localparam RMST_WAIT = 3'b010;
    localparam RMST_TRANS = 3'b011;
    localparam RMST_DONE = 3'b111;
    localparam WEIGHT_BASE = 131072;
    localparam WEIGHT_BURST_LEN = Tm * K * K;
    localparam CPW = XAW - CW;

    reg                                load_done;
    reg     [CW-1: 0]                  param_iolen;
    reg                                load_trans_start;

    reg     [2: 0]                     rmst_status;
    wire                               is_last_trans_pulse;
    wire    [XAW-1: 0]                 base_addr;
    wire    [CW-1: 0]                  tn;
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

    weight_counter #(
        .CW (CW),
        .n0_max (Tn)
    ) weight_counter (
        .ena     (row_burst_ena),
        .syn_rst (load_done), // When the whole tile is loaded, the counter will be reset.

        .cnt0    (tn),

        .done    (is_last_trans_pulse), 

        .clk     (clk),
        .rst     (rst)
    );

    assign row_burst_ena = rmst_status == RMST_CONFIG; // it is one cycle ahead of load_trans_start
    assign base_addr = WEIGHT_BASE + (tile_base_n + tn) * M * K * K + tile_base_m * K * K;

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
            param_iolen <= WEIGHT_BURST_LEN;
        end
    end    

   always@(posedge clk or posedge rst) begin
       if(rst == 1'b1) begin
           load_done <= 1'b0;
       end
       else if(rmst_status == RMST_DONE && is_last_trans == 1'b1) begin
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

