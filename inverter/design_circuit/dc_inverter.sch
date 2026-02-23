v {xschem version=3.4.6 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 130 -30 170 -30 {lab=Y}
N -120 -30 -90 -30 {lab=A}
N -120 -30 -120 40 {lab=A}
C {vsource.sym} -120 70 0 0 {name=VIN value=0 savecurrent=false}
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
.control
run
dc VIN 0 1.8 0.01
*plot V(Y) vs V(A) title VTC
plot V(Y) V(A) title VTC
*Voltage Transfer Characteristic
.endc
"}
C {lab_pin.sym} -120 -30 0 0 {name=p1 sig_type=std_logic lab=A}
C {lab_pin.sym} 170 -30 0 1 {name=p2 sig_type=std_logic lab=Y}
