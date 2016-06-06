onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /conv_top_tb/conv_tile/conv_tile_start
add wave -noupdate /conv_top_tb/conv_tile/conv_tile_done
add wave -noupdate -color {Medium Orchid} -radix unsigned /conv_top_tb/conv_tile/in_fm_rd_addr
add wave -noupdate /conv_top_tb/conv_tile/in_fm_rd_data
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/weight_rd_addr
add wave -noupdate /conv_top_tb/conv_tile/weight_rd_data
add wave -noupdate -color Magenta -radix unsigned /conv_top_tb/conv_tile/out_fm_wr_addr
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/out_fm_rd_addr
add wave -noupdate -radix hexadecimal /conv_top_tb/conv_tile/out_fm_rd_data
add wave -noupdate -color Magenta -radix hexadecimal /conv_top_tb/conv_tile/out_fm_wr_data
add wave -noupdate /conv_top_tb/conv_tile/out_fm_wr_ena
add wave -noupdate /conv_top_tb/timer
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/tile_base_n
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/tile_base_m
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/tile_base_col
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/tile_base_row
add wave -noupdate /conv_top_tb/conv_tile/clk
add wave -noupdate /conv_top_tb/conv_tile/rst
add wave -noupdate /conv_top_tb/conv_tile/in_fm_load_start
add wave -noupdate /conv_top_tb/conv_tile/weight_load_start
add wave -noupdate /conv_top_tb/conv_tile/out_fm_load_start
add wave -noupdate /conv_top_tb/conv_tile/conv_tile_computing_start
add wave -noupdate /conv_top_tb/conv_tile/conv_tile_computing_done
add wave -noupdate /conv_top_tb/conv_tile/conv_store_to_fifo_start
add wave -noupdate /conv_top_tb/conv_tile/conv_store_to_fifo_done
add wave -noupdate /conv_top_tb/conv_tile/in_fm_fifo_data_from_mem
add wave -noupdate /conv_top_tb/conv_tile/weight_fifo_data_from_mem
add wave -noupdate /conv_top_tb/conv_tile/out_fm_ld_fifo_data_from_mem
add wave -noupdate /conv_top_tb/conv_tile/out_fm_st_fifo_data_to_mem
add wave -noupdate /conv_top_tb/conv_tile/in_fm_fifo_push
add wave -noupdate /conv_top_tb/conv_tile/in_fm_fifo_almost_full
add wave -noupdate /conv_top_tb/conv_tile/weight_fifo_push
add wave -noupdate /conv_top_tb/conv_tile/weight_fifo_almost_full
add wave -noupdate /conv_top_tb/conv_tile/out_fm_ld_fifo_push
add wave -noupdate /conv_top_tb/conv_tile/out_fm_ld_fifo_almost_full
add wave -noupdate /conv_top_tb/conv_tile/out_fm_st_fifo_pop
add wave -noupdate /conv_top_tb/conv_tile/out_fm_st_fifo_empty
add wave -noupdate /conv_top_tb/conv_tile/conv_tile_store_start
add wave -noupdate /conv_top_tb/conv_tile/conv_tile_store_done
add wave -noupdate /conv_top_tb/conv_tile/conv_tile_clean
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_start
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_tile_clean
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_computing_start
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_computing_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_store_to_fifo_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_store_to_fifo_start
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_load_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_fifo_data_from_mem
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_fifo_push
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_fifo_almost_full
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_fifo_data_from_mem
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_fifo_push
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_fifo_almost_full
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_ld_fifo_data_from_mem
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_ld_fifo_push
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_ld_fifo_almost_full
add wave -noupdate -color Magenta /conv_top_tb/conv_tile/conv_core/out_fm_st_fifo_data_to_mem
add wave -noupdate -color Magenta /conv_top_tb/conv_tile/conv_core/out_fm_st_fifo_pop
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_st_fifo_empty
add wave -noupdate /conv_top_tb/conv_tile/conv_core/clk
add wave -noupdate /conv_top_tb/conv_tile/conv_core/rst
add wave -noupdate /conv_top_tb/conv_tile/conv_core/kernel_start
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_rd_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_wr_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_rd_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_rd_data0
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_rd_addr0
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_rd_data1
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_rd_addr1
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_rd_data2
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_rd_addr2
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_rd_data3
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_rd_addr3
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data00
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr00
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data01
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr01
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data02
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr02
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data03
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr03
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data10
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr10
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data11
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr11
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data12
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr12
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data13
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr13
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_fifo_data
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_fifo_data
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_ld_fifo_data
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_st_fifo_data
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data20
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr20
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data21
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr21
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data22
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr22
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data23
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr23
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data30
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr30
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data31
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr31
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data32
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr32
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_data33
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_rd_addr33
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_wr_addr0
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_wr_ena0
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_rd_addr0
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_rd_data0
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_wr_addr1
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_wr_ena1
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_rd_addr1
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_rd_data1
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_wr_addr2
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_wr_ena2
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_rd_addr2
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_rd_data2
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_wr_addr3
add wave -noupdate -color Gold /conv_top_tb/conv_tile/conv_core/out_fm_wr_data0
add wave -noupdate -color Gold /conv_top_tb/conv_tile/conv_core/out_fm_wr_data1
add wave -noupdate -color Gold /conv_top_tb/conv_tile/conv_core/out_fm_wr_data2
add wave -noupdate -color Gold /conv_top_tb/conv_tile/conv_core/out_fm_wr_data3
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_wr_ena3
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_rd_addr3
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_rd_data3
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_wr_ena
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_load_start
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_load_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_load_start
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_load_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_load_start
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_load_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_store_start
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_store_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_fifo_empty
add wave -noupdate /conv_top_tb/conv_tile/conv_core/in_fm_fifo_pop
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_fifo_empty
add wave -noupdate /conv_top_tb/conv_tile/conv_core/weight_fifo_pop
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_ld_fifo_empty
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_ld_fifo_pop
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_st_fifo_almost_full
add wave -noupdate /conv_top_tb/conv_tile/conv_core/out_fm_st_fifo_push
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wr_data
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wr_ena
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/rd_data
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/rd_ena
add wave -noupdate -color Violet /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/inter_rd_data
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/inter_rd_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/inter_wr_data
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/inter_wr_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/inter_wr_ena
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/conv_tile_clean
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/computing_on_going
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/clk
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/rst
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wr_data_reg
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wr_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wr_ena_reg
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/rd_addr
add wave -noupdate -color Magenta /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/q
add wave -noupdate -color Magenta -radix unsigned /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/rdaddress
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wraddress
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wren
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/data
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/conv_computing_start
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/conv_on_going_tmp
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/conv_on_going
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/row_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/conv_computing_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/kernel_start
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/conv_tile_clean
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/in_fm_rd_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/weight_rd_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/out_fm_wr_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/out_fm_wr_ena
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/clk
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/rst
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/conv_computing_start_reg
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/conv_computing_start_edge
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/kernel_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/slice_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/block_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/out_fm_rd_ena
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/out_slice_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/out_block_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/out_row_done
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/row
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/col
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/i
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/j
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/slice_id
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/block_id
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/out_block_id
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wr_data
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wr_ena
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/rd_data
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/rd_ena
add wave -noupdate -radix hexadecimal /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/inter_rd_data
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/conv_core/conv_ctrl_path_inst/out_fm_rd_addr
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/inter_rd_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/inter_wr_data
add wave -noupdate -radix unsigned /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/inter_wr_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/inter_wr_ena
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/conv_tile_clean
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/computing_on_going
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/clk
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/rst
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wr_data_reg
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wr_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wr_ena_reg
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/rd_addr
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/q
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wraddress
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/rdaddress
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/wren
add wave -noupdate /conv_top_tb/conv_tile/conv_core/output_fm/output_fm_bank0/data
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/in_fm_data0
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/in_fm_data1
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/in_fm_data2
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/in_fm_data3
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/weight0
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/weight1
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/weight2
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/weight3
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/kernel_start
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/clk
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/rst
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/mul0_result
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/mul1_result
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/mul2_result
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/mul3_result
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/fpadd_L0_0_result
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/fpadd_L0_1_result
add wave -noupdate /conv_top_tb/conv_tile/conv_core/conv_data_path0/out_fm_wr_data
add wave -noupdate -color Magenta /conv_top_tb/conv_tile/conv_core/conv_data_path0/out_fm_rd_data
add wave -noupdate -color Magenta /conv_top_tb/conv_tile/conv_core/conv_data_path0/fpacc_result
add wave -noupdate -color Magenta /conv_top_tb/conv_tile/conv_core/conv_data_path0/fpadd_top_result
add wave -noupdate -color Magenta /conv_top_tb/conv_tile/conv_core/conv_data_path0/fpacc_pulse
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {660975000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 83
configure wave -valuecolwidth 105
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {660937852 ps} {661335732 ps}
