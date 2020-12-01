function x = nufft_adj_simple(y, scaling_factor, interpolation_matrix, Kd, Nd)

% usage:
%   y = nufft_adj_simple(x, scaling_factor, interpolation_matrix, Kd, Nd)
%
% This function returns the same result as nufft_adj.m (although not
% all features are supported), the difference is that the necessary
% data to calculate the result can be passed independently.  The
% arguments can be gained by calling nufft_init.m:
%
% if  nstr = nufft_init(om, Nd, Jd, Kd, nufft_shift, ...), then
% scaling_factor = nstr.sn
% interpolation_matrix = nstr.p
% Kd = nstr.Kd
% Nd = nstr.Nd

dims = size(y);

x = full(interpolation_matrix' * y);
x = reshape(x, [Kd 1]);
x = prod(Kd) * col(ifftn_fast(x));
x = reshape(x, [Kd 1]);

% eliminate zero padding from ends
if length(Nd) == 1
	x = x(1:Nd(1),:);
elseif length(Nd) == 2
	x = x(1:Nd(1),1:Nd(2),:);
elseif length(Nd) == 3
	x = x(1:Nd(1),1:Nd(2),1:Nd(3),:);
else
	error 'only up to 3D implemented currently'
end

x = reshape(x, [prod(Nd) 1]);
x = x .* conj(col(scaling_factor));
x = reshape(x, [Nd dims(2:end)]);
