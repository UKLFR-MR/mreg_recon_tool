function out=fff(in, dim)

if nargin==1
    s = size(in);
    f = find(s~=1);
    dim = f(1);
end

tmp1 = ifftshift(in,dim); clear in;
tmp2 = fft(tmp1,[],dim); clear tmp1;
out  = fftshift(tmp2,dim);