function H = fspecial3D(type, hsize, sigma)

hsize = (hsize-1)/2;

if nargin<=2
    sigma = 1;
end

if strcmp(type,'gauss') || strcmp(type,'gaussian')
    [X,Y,Z] = ndgrid(-hsize(2):hsize(2),-hsize(1):hsize(1),-hsize(3):hsize(3));
    H = exp(-(X.*X + Y.*Y + Z.*Z)/2/sigma^2);
    H = H/sum(H(:));
end