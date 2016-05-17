	avlon_MM_slave u0 (
		.clk                    (<connected-to-clk>),                    //       clk.clk
		.reset                  (<connected-to-reset>),                  // clk_reset.reset
		.avs_writedata          (<connected-to-avs_writedata>),          //        s0.writedata
		.avs_beginbursttransfer (<connected-to-avs_beginbursttransfer>), //          .beginbursttransfer
		.avs_burstcount         (<connected-to-avs_burstcount>),         //          .burstcount
		.avs_readdata           (<connected-to-avs_readdata>),           //          .readdata
		.avs_address            (<connected-to-avs_address>),            //          .address
		.avs_waitrequest        (<connected-to-avs_waitrequest>),        //          .waitrequest
		.avs_write              (<connected-to-avs_write>),              //          .write
		.avs_read               (<connected-to-avs_read>),               //          .read
		.avs_readdatavalid      (<connected-to-avs_readdatavalid>)       //          .readdatavalid
	);

