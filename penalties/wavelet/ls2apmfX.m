function  APMF = ls2apmfX(LS)
%LS2APMF Lifting scheme to analyzis polyphase matrix factorization.
%   APMF = LS2APMF(LS) returns the Laurent matrices factorization
%   APMF, corresponding to the liftingX scheme LS. APMF is a cell
%   array of Laurent Matrices.
%
%   If LSC is a cell array of liftingX schemes, APMFC = LS2APMF(LSC)  
%   returns a cell array of factorizations. For each k, APMFC{k}
%   is a factorization of LSC{k}.
%   
%   Examples:
%      LS = liftwaveX('db1')
%      APMF = ls2apmfX(LS);
%      APMF{:}
%
%      LSC = {liftwaveX('db1'),liftwaveX('db2')};
%      LSC{:}
%      APMFC = ls2apmfX(LSC);
%      APMFC{1}{:} , APMFC{2}{:} 
%
%   See also APMF2LS, LS2PMF.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 11-Jun-2003.
%   Last Revision: 27-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

if isempty(LS) , APMF = [];  return; end

cellMODE = ~(isequal(LS{1,1},'p') || ...
             isequal(LS{1,1},'d') || isequal(LS,{1 1,[]}));
if cellMODE
    nbFACT = length(LS);
    APMF = cell(1,nbFACT);
    for k = 1:nbFACT
        APMF{k} = ONE_ls2apmfX(LS{k});
    end
else
    APMF = ONE_ls2apmfX(LS);
end

%---+---+---+---+---+---+---+---+---+---+---+---+---%
function APMF = ONE_ls2apmfX(LS)

nbLIFT = size(LS,1);
APMF = cell(1,nbLIFT);
for jj = nbLIFT:-1:2
    k = 1+nbLIFT-jj;
    P = laurpoly(LS{k,2},'maxDEG',LS{k,3});
    if LS{k,1}=='p'
        APMF{jj} = laurmat({1,P;0,1});
    else
        APMF{jj} = laurmat({1,0;P,1});
    end
end
APMF{1} = laurmat({LS{nbLIFT,1},0;0,LS{nbLIFT,2}});
%---+---+---+---+---+---+---+---+---+---+---+---+---%
