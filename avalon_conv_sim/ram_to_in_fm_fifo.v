/*
* Created           : cheng liu
* Date              : 2016-06-01
*
* Description:
* 
* This module moves a specified tile of data from RAM to fifo when the 
* 'start' signal is asserted. 'done' signal will be asserted when the data 
* movement is completed.  
* 
* Assumption:
* Given read address, the data from RAM will be available 2 cycles later.
* The original input data is stored in in_fm[M][R][C] with row major order.
* Apparently, the data in the tile doesn't fit in a sequential address space. 
*
* Instance example
ram_to_in_fm_fifo #(
    .AW (AW),
    .DW (DW),
    .M (M),
    .R (R),
    .C (C),
    .Tm (Tm),
    .Tr (Tr),
    .Tc (Tc)

) ram_to_fifo_inst (
    .start (),
    .done (),

    .fifo_push (),
    .fifo_almost_full (),
    .data_to_fifo (),

    .ram_addr (),
    .data_from_ram (),

    .tile_base_m (),
    .tile_base_row (),
    .tile_base_col (),

    .clk (),
    .rst ()
);
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module ram_to_in_fm_fifo #(

    parameter CW = 32,
    parameter AW = 32,
    parameter DW = 32,
    parameter M = 32,
    parameter R = 64,
    parameter C = 32,
    parameter Tm = 8,
    parameter Tr = 16,
    parameter Tc = 8,
    parameter XAW = 32,
    parameter XDW = 128,
    parameter WCNT = (XDW/DW),
    parameter BLEN = 8, //# of words (32) per transmission
    parameter MAX_PENDING = 16 // Note that FIFO_DEPTH (256 for now) in RMST >= MAX_PENDING * BLEN/4;

)(
    input                              start,
    output                             done,
    input                              conv_tile_clean,

    output                             fifo_push,
    input                              fifo_almost_full,
    output                   [DW-1: 0] data_to_fifo,

    output                   [AW-1: 0] ram_addr,
    input                    [DW-1: 0] data_from_ram,

    input                    [CW-1: 0] tile_base_m,
    input                    [CW-1: 0] tile_base_row,
    input                    [CW-1: 0] tile_base_col,

    input                              clk,
    input                              rst
);
    localparam rmst_fifo_capacity = 64;

    reg                                transfer_on_going_tmp;
    wire                               transfer_on_going;
    wire                               fifo_push_tmp;
    wire                     [AW-1: 0] logic_addr;
    wire                               is_addr_legal;
    wire                               is_data_legal;

    wire                     [CW-1: 0] tc;
    wire                     [CW-1: 0] tr;
    wire                     [CW-1: 0] tm;
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
    wire                               config_done,
    wire                    [XAW-1: 0] param_raddr,
    wire                     [AW-1: 0] param_iolen,

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            transfer_on_going_tmp <= 1'b0;
        end
        else if(start == 1'b1) begin
            transfer_on_going_tmp <= 1'b1;
        end
        else if(done == 1'b1) begin
            transfer_on_going_tmp <= 1'b0;
        end
    end

    assign transfer_on_going = (transfer_on_going_tmp == 1'b1) && (done == 1'b0);

    assign data_to_fifo = is_data_legal ? data_from_ram : 0;

    assign fifo_push_tmp = (fifo_almost_full == 1'b0) && (transfer_on_going == 1'b1);

    sig_delay #(
        .D (3)
    ) sig_delay0 (
        .sig_in (fifo_push_tmp),
        .sig_out (fifo_push),

        .clk (clk),
        .rst (rst)
    );

    sig_delay #(
        .D (2)
    ) sig_delay1 (
        .sig_in (is_addr_legal),
        .sig_out (is_data_legal),

        .clk (clk),
        .rst (rst)
    );



    assign logic_addr = (tile_base_m + tm) * R * C +
                        (tile_base_row + tr) * C + tile_base_col + tc;
    
    assign ram_addr = logic_addr;

    // Help the read master to do the flow control, as the stupid mem_top returns a meaningless rmst_done signal.
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rmst_read_data_num <= 0;
        end
        else if(rmst_go == 1'b1 && load_data_done == 1'b0) begin
            rmst_read_data_num <= rmst_read_data_num + (rmst_read_length >> 2);
        end
        else if(load_data_done == 1'b1) begin
            rmst_read_data_num <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rmst_pop_data_num <= 0;
        end
        else if (rmst_wr_ena_tmp == 1'b1 && load_data_done == 1'b0) begin
            rmst_pop_data_num = rmst_pop_data_num + 1;
        end
        else if (load_data_done == 1'b1) begin
            rmst_pop_data_num = 0;
        end
    end
    
    always@(posedge clk or posedge rst) begin
      if(rst == 1'b1) begin
        rmst_read_enable <= 1'b0;
      end
      else if(load_data_start == 1'b1) begin
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
        else if(config_done == 1'b1) begin
            raddr <= param_raddr;
            iolen <= param_iolen;
        end
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rd_len <= 0;
            rmst_read_base <= 0;
        end
        else if(config_done == 1'b1) begin
            rd_len <= param_iolen;
            rmst_read_base <= param_raddr;
        end
        else if(rmst_go == 1'b1) begin
            rd_len <= (rd_len > BLEN) ? (rd_len - BLEN) : 0;
            rmst_read_base <= (rd_len > BLEN) ? (rmst_read_base + (BLEN << 2)) : (rmst_read_base + (rd_len << 2));
        end
    end
    
    /*
    sig_delay #(
        .D (WCNT)
    ) sig_delay1 (
        .sig_in (rmst_done),
        .sig_out (load_data_done),

        .clk (clk),
        .rst (rst)
    );
    */
    
    assign load_data_done = (rmst_cnt_d2 == iolen-1);
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
    //assign rmst_user_read_buffer = rmst_user_data_available && (|rmst_word_ena); 
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

    //assign rmst_wr_data = rmst_rd_data[31: 0];
    assign rmst_load_data = rmst_rd_data[31: 0];
    assign rmst_wr_ena_tmp = |rmst_word_ena;
    assign rmst_wr_addr_tmp = rmst_cnt;
    
    sig_delay #(
        .D (2)
    ) sig_delay5 (
        .sig_in (rmst_wr_ena_tmp),
        .sig_out (load_fifo_push),

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

/*
 data_delay #(
        .D (2),
        .DW (AW)
    ) data_delay4 (
        .clk (clk),        
        .data_in (rmst_wr_addr_tmp),
        .data_out (rmst_wr_addr)
    );
*/


endmodule
