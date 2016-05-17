/*
* Created           : mny
* Date              : 201603
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module mv_top #(
    parameter WW = 10,
    parameter HW = 10,
    parameter CW = 10,
    parameter LW = WW + HW + CW,
    parameter VW = 4,
    parameter LDW = 32,
    parameter XAW = 32,
    parameter XDW = 128
)(
    input               config_ena,
    input         [5:0] config_addr,
    input        [31:0] config_wdata,
    output       [31:0] config_rdata,

    output                  [VW+1:0]            rmst_ctrl_fixed_location,
    output                  [(VW+2)*XAW-1:0]    rmst_ctrl_read_base,
    output                  [(VW+2)*XAW-1:0]    rmst_ctrl_read_length,
    output                  [VW+1:0]            rmst_ctrl_go,
    input                   [VW+1:0]            rmst_ctrl_done,
    output                  [VW+1:0]            rmst_user_read_buffer,
    input                   [(VW+2)*XDW-1:0]    rmst_user_buffer_data,
    input                   [VW+1:0]            rmst_user_data_available,
    
    output                          wmst_ctrl_fixed_location,
    output                [XAW-1:0] wmst_ctrl_write_base,
    output                [XAW-1:0] wmst_ctrl_write_length,
    output                          wmst_ctrl_go,
    input                           wmst_ctrl_done,
    output                          wmst_user_write_buffer,
    output                [XDW-1:0] wmst_user_write_input_data,
    input                           wmst_user_buffer_full,

    input           clk,
    input           rst
);
    
wire                 param_ena      ;
wire       [XAW-1:0] param_waddr    ;
wire       [XAW-1:0] param_iaddr    ;
wire       [XAW-1:0] param_baddr    ;
wire       [XAW-1:0] param_oaddr    ;
wire        [CW-1:0] param_olen     ;
wire        [LW-1:0] param_ilen     ;
wire       [XAW-1:0] param_woffset  ;
wire                 flag_over      ;

wire           [VW:0] mmat_ready ;
wire [LDW*(VW+1)-1:0] mmat_dat   ;

reg                   active;
wire                  active_data;

wire                  bias_ready;
wire         [VW-1:0] bias_req;
wire        [XDW-1:0] bias_dat;
wire         [VW-1:0] res_wreq;
wire        [XDW-1:0] res_data;

wire        [XAW-1:0] woffset;
reg         [XAW-1:0] waddr[0:VW-1];
reg                   dly_ena[0:VW-1];

mv_config #(
    .WW ( WW ),
    .HW ( HW ),
    .CW ( CW ),
    .LDW ( LDW ),
    .XAW ( XAW ),
    .XDW ( XDW )
) CONFIG (
    .config_ena     ( config_ena   ),
    .config_addr    ( config_addr  ),
    .config_wdata   ( config_wdata ),
    .config_rdata   ( config_rdata ),
    
    .param_ena      ( param_ena     ),
    .param_waddr    ( param_waddr   ),
    .param_iaddr    ( param_iaddr   ),
    .param_baddr    ( param_baddr   ),
    .param_oaddr    ( param_oaddr   ),
    .param_olen     ( param_olen    ),
    .param_ilen     ( param_ilen    ),
    .param_woffset  ( param_woffset ),
    .flag_over      ( flag_over     ),
    
    .rst( rst ),
    .clk( clk )
);

mv_bmem #(
    .WW ( WW ),
    .HW ( HW ),
    .CW ( CW ),
    .LDW ( LDW ),
    .XAW ( XAW ),
    .XDW ( XDW )
) BIAS (
    .rmst_ctrl_fixed_location   ( rmst_ctrl_fixed_location[4]           ),
    .rmst_ctrl_read_base        ( rmst_ctrl_read_base[5*XAW-1:4*XAW]    ),
    .rmst_ctrl_read_length      ( rmst_ctrl_read_length[5*XAW-1:4*XAW]  ),
    .rmst_ctrl_go               ( rmst_ctrl_go[4]                       ),
    .rmst_ctrl_done             ( rmst_ctrl_done[4]                     ),
    .rmst_user_read_buffer      ( rmst_user_read_buffer[4]              ),
    .rmst_user_buffer_data      ( rmst_user_buffer_data[5*XDW-1:4*XDW]  ),
    .rmst_user_data_available   ( rmst_user_data_available[4]           ),
    
    .wmst_ctrl_fixed_location   ( wmst_ctrl_fixed_location   ),
    .wmst_ctrl_write_base       ( wmst_ctrl_write_base       ),
    .wmst_ctrl_write_length     ( wmst_ctrl_write_length     ),
    .wmst_ctrl_go               ( wmst_ctrl_go               ),
    .wmst_ctrl_done             ( wmst_ctrl_done             ),
    .wmst_user_write_buffer     ( wmst_user_write_buffer     ),
    .wmst_user_write_input_data ( wmst_user_write_input_data ),

    .param_ena      ( param_ena   ),
    .param_raddr    ( param_baddr ),
    .param_waddr    ( param_oaddr ),
    .param_irow     ( param_olen  ),
    .flag_over      ( flag_over   ),

    .bias_ready ( bias_ready ),
    .bias_req   ( &bias_req  ),
    .bias_dat   ( bias_dat   ),
    .res_wreq   ( &res_wreq  ),
    .res_data   ( res_data   ),

    .rst( rst ),
    .clk( clk )
);

mv_rmem #(
    .WW ( WW ),
    .HW ( HW ),
    .CW ( CW ),
    .LDW ( LDW ),
    .XAW ( XAW ),
    .XDW ( XDW )
) VECTOR (
    .rmst_ctrl_fixed_location   ( rmst_ctrl_fixed_location[5]           ),
    .rmst_ctrl_read_base        ( rmst_ctrl_read_base[6*XAW-1:5*XAW]    ),
    .rmst_ctrl_read_length      ( rmst_ctrl_read_length[6*XAW-1:5*XAW]  ),
    .rmst_ctrl_go               ( rmst_ctrl_go[5]             ),
    .rmst_ctrl_done             ( rmst_ctrl_done[5]           ),
    .rmst_user_read_buffer      ( rmst_user_read_buffer[5]    ),
    .rmst_user_buffer_data      ( rmst_user_buffer_data[6*XDW-1:5*XDW]  ),
    .rmst_user_data_available   ( rmst_user_data_available[5] ),
    
    .param_ena      ( param_ena     ),
    .param_addr     ( param_iaddr   ),
    .param_ioffset  ( 'd0           ),
    .param_ilen     ( param_ilen    ),
    .param_irow     ( {2'd0, param_olen[CW-1:2]} + {9'd0, (|param_olen[1:0])} ),

    .mat_ready  ( mmat_ready[VW] ),
    .mat_req    ( active_data ),
    .mat_dat    ( mmat_dat[(VW+1)*LDW-1:VW*LDW] ),

    .rst( rst ),
    .clk( clk )
);

assign active_data = (&mmat_ready) & bias_ready;
always @ ( posedge clk )
    active <= active_data;

generate
    genvar g;

    assign woffset  = {param_woffset[XAW-3:0], 2'b0};
    //assign waddr[0] = param_waddr;
    
    always @ ( posedge clk ) begin
        dly_ena[0] <= param_ena;
        waddr[0]   <= param_waddr;
    end
    for( g = 1; g < VW; g = g + 1 ) begin: M0
        always @ ( posedge clk ) begin
            waddr[g]   <= waddr[g-1] + param_woffset[XAW-1:0];
            dly_ena[g] <= dly_ena[g-1];
        end
    end 
    for( g = 0; g < VW; g = g + 1 ) begin: M1
        mv_rmem #(
            .WW ( WW ),
            .HW ( HW ),
            .CW ( CW ),
            .LDW ( LDW ),
            .XAW ( XAW ),
            .XDW ( XDW )
        ) WEIGHT (
            .rmst_ctrl_fixed_location   ( rmst_ctrl_fixed_location[g] ),
            .rmst_ctrl_read_base        ( rmst_ctrl_read_base[(g+1)*XAW-1:g*XAW]      ),
            .rmst_ctrl_read_length      ( rmst_ctrl_read_length[(g+1)*XAW-1:g*XAW]    ),
            .rmst_ctrl_go               ( rmst_ctrl_go[g]             ),
            .rmst_ctrl_done             ( rmst_ctrl_done[g]           ),
            .rmst_user_read_buffer      ( rmst_user_read_buffer[g]    ),
            .rmst_user_buffer_data      ( rmst_user_buffer_data[(g+1)*XDW-1:g*XDW]    ),
            .rmst_user_data_available   ( rmst_user_data_available[g] ),
            
            .param_ena      ( dly_ena[VW-1] ),
            .param_addr     ( waddr[g]      ),
            .param_ioffset  ( woffset       ),
            .param_ilen     ( param_ilen    ),
            .param_irow     ( {2'd0, param_olen[CW-1:2]} + {9'd0, (|param_olen[1:0])} ),
        
            .mat_ready  ( mmat_ready[g]               ),
            .mat_req    ( active_data ),
            .mat_dat    ( mmat_dat[(g+1)*LDW-1:g*LDW] ),
        
            .rst( rst ),
            .clk( clk )
        );
    end
    for( g = 0; g < VW; g = g + 1 ) begin: M2
        fma #(
            .WW ( WW ),
            .HW ( HW ),
            .CW ( CW )
        ) FMA (
            .data_ena( active ),
            .dataa_in( mmat_dat[(g+1)*LDW-1:g*LDW]  ),
            .datab_in( mmat_dat[(VW+1)*LDW-1:VW*LDW]),
        
            .param_ena      ( param_ena  ),
            .param_ilength  ( param_ilen ),
        
            .bias_req( bias_req[g] ),
            .bias_dat( bias_dat[(g+1)*LDW-1:g*LDW] ),
            .data_act( res_wreq[g] ),
            .data_out( res_data[(g+1)*LDW-1:g*LDW] ),
        
            .rst( rst ),
            .clk( clk )
        );
    end
endgenerate

endmodule

