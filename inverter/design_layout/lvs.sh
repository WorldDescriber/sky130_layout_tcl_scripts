#select top cell
#extract all
#ext2spice lvs
#ext2spice
# Extract netlist for LVS
# input cmos_inverter.mag
# output cmos_inverter.spice
magic_sky130a -dnull -noconsole cmos_inverter.mag << EOF
extract all
ext2spice lvs
ext2spice
quit
EOF

#netgen -batch lvs "netlists/xor_synth.spice xor_gate" "netlists/xor_extracted.spice xor_gate" $(PDK_PATH)/libs.tech/netgen/sky130A_setup.tcl lvs_report.txt
netgen -batch lvs "../../../design_circuit/simulation/tran_inverter.spice inverter" "cmos_inverter.spice cmos_inverter" /usr/local/share/pdk/sky130A/libs.tech/netgen/sky130A_setup.tcl lvs_report.txt
