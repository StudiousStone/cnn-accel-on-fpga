/*
* Created           : mny
* Date              : 201603
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module fma #(
    parameter WW = 10,
    parameter HW = 10,
    parameter CW = 10,
    parameter LW = WW + HW + CW,
    parameter WDW           = LW,
    parameter HDW           = LW,
    parameter D_MUL         = 5,
    parameter D_ADD         = 7,
    parameter LDW           = 32,
    parameter LPW           = 1
)(
    input                   data_ena,
    input     [LDW*LPW-1:0] dataa_in,
    input     [LDW*LPW-1:0] datab_in,

    input                   param_ena,
    input         [WDW-1:0] param_ilength,

    output                  bias_req,
    input         [LDW-1:0] bias_dat,
    output                  data_act,
    output        [LDW-1:0] data_out,

    input           clk,
    input           rst
);

reg              [D_MUL:0] ena;
reg              [D_ADD:0] act;

reg          [LDW*LPW-1:0] dataa;
reg          [LDW*LPW-1:0] datab;
wire             [LDW-1:0] res_mul;

wire             [LDW-1:0] res_add;

wire                       dat_act_w;
wire             [LDW-1:0] dat_out_w;
reg              [LDW-1:0] dat_out_reg;

always @ ( posedge clk )    begin
    ena[0]<= data_ena;
    dataa <= dataa_in;
    datab <= datab_in;
end

fp_mul5 MUL(
    .clock    ( clk     ),
    .dataa    ( dataa   ),
    .datab    ( datab   ),
    .result   ( res_mul )
);
generate
    genvar g;

    for( g = 0; g < D_MUL; g = g + 1 ) begin: M0
        always @ ( posedge clk )
            ena[g+1] <= ena[g];
    end

    for( g = 0; g < D_ADD; g = g + 1 ) begin: M1
        always @ ( posedge clk )
            act[g+1] <= act[g];
    end
endgenerate

pacc #(
    .BW ( WDW )
)PACC(
    .dat_ena        ( ena[D_MUL] ),
    .dat_in         ( res_mul    ),

    .param_ena      ( param_ena     ),
    .param_ilen     ( param_ilength ),

    .dat_act        ( dat_act_w     ),
    .dat_out        ( dat_out_w     ),

    .clk            ( clk ),
    .rst            ( rst )
);

always @ ( posedge clk ) begin
    act[0] <= dat_act_w;
    if( dat_act_w )
        dat_out_reg <= dat_out_w;
end
fp_add7 ADD2(
    .clock    ( clk         ),
    .dataa    ( dat_out_reg ),
    .datab    ( bias_dat    ),
    .result   ( res_add     )
);

assign bias_req = dat_act_w;
assign data_act = act[D_ADD];
assign data_out = res_add;

endmodule
