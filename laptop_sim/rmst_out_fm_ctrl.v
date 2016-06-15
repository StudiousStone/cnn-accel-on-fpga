/*
* Created           : Cheng Liu
* Date              : 2016-04-25
*
* Description:
* Set softmax basic design parameters and expose information to upper mmodules
softmax_config #(
    .AW (),  // Internal memory address width
    .DW (),  // Internal data width
    .CW ()    // maxium number of configuration paramters is (2^CW).
)softmax_config(
    .config_ena (),
    .config_addr (),
    .config_wdata (),
    .config_rdata (),
    
    .config_done (),       // configuration is done. (orginal name: param_ena)
    .param_raddr (),
    .param_waddr (),
    .param_iolen (),
    .task_done (), // computing task is done. (original name: flag_over)
    
    .rst (),
    .clk ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module rmst_out_fm_ctrl #(
    parameter AW = 12,  // Internal memory address width
    parameter CW = 16,
    parameter DW = 32,  // Internal data width
    parameter N = 32,
    parameter M = 32,
    parameter R = 64,
    parameter C = 32,
    parameter tile_offset = 2,
    parameter Tn = 16,
    parameter Tm = 16,
    parameter Tr = 64,
    parameter Tc = 16,
    parameter S = 1,
    parameter K = 3
)(
    input                              load_start,
    output reg                         load_done,
  
    output                    [DW-1:0] param_raddr, // aligned by byte
    output reg                [AW-1:0] param_iolen, // aligned by word

    input                              load_trans_done,
    output reg                         load_trans_start,

    input                              load_fifo_almost_full,

    input                    [CW-1: 0] tile_base_n,
    input                    [CW-1: 0] tile_base_row,
    input                    [CW-1: 0] tile_base_col,

    input                              rst,
    input                              clk
);
    localparam RMST_IDLE = 3'b000;
    localparam RMST_CONFIG = 3'b001;
    localparam RMST_WAIT = 3'b010;
    localparam RMST_TRANS = 3'b011;
    localparam RMST_DONE = 3'b111;
    localparam out_fm_base = 0;

    reg                        [2: 0] rmst_status;
    wire                              is_last_trans_pulse;
    wire                   [DW-1: 0]  base_addr;
    wire                              row_burst_ena;
    wire                    [CW-1: 0] tn;
    wire                    [CW-1: 0] tr;
    reg                               is_last_trans;

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
    .n1_max (Tn),
    .n0_max (Tr)
) nest2_counter (
    .ena (row_burst_ena),
    .clean (load_done), // When the whole tile is loaded, the counter will be reset.

    .cnt0 (tr),
    .cnt1 (tn),

    .done (is_last_trans_pulse), 
    
    .clk (clk),
    .rst (rst)
);

assign row_burst_ena = rmst_status == RMST_CONFIG; // it is one cycle ahead of load_trans_start
assign base_addr = out_fm_base + (tile_base_n + tn) * R * C + (tile_base_row + tr) * C + tile_base_col;

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
            param_iolen <= Tc + tile_offset;
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

