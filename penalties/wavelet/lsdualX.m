function LSR = lsdualX(LS)
%LSDUAL Dual liftingX scheme.
%   LSD = LSDUAL(LS) returns the liftingX scheme LSD 
%   associated to LS. LS and LSD are issued of the
%   same polyphase matrix factorisation PMF, where
%   PMF = LS2PMF(LS). So [LS,LSD] = PMF2LS(PMF,'t').
%
%   For more information about liftingX schemes type: lsinfoX.
%
%   N.B.: LS = LSDUAL(LSDUAL(LS)).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Jun-2002.
%   Last Revision: 26-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

[PMF,dummy] = ls2pmfX(LS,'t');
[dummy,LSR] = pmf2lsX(PMF,'t');
