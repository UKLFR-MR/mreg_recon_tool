function y = upsconv2X(x,f,s,dwtXARG1,dwtXARG2)
%UPSCONV2 Upsample and convolution.
%
%   Y = UPSCONV2(X,{F1_R,F2_R},S,DWTATTR) returns the size-S
%   central portion of the one step dyadic interpolation
%   (upsample and convolution) of matrix X using filter F1_R
%   for rows and filter F2_R for columns. The upsample and
%   convolution attributes are described by DWTATTR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-May-2003.
%   Last Revision: 23-Feb-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Special case.
if isempty(x) , y = 0; return; end

% Check arguments for Extension and Shift.
switch nargin
    case 3 ,
        perFLAG  = 0;
        dwtXSHIFT = [0 0];
    case 4 , % Arg4 is a STRUCT
        perFLAG  = isequal(dwtXARG1.extMode,'per');
        dwtXSHIFT = mod(dwtXARG1.shift2D,2);
    case 5 ,
        perFLAG  = isequal(dwtXARG1,'per');
        dwtXSHIFT = mod(dwtXARG2,2);
end

% Define Size.
lf = length(f{1});
sx = 2*size(x);

ndimX = ndims(x);
if ndimX>2 , sx = sx(1:2); end
if isempty(s)
    if ~perFLAG , s = sx-lf+2; else s = sx; end
end

if ndimX<3
    y = upsconv2XONE(x);
else
    y = cell(0,3);
    for j = 1:3
        y{j} = upsconv2XONE(x(:,:,j));
    end
     y = cat(3,y{:});
end

    function y = upsconv2XONE(z)
        % Compute Upsampling and Convolution.
        if ~perFLAG
            y = dyadupX(z,'row',0);
            y = conv2(y',f{1}(:)','full'); y = y';
            y = dyadupX(y,'col',0);
            y = conv2(y ,f{2}(:)','full');
            y = wkeep2X(y,s,'c',dwtXSHIFT);
        else
            y = dyadupX(z,'row',0,1);
            y = wextendX('addrow','per',y,lf/2);
            y = conv2(y',f{1}(:)','full'); y = y';
            y = y(lf:lf+s(1)-1,:);
            %-------------------------------------------
            y = dyadupX(y,'col',0,1);
            y = wextendX('addcol','per',y,lf/2);
            y = conv2(y,f{2}(:)','full');
            y = y(:,lf:lf+s(2)-1);
            %-------------------------------------------
            if dwtXSHIFT(1)==1 , y = y([2:end,1],:); end
            if dwtXSHIFT(2)==1 , y = y(:,[2:end,1]); end
            %-------------------------------------------
        end
    end

end
