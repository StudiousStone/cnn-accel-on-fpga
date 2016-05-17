/*
* Created           : mny
* Date              : 201602
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module mv_bmem #(
    parameter WW = 10,
    parameter HW = 10,
    parameter CW = 10,
    parameter LW = WW + HW + CW,
    parameter LDW = 32,
    parameter XAW = 32,
    parameter XDW = 128
)(
    output                          rmst_ctrl_fixed_location,
    output                [XAW-1:0] rmst_ctrl_read_base,
    output                [XAW-1:0] rmst_ctrl_read_length,
    output                          rmst_ctrl_go,
    input                           rmst_ctrl_done,
    output                          rmst_user_read_buffer,
    input                 [XDW-1:0] rmst_user_buffer_data,
    input                           rmst_user_data_available,
    
    output                          wmst_ctrl_fixed_location,
    output                [XAW-1:0] wmst_ctrl_write_base,
    output                [XAW-1:0] wmst_ctrl_write_length,
    output                          wmst_ctrl_go,
    input                           wmst_ctrl_done,
    output                          wmst_user_write_buffer,
    output                [XDW-1:0] wmst_user_write_input_data,

    input               param_ena,
    input     [XAW-1:0] param_raddr,
    input     [XAW-1:0] param_waddr,
    input      [CW-1:0] param_irow,
    output              flag_over,

    output                  bias_ready,
    input                   bias_req,
    output        [XDW-1:0] bias_dat,
    input                   res_wreq,
    input         [XDW-1:0] res_data,

    input           rst,
    input           clk
);

reg                     [2:0]       done;
reg                     [3:0]       run_ena;

reg                     [CW-2:0]    len_word;
reg                     [CW-2:0]    len_symbol;

reg                     [XAW-1:0]   read_length;
reg                     [XAW-1:0]   read_base;

wire                                go;
wire                                read;
reg                                 rmst_not_empty;
wire                                almost_empty;
wire                                empty;
wire                    [7:0]       usedw;

reg                     [CW-2:0]    cnt_unit;
reg                     [7:0]       wlen;
reg                     [XAW-1:0]   wbase;
reg                                 go_write;
reg                                 over;

assign rmst_ctrl_fixed_location = 1'b0;
assign rmst_ctrl_read_base = read_base;
assign rmst_ctrl_read_length = read_length;
assign rmst_ctrl_go = go;
assign rmst_user_read_buffer = read;

always @ ( posedge clk ) begin
    done[0] <= rmst_ctrl_done;
    done[1] <= (~done[0]) & rmst_ctrl_done;
    done[2] <= done[1];
    run_ena[0] <= param_ena;
    run_ena[1] <= (~run_ena[0]) & param_ena;
    run_ena[2] <= run_ena[1];
    run_ena[3] <= run_ena[2];
end

always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )   begin
        len_symbol  <= 'b0;
        len_word    <= 'd0;
    end
    else if( run_ena[1] )   begin
        len_word    <= param_irow[CW-1:2] + (|param_irow[1:0]);
        len_symbol  <= param_irow[CW-1:2] + (|param_irow[1:0]);
    end
    else if( go )
        len_symbol  <= len_symbol - (read_length >> 4);
always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        read_length <= 'd0;
    else if( len_symbol > 'd31 )
        read_length <= ('d32 << 4);
    else if( len_symbol > 'd15 )
        read_length <= ('d16 << 4);
    else if( len_symbol > 'd7 )
        read_length <= ('d8 << 4);
    else
        read_length <= (len_symbol << 4);
always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        read_base <= 'd0;
    else if( run_ena[1] )
        read_base <= param_raddr;
    else if( go )
        read_base <= read_base + read_length;

assign go = (run_ena[3] | done[2]) & (|len_symbol);
assign read = rmst_not_empty & rmst_user_data_available & almost_empty;
always @ ( posedge clk )
    if( rmst_user_data_available )
        rmst_not_empty <= 1'b1;
    else
        rmst_not_empty <= 1'b0;

assign bias_ready = ((usedw > 'd4) | ((~empty) & (len_symbol == 'd0))) & ( wlen < 'd200);

scfifo	SCFF (
    .aclr           ( rst ),
    .clock          ( clk ),
    .data           ( rmst_user_buffer_data ),
    .rdreq          ( bias_req ),
    .sclr           ( 1'b0 ),
    .wrreq          ( read ),
    .almost_empty   ( almost_empty ),
    .almost_full    ( ),
    .empty          ( empty ),
    .full           ( ),
    .q              ( bias_dat ),
    .usedw          ( usedw ),
    .eccstatus ());
defparam
    SCFF.add_ram_output_register = "OFF",
    SCFF.almost_empty_value = 240,
    SCFF.almost_full_value = 200,
    SCFF.intended_device_family = "Cyclone V",
    SCFF.lpm_hint = "RAM_BLOCK_TYPE=M10K",
    SCFF.lpm_numwords = 256,
    SCFF.lpm_showahead = "OFF",
    SCFF.lpm_type = "scfifo",
    SCFF.lpm_width = XDW,
    SCFF.lpm_widthu = 8,
    SCFF.overflow_checking = "ON",
    SCFF.underflow_checking = "ON",
    SCFF.use_eab = "ON";

always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        cnt_unit <= 'd0;
    else if( run_ena[1] | flag_over )
        cnt_unit <= 'd0;
    else if( res_wreq )
        cnt_unit <= cnt_unit + 'd1;
always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        wlen <= 'd0;
    else if( run_ena[1] )
        wlen <= 'd0;
    else if( res_wreq )
        wlen <= go_write ? 'd1 : (wlen + 'd1);
    else if( go_write )
        wlen <= 'd0;
always @ ( posedge clk )
    if( run_ena[1] )
        wbase <= param_waddr;
    else if( go_write )
        wbase <= wbase + wmst_ctrl_write_length;
always @ ( posedge clk )
    if( ((wlen > 'd15) | ((|wlen) & (cnt_unit == len_word))) & wmst_ctrl_done & (~go_write) )
        go_write <= 1'b1;
    else 
        go_write <= 1'b0;
always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        over <= 'd0;
    else if( run_ena[1] | flag_over )
        over <= 'd0;
    else if( (cnt_unit == len_word) & (|len_word) )
        over <= 1'b1;

assign wmst_ctrl_fixed_location     = 1'b0;
assign wmst_user_write_buffer       = res_wreq;
assign wmst_user_write_input_data   = res_data;
assign wmst_ctrl_write_length       = {wlen, 4'd0};
assign wmst_ctrl_write_base         = wbase;
assign wmst_ctrl_go                 = go_write;
assign flag_over                    = over & go_write;

endmodule

