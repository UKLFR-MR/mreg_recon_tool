%==========================================================================
% function G=gradient_clip_offset(Goff,kdes,BW,Gmax,Smax)
% 
% Calculates a gradient clip with a certain with a certain initial value
% for and a certain desired k-space value kclip.
% Dependent on the value of Goff, kclip, Gmax, and Smax this might result 
% either in triangluar, or trapezoidal gradient shapes.
% -> Can be used to calculate rewinder and prewinder gradients
%
% INPUT:
% Goff      ... Offset gradient value. I.e. 
% kclip     ... Desired k-space value of the gradient clip [rad/m]
% BW        ... Sampling bandwidth [Hz]
% Gmax      ... max. gradient strength (<= 0.04 T/m)
% Smax      ... max. selw rate (<= 150 T/(m*s))
%
% OUTPUT:
% G     ... Clip gradient waveform
%
% Created:
% 22/03/2007, Florian.Wiesinger@Research.GE.COM
%==========================================================================

function G=gradient_clip_offset(Goff,kdes,BW,Gmax,Smax)

% Parameter definition:
gama=gyrogamma('1h');  % [rad/(T*s)]
vorz=sign(Goff);
Goff=vorz*Goff;
kdes=vorz*kdes;
dt=1/(2*BW);

% 1st point of min gradient requires special treatment:
% -> risk for Smax violation!
tmin=dt*ceil(Goff/Smax/dt); Nmin=round(tmin/dt); 
Sdown=Goff/tmin;
Gmin=Goff-[1:Nmin]*Sdown*dt;
kmin=gama*dt*sum([Goff,Gmin]);

if kdes<kmin
    % kdes<kmin: Have to add negative CLIP
    %==================================================
    % What follows is a basic Gradient CLIP calculation
    %==================================================
    kclip=abs(kdes-kmin);
    % Solve for t: t^2*S+t*dt*S=k/gama
    tcheck=roots([Smax,dt*Smax,-kclip/gama]);
    tcheck=dt*ceil(max(tcheck)/dt);
    Gcheck=Smax*tcheck;
    if Gcheck<Gmax
        tclip=tcheck; Nclip=round(tclip/dt);
        % Solve for S: S*tcheck^2+S*tcheck*dt=k/gama
        Sclip=kclip/(gama*(tcheck^2+tcheck*dt));
        Grauf=[1:Nclip]*dt*Sclip;
        Ggrad=Grauf(end);
        Gdown=Ggrad(end)-[1:Nclip]*Sclip*dt;
    elseif Gcheck>Gmax
        trauf=dt*floor(Gmax/Smax/dt); Nrauf=round(trauf/dt);
        kgrad=kclip-gama*Smax*trauf^2;
        tgrad=dt*ceil(kgrad/(gama*Smax*trauf)/dt); Ngrad=round(tgrad/dt);
        % Solve for S: S*trauf^2+S*trauf*tgrad=k/gama
        Sclip=kclip/(gama*(trauf^2+trauf*tgrad));
        Grauf=[1:Nrauf]*Sclip*dt;
        Ggrad=Grauf(end)*ones(1,Ngrad);
        Gdown=Ggrad(end)-[1:Nrauf]*Sclip*dt;
    end
    G=round(1e9*[Gmin,-Grauf,-Ggrad,-Gdown])/1e9;
elseif kdes>=kmin
    % Positive rewinder only
    tback=dt*ceil(Goff/Smax/dt); Nback=round(tback/dt); Sback=Goff/tback; 
    Gback=Goff-[1:Nback]*Sback*dt;
    % Solve for t: S*t^2+S*t*dt+Goff*2*(t+dt)+Goff*tback/2=k/gama
    tcheck=roots([Smax,Smax*dt+2*Goff,-kdes/gama+Goff*dt+Goff*tback/2]);
%    tcheck=roots([Smax,Smax*dt+2*Goff,-kdes/gama+2*Goff*dt+Goff*tback/2]);
    tcheck=dt*ceil(max(tcheck)/dt);
    Gcheck=Goff+Smax*tcheck;
    if Gcheck<Gmax
        trauf=tcheck; Nrauf=round(trauf/dt);
        % Solve for S: S*t^2+S*t*dt+Goff*2*(t+dt)+Goff*tback/2=k/gama
        Sclip=(kdes/gama-2*Goff*(trauf+dt)-Goff*tback/2)/(tcheck^2+tcheck*dt);
        Grauf=Goff+[0:Nrauf]*Sclip*dt;
        Ggrad=Grauf(end);
        Gdown=Ggrad(end)-[1:Nrauf]*Sclip*dt;
    elseif Gcheck>=Gmax
        trauf=dt*ceil((Gmax-Goff)/Smax/dt); Nrauf=round(trauf/dt);
        kgrad=kdes-gama*dt*sum([Goff,Gback])-gama*(Smax*trauf^2+Goff*(2*trauf+dt));
        tgrad=dt*ceil(kgrad/(gama*(Goff+Smax*trauf))/dt); Ngrad=round(tgrad/dt);
        % Solve for S: S*t1^2+S*t1*t2+Goff*(2*t1+t2+dt)+Goff*tback/2=k/gama
        Sclip=(kdes/gama-(Goff*(2*trauf+tgrad+dt)+Goff*tback/2))/(trauf^2+trauf*tgrad);
        Grauf=[Goff+[0:Nrauf]*Sclip*dt];
        if isempty(Grauf), Grauf=Goff; warning('Bug fix; not accurate'); end
        if (Ngrad<0)||isempty(Ngrad), Ngrad=1; warning('Bug fix; not accurate'); end
        Ggrad=Grauf(end)*ones(1,Ngrad);
        Gdown=Ggrad(end)-[1:Nrauf]*Sclip*dt;
    end
    G=round(1e9*[Grauf,Ggrad,Gdown,Gback])/1e9;
end
kdes=vorz*kdes; Goff=vorz*Goff; G=vorz*G;
display(['Relative Error: 100*(kdes-k(G))/kclip = ',...
    num2str(sum([Goff,G])*dt*gama-kdes),' %']);
