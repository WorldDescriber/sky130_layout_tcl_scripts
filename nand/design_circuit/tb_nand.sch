v {xschem version=3.4.6 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N -220 -10 -90 -10 {lab=A}
N -160 30 -90 30 {lab=B}
C {nand.sym} -20 10 0 0 {name=x1}
C {vdd.sym} -20 -50 0 0 {name=l1 lab=VDD}
C {gnd.sym} -20 70 0 0 {name=l2 lab=GND}
C {capa.sym} 100 40 0 0 {name=C1
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 100 70 0 0 {name=l3 lab=GND}
C {vsource.sym} -300 -30 0 0 {name=V1 value=1.8 savecurrent=false}
C {vdd.sym} -300 -60 0 0 {name=l4 lab=VDD}
C {gnd.sym} -300 0 0 0 {name=l5 lab=GND}
C {vsource.sym} -220 20 0 0 {name=V2 value="pulse(0 1.8 0 100p 100p 4n 8n)" savecurrent=false}
C {vsource.sym} -160 60 0 0 {name=V3 value="pulse(0 1.8 0 100p 100p 8n 16n)" savecurrent=false}
C {gnd.sym} -220 50 0 0 {name=l6 lab=GND}
C {gnd.sym} -160 90 0 0 {name=l7 lab=GND}
C {code_shown.sym} -250 -120 0 0 {name=s1 only_toplevel=false value=".lib /usr/local/share/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt"}
C {code_shown.sym} -260 180 0 0 {name=s2 only_toplevel=false value="
.tran 10p 32n
.save V(A) V(B) V(Y)
.control
run
plot V(A)
plot V(B)
plot V(Y)
.endc
"}
C {lab_pin.sym} -170 -10 1 0 {name=p1 sig_type=std_logic lab=A}
C {lab_pin.sym} -160 30 1 0 {name=p2 sig_type=std_logic lab=B}
C {lab_pin.sym} 100 10 2 0 {name=p3 sig_type=std_logic lab=Y}
