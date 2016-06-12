/*
* Created           : Cheng Liu
* Date              : 2016-04-25
*
* Description:
* Set softmax basic design parameters and expose information to upper mmodules
softmax_config #(
    .AW (),  // Internal memory address width
    .DW (),  // Internal data width
    .CW ()    // maxium number of configuration paramters is (2^CW).
)softmax_config(
    .config_ena (),
    .config_addr (),
    .config_wdata (),
    .config_rdata (),
    
    .config_done (),       // configuration is done. (orginal name: param_ena)
    .param_raddr (),
    .param_waddr (),
    .param_iolen (),
    .task_done (), // computing task is done. (original name: flag_over)
    
    .rst (),
    .clk ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module transfer_config #(
    parameter AW = 12,  // Internal memory address width
    parameter DW = 32,  // Internal data width
    parameter CW = 6,   // maxium number of configuration paramters is (2^CW).
    parameter DATA_SIZE = 1024
)(
    input                              config_start,
    output reg                         config_done,
  
    output reg                [DW-1:0] param_raddr, // aligned by byte
    output reg                [DW-1:0] param_waddr, // aligned by byte
    output reg                [AW-1:0] param_iolen, // aligned by word

    output reg                         task_done,        // computing task is done. (original name: flag_over)
    input                              store_data_done,
    
    input                              rst,
    input                              clk
);

    localparam tile_len = 128;
    reg                     [AW-1: 0] len;
    reg                     [AW-1: 0] last_iolen;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            last_iolen <= 0;
        end
        else if(config_done == 1'b1 && task_done == 1'b0) begin
            last_iolen <= param_iolen;
        end
        else if(task_done == 1'b1) begin
            last_iolen <= 0;
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            param_raddr <= 0;
            param_waddr <= 0;
        end
        else if(store_data_done == 1'b1 && task_done == 1'b0) begin
            param_raddr <= param_raddr + (last_iolen << 2);
            param_waddr <= param_waddr + (last_iolen << 2);
        end
        else if(task_done == 1'b1) begin
            param_raddr <= 0;
            param_waddr <= 0;
        end
    end
    

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            param_iolen <= 0;
        end
        else if(config_start == 1'b1 || store_data_done == 1'b1) begin
            param_iolen <= (len > tile_len) ? tile_len : len;
        end
    end    

   always@(posedge clk or posedge rst) begin
       if(rst == 1'b1) begin
           len <= DATA_SIZE;
       end
       else if(config_done == 1'b1 && task_done == 1'b0) begin
           len <= len - param_iolen;
       end
       else if(task_done == 1'b1) begin
           len <= 0;
       end
   end

   always@(posedge clk or posedge rst) begin
       if(rst == 1'b1) begin
           task_done <= 1'b0;
       end
       else if(store_data_done == 1'b1 && len == 0) begin
           task_done <= 1'b1;
       end
       else begin
           task_done <= 1'b0;
       end
   end

   always@(posedge clk or posedge rst) begin
       if(rst == 1'b1) begin
           config_done <= 1'b0;
       end
       else if((config_start == 1'b1) || (store_data_done == 1'b1 && len > 0)) begin
           config_done <= 1'b1;
       end
       else begin
           config_done <= 1'b0;
       end
   end


endmodule

