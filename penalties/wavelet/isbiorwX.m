function R = isbiorwX(wname)
%ISBIORW True for a biorthogonal wavelet.
%   R = ISBIORW(W) returns 1 if W is the name of 
%   a biorthogonal wavelet and 0 if not.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Jun-2003.
%   Last Revision 20-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $ 

R = wavetypeX(wname,'bior');
