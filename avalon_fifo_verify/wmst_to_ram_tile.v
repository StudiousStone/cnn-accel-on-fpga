/*
* Created           : Cheng Liu 
* Date              : 2016-04-25
*
* Description:
* This is a simple dual port memory allowing both read and write 
* operations at the same time as long as there are no read/write 
* conflicts. Note that the read port and write port are shared between 
* the internal softmax computing logic and the external system bus.
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module wmst_to_fifo_tile #(
    parameter AW = 12,
    parameter CW = 6,
    parameter DW = 32,
    parameter XAW = 32,
    parameter XDW = 128,
    parameter WCNT = (XDW/DW),
    parameter BLEN = 8, //# of words (32) per transmission
    parameter MAX_PENDING = 16 // Note that FIFO_DEPTH (256 for now) in RMST >= MAX_PENDING * BLEN/4;

)(
    // Port connected to the write master
    output                             wmst_fixed_location,
    output reg              [XAW-1: 0] wmst_write_base,
    output                   [CW-1: 0] wmst_write_length,
    output                             wmst_go,
    input                              wmst_done,

    output                  [XDW-1: 0] wmst_user_write_data,
    output                             wmst_user_write_buffer,
    input                              wmst_user_buffer_full,

    // Parameters from the configuration module
    input                              config_done,
    input                    [AW-1: 0] param_iolen,
    input                   [XAW-1: 0] param_waddr,

    output                             store_data_done,
    input                              store_data_start,

    // Internal memory port to the write master
    output reg                         fifo_pop,
    input                    [DW-1: 0] wmst_data_out,
    input                              fifo_empty,

    input                              rst,
    input                              clk
);

    // Assume write and read can be pipelined, but write must starts at lease WAR_DELAY cycles later.
    localparam RAW_DELAY = 200; 
    localparam rmst_fifo_capacity = 64;
    localparam TW = (BLEN < 64) ? 6 : 
                    (BLEN < 32) ? 5 :
                    (BLEN < 16) ? 4 :
                    (BLEN < 128) ? 7 :
                    (BLEN < 256) ? 8 : 16;


    reg                     [XAW-1: 0] waddr;
    reg                      [AW-1: 0] iolen;
    reg                      [AW-1: 0] wr_len;
    reg                      [AW-1: 0] wmst_cnt;
    reg                    [WCNT-1: 0] wmst_word_ena;

    reg                     [XDW-1: 0] write_buffer_data_reg;
    wire                   [WCNT-1: 0] wmst_word_ena_d2;
    reg                                wmst_done_reg;
    wire                               wmst_done_edge;
    reg                      [AW-1: 0] wmst_sent_data_num;
    reg                      [AW-1: 0] wmst_recv_data_num;
    reg                      [TW-1: 0] wmst_last_tran_len;
    reg                      [DW-1: 0] wmst_data_out_reg;

    // Lock the parameters
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            waddr <= 0;
            iolen <= 0;
        end
        else if(config_done == 1'b1) begin
            waddr <= param_waddr;
            iolen <= param_iolen;
        end
    end

    always@(posedge clk) begin
        wmst_done_reg <= wmst_done;
        wmst_data_out_reg <= wmst_data_out;
    end
    assign wmst_done_edge = wmst_done && (~wmst_done_reg);
    
    // =======================================================
    // Write data from user logic to the Avlon write master
    // =======================================================
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
            fifo_pop <= 1'b0;
        end
        else if((store_data_start == 1'b1) && (wmst_user_buffer_full == 1'b0) && fifo_empty == 1'b0) begin
            wmst_cnt <= 0;
            wmst_word_ena <= 1;
            fifo_pop <= 1'b1;
        end
        else if(wmst_cnt != (iolen-1) && (wmst_user_buffer_full == 1'b0) && fifo_empty == 1'b0) begin
            wmst_cnt <= wmst_cnt + 1;
            wmst_word_ena <= {wmst_word_ena[WCNT-2: 0], wmst_word_ena[WCNT-1]};
            fifo_pop <= 1'b1;
        end
        else if(wmst_user_buffer_full == 1'b1 || fifo_empty == 1'b1) begin
            wmst_cnt <= wmst_cnt;
            wmst_word_ena <= wmst_word_ena;
            fifo_pop <= 1'b0;
        end
        else if(wmst_cnt == (iolen-1)) begin
            wmst_cnt <= wmst_cnt;
            wmst_word_ena <= 0;
            fifo_pop <= 1'b0;
        end
    end
    //assign wmst_rd_addr = wmst_cnt;
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            write_buffer_data_reg <= 0;
        end
        else if((|wmst_word_ena_d2) && (wmst_user_buffer_full == 1'b0)) begin
            write_buffer_data_reg <= {wmst_data_out_reg, write_buffer_data_reg[XDW-1: 32]};
        end
    end    

    assign wmst_user_write_data = write_buffer_data_reg;
    
    // Issue send command to the write master to make sure it sends with BLEN bytes continuously.
    assign wmst_fixed_location = 1'b0;
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wmst_write_base <= 0;
        end
        else if(config_done == 1'b1) begin
            wmst_write_base <= param_waddr;
        end
        else if(wmst_go == 1'b1) begin
            wmst_write_base <= (wr_len > BLEN) ? (wmst_write_base + (BLEN << 2)) : (wmst_write_base + (wr_len << 2));
        end
    end
    
    assign wmst_write_length = (wr_len > BLEN) ? (BLEN << 2) : (wr_len << 2);     
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wr_len <= 0;
        end
        else if(config_done == 1'b1) begin
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
        else if (store_data_done == 1'b1) begin
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

    /*
    sig_delay #(
        .D (2)
    ) sig_delay2 (
        .sig_in (go_reg),
        .sig_out (wmst_go),

        .clk (clk),
        .rst (rst)
    );
    */
    
    data_delay #(
        .D (2),
        .DW (WCNT)
    ) data_delay2 (
        .clk (clk),        
        .data_in (wmst_word_ena),
        .data_out (wmst_word_ena_d2)
    );

    assign store_data_done = (wmst_sent_data_num == iolen && iolen != 0) && (wmst_done == 1'b1);
   

endmodule


