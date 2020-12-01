function varargout = iswtX(varargin)
%ISWT Inverse discrete stationary wavelet transform 1-D.
%   ISWT performs a multilevel 1-D stationary wavelet 
%   reconstruction using either a specific orthogonal wavelet  
%   ('wname', see WFILTERS for more information) or specific 
%   reconstruction filters (Lo_R and Hi_R).
%
%   X = ISWT(SWC,'wname') or X = ISWT(SWA,SWD,'wname') 
%   or X = ISWT(SWA(end,:),SWD,'wname') reconstructs the 
%   signal X based on the multilevel stationary wavelet   
%   decomposition structure SWC or [SWA,SWD] (see SWT).
%
%   For X = ISWT(SWC,Lo_R,Hi_R) or X = ISWT(SWA,SWD,Lo_R,Hi_R),  
%   or X = ISWT(SWA(end,:),SWD,Lo_R,Hi_R),
%   Lo_R is the reconstruction low-pass filter.
%   Hi_R is the reconstruction high-pass filter.
%
%   See also IDWT, SWT, WAVEREC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Dec-97.
%   Last Revision: 23-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Check arguments.
nbIn = nargin;
msg = nargchk(2,4,nbIn);
if ~isempty(msg)
    error('Wavelet:FunctionInput:NbArg',msg)
end
switch nbIn
  case 2 , argstr = 1; argnum = 2;
  case 4 , argstr = 0; argnum = 3;
  case 3
      if ischar(varargin{3})
          argstr = 1; argnum = 3;
      else
          argstr = 0; argnum = 2;
      end
end

% Compute reconstruction filters.
if argstr
    [lo_R,hi_R] = wfiltersX(varargin{argnum},'r');
else
    lo_R = varargin{argnum}; hi_R = varargin{argnum+1};
end

% Set DWT_Mode to 'per'.
old_modeDWT = dwtmodeX('status','nodisp');
dwtmodeX('per','nodisp');

% Get inputs.
if argnum==2
    p = size(varargin{1},1);
    n = p-1;
    d = varargin{1}(1:n,:);
    a = varargin{1}(p,:);
else
    a = varargin{1};
    d = varargin{2};
end
a      = a(size(a,1),:);
[n,lx] = size(d);
for k = n:-1:1
    step = 2^(k-1);
    last = step;
    for first = 1:last
      ind = first:step:lx;
      lon = length(ind);
      subind = ind(1:2:lon);
      x1 = idwtXLOC(a(subind),d(k,subind),lo_R,hi_R,lon,0);
      subind = ind(2:2:lon);
      x2 = idwtXLOC(a(subind),d(k,subind),lo_R,hi_R,lon,-1);
      a(ind) = 0.5*(x1+x2);
    end
end
varargout{1} = a;

% Restore DWT_Mode.
dwtmodeX(old_modeDWT,'nodisp');


%===============================================================%
% INTERNAL FUNCTIONS
%===============================================================%
function y = idwtXLOC(a,d,lo_R,hi_R,lon,shift)

y = upconvLOC(a,lo_R,lon) + upconvLOC(d,hi_R,lon);
if shift==-1 , y = y([end,1:end-1]); end
%---------------------------------------------------------------%
function y = upconvLOC(x,f,l)

lf = length(f);
y  = dyadupX(x,0,1);
y  = wextendX('1D','per',y,lf/2);
y  = wconv1X(y,f);
y  = wkeep1X(y,l,lf);
%===============================================================%
