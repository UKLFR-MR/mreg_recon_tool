function y = wunique(x)
%WUNIQUE Set unique.
%    WUNIQUE(A) for the array A returns the same values as in A 
%    but with no repetitions. A will also be sorted.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-May-2003.
%   Last Revision: 25-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:54:55 $

if isempty(x) , y = []; return; end
y = sort(x);
d = diff(y);
J = 1 + find(d>0);
K = [1 ; J(:)];
y = y(K);

