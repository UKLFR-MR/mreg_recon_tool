function POW = powers(P,type)
%POWERS Powers of a Laurent polynomial.
%   POW = POWERS(P) returns the powers of all monomials
%   of the Laurent polynomial P.
%   POW = POWERS(P,'min') and POW = POWERS(P,'max') returns  
%   the lowest, the biggest, power of the monomials of P 
%   respectively.
%
%   See also DEGREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Jun-2003.
%   Last Revision: 02-Nov-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:54:39 $ 

C = P.coefs;
powMAX = P.maxDEG;
powMIN = powMAX-length(C)+1;
if nargin<2 , type = 'all'; end
switch lower(type)
    case 'all' , POW = powMIN:powMAX;
    case 'min' , POW = powMIN;
    case 'max' , POW = powMAX;
    otherwise
        error('Wavelet:Invalid_ArgVal', ...
            'Invalid argument value for ARG 2.')
end
