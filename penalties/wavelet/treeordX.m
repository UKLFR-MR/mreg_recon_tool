function order = treeordX(t)
%TREEORD Tree order.
%   ORD = treeordX(T) returns the order ORD of the tree T.
%
%   See also WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.1 $

order = wtreemgr('order',t);