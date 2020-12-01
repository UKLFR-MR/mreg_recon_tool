function lev = wmaxlevX(sizeX,wname)
%WMAXLEV Maximum wavelet decomposition level.
%   WMAXLEV can help you avoid unreasonable maximum level value.
%
%   L = WMAXLEV(S,'wname') returns the maximum level
%   decomposition of signal or image of size S using the wavelet
%   named in the string 'wname' (see WFILTERS for more information).
%
%   WMAXLEV gives the maximum allowed level decomposition,
%   but in general, a smaller value is taken.
%   Usual values are 5 for the 1-D case, and 3 for the 2-D case.
%
%   See also WAVEDEC, WAVEDEC2, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 30-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
% $Revision: 1.1 $

if     isempty(sizeX)
       lev = [];
       return;
elseif length(sizeX)==1
       lx = sizeX;
elseif min(sizeX)==1
       lx = max(sizeX);
elseif length(sizeX)==3
       lx = min(sizeX(1:2));    
else
       lx = min(sizeX);
end

wname = deblanklX(wname);
[wtype,bounds] = wavemngrX('fields',wname,'type','bounds');
switch wtype
  case {1,2}
    Lo_D = wfiltersX(wname);
    lw = length(Lo_D);

  case {3,4,5} , lw = bounds(2)-bounds(1)+1;

  otherwise
    errargtX(mfilename,'invalid argument','msg');
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end

% the rule is the last level for which at least one coefficient 
% is correct : (lw-1)*(2^lev) < lx

lev = fix(log(lx/(lw-1))/log(2));
if lev<1 , lev = 0; end
