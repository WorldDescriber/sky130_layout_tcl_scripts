v {xschem version=3.4.6 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 130 -30 170 -30 {lab=Y}
N -120 -30 -90 -30 {lab=A}
N -120 -30 -120 40 {lab=A}
C {vsource.sym} -120 70 0 0 {name=VIN value="pulse(0 1.8 1n 10p 10p 5n 10n)" savecurrent=false}
C {inverter.sym} 20 -30 0 0 {name=x1}
C {gnd.sym} -120 100 0 0 {name=l1 lab=GND}
C {gnd.sym} 0 20 0 0 {name=l2 lab=GND}
C {gnd.sym} 170 30 0 0 {name=l3 lab=GND}
C {capa.sym} 170 0 0 0 {name=Cload
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {vdd.sym} 0 -80 0 0 {name=l4 lab=VDD}
C {vsource.sym} -220 0 0 0 {name=VDD value=1.8 savecurrent=false}
C {gnd.sym} -220 30 0 0 {name=l5 lab=GND}
C {vdd.sym} -220 -30 0 0 {name=l6 lab=VDD}
C {code_shown.sym} -240 -340 0 0 {name=s1 only_toplevel=false value="
.lib /usr/local/share/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.tran 10p 20n
.control
run
plot V(A) V(Y)
meas tran trise TRIG V(Y) VAL=0.18 RISE=1 TARG V(Y) VAL=1.62 RISE=1
meas tran tfall TRIG V(Y) VAL=1.62 FALL=1 TARG V(Y) VAL=0.18 FALL=1
meas tran tpdr TRIG V(A) VAL=0.9 RISE=1 TARG V(Y) VAL=0.9 FALL=1
meas tran tpdf TRIG V(A) VAL=0.9 FALL=1 TARG V(Y) VAL=0.9 RISE=1
.endc
"}
C {lab_pin.sym} -120 -30 0 0 {name=p1 sig_type=std_logic lab=A}
C {lab_pin.sym} 170 -30 0 1 {name=p2 sig_type=std_logic lab=Y}
