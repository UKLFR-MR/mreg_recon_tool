function x = wrcoefX(o,c,l,varargin)
%WRCOEF Reconstruct single branch from 1-D wavelet coefficients.
%   WRCOEF reconstructs the coefficients of a 1-D signal,
%   given a wavelet decomposition structure (C and L) and
%   either a specified wavelet ('wname', see WFILTERS for more information) 
%   or specified reconstruction filters (Lo_R and Hi_R).
%
%   X = WRCOEF('type',C,L,'wname',N) computes the vector of
%   reconstructed coefficients, based on the wavelet
%   decomposition structure [C,L] (see WAVEDEC for more information),
%   at level N. 'wname' is a string containing the name of the wavelet.
% 
%   Argument 'type' determines whether approximation
%   ('type' = 'a') or detail ('type' = 'd') coefficients are
%   reconstructed.
%   When 'type' = 'a', N is allowed to be 0; otherwise, 
%   a strictly positive number N is required.
%   Level N must be an integer such that N <= length(L)-2. 
%
%   X = WRCOEF('type',C,L,Lo_R,Hi_R,N) computes coefficient
%   as above, given the reconstruction you specify.
%
%   X = WRCOEF('type',C,L,'wname') and
%   X = WRCOEF('type',C,L,Lo_R,Hi_R) reconstruct coefficients
%   of maximum level N = length(L)-2.
%
%   See also APPCOEF, DETCOEF, WAVEDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%	$Revision: 1.1 $

% Check arguments.
msg = nargchk(4,6,nargin);
if ~isempty(msg)
    error('Wavelet:FunctionInput:NbArg',msg)
end
o = lower(o(1));
rmax = length(l); nmax = rmax-2;
if o=='a', nmin = 0; else nmin = 1; end
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfiltersX(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1};  Hi_R = varargin{2}; next = 3;
end
if nargin>=(3+next) , n = varargin{next}; else n = nmax; end

if (n<nmin) || (n>nmax) || (n~=fix(n))
    error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
        'Invalid argument value.');
end

% Get DWT_Mode
dwtXATTR = dwtmodeX('get');

switch o
  case 'a'
    % Extract approximation.
    x = appcoefX(c,l,Lo_R,Hi_R,n);
    if n==0, return; end
    F1 = Lo_R;

  case 'd'
    % Extract detail coefficients.
    x = detcoefX(c,l,n);
    F1 = Hi_R;

  otherwise
    error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
        'Invalid argument value.');
end

imin = rmax-n;
x  = upsconv1X(x,F1,l(imin+1),dwtXATTR);
for k=2:n , x = upsconv1X(x,Lo_R,l(imin+k),dwtXATTR); end
