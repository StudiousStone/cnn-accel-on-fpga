#!/bin/bash -f
xv_path="/software/Vivado/2015.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 3d6f71657dcc4e3d97ab1fcab5ec0706 -m64 --debug typical --relax --mt 8 -L blk_mem_gen_v8_3_1 -L axi_bram_ctrl_v4_0_6 -L xil_defaultlib -L lib_pkg_v1_0_2 -L lib_srl_fifo_v1_0_2 -L fifo_generator_v13_0_1 -L lib_fifo_v1_0_4 -L lib_cdc_v1_0_2 -L axi_datamover_v5_1_9 -L axi_sg_v4_1_2 -L axi_cdma_v4_1_7 -L proc_sys_reset_v5_0_8 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_7 -L axi_data_fifo_v2_1_6 -L axi_crossbar_v2_1_8 -L unisims_ver -L unimacro_ver -L secureip --snapshot CDMA_tb_behav xil_defaultlib.CDMA_tb xil_defaultlib.glbl -log elaborate.log
