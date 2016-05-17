/*
* Created           : mny
* Date              : 201602
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module mv_config #(
    parameter WW = 10,
    parameter HW = 10,
    parameter CW = 10,
    parameter LW = WW + HW + CW,
    parameter LDW = 32,
    parameter KS = 3,
    parameter XAW = 32,
    parameter XDW = 128
)(
    input               config_ena,
    input         [5:0] config_addr,
    input        [31:0] config_wdata,
    output reg   [31:0] config_rdata,
    
    output                 param_ena,
    output reg   [XAW-1:0] param_waddr,
    output reg   [XAW-1:0] param_iaddr,
    output reg   [XAW-1:0] param_baddr,
    output reg   [XAW-1:0] param_oaddr,
    output reg    [CW-1:0] param_olen,
    output reg    [LW-1:0] param_ilen,
    output reg   [XAW-1:0] param_woffset,
    input                  flag_over,
    
    input           rst,
    input           clk
);

localparam WBASE        = 'h00;
localparam IBASE        = 'h01;
localparam BBASE        = 'h02;
localparam OBASE        = 'h03;
localparam ILEN         = 'h04;
localparam OLEN         = 'h05;
localparam WOFFSET      = 'h06;

localparam CSR_RUN      = 'h20;
localparam CSR_STATE    = 'h21;
localparam CSR_TIME     = 'h22;
localparam CSR_CHECK    = 'h3F;

reg             [1:0]   run; 

reg                     csr_status;
reg                     csr_over;
reg             [31:0]  csr_time_cost;

always @ ( posedge clk )
    if( config_ena && (config_addr == WBASE) )
        param_waddr <= config_wdata[XAW-1:0];
always @ ( posedge clk )
    if( config_ena && (config_addr == IBASE) )
        param_iaddr <= config_wdata[XAW-1:0];
always @ ( posedge clk )
    if( config_ena && (config_addr == BBASE) )
        param_baddr <= config_wdata[XAW-1:0];
always @ ( posedge clk )
    if( config_ena && (config_addr == OBASE) )
        param_oaddr <= config_wdata[XAW-1:0];
always @ ( posedge clk )
    if( config_ena && (config_addr == OLEN) )
        param_olen  <= config_wdata[CW-1:0];
always @ ( posedge clk )
    if( config_ena && (config_addr == ILEN) )
        param_ilen  <= config_wdata[LW-1:0];
always @ ( posedge clk )
    if( config_ena && (config_addr == WOFFSET) )
        param_woffset  <= config_wdata[XAW-1:0];

always @ ( posedge clk )
    run[1] <= run[0];
always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        run[0] <= 1'b0;
    else if( config_ena && (config_addr == CSR_RUN) )
        run[0] <= config_wdata[0];
assign param_ena = (~run[1]) & run[0];

always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        csr_status <= 1'b0;
    else if( param_ena )
        csr_status <= 1'b1;
    else if( flag_over )
        csr_status <= 1'b0;
always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        csr_over <= 1'b0;
    else if( param_ena )
        csr_over <= 1'b0;
    else if( flag_over )
        csr_over <= 1'b1;
always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        csr_time_cost <= 'd0;
    else if( param_ena )
        csr_time_cost <= 'd0;
    else if( csr_status )
        csr_time_cost <= (csr_time_cost == 32'hFF_FF_FF_FF) ? 32'hFF_FF_FF_FF : (csr_time_cost + 'd1);

always @ ( posedge clk )
    case( config_addr )
        WBASE       : config_rdata <= param_waddr;
        IBASE       : config_rdata <= param_iaddr;
        BBASE       : config_rdata <= param_baddr;
        OBASE       : config_rdata <= param_oaddr;
        ILEN        : config_rdata <= param_ilen;
        OLEN        : config_rdata <= param_olen;
        WOFFSET     : config_rdata <= param_woffset;
       
        CSR_RUN     : config_rdata <= run[0];
        CSR_STATE   : config_rdata <= {30'd0, csr_status, csr_over};
        CSR_TIME    : config_rdata <= csr_time_cost;
        CSR_CHECK   : config_rdata <= 32'hF0_F0_F0_F0;
    endcase

endmodule

