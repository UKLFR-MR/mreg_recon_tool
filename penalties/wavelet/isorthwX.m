function R = isorthwX(wname)
%ISORTHW True for an orthogonal wavelet.
%   R = ISORTHW(W) returns 1 if W is the name of 
%   an orthogonal wavelet and 0 if not.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Jun-2003.
%   Last Revision 20-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $ 

R = wavetypeX(wname,'orth');
