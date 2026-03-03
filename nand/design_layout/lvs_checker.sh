magic_sky130a -noconsole -dnull << EOF
load nand
select top cell
extract all
ext2spice lvs
ext2spice
quit
EOF
#netgen -batch lvs "cmos_inverter.spice cmos_inverter" "cmos_inverter.cir cmos_inverter" /usr/local/share/pdk/sky130A/libs.tech/netgen/sky130A_setup.tcl
#netgen -batch lvs "inv.spice inv" "../../schematic/tb_inv.spice inv" /usr/local/share/pdk/sky130A/libs.tech/netgen/sky130A_setup.tcl
netgen -batch lvs "../../../design_circuit/circuit_3/simulation/tb_nand.spice nand" "nand.spice nand" /usr/local/share/pdk/sky130A/libs.tech/netgen/sky130A_setup.tcl
