function F = inline(P)
%INLINE Construct an INLINE object associated to a Laurent Polynomial.
%   F = INLINE(P) returns an inline object associated to the
%   Laurent Polynomial P.
%   
%   Example:
%      PL = laurpoly([-1 1],1)
%      PI = inline(PL)
%      p0 = PI(0)
%      p1 = PI(1)
   
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 16-Jun-2003.
%   Last Revision: 03-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:54:39 $

F = inline(lpstr(P,Inf));
