
vsim -novopt -L altera_mf_ver -L altera_primitives_ver -L cyclonev_atoms_ver -L model_220_ver -t ns work.mv_tb

add wave sim:/mv_tb/*
add wave sim:/mv_tb/CFG/*
add wave sim:/mv_tb/MV/*
add wave sim:/mv_tb/MV/BIAS/*
add wave sim:/mv_tb/MV/VECTOR/*
add wave {sim:/mv_tb/MV/M1[0]/WEIGHT/*}
add wave {sim:/mv_tb/MV/M1[1]/WEIGHT/*}
add wave {sim:/mv_tb/MV/M1[2]/WEIGHT/*}
add wave {sim:/mv_tb/MV/M1[3]/WEIGHT/*}
add wave {sim:/mv_tb/MV/M2[0]/FMA/*}
add wave {sim:/mv_tb/MV/M2[1]/FMA/*}
add wave {sim:/mv_tb/MV/M2[2]/FMA/*}
add wave {sim:/mv_tb/MV/M2[3]/FMA/*}

add wave sim:/mv_tb/MEM/*
add wave {sim:/mv_tb/MEM/M1[0]/WMST/*}
add wave {sim:/mv_tb/MEM/M1[1]/WMST/*}
add wave {sim:/mv_tb/MEM/M0[0]/RMST/*}
add wave {sim:/mv_tb/MEM/M0[1]/RMST/*}
add wave {sim:/mv_tb/MEM/M0[2]/RMST/*}
add wave {sim:/mv_tb/MEM/M0[3]/RMST/*}
add wave {sim:/mv_tb/MEM/M0[4]/RMST/*}
add wave {sim:/mv_tb/MEM/M0[5]/RMST/*}

run -all