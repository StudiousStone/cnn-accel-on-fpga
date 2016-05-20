/*
* Created           : cheng liu
* Date              : 2016-05-18
*
* Description:
* 
* One bank of out_fm, and it accommodates a few output feacture maps of different channels.
* As both the read and write operations happen sequentially, the addresses are generated automatically. 
* Instance example
module output_fm_bank #(
    .AW (), 
    .DW (),
    .Tn (),
    .Tr (),
    .Tc (),
    .Y () 
) output_fm_bank_inst (
    .rd_data (),
    .rd_addr (),
    .rd_ena (),
    .wr_data (),
    .wr_addr (),
    .wr_ena (),

    .inter_rd_data (),
    .inter_rd_addr (),
    .inter_wr_data (),
    .inter_wr_addr (),
    .inter_wr_ena (),

    .ld_out_fm_start (),
    .ld_out_fm_done (),
    .st_out_fm_start (),
    .st_out_fm_done (),

    .clk (),
    .rst ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module output_fm_bank #(
    parameter AW = 16,  // input_fm bank address width
    parameter DW = 32,  // data width
    parameter Tn = 16,  // output_fm tile size of input channel
    parameter Tr = 64,  // output_fm tile size of row
    parameter Tc = 16,  // output_fm tile size of col
    parameter Y = 4     // # of out_fm bank
)(
    // port to out memory
    input                    [DW-1: 0] wr_data,
    input                              wr_ena,

    output                   [AW-1: 0] rd_data,
    input                              rd_ena,

    // port to internal computing logic
    output                   [DW-1: 0] inter_rd_data,
    input                    [AW-1: 0] inter_rd_addr,

    input                    [DW-1: 0] inter_wr_data,
    input                    [AW-1: 0] inter_wr_addr,
    input                              inter_wr_ena,

    // Control status
    input                              ld_out_fm_start,
    input                              ld_out_fm_done,
    input                              st_out_fm_start,
    input                              st_out_fm_done,

    input                              clk,
    input                              rst
);
    localparam bank_capacity = (Tn/Y) * Tr * Tc; // # of words

    reg                                computing_on_going;
    reg                      [DW-1: 0] wr_data_reg;
    wire                     [AW-1: 0] wr_addr;
    reg                                wr_ena_reg;
    wire                     [AW-1: 0] rd_addr;

    always @(posedge clk) begin
        wr_ena_reg <= wr_ena;
        wr_data_reg <= wr_data;
    end

    counter #(
        .CW (AW),
        .MAX (bank_capacity)
    ) ld_counter (
        .ena (wr_ena),
        .cnt (wr_addr),
        .done (),

        .clk (clk),
        .rst (rst)
    );

    counter #(
        .CW (AW),
        .MAX (bank_capacity)
    ) st_counter (
        .ena (rd_ena),
        .cnt (rd_addr),
        .done (),

        .clk (clk),
        .rst (rst)
    );

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            computing_on_going <= 1'b0;
        end
        else if(ld_out_fm_start == 1'b1 || st_out_fm_start == 1'b1) begin
            computing_on_going <= 1'b0;
        end
        else if(ld_out_fm_done == 1'b1 || st_out_fm_done == 1'b1) begin
            computing_on_going <= 1'b1;
        end
    end

    assign wraddress = computing_on_going ? inter_wr_addr : wr_addr;
    assign data = computing_on_going ? inter_wr_data : wr_data_reg;
    assign wren = computing_on_going ? inter_wr_ena : wr_ena_reg;
    assign rdaddress = computing_on_going ? inter_rd_addr : rd_addr;
    assign inter_rd_data = q;
    assign rd_data = q;

    // output_fm Bank
    altsyncram	altsyncram_component (
				.address_a (wraddress),
				.address_b (rdaddress),
				.clock0 (clk),
				.data_a (data),
				.wren_a (wren),
				.q_b (q),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b ({32{1'b1}}),
				.eccstatus (),
				.q_a (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
    defparam
		altsyncram_component.address_aclr_b = "NONE",
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.intended_device_family = "Cyclone V",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = bank_capacity,
		altsyncram_component.numwords_b = bank_capacity,
		altsyncram_component.operation_mode = "DUAL_PORT",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_b = "CLOCK0",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_mixed_ports = "OLD_DATA",
		altsyncram_component.widthad_a = AW,
		altsyncram_component.widthad_b = AW,
		altsyncram_component.width_a = 32,
		altsyncram_component.width_b = 32,
		altsyncram_component.width_byteena_a = 1;

endmodule
