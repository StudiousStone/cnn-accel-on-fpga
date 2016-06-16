/*
* Created           : cheng liu
* Date              : 2016-06-15
* Email             : st.liucheng@gmail.com
*
* Description:
*
* Typically, when the write master completes the ddr writing, the next tile computing can be started.
* However, when there is only a fraction of the tile output in the corner is written to the ddr, then 
* the ddr writing can be done before the internal output is dumped to the output fifo. In this case, the conv_tile_reset 
* signal based on the store_done signal may cause mistakes. Although it is possible to reset all the tile computing, 
* it is somewhat difficult to reset all the pipelined data path and control signals. Currently, we just issue a done 
* signal when both internal store and ddr writing is done.
*
* Instance example:
*
gen_store_done gen_store_done (
    .internal_store_done  (),
    .wmst_store_done      (),
    .conv_store_done      (),

    .clk                  (clk),
    .rst                  (rst)
);
*
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module gen_store_done (
    input                              internal_store_done,
    input                              wmst_store_done,

    output                             conv_store_done,

    input                              clk,
    input                              rst
);

    reg                                internal_store_done_keep;
    reg                                wmst_store_done_keep;
    wire                               conv_store_done_keep;
    reg                                conv_store_done_keep_reg;

    assign conv_store_done_keep = (internal_store_done_keep || internal_store_done) &&
                                  (wmst_store_done_keep || wmst_store_done);

    always@(posedge clk) begin
        conv_store_done_keep_reg <= conv_store_done_keep;
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            internal_store_done_keep <= 1'b0;
        end
        else if(internal_store_done == 1'b1 && conv_store_done == 1'b0) begin
            internal_store_done_keep <= 1'b1;
        end
        else if(conv_store_done == 1'b1) begin
            internal_store_done_keep <= 1'b0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wmst_store_done_keep <= 1'b0;
        end
        else if(wmst_store_done == 1'b1 && conv_store_done == 1'b0) begin
            wmst_store_done_keep <= 1'b1;
        end
        else if(conv_store_done == 1'b1) begin
            wmst_store_done_keep <= 1'b0;
        end
    end

    assign conv_store_done = conv_store_done_keep && (~conv_store_done_keep_reg);

endmodule
