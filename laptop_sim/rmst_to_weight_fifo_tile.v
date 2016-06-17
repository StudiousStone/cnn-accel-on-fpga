/*
* Created           : Cheng Liu 
* Date              : 2016-06-05
* Email             : st.liucheng@gmail.com
*
* Description:
* Moves conv weight to FPGA through avalon read master. 
* 
* Instance example:
*
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module rmst_to_weight_fifo_tile #(
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
    // Port connected to the read master
    output                             rmst_fixed_location,
    output  [XAW-1: 0]                 rmst_read_base,
    output  [XAW-1: 0]                 rmst_read_length,
    output                             rmst_go,
    input                              rmst_done,

    output                             rmst_user_read_buffer,
    input   [XDW-1:0]                  rmst_user_buffer_data,
    input                              rmst_user_data_available, 

    output  [DW-1: 0]                  rmst_load_data,
    output                             load_fifo_push,
    input                              load_fifo_almost_full,

    input   [CW-1: 0]                  tile_base_n,
    input   [CW-1: 0]                  tile_base_m,

    output                             load_done,
    input                              load_start,

    input                              rst,
    input                              clk
);
    localparam WCNT = (XDW/DW);
    localparam BLEN = 8; 
    localparam CPW = XAW - CW;
    localparam RMST_FIFO_CAPACITY = 128;

    reg     [XAW-1: 0]                 raddr;
    reg     [CW-1: 0]                  iolen;
    reg     [CW-1: 0]                  rd_len;
    reg     [CW-1: 0]                  rmst_cnt;
    reg     [XDW-1: 0]                 rmst_rd_data;
    reg     [WCNT-1: 0]                rmst_word_ena;
    reg     [XAW-1: 0]                 rmst_read_base;
    wire    [CW-1: 0]                  read_length;


    reg     [WCNT-1: 0]                rmst_word_ena_d1;
    reg     [WCNT-1: 0]                rmst_word_ena_d2;
    wire    [WCNT-1: 0]                rmst_word_ena_d4;
    wire    [XAW-1: 0]                 rmst_wr_addr_tmp;
    wire                               rmst_wr_ena_tmp;
      
    reg                                rmst_done_reg;
    wire                               rmst_done_edge;
    reg                                rmst_read_enable;
    reg                                rmst_done_edge_reg;
    reg     [CW-1: 0]                  rmst_read_data_num;
    reg     [CW-1: 0]                  rmst_pop_data_num;

    // Parameters from the configuration module
    wire                               load_trans_start;
    wire                               load_trans_done;

    wire    [XAW-1: 0]                 param_raddr;
    wire    [CW-1: 0]                  param_iolen;
    reg                                rmst_user_data_available_reg;
    wire                               load_trans_done_tmp;
    wire                               load_trans_cnt_full;
    reg                                load_trans_cnt_full_reg;
    wire    [DW-1: 0]                  rmst_load_data_tmp0;
 
   // load filter signals
    wire    [DW-1: 0]                  rmst_load_data_tmp;
    wire                               load_fifo_push_tmp;

    weight_filter #(
        .AW (AW),
        .CW (CW),
        .DW (DW),

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

    ) weight_filter (
        .fifo_push_tmp    (load_fifo_push_tmp),
        .data_to_fifo_tmp (rmst_load_data_tmp),

        .fifo_push        (load_fifo_push),
        .data_to_fifo     (rmst_load_data),

        .tile_base_m      (tile_base_m),
        .tile_base_n      (tile_base_n),

        .clk              (clk),
        .rst              (rst)
    );

    always@(posedge clk) begin
        rmst_user_data_available_reg <= rmst_user_data_available;
        load_trans_cnt_full_reg <= load_trans_cnt_full;
    end

    rmst_weight_ctrl #(
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

    ) rmst_weight_ctrl (

        .load_start            (load_start),
        .load_done             (load_done),
  
        .param_raddr           (param_raddr), // aligned by byte
        .param_iolen           (param_iolen), // aligned by word

        .load_trans_done       (load_trans_done),
        .load_trans_start      (load_trans_start),

        .load_fifo_almost_full (load_fifo_almost_full),

        .tile_base_n           (tile_base_n),
        .tile_base_m           (tile_base_m),

        .rst                   (rst),
        .clk                   (clk)
    );


    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rmst_read_data_num <= 0;
        end
        else if(rmst_user_read_buffer == 1'b1) begin
            rmst_read_data_num <= rmst_read_data_num + 4;
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
    
    assign load_trans_done_tmp = load_trans_cnt_full && (~load_trans_cnt_full_reg);
    assign load_trans_cnt_full = (rmst_cnt == iolen - 1);
    assign rmst_fixed_location = 1'b0;
    assign rmst_read_length = {{CPW{1'b0}}, read_length};
    assign read_length = (rd_len > BLEN) ? (BLEN << 2) : (rd_len << 2);
    assign rmst_go = (rd_len > 0) && ((rmst_done_reg == 1'b1 && rmst_done != 1'b0) || rd_len == iolen) && 
                     (rmst_read_enable == 1'b1) && ((rmst_read_data_num - rmst_pop_data_num + BLEN) <= RMST_FIFO_CAPACITY);

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
        else if(rmst_cnt == (iolen-1) && rmst_word_ena[WCNT-1] == 1'b1) begin
            rmst_word_ena <= 0;
            rmst_cnt <= 0;
        end
    end

    always@(posedge clk) begin
        rmst_word_ena_d1 <= rmst_word_ena;
        rmst_word_ena_d2 <= rmst_word_ena_d1;
    end

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
            rmst_rd_data <= {{DW{1'b0}}, rmst_rd_data[XDW-1: DW]};
        end
    end

    assign rmst_load_data_tmp0 = rmst_rd_data[DW-1: 0];
    assign rmst_wr_ena_tmp = (|rmst_word_ena_d4) && (rmst_read_data_num > rmst_pop_data_num);
    assign rmst_wr_addr_tmp = rmst_cnt;
    
    sig_delay #(
        .D (2)
    ) sig_delay0 (
        .sig_in  (rmst_wr_ena_tmp),
        .sig_out (load_fifo_push_tmp),

        .clk     (clk),
        .rst     (rst)
    );
    
    sig_delay #(
        .D (4)
    ) sig_delay1 (        
        .sig_in  (load_trans_done_tmp),
        .sig_out (load_trans_done),

        .clk     (clk),
        .rst     (rst)
    );

    data_delay #(
        .D (4),
        .DW (DW)
    ) data_delay0 (
        .clk      (clk),        
        .data_in  (rmst_load_data_tmp0),
        .data_out (rmst_load_data_tmp)
    );

    data_delay #(
        .D (4),
        .DW (WCNT)
    ) data_delay1 (
        .clk      (clk),        
        .data_in  (rmst_word_ena),
        .data_out (rmst_word_ena_d4)
    );

endmodule

