/*
* Created           : mny
* Date              : 201603
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module mem_rmst (
    input  wire         read_control_fixed_location   ,   //    read_0_control.fixed_location
    input  wire [31:0]  read_control_read_base        ,        //                  .read_base
    input  wire [31:0]  read_control_read_length      ,      //                  .read_length
    input  wire         read_control_go               ,               //                  .go
    output wire         read_control_done             ,             //                  .done
    input  wire         read_user_read_buffer         ,         //       read_0_user.read_buffer
    output wire [127:0] read_user_buffer_output_data  ,  //                  .buffer_output_data
    output wire         read_user_data_available      ,      //                  .data_available
   
    output reg  rreq,
    input       grant,

    output       [31:0] raddr,
    input       [127:0] rdata,

    input           clk,
    input           rst
);

reg             [31:0] addr;
reg             [31:0] len;
reg                    write;
wire                   ena;
wire                   empty;

assign read_user_data_available = ~empty;
assign raddr = addr;

always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        rreq <= 1'b0;
    else if( read_control_go )
        rreq <= 1'b1;
    else if( len == 'd0 )
        rreq <= 'd0;
assign ena = (len > 'd0) & grant;
always @ ( posedge clk or posedge rst )
    if( rst == 'b1 )
        len <= 'd0;
    else if( read_control_go )
        len <= read_control_read_length >> 4;
    else if( ena )
        len <= len - 'd1;
always @ ( posedge clk )
    write <= ena;
always @ ( posedge clk )
    if( read_control_go )
        addr <= read_control_read_base >> 4;
    else if( ena )
        addr <= addr + 'd1;
assign read_control_done = (len == 'd0);
        
scfifo	SCFF (
    .aclr           ( rst ),
    .clock          ( clk ),
    .data           ( rdata ),
    .rdreq          ( read_user_read_buffer ),
    .sclr           ( 1'b0 ),
    .wrreq          ( write ),
    .almost_empty   ( ),
    .almost_full    ( ),
    .empty          ( empty ),
    .full           (  ),
    .q              ( read_user_buffer_output_data ),
    .usedw          ( ),
    .eccstatus ());
defparam
    SCFF.add_ram_output_register = "OFF",
    SCFF.almost_empty_value = 8,
    SCFF.almost_full_value = 250,
    SCFF.intended_device_family = "Cyclone V",
    SCFF.lpm_hint = "RAM_BLOCK_TYPE=M10K",
    SCFF.lpm_numwords = 256,
    SCFF.lpm_showahead = "ON",
    SCFF.lpm_type = "scfifo",
    SCFF.lpm_width = 128,
    SCFF.lpm_widthu = 8,
    SCFF.overflow_checking = "ON",
    SCFF.underflow_checking = "ON",
    SCFF.use_eab = "ON";

endmodule
