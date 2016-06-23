
// synopsys translate_off
`timescale 1ns/1ns
// synopsys translate_on

module config_data#(
    parameter WW = 10,
    parameter HW = 10,
    parameter CW = 10,
    parameter LW = WW + HW + CW,
    parameter VW = 4,
    parameter LDW = 32,
    parameter XAW = 32,
    parameter XDW = 128
)(
    output reg          config_ena,
    output reg    [5:0] config_addr,
    output reg   [31:0] config_wdata,
    input        [31:0] config_rdata,
    
    output reg                      wmst_ctrl_fixed_location,
    output reg            [XAW-1:0] wmst_ctrl_write_base,
    output reg            [XAW-1:0] wmst_ctrl_write_length,
    output reg                      wmst_ctrl_go,
    input                           wmst_ctrl_done,
    output reg                      wmst_user_write_buffer,
    output reg            [XDW-1:0] wmst_user_write_input_data,
    input                           wmst_user_buffer_full,
    
    output reg                              rmst_ctrl_fixed_location,
    output reg                  [31:0]      rmst_ctrl_read_base,
    output reg                  [31:0]      rmst_ctrl_read_length,
    output reg                              rmst_ctrl_go,
    input                                   rmst_ctrl_done,
    output reg                              rmst_user_read_buffer,
    input                       [127:0]     rmst_user_buffer_data,
    input                                   rmst_user_data_available,
    
    
    input               clk,
    input               rst
);

localparam CFG_WBASE    = 'h00;
localparam CFG_IBASE    = 'h01;
localparam CFG_BBASE    = 'h02;
localparam CFG_OBASE    = 'h03;
localparam CFG_ILEN     = 'h04;
localparam CFG_OLEN     = 'h05;
localparam CFG_WOFFSET  = 'h06;

localparam CSR_RUN      = 'h20;
localparam CSR_STATE    = 'h21;
localparam CSR_TIME     = 'h22;
localparam CSR_CHECK    = 'hFF;

localparam IH           = 32;
localparam IW           = 32;
localparam IC           = 4;
localparam ILEN         = IH * IW * IC;
localparam OLEN         = 32;
localparam WOFFSET      = ILEN * 16;
localparam WBASE        = 'd0;
localparam IBASE        = WBASE + WOFFSET * OLEN;
localparam BBASE        = IBASE + ILEN * 16;
localparam OBASE        = BBASE;

reg         [31:0]      wmem[0:ILEN*OLEN-1];
reg         [31:0]      imem[0:ILEN-1];
reg         [31:0]      bmem[0:OLEN-1];
reg         [31:0]      omem[0:OLEN-1];

integer                 i, cnt, len;
reg         [127:0]     data;
integer                 fp_mem;
integer                 cnt_o;

initial begin
    config_ena = 0;
    config_addr = 0;
    config_wdata = 0;

    wmst_ctrl_fixed_location    = 'd0;
    $readmemh("wmem.txt", wmem, 0, ILEN*OLEN-1);
    $readmemh("imem.txt", imem, 0, ILEN-1);
    $readmemh("bmem.txt", bmem, 0, OLEN-1);
    fp_mem = $fopen("ores.txt");
    
    wait( rst == 1'b0 );
    cnt_o = 'd0;
    # 100;
    repeat ( OLEN ) begin
        WRITE_DATA(2'd0, ILEN, WBASE + cnt_o * WOFFSET, cnt_o * ILEN);
        $display($time, " weight data configure finished, at base = %d\n", WBASE + cnt_o*WOFFSET);
        @( posedge clk );
        @( posedge clk );
        cnt_o = cnt_o + 'd1;
        @( posedge clk );
        @( posedge clk );
    end
    //WRITE_DATA(2'd0, WLEN, WBASE + 1*WOFFSET, 1*WLEN);
    //$display($time, " weight data configure finished, at base = %d\n", WBASE + 1*WOFFSET);
    //@( posedge clk );
    //WRITE_DATA(2'd0, WLEN, WBASE + 2*WOFFSET, 2*WLEN);
    //$display($time, " weight data configure finished, at base = %d\n", WBASE + 0*WOFFSET);
    //@( posedge clk );
    //WRITE_DATA(2'd0, WLEN, WBASE + 3*WOFFSET, 3*WLEN);
    //$display($time, " weight data configure finished, at base = %d\n", WBASE + 1*WOFFSET);
    
    # 5000;
    # 100;
    WRITE_DATA(2'd1, ILEN, IBASE + 0*WOFFSET, 0*ILEN);
    $display($time, " input data configure finished, at base = %h\n", IBASE);
    # 100;
    WRITE_DATA(2'd2, OLEN, BBASE + 0*WOFFSET, 0*ILEN);
    $display($time, " bias data configure finished, at base = %h\n", BBASE);
    
    config_ena = 1;
    config_addr = 0;
    config_wdata = 0;
    CONFIG_PARAM(CFG_WBASE, WBASE, config_addr, config_wdata);
    CONFIG_PARAM(CFG_IBASE, IBASE, config_addr, config_wdata);
    CONFIG_PARAM(CFG_BBASE, BBASE, config_addr, config_wdata);
    CONFIG_PARAM(CFG_OBASE, OBASE, config_addr, config_wdata);
    CONFIG_PARAM(CFG_ILEN, ILEN, config_addr, config_wdata);
    CONFIG_PARAM(CFG_OLEN, OLEN, config_addr, config_wdata);
    CONFIG_PARAM(CFG_WOFFSET, WOFFSET, config_addr, config_wdata);
    
    CONFIG_PARAM(CSR_RUN, 32'd0, config_addr, config_wdata);
    CONFIG_PARAM(CSR_RUN, 32'd1, config_addr, config_wdata);
    CONFIG_PARAM(CSR_RUN, 32'd0, config_addr, config_wdata);
    $display($time, " parameter data configure finished\n");
    
    # 200;
    config_addr = CSR_STATE;
    wait( config_rdata[1:0] == 2'b01 );
    $display($time, " test finished\n");
    # 2000;
    READ_DATA( OLEN, OBASE );
    # 2000;
    $fclose( fp_mem );
    
    # 3000;
    
    $stop(2);
end

task READ_DATA;
    input   [31:0] len;
    input   [31:0] addr;
    
    integer i;
    begin      
        rmst_ctrl_read_base         = addr;
        rmst_ctrl_read_length       = len * 4;
        rmst_ctrl_go                = 'd0;
        rmst_ctrl_fixed_location    = 'd0;
        rmst_user_read_buffer       = 'd0;
        @ ( posedge clk );
        @ ( posedge clk );
        rmst_ctrl_go                = 'd1;
        @ ( posedge clk );
        rmst_ctrl_go                = 'd0;
        @ ( posedge clk );
        i = 0;
        while ( i < len )  begin
            @ ( posedge clk );
            if( rmst_user_data_available ) begin
                rmst_user_read_buffer   = 'd1;
                data                    = rmst_user_buffer_data;
                i                       = i + 'd4;
                @ ( posedge clk );
                rmst_user_read_buffer   = 'd0;
                $fwrite(fp_mem, "%h\n", data[31:0]);
                $fwrite(fp_mem, "%h\n", data[63:32]);
                $fwrite(fp_mem, "%h\n", data[95:64]);
                $fwrite(fp_mem, "%h\n", data[127:96]);
            end
            @ ( posedge clk );
            @ ( posedge clk );
            @ ( posedge clk );
        end
    end
endtask

task WRITE_DATA;
    input       [1:0]       sel;
    input       [XAW-1:0]   wlen;
    input       [XAW-1:0]   wbase;
    input       [XAW-1:0]   woffset;
     
    begin
        wmst_ctrl_write_base        = 'd0;
        wmst_ctrl_write_length      = 'd0;
        wmst_ctrl_go                = 'd0;
        wmst_user_write_buffer      = 'd0;
        wmst_user_write_input_data  = 'd0;
        cnt = 'd0;
        len                         = wlen + 4;
        wmst_ctrl_write_base        = wbase;
        
        @ ( posedge clk );
        
        @ ( posedge clk );
        for( i = 0; i < len / 4; i = i + 1 ) begin: M0
            case( sel )
                2'd0: wmst_user_write_input_data  = {wmem[woffset+4*i+3], wmem[woffset+4*i+2], wmem[woffset+4*i+1], wmem[woffset+4*i]};
                2'd1: wmst_user_write_input_data  = {imem[woffset+4*i+3], imem[woffset+4*i+2], imem[woffset+4*i+1], imem[woffset+4*i]};
                2'd2: wmst_user_write_input_data  = {bmem[woffset+4*i+3], bmem[woffset+4*i+2], bmem[woffset+4*i+1], bmem[woffset+4*i]};
            endcase
            wmst_user_write_buffer      = 'd1;
            cnt                         = cnt + 'd1;
            @ ( posedge clk );
            if( wmst_user_buffer_full ) begin
                wmst_user_write_buffer  = 'd0;
                @ ( posedge clk );
                wait( ~wmst_user_buffer_full );
                @ ( posedge clk );
                @ ( posedge clk );
            end
            if( cnt == 8 ) begin
                wmst_user_write_buffer  = 'd0;
                @ ( posedge clk );
                wmst_ctrl_write_length  = cnt << 4;
                wmst_ctrl_go            = 'd1;
                @ ( posedge clk );
                cnt                     = 'd0;
                wmst_ctrl_go            = 'd0;
                wmst_ctrl_write_base    = wmst_ctrl_write_base + (8 << 4);
                @ ( posedge clk );
                wait( wmst_ctrl_done );
                @ ( posedge clk );
                @ ( posedge clk );
            end
        end
        wmst_user_write_buffer  = 'd0;
        @ ( posedge clk );
        wmst_ctrl_write_length  = cnt << 4;
        wmst_ctrl_go            = 'd1;
        @ ( posedge clk );
        cnt                     = 'd0;
        wmst_ctrl_go            = 'd0;
        @ ( posedge clk );
        wait( wmst_ctrl_done );
        @ ( posedge clk );
        @ ( posedge clk );
    end    
endtask

task CONFIG_PARAM;
    input   [5:0] addr;
    input  [31:0] data;
    output reg     [5:0] config_addr;
    output reg    [31:0] config_data;
    begin
        @ ( posedge clk );
        config_addr = addr;
        config_data = data;
        @ ( posedge clk );
    end
endtask

endmodule

