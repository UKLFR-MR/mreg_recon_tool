function R = ne(A,B)
%NE Laurent polynomial inequality test.
%   NE(A,B) returns 1 if the two Laurent polynomials A and B
%   are different and 0 otherwise.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Mar-2001.
%   Last Revision: 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:54:39 $

R = ~eq(A,B);
