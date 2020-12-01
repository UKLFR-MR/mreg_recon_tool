function Tb = trajectStruct_balance(T1)
%no rotations of input trajectories at this point

    
    grad_start_end=[0 0; 0 0; 0 0];
    K_dephase = T1.K(1,:);
    K_rephase = -T1.K(end,:);
    
    G_dephase = find_optimal_grad3D(T1.SYS,grad_start_end,K_dephase);
    G_rephase = find_optimal_grad3D(T1.SYS,grad_start_end,K_rephase);

    dataG = [G_dephase; T1.G; G_rephase];

% integrate gradient
for m=1:size(dataG,1)
    kx(m)=sum(dataG(1:m,1)*T1.SYS.GRT_SI)*T1.SYS.GAMMA_SI/(2*pi) ;
    ky(m)=sum(dataG(1:m,2)*T1.SYS.GRT_SI)*T1.SYS.GAMMA_SI/(2*pi) ;
    kz(m)=sum(dataG(1:m,3)*T1.SYS.GRT_SI)*T1.SYS.GAMMA_SI/(2*pi) ;
end


dataK=[kx; ky; kz]';

Tb=T1;
Tb.G = dataG;
Tb.G_bound=[dataG(1,:) ; dataG(end,:)];
Tb.K = dataK;
Tb.K_bound=[dataK(1,:) ; dataK(end,:)];
Tb.duration = size(dataG,1)*Tb.SYS.GRT_SI;
Tb.ramp_included='true';
    
%% perform the actual connection  

end
%END OF FUNCTION

%% Function that use linear programing framework
function [G exitflag]=find_optimal_grad3D(SYS,grad,targets)
%SYS = gradient system structure
%grad specifies start and end value of gradient [gxbegin gx_end; gy..;
%gz..], if grad is not an array
%targets specify the k-space difference to be reached at length n
%targets are defined by deltak-value (k-space position and when this point
%hast to be reached

n=1;
exitflag(1) =0; exitflag(2) =0; exitflag(3)=0;
while ~( exitflag(1) == 1 && exitflag(2) == 1 && exitflag(3) ==1)
    
    gx=[]; gy=[]; gz=[];
    n=n+1;
    [gx exitflag(1)]=find_optimal_grad(n,SYS,grad(1,:),[targets(1) n]);
    [gy exitflag(2)]=find_optimal_grad(n,SYS,grad(2,:),[targets(2) n]);
    [gz exitflag(3)]=find_optimal_grad(n,SYS,grad(3,:),[targets(3) n]);

end

G=[gx gy gz];
end

%% Connect trajectories by succesive removal of points untill smooth
%connection is possible 
function [G exitflag]=find_optimal_grad3D_remove_points(SYS,T1,T2)

    N=2;
    exitflag=ones(3,1);
    %find optimum for all three gradient axes
    for l=1:3
        deltak=-(T1.K(end-(N/2)+1,l) - T2.K(N/2,l));
        grad_start_end = [T1.G(end-(N/2)+1,l) ,T2.G(N/2,l)];
        [x(:,l) exitflag(l)]=find_optimal_grad(N,SYS,grad_start_end,[deltak N]);
    end
    while ~( exitflag(1) == 1 && exitflag(2) == 1 && exitflag(3) == 1)
        x=[];
        N=N+2;
        for l=1:3
            deltak=-(T1.K(end-(N/2)+1,l) - T2.K(N/2,l));
            grad_start_end = [T1.G(end-(N/2)+1,l) ,T2.G(N/2,l)];
            [x(:,l) exitflag(l)]=find_optimal_grad(N,SYS,grad_start_end,[deltak N]);
        end
    end
    
gx1=T1.G(:,1);
gx1(end-N/2+1:end)=x(1:N/2,1);
gx2=T2.G(:,1);
gx2(1:N/2)=x(N/2+1:end,1);

gy1=T1.G(:,2);
gy1(end-N/2+1:end)=x(1:N/2,2);
gy2=T2.G(:,2);
gy2(1:N/2)=x(N/2+1:end,2);

gz1=T1.G(:,3);
gz1(end-N/2+1:end)=x(1:N/2,3);
gz2=T2.G(:,3);
gz2(1:N/2)=x(N/2+1:end,3);

gx=[gx1; gx2];
gy=[gy1;gy2];
gz=[gz1;gz2];   

G=[gx gy gz];
    
end

%% Call linear programming and find optimal connection for one axis
function [x exitflag]=find_optimal_grad(N,SYS,grad,targets)

%targets are defined by deltak-value (k-space position and when this point
%hast to be reached

%N is the length of output vector x
%GMAX has to be in [mT/m]
%GO and G_end also have to be in [mT/m]
%grad specifies start and end value of gradient, if grad is not an array
%no end point gradient is specified

    
    GRT =SYS.GRT_SI; %[s]
    gamma = SYS.GAMMA_SI;  %rad/(s*mT)
    GMAX = SYS.GMAX_SI;
    
    %coefficients vector
    f=ones(N,1)/2;

    %slew inequality
    s=zeros(2,N);
    s(1,1)=1;
    s(1,2)=-1;
    s(2,1)=-1;
    s(2,2)=1;

    A=zeros(2*(N-1),N);
    for m=1:(N-1)
        A((2*m-1):2*m,:)=circshift(s,[0 m-1]);
    end

    b=SYS.SLEW_per_GRT_SI*ones(2*(N-1),1);

    %total moment equality
    for m=1:size(targets,1)
       Aeq(m,:)=zeros(N,1);
       Aeq(m,1:targets(m,2))=gamma/(2*pi)*GRT;
       beq(m)=targets(m,1);
    end

    %start_end_value
    if ~isempty(grad)
        aeq(1,:)=zeros(N,1);
        aeq(1,1)=1;
        if length(grad)==2
            aeq(2,:)=zeros(N,1);
            aeq(2,end)=1;
        end    
        Aeq=[Aeq ; aeq];
        beq=[beq grad(1)];
    
        if length(grad)==2
            beq =[beq grad(2)];
        end
    end
    
    %upper lower bound
    lb = -GMAX*ones(N,1);
    ub = GMAX*ones(N,1);
  options = optimset('Display','off'); 
[x a exitflag] = linprog(f,A,b,Aeq,beq,lb,ub,[],options);
end