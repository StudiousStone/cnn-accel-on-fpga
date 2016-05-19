/*
* Created           : cheng liu
* Date              : 2016-05-16
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
    .rd_data (),
    .rd_addr (),
    .wr_data (),
    .wr_ena (),

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
    output                   [DW-1: 0] rd_data00,
    input                    [AW-1: 0] rd_addr00,
    output                   [DW-1: 0] rd_data01,
    input                    [AW-1: 0] rd_addr01,
    output                   [DW-1: 0] rd_data02,
    input                    [AW-1: 0] rd_addr02,
    output                   [DW-1: 0] rd_data03,
    input                    [AW-1: 0] rd_addr03,

    // weight of output channel 1
    output                   [DW-1: 0] rd_data10,
    input                    [AW-1: 0] rd_addr10,
    output                   [DW-1: 0] rd_data11,
    input                    [AW-1: 0] rd_addr11,
    output                   [DW-1: 0] rd_data12,
    input                    [AW-1: 0] rd_addr12,
    output                   [DW-1: 0] rd_data13,
    input                    [AW-1: 0] rd_addr13,

    // weight of output channel 2
    output                   [DW-1: 0] rd_data20,
    input                    [AW-1: 0] rd_addr20,
    output                   [DW-1: 0] rd_data21,
    input                    [AW-1: 0] rd_addr21,
    output                   [DW-1: 0] rd_data22,
    input                    [AW-1: 0] rd_addr22,
    output                   [DW-1: 0] rd_data23,
    input                    [AW-1: 0] rd_addr23,

    // weight of output channel 3
    output                   [DW-1: 0] rd_data30,
    input                    [AW-1: 0] rd_addr30,
    output                   [DW-1: 0] rd_data31,
    input                    [AW-1: 0] rd_addr31,
    output                   [DW-1: 0] rd_data32,
    input                    [AW-1: 0] rd_addr32,
    output                   [DW-1: 0] rd_data33,
    input                    [AW-1: 0] rd_addr33,
     
    // write port
    input                    [DW-1: 0] weight_fifo_data,
    output                             weight_fifo_pop,
    input                              weight_fifo_empty,

    input                              weight_load_start,
    output                             weight_load_done,

    input                              clk,
    input                              rst
);
    localparam weight_size = Tm * Tn * K * K;
    localparam 2D_cube_size = K * K;
    localparam 3D_cube_size = K * K * Tm;

    // The two index registers are used to decide which bank is going to be activated.
    reg                     [AW-1: 0] 2D_cube_cnt;
    reg                     [AW-1: 0] 3D_cube_cnt;
    reg                     [AW-1: 0] data_cnt0;
    reg                     [AW-1: 0] data_cnt1;

    wire                       [1: 0] input_channel_index; 
    wire                       [1: 0] output_channel_index;

    reg                               wr_ena00;
    reg                               wr_ena01;
    reg                               wr_ena02;
    reg                               wr_ena03;

    reg                               wr_ena10;
    reg                               wr_ena11;
    reg                               wr_ena12;
    reg                               wr_ena13;

    reg                               wr_ena20;
    reg                               wr_ena21;
    reg                               wr_ena22;
    reg                               wr_ena23;

    reg                               wr_ena30;
    reg                               wr_ena31;
    reg                               wr_ena32;
    reg                               wr_ena33;

    reg                               weight_load_on_going;
    reg                     [DW-1: 0] weight_cnt;

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

    assign weight_fifo_pop = (weight_load_on_going == 1'b1) && (weight_fifo_empty == 1'b0);

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            weight_cnt <= 0;
        end
        else if(weight_fifo_pop == 1'b1) begin
            weight_cnt <= weight_cnt + 1;
        end
        else if(weight_load_done == 1'b1) begin
            weight_cnt <= 0;
        end
    end

    assign weight_load_done = (weight_cnt == weight_size - 1);

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            data_cnt0 <= 0;
        end
        else if(weight_fifo_pop == 1'b1 && data_cnt0 != 2D_cube_size - 1) begin
            data_cnt0 <= data_cnt0 + 1;
        end
        else if(data_cnt0 == 2D_cube_size - 1) begin
            data_cnt0 <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            data_cnt1 <= 0;
        end
        else if(weight_fifo_pop == 1'b1 && data_cnt1 != 3D_cube_size - 1) begin
            data_cnt1 <= data_cnt1 + 1;
        end
        else if(data_cnt1 == 3D_cube_size - 1) begin
            data_cnt1 <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            input_channel_index <= 0;
        end
        else if(data_cnt0 == 2D_cube_size - 1 && weight_load_done == 1'b0) begin
            input_channel_index <= input_channel_index + 1;
        end
        else if(weight_load_done == 1'b1) begin
            input_channel_index <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            output_channel_index <= 0;
        end
        else if(data_cnt1 == 3D_cube_size - 1 && weight_load_done == 1'b0) begin
            output_channel_index <= output_channel_index + 1;
        end
        else if(weight_load_done == 1'b1) begin
            output_channel_index <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wr_ena00 <= 1'b0;
            wr_ena01 <= 1'b0;
            wr_ena02 <= 1'b0;
            wr_ena03 <= 1'b0;

            wr_ena10 <= 1'b0;
            wr_ena11 <= 1'b0;
            wr_ena12 <= 1'b0;
            wr_ena13 <= 1'b0;

            wr_ena20 <= 1'b0;
            wr_ena21 <= 1'b0;
            wr_ena22 <= 1'b0;
            wr_ena23 <= 1'b0;

            wr_ena30 <= 1'b0;
            wr_ena31 <= 1'b0;
            wr_ena32 <= 1'b0;
            wr_ena33 <= 1'b0;
        end
        else if(wr_ena == 1'b1) begin
            wr_ena00 <= (output_channel_index == 0) && (input_channel_index == 0);
            wr_ena01 <= (output_channel_index == 0) && (input_channel_index == 1);
            wr_ena02 <= (output_channel_index == 0) && (input_channel_index == 2);
            wr_ena03 <= (output_channel_index == 0) && (input_channel_index == 3);

            wr_ena10 <= (output_channel_index == 1) && (input_channel_index == 0);
            wr_ena11 <= (output_channel_index == 1) && (input_channel_index == 1);
            wr_ena12 <= (output_channel_index == 1) && (input_channel_index == 2);
            wr_ena13 <= (output_channel_index == 1) && (input_channel_index == 3);

            wr_ena20 <= (output_channel_index == 2) && (input_channel_index == 0);
            wr_ena21 <= (output_channel_index == 2) && (input_channel_index == 1);
            wr_ena22 <= (output_channel_index == 2) && (input_channel_index == 2);
            wr_ena23 <= (output_channel_index == 2) && (input_channel_index == 3);

            wr_ena30 <= (output_channel_index == 3) && (input_channel_index == 0);
            wr_ena31 <= (output_channel_index == 3) && (input_channel_index == 1);
            wr_ena32 <= (output_channel_index == 3) && (input_channel_index == 2);
            wr_ena33 <= (output_channel_index == 3) && (input_channel_index == 3);
        end
        else begin
            wr_ena00 <= 1'b0;
            wr_ena01 <= 1'b0;
            wr_ena02 <= 1'b0;
            wr_ena03 <= 1'b0;

            wr_ena10 <= 1'b0;
            wr_ena11 <= 1'b0;
            wr_ena12 <= 1'b0;
            wr_ena13 <= 1'b0;

            wr_ena20 <= 1'b0;
            wr_ena21 <= 1'b0;
            wr_ena22 <= 1'b0;
            wr_ena23 <= 1'b0;

            wr_ena30 <= 1'b0;
            wr_ena31 <= 1'b0;
            wr_ena32 <= 1'b0;
            wr_ena33 <= 1'b0;

        end
    end

    weight_bank #(
        .AW (AW), 
        .DW (DW),
        .Tm (Tm),
        .Tn (Tn),
        .K (K),
        .X (X),
        .Y (Y) 
    ) weight_bank00 (
        .rd_data (rd_data00),
        .rd_addr (rd_addr00),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena00),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data01),
        .rd_addr (rd_addr01),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena01),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data02),
        .rd_addr (rd_addr02),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena02),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data03),
        .rd_addr (rd_addr03),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena03),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data10),
        .rd_addr (rd_addr10),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena10),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data11),
        .rd_addr (rd_addr11),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena11),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data12),
        .rd_addr (rd_addr12),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena12),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data13),
        .rd_addr (rd_addr13),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena13),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data20),
        .rd_addr (rd_addr20),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena20),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data21),
        .rd_addr (rd_addr21),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena21),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data22),
        .rd_addr (rd_addr22),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena22),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data23),
        .rd_addr (rd_addr23),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena23),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data30),
        .rd_addr (rd_addr30),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena30),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data31),
        .rd_addr (rd_addr31),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena31),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data32),
        .rd_addr (rd_addr32),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena32),

        .clk (clk),
        .rst (rst)
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
        .rd_data (rd_data33),
        .rd_addr (rd_addr33),
        .wr_data (weight_fifo_data),
        .wr_ena (wr_ena33),

        .clk (clk),
        .rst (rst)
    );

endmodule
