/*
* Created           : cheng liu
* Date              : 2016-05-18
*
* Description:
* 
* test convolution core logic assuming a single tile of data
* 
* 
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on


module conv_tb;
    parameter AW = 16;
    parameter DW = 32;
    parameter N = 16;
    parameter M = 16;
    parameter R = 64;
    parameter C = 16;
    parameter Tn = 16;
    parameter Tm = 16;
    parameter Tr = 64;
    parameter Tc = 16;
    parameter K = 3;
    parameter X = 4;
    parameter Y = 4;
    parameter ACC_DELAY = 9;
    parameter DIV_DELAY = 20;
    parameter CLK_PERIOD = 10;

    localparam in_fm_size = M * R * C;
    localparam weight_size = N * M * K * K;
    localparam out_fm_size = N * R * C;
    localparam tmp = in_fm_size > out_fm_size ? in_fm_size : out_fm_size;
    localparam max_data_size = weight_size > tmp ? weight_size : tmp;
    localparam last_load_sel = (in_fm_size >= out_fm_size && in_fm_size >= weight_size) ? 2'b01 :
                               (weight_size >= in_fm_size && weight_size >= out_fm_size) ? 2'b10 : 2'b00;
    
    reg                       clk;
    reg                       rst;

    reg             [DW-1: 0] in_fm_mem[0: in_fm_size - 1];
    reg             [DW-1: 0] weight_mem[0: weight_size - 1];
    reg             [DW-1: 0] out_fm_mem[0: out_fm_size - 1];

    wire            [AW-1: 0] in_fm_rd_addr;
    wire            [AW-1: 0] weight_rd_addr;
    wire            [AW-1: 0] out_fm_rd_addr;
    wire            [AW-1: 0] out_fm_wr_addr;

    reg             [DW-1: 0] in_fm_rd_data;
    reg             [DW-1: 0] weight_rd_data;
    reg             [DW-1: 0] out_fm_rd_data;
    reg             [DW-1: 0] in_fm_rd_data_tmp;
    reg             [DW-1: 0] weight_rd_data_tmp;
    reg             [DW-1: 0] out_fm_rd_data_tmp;

    wire            [DW-1: 0] out_fm_wr_data;
    wire                      out_fm_wr_ena;

    reg                       conv_tile_start;
    wire                      conv_tile_load_start;
    wire                      conv_tile_computing_done;
    wire                      conv_tile_load_done;
    wire                      conv_tile_store_start;
    wire                      conv_tile_store_done;

    wire                      in_fm_load_start;
    reg                       in_fm_load_done;

    wire                      weight_load_start;
    reg                       weight_load_done;

    wire                      out_fm_load_start;
    reg                       out_fm_load_done;

    reg                       in_fm_load_on_going;
    reg                       weight_load_on_going;
    reg                       out_fm_load_on_going;

    reg             [AW-1: 0] in_fm_load_cnt;
    reg             [AW-1: 0] weight_load_cnt;
    reg             [AW-1: 0] out_fm_load_cnt;

    // clock and reset signal
    always #(CLK_PERIOD/2) clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;

        #10*CLK_PERIOD
        rst = 0;
    end

    // Initialize the outside memory and read the result after computing 
    initial begin
        $readmemh("in_fm.txt", in_fm_mem, 0, in_fm_size - 1);
        $readmemh("weight.txt", weight_mem, 0, weight_size - 1);
        $readmemh("out_fm_init.txt", out_fm_mem, 0, out_fm_size - 1);

        #6000*CLKPERIOD
        $writememh("out_fm_result.txt", out_fm_mem, 0, out_fm_size - 1);
        $stop(2);
    end

    // outside memory simulation model
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            in_fm_rd_data_tmp <= 0;
            weight_rd_data_tmp <= 0;

            out_fm_rd_data_tmp <= 0;
            in_fm_rd_data <= 0;

            weight_rd_data <= 0;
            out_fm_rd_data <= 0;
        end
        else begin
            in_fm_rd_data_tmp <= in_fm_mem[in_fm_rd_addr];
            in_fm_rd_data <= in_fm_rd_data_tmp;

            weight_rd_data_tmp <= weight_mem[weight_rd_addr];
            weight_rd_data <= weight_rd_data_tmp;

            out_fm_rd_data_tmp <= out_fm_mem[out_fm_rd_addr];
            out_fm_rd_data <= out_fm_rd_data_tmp;
        end
    end

    always@(posedge clk) begin
        if(out_fm_wr_ena == 1'b1) begin
            out_fm_mem[out_fm_wr_addr] <= out_fm_wr_data;
        end
    end

    // Generate conv start signal
    initial begin
        conv_tile_start = 1'b0;
        #(20*CLK_PERIOD)
        conv_tile_start = 1'b1;
        #CLK_PERIOD
        conv_tile_start = 1'b0;
    end

    // The three input data start loading at the same time.
    assign conv_tile_load_start = conv_tile_start;
    assign in_fm_load_start = conv_tile_start;
    assign weight_load_start = conv_tile_start;
    assign out_fm_load_start = conv_tile_start;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            conv_tile_load_on_going <= 1'b0;
        end
        else if(conv_tile_load_start == 1'b1) begin
            conv_tile_load_on_going <= 1'b1;
        end
        else if(conv_tile_load_done == 1'b1) begin
            conv_tile_load_on_going <= 1'b0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            in_fm_load_cnt <= 0;
        end
        else if(in_fm_push == 1'b1) begin
            in_fm_load_cnt <= in_fm_load_cnt + 1;
        end
        else if(in_fm_load_done == 1'b1) begin
            in_fm_load_cnt <= 0;
        end
    end

    assign in_fm_load_done = (in_fm_load_cnt == in_fm_size -1);
    assign in_fm_load_on_going = (in_fm_load_cnt < in_fm_size) && (conv_load_on_going == 1'b1);
    assign in_fm_fifo_push = (in_fm_fifo_almost_full == 1'b0) && (in_fm_load_on_going == 1'b1);

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            weight_load_cnt <= 0;
        end
        else if(weight_fifo_push == 1'b1) begin
            weight_load_cnt <= weight_load_cnt + 1;
        end
        else if(weight_load_done == 1'b1) begin
            weight_load_cnt <= 0;
        end
    end

    assign weight_load_done = (weight_load_cnt == weight_size - 1);
    assign weight_load_on_going = (weight_load_cnt < weight_size) && (conv_load_on_going == 1'b1);
    assign weight_load_fifo_push = (weight_fifo_almost_full == 1'b0) && (weight_fifo_on_going == 1'b1);


    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            out_fm_load_cnt <= 0;
        end
        else if(out_fm_fifo_push == 1'b1) begin
            out_fm_load_cnt <= out_fm_load_cnt + 1;
        end
        else if(out_fm_load_done == 1'b1) begin
            out_fm_load_cnt <= 0;
        end
    end

    assign out_fm_load_done = (out_fm_load_cnt == out_fm_size - 1);
    assign out_fm_load_on_going = (out_fm_load_cnt < out_fm_size) && (out_fm_load_on_going == 1'b1);
    assign out_fm_load_fifo_push = (out_fm_load_fifo_almost_full == 1'b0) && (out_fm_load_on_going == 1'b1);

    assign conv_tile_load_done = last_load_sel == 2'b01 ? in_fm_load_done :
                                 last_load_sel == 2'b10 ? weight_load_done : out_fm_load_done;

    assign conv_tile_store_start = conv_tile_computing_done;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            conv_tile_store_on_going <= 1'b0;
        end
        else if(conv_tile_store_start == 1'b1) begin
            conv_tile_store_on_going <= 1'b1;
        end
        else if(conv_tile_store_done == 1'b1) begin
            conv_tile_store_on_going <= 1'b0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            conv_tile_store_cnt <= 0;
        end
        else if(out_fm_st_fifo_pop == 1'b1) begin
            conv_tile_store_cnt <= conv_tile_store_cnt + 1;
        end
        else if(conv_tile_store_done == 1'b1) begin
            conv_tile_store_cnt <= 0;
        end
    end
    assign conv_tile_store_done = conv_tile_store_cnt == out_fm_size - 1;
    assign out_fm_st_fifo_pop = (out_fm_st_fifo_empty == 1'b0) && (conv_tile_store_on_going == 1'b1);

    conv_mem_if #(
        .DW (DW)
    ) conv_mem_if_inst (
        // in_fm FIFO
        .in_fm_to_conv (in_fm_to_conv),
        .in_fm_empty (in_fm_fifo_empty),
        .in_fm_pop (in_fm_fifo_pop),

        .in_fm_from_mem (in_fm_rd_data),
        .in_fm_almost_full (in_fm_fifo_almost_full),
        .in_fm_push (in_fm_fifo_push),

        // weight FIFO
        .weight_to_conv (weight_to_conv),
        .weight_empty (weight_fifo_empty),
        .weight_pop (weight_fifo_pop),

        .weight_from_mem (weight_rd_data),
        .weight_almost_full (weight_almost_full),
        .weight_push (weight_fifo_push),

        // out_fm load FIFO
        .out_fm_ld_to_conv (out_fm_ld_to_conv),
        .out_fm_ld_empty (out_fm_ld_fifo_empty),
        .out_fm_ld_pop (out_fm_ld_fifo_pop),

        .out_fm_ld_from_mem (out_fm_ld_rd_data),
        .out_fm_ld_almost_full (out_fm_ld_fifo_almost_full),
        .out_fm_ld_push (out_fm_ld_fifo_push),

        // out_fm store FIFO
        .out_fm_st_to_mem (out_fm_st_wr_data),
        .out_fm_st_empty (out_fm_st_fifo_empty),
        .out_fm_st_pop (out_fm_st_fifo_pop),

        .out_fm_st_from_conv (out_fm_st_from_conv),
        .out_fm_st_almost_full (out_fm_st_fifo_almost_full),
        .out_fm_st_push (out_fm_st_fifo_push),

        .clk (clk),
        .rst (rst)

    );

endmodule

