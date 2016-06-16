/*
* Created           : cheng liu
* Date              : 2016-05-28
* Email             : st.liucheng@gmail.com
*
* Description:
* This module simulates both the memory model and convolution design connected through 
* avalon interface.
*
* Instance example:
*
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on


module conv_top_tb; 

    parameter AW = 16;           // address data width of convolution
    parameter CW = 16;           // data width of counters in convolution
    parameter DW = 32;           // data width of convolution
    parameter XAW = 32;          // avalon address width
    parameter XDW = 128;         // avalon data width

    parameter N = 16;            // # of output channels
    parameter M = 16;            // # of input channels
    parameter R = 32;            // # of rows in a feature map (height of feature map)
    parameter C = 16;            // # of columns in a feature map (width of feature map)
    parameter S = 1;             // stride
    parameter K = 3;             // kernel size

    parameter Tn = 8;            // # of tiled output channels
    parameter Tm = 8;            // # of tiled input channels
    parameter Tr = 16;           // # of tiled rows
    parameter Tc = 10;           // # of tiled columns

    parameter ROW_OFFSET  = 0;    // offset that makes sure a row of input/output are aligned with 128 bits
    parameter TILE_ROW_OFFSET = 2;// offset that makes sure a row of a tile are aligned with 128 bits

    parameter X = 4;             // physical input lanes of input channel X <= Tm
    parameter Y = 4;             // physical output lanes of output channel Y <= Tn

    parameter FP_MUL_DELAY = 11;
    parameter FP_ADD_DELAY = 14;
    parameter FP_ACCUM_DELAY = 9;
    parameter R_PORT = 3;
    parameter W_PORT = 1;

    localparam CLK_PERIOD = 10;
    localparam TILE_N_NUM = ceil(N, Tn);
    localparam TILE_M_NUM = ceil(M, Tm);
    localparam TILE_ROW_KERNEL_NUM = (Tr + S - K)/S;
    localparam TILE_COL_KERNEL_NUM = (Tc + S - K)/S;
    localparam ROW_KERNEL_NUM = (R + S - K)/S;
    localparam COL_KERNEL_NUM = (C + S - K)/S;
    localparam TILE_ROW_NUM = ceil(ROW_KERNEL_NUM, TILE_ROW_KERNEL_NUM);
    localparam TILE_COL_NUM = ceil(COL_KERNEL_NUM, TILE_COL_KERNEL_NUM);
    localparam TILE_NUM = TILE_N_NUM * TILE_M_NUM * TILE_ROW_NUM * TILE_COL_NUM;

    // note that y != 0 x > 0, y > 0
    function integer ceil(input integer x, input integer y);
        integer val;
        begin
            val = y;
            ceil = 1;
            while(val < x) begin
                ceil = ceil + 1;
                val = ceil * y;
            end
        end
    endfunction


    // Avalon interface
    wire  [R_PORT-1: 0]                rmst_fixed_location;        // fixed_location
    wire  [R_PORT*XAW-1: 0]            rmst_read_base;             // read_base
    wire  [R_PORT*XAW-1: 0]            rmst_read_length;           // read_length
    wire  [R_PORT-1: 0]                rmst_go;                    // go
    wire  [R_PORT-1: 0]                rmst_done;                  // done
    wire  [R_PORT-1: 0]                rmst_user_read_buffer;      // read_buffer
    wire  [R_PORT*XDW-1: 0]            rmst_user_buffer_data;      // buffer_output_data
    wire  [R_PORT-1: 0]                rmst_user_data_available;   // data_available

    wire  [W_PORT-1: 0]                wmst_fixed_location;        // fixed_location
    wire  [W_PORT*XAW-1: 0]            wmst_write_base;            // write_base
    wire  [W_PORT*XAW-1: 0]            wmst_write_length;          // write_length
    wire  [W_PORT-1: 0]                wmst_go;                    // go
    wire  [W_PORT-1: 0]                wmst_done;                  // done
    wire  [W_PORT-1: 0]                wmst_user_write_buffer;     // write_buffer
    wire  [W_PORT*XDW-1: 0]            wmst_user_write_data;       // buffer_input_data
    wire  [W_PORT-1: 0]                wmst_user_buffer_full;   

    wire                               in_fm_rmst_fixed_location;
    wire  [XAW-1: 0]                   in_fm_rmst_read_base; 
    wire  [XAW-1: 0]                   in_fm_rmst_read_length;
    wire                               in_fm_rmst_go;
    wire                               in_fm_rmst_done;
    wire                               in_fm_rmst_user_read_buffer;
    wire  [XDW-1: 0]                   in_fm_rmst_user_buffer_data;
    wire                               in_fm_rmst_user_data_available;

    wire                               weight_rmst_fixed_location;
    wire  [XAW-1: 0]                   weight_rmst_read_base;
    wire  [XAW-1: 0]                   weight_rmst_read_length;
    wire                               weight_rmst_go;
    wire                               weight_rmst_done;
    wire                               weight_rmst_user_read_buffer;
    wire  [XDW-1: 0]                   weight_rmst_user_buffer_data;
    wire                               weight_rmst_user_data_available;

    wire                               out_fm_rmst_fixed_location;
    wire  [XAW-1: 0]                   out_fm_rmst_read_base;
    wire  [XAW-1: 0]                   out_fm_rmst_read_length;
    wire                               out_fm_rmst_go;
    wire                               out_fm_rmst_done;
    wire                               out_fm_rmst_user_read_buffer;
    wire  [XDW-1: 0]                   out_fm_rmst_user_buffer_data;
    wire                               out_fm_rmst_user_data_available;

    wire                               out_fm_wmst_fixed_location;
    wire  [XAW-1: 0]                   out_fm_wmst_write_base;
    wire  [XAW-1: 0]                   out_fm_wmst_write_length;
    wire                               out_fm_wmst_go; 
    wire                               out_fm_wmst_done;
    wire                               out_fm_wmst_user_write_buffer;
    wire  [XDW-1: 0]                   out_fm_wmst_user_write_data;
    wire                               out_fm_wmst_user_buffer_full;   

    // system signals
    reg                                conv_start;
    wire                               conv_done;

    reg                                clk;
    reg                                rst;

    // internal signals
    wire  [CW-1: 0]                    tile_base_n;
    wire  [CW-1: 0]                    tile_base_m;
    wire  [CW-1: 0]                    tile_base_row;
    wire  [CW-1: 0]                    tile_base_col;

    wire                               conv_tile_start;
    wire                               conv_tile_done;

    wire                               conv_on_going;
    reg                                conv_on_going_tmp;
    reg                                new_conv_tile_start;

    reg                                conv_start_reg;
    wire                               conv_start_edge;

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
    
    // simulation model of DDR with multiple avalon interfaces
    mem_top #(
        .R_PORT (R_PORT),
        .W_PORT (W_PORT)
    ) mem_model(
        .read_control_fixed_location  (rmst_fixed_location),
        .read_control_read_base       (rmst_read_base),
        .read_control_read_length     (rmst_read_length),
        .read_control_go              (rmst_go), 
        .read_control_done            (rmst_done), 
        .read_user_read_buffer        (rmst_user_read_buffer),
        .read_user_buffer_output_data (rmst_user_buffer_data),
        .read_user_data_available     (rmst_user_data_available),

        .write_control_fixed_location (wmst_fixed_location),
        .write_control_write_base     (wmst_write_base),
        .write_control_write_length   (wmst_write_length),
        .write_control_go             (wmst_go),
        .write_control_done           (wmst_done), 
        .write_user_write_buffer      (wmst_user_write_buffer),
        .write_user_buffer_input_data (wmst_user_write_data),
        .write_user_buffer_full       (wmst_user_buffer_full), 

        .clk (clk),
        .rst (rst)
    );

    assign rmst_fixed_location[0] = in_fm_rmst_fixed_location;
    assign rmst_fixed_location[1] = weight_rmst_fixed_location;
    assign rmst_fixed_location[2] = out_fm_rmst_fixed_location;

    assign rmst_read_base[XAW-1: 0] = in_fm_rmst_read_base;
    assign rmst_read_base[2*XAW-1: XAW] = weight_rmst_read_base; 
    assign rmst_read_base[3*XAW-1: 2*XAW] = out_fm_rmst_read_base; 

    assign rmst_read_length[XAW-1: 0] = in_fm_rmst_read_length;
    assign rmst_read_length[2*XAW-1: XAW] = weight_rmst_read_length;
    assign rmst_read_length[3*XAW-1: 2*XAW] = out_fm_rmst_read_length;

    assign rmst_go[0] = in_fm_rmst_go;
    assign rmst_go[1] = weight_rmst_go;   
    assign rmst_go[2] = out_fm_rmst_go;

    assign in_fm_rmst_done = rmst_done[0];
    assign weight_rmst_done = rmst_done[1];
    assign out_fm_rmst_done = rmst_done[2];

    assign rmst_user_read_buffer[0] = in_fm_rmst_user_read_buffer;
    assign rmst_user_read_buffer[1] = weight_rmst_user_read_buffer;
    assign rmst_user_read_buffer[2] = out_fm_rmst_user_read_buffer;

    assign in_fm_rmst_user_buffer_data = rmst_user_buffer_data[XDW-1: 0];
    assign weight_rmst_user_buffer_data = rmst_user_buffer_data[2*XDW-1: XDW];
    assign out_fm_rmst_user_buffer_data = rmst_user_buffer_data[3*XDW-1: 2*XDW];

    assign in_fm_rmst_user_data_available = rmst_user_data_available[0];
    assign weight_rmst_user_data_available = rmst_user_data_available[1];
    assign out_fm_rmst_user_data_available = rmst_user_data_available[2];

    assign wmst_fixed_location = out_fm_wmst_fixed_location;
    assign wmst_write_base = out_fm_wmst_write_base;
    assign wmst_write_length = out_fm_wmst_write_length;
    assign wmst_go = out_fm_wmst_go;
    assign out_fm_wmst_done = wmst_done;
    assign wmst_user_write_buffer = out_fm_wmst_user_write_buffer;
    assign wmst_user_write_data = out_fm_wmst_user_write_data;
    assign out_fm_wmst_user_buffer_full = wmst_user_buffer_full;

    // Tile module
    conv_tile #(
        .AW (AW),
        .CW (CW),
        .DW (DW),

        .N (N),
        .M (M),
        .R (R),
        .C (C),
        .S (S),
        .K (K),

        .Tn (Tn),
        .Tm (Tm),
        .Tr (Tr),
        .Tc (Tc),

        .X (X),
        .Y (Y),

        .TILE_ROW_OFFSET (TILE_ROW_OFFSET),

        .FP_MUL_DELAY (FP_MUL_DELAY),
        .FP_ADD_DELAY (FP_ADD_DELAY),
        .FP_ACCUM_DELAY (FP_ACCUM_DELAY),
        .XAW (XAW),
        .XDW (XDW)
    ) conv_tile (
        .conv_tile_start (conv_tile_start),
        .conv_tile_done (conv_tile_done),

        // load in_fm tile through avalon read master
        .in_fm_rmst_fixed_location   (in_fm_rmst_fixed_location),
        .in_fm_rmst_read_base        (in_fm_rmst_read_base),
        .in_fm_rmst_read_length      (in_fm_rmst_read_length),
        .in_fm_rmst_go               (in_fm_rmst_go),
        .in_fm_rmst_done             (in_fm_rmst_done),

        .in_fm_rmst_user_read_buffer (in_fm_rmst_user_read_buffer),
        .in_fm_rmst_user_buffer_data (in_fm_rmst_user_buffer_data),
        .in_fm_rmst_user_data_available (in_fm_rmst_user_data_available),

        // load weight tile through avalon read master
        .weight_rmst_fixed_location   (weight_rmst_fixed_location),
        .weight_rmst_read_base        (weight_rmst_read_base),
        .weight_rmst_read_length      (weight_rmst_read_length),
        .weight_rmst_go               (weight_rmst_go),
        .weight_rmst_done             (weight_rmst_done),

        .weight_rmst_user_read_buffer (weight_rmst_user_read_buffer),
        .weight_rmst_user_buffer_data (weight_rmst_user_buffer_data),
        .weight_rmst_user_data_available (weight_rmst_user_data_available),

        // load out_fm tile through avalon read master
        .out_fm_rmst_fixed_location   (out_fm_rmst_fixed_location),
        .out_fm_rmst_read_base        (out_fm_rmst_read_base),
        .out_fm_rmst_read_length      (out_fm_rmst_read_length),
        .out_fm_rmst_go               (out_fm_rmst_go),
        .out_fm_rmst_done             (out_fm_rmst_done),

        .out_fm_rmst_user_read_buffer (out_fm_rmst_user_read_buffer),
        .out_fm_rmst_user_buffer_data (out_fm_rmst_user_buffer_data),
        .out_fm_rmst_user_data_available (out_fm_rmst_user_data_available),

        // write out_fm tile back through avalon write master
        .out_fm_wmst_fixed_location   (out_fm_wmst_fixed_location),
        .out_fm_wmst_write_base       (out_fm_wmst_write_base),
        .out_fm_wmst_write_length     (out_fm_wmst_write_length),
        .out_fm_wmst_go               (out_fm_wmst_go),
        .out_fm_wmst_done             (out_fm_wmst_done),

        .out_fm_wmst_user_write_buffer(out_fm_wmst_user_write_buffer),
        .out_fm_wmst_user_write_data  (out_fm_wmst_user_write_data),
        .out_fm_wmst_user_buffer_full (out_fm_wmst_user_buffer_full),

        .tile_base_n                  (tile_base_n),
        .tile_base_m                  (tile_base_m),
        .tile_base_row                (tile_base_row),
        .tile_base_col                (tile_base_col),

        .clk                          (clk),
        .rst                          (rst)
    );

    gen_tile_cord #(
        .CW (CW),

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

    ) gen_tile_cord (
        .conv_tile_done    (conv_tile_done),

        .tile_base_n       (tile_base_n),
        .tile_base_m       (tile_base_m),
        .tile_base_row     (tile_base_row),
        .tile_base_col     (tile_base_col),

        .clk               (clk),
        .rst               (rst)
    );

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            conv_on_going_tmp <= 1'b0;
        end
        else if(conv_start == 1'b1) begin
            conv_on_going_tmp <= 1'b1;
        end
        else if(conv_done == 1'b1) begin
            conv_on_going_tmp <= 1'b0;
        end
    end

    assign conv_on_going = (conv_on_going_tmp == 1'b1) && (conv_done == 1'b0);

    counter #(
        .CW (CW),
        .MAX (TILE_NUM)
    ) counter (
        .ena        (conv_tile_done),
        .cnt        (),
        .done       (conv_done),
        .clean      (1'b0),

        .clk        (clk),
        .rst        (rst)
    );

    always@(posedge clk) begin
        conv_start_reg <= conv_start;
        new_conv_tile_start <= conv_tile_done;
    end

    assign conv_start_edge = conv_start && (~conv_start_reg);
    assign conv_tile_start = (conv_start_edge == 1'b1) || ((new_conv_tile_start == 1'b1) && (conv_done == 1'b0));

endmodule
