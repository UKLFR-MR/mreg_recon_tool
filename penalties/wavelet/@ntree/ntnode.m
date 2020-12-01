function nb = ntnode(t)
%NTNODE Number of terminal nodes.
%   NB = NTNODE(T) returns the number of terminal nodes
%   in the tree T. 
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   See also WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-May-2003.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:55:17 $

nb = length(t.tn);
