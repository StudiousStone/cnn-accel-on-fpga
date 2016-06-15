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

module rmst_to_in_fm_fifo_tile #(

    parameter AW = 12,
    parameter CW = 16,
    parameter DW = 32,
    parameter XAW = 32,
    parameter XDW = 128,
    parameter N = 32,
    parameter M = 32,
    parameter R = 64,
    parameter C = 32,
    parameter Tn = 16,
    parameter Tm = 16,
    parameter Tr = 64,
    parameter Tc = 16,
    parameter S = 1,
    parameter K = 3,
    parameter WCNT = (XDW/DW),
    parameter BLEN = 8, //# of words (32) per transmission
    parameter MAX_PENDING = 16 // Note that FIFO_DEPTH (256 for now) in RMST >= MAX_PENDING * BLEN/4;

)(
    // Port connected to the read master
    output                             rmst_fixed_location,
    output reg               [XAW-1:0] rmst_read_base,
    output                    [CW-1:0] rmst_read_length,
    output                             rmst_go,
    input                              rmst_done,

    output                             rmst_user_read_buffer,
    input                    [XDW-1:0] rmst_user_buffer_data,
    input                              rmst_user_data_available, 

    output                   [DW-1: 0] rmst_load_data,
    output                             load_fifo_push,
    input                              load_fifo_almost_full,

    input                    [CW-1: 0] tile_base_m,
    input                    [CW-1: 0] tile_base_row,
    input                    [CW-1: 0] tile_base_col,

    output                             load_done,
    input                              load_start,

    input                              rst,
    input                              clk
);

    localparam rmst_fifo_capacity = 64;

    reg                     [XAW-1: 0] raddr;
    reg                      [AW-1: 0] iolen;
    reg                      [AW-1: 0] rd_len;
    reg                      [AW-1: 0] rmst_cnt;
    reg                     [XDW-1: 0] rmst_rd_data;
    reg                    [WCNT-1: 0] rmst_word_ena;


    wire                   [WCNT-1: 0] rmst_word_ena_d1;
    wire                   [WCNT-1: 0] rmst_word_ena_d2;
    wire                     [AW-1: 0] rmst_cnt_d2;
    wire                     [AW-1: 0] rmst_wr_addr_tmp;
    wire                               rmst_wr_ena_tmp;
      
    reg                                rmst_done_reg;
    wire                               rmst_done_edge;
    reg                                rmst_read_enable;
    reg                                rmst_done_edge_reg;
    reg                      [AW-1: 0] rmst_read_data_num;
    reg                      [AW-1: 0] rmst_pop_data_num;

    // Parameters from the configuration module
    wire                               load_trans_start;
    wire                               load_trans_done;
    wire                    [XAW-1: 0] param_raddr;
    wire                     [AW-1: 0] param_iolen;

   // load filter signals
    wire                     [DW-1: 0] rmst_load_data_tmp;
    wire                               load_fifo_push_tmp;

in_fm_filter #(
    .AW (AW),
    .CW (CW),
    .DW (DW),
    .N (N),
    .M (M),
    .R (R),
    .C (C),
    .Tn (Tn),
    .Tm (Tm),
    .Tr (Tr),
    .Tc (Tc),
    .S (S),
    .K (K)

) in_fm_filter (
    .fifo_push_tmp (load_fifo_push_tmp),
    .data_to_fifo_tmp (rmst_load_data_tmp),
    
    .fifo_push (load_fifo_push),
    .data_to_fifo (rmst_load_data),

    .tile_base_m (tile_base_m),
    .tile_base_row (tile_base_row),
    .tile_base_col (tile_base_col),

    .clk (clk),
    .rst (rst)
);

    rmst_in_fm_ctrl #(
        .AW (AW),
        .CW (CW),
        .DW (DW),
        .N (N),
        .M (M),
        .R (R),
        .C (C),
        .Tn (Tn),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),
        .S (S),
        .K (K)
    ) rmst_in_fm_ctrl (
        .load_start (load_start),
        .load_done (load_done),
  
        .param_raddr (param_raddr), // aligned by byte
        .param_iolen (param_iolen), // aligned by word

        .load_trans_done (load_trans_done),
        .load_trans_start (load_trans_start),

        .load_fifo_almost_full (load_fifo_almost_full),

        .tile_base_m (tile_base_m),
        .tile_base_row (tile_base_row),
        .tile_base_col (tile_base_col),

        .rst (rst),
        .clk (clk)
    );


    // Help the read master to do the flow control, as the stupid mem_top returns a meaningless rmst_done signal.
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rmst_read_data_num <= 0;
        end
        else if(rmst_go == 1'b1 && load_trans_done == 1'b0) begin
            rmst_read_data_num <= rmst_read_data_num + (rmst_read_length >> 2);
        end
        else if(load_trans_done == 1'b1) begin
            rmst_read_data_num <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rmst_pop_data_num <= 0;
        end
        else if (rmst_wr_ena_tmp == 1'b1 && load_trans_done == 1'b0) begin
            rmst_pop_data_num = rmst_pop_data_num + 1;
        end
        else if (load_trans_done == 1'b1) begin
            rmst_pop_data_num = 0;
        end
    end
    
    always@(posedge clk or posedge rst) begin
      if(rst == 1'b1) begin
        rmst_read_enable <= 1'b0;
      end
      else if(load_trans_start == 1'b1) begin
        rmst_read_enable <= 1'b1;
      end
      else if(rd_len == 0) begin
        rmst_read_enable <= 1'b0;
      end
    end
    
    always@(posedge clk) begin
        rmst_done_reg <= rmst_done;
        rmst_done_edge_reg <= rmst_done_edge;
    end
    assign rmst_done_edge = rmst_done && (~rmst_done_reg);

    // Lock the parameters
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            raddr <= 0;
            iolen <= 0;
        end
        else if(load_trans_start == 1'b1) begin
            raddr <= param_raddr;
            iolen <= param_iolen;
        end
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rd_len <= 0;
            rmst_read_base <= 0;
        end
        else if(load_trans_start == 1'b1) begin
            rd_len <= param_iolen;
            rmst_read_base <= param_raddr;
        end
        else if(rmst_go == 1'b1) begin
            rd_len <= (rd_len > BLEN) ? (rd_len - BLEN) : 0;
            rmst_read_base <= (rd_len > BLEN) ? (rmst_read_base + (BLEN << 2)) : (rmst_read_base + (rd_len << 2));
        end
    end
    
    
    assign load_trans_done = (rmst_cnt_d2 == iolen-1);
    assign rmst_fixed_location = 1'b0;
    assign rmst_read_length = (rd_len > BLEN) ? (BLEN << 2) : (rd_len << 2);
    /*
    always@(posedge clk or posedge rst) begin
      if(rst == 1'b1) begin
        rmst_go <= 1'b0;
      end
      else begin
        
        rmst_go <= ((rmst_done_edge == 1'b1) || (rd_len == iolen)) && 
                   (rd_len > 0) && (rmst_done == 1'b1) && (rmst_read_enable == 1'b1);
      end
    end
    */
    assign rmst_go = (rd_len > 0) && ((rmst_done_reg == 1'b1 && rmst_done != 1'b0) || rd_len == iolen) && 
                     (rmst_read_enable == 1'b1) && ((rmst_read_data_num - rmst_pop_data_num + BLEN) <= rmst_fifo_capacity);

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rmst_word_ena <= 0;
            rmst_cnt <= 0;
        end
        else if(rmst_user_data_available == 1'b1 && rmst_word_ena == 0) begin
            rmst_word_ena <= 1;
            rmst_cnt <= 0;
        end
        else if(rmst_cnt != (iolen-1) && rmst_user_data_available == 1'b1) begin
            rmst_word_ena <= {rmst_word_ena[WCNT-2: 0], rmst_word_ena[WCNT-1]};
            rmst_cnt <= rmst_cnt + 1;
        end
        else if(rmst_user_data_available == 1'b0) begin
            rmst_word_ena <= rmst_word_ena;
            rmst_cnt <= rmst_cnt;
        end
        else if(rmst_cnt == (iolen-1)) begin
            rmst_word_ena <= 0;
            rmst_cnt <= 0;
        end
    end

    data_delay #(
        .D (1),
        .DW (WCNT)
    ) data_delay0 (
        .clk (clk),        
        .data_in (rmst_word_ena),
        .data_out (rmst_word_ena_d1)
    );
    
    data_delay #(
        .D (1),
        .DW (WCNT)
    ) data_delay1 (
        .clk (clk),        
        .data_in (rmst_word_ena_d1),
        .data_out (rmst_word_ena_d2)
    );

    // The test bench may be wrong. The read buffer signal behaves as a read request.
    // It guess it may take XDW as the data pop granularity from the Avlon interface FIFO.
    assign rmst_user_read_buffer = rmst_user_data_available && rmst_word_ena[WCNT-1]; 
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rmst_rd_data <= 0;
        end
        else if(rmst_user_data_available == 1'b1 && rmst_word_ena_d1[0] == 1'b1) begin
            rmst_rd_data <= rmst_user_buffer_data;
        end
        else begin
            rmst_rd_data <= {32'b0, rmst_rd_data[XDW-1: 32]};
        end
    end

    assign rmst_load_data_tmp = rmst_rd_data[31: 0];
    assign rmst_wr_ena_tmp = |rmst_word_ena;
    assign rmst_wr_addr_tmp = rmst_cnt;
    
    sig_delay #(
        .D (2)
    ) sig_delay5 (
        .sig_in (rmst_wr_ena_tmp),
        .sig_out (load_fifo_push_tmp),

        .clk (clk),
        .rst (rst)
    );
    
    data_delay #(
        .D (2),
        .DW (AW)
    ) data_delay3 (
        .clk (clk),        
        .data_in (rmst_cnt),
        .data_out (rmst_cnt_d2)
    );

endmodule



