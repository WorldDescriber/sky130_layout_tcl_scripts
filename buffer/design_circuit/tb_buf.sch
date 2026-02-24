v {xschem version=3.4.6 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 60 40 60 80 {lab=A}
N 60 40 150 40 {lab=A}
C {buf.sym} 220 40 0 0 {name=x1}
C {capa.sym} 320 70 0 0 {name=Cload
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {vsource.sym} -150 40 0 0 {name=VDD value=1.8 savecurrent=false}
C {gnd.sym} -150 70 0 0 {name=l1 lab=GND}
C {gnd.sym} 200 90 0 0 {name=l2 lab=GND}
C {gnd.sym} 320 100 0 0 {name=l3 lab=GND}
C {vdd.sym} 200 -10 0 0 {name=l4 lab=VDD}
C {vdd.sym} -150 10 0 0 {name=l5 lab=VDD}
C {lab_pin.sym} 150 40 0 0 {name=p1 sig_type=std_logic lab=A}
C {lab_pin.sym} 320 40 0 1 {name=p2 sig_type=std_logic lab=Y}
C {vsource.sym} 60 110 0 0 {name=VA value="pulse(0 1.8 1n 10p 10p 5n 10n)" savecurrent=false}
C {gnd.sym} 60 140 0 0 {name=l6 lab=GND}
C {code_shown.sym} -220 -100 0 0 {name=s1 only_toplevel=false value=".lib /usr/local/share/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt"}
C {code_shown.sym} -220 190 0 0 {name=s2 only_toplevel=false value="
* Analysis
.tran 10p 20n
.control
run
plot v(a) v(y)
* 20% to 80%
meas tran trise28 TRIG v(y) VAL=0.36 RISE=1 TARG v(y) VAL=1.44 RISE=1
* 80% to 10%
meas tran tfall82 TRIG v(y) VAL=1.44 FALL=1 TARG v(y) VAL=0.36 FALL=1
let power = v(VDD)*i(VDD)
meas tran avg_power AVG power from=1n to=20n
meas tran peak_power MAX power from=1n to=20n
meas tran trise19 TRIG V(Y) VAL=0.18 RISE=1 TARG V(Y) VAL=1.62 RISE=1
meas tran tfall91 TRIG V(Y) VAL=1.62 FALL=1 TARG V(Y) VAL=0.18 FALL=1
meas tran tpdr TRIG V(A) VAL=0.9 RISE=1 TARG V(Y) VAL=0.9 FALL=1
meas tran tpdf TRIG V(A) VAL=0.9 FALL=1 TARG V(Y) VAL=0.9 RISE=1
*(tpdr+tpdf)/2  ; Average propagation delay
meas tran energy INTEG power from=1n to=20n
*'energy/4'  ; 4 transitions in 20ns
meas tran i_peak MAX I(VDD)
meas tran i_avg AVG I(VDD) from=1n to=20n

meas tran voh MIN V(Y) from=2n to=4n   ; Output high level
meas tran vol MAX V(Y) from=7n to=9n   ; Output low level
meas tran overshoot MAX V(Y) from=1n to=3n
meas tran undershoot MIN V(Y) from=6n to=8n



.endc
"}
