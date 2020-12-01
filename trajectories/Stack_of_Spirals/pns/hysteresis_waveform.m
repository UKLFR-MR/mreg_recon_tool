function Ghyst = hysteresis_waveform(gmax,smax,gdt)
%HYSTERESIS_WAVEFORM
% Ghyst = hysteresis_waveform(gmax,smax,gdt)
% 
% Script to get a "standardized" gradient ramp, which can be used for
% hysteresis pulses. The short gradient pulse (<1ms) should be appended to
% the desired gradient waveform.
%
% Ghyst=MFM_Hysteresis_Waveform
%
% no INPUT:
% OUTPUT:   
% Ghyst     ... [T/m] Hysteresis gradient pulse, [1,#pts]
%
% (C)   08/2008  Florian.Wiesinger@research.ge.com
%  10/2008 Rolf Schulte: input G,S,gdt

if ~exist('gmax','var'), gmax=5e-3; end;    % [T/m] Gradient amplitude
if ~exist('smax','var'), smax=20;   end;    % [T/m/s] Gradient slew rate
if ~exist('gdt','var'),  gdt=4e-6;  end;    % [s] Gradient update time

N_ramp = ceil(gmax/smax/gdt);
S_ramp = gmax/(N_ramp*gdt);
Ghyst = [1:N_ramp]*gdt*S_ramp;
Ghyst = [Ghyst,fliplr(Ghyst)];
