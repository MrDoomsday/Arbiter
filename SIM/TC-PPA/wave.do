onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tc_ppa_arbiter_tb/DUT/clk
add wave -noupdate /tc_ppa_arbiter_tb/DUT/reset_n
add wave -noupdate -expand -group req -expand /tc_ppa_arbiter_tb/DUT/req_i
add wave -noupdate -expand -group req /tc_ppa_arbiter_tb/DUT/req_rdy_o
add wave -noupdate -expand -group gnt -expand /tc_ppa_arbiter_tb/DUT/gnt_o
add wave -noupdate -expand -group gnt /tc_ppa_arbiter_tb/DUT/gnt_rdy_i
add wave -noupdate -expand -group debug /tc_ppa_arbiter_tb/DUT/mpe
add wave -noupdate -expand -group debug /tc_ppa_arbiter_tb/DUT/mpe_mask
add wave -noupdate -expand -group debug /tc_ppa_arbiter_tb/DUT/mpe_mux
add wave -noupdate -expand -group debug /tc_ppa_arbiter_tb/DUT/hptr
add wave -noupdate -expand -group debug /tc_ppa_arbiter_tb/DUT/hptr_next
add wave -noupdate -expand -group debug -expand /tc_ppa_arbiter_tb/DUT/request
add wave -noupdate -expand -group debug /tc_ppa_arbiter_tb/DUT/gnt_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {430 ns} 1} {{Cursor 2} {364 ns} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {107 ns} {1197 ns}
