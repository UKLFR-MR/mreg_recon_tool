function P = prod(varargin)
%PROD Product of Laurent matrices.
%   P = PROD(M1,M2,...) returns a Laurent matrix which is
%   the product of the Laurent matrices Mi.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-May-2003.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:54:03 $ 

nbIn = nargin;
if nbIn<1
    error('Wavelet:FunctionInput:NotEnough_ArgNum', ...
        'Not enough input arguments.');
end
P = varargin{1};
for k = 2:nbIn
    P = P * varargin{k};
end
