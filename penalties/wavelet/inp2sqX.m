function Y = inp2sqX(xDEC,level)
%INP2SQ In Place to "square" storage of coefficients.
%   Y = INP2SQ(xDEC,LEVEL) returns the "Square" storage
%   for a 2-D wavelet decomposition obtained by Lifting.
%
%   Example:
%      load woman; L = 3;
%      XinP = lwt2X(X,'db2',L);
%      Xsq  = inp2sqX(XinP,L);
%
%   See also ILWT2, LWT2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 25-May-2001.
%   Last Revision: 13-Sep-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

wname = 'dummy';
Y = lwtcoef2X('ca',xDEC,wname,level,level);
for k = level:-1:1
    H = lwtcoef2X('ch',xDEC,wname,level,k);
    V = lwtcoef2X('cv',xDEC,wname,level,k);
    D = lwtcoef2X('cd',xDEC,wname,level,k);
    Y = [Y , H ; V , D];
end
