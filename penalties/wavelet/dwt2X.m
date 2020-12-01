function [a,h,v,d] = dwt2X(x,varargin)
%DWT2 Single-level discrete 2-D wavelet transform.
%   DWT2 performs a single-level 2-D wavelet decomposition
%   with respect to either a particular wavelet ('wname',
%   see WFILTERS for more information) or particular wavelet filters
%   (Lo_D and Hi_D) you specify.
%
%   [CA,CH,CV,CD] = DWT2(X,'wname') computes the approximation
%   coefficients matrix CA and details coefficients matrices 
%   CH, CV, CD, obtained by a wavelet decomposition of the 
%   input matrix X.
%   'wname' is a string containing the wavelet name.
%
%   [CA,CH,CV,CD] = DWT2(X,Lo_D,Hi_D) computes the 2-D wavelet
%   decomposition as above given these filters as input:
%   Lo_D is the decomposition low-pass filter.
%   Hi_D is the decomposition high-pass filter.
%   Lo_D and Hi_D must be the same length.
%
%   Let SX = size(X) and LF = the length of filters; then
%   size(CA) = size(CH) = size(CV) = size(CD) = SA where
%   SA = CEIL(SX/2), if the DWT extension mode is set to
%   periodization. SA = FLOOR((SX+LF-1)/2) for the other
%   extension modes. For the different DWT extension modes, 
%   see DWTMODE.
%
%   [CA,CH,CV,CD] = DWT2(...,'mode',MODE) computes the wavelet 
%   decomposition with the extension mode MODE you specify.
%   MODE is a string containing the extension mode.
%
%   NOTE: When X represents an indexed image, then X as well 
%   as the output arrays CA, CH, CV, CD are m-by-n matrices.
%   When X represents a truecolor image, then they become 
%   m-by-n-by-3 arrays. These arrays consist of three m-by-n matrices
%  (representing the red, green, and blue color planes) concatenated 
%   along the third dimension.
%   For more information on image formats, see the reference pages 
%   of IMAGE and IMFINFO functions.
%
%   Example:
%     x = magic(4);
%     [ca,ch,cv,cd] = dwt2X(x,'db1','mode','sym')
%
%   See also DWTMODE, IDWT2, WAVEDEC2, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 13-Sep-2008.
%   Copyright 1995-2007 The MathWorks, Inc.
% $Revision: 1.1 $

% Check arguments.
nbIn = nargin;
msg = nargchk(2,7,nbIn);
if ~isempty(msg)
    error('Wavelet:FunctionInput:NbArg',msg)
end
if ischar(varargin{1})
    [Lo_D,Hi_D] = wfiltersX(varargin{1},'d'); next = 2;
else
    Lo_D = varargin{1}; Hi_D = varargin{2};  next = 3;
end

% Check arguments for Extension and Shift.
DWT_Attribute = getappdata(0,'DWT_Attribute');
if isempty(DWT_Attribute) , DWT_Attribute = dwtmodeX('get'); end
dwtXEXTM = DWT_Attribute.extMode; % Default: Extension.
shift   = DWT_Attribute.shift2D; % Default: Shift.
for k = next:2:nbIn-1
    switch varargin{k}
      case 'mode'  , dwtXEXTM = varargin{k+1};
      case 'shift' , shift   = mod(varargin{k+1},2);
    end
end

% Compute sizes.
lf = length(Lo_D);
sx = size(x);

% Extend, Decompose &  Extract coefficients.
first = 2-shift;
flagPer = isequal(dwtXEXTM,'per');
if ~flagPer
    sizeEXT = lf-1; last = sx+lf-1;
else
    sizeEXT = lf/2; last = 2*ceil(sx/2);
end

x = double(x);
if length(sx)==2
    y = wextendX('addcol',dwtXEXTM,x,sizeEXT);
    z = conv2(y,Lo_D(:)','valid');
    a = convdown(z,Lo_D,dwtXEXTM,sizeEXT,first,last);
    h = convdown(z,Hi_D,dwtXEXTM,sizeEXT,first,last);
    z = conv2(y,Hi_D(:)','valid');
    v = convdown(z,Lo_D,dwtXEXTM,sizeEXT,first,last);
    d = convdown(z,Hi_D,dwtXEXTM,sizeEXT,first,last);
else
    a = cell(0,3);
    h = cell(0,3);
    v = cell(0,3);
    d = cell(0,3);
    for k = 1:3
        y = wextendX('addcol',dwtXEXTM,x(:,:,k),sizeEXT);
        z = conv2(y,Lo_D(:)','valid');
        a{k} = convdown(z,Lo_D,dwtXEXTM,sizeEXT,first,last);
        h{k} = convdown(z,Hi_D,dwtXEXTM,sizeEXT,first,last);
        z = conv2(y,Hi_D(:)','valid');
        v{k} = convdown(z,Lo_D,dwtXEXTM,sizeEXT,first,last);
        d{k} = convdown(z,Hi_D,dwtXEXTM,sizeEXT,first,last);
    end
    a = cat(3,a{:});
    h = cat(3,h{:});
    v = cat(3,v{:});
    d = cat(3,d{:});
end

%-------------------------------------------------------%
% Internal Function(s)
%-------------------------------------------------------%
function y = convdown(x,F,dwtXEXTM,lenEXT,first,last)

y = x(:,first(2):2:last(2));
y = wextendX('addrow',dwtXEXTM,y,lenEXT);
y = conv2(y',F(:)','valid');
y = y';
y = y(first(1):2:last(1),:);
%-------------------------------------------------------%
