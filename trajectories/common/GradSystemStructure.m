function SYS=GradSystemStructure(status,GRT, slewrate)

%% usage: SYS=GradSystemStructure(status,GRT, slewrate)
% input: status:    'unknown': leaves SR and G_max empty
%                   'slow':    SR = 110 T/m/s, G_max = 25 mT/m
%                   'medium':  SR = 130 T/m/s, G_max = 30 mT/m
%                   'fast':    SR = 170 T/m/s, G_max = 38 mT/m
%                   'patloc'   for PatLoc only
%                   'custom'   SR set by input, G_max = 38 mT/m
%        GRT: in seconds [s], set to 1e-6s if left empty
%        slewrate: !!!ONLY!!! needed for stauts = 'custom'

% Jakob Asslaender, August 2011



%HW 110914: extension for PatLoc1 system

if nargin <2 || isempty(GRT)
    %default gradient raster time
    GRT = 10/(1000*1000); % 10*1e-6 s
end

%constants
SYS.GAMMA = 0.2675;  %rad/(microsec*mT)
SYS.GAMMA_SI =  0.2675*(1000*1000*1000);  %rad/(Ts)
SYS.GAMMA_bar=SYS.GAMMA/(2*pi);

if nargin == 0
    status = 'unknown';
end  

%set gradient raster time
    SYS.GRT = (10^6)*GRT;  %[micros]
    SYS.GRT_SI = GRT; % 10*1e-6 s

%set properties to empty arrays if no type is specified
    SYS.type = 'unknown';
    SYS.GMAX = [];
    SYS.GMAX_SI =[];
    SYS.SLEW = [];
    SYS.SLEW_per_GRT =[];
    SYS.SLEW_per_GRT_SI =[];

if strcmp(status,'slow')
    SYS.type = 'slow';
    SYS.GMAX = 25; %[mT/m]
    SYS.GMAX_SI =25/1000; %[T/m]
    SYS.SLEW = 110; %T/m/s
    SYS.SLEW_per_GRT = SYS.SLEW*SYS.GRT/1000; %[mT/m]
    SYS.SLEW_per_GRT_SI = SYS.SLEW*SYS.GRT_SI; %[T/m];
elseif strcmp(status,'medium')
    SYS.type = 'medium';
    SYS.GMAX = 30; %[mT/m]
    SYS.GMAX_SI =30/1000; %[T/m]
    SYS.SLEW = 135; %T/m/s
    SYS.SLEW_per_GRT = SYS.SLEW*SYS.GRT/1000; %[mT/m]
    SYS.SLEW_per_GRT_SI = SYS.SLEW*SYS.GRT_SI; %[T/m];
elseif strcmp(status,'fast')
    SYS.type = 'fast';
    SYS.GMAX = 38; %[mT/m]
    SYS.GMAX_SI =38/1000; %[T/m]
    SYS.SLEW = 170; %T/m/s
    SYS.SLEW_per_GRT = SYS.SLEW*SYS.GRT/1000; %[mT/m]
    SYS.SLEW_per_GRT_SI = SYS.SLEW*SYS.GRT_SI; %[T/m];
    
%HW: 110914: extension for PatLoc1 system
elseif strcmp(status,'patloc')
    SYS.type = 'patloc';
    SYS.GMAX = 32; %[mT/m]
    SYS.GMAX_SI =32/1000; %[T/m]
    SYS.SLEW = 170; %T/m/s (= 5.88 µs/mT/m);
    SYS.SLEW_per_GRT = SYS.SLEW*SYS.GRT/1000; %[mT/m]
    SYS.SLEW_per_GRT_SI = SYS.SLEW*SYS.GRT_SI; %[T/m];
    
elseif strcmp(status, 'custom')
    SYS.type = 'medium';
    SYS.GMAX = 38; %[mT/m]
    SYS.GMAX_SI =38/1000; %[T/m]
    SYS.SLEW = slewrate; %T/m/s
    SYS.SLEW_per_GRT = SYS.SLEW*SYS.GRT/1000; %[mT/m]
    SYS.SLEW_per_GRT_SI = SYS.SLEW*SYS.GRT_SI; %[T/m];

end