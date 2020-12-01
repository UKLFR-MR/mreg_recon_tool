function [a,d] = hlwtX(x,integerFlag)
%HLWT Haar (Integer) Wavelet decomposition 1-D using liftingX.
%
%     [a,d] = hlwtX(x) or
%     [a,d] = hlwtX(x,integerFlag)
%     Dans le cas 2, on a une transformation en entiers
%     modulo la normalisation.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-Jan-2000.
%   Last Revision 16-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $ 

% Test si transformation en entiers.
notInteger = nargin<2;

% Splitting.
a = x(2:2:end);
d = x(1:2:end);

% Lifting.
d = d-a;              % Dual liftingX.
if notInteger
    a = (a+d/2);      % Primal liftingX.
    d = d/2;          % Normalization.
else
    a = (a+fix(d/2)); % Primal liftingX.
end
