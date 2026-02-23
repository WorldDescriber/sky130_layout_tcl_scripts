v {xschem version=3.4.6 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 1380 -980 1380 -880 {lab=A}
N 1420 -950 1420 -910 {lab=Y}
N 1420 -930 1460 -930 {lab=Y}
N 1420 -980 1450 -980 {lab=VDD}
N 1420 -1010 1450 -1010 {lab=VDD}
N 1450 -1010 1450 -980 {lab=VDD}
N 1420 -880 1450 -880 {lab=Y}
N 1450 -880 1450 -850 {lab=Y}
N 1420 -850 1450 -850 {lab=Y}
N 1420 -850 1420 -820 {lab=Y}
C {ipin.sym} 1380 -930 0 0 {name=p1 lab=A}
C {opin.sym} 1460 -930 0 0 {name=p2 lab=Y}
C {sky130_fd_pr/pfet_01v8.sym} 1400 -980 0 0 {name=M1
W=2.0
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
C {sky130_fd_pr/nfet_01v8.sym} 1400 -880 0 0 {name=M2
W=1.0
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
C {ipin.sym} 1420 -1010 1 0 {name=p3 lab=VDD}
C {opin.sym} 1420 -820 0 0 {name=p4 lab=VSS}
