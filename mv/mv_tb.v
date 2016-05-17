
`timescale 1ns/1ns

module mv_tb;

parameter CLOCK_PERIOD = 20;

reg         clk = 0;
reg         rst = 0;
always # ( CLOCK_PERIOD / 2 ) clk = ~clk;
initial begin
    rst = 1;
    # 200;
    rst = 0; 
end

parameter R_PORT = 8;
parameter W_PORT = 8;
parameter VW     = 4;

wire  [R_PORT-1:0]        rmst_ctrl_fixed_location   ;   //    read_0_control.fixed_location
wire  [R_PORT*32-1:0]     rmst_ctrl_read_base        ;        //                  .read_base
wire  [R_PORT*32-1:0]     rmst_ctrl_read_length      ;      //                  .read_length
wire  [R_PORT-1:0]        rmst_ctrl_go               ;               //                  .go
wire  [R_PORT-1:0]        rmst_ctrl_done             ;             //                  .done
wire  [R_PORT-1:0]        rmst_user_read_buffer         ;         //       read_0_user.read_buffer
wire  [R_PORT*128-1:0]    rmst_user_buffer_data  ;  //                  .buffer_output_data
wire  [R_PORT-1:0]        rmst_user_data_available      ;      //                  .data_available

wire  [W_PORT-1:0]        wmst_ctrl_fixed_location  ;  //   write_0_control.fixed_location
wire  [W_PORT*32-1:0]     wmst_ctrl_write_base      ;      //                  .write_base
wire  [W_PORT*32-1:0]     wmst_ctrl_write_length    ;    //                  .write_length
wire  [W_PORT-1:0]        wmst_ctrl_go              ;              //                  .go
wire  [W_PORT-1:0]        wmst_ctrl_done            ;            //                  .done
wire  [W_PORT-1:0]        wmst_user_write_buffer        ;       //      write_0_user.write_buffer
wire  [W_PORT*128-1:0]    wmst_user_write_input_data    ;  //                  .buffer_input_data
wire  [W_PORT-1:0]        wmst_user_buffer_full        ;// 

wire          config_ena    ;
wire    [5:0] config_addr   ;
wire   [31:0] config_wdata  ;
wire   [31:0] config_rdata  ;

config_data CFG(
    .config_ena     ( config_ena   ),
    .config_addr    ( config_addr  ),
    .config_wdata   ( config_wdata ),
    .config_rdata   ( config_rdata ),
    
    .wmst_ctrl_fixed_location   ( wmst_ctrl_fixed_location[1]       ),
    .wmst_ctrl_write_base       ( wmst_ctrl_write_base[2*32-1:32]   ),
    .wmst_ctrl_write_length     ( wmst_ctrl_write_length[2*32-1:32] ),
    .wmst_ctrl_go               ( wmst_ctrl_go[1]                   ),
    .wmst_ctrl_done             ( wmst_ctrl_done[1]                 ),
    .wmst_user_write_buffer     ( wmst_user_write_buffer[1]         ),
    .wmst_user_write_input_data ( wmst_user_write_input_data[2*128-1:128] ),
    .wmst_user_buffer_full      ( wmst_user_buffer_full[1]          ),
    
    .rmst_ctrl_fixed_location   ( rmst_ctrl_fixed_location[VW+2]      ),
    .rmst_ctrl_read_base        ( rmst_ctrl_read_base[(VW+3)*32-1:(VW+2)*32]    ),
    .rmst_ctrl_read_length      ( rmst_ctrl_read_length[(VW+3)*32-1:(VW+2)*32]  ),
    .rmst_ctrl_go               ( rmst_ctrl_go[VW+2]                  ),
    .rmst_ctrl_done             ( rmst_ctrl_done[VW+2]                ),
    .rmst_user_read_buffer      ( rmst_user_read_buffer[VW+2]         ),
    .rmst_user_buffer_data      ( rmst_user_buffer_data[(VW+3)*128-1:(VW+2)*128] ),
    .rmst_user_data_available   ( rmst_user_data_available[VW+2]      ),

    .clk( clk ),
    .rst( rst )
);

mv_top MV (
    .config_ena     ( config_ena   ),
    .config_addr    ( config_addr  ),
    .config_wdata   ( config_wdata ),
    .config_rdata   ( config_rdata ),

    .rmst_ctrl_fixed_location   ( rmst_ctrl_fixed_location[VW+1:0]      ),
    .rmst_ctrl_read_base        ( rmst_ctrl_read_base[(VW+2)*32-1:0]    ),
    .rmst_ctrl_read_length      ( rmst_ctrl_read_length[(VW+2)*32-1:0]  ),
    .rmst_ctrl_go               ( rmst_ctrl_go[VW+1:0]                  ),
    .rmst_ctrl_done             ( rmst_ctrl_done[VW+1:0]                ),
    .rmst_user_read_buffer      ( rmst_user_read_buffer[VW+1:0]         ),
    .rmst_user_buffer_data      ( rmst_user_buffer_data[(VW+2)*128-1:0] ),
    .rmst_user_data_available   ( rmst_user_data_available[VW+1:0]      ),
    
    .wmst_ctrl_fixed_location   ( wmst_ctrl_fixed_location[0]       ),
    .wmst_ctrl_write_base       ( wmst_ctrl_write_base[1*32-1:0]    ),
    .wmst_ctrl_write_length     ( wmst_ctrl_write_length[1*32-1:0]  ),
    .wmst_ctrl_go               ( wmst_ctrl_go[0]                   ),
    .wmst_ctrl_done             ( wmst_ctrl_done[0]                 ),
    .wmst_user_write_buffer     ( wmst_user_write_buffer[0]         ),
    .wmst_user_write_input_data ( wmst_user_write_input_data[1*128-1:0] ),
    .wmst_user_buffer_full      ( wmst_user_buffer_full[0]          ),

    .clk( clk ),
    .rst( rst )
);

mem_top #(
    .R_PORT ( R_PORT ),
    .W_PORT ( W_PORT )
) MEM (
    .read_control_fixed_location   ( rmst_ctrl_fixed_location  ),   //    read_0_control.fixed_location
    .read_control_read_base        ( rmst_ctrl_read_base       ),        //                  .read_base
    .read_control_read_length      ( rmst_ctrl_read_length     ),      //                  .read_length
    .read_control_go               ( rmst_ctrl_go              ),               //                  .go
    .read_control_done             ( rmst_ctrl_done            ),             //                  .done
    .read_user_read_buffer         ( rmst_user_read_buffer      ),         //       read_0_user.read_buffer
    .read_user_buffer_output_data  ( rmst_user_buffer_data      ),  //                  .buffer_output_data
    .read_user_data_available      ( rmst_user_data_available   ),      //                  .data_available

    .write_control_fixed_location  ( wmst_ctrl_fixed_location ),  //   write_0_control.fixed_location
    .write_control_write_base      ( wmst_ctrl_write_base     ),      //                  .write_base
    .write_control_write_length    ( wmst_ctrl_write_length   ),    //                  .write_length
    .write_control_go              ( wmst_ctrl_go             ),              //                  .go
    .write_control_done            ( wmst_ctrl_done           ),            //                  .done
    .write_user_write_buffer       ( wmst_user_write_buffer     ),       //      write_0_user.write_buffer
    .write_user_buffer_input_data  ( wmst_user_write_input_data ),  //                  .buffer_input_data
    .write_user_buffer_full        ( wmst_user_buffer_full       ),// 
    
    .clk( clk ),
    .rst( rst )
);
endmodule
