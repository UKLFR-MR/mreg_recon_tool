function Tup = trajectStruct_rampUp(T1)
%ramp up gradient and travel to inital k-space point
    
    grad_start_end=[0 T1.G(1,1); 0 T1.G(1,2); 0 T1.G(1,3)];
    K_dephase = T1.K(1,:);
    
    G_dephase = findOptimalGrad3D(T1.SYS,grad_start_end,K_dephase);

%    dataG = [zeros(40,3); G_dephase; T1.G;];
    dataG = [G_dephase; T1.G;];

% integrate gradient
    kx=cumsum(dataG(:,1)*T1.SYS.GRT_SI)*T1.SYS.GAMMA_SI/(2*pi) ;
    ky=cumsum(dataG(:,2)*T1.SYS.GRT_SI)*T1.SYS.GAMMA_SI/(2*pi) ;
    kz=cumsum(dataG(:,3)*T1.SYS.GRT_SI)*T1.SYS.GAMMA_SI/(2*pi) ;


dataK=[kx ky kz];

Tup=T1;
Tup.G = dataG;
Tup.K = dataK;
Tup.duration = size(dataG,1)*Tup.SYS.GRT_SI;
Tup.rampUp='true';
end
%END OF FUNCTION