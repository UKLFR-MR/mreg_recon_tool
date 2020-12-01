function x = idwt2X(a,h,v,d,varargin)
%IDWT2  Single-level inverse discrete 2-D wavelet transform.
%   IDWT2 performs a single-level 2-D wavelet reconstruction
%   with respect to either a particular wavelet
%   ('wname', see WFILTERS for more information) or particular wavelet
%   reconstruction filters (Lo_R and Hi_R) you specify.
%
%   X = IDWT2(CA,CH,CV,CD,'wname') uses the wavelet 'wname'
%   to compute the single-level reconstructed approximation
%   coefficients matrix X, based on approximation matrix CA
%   and (horizontal, vertical, and diagonal) details matrices
%   CH, CV and CD.
%
%   X = IDWT2(CA,CH,CV,CD,Lo_R,Hi_R) reconstructs as above,
%   using filters you specify:
%   Lo_R is the reconstruction low-pass filter.
%   Hi_R is the reconstruction high-pass filter.
%   Lo_R and Hi_R must be the same length.
%
%   Let SA = size(CA) = size(CH) = size(CV) = size(CD) and
%   LF the length of the filters; then size(X) = SX where
%   SX = 2*SA if the DWT extension mode is set to periodization.
%   SX = 2*SA-LF+2 for the other extension modes.
%
%   X = IDWT2(CA,CH,CV,CD,'wname',S) and
%   X = IDWT2(CA,CH,CV,CD,Lo_R,Hi_R,S) return the size-S
%   central portion of the result obtained using
%   IDWT2(CA,CH,CV,CD,'wname'). S must be less than SX.
%
%   X = IDWT2(...,'mode',MODE) computes the wavelet
%   reconstruction using the specified extension mode MODE.
%
%   X = IDWT2(CA,[],[],[], ... ) returns the single-level
%   reconstructed approximation coefficients matrix X
%   based on approximation coefficients matrix CA.
%   
%   X = IDWT2([],CH,[],[], ... ) returns the single-level
%   reconstructed detail coefficients matrix X
%   based on horizontal detail coefficients matrix CH.
%
%   The same result holds for X = IDWT2([],[],CV,[], ... ) and
%   X = IDWT2([],[],[],CD, ... ).
%
%   More generally, X = IDWT2(AA,HH,VV,DD, ... ) returns the single-level
%   reconstructed matrix X where AA can be CA or [], and so on.
%
%   NOTE: If CA,CH,CV,CD are obtained from an indexed image 
%   analysis (respectively a truecolor image analysis) then 
%   they are m-by-n matrices (respectively m-by-n-by-3 arrays).
%   In the first case the output array X is an m-by-n matrix,
%   in the second case X is an m-by-n-by-3 array.
%   For more information on image formats, see the reference
%   pages of IMAGE and IMFINFO functions.
%
%   See also DWT2, DWTMODE, UPWLEV2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 16-Sep-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
% $Revision: 1.1 $

% Check arguments.
msg = nargchk(5,11,nargin);
if ~isempty(msg)
    error('Wavelet:FunctionInput:NbArg',msg)
end
if isempty(a) && isempty(h) && isempty(v) && isempty(d), x = []; return; end
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfiltersX(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end

% Check arguments for Size, Shift and Extension.
DWT_Attribute = getappdata(0,'DWT_Attribute');
if isempty(DWT_Attribute) , DWT_Attribute = dwtmodeX('get'); end
dwtXEXTM = DWT_Attribute.extMode; % Default: Extension.
shift   = DWT_Attribute.shift2D; % Default: Shift.
sx = [];
k = next;
while k<=length(varargin)
    if ischar(varargin{k})
        switch varargin{k}
           case 'mode'  , dwtXEXTM = varargin{k+1};
           case 'shift' , shift = mod(varargin{k+1},2);
        end
        k = k+2;
    else
        sx = varargin{k};
        k = k+1;
    end
end
x = upsconv2X(a,{Lo_R,Lo_R},sx,dwtXEXTM,shift)+ ... % Approximation.
    upsconv2X(h,{Hi_R,Lo_R},sx,dwtXEXTM,shift)+ ... % Horizontal Detail.
    upsconv2X(v,{Lo_R,Hi_R},sx,dwtXEXTM,shift)+ ... % Vertical Detail.
    upsconv2X(d,{Hi_R,Hi_R},sx,dwtXEXTM,shift);     % Diagonal Detail.

% if ndims(x)>2
%     [ST,I] = dbstack;
%     funNames = {ST(:).name};
%     x(x<0) = 0;
%     x = uint8(x); 
% end
