/*
* Created           : cheng liu
* Date              : 2016-05-28
*
* Description:
* This module assumes all the input/output data are stored in RAM blocks. 
* It schedules the input/output data with the granularity of a tile. Meanwhile 
* it automatically fill zeros when the remaining input/output can't fit into 
* a tile.
* 
*
* Instance example:
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on


module conv_top_tb; 

    parameter N = 128;
    parameter M = 256;
    parameter R = 128;
    parameter C = 128;
    parameter Tn = 16;
    parameter Tm = 16;
    parameter Tr = 64;
    parameter Tc = 16;
    parameter S = 1;
    parameter K = 3;
    parameter X = 4;
    parameter Y = 4;
    parameter AW = 32;
    parameter DW = 32;

    localparam in_fm_size = M * R * C;
    localparam weight_size = N * M * K * K;
    localparam out_fm_size = N * R * C;
    localparam tile_N_num = (N%Tn == 0) ? (N/Tn) : (N/Tn + 1);
    localparam tile_M_num = (M%Tm == 0) ? (M/Tm) : (M/Tm + 1);
    localparam tile_R_margin = Tr - ((Tr + S - K)/S) * S;
    localparam tile_C_margin = Tc - ((Tc + S - K)/S) * S;
    localparam tile_R_num = (tile_R_margin == 0) ? ((R - tile_R_margin) / (Tr - tile_R_margin)) : 
                            (1 + (R - tile_R_margin)/(Tr - tile_R_margin));
    localparam tile_C_num = (tile_C_margin == 0) ? ((C - tile_C_margin) / (Tc - tile_C_margin)) :
                            (1 + (C - tile_C_margin)/(Tc - tile_C_margin));
    localparam tile_num = tile_N_num * tile_M_num * tile_R_num * tile_C_num;

    reg                                conv_start;
    reg                                conv_done;

    wire                               conv_tile_start;
    wire                               conv_tile_done;

    wire                     [AW-1: 0] in_fm_rd_tile_addr;
    wire                     [AW-1: 0] weight_rd_tile_addr;
    wire                     [AW-1: 0] out_fm_rd_tile_addr;

    reg                      [AW-1: 0] in_fm_rd_addr;
    reg                      [AW-1: 0] weight_rd_addr;
    reg                      [AW-1: 0] out_fm_rd_addr;

    reg                      [DW-1: 0] in_fm_rd_data;
    reg                      [DW-1: 0] weight_rd_data;
    reg                      [DW-1: 0] out_fm_rd_data;

    wire                     [AW-1: 0] out_fm_wr_addr;
    wire                     [DW-1: 0] out_fm_wr_data;
    wire                               out_fm_wr_ena;

    wire                     [AW-1: 0] out_fm_wr_tile_addr;
    wire                               out_fm_wr_tile_ena;

    wire                               conv_on_going;
    reg                                conv_on_going_tmp;

    reg                                clk;
    reg                                rst;

    reg                      [AW-1: 0] tile_base_n;
    reg                      [AW-1: 0] tile_base_m;
    reg                      [AW-1: 0] tile_base_row;
    reg                      [AW-1: 0] tile_base_col;

    wire                     [AW-1: 0] next_tile_base_n;
    wire                     [AW-1: 0] next_tile_base_m;
    wire                     [AW-1: 0] next_tile_base_row;
    wire                     [AW-1: 0] next_tile_base_col;

    reg                      [AW-1: 0] data_n;
    reg                      [AW-1: 0] data_m;
    reg                      [AW-1: 0] data_row;
    reg                      [AW-1: 0] data_col;

    wire                     [AW-1: 0] next_data_n;
    wire                     [AW-1: 0] next_data_m;
    wire                     [AW-1: 0] next_data_row;
    wire                     [AW-1: 0] next_data_col;

    reg                      [DW-1: 0] in_fm_mem [0: in_fm_size - 1];
    reg                      [DW-1: 0] weight_mem [0: weight_size - 1];
    reg                      [DW-1: 0] out_fm_mem [0: out_fm_size - 1];

    // clock and reset signal
    always #(CLK_PERIOD/2) clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;

        repeat (10) begin
            @(posedge clk);
        end
        rst = 0;
    end

    // Generate conv start signal
    initial begin
        conv_start = 1'b0;
        repeat (20) begin
            @(posedge clk);
        end
        conv_start = 1'b1;
        @(posedge clk)
        conv_start = 1'b0;
    end

    // Initialize the outside memory and read the result after computing 
    initial begin
        $readmemh("in_fm.txt", in_fm_mem, 0, in_fm_size - 1);
        $readmemh("weight.txt", weight_mem, 0, weight_size - 1);
        $readmemh("out_fm_init.txt", out_fm_mem, 0, out_fm_size - 1);

        repeat (240000) begin
            @(posedge clk);
        end
        $writememh("out_fm_result.txt", out_fm_mem, 0, out_fm_size - 1);
        $stop(2);
    end

    // outside memory simulation model
    reg                      [DW-1: 0] in_fm_rd_data_tmp;
    reg                      [DW-1: 0] weight_rd_data_tmp;
    reg                      [DW-1: 0] out_fm_rd_data_tmp;

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

    // Tile module
    conv_tile #(
        .AW (AW),
        .DW (DW),
        .Tn (Tn),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),
        .S (S),
        .K (K),
        .X (X),
        .Y (Y)
    ) conv_tile (
        .conv_tile_start (conv_tile_start),
        .conv_tile_done (conv_tile_done),
        
        .in_fm_rd_addr (in_fm_rd_tile_addr),
        .weight_rd_addr (weight_rd_addr),
        .out_fm_rd_addr (out_fm_rd_addr),

        .in_fm_rd_data (in_fm_rd_data),
        .weight_rd_data (weight_rd_data),
        .out_fm_rd_data (out_fm_rd_data),

        .out_fm_wr_addr (out_fm_wr_addr),
        .out_fm_wr_data (out_fm_wr_data),
        .out_fm_wr_ena (out_fm_wr_ena),

        .clk (clk),
        .rst (rst)
    );

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            conv_on_going_tmp <= 1'b0;
        end
        else if(start == 1'b1) begin
            conv_on_going_tmp <= 1'b1;
        end
        else if(done == 1'b1) begin
            conv_on_going_tmp <= 1'b0;
        end
    end
    assign conv_on_going = (conv_on_going_tmp == 1'b1) && (done == 1'b0);

    assign data_to_ram = data_from_fifo;

    counter #(
        .CW (CW),
        .MAX (DATA_SIZE)
    ) counter (
        .ena (fifo_pop),
        .cnt (ram_addr),
        .done (done),

        .clk (clk),
        .rst (rst)
    );
    
    assign ram_wena = fifo_pop;

    // New convolution tile starts when last convolution is done.
    sig_delay #(
        .D (1)
    ) sig_delay0 (
        .sig_in (conv_tile_done),
        .sig_out (new_conv_tile_start),

        .clk (clk),
        .rst (rst)
    );

    sig_delay #(
        .D (1)
    ) sig_delay1 (
        .sig_in (conv_tile_),
        .sig_out (new_conv_tile_start),

        .clk (clk),
        .rst (rst)
    );

    reg                                conv_start_reg;
    wire                               conv_start_edge;

    always@(posedge clk) begin
        conv_start_reg <= conv_start;
    end

    assign conv_start_edge = conv_start && (~conv_start_reg);
    assign conv_tile_start = (conv_start_edge == 1'b1) || 
                             ((new_conv_tile_start == 1'b1) && (conv_done_reg == 1'b0));

    get_next_tile #(
        .N (N),
        .M (M),
        .R (R),
        .C (C),
        .X (X),
        .Y (Y),
        .Tn (Tn),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),
        .K (K),
        .S (S)
    ) get_next_tile (
        .conv_tile_start (),

        .tile_base_n (),
        .tile_base_m (),
        .tile_base_row (),
        .tile_base_col (),

        .next_tile_base_n (),
        .next_tile_base_m (),
        .next_tile_base_row (),
        .next_tile_base_col (),

        .clk (clk),
        .rst (rst)
    );

    load_weight_tile #(
        .N (),
        .M ()
    ) get_next_weight_tile (
        .tile_base_n (),
        .tile_base_m (),
        .tile_base_row (),
        .tile_base_col ()
    );

    load_out_fm_tile #(
        .N (),
        .M (),
        .R (),
        .C (),
        .X ()
    ) get_next_out_fm_tile (
        .tile_base_n (),
        .tile_base_m (),
        .tile_base_row (),
        .tile_base_col (),
    );

    store_out_fm_tile #(
        .DW (DW),
        .AW (AW),
        .N (N),
        .M (M),
        .R (R),
        .C (C),
        .K (K),
        .S (S),
        .X (X),
        .Y (Y)
    ) store_out_fm_tile (
        .tile_base_n (),
        .tile_base_m (),
        .tile_base_row (),
        .tile_base_col (),
    );

endmodule
