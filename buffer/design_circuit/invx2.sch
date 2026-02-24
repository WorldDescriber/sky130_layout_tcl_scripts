v {xschem version=3.4.6 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 950 -840 950 -750 {lab=A}
N 990 -810 990 -780 {lab=Y}
N 900 -800 950 -800 {lab=A}
N 990 -790 1060 -790 {lab=Y}
N 990 -840 1020 -840 {lab=VDD}
N 990 -870 1020 -870 {lab=VDD}
N 1020 -870 1020 -840 {lab=VDD}
N 990 -750 1020 -750 {lab=VSS}
N 990 -720 1020 -720 {lab=VSS}
N 1020 -750 1020 -720 {lab=VSS}
C {sky130_fd_pr/pfet_01v8.sym} 970 -840 0 0 {name=M1
W=2
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
C {sky130_fd_pr/nfet_01v8.sym} 970 -750 0 0 {name=M2
W=0.84
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
C {ipin.sym} 900 -800 0 0 {name=p1 lab=A}
C {opin.sym} 1060 -790 0 0 {name=p2 lab=Y}
C {ipin.sym} 990 -870 1 0 {name=p3 lab=VDD}
C {ipin.sym} 990 -720 3 0 {name=p4 lab=VSS}
