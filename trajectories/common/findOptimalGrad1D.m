%% Function that use linear programing framework
%% Call linear programming and find optimal connection for one axis
function [x exitflag]=findOptimalGrad1D(N,SYS,grad,targets)

%targets are defined by deltak-value (k-space position and when this point
%hast to be reached

%N is the length of output vector x
%SYS is a gradient system structure with GMAX in [mT/m]
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
%  options.Algorithm = 'dual-simplex'; %this looks quite a bit
%  different...?
[x a exitflag] = linprog(f,A,b,Aeq,beq,lb,ub,[],options);
end