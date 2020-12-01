function T=shells(R,fov,resolution,TE,Npolar,Nradial,varargin)
% This function creates a single/multi shot concentric shells trajectory
% with variable density undersampling (see MRM...).

% INPUT:
%   R = [radial0 radialMax polar0 polarMax] : undersampling factors in
%       radial and polar direction at center of kspace (...0) and periphery (...Max)
%
%   fov : Field-Of-View in [m]
%
%   resolution : Resolution in pixel. Currently only isotropic resolution
%                is supported.
%
%   TE : Time of smallest shell element relative to start of trajectory.
%        Value must be in [s].
%
%   Npolar : Number of undersampling per shot in polar direction. This
%            means interleaved (multishot) acquisition so that after Npolar
%            shots the global polar sampling density (specified by R(3) and
%            R(4)) is achieved. For each shot and each shell element the
%            number of turns on the surface is therfore decreased by factor
%            Npolar. Default is single shot acquisition (Npolar =1).
%
%   Nradial : Number of undersampling per shot in radial direction... (to be continoued by jakob)
%
% VARARGIN:
% In varargin several additional parameter/value pairs can be specified.
% (function vararg_pair_bz is needed)
%
% parameter     : value
% 'GradSystem'  : 'slow'|'medium';|'fast'.
% 'SlewMode'    : 'const'|'optim'.
% 'alpha'       : value in radians.
%
%
% OUTPUT:
% Output is a trajectory structure containing the actual trajectory,
% gradient shape and various additional information. This gradient
% structure can be exported as a scanner readable *.grad-file.


if nargin < 6
    Nradial = 1;
end
if nargin < 5
    Npolar  = 1;
end
if nargin < 4
    TE = 0;
end
if nargin < 3
    resolution = 64;
end
if nargin < 2
    fov = 0.256;
end
if nargin <1
    R = [2 5 3 5];
end

%default arguments for optional varargins
args.GradSystem     = 'fast';
args.SlewMode   = 'optim';
args.alpha      = 0; %additional rotation bewtween shell elements

%check if any default args are overwritten by user input
args = vararg_pair(args, varargin);

Rrad0       = R(1);
RradMax     = R(2);
Rpolar0     = R(3);
RpolarMax   = R(4);

% Calculate global maximum k-space from FOV and voxel size
KMAX = (1/fov)*(resolution/2.0); %should be in[1/m]
deltaK_full = KMAX/(resolution/2); %k-space increment for full sampling

%Create structure that specifies gradient system
SYSTEM=GradSystemStructure(args.GradSystem);



%% Set up the parameters for the individual shells
[k_vd NofShells] = radial_sampling_density(Rrad0,RradMax,0,resolution/2);

shell_radii = KMAX*k_vd; %array of shell radii in [1/m], corresponds to kR from Eq.x
% NofShells = length(k_vd).

%Calculate parameter a for full sampling for each shell element
a_full = pi./asin((deltaK_full./(2*shell_radii))); %see Eq.x in paper

% slope of acceleration factor
Rp_ink=(RpolarMax- Rpolar0)/length(shell_radii(:));

if Rp_ink == 0
    Rp = Rpolar0*ones(1,length(a_full));
else
    Rp = Rpolar0 :Rp_ink:RpolarMax;
end
a_accelerated = a_full./Rp(1:length(a_full)); %Number of revolutions for each shell element (total undersample k-space)
a_polar= a_accelerated/Npolar; % interleaved acquisition in polar direction further decreases the number of revolutions per shot

%views with slightly shifted radii according to number Nradial
shell_radius_tmp = zeros(Nradial, size(shell_radii, 2));
for iradial = 1:Nradial
    shell_radius_tmp(iradial,:) = shell_radii - (iradial-1) * diff([0 shell_radii])/Nradial;
end
shell_radii = shell_radius_tmp;


%% Create all single elements ...

% ...with constant slew rate for all elements
if strcmp(args.SlewMode,'const')
    for iradial=1:Nradial
        sign=1;
        for elem=1:NofShells
            for ipolar=1:Npolar
                T(elem,ipolar,iradial)=single_element_shell(ceil(a_polar(elem)/2),shell_radii(iradial,elem),sign,SYSTEM,0);
                sign = -sign;
                T(elem,ipolar,iradial)=trajectStruct_rotate(T(elem,ipolar,iradial),(2*pi/Npolar)*(ipolar-1),[0 0 1]);
            end
        end
    end
end

% ... and with optimized (individual) slew rates for better PNS performance
if strcmp(args.SlewMode,'optim') % Jakobs method
    
    %store original gradient system structure
    SYSTEM_ORG = SYSTEM;
    
    for iradial=1:Nradial
        sign=1;
        for elem=1:NofShells
            % SYSTEM.SLEW = slew(elem); %T/m/s
            SYSTEM.SLEW = 400 * exp(-shell_radii(iradial, elem)/52) + 125;
%             if elem == NofShells    % davon ausgehend, dass dieser an Anfang gestellt wird
%                 SYSTEM.SLEW = SYSTEM.SLEW + 50;
%             end
            SYSTEM.SLEW = min(SYSTEM.SLEW, SYSTEM_ORG.SLEW);
            display(['slewrate = ', num2str(SYSTEM.SLEW)]);
            
            SYSTEM.SLEW_per_GRT = SYSTEM.SLEW*SYSTEM.GRT/1000; %[mT/m]
            SYSTEM.SLEW_per_GRT_SI = SYSTEM.SLEW*SYSTEM.GRT_SI; %[T/m];
            T(elem,1,iradial)=single_element_shell(ceil(a_polar(elem)/2),shell_radii(iradial,elem),sign,SYSTEM,0);
           
            sign = -sign;
            for ipolar=2:Npolar
                T(elem,ipolar,iradial)=trajectStruct_rotate(T(elem,1,iradial),(2*pi/Npolar)*(ipolar-1),[0 0 1]);
            end
        end
    end
end

display('All single elements created...')


%% sort elements for in-out-encoding
if TE > 0
    %determine sorting index for first interleave and view
    Ttmp=T(:,1,1);
    
    d=0;
    n=0;
    while d < TE
        d=d+Ttmp(end-n).duration;
%        d=d+Ttmp(n+1).duration;
        n=n+1;
    end
    n=n-1;
%V1
    sort_idx(1:n)=length(Ttmp):-1:length(Ttmp)-(n-1);
    sort_idx(n+1:length(Ttmp))=1:length(Ttmp)-n;

%V2/3
%    sort_idx(1:n) = n:-1:1;
%    sort_idx(n+1:length(Ttmp))=n+1:length(Ttmp);
%    sort_idx(n+1:length(Ttmp))=length(Ttmp):-1:n+1;
    
%V4
%    sort_idx(1) = floor(n/2)+1;
%    id = 1
%    while id<floor(n/2)+1
%        sort_idx(end+1) = floor(n/2)+1 - id;
%        sort_idx(end+1) = floor(n/2)+1 + id;
%        id = id + 1;
%    end
%    sort_idx = [sort_idx max(sort_idx)+1:length(Ttmp)];
    
%%%%%%%%%%%%%%%%%%%% This is experimental stuff:

% % ... and with optimized (individual) slew rates for better PNS performance
% if strcmp(args.SlewMode,'optim') % Jakobs method
%     
%     %store original gradient system structure
%     SYSTEM=GradSystemStructure(args.GradSystem);
%     SYSTEM_ORG = SYSTEM;
%     
%     for iradial=1:Nradial
%         sign=1;
%         for elem=1:NofShells
%             % SYSTEM.SLEW = slew(elem); %T/m/s
%             SYSTEM.SLEW = 400 * exp(-shell_radii(iradial, sort_idx(elem))/52) + 125;
% %             if elem == NofShells    % davon ausgehend, dass dieser an Anfang gestellt wird
% %                 SYSTEM.SLEW = SYSTEM.SLEW + 50;
% %             end
%             SYSTEM.SLEW = min(SYSTEM.SLEW, SYSTEM_ORG.SLEW);
%             display(['slewrate = ', num2str(SYSTEM.SLEW)]);
%             
%             SYSTEM.SLEW_per_GRT = SYSTEM.SLEW*SYSTEM.GRT/1000; %[mT/m]
%             SYSTEM.SLEW_per_GRT_SI = SYSTEM.SLEW*SYSTEM.GRT_SI; %[T/m];
%             T(elem,1,iradial)=single_element_shell(ceil(a_polar(sort_idx(elem))/2),shell_radii(iradial,sort_idx(elem)),sign,SYSTEM,0);
%            
%             sign = -sign;
%             for ipolar=2:Npolar
%                 T(elem,ipolar,iradial)=trajectStruct_rotate(T(elem,1,iradial),(2*pi/Npolar)*(ipolar-1),[0 0 1]);
%             end
%         end
%     end
% end

%%%%%%%%%%%%%%%%%%% vs:

    T = T(sort_idx,:,:);
end


%% ramp up first element
for iradial=1:Nradial
    for ipolar=1:Npolar
        temp = T(1,ipolar,iradial);
        T(1,ipolar,iradial) = trajectStruct_rampUp(T(1,ipolar,iradial));
        T(1,ipolar,iradial).index(1) = length(T(1,ipolar,iradial).G) - length(temp.G);
    end
end


%% connect elements for continous acquisition of k-space
for iradial =1:Nradial
    for ipolar=1:Npolar
        Tc(ipolar,iradial) = T(1,ipolar,iradial);
        alpha= args.alpha; % additional rotation between shell elements during continous acquisition of k-space
        for l=2:length(T(:,ipolar,iradial))
            Tc(ipolar,iradial) = trajectStruct_connect(Tc(ipolar,iradial),trajectStruct_rotate(T(l,ipolar,iradial),alpha*l,[0 0 1]));
        end
    end
end
display('...elements connected')


%% ramp down all elements
%make one array of trajectory elements that are acquired sequentially
T =Tc(:); %T(n) is a part of k-space that is acquired in one shot

for k=1:length(T)
    T(k).index(2) = length(T(k).G);
    T(k)=trajectStruct_rampDown(T(k));
end

%determine longest segments and zero fill all other elements for equal
% number of ADCs in sequence
points_max=0;
for k=1:length(T)
    points_max=max(points_max,size(T(k).K,1));
end

for k=1:length(T)
    if size(T(k).K,1) < points_max
        T(k) = trajectStruct_zeroFill(T(k),points_max - size(T(k).K,1));
    end
end



%% reorder gradient axis. slow gradients are on physical y-axis
if strcmp(args.SlewMode,'optim')
    for i = 1 : Nradial * Npolar
        T(i).SYS = SYSTEM_ORG;
        T(i).K = circshift(T(i).K, [0 2]);  % slow gradient should be y due to stimulation
        T(i).G = circshift(T(i).G, [0 2]);
    end
end


%% return information for trajectStruct_export
T(1).fov    = fov;
T(1).N      = resolution;
[~, te]    = min(makesos(T(1).K(200:end-200,:), 2));
T(1).TE    = (te + 200) * 10; % [us]

display('finished')