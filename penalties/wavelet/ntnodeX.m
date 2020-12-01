function nb = ntnodeX(t)
%NTNODE Number of terminal nodes.
%   NB = NTNODE(T) returns the number of terminal nodes
%   in the tree T. 
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   See also WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.1 $

nb = wtreemgr('ntnodeX',t);