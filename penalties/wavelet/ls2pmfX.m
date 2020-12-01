function  varargout = ls2pmfX(LS,factMode)
%LS2PMF Lifting scheme(s) to polyphase matrix factorization(s).
%   PMF = LS2PMF(LS,FACTMODE) returns the polyphase matrix
%   factorization corresponding to the liftingX scheme LS.
%   PMF is a cell array of Laurent matrices. FACTMODE indicates 
%   the type of factorization from which LS is issued. The valid 
%   values for FACTMODE are: 
%      'd' (dual factorization) or 'p' (primal factorization).
%
%   PMF = LS2PMF(LS) is equivalent to PMF = LS2PMF(LS,'d') .
%
%   If LSC is a cell array of Lifting Schemes, PMFC = LS2PMF(LSC)  
%   returns a cell array of factorizations. For each k, PMFC{k}
%   is a factorization of LSC{k}.
%
%   [PMF_d,PMF_p] = LS2PMF(LS,'t') returns the two possible 
%   polyphase matrix factorizations.
%
%   See also LS2APMF, PMF2LS.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-May-2001.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

if isempty(LS) , varargout = cell(1,nargout);  return; end
if nargin<2 , factMode = 'd'; end

%-------------------------------------------%
% PMF2APMF is an involutive transformation. %
% So:  M == PMF2APMF(PMF2APMF(M))           %
% And: APMF2PMF == PMF2APMF                 %
%-------------------------------------------%
APMF = ls2apmfX(LS);
factMode = lower(factMode(1));
switch factMode
    case 't' ,
        [varargout{1},varargout{2}] = pmf2apmfX(APMF,factMode);
    case {'d','p'}
        varargout{1} = pmf2apmfX(APMF,factMode);
    otherwise
        error('Wavelet:FunctionArgVal:Invalid_ArgVal',...
            'Invalid value for factorization mode.')
end
