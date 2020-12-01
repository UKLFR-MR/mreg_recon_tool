function y = upsaconvX(type,x,f,s,dwtXATTR,shiFLAG)
%UPSACONV Upsample and convolution.
%
%   Y = UPSACONV('1D',X,F_R) returns the one step dyadic
%   interpolation (upsample and convolution) of vector X
%   using filter F_R.
%
%   Y = UPSACONV('1D',X,F_R,L) returns the length-L central 
%   portion of the result obtained using Y = UPSACONV('1D',X,F_R).
%
%   Y = UPSACONV('2D',X,{F1_R,F2_R}) returns the one step dyadic 
%   interpolation (upsample and convolution) of matrix X
%   using filter F1_R for rows and filter F2_R for columns.
%
%   Y = UPSACONV('2D',X,{F1_R,F2_R},S) returns the size-S
%   central portion of the result obtained 
%   using Y = UPSACONV('2D',X,{F1_R,F2_R})
% 
%   Y = UPSACONV('1D',X,F_R,DWTATTR) returns the one step
%   interpolation of vector X using filter F_R where the upsample 
%   and convolution attributes are described by DWTATTR.
%
%   Y = UPSACONV('1D',X,F_R,L,DWTATTR) combines the two 
%   other usages.
%
%   Y = UPSACONV('2D',X,{F1_R,F2_R},DWTATTR) returns the one step
%   interpolation of matrix X using filters F1_R and F2_R where  
%   the upsample and convolution attributes are described by DWTATTR.
% 
%   Y = UPSACONV('2D',X,{F1_R,F2_R},S,DWTATTR) combines the 
%   other usages.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Nov-97.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Special case.
if isempty(x) , y = 0; return; end

y = x;
if nargin<4 , sizFLAG = 1; else , sizFLAG = isempty(s); end
if nargin<5 , dwtXATTR = dwtmodeX('get'); end
if nargin<6 , shiFLAG = 1; end
dumFLAG = ~isstruct(dwtXATTR);
if ~dumFLAG , perFLAG = isequal(dwtXATTR.extMode,'per'); else , perFLAG = 0; end
shiFLAG = shiFLAG && ~dumFLAG;

switch type
    case {1,'1','1d','1D'}
        ly = length(y);
        lf = length(f);
        if sizFLAG
            if ~perFLAG , s = 2*ly-lf+2; else , s = 2*ly; end
        end
        if shiFLAG , shift = dwtXATTR.shift1D; else , shift = 0; end
        shift = mod(shift,2);
        if ~perFLAG
            if sizFLAG , s = 2*ly-lf+2; end
            y = wconv1X(dyadupX(y,0),f);
            y = wkeep1X(y,s,'c',shift);
        else
            if sizFLAG , s = 2*ly; end
            y = dyadupX(y,0,1);
            y = wextendX('1D','per',y,lf/2);
            y = wconv1X(y,f);
            y = wkeep1X(y,2*ly,lf);
            if shift==1 , y = y([2:end,1]); end
            y = y(1:s);
        end

    case {2,'2','2d','2D'}
        sy = size(y);
        lf = length(f{1});
        if sizFLAG
            if ~perFLAG , s = 2*sy-lf+2; else , s = 2*sy; end
        end
        if shiFLAG , shift = dwtXATTR.shift2D; else , shift = [0 0]; end
        shift = mod(shift,2);
        if ~perFLAG
            y = wconv2X('col',dyadupX(y,'row',0),f{1});
            y = wconv2X('row',dyadupX(y,'col',0),f{2});
            y = wkeep2X(y,s,'c',shift);
        else
            y = dyadupX(y,'mat',0,1);
            y = wextendX('2D','per',y,[lf/2,lf/2]);
            y = wconv2X('col',y,f{1});
            y = wconv2X('row',y,f{2});
            y = wkeep2X(y,2*sy,[lf lf]);
            if shift(1)==1 , y = y([2:end,1],:); end
            if shift(2)==1 , y = y(:,[2:end,1]); end
            y = wkeep2X(y,s,[1,1]);
        end
end
