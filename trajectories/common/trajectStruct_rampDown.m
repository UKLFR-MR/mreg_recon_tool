function Tdown = trajectStruct_rampDown(T1)
%ramps down the gradient and rephases all spins (return to k-space center)
% and add some extra samples at the end of the acquisition which can be
% used for T2*-correction
    
    grad_start_end=[T1.G(end,1) 0; T1.G(end,2) 0; T1.G(end,3) 0];
    K_dephase = T1.K(end,:);

    %lil hacky
    SYS = T1.SYS;
    SYS.SLEW_per_GRT_SI = 0.001;
    
    G_rephase = findOptimalGrad3D(SYS,grad_start_end,-K_dephase);

%    dataG = [T1.G; G_rephase; zeros(20,3)];
    dataG = [T1.G; G_rephase];

% integrate gradient
    kx=cumsum(dataG(:,1)*T1.SYS.GRT_SI)*T1.SYS.GAMMA_SI/(2*pi) ;
    ky=cumsum(dataG(:,2)*T1.SYS.GRT_SI)*T1.SYS.GAMMA_SI/(2*pi) ;
    kz=cumsum(dataG(:,3)*T1.SYS.GRT_SI)*T1.SYS.GAMMA_SI/(2*pi) ;


dataK=[kx ky kz];

Tdown=T1;
Tdown.G = dataG;
Tdown.K = dataK;
Tdown.duration = size(dataG,1)*Tdown.SYS.GRT_SI;
Tdown.rampDown='true';
end
%END OF FUNCTION