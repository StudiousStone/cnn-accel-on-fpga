/*
* Created           : cheng liu
* Date              : 2016-05-24
*
* Description:
* This is a simple dual port ram behavioural model.
* It allows both a read and a write operation in each cycle. Read data will be available 
* two cycles after the address is given. Write address, write data and write ena should 
* be alighed. Read and write conflict are not handled in the model. 
* 
* Instance example
dp_ram_bhm #(
    .AW (),
    .DW (),
    .NUM ()
) dp_ram_bhm_inst (
    .clock (),
    .data (),
    .rdaddress (),
    .wraddress (),
    .wren (),
    .q ()
);
*/

// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module dp_ram_bhm #(
    parameter AW = 16,
    parameter DW = 32,
    parameter DATA_SIZE = 1024
)(
    input                               clock,
    input                     [DW-1: 0] data,
    input                     [AW-1: 0] rdaddress,
    input                     [AW-1: 0] wraddress,
    input                               wren,
    output                    [DW-1: 0] q
);
	
    reg                       [DW-1: 0] ram [0: DATA_SIZE-1];
    reg                       [DW-1: 0] q_reg0;
    reg                       [DW-1: 0] q_reg1;
	
    always@(posedge clock) begin
        q_reg0 <= ram[rdaddress];
	q_reg1 <= q_reg0;
    end
    assign q = q_reg1;
	
    always@(posedge clock) begin
	if(wren == 1'b1) begin
	  ram[wraddress] <= data;
	end
    end

    initial begin
        $readmemh("init.txt", mem, 0, DATA_SIZE - 1);
        #80000
        $writememh("result.txt", mem, 0, DATA_SIZE - 1);
        $stop(2);
    end

endmodule
