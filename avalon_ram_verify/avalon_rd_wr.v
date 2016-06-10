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

module avalon_rd_wr #(
    parameter AW = 12,
    parameter CW = 6,
    parameter DW = 32,
    parameter XAW = 32,
    parameter XDW = 128,
    parameter WCNT = (XDW/DW),
    parameter BLEN = 8, //# of words (32) per transmission
    parameter DATA_SIZE = 128,
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
    input                   [XAW-1: 0] param_raddr,
    input                    [AW-1: 0] param_iolen,
    input                   [XAW-1: 0] param_waddr,

    output                             load_data_done,
    output                             store_data_done,

    input                              store_data_start,
    input                              load_data_start,

    // Internal memomry port to the softmax_core
    //output                   [AW-1: 0] internal_wr_addr,
    //output                   [DW-1: 0] internal_wr_data,
    //output                             internal_wr_ena,

    //output                   [AW-1: 0] internal_rd_addr,
    //output                   [DW-1: 0] internal_rd_data,

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

    // Internal memory port to the read master
    wire                     [AW-1: 0] rmst_wr_addr;
    wire                     [DW-1: 0] rmst_wr_data;
    wire                               rmst_wr_ena;

    // Internal memory port to the write master
    wire                     [AW-1: 0] wmst_rd_addr;
    wire                     [DW-1: 0] wmst_rd_data;

    reg                     [XAW-1: 0] raddr;
    reg                     [XAW-1: 0] waddr;
    reg                      [AW-1: 0] iolen;
    reg                      [AW-1: 0] rd_len;
    reg                      [AW-1: 0] wr_len;
    reg                      [AW-1: 0] rmst_cnt;
    reg                      [AW-1: 0] wmst_cnt;
    reg                     [XDW-1: 0] rmst_rd_data;
    reg                    [WCNT-1: 0] rmst_word_ena;
    reg                    [WCNT-1: 0] wmst_word_ena;

    reg                     [XDW-1: 0] write_buffer_data_reg;
    wire                   [WCNT-1: 0] rmst_word_ena_d1;
    wire                   [WCNT-1: 0] wmst_word_ena_d2;
    wire                   [WCNT-1: 0] rmst_word_ena_d2;
    wire                     [AW-1: 0] rmst_wr_addr_tmp;
    wire                               rmst_wr_ena_tmp;
      
    reg                                rmst_done_reg;
    wire                               rmst_done_edge;
    reg                                wmst_done_reg;
    wire                               wmst_done_edge;
    reg                      [AW-1: 0] wmst_sent_data_num;
    reg                      [AW-1: 0] wmst_recv_data_num;
    reg                      [TW-1: 0] wmst_last_tran_len;
    reg                                rmst_read_enable;
    reg                                rmst_done_edge_reg;
    reg                      [AW-1: 0] rmst_read_data_num;
    reg                      [AW-1: 0] rmst_pop_data_num;

    // Help the read master to do the flow control, as the stupid mem_top returns a meaningless rmst_done signal.
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rmst_read_data_num <= 0;
        end
        else if(rmst_go == 1'b1) begin
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
        else if (rmst_wr_ena == 1'b1) begin
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
        wmst_done_reg <= wmst_done;
        rmst_done_edge_reg <= rmst_done_edge;
    end
    assign rmst_done_edge = rmst_done && (~rmst_done_reg);
    assign wmst_done_edge = wmst_done && (~wmst_done_reg);

    // Lock the parameters
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            raddr <= 0;
            waddr <= 0;
            iolen <= 0;
        end
        else if(config_done == 1'b1) begin
            raddr <= param_raddr;
            waddr <= param_waddr;
            iolen <= param_iolen;
        end
        else begin
            raddr <= raddr;
            waddr <= waddr;
            iolen <= iolen; 
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
    
    assign load_data_done = (rmst_wr_addr == iolen-1);
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
        else if(rmst_cnt != (iolen-1) && rmst_user_data_available == 1'b1 ) begin
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

    assign rmst_wr_data = rmst_rd_data[31: 0];
    assign rmst_wr_ena_tmp = |rmst_word_ena;
    assign rmst_wr_addr_tmp = rmst_cnt;
    
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
        end
        else if((store_data_start == 1'b1) && (wmst_user_buffer_full == 1'b0)) begin
            wmst_cnt <= 0;
            wmst_word_ena <= 1;
        end
        else if(wmst_cnt != (iolen-1) && (wmst_user_buffer_full == 1'b0)) begin
            wmst_cnt <= wmst_cnt + 1;
            wmst_word_ena <= {wmst_word_ena[WCNT-2: 0], wmst_word_ena[WCNT-1]};
        end
        else if(wmst_user_buffer_full == 1'b1) begin
            wmst_cnt <= wmst_cnt;
            wmst_word_ena <= wmst_word_ena;
        end
        else if(wmst_cnt == (iolen-1)) begin
            wmst_cnt <= wmst_cnt;
            wmst_word_ena <= 0;
        end
    end
    assign wmst_rd_addr = wmst_cnt;
    
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            write_buffer_data_reg <= 0;
        end
        else if((|wmst_word_ena_d2) && (wmst_user_buffer_full == 1'b0)) begin
            write_buffer_data_reg <= {wmst_rd_data, write_buffer_data_reg[XDW-1: 32]};
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

    assign store_data_done = (wmst_sent_data_num == iolen) && (wmst_done == 1'b1);
    
    sig_delay #(
        .D (2)
    ) sig_delay5 (
        .sig_in (rmst_wr_ena_tmp),
        .sig_out (rmst_wr_ena),

        .clk (clk),
        .rst (rst)
    );
    
    data_delay #(
        .D (2),
        .DW (AW)
    ) data_delay3 (
        .clk (clk),        
        .data_in (rmst_wr_addr_tmp),
        .data_out (rmst_wr_addr)
    );
        
  dp_mem #(
      .AW(AW),      .DW(DW),      .DATA_SIZE (DATA_SIZE)
  ) dp_mem (
	    .clk (clk),
	    .rst (rst),
	    .data_in (rmst_wr_data),
	    .raddr (wmst_rd_addr),
 	    .waddr (rmst_wr_addr),
	    .wena (rmst_wr_ena),
	    .data_out (wmst_rd_data)
	);

endmodule

