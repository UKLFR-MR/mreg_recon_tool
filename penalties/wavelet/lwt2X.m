function varargout = lwt2X(x,LS,varargin)
%LWT2 Lifting wavelet decomposition 2-D.
%   LWT2 performs a 2-D liftingX wavelet decomposition
%   with respect to a particular lifted wavelet that you specify.
%
%   [CA,CH,CV,CD] = LWT2(X,W) computes the approximation
%   coefficients matrix CA and detail coefficients matrices
%   CH, CV and CD obtained by a liftingX wavelet decomposition, 
%   of the matrix X. W is a lifted wavelet name (see LIFTWAVE).
%
%   X_InPlace = LWT2(X,LS) computes the approximation and
%   detail coefficients. These coefficients are stored in-place:
%       CA = X_InPlace(1:2:end,1:2:end)
%       CH = X_InPlace(2:2:end,1:2:end)
%       CV = X_InPlace(1:2:end,2:2:end)
%       CD = X_InPlace(2:2:end,2:2:end)
%
%   LWT2(X,W,LEVEL) computes the liftingX wavelet decomposition
%   at level LEVEL.
%
%   X_InPlace = LWT2(X,W,LEVEL,'typeDEC',typeDEC) or
%   [CA,CH,CV,CD] = LWT2(X,W,LEVEL,'typeDEC',typeDEC) with
%   typeDEC = 'w' or 'wp' compute the wavelet or the
%   wavelet packet decomposition using liftingX at level LEVEL.
%
%   Instead of a lifted wavelet name, you may use the associated
%   liftingX scheme LS:
%     LWT2(X,LS,...) instead of LWT2(X,W,...).
%
%   For more information about liftingX schemes type: lsinfoX.
%
%   NOTE: When X represents an indexed image, then X as well 
%   as the output arrays CA, CH, CV, CD or X_InPlace are 
%   m-by-n matrices. When X represents a truecolor image, 
%   then they become  m-by-n-by-3 arrays. These arrays consist
%   of three m-by-n matrices (representing the red, green, and 
%   blue color planes) concatenated along the third dimension.
%   For more information on image formats, see the reference pages 
%   of IMAGE and IMFINFO functions.
%
%   See also ILWT2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Feb-2000.
%   Last Revision: 07-Oct-2007.
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
nbOut = nargout;
switch nbOut
    case {0,1,4,5} , 
    case {2,3}
        error('Wavelet:FunctionOutput:Invalid_ArgNum',...
            'Invalid number of output arguments.');
    otherwise
        error('Wavelet:FunctionOutput:TooMany_ArgNum', ...
            'Too many output arguments.');
end

% Default: level and typeDEC.
level = 1; typeDEC = 'w';
firstIdxAPP = 1; firstIdxDET = 1+mod(firstIdxAPP,2);
if nargin>2
    level = varargin{1};
    for k = 2:2:length(varargin)-1
      argName = lower( varargin{k});
      switch argName
        case 'typedec' , typeDEC = varargin{k+1};
      end
    end
end
if ischar(LS) , LS = liftwaveX(LS); end

%===================%
% LIFTING ALGORITHM %
%===================%
% Splitting.
if ndims(x)>2 , x = double(x); end
L = x(:,firstIdxAPP:2:end,:);
H = x(:,firstIdxDET:2:end,:);
sL = size(L);
sH = size(H);

% Lifting.
NBL = size(LS,1);
LStype = LS{NBL,3};
for k = 1:NBL-1
    liftTYPE = LS{k,1};
    liftFILT = LS{k,2};
    DF       = LS{k,3};
    switch liftTYPE
      case 'p' , L = L + lsupdateX('r',H,liftFILT,DF,sL,LStype);
      case 'd' , H = H + lsupdateX('r',L,liftFILT,DF,sH,LStype);
    end
end

% Splitting.
a = L(firstIdxAPP:2:end,:,:); h = L(firstIdxDET:2:end,:,:); clear L
v = H(firstIdxAPP:2:end,:,:); d = H(firstIdxDET:2:end,:,:); clear H
sa = size(a); sh = size(h);
sv = size(v); sd = size(d);

% Lifting.
for k = 1:NBL-1
    liftTYPE = LS{k,1};
    liftFILT = LS{k,2};
    DF       = LS{k,3};
    switch liftTYPE
      case 'p'
        a = a + lsupdateX('c',h,liftFILT,DF,sa,LStype);
        v = v + lsupdateX('c',d,liftFILT,DF,sv,LStype);

      case 'd'
        h = h + lsupdateX('c',a,liftFILT,DF,sh,LStype);
        d = d + lsupdateX('c',v,liftFILT,DF,sd,LStype);
    end
end
% Normalization.
if isempty(LStype)
    a = LS{end,1}*LS{end,1}*a;
    h = LS{end,1}*LS{end,2}*h;
    v = LS{end,2}*LS{end,1}*v;
    d = LS{end,2}*LS{end,2}*d;
end
%========================================================================%


% Recursion if level > 1.
if level>1
   level = level-1;
   a = lwt2X(a,LS,level,'typeDEC',typeDEC);
   if isequal(typeDEC,'wp')
       h = lwt2X(h,LS,level,'typeDEC',typeDEC);
       v = lwt2X(v,LS,level,'typeDEC',typeDEC);
       d = lwt2X(d,LS,level,'typeDEC',typeDEC);
   end
end

% Store in place.
x(firstIdxAPP:2:end,firstIdxAPP:2:end,:) = a;
x(firstIdxDET:2:end,firstIdxAPP:2:end,:) = h;
x(firstIdxAPP:2:end,firstIdxDET:2:end,:) = v;
x(firstIdxDET:2:end,firstIdxDET:2:end,:) = d;

switch nargout
  case 1 , varargout = {x};
  case 4 , varargout = {a,h,v,d};
  case 5 , varargout = {x,a,h,v,d};
end
