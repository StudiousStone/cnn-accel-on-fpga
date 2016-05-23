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

    wire                      conv_tile_start;
    wire                      in_fm_load_start;
    wire                      in_fm_load_done;
    wire                      weight_load_start;
    wire                      weight_load_done;
    wire                      out_fm_load_start;
    wire                      out_fm_load_done;
    wire                      conv_tile_load_done;
    
    wire                      conv_tile_computing_start;
    wire                      conv_tile_computing_done;

    wire                      conv_tile_store_start;
    wire                      conv_tile_store_done;


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
        repeat (20) begin
            @(posedge clk)
        end
        conv_tile_start = 1'b1;
        @(posedge clk)
        conv_tile_start = 1'b0;
    end

    // The three input data start loading at the same time.
    // Connect the in_fm ram port with the fifo port
    ram_to_fifo #(
        .CW (DW),
        .AW (DW),
        .DW (DW),
        .DATA_SIZE (in_fm_size)
    ) in_fm_ram_to_fifo (
        .start (in_fm_load_start),
        .done (in_fm_load_done),

        .fifo_push (in_fm_fifo_push),
        .fifo_almost_full (in_fm_fifo_almost_full),
        .data_to_fifo (in_fm_fifo_data_from_mem),

        .ram_addr (in_fm_rd_addr),
        .data_from_ram (in_fm_rd_data),

        .clk (clk),
        .rst (rst)
    );

    ram_to_fifo #(
        .CW (DW),
        .AW (DW),
        .DW (DW),
        .DATA_SIZE (weight_size)
    ) weight_ram_to_fifo (
        .start (weight_load_start),
        .done (weight_load_done),

        .fifo_push (weight_fifo_push),
        .fifo_almost_full (weight_fifo_almost_full),
        .data_to_fifo (weight_fifo_data_from_mem),

        .ram_addr (weight_rd_addr),
        .data_from_fifo (weight_rd_data),

        .clk (clk),
        .rst (rst)
    );
    
    ram_to_fifo #(
        .CW (CW),
        .AW (DW),
        .DW (DW),
        .DATA_SIZE (out_fm_size)
    ) out_fm_to_fifo (
        .start (out_fm_load_start),
        .done (out_fm_load_done),

        .fifo_push (out_fm_fifo_push),
        .fifo_almost_full (out_fm_fifo_almost_full),
        .data_to_fifo (out_fm_fifo_data_from_mem),

        .ram_addr (out_fm_rd_addr),
        .data_from_fifo (out_fm_rd_data),

        .clk (clk),
        .rst (rst)
    );

    fifo_to_ram #(
        .CW (DW),
        .AW (DW),
        .DW (DW),
        .DATA_SIZE (out_fm_size)
    ) fifo_to_out_fm_ram(
        .start (out_fm_store_start),
        .done (out_fm_store_done),

        .fifo_pop (out_fm_st_fifo_pop),
        .fifo_empty (out_fm_st_fifo_empty),
        .data_from_fifo (out_fm_st_fifo_data_to_mem),

        .ram_wena (out_fm_wr_ena),
        .ram_addr (out_fm_wr_addr),
        .data_to_ram (out_fm_wr_data),

        .clk (clk),
        .rst (rst)
    );

    assign in_fm_load_start = conv_tile_start;
    assign weight_load_start = conv_tile_start;
    assign out_fm_load_start = conv_tile_start;
    assign conv_tile_load_done = last_load_sel == 2'b01 ? in_fm_load_done :
                                 last_load_sel == 2'b10 ? weight_load_done : out_fm_load_done;

    assign conv_tile_store_start = conv_tile_computing_done;

    conv_core #(

        .AW (AW),  // input_fm bank address width
        .DW (DW),  // data width
        .Tn (Tn),  // output_fm tile size on output channel dimension
        .Tm (Tm),  // input_fm tile size on input channel dimension
        .Tr (Tr),  // input_fm tile size on feature row dimension
        .Tc (Tc),  // input_fm tile size on feature column dimension
        .K (K),    // kernel scale
        .X (X),    // # of parallel input_fm port
        .Y (Y),    // # of parallel output_fm port
        .FP_MUL_DELAY (FP_MUL_DELAY), // multiplication delay
        .FP_ADD_DELAY (FP_ADD_DELAY), // addition delay
        .FP_ACCUM_DELAY (FP_ACCUM_DELAY) // accumulation delay
    ) conv_core (
        .conv_start (conv_tile_start), 
        .conv_done (conv_tile_done),
        .conv_computing_done (conv_tile_computing_done),

        // port to or from outside memory through FIFO
        .in_fm_fifo_data_from_mem (in_fm_fifo_data_from_mem),
        .in_fm_fifo_push (in_fm_fifo_push),
        .in_fm_fifo_almost_full (in_fm_fifo_almost_full),

        .weight_fifo_data_from_mem (weight_fifo_data_from_mem),
        .weight_fifo_push (weight_fifo_push),
        .weight_fifo_almost_full (weight_fifo_almost_full),

        .out_fm_ld_fifo_data_from_mem (out_fm_ld_fifo_data_from_mem),
        .out_fm_ld_fifo_push (out_fm_ld_fifo_push),
        .out_fm_ld_fifo_almost_full (out_fm_ld_fifo_almost_full),

        .out_fm_st_fifo_data_to_mem (out_fm_st_fifo_data_to_mem),
        .out_fm_st_fifo_empty (out_fm_st_fifo_empty),
        .out_fm_st_fifo_pop (out_fm_st_fifo_pop),

        // system clock
        .clk (clk),
        .rst (rst)
    );

endmodule

