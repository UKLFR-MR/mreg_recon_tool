function m = wrmcoefX(o,c,l,varargin)
%WRMCOEF Reconstruct row matrix of single branches 
%   from 1-D wavelet coefficients.
%   M = WRMCOEF(O,C,L,W,N) computes the matrix of
%   reconstructed coefficients, based on the wavelet
%   decomposition structure [C,L], of levels given 
%   in vector N.
%   W is a string containing the wavelet name.
%   If O = 'a', approximation coefficients are reconstructed
%   and value 0 for level is allowed, else detail coefficients 
%   are reconstructed and only strictly positive values for
%   level are allowed.
%   Vector N must contains positive integers <= length(L)-2. 
%
%   M is the output matrix of reconstructed coefficients 
%   vectors stored row-wise.
%   
%   For M = WRMCOEF(O,C,L,Lo,Hi,N) 
%   Lo is the reconstruction low-pass filter and
%   Hi is the reconstruction high-pass filter.
%
%   M = WRMCOEF(O,C,L,W) or M = WRMCOEF(O,C,L,Lo,Hi) reconstructs 
%   coefficients of all possible levels.
%
%   See also APPCOEF, DETCOEF, WRCOEF, WAVEDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $

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
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end
if nargin>=(3+next), n = varargin{next}; else n = nmin:nmax; end
if find((n<nmin) | (n>nmax) | (n~=fix(n)))
    error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
        'Invalid level(s) value(s).');
end

% Initialization
if size(l,1)>1 , c = c'; l = l'; end
m = zeros(length(n),l(rmax));

% Get DWT_Mode
dwtXATTR = dwtmodeX('get');

switch o
    case 'a'
        for p = nmax:-1:0
            [c,l,a] = upwlevX(c,l,Lo_R,Hi_R);
            j = find(p==n);
            if ~isempty(j)
                % Approximation reconstruction.
                imin   = length(l)-p;
                nbrows = length(j);
                m(j,:) = ReconsCoefs(a,Lo_R,Lo_R,l,imin,p,nbrows,dwtXATTR);
            end
        end

    case 'd'
        for p = 1:nmax
            j = find(p==n);
            if ~isempty(j)
                % Extract detail coefficients.
                d = detcoefX(c,l,p);

                % Detail reconstruction.
                imin   = rmax-p;
                nbrows = length(j);
                m(j,:) = ReconsCoefs(d,Hi_R,Lo_R,l,imin,p,nbrows,dwtXATTR);
            end
        end

    otherwise
        error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
            'Invalid argument value.');
end


%--------------------------------------------------------%
% Internal Function(s)
%--------------------------------------------------------%
function x = ReconsCoefs(x,f1,f2,l,i,p,n,dwtXATTR)
if p>0
    x  = upsconv1X(x,f1,l(i+1),dwtXATTR);
    for k=2:p , x = upsconv1X(x,f2,l(i+k),dwtXATTR); end
end
x = x(ones(n,1),:);
