function a = appcoef2X(c,s,varargin)
%APPCOEF2 Extract 2-D approximation coefficients.
%   APPCOEF2 computes the approximation coefficients of a
%   two-dimensional signal.
%
%   A = APPCOEF2(C,S,'wname',N) computes the approximation
%   coefficients at level N using the wavelet decomposition
%   structure [C,S] (see WAVEDEC2).
%   'wname' is a string containing the wavelet name.
%   Level N must be an integer such that 0 <= N <= size(S,1)-2.
%
%   A = APPCOEF2(C,S,'wname') extracts the approximation
%   coefficients at the last level size(S,1)-2.
%
%   Instead of giving the wavelet name, you can give the filters.
%   For A = APPCOEF2(C,S,Lo_R,Hi_R) or
%   A = APPCOEF2(C,S,Lo_R,Hi_R,N),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
%
%   NOTE: If C and S are obtained from an indexed image analysis
%   (respectively a truecolor image analysis) then A is an
%   m-by-n matrix (respectively  an m-by-n-by-3 array).
%   For more information on image formats, see the reference
%   pages of IMAGE and IMFINFO functions.
%   
%   See also DETCOEF2, WAVEDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 24-Jan-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
% $Revision: 1.1 $

% Check arguments.
msg = nargchk(2,5,nargin);
if ~isempty(msg)
    error('Wavelet:FunctionInput:NbArg',msg)
end
rmax = size(s,1);
nmax = rmax-2;
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfiltersX(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end
if nargin>=(2+next) , n = varargin{next}; else n = nmax; end
if (n<0) || (n>nmax) || (n~=fix(n))
    error('Wavelet:DecompositionLevel:ArgumentValue',...
        'Invalid level value.');
end

% Initialization.
nl   = s(1,1);
nc   = s(1,2);
if length(s(1,:))<3 , dimFactor = 1; else dimFactor = 3; end;
a    = zeros(nl,nc,dimFactor);
a(:) = c(1:nl*nc*dimFactor);

% Iterated reconstruction.
rm   = rmax+1;
for p=nmax:-1:n+1
    [h,v,d] = detcoef2X('all',c,s,p);
    a = idwt2X(a,h,v,d,Lo_R,Hi_R,s(rm-p,:));
end

% If true color image.
% if n==0 && ndims(a)>2
%     a(a<0) = 0;
%     a = uint8(a);
% end
