function K=Grad2K(G,K0,inc)
%G must be and Nx3 array with gradient values in SI units T/m
%K0 is the k-space starting value in 1/m
%inc is gradient dwell time (time between two samples)

SYS = GradSystemStructure();

K=cumsum(G,1)*inc*SYS.GAMMA_SI/(2*pi) ;

K(:,1)=K(:,1)+K0(1);
K(:,2)=K(:,2)+K0(2);
K(:,3)=K(:,3)+K0(3);

%add an extra sample with starting value in order to compensate for diff
%K = [K0 K];