function [LoD,HiD,LoR,HiR] = ls2filtX(LS)
%LS2FILT Lifting scheme to filters.
%   [LoD,HiD,LoR,HiR] = LS2FILT(LS) returns the four
%   filters associated to the liftingX scheme LS.
%
%   See also FILT2LS, LSINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Jul-2003.
%   Last Revision: 09-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

[LoD,HiD,LoR,HiR] = ls2filtersX(LS,'d_num');
