/*
* Created           : Cheng Liu 
* Date              : 2016-06-10
* Email             : st.liucheng@gmail.com
*
* Description:
* Store output data to DDR via avalon write master.
* The basic idea is to transmit a tile of output row by row.
* Iterating all the tiles of the out feature map will 
* eventually complete the storing process of the convolution.
* 
* 
* Instance example: 
* 
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module wmst_to_out_fm_fifo_tile #(
    parameter AW = 12,
    parameter CW = 16,
    parameter DW = 32,
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
    // Port connected to the write master
    output                             wmst_fixed_location,
    output reg [XAW-1: 0]              wmst_write_base,
    output  [XAW-1: 0]                 wmst_write_length,
    output                             wmst_go,
    input                              wmst_done,

    output  [XDW-1: 0]                 wmst_user_write_data,
    output                             wmst_user_write_buffer,
    input                              wmst_user_buffer_full,

    output                             store_done,
    input                              store_start,

    input   [CW-1: 0]                  tile_base_n,
    input   [CW-1: 0]                  tile_base_row,
    input   [CW-1: 0]                  tile_base_col,

    input   [DW-1: 0]                  wmst_store_data,
    output reg                         store_fifo_pop,
    input                              store_fifo_empty,

    input                              rst,
    input                              clk
);

    localparam WCNT = (XDW/DW);
    localparam BLEN = 8; //# of words (32) per transmission
    localparam CPW = XAW - CW;

    wire    [CW-1: 0]                  write_length;
    reg     [XAW-1: 0]                 waddr;
    reg     [CW-1: 0]                  iolen;
    reg     [CW-1: 0]                  wr_len;
    reg     [CW-1: 0]                  wmst_cnt;
    reg     [WCNT-1: 0]                wmst_word_ena;

    reg     [XDW-1: 0]                 write_buffer_data_reg;
    wire    [WCNT-1: 0]                wmst_word_ena_d2;
    reg                                wmst_done_reg;
    wire                               wmst_done_edge;
    reg     [CW-1: 0]                  wmst_sent_data_num;
    reg     [CW-1: 0]                  wmst_recv_data_num;
    reg     [CW-1: 0]                  wmst_last_tran_len;
    reg     [DW-1: 0]                  wmst_store_data_d1;

    reg                                store_on_going;
    wire                               store_trans_start;
    wire                               store_trans_done;
    wire    [CW-1: 0]                  param_iolen;
    wire    [XAW-1: 0]                 param_waddr;


    wmst_out_fm_ctrl #(
        .AW (AW),
        .CW (CW),
        .DW (DW),
        .XAW (XAW),
        .XDW (XDW),

        .N (N),
        .M (M),
        .R (R),
        .C (C),
        .K (K),
        .S (S),

        .Tn (Tn),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc)

    ) wmst_out_fm_ctrl (
        .store_start       (store_start),
        .store_done        (store_done),
  
        .param_waddr       (param_waddr), // aligned by byte
        .param_iolen       (param_iolen), // aligned by word

        .store_trans_done  (store_trans_done),
        .store_trans_start (store_trans_start),
        .store_fifo_empty  (store_fifo_empty),

        .tile_base_n       (tile_base_n),
        .tile_base_row     (tile_base_row),
        .tile_base_col     (tile_base_col),

        .rst               (rst),
        .clk               (clk)
    );

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            store_on_going <= 1'b0;
        end
        else if(store_trans_start == 1'b1) begin
            store_on_going <= 1'b1;
        end
        else if(store_trans_done == 1'b1) begin
            store_on_going <= 1'b0;
        end
    end

    // Lock the parameters
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            waddr <= 0;
            iolen <= 0;
        end
        else if(store_trans_start == 1'b1) begin
            waddr <= param_waddr;
            iolen <= param_iolen;
        end
    end

    always@(posedge clk) begin
        wmst_done_reg <= wmst_done;
    end
    assign wmst_done_edge = wmst_done && (~wmst_done_reg);
    
    // Write data from user logic to the Avlon write master
    reg                                write_buffer_reg;
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            write_buffer_reg <= 1'b0;
        end
        else if(wmst_word_ena_d2[WCNT-1] == 1'b1 && wmst_user_buffer_full == 1'b0) begin
            write_buffer_reg <= 1'b1;
        end
        else begin
            write_buffer_reg <= 1'b0;
        end
    end
    
    assign wmst_user_write_buffer = write_buffer_reg;

    // As long as there are still available buffer in downstream module, 
    // data will be sent continuously.
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wmst_cnt <= 0;
            wmst_word_ena <= 0;
            store_fifo_pop <= 0;
        end
        else if((store_trans_start == 1'b1) && (wmst_user_buffer_full == 1'b0) && store_fifo_empty == 1'b0) begin
            wmst_cnt <= 0;
            wmst_word_ena <= 1'b1;
            store_fifo_pop <= 1'b1;
        end
        else if(wmst_cnt != (iolen-1) && (wmst_user_buffer_full == 1'b0) && store_fifo_empty == 1'b0 && store_on_going == 1'b1) begin
            wmst_cnt <= wmst_cnt + 1;
            wmst_word_ena <= {wmst_word_ena[WCNT-2: 0], wmst_word_ena[WCNT-1]};
            store_fifo_pop <= 1'b1;
        end
        else if(wmst_user_buffer_full == 1'b1 || store_fifo_empty == 1'b1) begin
            wmst_cnt <= wmst_cnt;
            wmst_word_ena <= wmst_word_ena;
            store_fifo_pop <= 1'b0;
        end
        else if(wmst_cnt == (iolen-1)) begin
            wmst_cnt <= wmst_cnt;
            wmst_word_ena <= 0;
            store_fifo_pop <= 1'b0;
        end
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            write_buffer_data_reg <= 0;
        end
        else if((|wmst_word_ena_d2) && (wmst_user_buffer_full == 1'b0)) begin
            write_buffer_data_reg <= {wmst_store_data_d1, write_buffer_data_reg[XDW-1: 32]};
        end
    end    

    assign wmst_user_write_data = write_buffer_data_reg;
    
    // Issue send command to the write master to make sure it sends with BLEN bytes continuously.
    assign wmst_fixed_location = 1'b0;
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wmst_write_base <= 0;
        end
        else if(store_trans_start == 1'b1) begin
            wmst_write_base <= param_waddr;
        end
        else if(wmst_go == 1'b1) begin
            wmst_write_base <= (wr_len > BLEN) ? (wmst_write_base + (BLEN << 2)) : (wmst_write_base + (wr_len << 2));
        end
    end
    
    assign wmst_write_length = {{CPW{1'b0}}, write_length}; 
    assign write_length = (wr_len > BLEN) ? (BLEN << 2) : (wr_len << 2);     
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wr_len <= 0;
        end
        else if(store_trans_start == 1'b1) begin
            wr_len <= param_iolen;
        end
        else if(wmst_go == 1'b1) begin
            wr_len <= (wr_len > BLEN) ? (wr_len - BLEN) : 0;
        end
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wmst_sent_data_num <= 0;
        end
        else if (wmst_done_edge == 1'b1) begin
            wmst_sent_data_num <= wmst_sent_data_num + wmst_last_tran_len;
        end
        else if(wmst_sent_data_num == iolen) begin
            wmst_sent_data_num <= 0;
        end
    end 
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wmst_recv_data_num <= 0;
        end
        else if (wmst_user_write_buffer == 1'b1) begin
            wmst_recv_data_num <= wmst_recv_data_num + 4;
        end
        else if ((wmst_recv_data_num == wmst_sent_data_num) && (wmst_recv_data_num == iolen)) begin
            wmst_recv_data_num <= 0;
        end
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wmst_last_tran_len = 0;
        end
        else if (wmst_go == 1'b1) begin
            wmst_last_tran_len = (wmst_write_length >> 2);
        end
        else if (store_trans_done == 1'b1) begin
            wmst_last_tran_len = 0;
        end
    end
        
    // Make sure the wmst_recv_data_num is updated after the wmst_done is asserted.
    reg                                 wmst_go_reg;
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wmst_go_reg <= 1'b0;
        end
        else begin
            wmst_go_reg <= wmst_go;
        end
    end
    
    // As the wmst_recv_data_num updates one cycle after wmst_done, thus the comparison 
    // will not be valid at the first cycle that wmst_done is asserted.
    assign wmst_go = ((wmst_recv_data_num >= (BLEN + wmst_sent_data_num)) && wmst_done == 1'b1 && wmst_done_edge == 1'b0) || 
                     ((wmst_recv_data_num > wmst_sent_data_num) && (wmst_recv_data_num == iolen) && (wmst_done == 1'b1) && wmst_done_edge == 1'b0);

    data_delay #(
        .D (2),
        .DW (WCNT)
    ) data_delay0 (
        .clk (clk),        
        .data_in (wmst_word_ena),
        .data_out (wmst_word_ena_d2)
    );

    always@(posedge clk) begin
        wmst_store_data_d1 <= wmst_store_data;
    end

    assign store_trans_done = (wmst_sent_data_num == iolen && iolen != 0) && (wmst_done == 1'b1);

endmodule



