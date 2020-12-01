function Tc = trajectStruct_connect(T1,T2,type)
%no rotations of input trajectories at this point
if nargin < 3
    type = 'unspec';
end

%check if both trajectory elements have identical grad system limits
if ~strcmp(T1.SYS.type,T2.SYS.type)
    warning('Elements do not have identical grad system limits')
    return;
end

    %lil hacky
    SYS = T1.SYS;
    SYS.SLEW_per_GRT_SI = 0.001;

if strcmp(type,'rip')
    [dataG exitflag]=find_optimal_grad3D_remove_points(SYS,T1,T2); 
else
    
    grad_start_end=[T1.G(end,1) T2.G(1,1);T1.G(end,2) T2.G(1,2);T1.G(end,3) T2.G(1,3)];
    deltak=T2.K(1,:) -T1.K(end,:);
    
    Gc=findOptimalGrad3D(SYS,grad_start_end,deltak);
    dataG=[T1.G; Gc; T2.G];
end

% integrate gradient
    kx=cumsum(dataG(:,1))*T1.SYS.GRT_SI*T1.SYS.GAMMA_SI/(2*pi) ;
    ky=cumsum(dataG(:,2))*T1.SYS.GRT_SI*T1.SYS.GAMMA_SI/(2*pi) ;
    kz=cumsum(dataG(:,3))*T1.SYS.GRT_SI*T1.SYS.GAMMA_SI/(2*pi) ;

%if not(strcmp(type,'rip'))
    kx=kx + T1.K(1,1) - dataG(1,1)*T1.SYS.GRT_SI*T1.SYS.GAMMA_SI/(2*pi);
    ky=ky + T1.K(1,2) - dataG(1,2)*T1.SYS.GRT_SI*T1.SYS.GAMMA_SI/(2*pi);
    kz=kz + T1.K(1,3) - dataG(1,3)*T1.SYS.GRT_SI*T1.SYS.GAMMA_SI/(2*pi);
%end

dataK=[kx ky kz];

Tc=T1;
Tc.G = dataG;
%Tc.G_bound=[dataG(1,:) ; dataG(end,:)];
Tc.K = dataK;
%Tc.K_bound=[dataK(1,:) ; dataK(end,:)];
Tc.duration = size(dataG,1)*Tc.SYS.GRT_SI;
if(isfield(T2,'in_out'))
    Tc.in_out = T2.in_out;
end 
%% perform the actual connection  

end
%END OF FUNCTION

%% Connect trajectories by succesive removal of points untill smooth
%connection is possible 
function [G exitflag]=find_optimal_grad3D_remove_points(SYS,T1,T2)
    
    N1=0; N2=0; N3 = 0;
    exitflag=zeros(3,1);
    %find optimum for all three gradient axes
    while ~( exitflag(1) == 1 && exitflag(2) == 1 && exitflag(3) == 1)
        x=[];
        if N1 < size(T1.K,1)-1 && N2 < size(T2.K,1)-2
            N1=N1+1; N2=N2+1;
        elseif N1 < size(T1.K,1)-1
            N1=N1+1;
        elseif N2 < size(T2.K,1)-2
            N2=N2+1;
        else
            error('Can''t connect by removing points. Both trajectories are too short and too far apart.');
        end
        for l=1:3
            deltak = -(T1.K(end-(N1),l) - T2.K(N2,l));
            grad_start_end = [T1.G(end-(N1),l) ,T2.G(N2,l)];
            [xl exitflag(l)]=findOptimalGrad1D(N1+N2+N3,SYS,grad_start_end,[deltak N1+N2+N3]);
            if ~isempty(xl)
                x(:,l) = xl;
            end
        end
    end
    
gx = T1.G(1:end-N1,1);
gx = [gx; x(:,1)];
gx = [gx; T2.G(N2:end,1)];

gy = T1.G(1:end-N1,2);
gy = [gy; x(:,2)];
gy = [gy; T2.G(N2:end,2)];

gz = T1.G(1:end-N1,3);
gz = [gz; x(:,3)];
gz = [gz; T2.G(N2:end,3)];

G=[gx gy gz];
    
end
