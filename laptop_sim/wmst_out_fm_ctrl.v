/*
* Created           : Cheng Liu
* Date              : 2016-06-10
* Email             : st.liucheng@gmail.com
*
* Description:
* Controls the avalon write master to move the convolution output to 
* the DDR.
*
* Instance example:
*
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module wmst_out_fm_ctrl #(
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
    input                              store_start,
    output                             store_done,
  
    output  [XAW-1: 0]                 param_waddr, // aligned by byte
    output  [CW-1: 0]                  param_iolen, // aligned by word

    input                              store_trans_done,        // computing task is done. (original name: flag_over)
    output                             store_trans_start,
    input                              store_fifo_empty,

    input   [CW-1: 0]                  tile_base_n,
    input   [CW-1: 0]                  tile_base_row,
    input   [CW-1: 0]                  tile_base_col,
    
    input                              rst,
    input                              clk
);

    localparam WMST_IDLE = 3'b000;
    localparam WMST_CONFIG = 3'b001; // Immediately ready for write transmission
    localparam WMST_WAIT = 3'b010; // wait for either no-empty store fifo or available avalon response
    localparam WMST_TRANS = 3'b011; // start data transmission
    localparam WMST_DONE = 3'b111; // complete the data transmiossion
    localparam OUT_FM_BASE = 0;

    localparam Tr_STEP = ((Tr + S - K)/S) * S;
    localparam Tc_STEP = ((Tc + S - K)/S) * S;
    localparam R_STEP = ((R + S - K)/S) * S;
    localparam C_STEP = ((C + S - K)/S) * S;
    
    reg                               store_done;
    reg     [CW-1: 0]                 param_iolen;
    reg                               store_trans_start;

    reg     [2: 0]                    wmst_status;
    wire                              is_last_trans_pulse;
    reg                               is_last_trans;

    wire    [XAW-1: 0]                base_addr;
    wire                              row_burst_ena;
    reg     [CW-1: 0]                 valid_row_len;
    reg     [CW-1: 0]                 valid_col_len;        
    reg     [CW-1: 0]                 valid_n_len;
    wire    [CW-1: 0]                 tn;
    wire    [CW-1: 0]                 tr;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            is_last_trans <= 1'b0;
        end
        else if(is_last_trans_pulse == 1'b1) begin
            is_last_trans <= 1'b1;
        end
        else if(store_done == 1'b1) begin
            is_last_trans <= 1'b0;
        end
    end

    // lock valid row and n length
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            valid_n_len <= 0;
            valid_row_len <= 0;
            valid_col_len <= 0;
        end
        // TO BE FIXED
        // the valid column length should be further analyzed. 4 <= It <= Tc_STEP.
        else if(store_start == 1'b1) begin
            valid_n_len <= (tile_base_n + Tn < N) ? Tn : (N - tile_base_n);
            valid_row_len <= ((tile_base_row + Tr < R) && (tile_base_row < R_STEP)) ? Tr_STEP : (R_STEP - tile_base_row);
            valid_col_len <= Tc_STEP;
            //(tile_base_col + Tc < C_STEP) ? col_step : (C_STEP - tile_base_col - 1);
        end
        else if(store_done == 1'b1) begin
            valid_n_len <= 0;
            valid_row_len <= 0;
            valid_col_len <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wmst_status <= WMST_IDLE;
        end
        else if(store_done == 1'b1) begin
            wmst_status <= WMST_IDLE;
        end
        else if (wmst_status == WMST_IDLE && store_start == 1'b1 && store_fifo_empty == 1'b0) begin
            wmst_status <= WMST_CONFIG;
        end
        else if (wmst_status == WMST_IDLE && store_start == 1'b1 && store_fifo_empty == 1'b1) begin
            wmst_status <= WMST_WAIT;
        end
        else if (wmst_status == WMST_WAIT && store_fifo_empty == 1'b0) begin
            wmst_status <= WMST_CONFIG;
        end
        else if (wmst_status == WMST_CONFIG) begin
            wmst_status <= WMST_TRANS;
        end
        else if(wmst_status == WMST_TRANS && store_trans_done == 1'b1) begin
            wmst_status <= WMST_DONE;
        end
        else if(wmst_status == WMST_DONE && is_last_trans == 1'b0 && store_fifo_empty == 1'b0) begin
            wmst_status <= WMST_CONFIG;
        end
        else if(wmst_status == WMST_DONE && is_last_trans == 1'b0 && store_fifo_empty == 1'b1) begin
            wmst_status <= WMST_WAIT;
        end
        else if(wmst_status == WMST_DONE && is_last_trans == 1'b1) begin
            wmst_status <= WMST_IDLE;
        end
    end

    out_fm_st_counter #(
        .CW (CW)
    ) out_fm_st_counter (
        .store_start  (store_start),

        .n0_max       (valid_row_len),
        .n1_max       (valid_n_len),

        .ena          (row_burst_ena),
        .syn_rst      (store_done), 

        .cnt0         (tr),
        .cnt1         (tn),
        .done         (is_last_trans_pulse), 

        .clk          (clk),
        .rst          (rst)
    );

    assign row_burst_ena = wmst_status == WMST_CONFIG; // it is one cycle ahead of load_trans_start
    assign base_addr = OUT_FM_BASE + (tile_base_n + tn) * R * C + (tile_base_row + tr) * C + tile_base_col;
    assign param_waddr = (base_addr << 2);

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            param_iolen <= 0;
        end
        else if(wmst_status == WMST_CONFIG) begin
            param_iolen <= valid_col_len;
        end
    end    

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            store_done <= 1'b0;
        end
        else if(wmst_status == WMST_DONE && is_last_trans == 1'b1) begin
            store_done <= 1'b1;
        end
        else begin
            store_done <= 1'b0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            store_trans_start <= 1'b0;
        end
        else if(wmst_status == WMST_CONFIG) begin
            store_trans_start <= 1'b1;
        end
        else begin
            store_trans_start <= 1'b0;
        end
    end

endmodule
