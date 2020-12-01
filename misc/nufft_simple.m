function y = nufft_simple(x, scaling_factor, interpolation_matrix, Kd)

% usage:
%   y = nufft_simple(x, scaling_factor, interpolation_matrix, Kd)
%
% This function returns the same result as nufft.m (although not
% all features are supported), the difference is that the necessary
% data to calculate the result can be passed independently.  The
% arguments can be gained by calling nufft_init.m:
%
% if  nstr = nufft_init(om, Nd, Jd, Kd, nufft_shift, ...), then
% scaling_factor = nstr.sn
% interpolation_matrix = nstr.p
% Kd = nstr.Kd

y = x .* scaling_factor;
y = col(fftn_fast(y, Kd));
y = interpolation_matrix * y;
