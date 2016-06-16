/*
* Created           : cheng liu
* Date              : 2016-05-18
* Email             : st.liucheng@gmail.com
*
* Description:
* 
* convolution kernel logic processing a single tile of data
* 
*  Instance example
*
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on


module conv_tile #(
    parameter AW = 32,
    parameter CW = 16,
    parameter DW = 32,
    parameter XAW = 32,
    parameter XDW = 128

    parameter N = 32,
    parameter M = 32,
    parameter R = 64,
    parameter C = 32,
    parameter S = 1,
    parameter K = 3,

    parameter Tn = 16,
    parameter Tm = 16,
    parameter Tr = 64,
    parameter Tc = 16,

    parameter TILE_ROW_OFFSET = 2,

    parameter X = 4,
    parameter Y = 4,

    parameter FP_MUL_DELAY = 11,
    parameter FP_ADD_DELAY = 14,
    parameter FP_ACCUM_DELAY = 9
)(
    input                              conv_tile_start,
    output                             conv_tile_done,

    input   [CW-1: 0]                  tile_base_n,
    input   [CW-1: 0]                  tile_base_m,
    input   [CW-1: 0]                  tile_base_col,
    input   [CW-1: 0]                  tile_base_row,

    output                             in_fm_rmst_fixed_location,
    output  [XAW-1:0]                  in_fm_rmst_read_base, 
    output  [XAW-1:0]                  in_fm_rmst_read_length,
    output                             in_fm_rmst_go,
    input                              in_fm_rmst_done, 

    output                             in_fm_rmst_user_read_buffer,
    input   [XDW-1:0]                  in_fm_rmst_user_buffer_data, 
    input                              in_fm_rmst_user_data_available,

    output                             weight_rmst_fixed_location,
    output  [XAW-1:0]                  weight_rmst_read_base,
    output  [XAW-1:0]                  weight_rmst_read_length,
    output                             weight_rmst_go, 
    input                              weight_rmst_done,

    output                             weight_rmst_user_read_buffer, 
    input   [XDW-1:0]                  weight_rmst_user_buffer_data,
    input                              weight_rmst_user_data_available,

    output                             out_fm_rmst_fixed_location,
    output  [XAW-1:0]                  out_fm_rmst_read_base,
    output  [XAW-1:0]                  out_fm_rmst_read_length,
    output                             out_fm_rmst_go, 
    input                              out_fm_rmst_done, 

    output                             out_fm_rmst_user_read_buffer, 
    input   [XDW-1:0]                  out_fm_rmst_user_buffer_data,
    input                              out_fm_rmst_user_data_available,

    output                             out_fm_wmst_fixed_location,
    output  [XAW-1:0]                  out_fm_wmst_write_base,
    output  [XAW-1:0]                  out_fm_wmst_write_length,
    output                             out_fm_wmst_go,
    input                              out_fm_wmst_done,

    output                             out_fm_wmst_user_write_buffer,
    output  [XDW-1:0]                  out_fm_wmst_user_write_data,
    input                              out_fm_wmst_user_buffer_full,   

    input                              clk,
    input                              rst
);

    wire                               in_fm_load_start;
    wire                               weight_load_start;
    wire                               out_fm_load_start;
    wire                               conv_tile_load_done;
    
    wire                               conv_tile_computing_start;
    wire                               conv_tile_computing_done;

    wire                               conv_store_to_fifo_start;
    wire                               conv_store_to_fifo_done;


    wire  [DW-1: 0]                    in_fm_fifo_data_from_mem;
    wire  [DW-1: 0]                    weight_fifo_data_from_mem;
    wire  [DW-1: 0]                    out_fm_ld_fifo_data_from_mem;
    wire  [DW-1: 0]                    out_fm_st_fifo_data_to_mem;
    
    wire                               in_fm_fifo_push;
    wire                               in_fm_fifo_almost_full;

    wire                               weight_fifo_push;
    wire                               weight_fifo_almost_full;

    wire                               out_fm_ld_fifo_push;
    wire                               out_fm_ld_fifo_almost_full;

    wire                               out_fm_st_fifo_pop;
    wire                               out_fm_st_fifo_empty;

    wire                               conv_tile_store_start;
    wire                               conv_tile_store_done;
    wire                               wmst_tile_store_done;    
    
    reg                                conv_tile_reset;
    
    always@(posedge clk) begin
        conv_tile_reset <= conv_tile_done;
    end

    gen_store_done  gen_store_done(
        .internal_store_done   (conv_store_to_fifo_done),
        .wmst_store_done       (wmst_tile_store_done),
        .conv_store_done       (conv_tile_store_done),

        .clk                   (clk),
        .rst                   (rst)
    );

    // TO BE FIXED
    // As the read port and write port of out_fm are shared by both convolution 
    // kernel computing logic and output fifo, switching from computing status to 
    // storing status may cause wrong operation. This will be further fixed by returning 
    // a more safe computing_done signal.

    sig_delay #(
        .D (120)
    ) sig_delay (
        .sig_in   (conv_tile_computing_done),
        .sig_out  (conv_store_to_fifo_start),
        
        .clk      (clk),
        .rst      (rst)
    );

    // The three input data start loading at the same time.
    // Connect the in_fm ram port with the fifo port
    rmst_to_in_fm_fifo_tile #(
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
        .Tc (Tc),

        .TILE_ROW_OFFSET (TILE_ROW_OFFSET)

    ) rmst_to_in_fm_fifo_tile (
        .load_start               (in_fm_load_start),
        .load_done                (),

        .load_fifo_push           (in_fm_fifo_push),
        .load_fifo_almost_full    (in_fm_fifo_almost_full),
        .rmst_load_data           (in_fm_fifo_data_from_mem),

        .rmst_fixed_location      (in_fm_rmst_fixed_location),
        .rmst_read_base           (in_fm_rmst_read_base),
        .rmst_read_length         (in_fm_rmst_read_length),
        .rmst_go                  (in_fm_rmst_go),
        .rmst_done                (in_fm_rmst_done),

        .rmst_user_read_buffer    (in_fm_rmst_user_read_buffer),
        .rmst_user_buffer_data    (in_fm_rmst_user_buffer_data),
        .rmst_user_data_available (in_fm_rmst_user_data_available),

        .tile_base_m              (tile_base_m),
        .tile_base_row            (tile_base_row),
        .tile_base_col            (tile_base_col),

        .clk                      (clk),
        .rst                      (rst)
    );

    rmst_to_weight_fifo_tile #(
        .AW (AW),
        .CW (CW),
        .DW (DW),
        .XAW (XAW),
        .XDW (XDW),

        .N (N),
        .M (M),
        .K (K),

        .Tn (Tn),
        .Tm (Tm)

    ) rmst_to_weight_fifo_tile (
        .load_start               (weight_load_start),
        .load_done                (),

        .load_fifo_push           (weight_fifo_push),
        .load_fifo_almost_full    (weight_fifo_almost_full),
        .rmst_load_data           (weight_fifo_data_from_mem),

        .rmst_fixed_location      (weight_rmst_fixed_location),
        .rmst_read_base           (weight_rmst_read_base),
        .rmst_read_length         (weight_rmst_read_length),
        .rmst_go                  (weight_rmst_go),
        .rmst_done                (weight_rmst_done),

        .rmst_user_read_buffer    (weight_rmst_user_read_buffer),
        .rmst_user_buffer_data    (weight_rmst_user_buffer_data),
        .rmst_user_data_available (weight_rmst_user_data_available),

        .tile_base_n              (tile_base_n),
        .tile_base_m              (tile_base_m),

        .clk                      (clk),
        .rst                      (rst)
    );
    
    rmst_to_out_fm_fifo_tile #(
        .AW (AW),
        .CW (CW),
        .DW (DW),

        .N (N),
        .R (R),
        .C (C),

        .Tn (Tn),
        .Tr (Tr),
        .Tc (Tc),

        .TILE_ROW_OFFSET (TILE_ROW_OFFSET)

    ) rmst_to_out_fm_fifo_tile (
        .load_start               (out_fm_load_start),
        .load_done                (),

        .load_fifo_push           (out_fm_ld_fifo_push),
        .load_fifo_almost_full    (out_fm_ld_fifo_almost_full),
        .rmst_load_data           (out_fm_ld_fifo_data_from_mem),

        .rmst_fixed_location      (out_fm_rmst_fixed_location),
        .rmst_read_base           (out_fm_rmst_read_base),
        .rmst_read_length         (out_fm_rmst_read_length),
        .rmst_go                  (out_fm_rmst_go),
        .rmst_done                (out_fm_rmst_done),

        .rmst_user_read_buffer    (out_fm_rmst_user_read_buffer),
        .rmst_user_buffer_data    (out_fm_rmst_user_buffer_data),
        .rmst_user_data_available (out_fm_rmst_user_data_available),

        .tile_base_n              (tile_base_n),
        .tile_base_row            (tile_base_row),
        .tile_base_col            (tile_base_col),

        .clk                      (clk),
        .rst                      (rst)
    );

    wmst_to_out_fm_fifo_tile #(
        .AW (AW),
        .CW (CW),
        .DW (DW),
        .N (N),
        .R (R),
        .C (C),
        .K (K),
        .S (S)

        .Tn (Tn),
        .Tr (Tr),
        .Tc (Tc),

    ) wmst_to_out_fm_fifo_tile (

        .store_start (conv_tile_store_start),
        .store_done (wmst_tile_store_done),

        .store_fifo_pop (out_fm_st_fifo_pop),
        .store_fifo_empty (out_fm_st_fifo_empty),
        .wmst_store_data (out_fm_st_fifo_data_to_mem),

        .wmst_fixed_location   (out_fm_wmst_fixed_location),
        .wmst_write_base       (out_fm_wmst_write_base),
        .wmst_write_length     (out_fm_wmst_write_length),
        .wmst_go               (out_fm_wmst_go),
        .wmst_done             (out_fm_wmst_done),

        .wmst_user_write_buffer(out_fm_wmst_user_write_buffer),
        .wmst_user_write_data  (out_fm_wmst_user_write_data),
        .wmst_user_buffer_full (out_fm_wmst_user_buffer_full),

        .tile_base_n            (tile_base_n),
        .tile_base_row          (tile_base_row),
        .tile_base_col          (tile_base_col),

        .clk                    (clk),
        .rst                    (rst)
    );

    assign in_fm_load_start = conv_tile_start;
    assign weight_load_start = conv_tile_start;
    assign out_fm_load_start = conv_tile_start;

    assign conv_tile_store_start = conv_store_to_fifo_start;
    assign conv_tile_done = conv_tile_store_done;
    
    sig_delay #(
        .D (5)
    ) sig_delay1 (
        .sig_in (conv_tile_load_done),
        .sig_out (conv_tile_computing_start),
        
        .clk (clk),
        .rst (rst)
    );

    conv_core #(
        .CW (CW),
        .AW (AW),  // input_fm bank address width
        .DW (DW),  // data width
        .N (N),
        .M (M),
        .R (R),
        .C (C),     
        .TILE_ROW_OFFSET (TILE_ROW_OFFSET),   
        .Tn (Tn),  // output_fm tile size on output channel dimension
        .Tm (Tm),  // input_fm tile size on input channel dimension
        .Tr (Tr),  // input_fm tile size on feature row dimension
        .Tc (Tc),  // input_fm tile size on feature column dimension
        .K (K),    // kernel scale
        .X (X),    // # of parallel input_fm port
        .Y (Y),    // # of parallel output_fm port
        .S (S),
        .FP_MUL_DELAY (FP_MUL_DELAY), // multiplication delay
        .FP_ADD_DELAY (FP_ADD_DELAY), // addition delay
        .FP_ACCUM_DELAY (FP_ACCUM_DELAY) // accumulation delay

    ) conv_core (

        .conv_start (conv_tile_start), 
        .conv_computing_start (conv_tile_computing_start),
        .conv_store_to_fifo_done (conv_store_to_fifo_done),
        .conv_store_to_fifo_start (conv_store_to_fifo_start),
        .conv_computing_done (conv_tile_computing_done),
        .conv_tile_reset (conv_tile_reset),
        .conv_load_done (conv_tile_load_done),

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
        
        .tile_base_n            (tile_base_n),
        .tile_base_row          (tile_base_row),
        .tile_base_col          (tile_base_col),

        // system clock
        .clk (clk),
        .rst (rst)
    );
    
    
   // dump internal data
   // synopsys translate_off
    wire is_tile_0;
    integer file0;
    assign is_tile_0 = (tile_base_n == 0 && tile_base_m == 0 && tile_base_row == 0 &&  tile_base_col == 0);
    
    initial begin : dump_in_fm_tile
        file0 = $fopen("in_fm_tile_sim_0_0_0_0.txt","w");
        #3400000
        $fclose(file0);
    end
    
    always@(posedge clk) begin
        if(is_tile_0 == 1'b1 && in_fm_fifo_push == 1'b1) begin
            $fwrite(file0,"%H\n", in_fm_fifo_data_from_mem);
        end
    end
   // synopsys translate_on

endmodule

