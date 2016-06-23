/*
* Created           : cheng liu
* Date              : 2016-04-22
*
* Description:
* 
* test altera memory port
* 
* 
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on


module softmax_tb;
    parameter AW = 10;
    parameter DW = 32;
    parameter DATA_SIZE = 128;
    parameter NORM_DELAY = 14;
    parameter EXP_DELAY = 17;
    parameter ACC_DELAY = 9;
    parameter DIV_DELAY = 20;
    parameter CLK_PERIOD = 10;
    
    reg                       clk = 0;
    reg                       rst;

    //reg             [DW-1: 0] inmem[0: DATA_SIZE-1];
    //reg             [DW-1: 0] outmem[0: DATA_SIZE-1];
    reg             [DW-1: 0] mem[0: DATA_SIZE-1];


    reg                       downstream_ready;
    reg             [DW-1: 0] mem_data_out;
    reg             [DW-1: 0] mem_data_tmp;
    wire                      softmax_core_done;
    wire            [AW-1: 0] rd_addr;
    wire            [AW-1: 0] wr_addr;
    wire                      wr_ena;   
    wire            [DW-1: 0] wr_data;
    wire            [DW-1: 0] rd_data;
    reg                       softmax_core_start;

    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        rst = 1;
        downstream_ready = 1'b1;

        #100
        rst = 0;

        #6000
        $writememh("result.txt", mem, 0, DATA_SIZE-1);
        $stop(2);
    end

    //init memory
    initial begin
        $readmemh("init.txt", mem, 0, DATA_SIZE-1);
    end

    always@(posedge clk or posedge rst) begin
      if(rst == 1'b1) begin
        mem_data_tmp <= 0;
        mem_data_out <= 0;
      end
      else begin
        mem_data_tmp <= mem[rd_addr];
        mem_data_out <= mem_data_tmp;
      end
    end

    always@(posedge clk) begin
        if(wr_ena == 1'b1) begin
            mem[wr_addr] <= wr_data;
        end
    end

    assign rd_data = mem_data_out;

    initial begin
        softmax_core_start = 1'b0;
        downstream_ready = 1'b1;
        #200
        softmax_core_start = 1'b1;
        #CLK_PERIOD
        softmax_core_start = 1'b0;
        #8000
        softmax_core_start = 1'b1;
        #CLK_PERIOD
        softmax_core_start = 1'b0;
    end

softmax_core #(
    .AW (AW),
    .DW (DW),
    .DATA_SIZE (DATA_SIZE),
    .NORM_DELAY (NORM_DELAY),
    .EXP_DELAY (EXP_DELAY),
    .ACC_DELAY (ACC_DELAY),
    .DIV_DELAY (DIV_DELAY)
) softmax_core (
    // port connected with input memory
    .data_in (rd_data),
    .rd_addr (rd_addr),

    // port connected with output memory
    .wr_ena (wr_ena),
    .wr_addr (wr_addr),
    .data_out (wr_data),

    // softmax_core control signals
    .softmax_core_start (softmax_core_start), 
    .softmax_core_done (softmax_core_done),
    .downstream_ready (downstream_ready),

    // global signals
    .clk (clk),
    .rst (rst)
);

endmodule

