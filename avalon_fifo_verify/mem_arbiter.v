/*
* Created           : mny
* Date              : 201603
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module mem_arbiter #(
    parameter PORT = 8
)(
    input       [PORT-1:0] req,
    output reg  [PORT-1:0] grant,

    input           clk,
    input           rst
);

localparam S_IDLE = 3'h1;
localparam S_BUSY = 3'h2;
localparam S_ITER = 3'h4;

reg         [2:0] s_cur;
reg         [2:0] s_nxt;

always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        s_cur <= S_IDLE;
    else
        s_cur <= s_nxt;

always @ * begin
    s_nxt = s_cur;
    case( s_cur )
        S_IDLE: if( grant & req ) s_nxt = S_BUSY;
        S_BUSY: if( (grant & req) == 'd0 )  s_nxt = S_ITER;
        S_ITER: s_nxt = S_IDLE;
        default: s_nxt = S_IDLE;
    endcase
end

always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        grant <= {{(PORT-1){1'b0}}, 1'b1};
    else if( s_cur[0] )
        grant <= (grant & req) ? grant : {grant[PORT-2:0], grant[PORT-1]};
    else if( s_cur[2] )
        grant <= {grant[PORT-2:0], grant[PORT-1]};

endmodule
