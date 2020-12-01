function varargout = lwtX(x,LS,varargin)
%LWT Lifting wavelet decomposition 1-D.
%   LWT performs a 1-D liftingX wavelet decomposition
%   with respect to a particular lifted wavelet that you specify.
%
%   [CA,CD] = LWT(X,W) computes the approximation
%   coefficients vector CA and detail coefficients vector CD,
%   obtained by a liftingX wavelet decomposition, of 
%   the vector X. W is a lifted wavelet name (see LIFTWAVE).
%
%   X_InPlace = LWT(X,W) computes the approximation and
%   detail coefficients. These coefficients are stored in-place:
%     CA = X_InPlace(1:2:end) and CD = X_InPlace(2:2:end)
%
%   LWT(X,W,LEVEL) computes the liftingX wavelet decomposition 
%   at level LEVEL.
%
%   X_InPlace = LWT(X,W,LEVEL,'typeDEC',typeDEC) or
%   [CA,CD] = LWT(X,W,LEVEL,'typeDEC',typeDEC) with
%   typeDEC = 'w' or 'wp' computes the wavelet or the
%   wavelet packet decomposition using liftingX, at level LEVEL.
%
%   Instead of a lifted wavelet name, you may use the associated
%   liftingX scheme LS:
%     LWT(X,LS,...) instead of LWT(X,W,...).
%
%   For more information about liftingX schemes type: lsinfoX.
%
%   See also ILWT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Feb-2000.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Check arguments.
nbIn = nargin;
switch nbIn
    case {2,3,5}
    case {0,1}
        error('Wavelet:FunctionInput:NotEnough_ArgNum', ...
            'Not enough input arguments.');
    case {4}
        error('Wavelet:FunctionInput:Invalid_ArgNum', ...
            'Invalid number of input arguments.');
    otherwise
        error('Wavelet:FunctionInput:TooMany_ArgNum', ...
            'Too many input arguments.');
end
if nargout>3
    error('Wavelet:FunctionOutput:TooMany_ArgNum', ...
        'Too many output arguments.');
end

% Default: level and typeDEC.
level = 1; 
typeDEC = 'w';
if nargin>2
    level = varargin{1};
    for k = 2:2:length(varargin)-1
        argName = lower( varargin{k});
        switch argName
            case 'typedec' , typeDEC = varargin{k+1};
        end
    end
end
% if level>1
%     msg = nargoutchk(0,1,nargout); error(msg);
% end
if ischar(LS) , LS = liftwaveX(LS); end

%===================%
% LIFTING ALGORITHM %
%===================%
% Splitting.
lx = length(x);
firstIdxAPP = 1;
firstIdxDET = 1+mod(firstIdxAPP,2);
idxAPP = firstIdxAPP:2:lx;
idxDET = firstIdxDET:2:lx;
lenAPP = length(idxAPP);
lenDET = length(idxDET);

% Lifting.
NBL = size(LS,1);
LStype = LS{NBL,3};
for k = 1:NBL-1
    liftTYPE = LS{k,1};
    liftFILT = LS{k,2};
    DF       = LS{k,3};
    switch liftTYPE
       case 'p' , 
           x(idxAPP) = x(idxAPP) + ...
               lsupdateX('v',x(idxDET),liftFILT,DF,lenAPP,LStype);
       case 'd' , 
           x(idxDET) = x(idxDET) + ...
               lsupdateX('v',x(idxAPP),liftFILT,DF,lenDET,LStype);
    end
end

% Normalization.
if isempty(LStype)
    x(idxAPP) = LS{NBL,1}*x(idxAPP);
    x(idxDET) = LS{NBL,2}*x(idxDET);
end
%========================================================================%

% Recursion if level > 1.
if level>1
   x(idxAPP) = lwtX(x(idxAPP),LS,level-1,'typeDEC',typeDEC);
   if isequal(typeDEC,'wp')
       x(idxDET) = lwtX(x(idxDET),LS,level-1,'typeDEC',typeDEC);
   end
end

switch nargout
  case 1 , varargout = {x};
  case 2 , varargout = {x(idxAPP),x(idxDET)};
  case 3 , varargout = {x,x(idxAPP),x(idxDET)};
end
