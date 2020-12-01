function [perfl2,perf0] = wscrupdX(c,l,n,thr,sorh)
%WSCRUPD Update Compression Scores using Wavelets thresholding.
%   For 1D case :
%   [PERFL2,PERF0] = WSCRUPD(C,L,N,THR,SORH) returns
%   compression scores induced by wavelet coefficients
%   thresholding of the decomposition structure [C,L]
%   (performed at level N) using level-dependent thresholds
%   contained in vector THR (THR must be of length N).
%   SORH ('s' or 'h') is for soft or hard thresholding
%   (see WTHRESH for more details).
%   Output arguments PERFL2 and PERF0 are L^2 recovery
%   and compression scores in percentages.
%
%   For 2D case :
%   [PERFL2,PERF0] = WSCRUPD(C,L,N,THR,SORH)
%   THR must be a matrix 3 by N containing the level
%   dependent thresholds in the three orientations
%   horizontal, diagonal and vertical.
%
%   See also WDENCMP, WCMPSCR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 31-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
% $Revision: 1.1 $

% Check arguments and set problem dimension.
if errargtX(mfilename,n,'int')
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end
if errargtX(mfilename,thr,'re0')
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end
if errargtX(mfilename,sorh,'str')
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end
dim = 1; if min(size(l))~=1, dim = 2; end

% Wavelet coefficients thresholding.
if dim == 1
    cxc = wthcoefX('t',c,l,1:n,thr,sorh);
else
    cxc = wthcoef2X('h',c,l,1:n,thr(1,:),sorh);
    cxc = wthcoef2X('d',cxc,l,1:n,thr(2,:),sorh);
    cxc = wthcoef2X('v',cxc,l,1:n,thr(3,:),sorh);
end

% Compute L^2 recovery and compression scores.
sumc2 = sum(c.^2);
if sumc2<eps
    perfl2 = 100;
else
    perfl2 = 100*(sum(cxc.^2)/sumc2);
end
perf0 = 100*(length(find(cxc==0))/length(cxc));

