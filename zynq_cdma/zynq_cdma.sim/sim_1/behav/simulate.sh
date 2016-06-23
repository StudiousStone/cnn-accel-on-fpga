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
ExecStep $xv_path/bin/xsim CDMA_tb_behav -key {Behavioral:sim_1:Functional:CDMA_tb} -tclbatch CDMA_tb.tcl -view /home/liucheng/projects/backup/zynq_cdma/CDMA_tb_behav.wcfg -log simulate.log
