onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mtc_ppa_tb/DUT/clk
add wave -noupdate /mtc_ppa_tb/DUT/reset_n
add wave -noupdate -expand -group req /mtc_ppa_tb/DUT/req_i
add wave -noupdate -expand -group req /mtc_ppa_tb/DUT/req_vld_i
add wave -noupdate -expand -group req /mtc_ppa_tb/DUT/req_rdy_o
add wave -noupdate -expand -group gnt /mtc_ppa_tb/DUT/gnt_o
add wave -noupdate -expand -group gnt /mtc_ppa_tb/DUT/gnt_vld_o
add wave -noupdate -expand -group gnt /mtc_ppa_tb/DUT/gnt_rdy_i
add wave -noupdate -expand /mtc_ppa_tb/DUT/hptr
add wave -noupdate /mtc_ppa_tb/DUT/hptr_next
add wave -noupdate /mtc_ppa_tb/DUT/hptr_vld
add wave -noupdate -expand /mtc_ppa_tb/DUT/gnt_out_mpeth_one
add wave -noupdate -expand /mtc_ppa_tb/DUT/gnt_out_mpeth_two
add wave -noupdate /mtc_ppa_tb/DUT/gnt_vld_out_mpeth_one
add wave -noupdate /mtc_ppa_tb/DUT/gnt_vld_out_mpeth_two
add wave -noupdate -expand /mtc_ppa_tb/DUT/gnt_out_mpe_mux
add wave -noupdate /mtc_ppa_tb/DUT/gnt_vld_mpe_mux
add wave -noupdate -group gnt_converter /mtc_ppa_tb/DUT/gnt_converter/clk
add wave -noupdate -group gnt_converter /mtc_ppa_tb/DUT/gnt_converter/reset_n
add wave -noupdate -group gnt_converter /mtc_ppa_tb/DUT/gnt_converter/in_gnt_i
add wave -noupdate -group gnt_converter /mtc_ppa_tb/DUT/gnt_converter/in_gnt_vld_i
add wave -noupdate -group gnt_converter /mtc_ppa_tb/DUT/gnt_converter/in_gnt_rdy_o
add wave -noupdate -group gnt_converter /mtc_ppa_tb/DUT/gnt_converter/out_gnt_o
add wave -noupdate -group gnt_converter /mtc_ppa_tb/DUT/gnt_converter/out_gnt_vld_o
add wave -noupdate -group gnt_converter /mtc_ppa_tb/DUT/gnt_converter/out_gnt_rdy_i
add wave -noupdate -group gnt_converter /mtc_ppa_tb/DUT/gnt_converter/edge_detector
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {270 ns} 0}
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
WaveRestoreZoom {0 ns} {1174 ns}
