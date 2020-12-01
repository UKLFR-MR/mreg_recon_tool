function nums = locnumcn(nodes,order)
%LOCNUMCN Local number for a child node.
%   NUMS = LOCNUMCN(NODES,ORDER)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jun-98.
%   Last Revision: 16-Jul-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:54:55 $

if order==0 , nums = 1; return; end 
nums  = nodes-order*floor((nodes-1)/order);
%-------------------------
% nums = rem(nodes,order);
% nums(nums==0) = order;
%-------------------------
