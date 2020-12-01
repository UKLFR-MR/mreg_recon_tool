function P = prod(varargin)
%PROD Product of Laurent polynomials.
%   P = PROD(P1,P2,...) returns a Laurent polynomial  
%   which is the product of the Laurent polynomials Pi.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-Mar-2003.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:54:39 $ 

nbIn = nargin;
if nbIn<1
    error('Wavelet:FunctionInput:NotEnough_ArgNum', ...
        'Not enough input arguments.');
end
P = varargin{1};
for k = 2:nbIn
    P = P * varargin{k};
end
