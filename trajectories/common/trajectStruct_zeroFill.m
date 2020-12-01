function T=trajectStruct_zeroFill(Tin,L)

T=Tin;

T.K=cat(1,Tin.K, zeros(L,3));
%T.K_bound(2,:)=[0 0 0];
T.G=cat(1,Tin.G, zeros(L,3));
T.duration = Tin.duration + L*Tin.SYS.GRT_SI;