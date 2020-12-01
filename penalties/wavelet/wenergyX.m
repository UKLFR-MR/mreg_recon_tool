function [Ea,Ed] = wenergyX(C,L)
%WENERGY Energy for 1-D wavelet decomposition.
%   For a one dimensional wavelet decomposition [C,L],  
%   (see WAVEDEC) [Ea,Ed] = WENERGY(C,L) returns Ea,  
%   which is the percentage of energy corresponding to
%   the approximation and Ed, which is the vector containing 
%   the percentages of energy corresponding to the details.
%
%   Example:
%     load noisbump
%     [C,L] = wavedecX(noisbump,4,'sym4');
%     [Ea,Ed] = wenergyX(C,L)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $

Et = sum(C.^2);
level = length(L)-2;
Ca = C(1:L(1));
Cd = detcoefX(C,L,'cells');
Ea = 100*sum(Ca.^2)/Et;
for k=1:level , Ed(k) = 100*sum(Cd{k}.^2)/Et; end