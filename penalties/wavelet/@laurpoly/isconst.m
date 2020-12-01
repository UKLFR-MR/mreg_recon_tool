function R = isconst(P)
%ISCONST True for a constant Laurent polynomial.
%   R = ISCONST(P) returns 1 if P is a constant Laurent polynomial
%   and 0 if not.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 23-Apr-2001.
%   Last Revision 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:54:39 $ 

D = P.maxDEG;
C = length(P.coefs);
R = (D==0) && length(C)==1;