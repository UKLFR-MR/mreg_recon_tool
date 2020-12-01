function T=single_element_shell(turns,kmax,up,SYS,plot_flag,rect_flag)
% this function creates a single element for a trajectory based on
% concentric shells. The single element is a trajectory that spirals from
% the N-to-S-pole on a spherical shell with radius kmax;
% The trajectory is described by :
% kx = kmax * sin(theta)*cos(a*theta);
% ky = kmax * sin(theta)*sin(a*theta);
% kz = kmax * cos(theta);
%
% the parametric function theta(t), ranging from 0 to pi, dictates the velocity and acceleration along the trajectory;
% a/2 revolutions are performed during the path from the N- to the S-pole.

% integer number (a = 2*turns)
% kmax [1/m]
% up; 1 = N->S; -1 = S->N
% SYS = Gradient system structure


if nargin < 6
    rect_flag = 0;
end
if nargin < 4
    plot_flag =1;
end
if nargin < 2
    kmax = 125;
end

%set a to correct value
a=2*turns;

%this increment is used to provide output from odexxx on a finer grid
ink = SYS.GRT_SI/1000;

%solve differential equation (see function THETA_2PUNKT further down in the code)
options = odeset('Events',@events,'RelTol',1e-10,'AbsTol',[1e-10 1e-10],'Stats','off','MaxStep',0.00001);
[t theta]=ode45(@(t,y) THETA_2PUNKT(t,y,SYS,a,kmax),0:ink:0.20,[0 0],options);

%find equator
eq_index = find(abs(theta(:,1)-pi/2)==min(abs(theta(:,1)-pi/2)));

%shorten theta to exact length of pi/2
THETA = theta(1:eq_index,1);

%mirror theta (point reflection at (T/2,pi/2)); Use fine raster  
tmp = THETA - pi/2;
THETA2 = -tmp(end:-1:1) + pi/2;
THETA = [THETA; THETA2]; % combine both hemispheres

%downsample to GRT and calculate total gradient duration
T_total=2*length(1:eq_index)*ink; %[s] twice the duration till equator
tspan=0:SYS.GRT_SI:T_total;
THETA = interp1(0:ink:T_total-ink,THETA,tspan,'linear');
% !!! downsampling after constructing theta for the second hemisphere prevents the 
% gradient shape to produce unwanted amplitude spikes because of
% unprecise detection of the exact theta = pi/2 location. 
% 100 per cent heuristic approach !!!



%calculate trajectory from analytic expression 
    kx = kmax * sin(THETA).*cos(a*THETA);
    ky = kmax * sin(THETA).*sin(a*THETA);
    kz = kmax * cos(THETA);
    
    K= [kx; ky; kz]';
    
    G=K2Grad(K,SYS.GRT_SI);
    


%calculate gradient shape
%     gx = kmax*(2*pi/SYS.GAMMA_SI)*theta(:,2).*(cos(theta(:,1)).*cos(a*theta(:,1)) - sin(theta(:,1)).*sin(a*theta(:,1))*a);
%     gy = kmax*(2*pi/SYS.GAMMA_SI)*theta(:,2).*(cos(theta(:,1)).*sin(a*theta(:,1)) + sin(theta(:,1)).*cos(a*theta(:,1))*a);
%     if rect_flag == 1
%         kmax = kmax/2;
%     end
%     gz = -kmax*(2*pi/SYS.GAMMA_SI)*theta(:,2).*sin(theta(:,1));
%     
%     G=[gx gy gz];
%     
    

    
    if(up == -1)
        G(:,3)=-G(:,3);
        K(:,3) = -K(:,3);
    end
%check slew rate 
    sx = diff(G(:,1))./(SYS.GRT_SI);
    sy = diff(G(:,2))./(SYS.GRT_SI);
    sz = diff(G(:,3))./(SYS.GRT_SI);
    S(:,1)=sx; S(:,2)=sy; S(:,3)=sz;

% integrate gradient 
    %kx=cumsum(G(:,1)*SYS.GRT_SI)*SYS.GAMMA_SI/(2*pi) ;
    %ky=cumsum(G(:,2)*SYS.GRT_SI)*SYS.GAMMA_SI/(2*pi) ;
    %kz=cumsum(G(:,3)*SYS.GRT_SI)*SYS.GAMMA_SI/(2*pi) +kmax;

    
%K(:,1)=kx; K(:,2)=ky; K(:,3)=kz;

%determine minimum dwell time not yet implemented
d = sqrt(sum(abs(K).^2,2));

T = trajectStruct_init(K,G,SYS);

if plot_flag
    display('duration in [ms]')
    disp(1000*T.duration)
    %figure; plot3(K(:,1),K(:,2),K(:,3),'o')
    figure; plot(1000*tspan(1:size(G,1)),G); xlabel('t [ms]'); ylabel('G [T/m]')
    figure; plot(1000*tspan(1:size(G,1)),sqrt(G(:,1).^2 + G(:,2).^2)); xlabel('t [ms]'); ylabel('|G| [T/m]')
    figure; plot(1000*tspan(1:size(S,1)),S); xlabel('t [ms]'); ylabel('S [Ts/m]')
    figure; plot(1000*tspan(1:size(S,1)),sqrt(S(:,1).^2 + S(:,2).^2)); xlabel('t [ms]'); ylabel('|S| [Ts/m]')
end

end
%END OF MAIN FUNCTION

%% Function handle to be used in ode for the second derivative of theta
function dtheta=THETA_2PUNKT(t,y,SYS,a,kR)
	if nargin < 5
	 kR=125;
	end
	if nargin < 4
    	a=16;
	end

	%EVERTHING IS IN SI UNITS NOW; see Eqs.12,13 in shell paper
	beta = ((SYS.SLEW * SYS.GAMMA_SI)/(kR*2*pi)).^2 ; 
	c = 1 -sin(y(1))^2*(1-a^2);
	d = 2*y(2)^2*cos(y(1))*sin(y(1))*(-1 + a^2);
	e = (y(2)^4)*((sin(y(1))^2)*((1-a^2)^2) +4*a^2);
    
    %calculate the current gradient amplitude (length of vector)
	A = sqrt(1 + sin(y(1)).^2*(a^2 -1));
	G = kR*(2*pi/SYS.GAMMA_SI)*y(2)*A;
    if G > SYS.GMAX_SI
        beta = 0;
    end
    
    %calculate Diskriminante
	Diskriminante = d^2 -4*c*(e-beta);
	%important to make the solution of the differential equation more stable
	if (Diskriminante <0)
    		Diskriminante = 0;
	end

	%calculate the second derivative
	dtheta(2)=(-d+sqrt(Diskriminante))/(2*c);
	dtheta(1)=y(2);



	if y(1) > 2.3 
    	%display([y(1) G])
    	dtheta(2)=-5000;
	end

	dtheta=dtheta';
end

%% EVENT FUNCTION
function [value,isterminal,direction] = events(t,y)
	% Locate when y(1)=theta=pi and then stop the integration
	value(1) = y(1) - 1.05*(pi/2);     % Detect height = 0; but we want to perform the integration a 	little bit further on
	value(2) = 1;
	isterminal = [1 1];   % Stop the integration
	direction =  [0 0];   % Negative direction only
end

