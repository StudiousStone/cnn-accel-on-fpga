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

    output                             done;
    output                             fifo_pop;
    input                              fifo_empty;
    input                    [DW-1: 0] data_from_fifo;

    output                             ram_wena;
    output                   [AW-1: 0] ram_addr;
    output                   [DW-1: 0] data_to_ram;

    input                              clk;
    input                              rst;

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
            @(posedge clk);
        end
        conv_tile_start = 1'b1;
        @(posedge clk)
        conv_tile_start = 1'b0;
    end


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

    assign data_to_ram = data_from_fifo;

    assign fifo_pop = (fifo_empty == 1'b0) && (transfer_on_going == 1'b1);

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

endmodule
