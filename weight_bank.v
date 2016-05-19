/*
* Created           : cheng liu
* Date              : 2016-05-16
*
* Description:
* 
* One bank of weight, and it contains Tm/X kernel weight coefficients.
* 
* Instance example
weight_bank #(
    .AW (), 
    .DW (),
    .Tm (),
    .Tn (),
    .K (),
    .X ()
    .Y () 
) weight_bank_inst (
    .rd_data (),
    .rd_addr (),

    .wr_data (),
    .wr_ena (),

    .clk (),
    .rst ()
);

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module weight_bank #(
    parameter AW = 10,  // input_fm bank address width
    parameter DW = 32,  // data width
    parameter Tn = 16,  // output_fm tile size of output channel
    parameter Tm = 16,  // input_fm tile size of input channel
    parameter K = 3,    // kernel parameter
    parameter X = 4,    // # of input_fm bank
    parameter Y = 4     // # of output_fm bank
)(
    output                   [DW-1: 0] rd_data,
    input                    [AW-1: 0] rd_addr,

    input                    [DW-1: 0] wr_data,
    input                              wr_ena,

    input                              clk,
    input                              rst
);
    localparam bank_capacity = (Tn/Y) * (Tm/X) * K * K; // # of words

    reg                     [AW-1: 0] wr_addr;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            wr_addr <= 0;
        end
        else if(wr_ena == 1'b1) begin
            wr_addr <= wr_addr + 1;
        end
        else if(wr_addr == bank_capacity - 1) begin
            wr_addr <= 0;
        end
    end

    // weight Bank
    altsyncram	altsyncram_component (
				.address_a (wraddress),
				.address_b (rdaddress),
				.clock0 (clk),
				.data_a (data),
				.wren_a (wren),
				.q_b (sub_wire0),
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
