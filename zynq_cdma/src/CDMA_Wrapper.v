/*
* Created           : cheng liu
* Date              : 2016-06-23
* Email             : st.liucheng@gmail.com
*
* Description:
* The module is used to pack the CDMA core to allow user logic 
* doing multiple DMA transfers for a 3D data block. This could be 
* further optimized by enabling the SG functionality of the CDMA core.
* 
*/

`timescale 1 ns / 1 ps

	module CDMA_Wrapper #(
		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 6,
        // Width of the data transfer length
        parameter TRANS_WIDTH = 16
	)(
		// Users to add ports here
        input [C_S_AXI_DATA_WIDTH-1 : 0] src_addr,
        input [C_S_AXI_DATA_WIDTH-1 : 0] dst_addr,
        input [TRANS_WIDTH-1: 0]         trans_len,
        input                            CDMA_start,
        output                           CDMA_done,

        // to AXI Lite 
        output [5:0]                     S_AXI_LITE_araddr,
        output                           S_AXI_LITE_arvalid,
        input                            S_AXI_LITE_arready,

        output [5:0]                     S_AXI_LITE_awaddr,
        input                            S_AXI_LITE_awready,
        output                           S_AXI_LITE_awvalid,

        output                           S_AXI_LITE_bready,
        input [1:0]                      S_AXI_LITE_bresp,
        input                            S_AXI_LITE_bvalid,

        input [31:0]                     S_AXI_LITE_rdata,
        output                           S_AXI_LITE_rready,
        input [1:0]                      S_AXI_LITE_rresp,
        input                            S_AXI_LITE_rvalid,

        output [31:0]                    S_AXI_LITE_wdata,
        input                            S_AXI_LITE_wready,
        output                           S_AXI_LITE_wvalid,

		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
		input wire [2 : 0]                    S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
		input wire                            S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
		output wire                           S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
        // data and strobes are available.
		input wire                                S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
        // can accept the write data.
		output wire                               S_AXI_WREADY,
		// Write response. This signal indicates the status
        // of the write transaction.
		output wire [1 : 0]                       S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
		output wire                               S_AXI_BVALID,
		// Response ready. This signal indicates that the master
        // can accept a write response.
		input wire                                S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
		input wire [2 : 0]                        S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
		input wire                                S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
		output wire                               S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0]    S_AXI_RDATA,
		// Read response. This signal indicates the status of the
        // read transfer.
		output wire [1 : 0]                       S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
        // signaling the required read data.
		output wire                               S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
        // accept the read data and response information.
		input wire                                S_AXI_RREADY
	);

	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;

	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
        if ( S_AXI_ARESETN == 1'b0 )begin
	      axi_awready <= 1'b0;
        end 
        else if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID) begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
            axi_awready <= 1'b1;
        end
        else begin
	          axi_awready <= 1'b0;
        end
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 
	always @( posedge S_AXI_ACLK )
	begin
        if ( S_AXI_ARESETN == 1'b0 )begin
	        axi_awaddr <= 0;
        end 
        else if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID) begin
        // Write Address latching 
            axi_awaddr <= S_AXI_AWADDR;
        end
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            axi_wready <= 1'b0;
	    end 
	    else if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID) begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
            axi_wready <= 1'b1;
        end
        else begin
            axi_wready <= 1'b0;
        end
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;
    
    
	always @( posedge S_AXI_ACLK )
	begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            usr_data_out1 <= 0;
            usr_data_out2 <= 0;
            usr_data_out3 <= 0;

	    end 
        else if (slv_reg_wren) begin 
            case ( axi_awaddr[C_S_AXI_ADDR_WIDTH-1 : ADDR_LSB] )
                5'h00: usr_data_out1 <= S_AXI_WDATA;
                5'h01: usr_data_out2 <= S_AXI_WDATA;
                5'h02: usr_data_out3 <= S_AXI_WDATA;


                5'h04: wmst_usr_wr_buf   <= S_AXI_WDATA[0]; 
                5'h05: wmst_usr_buf_data <= S_AXI_WDATA; 
                5'h06: wmst_wr_baddr     <= S_AXI_WDATA; 
                5'h07: wmst_wr_len       <= S_AXI_WDATA; 
                5'h08: wmst_ctrl_go      <= S_AXI_WDATA[0]; 

                5'h09: rmst_usr_rd_buf   <= S_AXI_WDATA[0]; 
                5'h0a: rmst_ctrl_go      <= S_AXI_WDATA[0]; 
                5'h0b: rmst_rd_baddr     <= S_AXI_WDATA; 
                5'h0c: rmst_rd_len       <= S_AXI_WDATA; 

                default: ;
            endcase
        end
        else begin
            wmst_usr_wr_buf <= 1'b0; 
            wmst_ctrl_go    <= 1'b0; 
            rmst_usr_rd_buf <= 1'b0; 
            rmst_ctrl_go    <= 1'b0;
        end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            axi_bvalid  <= 0;
            axi_bresp   <= 2'b0;
	    end 
        else if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
            // indicates a valid write response is available
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b0; // 'OKAY' response 
        end                     // work error responses in future
        else if (S_AXI_BREADY && axi_bvalid) begin
            //check if bready is asserted while bvalid is high) 
            //(there is a possibility that bready is always asserted high)   
            axi_bvalid <= 1'b0; 
        end  
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            axi_arready <= 1'b0;
            axi_araddr  <= 32'b0;
	    end 
        else if (~axi_arready && S_AXI_ARVALID) begin
            // indicates that the slave has acceped the valid read address
            axi_arready <= 1'b1;
            // Read address latching
            axi_araddr  <= S_AXI_ARADDR;
        end
        else begin
            axi_arready <= 1'b0;
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            axi_rvalid <= 0;
            axi_rresp  <= 0;
	    end 
        else if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
            // Valid read data is available at the read data bus
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b0; // 'OKAY' response
        end   
        else if (axi_rvalid && S_AXI_RREADY) begin
            // Read data is accepted by the master
            axi_rvalid <= 1'b0;
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
        // Address decoding for reading registers
        case ( axi_araddr[C_S_AXI_ADDR_WIDTH-1 : ADDR_LSB] )
            5'h00   : reg_data_out <= usr_data_in0;
            5'h01   : reg_data_out <= usr_data_in1;
            5'h02   : reg_data_out <= usr_data_in2;
            5'h03   : reg_data_out <= usr_data_in3;
            default : reg_data_out <= 0;
        endcase
    end

	// Output register or memory read data
    always @( posedge S_AXI_ACLK )
	begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            axi_rdata  <= 0;
        end 	  
        // When there is a valid read address (S_AXI_ARVALID) with 
        // acceptance of read address by the slave (axi_arready), 
        // output the read dada 
        else if (slv_reg_rden) begin
            axi_rdata <= reg_data_out;     // register read data
	    end
    end    

endmodule
