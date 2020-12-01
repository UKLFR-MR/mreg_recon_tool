function G=K2Grad(K,inc)
%G must be and Nx3 array with gradient values in SI units T/m
%K0 is the k-space starting value in 1/m
%inc is gradient dwell time (time between two samples)

SYS = GradSystemStructure();

G=(diff(K,1)/inc)*((2*pi)/SYS.GAMMA_SI);
