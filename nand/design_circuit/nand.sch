v {xschem version=3.4.6 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N -70 -10 50 -10 {lab=Y}
N -10 -10 -10 20 {lab=Y}
N -10 10 100 10 {lab=Y}
N -110 -40 -110 50 {lab=A}
N -180 10 -110 10 {lab=A}
N -70 -40 -50 -40 {lab=VDD}
N -70 -70 -40 -70 {lab=VDD}
N -40 -70 -40 -40 {lab=VDD}
N -50 -40 -40 -40 {lab=VDD}
N 50 -40 80 -40 {lab=VDD}
N 80 -70 80 -40 {lab=VDD}
N -10 110 50 110 {lab=VSS}
N -10 140 50 140 {lab=VSS}
N -10 50 50 50 {lab=VSS}
N 50 50 50 140 {lab=VSS}
N -0 -40 10 -40 {lab=B}
N -0 -130 -0 -40 {lab=B}
N -130 -130 -0 -130 {lab=B}
N -180 70 -130 70 {lab=B}
N -40 -70 50 -70 {lab=VDD}
N 20 -90 20 -70 {lab=VDD}
N 50 -70 80 -70 {lab=VDD}
N -110 50 -110 110 {lab=A}
N -110 110 -50 110 {lab=A}
N -130 -130 -130 70 {lab=B}
N -130 70 -70 70 {lab=B}
N -70 50 -70 70 {lab=B}
N -70 50 -50 50 {lab=B}
C {sky130_fd_pr/pfet_01v8.sym} -90 -40 0 0 {name=M1
W=1
L=0.15
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/pfet_01v8.sym} 30 -40 0 0 {name=M2
W=1
L=0.15
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} -30 50 0 0 {name=M3
W=1
L=0.15
nf=1 
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} -30 110 0 0 {name=M4
W=1
L=0.15
nf=1 
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {ipin.sym} -180 10 0 0 {name=p1 lab=A}
C {ipin.sym} -180 70 0 0 {name=p2 lab=B}
C {ipin.sym} 20 -90 1 0 {name=p4 lab=VDD}
C {ipin.sym} -10 140 3 0 {name=p5 lab=VSS}
C {opin.sym} 100 10 0 0 {name=p6 lab=Y}
C {lab_pin.sym} -10 80 0 0 {name=p3 sig_type=std_logic lab=net1}
