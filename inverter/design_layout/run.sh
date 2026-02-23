rm cmos_inverter.mag
magic_sky130a -dnull -noconsole gen_inv.tcl
magic_sky130a cmos_inverter.mag
