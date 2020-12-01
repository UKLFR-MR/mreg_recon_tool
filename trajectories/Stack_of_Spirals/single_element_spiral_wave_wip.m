function T = single_element_spiral(kz, kr_max, Rmin, Rmax, fov, in_out, SYSTEM)

%% function T = single_element_spiral(kz, kr_max, Rmin, Rmax, fov, in_out, SYSTEM)
% Wrapper function for vds.m

% Jakob Asslaender, August 2011

% inputs need to be in G, cm, s, outputs are the same
% [k,g,s,time,r,theta] = vds(SYSTEM.SLEW*100,SYSTEM.GMAX_SI*100,SYSTEM.GRT_SI,1,[100*fov/Rmin 100*fov/Rmax-100*fov/Rmin], kr_max/100);

[k,g,s,time,r,theta] = vds_pns(SYSTEM.SLEW*100,SYSTEM.GMAX_SI*100,SYSTEM.GRT_SI,1,[100*fov/Rmin 100*fov/Rmax-100*fov/Rmin], kr_max/100, 65, 334e-6, 70);

% npix = fov*2*kr_max;
% [k,dcf,t,ind,out]=design_spiral(fov*1000,npix,1,SYSTEM.GRT_SI*1e6,0,SYSTEM.GMAX,SYSTEM.SLEW,'1h');


k = [0 k]*100; % convertion from rad/cm to rad/m
g = g/100; % convertion from G/cm to T/m

if in_out == 1
    K = [real(k)' imag(k)' kz*ones(size(k, 2), 1)];
    G = [real(g)' imag(g)'   zeros(size(g, 2), 1)];
elseif in_out == -1
    K = [real(k(end:-1:1))' imag(k(end:-1:1))' kz*ones(size(k, 2), 1)];
    G = [-real(g(end:-1:1))' -imag(g(end:-1:1))'   zeros(size(g, 2), 1)];
    K = [real(k(end:-1:1))' -imag(k(end:-1:1))' kz*ones(size(k, 2), 1)];
    G = [-real(g(end:-1:1))' imag(g(end:-1:1))'   zeros(size(g, 2), 1)];
else
    error('single_element_spiral:in_out', 'in_out must be either 1 for inside out or -1 for outside in');
end

n = 4;
a = 1/length(G)*2*pi;
a = a*n;
b = .000*n;
G(:,3) = b*sin(pi/2+[1:length(G)]*a);

kx = [K(1,1); K(1,1)+cumsum(G(:,1))*SYSTEM.GRT_SI*SYSTEM.GAMMA_SI/(2*pi)];
ky = [K(1,2); K(1,2)+cumsum(G(:,2))*SYSTEM.GRT_SI*SYSTEM.GAMMA_SI/(2*pi)];
kz = [K(1,3); K(1,3)+cumsum(G(:,3))*SYSTEM.GRT_SI*SYSTEM.GAMMA_SI/(2*pi)];

K = [kx ky kz];


T = trajectStruct_init(K,G,SYSTEM);
T.in_out = in_out;
