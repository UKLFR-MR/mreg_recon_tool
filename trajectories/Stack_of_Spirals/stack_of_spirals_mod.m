function T = stack_of_spirals(R,N,fov,resolution, sphericity, pf)

%% usage: T = stack_of_spirals(R,Nradial,Nz,fov,resolution, pf)

%% INPUT:
% R = reduction factor: [Rrad_min Rrad_max Rz_min Rz_max]
%   to set FOV_z smaller simply increas Rz
% N: spiral interleaves
% fov in m: [r z] It is set unisotropic to radial- and z-fov
% resolution in m: (!!! This definition is different to Benni's shells !!!)
%           This is only implemented for isotropic resolution but could 
%           easily be made unisotropic by changing kz_max
% pf:       Partial Fourier factor. If you don't want to use partial
%           fourier, use one or leave empty. 0.5 is half Fourier, 1 is full
%           sampling etc. K-space is cut of at the beginning.
% alt_order: If 1, the aquisition direction in z is alternated every other
%            step. Otherwise choose 0 or leave empty.

%% OUTPUT:
% T: Trajectory struct (defined in Benni's toolbox)

% Jakob Asslaender August 2011
% modded and improved by Bruno Riemenschneider 2015

Rrad_min = R(1);
Rrad_max = R(2);
Rz_min   = R(3);
Rz_max   = R(4);

slew_max = 170;
SYSTEM=GradSystemStructure('custom', [], slew_max);
%SYSTEM=GradSystemStructure('fast');


%% Definition of the size of k-space
k_max = 1/(2*resolution);     % 1D edge of k-space in 1/m
kz(1) = 0;
kr_max(1) = k_max;
i = 1;
kz(i+1) = min(kz(i) + (Rz_min + kz(i)/k_max * (Rz_max - Rz_min))/fov(2), k_max);
kr_max(i+1) = max(sqrt(kr_max(1)^2 - sphericity*kz(i+1)^2), k_max/10);
i = i + 1;
kz_shift = 0; % (kz(2) - kz(1))/Nz;
while kz(i) < k_max-kz_shift*(N-1)/2
    kz(i+1) = min(kz(i) + (Rz_min + kz(i)/k_max * (Rz_max - Rz_min))/fov(2), k_max);
    kr_max(i+1) = max(sqrt(kr_max(1)^2 - sphericity*kz(i+1)^2), k_max/10);
    i = i + 1;
end
kz = [kz(end:-1:2), -kz];
kr_max = [kr_max(end:-1:2), kr_max];

%% Inversion to demonstrate different offresonance behavior
% kz = kz(end:-1:1);

%% Create all single spirals
for iz=1%:Nz
    ikz = kz+kz_shift*(-(N-1)/2+iz-1);
    in_out = 1 - mod(size(kz,2)-1, 4);
%    in_out = in_out*(-1);
%    in_out = -1;
    for element = 1:length(kz)
        Rmin = (Rrad_min + abs(kz(element)/k_max) * (Rrad_max - Rrad_min));
        Rmax = Rrad_max;
        T(element, iz, 1) = single_element_spiral(ikz(element), kr_max(element), Rmin, Rmax, fov(1), in_out, SYSTEM);
%        T(element, iz, 1) = single_element_spiral(ikz(element), kr_max(element), Rrad_min, Rrad_max, fov(1), in_out, SYSTEM);
%        T(element, iz, 1) = single_element_spiral_wave(ikz(element), kr_max(element), Rmin, Rmax, fov(1), in_out, SYSTEM);
        
        % calculate the angle between the direction of the end of the
        % of one and the beginning of the next spiral and rotate the second
        % one to match.
        
        if element > 1
            last2 = T(element-1,iz,1).K(end-1:end,1)+ 1i * T(element-1,iz,1).K(end-1:end,2);
            first2 = T(element,iz,1).K(1:2,1)+ 1i* T(element,iz,1).K(1:2,2);
            alpha = angle(diff(last2,1,1)) - angle(diff(first2,1,1));
%            alpha = pi/Nz*element;
%            T(element, iz, 1) = trajectStruct_rotate(T(element,iz,1),alpha+pi,[0 0 1]);
            T(element, iz, 1) = trajectStruct_rotate(T(element,iz,1),alpha+pi*1.75,[0 0 1]);

            %needed to sample k = 0 after connection by 'ripping':
%             extra = 4;
%             if (in_out==1)
%                 T(element, iz, 1).K = [zeros(extra,3); T(element, iz, 1).K];
%                 T(element, iz, 1).G = [zeros(extra,3); T(element, iz, 1).G];
%             else
%                 T(element, iz, 1).K = [T(element, iz, 1).K; zeros(extra,3)];
%                 T(element, iz, 1).G = [T(element, iz, 1).G; zeros(extra,3)];
%             end
        end

        extra = 4;
        if element == (length(kz)+1)/2
            %needed to sample k = 0 after connection by 'ripping':
            T(element, iz, 1).K = [zeros(extra,3); T(element, iz, 1).K];
            T(element, iz, 1).G = [zeros(extra,3); T(element, iz, 1).G];
        end
        
%         if (mod(element,2)==0)
%             %needed to sample k = 0 after connection by 'ripping':
%             T(element, iz, 1).K = [zeros(extra,3); T(element, iz, 1).K];
%             T(element, iz, 1).G = [zeros(extra,3); T(element, iz, 1).G];
%         else
%             T(element, iz, 1).K = [T(element, iz, 1).K; zeros(extra,3)];
%             T(element, iz, 1).G = [T(element, iz, 1).G; zeros(extra,3)];            
%         end
        
        in_out = -in_out;
    end
end
display('All single elements created...')

% T(end).SYS = GradSystemStructure('custom', [], 100);
% T(end-2).SYS = GradSystemStructure('custom', [], 100);


%% Partial Fourier
if nargin > 5 && ~isempty(pf)
    if kz(1) > 0
        T = T(kz <=  k_max * 2*(pf-0.5),:,:);
    elseif kz(1) < 0
        T = T(kz >= -k_max * 2*(pf-0.5),:,:);
    end
end

%% ramp up first element
for iradial=1%:Nradial
    for iz=1%:Nz
        temp = T(1,iz,iradial);
        T(1,iz,iradial) = trajectStruct_rampUp(T(1,iz,iradial));
        T(1,iz,iradial).index(1) = length(T(1,iz,iradial).G) - length(temp.G);
    end
end

%% connect elements by bending the endings ('rip' mode).
for iradial =1%:Nradial
    for iz=1%:Nz
        Tc(iz,iradial) = T(1,iz,iradial);
        for element=2:size(T, 1)
%            Tc(iz,iradial) = trajectStruct_connect_rotate(Tc(iz,iradial),T(element,iz,iradial), 'rip');
%            Tc(iz,iradial) = trajectStruct_connect_inout(Tc(iz,iradial),T(element,iz,iradial), 'rip');
            Tc(iz,iradial) = trajectStruct_connect(Tc(iz,iradial),T(element,iz,iradial), 'rip');
        end
    end
end

display('...elements connected')
T =Tc(:);

for iz=2:N
    T(iz) = T(1);
    T(iz) = trajectStruct_rotate(T(iz),(2*pi/N)*(iz-1),[0 0 1]);
end
% every second shot inverted:
% for iz=2:Nz
%     T(iz) = T(1);
%     T(iz) = trajectStruct_rotate(T(iz),(2*pi/Nz*2)*(iz-1),[0 0 1]);
%     if mod(iz,2)
%         T(iz).G = T(iz).G(end:-1:1,:);        
%         T(iz).G(:,3) = -T(iz).G(:,3);        
%     end
% end

%% ramp down last element
for k=1:length(T)
    T(k).index(2) = length(T(k).G);
    T(k)=trajectStruct_rampDown(T(k));
    
end

%% determine longest segments
points_max=0;
for k=1:length(T)
    points_max=max(points_max,size(T(k).K,1));
end

for k=1:length(T)
    if size(T(k).K,1) < points_max
        T(k) = trajectStruct_zeroFill(T(k),points_max - size(T(k).K,1));
    end
end

%% return information for trajectStruct_export
for i=1:length(T)
    T(i).fov    = [fov(1) fov(1) fov(2)];
    T(i).N      = T(i).fov/resolution;
    % The 200 makes sure that not beginning of the trajectory (which usually is in the k-space center) does not count as TE
    [~, te]    = min(makesos(T(i).K(200:end-200,:), 2));  % The Echotime of the first trajectory is taken. Hopefully they are all similar...
    T(i).TE    = (te + 200) * 10; % [us]
end

% T.K = [T.K(:,2), T.K(:,3), T.K(:,1)];
% T.G = [T.G(:,2), T.G(:,3), T.G(:,1)];


display('finished')