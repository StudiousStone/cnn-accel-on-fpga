/*
* Created           : cheng liu
* Date              : 2016-05-16
* Email             : st.liucheng@gmail.com
*
* Description:
* 
* One bank of weight, and it contains Tm/X kernel weight coefficients.
* In order to simplify the write control, the design assumes the input data comes sequentially.
* 
* Instance example
weight #(
    .AW (), 
    .DW (),
    .Tm (),
    .Tn (),
    .K (),
    .X (),
    .Y () 
) weight_inst (
    .rd_data00 (),
    .rd_addr00 (),
    .rd_data01 (),
    .rd_addr01 (),
    .rd_data02 (),
    .rd_addr02 (),
    .rd_data03 (),
    .rd_addr03 (),

    .rd_data10 (),
    .rd_addr10 (),
    .rd_data11 (),
    .rd_addr11 (),
    .rd_data12 (),
    .rd_addr12 (),
    .rd_data13 (),
    .rd_addr13 (),

    .rd_data20 (),
    .rd_addr20 (),
    .rd_data21 (),
    .rd_addr21 (),
    .rd_data22 (),
    .rd_addr22 (),
    .rd_data23 (),
    .rd_addr23 (),

    .rd_data30 (),
    .rd_addr30 (),
    .rd_data31 (),
    .rd_addr31 (),
    .rd_data32 (),
    .rd_addr32 (),
    .rd_data33 (),
    .rd_addr33 (),

    .weight_fifo_data (),
    .weight_fifo_pop (),
    .weight_fifo_empty (),

    .weight_load_start (),
    .weight_load_done (),

    .clk (),
    .rst ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module weight #(
    parameter AW = 10,  // input_fm bank address width
    parameter DW = 32,  // data width
    parameter Tn = 16,  // output_fm tile size of output channel
    parameter Tm = 16,  // input_fm tile size of input channel
    parameter K = 3,    // kernel parameter
    parameter X = 4,    // # of input_fm bank
    parameter Y = 4     // # of output_fm bank
)(
    // weight of output channel 0
    output  [DW-1: 0]                  rd_data00,
    input   [AW-1: 0]                  rd_addr00,
    output  [DW-1: 0]                  rd_data01,
    input   [AW-1: 0]                  rd_addr01,
    output  [DW-1: 0]                  rd_data02,
    input   [AW-1: 0]                  rd_addr02,
    output  [DW-1: 0]                  rd_data03,
    input   [AW-1: 0]                  rd_addr03,

    // weight of output channel 1
    output  [DW-1: 0]                  rd_data10,
    input   [AW-1: 0]                  rd_addr10,
    output  [DW-1: 0]                  rd_data11,
    input   [AW-1: 0]                  rd_addr11,
    output  [DW-1: 0]                  rd_data12,
    input   [AW-1: 0]                  rd_addr12,
    output  [DW-1: 0]                  rd_data13,
    input   [AW-1: 0]                  rd_addr13,

    // weight of output channel 2
    output  [DW-1: 0]                  rd_data20,
    input   [AW-1: 0]                  rd_addr20,
    output  [DW-1: 0]                  rd_data21,
    input   [AW-1: 0]                  rd_addr21,
    output  [DW-1: 0]                  rd_data22,
    input   [AW-1: 0]                  rd_addr22,
    output  [DW-1: 0]                  rd_data23,
    input   [AW-1: 0]                  rd_addr23,

    // weight of output channel 3
    output  [DW-1: 0]                  rd_data30,
    input   [AW-1: 0]                  rd_addr30,
    output  [DW-1: 0]                  rd_data31,
    input   [AW-1: 0]                  rd_addr31,
    output  [DW-1: 0]                  rd_data32,
    input   [AW-1: 0]                  rd_addr32,
    output  [DW-1: 0]                  rd_data33,
    input   [AW-1: 0]                  rd_addr33,
     
    // write port
    input   [DW-1: 0]                  weight_fifo_data,
    output                             weight_fifo_pop,
    input                              weight_fifo_empty,

    input                              weight_load_start,
    output                             weight_load_done,
    input                              conv_tile_reset,

    input                              clk,
    input                              rst
);
    localparam WEIGHT_SIZE = Tm * Tn * K * K;
    localparam KERNEL_SIZE = K * K;
    localparam BLOCK_SIZE = K * K * Tm;

    // The two index registers are used to decide which bank is going to be activated.
    reg     [1: 0]                    input_channel_index; 
    reg     [1: 0]                    output_channel_index;

    wire                              wr_ena00;
    wire                              wr_ena01;
    wire                              wr_ena02;
    wire                              wr_ena03;

    wire                              wr_ena10;
    wire                              wr_ena11;
    wire                              wr_ena12;
    wire                              wr_ena13;

    wire                              wr_ena20;
    wire                              wr_ena21;
    wire                              wr_ena22;
    wire                              wr_ena23;

    wire                              wr_ena30;
    wire                              wr_ena31;
    wire                              wr_ena32;
    wire                              wr_ena33;

    reg                               weight_load_on_going;
    wire                              kernel_done;
    wire                              block_done;
    reg                               wr_ena;

    // Generate fifo pop signal and get data from the fifo.
    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            weight_load_on_going <= 1'b0;
        end
        else if(weight_load_start == 1'b1) begin
            weight_load_on_going <= 1'b1;
        end
        else if(weight_load_done == 1'b1) begin
            weight_load_on_going <= 1'b0;
        end
    end

    assign weight_fifo_pop = (weight_load_on_going == 1'b1) && 
                             (weight_fifo_empty == 1'b0) && 
                             (weight_load_done == 1'b0);

    counter #(
        .CW (DW),
        .MAX (WEIGHT_SIZE)
    ) weight_counter (
        .ena     (weight_fifo_pop),
        .cnt     (),
        .done    (weight_load_done),
        .syn_rst (conv_tile_reset),

        .clk     (clk),
        .rst     (rst)
    );

    counter #(
        .CW (AW),
        .MAX (KERNEL_SIZE)
    ) kernel_counter (
        .ena     (weight_fifo_pop),
        .cnt     (),
        .done    (kernel_done),
        .syn_rst (conv_tile_reset),

        .clk     (clk),
        .rst     (rst)
    );

    counter #(
        .CW (AW),
        .MAX (BLOCK_SIZE)
    ) block_counter (
        .ena     (weight_fifo_pop),
        .cnt     (),
        .done    (block_done),
        .syn_rst (conv_tile_reset),

        .clk     (clk),
        .rst     (rst)
    );

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            input_channel_index <= 0;
        end
        else if(kernel_done == 1'b1 && input_channel_index < X - 1) begin
            input_channel_index <= input_channel_index + 1;
        end
        else if(kernel_done == 1'b1 && input_channel_index == X - 1) begin
            input_channel_index <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            output_channel_index <= 0;
        end
        else if(block_done == 1'b1 && output_channel_index < Y - 1) begin
            output_channel_index <= output_channel_index + 1;
        end
        else if(block_done == 1'b1 && output_channel_index == Y - 1) begin
            output_channel_index <= 0;
        end
    end

    always@(posedge clk) begin
        wr_ena <= weight_fifo_pop;
    end

    assign wr_ena00 = (wr_ena == 1'b1) && (output_channel_index == 0) && (input_channel_index == 0);
    assign wr_ena01 = (wr_ena == 1'b1) && (output_channel_index == 0) && (input_channel_index == 1);
    assign wr_ena02 = (wr_ena == 1'b1) && (output_channel_index == 0) && (input_channel_index == 2);
    assign wr_ena03 = (wr_ena == 1'b1) && (output_channel_index == 0) && (input_channel_index == 3);

    assign wr_ena10 = (wr_ena == 1'b1) && (output_channel_index == 1) && (input_channel_index == 0);
    assign wr_ena11 = (wr_ena == 1'b1) && (output_channel_index == 1) && (input_channel_index == 1);
    assign wr_ena12 = (wr_ena == 1'b1) && (output_channel_index == 1) && (input_channel_index == 2);
    assign wr_ena13 = (wr_ena == 1'b1) && (output_channel_index == 1) && (input_channel_index == 3);

    assign wr_ena20 = (wr_ena == 1'b1) && (output_channel_index == 2) && (input_channel_index == 0);
    assign wr_ena21 = (wr_ena == 1'b1) && (output_channel_index == 2) && (input_channel_index == 1);
    assign wr_ena22 = (wr_ena == 1'b1) && (output_channel_index == 2) && (input_channel_index == 2);
    assign wr_ena23 = (wr_ena == 1'b1) && (output_channel_index == 2) && (input_channel_index == 3);

    assign wr_ena30 = (wr_ena == 1'b1) && (output_channel_index == 3) && (input_channel_index == 0);
    assign wr_ena31 = (wr_ena == 1'b1) && (output_channel_index == 3) && (input_channel_index == 1);
    assign wr_ena32 = (wr_ena == 1'b1) && (output_channel_index == 3) && (input_channel_index == 2);
    assign wr_ena33 = (wr_ena == 1'b1) && (output_channel_index == 3) && (input_channel_index == 3);

    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank00 (
        .rd_data         (rd_data00),
        .rd_addr         (rd_addr00),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena00),
        .conv_tile_reset (conv_tile_reset),

        .clk             (clk),
        .rst             (rst)
    );


    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank01 (
        .rd_data         (rd_data01),
        .rd_addr         (rd_addr01),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena01),
        .conv_tile_reset (conv_tile_reset),
        
        .clk             (clk),
        .rst             (rst)
    );


    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank02 (
        .rd_data         (rd_data02),
        .rd_addr         (rd_addr02),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena02),
        .conv_tile_reset (conv_tile_reset),
        
        .clk             (clk),
        .rst             (rst)
    );

    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank03 (
        .rd_data         (rd_data03),
        .rd_addr         (rd_addr03),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena03),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );

    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank10 (
        .rd_data         (rd_data10),
        .rd_addr         (rd_addr10),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena10),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );


    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank11 (
        .rd_data         (rd_data11),
        .rd_addr         (rd_addr11),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena11),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );


    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank12 (
        .rd_data         (rd_data12),
        .rd_addr         (rd_addr12),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena12),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );

    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank13 (
        .rd_data         (rd_data13),
        .rd_addr         (rd_addr13),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena13),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );

    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank20 (
        .rd_data         (rd_data20),
        .rd_addr         (rd_addr20),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena20),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );


    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank21 (
        .rd_data         (rd_data21),
        .rd_addr         (rd_addr21),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena21),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );


    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank22 (
        .rd_data         (rd_data22),
        .rd_addr         (rd_addr22),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena22),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );

    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank23 (
        .rd_data         (rd_data23),
        .rd_addr         (rd_addr23),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena23),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );

    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank30 (
        .rd_data         (rd_data30),
        .rd_addr         (rd_addr30),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena30),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );


    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank31 (
        .rd_data         (rd_data31),
        .rd_addr         (rd_addr31),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena31),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );

    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank32 (
        .rd_data         (rd_data32),
        .rd_addr         (rd_addr32),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena32),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );

    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank33 (
        .rd_data         (rd_data33),
        .rd_addr         (rd_addr33),
        .wr_data         (weight_fifo_data),
        .wr_ena          (wr_ena33),
        .conv_tile_reset (conv_tile_reset),        

        .clk             (clk),
        .rst             (rst)
    );

endmodule
