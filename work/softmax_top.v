/*
* Created           : cheng liu
* Date              : 20160418
*
* Description:
*
* Add Avlon master read/write port as well as internal simple dual port memory
*
*/

softmax_top #(
    parameter AW = 12,
    parameter DW = 12,
    parameter DATA_SIZE = 128,
    parameter NORM_DELAY = 14,
    parameter EXP_DELAY = 17,
    parameter ACC_DELAY = 9,
    parameter DIV_DELAY = 14,
    parameter CW = 6
)(
    // Avlon port
    // Port connected to the read master
    output                             rmst_fixed_location,
    output                   [XAW-1:0] rmst_read_base,
    output                   [XAW-1:0] rmst_read_length,
    output                             rmst_go,
    input                              rmst_done,

    output                             rmst_user_read_buffer,
    input                    [XDW-1:0] rmst_user_buffer_data,
    input                              rmst_user_data_available, 

    // Port connected to the write master
    output                             wmst_fixed_location,
    output                  [XAW-1: 0] wmst_write_base,
    output                  [XAW-1: 0] wmst_write_length,
    output                             wmst_go,
    input                              wmst_done,
    output                  [XDW-1: 0] wmst_user_write_data,
    output                             wmst_user_write_buffer,
    input                              wmst_user_buffer_full,

    // Control signals
    input                              softmax_start,
    input                              softmax_done,

    // Configuration interface to be connected as Avlon Slave
    input                             config_ena,
    input                   [CW-1: 0] config_addr,
    input                   [DW-1: 0] config_wdata,
    output                  [DW-1: 0] config_rdata,

    // System signal
    input                              clk,
    input                              rst

);

    wire                               config_done;
    wire                               softmax_core_done;
    wire                     [DW-1: 0] param_raddr;
    wire                     [DW-1: 0] param_waddr;
    wire                     [DW-1: 0] param_iolen;

    softmax_config #(
        .AW (AW),  // Internal memory address width
        .DW (DW),  // Internal data width
        .CW (CW)    // maxium number of configuration paramters is (2^CW).
    )softmax_config (
        .config_ena (config_ena),
        .config_addr (config_addr),
        .config_wdata (config_wdata),
        .config_rdata (config_rdata),
    
        .config_done (config_done),       // configuration is done. (orginal name: param_ena)
        .param_raddr (param_raddr),
        .param_waddr (param_waddr),
        .param_iolen (param_iolen),
        .softmax_core_done (softmax_core_done), // computing task is done. (original name: flag_over)
    
        .clk (clk),
        .rst (rst)
    );

    assign load_data_start = config_done;
    softmax_dp_mem #(
        .AW (AW),
        .DW (DW),
        .XAW (XAW),
        .XDW (XDW)

    )(
        // Port connected to the read master
        .rmst_fixed_location (rmst_fixed_location),
        .rmst_read_base (rmst_read_base),
        .rmst_read_length (rmst_read_length),
        .rmst_go (rmst_go),
        .rmst_done (rmst_done),

        .rmst_user_read_buffer (rmst_user_read_buffer),
        .rmst_user_buffer_data (rmst_user_buffer_data),
        .rmst_user_data_available (rmst_user_data_available), 

        // Port connected to the write master
        .wmst_fixed_location (wmst_fixed_location),
        .wmst_write_base (wmst_write_base),
        .wmst_write_length (wmst_write_length),
        .wmst_go (wmst_go),
        .wmst_done (wmst_done),
        .wmst_user_write_data (wmst_user_write_data),
        .wmst_user_write_buffer (wmst_user_write_buffer),
        .wmst_user_buffer_full (wmst_user_buffer_full),

        // Parameters from the configuration module
        .param_raddr (param_raddr),
        .param_iolen (param_iolen),
        .param_waddr (param_waddr),

        .load_data_done (load_data_done),
        .store_data_done (store_data_done),

        // Internal memomry port to the softmax_core
        .internal_wr_addr (internal_wr_addr),
        .internal_wr_data (internal_wr_data),
        .internal_wr_ena (internal_wr_ena),

        .internal_rd_addr (internal_rd_addr),
        .internal_rd_data (internal_rd_data),

        .store_data_start (store_data_start),
        .load_data_start (load_data_start),

        .rst (rst),
        .clk (clk)
    );
    assign softmax_done = store_data_done;

    assign softmax_core_start = load_data_done;
    assign store_data_start = softmax_core_done;
    softmax_core #(
        .AW (AW),
        .DW (DW),
        .DATA_SIZE (DATA_SIZE),
        .NORM_DELAY (NORM_DELAY),
        .EXP_DELAY (EXP_DELAY),
        .ACC_DELAY (ACC_DELAY),
        .DIV_DELAY (DIV_DELAY)
    ) softmax_core (
        // port connected with input memory
        .data_in (internal_rd_data),
        .rd_addr (internal_rd_addr),

        // port connected with output memory
        .wr_ena (internal_wr_ena),
        .wr_addr (internal_wr_addr),
        .data_out (internal_wr_data),

        // softmax_core control signals
        .softmax_core_start (softmax_core_start), 
        .softmax_core_done (softmax_core_done),

        .downstream_ready (1'b1),

        // global signals
        .clk (clk),
        .rst (rst)
    );

endmodule
