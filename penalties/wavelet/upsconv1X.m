function y = upsconv1X(x,f,s,dwtXARG1,dwtXARG2)
%UPSCONV1 Upsample and convolution 1D.
%
%   Y = UPSCONV1(X,F_R,L,DWTATTR) returns the length-L central 
%   portion of the one step dyadic interpolation (upsample and
%    convolution) of vector X using filter F_R. The upsample 
%   and convolution attributes are described by DWTATTR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-May-2003.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Special case.
if isempty(x) , y = 0; return; end

% Check arguments for Extension and Shift.
switch nargin
    case 3 , 
        perFLAG  = 0;  
        dwtXSHIFT = 0;
    case 4 , % Arg4 is a STRUCT
        perFLAG  = isequal(dwtXARG1.extMode,'per');
        dwtXSHIFT = mod(dwtXARG1.shift1D,2);
    case 5 , 
        perFLAG  = isequal(dwtXARG1,'per');
        dwtXSHIFT = mod(dwtXARG2,2);
end

% Define Length.
lx = 2*length(x);
lf = length(f);
if isempty(s)
    if ~perFLAG , s = lx-lf+2; else , s = lx; end
end

% Compute Upsampling and Convolution.
y = x;
if ~perFLAG
    y = wconv1X(dyadupX(y,0),f);
    y = wkeep1X(y,s,'c',dwtXSHIFT);
else
    y = dyadupX(y,0,1);
    y = wextendX('1D','per',y,lf/2);    
    y = wconv1X(y,f);
    y = y(lf:lf+s-1);
    if dwtXSHIFT==1 , y = y([2:end,1]); end
end
