function N = pnorm(T,P)
%PNORM Pseudo-norm for a Laurent polynomial.
%   For a Laurent polynomial T, N = PNORM(T,P) returns
%   the norm NORM(V,P) of the vector V which contains the 
%   the coefficients of T. So:
%       PNORM(T,P)    = sum(abs(V).^P)^(1/P).
%       PNORM(T,inf)  = max(abs(V)).
%       PNORM(T,-inf) = min(abs(V)).
%
%   N = PNORM(T) is equivalent to N = PNORM(T,2).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jul-2003.
%   Last Revision: 16-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:54:39 $

if nargin<2 , P = 2; end
N = norm(T.coefs,P);
