onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/clk
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/data_sampled
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/data_in
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/rst_n
add wave -noupdate -expand -group {FIFO - DUT} -color Firebrick /top/dut/fifo_intf/wr_en
add wave -noupdate -expand -group {FIFO - DUT} -color Gold /top/dut/fifo_intf/rd_en
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/data_out
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/wr_ack
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/overflow
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/full
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/empty
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/almostfull
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/almostempty
add wave -noupdate -expand -group {FIFO - DUT} /top/dut/fifo_intf/underflow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {2210 ns} 0} {{Cursor 3} {2409 ns} 0} {{Cursor 4} {2010 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {2458 ns}
