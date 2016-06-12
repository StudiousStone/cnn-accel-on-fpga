/*
* Created           : cheng liu
* Date              : 2016-04-26
*
* Description:
* 
* Verify the read master port and write master port 
* 
* 
*/

`timescale 1ns/1ns

module avlon_tb;

parameter CLK_PERIOD = 10;
parameter DATA_SIZE = 1024;
parameter TILE_SIZE = 128;
parameter R_PORT = 1;
parameter W_PORT = 1;

localparam AW = 12;
localparam DW = 32;
localparam CW = 8;
localparam RES = 24;
localparam XAW = 32;
localparam XDW = 128;
localparam WCNT =(XDW/DW);

wire  [R_PORT-1:0]        rmst_fixed_location;   // fixed_location
wire  [R_PORT*XAW-1:0]    rmst_read_base;        // read_base
wire  [R_PORT*XAW-1:0]    rmst_read_length;      // read_length
wire  [R_PORT*CW-1: 0]    rmst_read_length_tmp;
wire  [R_PORT-1:0]        rmst_go;               // go
wire  [R_PORT-1:0]        rmst_done;             // done
wire  [R_PORT-1:0]        rmst_user_read_buffer;      // read_buffer
wire  [R_PORT*128-1:0]    rmst_user_buffer_data;      // buffer_output_data
wire  [R_PORT-1:0]        rmst_user_data_available;   // data_available

wire  [W_PORT-1:0]        wmst_fixed_location;   // fixed_location
wire  [W_PORT*XAW-1:0]    wmst_write_base;       // write_base
wire  [W_PORT*XAW-1:0]    wmst_write_length;     // write_length
wire  [W_PORT*CW-1: 0]    wmst_write_length_tmp;
wire  [W_PORT-1:0]        wmst_go;               // go
wire  [W_PORT-1:0]        wmst_done;             // done
wire  [W_PORT-1:0]        wmst_user_write_buffer;// write_buffer
wire  [W_PORT*128-1:0]    wmst_user_write_data;  // buffer_input_data
wire  [W_PORT-1:0]        wmst_user_buffer_full;      

reg                       config_start;
wire                      config_done;

wire            [DW-1: 0] param_raddr;
wire            [DW-1: 0] param_waddr;
wire            [AW-1: 0] param_iolen;

wire                      load_data_start;
wire                      load_data_done;
wire                      store_data_start;
wire                      store_data_done;

wire                      fifo_push;
wire            [DW-1: 0] rmst_data_in;
wire                      fifo_almost_full;

wire                      fifo_empty;
wire                      fifo_pop;
wire            [DW-1: 0] wmst_data_out;

reg         clk = 0;
reg         rst = 0;
wire        task_done;

always # (CLK_PERIOD / 2) clk = ~clk;

initial begin
    rst = 1;
    config_start <= 1'b0;

    repeat (5) begin
        @(posedge clk);
    end
    rst = 0; 

    @(posedge clk)
    config_start <= 1'b1;

    @(posedge clk)
    config_start <= 1'b0;

end

transfer_config #(
    .AW (AW),  // Internal memory address width
    .DW (DW),  // Internal data width
    .CW (CW),  // maxium number of configuration paramters is (2^CW).
    .DATA_SIZE (DATA_SIZE)
)transfer_config(
    .config_start (config_start),
    .config_done  (config_done), 

    .param_raddr  (param_raddr),
    .param_waddr  (param_waddr),
    .param_iolen  (param_iolen),

    .task_done    (task_done), // computing task is done. (original name: flag_over)
    .store_data_done (store_data_done),
    
    .rst          (rst),
    .clk          (clk)
);


sig_delay #(
    .D (10)
) sig_delay0 (
    .sig_in (config_done),
    .sig_out (load_data_start),

    .clk (clk),
    .rst (rst)
);


sig_delay #(
    .D (10)
) sig_delay (
    .sig_in (load_data_start),
    .sig_out (store_data_start),

    .clk (clk),
    .rst (rst)
);

rmst_to_fifo_tile #(
    .AW (AW),
    .CW (CW),
    .DW (DW),
    .XAW (XAW),
    .XDW (XDW)
) rmst_in_fm (
    .param_raddr           (param_raddr),
    .param_iolen           (param_iolen),
    .config_done           (config_done),

    .rmst_fixed_location   (rmst_fixed_location),
    .rmst_read_base        (rmst_read_base),
    .rmst_read_length      (rmst_read_length_tmp),
    .rmst_go               (rmst_go),
    .rmst_done             (rmst_done),

    .rmst_user_read_buffer (rmst_user_read_buffer),
    .rmst_user_buffer_data (rmst_user_buffer_data),
    .rmst_user_data_available (rmst_user_data_available),

    .rmst_data_in             (rmst_data_in),
    .fifo_push                (fifo_push),
    .fifo_almost_full         (fifo_almost_full),

    .load_data_done           (load_data_done),
    .load_data_start          (load_data_start),

    .clk                   (clk),
    .rst                   (rst)
);

wmst_to_fifo_tile #(
    .AW (AW),
    .CW (CW),
    .DW (DW),
    .XAW (XAW),
    .XDW (XDW)
) wmst_out_fm (
    .param_waddr           (param_waddr),
    .param_iolen           (param_iolen),
    .config_done           (config_done),
    
    .wmst_fixed_location   (wmst_fixed_location),
    .wmst_write_base       (wmst_write_base),
    .wmst_write_length     (wmst_write_length_tmp),
    .wmst_go               (wmst_go),
    .wmst_done             (wmst_done),

    .wmst_user_write_buffer(wmst_user_write_buffer),
    .wmst_user_write_data  (wmst_user_write_data),
    .wmst_user_buffer_full (wmst_user_buffer_full),

    .store_data_done       (store_data_done),
    .store_data_start      (store_data_start),

    .fifo_pop              (fifo_pop),
    .fifo_empty            (fifo_empty),
    .wmst_data_out         (wmst_data_out),
    
    .clk                   (clk),
    .rst                   (rst)
);

assign rmst_read_length = {24'b0, rmst_read_length_tmp};
assign wmst_write_length = {24'b0, wmst_write_length_tmp};

mem_top #(
    .R_PORT (R_PORT),
    .W_PORT (W_PORT)
) mem_model(
    .read_control_fixed_location  (rmst_fixed_location),
    .read_control_read_base       (rmst_read_base),
    .read_control_read_length     (rmst_read_length),
    .read_control_go              (rmst_go), 
    .read_control_done            (rmst_done), 
    .read_user_read_buffer        (rmst_user_read_buffer),
    .read_user_buffer_output_data (rmst_user_buffer_data),
    .read_user_data_available     (rmst_user_data_available),

    .write_control_fixed_location (wmst_fixed_location),
    .write_control_write_base     (wmst_write_base),
    .write_control_write_length   (wmst_write_length),
    .write_control_go             (wmst_go),
    .write_control_done           (wmst_done), 
    .write_user_write_buffer      (wmst_user_write_buffer),
    .write_user_buffer_input_data (wmst_user_write_data),
    .write_user_buffer_full       (wmst_user_buffer_full), 
    
    .clk (clk),
    .rst (rst)
);

scfifo	SCFF (
    .aclr           (rst),
    .clock          (clk),
    .data           (rmst_data_in),
    .rdreq          (fifo_pop),
    .sclr           (1'b0),
    .wrreq          (fifo_push),
    .almost_empty   (),
    .almost_full    (fifo_almost_full),
    .empty          (fifo_empty),
    .full           (),
    .q              (wmst_data_out),
    .usedw          (),
    .eccstatus ());
defparam
    SCFF.add_ram_output_register = "OFF",
    SCFF.almost_empty_value = 8,
    SCFF.almost_full_value = 250,
    SCFF.intended_device_family = "Cyclone V",
    SCFF.lpm_hint = "RAM_BLOCK_TYPE=M10K",
    SCFF.lpm_numwords = 256,
    SCFF.lpm_showahead = "OFF",
    SCFF.lpm_type = "scfifo",
    SCFF.lpm_width = 32,
    SCFF.lpm_widthu = 8,
    SCFF.overflow_checking = "ON",
    SCFF.underflow_checking = "ON",
    SCFF.use_eab = "ON";

endmodule
