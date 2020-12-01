function out=ifff(in, dim)

if nargin==1
    s = size(in);
    f = find(s~=1);
    dim = f(1);
end

out=fftshift(ifft(ifftshift(in,dim),[],dim),dim);