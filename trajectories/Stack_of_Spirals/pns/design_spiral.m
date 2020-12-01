function [k,dcf,t,ind,out]=design_spiral(fov,npix,arms,ksamp,...
    fname,gmax,smax,nucleus)
%DESIGN_SPIRAL Design a spiral with delayed acq for fast CSI
%[k,dcf,t,ind,out]=design_spiral(fov,npix,arms,ksamp,...
%    fname,gmax,smax,nucleus)
%
%     fov  field of view                                  [mm]
%    npix  #pixels (Cartesian resolution after gridding)
%    arms  #spatial arms (def=1)
%   ksamp  k-space sampling time (opt; default=16)        [us]
%   fname  filename (if given->write_ak_wav) (true: generate name)
%    gmax  max gradient amp (opt; def=40)                 [mT/m]
%    smax  max slew rate (opt; def=150)                   [T/m/s]
% nucleus  default: '13C'
%
%       k  k-space trajectory  [-0.5..0.5]
%     dcf  density compensation function (calculated with vornoi_area)
%       t  time  (nexc x recon-pts)
%     ind  index (2nd dim) for k-space points on spiral (excl ramps, etc)
%     out  output structure of wrt_wavs
%
% 3/2011 Rolf Schulte
% 6/2013 RFS: modified to write_ak_wav.m
if (nargin<1), help(mfilename); return; end;

fufa_rew_gmax = 0.98;
fufa_rew_smax = 0.98;
fufa_vds_gmax = 0.99;
fufa_vds_smax = 0.99;
g_offset = 16;                          % #grad pts offset for start of traj

if ~exist('arms','var'), arms = []; end;    % #spatial arms
if isempty(arms), arms = 1; end
if ~exist('ksamp','var'), ksamp = []; end;  % [s] k-space sampling time
if isempty(ksamp), ksamp = 16; end
if ksamp<2, warning('dcs:ksamp','ksamp(=%g)<2',ksamp); input(''); end
if ~exist('fname','var'), fname = []; end;  % for waveform file
if ~exist('gmax','var'), gmax = []; end
if isempty(gmax), gmax = 40; end;           % [mT/m] max gradient amplitude
if gmax<1, warning('dcs:gmax','gmax(=%g)<1',gmax); input(''); end
if ~exist('smax','var'), smax = []; end
if isempty(smax), smax = 150; end;          % [T/m/s] max slew rate
if ~exist('nucleus','var'), nucleus = '13C'; end;

if fov<1, warning('dcs:fov','fov(=%g)<1',fov); input(''); end
if (islogical(fname) || isnumeric(fname)),
    if fname,
        if isnumeric(nucleus), error('Please enter string for nucleus'); end
        fname = sprintf('spiral_%s_fov%g_npix%g_arms%g_ksamp%g_gmax%g_smax%g', ...
            nucleus,round(fov),npix,arms,ksamp,round(gmax),round(smax));
    else
        fname = [];
    end
end

fov = fov*1d-3;           % [mm] -> [m]
ksamp = ksamp*1d-6;       % [us] -> [s]
gmax = gmax*1d-3;         % [mT/m] -> [T/m]
res = fov/npix;           % [m] resolution
gsamp = 10e-6;             % [s] gradient update time

dki = ksamp/gsamp;
if dki<0.5,
    error('ksamp: dki<0.5');
end
if (abs(dki-round(dki))>1d-10)
    if abs(dki-0.5)>1d-10,
        error('ksamp (=%g us) not multiple of gsamp (=%g us)',...
            ksamp*1d6,gsamp*1d6);
    end
else
    dki = round(dki);
end
k_offset = g_offset/dki;

% Hysteresis gradient
ghyst = hysteresis_waveform(gmax/sqrt(2),smax/sqrt(2),gsamp);
ghyst = [zeros(1,100),ghyst*(1+1i),zeros(1,100)];

%===========
% CSI Spiral
%===========
rgamma = abs(gyrogamma('1h')/gyrogamma(nucleus));
fov_c13 = fov/rgamma;
res_c13 = res/rgamma;
fprintf('gamma ratio=%g\n',rgamma);
fprintf('scaled FOV (fov_c13)=%g\n',fov_c13); 
fprintf('scaled res (res_c13)=%g\n',res_c13);
gmax_nyquist = 2*pi/(gyrogamma('1h')*ksamp*fov_c13);
fprintf('gmax_nyquist = %g [mT/m]\n',gmax_nyquist*1d3);
if (gmax_nyquist<gmax),
    fprintf('Attention: approaching sampling BW limited regime\n');
    if (ksamp>gsamp), 
        fprintf('!!! Undersampling will occur: reduce ksamp !!!\n'); 
        input('press key to continue');
    end
end
pause(1);
[k1,g1,s1,t1,r1,theta1] = vds(fufa_vds_smax*smax*1e2,fufa_vds_gmax*gmax*1e2,gsamp, ...
   arms,[fov_c13*1e2,0],1/(2*res_c13*1e2));

% calculate single interleave
gtmp = 1e-2*g1;
ktmp = gyrogamma('1h')*gsamp*cumsum(gtmp);

% rewinders
grewx = gradient_clip_offset(real(gtmp(end)),-real(ktmp(end)),...
    1/gsamp/2,fufa_rew_gmax*gmax/sqrt(2),fufa_rew_smax*smax/sqrt(2));
grewy = gradient_clip_offset(imag(gtmp(end)),-imag(ktmp(end)),...
    1/gsamp/2,fufa_rew_gmax*gmax/sqrt(2),fufa_rew_smax*smax/sqrt(2));

grew = zeros(1,max(length(grewx),length(grewy)));
grew(1:length(grewx)) = 1*grewx;
grew(1:length(grewy)) = grew(1:length(grewy))+1i*grewy;

g3 = [gtmp,gtmp(end),grew].';
nk = round(length(ktmp)/dki);


% delay grad, calculate time and index list
g = zeros(g_offset+length([g3.',ghyst]),arms);
acq_pts = 2^ceil(log2(length(g)/dki));
if acq_pts>16384
    warning('dcs:acq','#sampling pts/exc (=%g)>16384: exceeds fidall limit',nk);
end
t = NaN(arms,nk);                      % time of acq pts
ind = false(arms,acq_pts);             % index for acquired data 


for ll=1:arms,
    g((g_offset+1):g_offset+length([g3.',ghyst]),ll) = ...
        [g3*exp(1i*(ll-1)/arms*2*pi);ghyst.'];
    t(ll,:) = (0:nk-1)*ksamp;
    ind(ll,(k_offset+(1:nk))) = true;
end

% k-space trajectory
if dki>1, k = ktmp(1:dki:length(ktmp))/2/pi*res_c13; 
else k = ktmp/2/pi*res_c13;
end
if abs(dki-0.5)<1d-10, 
    k = interp1((1:length(k)),k,(1:0.5:length(k)+0.5),'spline');
end
if arms>1,
    tmp = [];
    for l=1:arms, tmp = [tmp , k*exp(1i*(l-1)/arms*2*pi)]; end
    k = tmp;
end
dcf = voronoi_area(k*npix);       % density compensation function

% print info about waveform
desc1 = sprintf('Sequence details\n');
desc2 = sprintf('Acq BW = %g [kHz] (full)\n',1d-3/ksamp);
desc3 = sprintf('gsamp = %g [us]; ksamp = %g [us]\n',gsamp*1d6,ksamp*1d6);
desc4 = sprintf('g_pts = %gx%g; k_pts = %g; acq_pts/exc = %g\n',...
    size(g,1),size(g,2),size(k,2),acq_pts);
t_arm = t1(end); t_rew = (length(grew)+1)*gsamp;
desc5 = sprintf('t_arm = %g [ms]; t_rew = %g [ms]\n',t_arm*1d3,t_rew*1d3);
desc6 = sprintf('t_seq = %g [ms]',size(g,1)*gsamp*1d3);
desc7 = sprintf(' = %g [ms] (w/o hyst grad)\n',...
    (size(g,1)-length(ghyst))*gsamp*1d3);
desc = [desc1 desc2 desc3 desc4 desc5 desc6 desc7];
fprintf('\n%s\n',desc);

% checks
if any(size(dcf)~=size(k)),  
    warning('design_spiral:size','size(dcf)~=size(k): interpolating dcf'); 
    dcf = interp1(linspace(0,1,size(dcf,2)),dcf,linspace(0,1,size(k,2)));
end
if size(k)~=sum(ind(:)),     error('size(k)~=sum(ind(:))'); end
if prod(size(t))~=size(k,2), error('prod(size(t))~=size(k,2)'); end

% export waveforms
if ~isempty(fname),
    fprintf('\nWriting out gradient waveforms + .mat\n');
    fprintf('fname = %s\n',fname);
    out = write_ak_wav([fname '.wav'],g,1/ksamp,fov_c13,desc);
    save(fname,'out','k','dcf','t','ind','fov',...
        'npix','gsamp','ksamp','gmax','smax','nucleus',...
        't_rew','t_arm','g_offset','gmax_nyquist','rgamma','fov_c13');
else
    out.gmax = gmax;
    out.smax = smax;
    out.gdt = gsamp;
    out.kdt = ksamp;
    out.grad = g;
    out.bw = 1/ksamp;
    out.fov = fov;
end
