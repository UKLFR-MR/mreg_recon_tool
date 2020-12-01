function Y = smooth2(X,filt,varargin)

switch filt
    case {'gauss','gaussian'}
        q = gauss_kernel([7 7],0.8);
end

Y = conv2(X,q,'same');