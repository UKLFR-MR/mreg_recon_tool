 function q = gauss_kernel(dim, w, how)
 
% function q = gauss_kernel(w, dim, how)
%
% Symmetric gaussian kernel with given width "w" in pixels and dimension "dim".
% The kernel is normalized by the sum of the kernel
%
% arguments:
% dim = array size of the kernel
% w = width of the gaussian function
% how = measure of the width of the gaussian
%       "fwhm" (full width at half maximum) or "sd" (standard deviation = default)
%       Note: MATLABs function "fspecial" uses the standard deviation.
%
% Thimo Hugger
% 15.09.2011


if nargin<=1 || isempty(w)
    w = 1;
end
if nargin<=2 % 
    how = 'sd';
end

if isscalar(w)
    w = repmat(w, [1 length(dim)]);
end

switch how
    case 'fwhm'
        c = w/(2*sqrt(2*log(2))); % relates the FWHM to the standard deviation of the gaussian
    case 'sd'
        c = w;
end

if length(dim)==1
    x = [0:dim-1]-(dim-1)/2;
    q = exp(-0.5*x.^2/c^2);
    q = q / sum(q(:));
    
elseif length(dim)==2
    [x,y] = meshgrid([0:dim(2)-1]-(dim(2)-1)/2,[0:dim(1)-1]-(dim(1)-1)/2);
    q = exp(-0.5*x.^2/c(2)^2).*exp(-0.5*y.^2/c(1)^2);
    q = q / sum(q(:));

elseif length(dim)==3
    [x,y,z] = meshgrid([0:dim(2)-1]-(dim(2)-1)/2,[0:dim(1)-1]-(dim(1)-1)/2,[0:dim(3)-1]-(dim(3)-1)/2);
    q = exp(-0.5*x.^2/c(2)^2).*exp(-0.5*y.^2/c(1)^2).*exp(-0.5*z.^2/c(3)^2);
    q = q / sum(q(:));
    
else
    error('Dimensions higher than 3 are not implemented yet.');
    
end
