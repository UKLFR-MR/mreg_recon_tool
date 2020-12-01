function varargout = wfiltersX(wname,o)
%WFILTERS Wavelet filters.
%   [LO_D,HI_D,LO_R,HI_R] = WFILTERS('wname') computes four
%   filters associated with the orthogonal or biorthogonal
%   wavelet named in the string 'wname'. 
%   The four output filters are:
%       LO_D, the decomposition low-pass filter
%       HI_D, the decomposition high-pass filter
%       LO_R, the reconstruction low-pass filter
%       HI_R, the reconstruction high-pass filter
%   Available wavelet names 'wname' are:
%   Daubechies: 'db1' or 'haar', 'db2', ... ,'db45'
%   Coiflets  : 'coif1', ... ,  'coif5'
%   Symlets   : 'sym2' , ... ,  'sym8', ... ,'sym45'
%   Discrete Meyer wavelet: 'dmey'
%   Biorthogonal:
%       'bior1.1', 'bior1.3' , 'bior1.5'
%       'bior2.2', 'bior2.4' , 'bior2.6', 'bior2.8'
%       'bior3.1', 'bior3.3' , 'bior3.5', 'bior3.7'
%       'bior3.9', 'bior4.4' , 'bior5.5', 'bior6.8'.
%   Reverse Biorthogonal: 
%       'rbio1.1', 'rbio1.3' , 'rbio1.5'
%       'rbio2.2', 'rbio2.4' , 'rbio2.6', 'rbio2.8'
%       'rbio3.1', 'rbio3.3' , 'rbio3.5', 'rbio3.7'
%       'rbio3.9', 'rbio4.4' , 'rbio5.5', 'rbio6.8'.
%
%   [F1,F2] = WFILTERS('wname','type') returns the following
%   filters: 
%   LO_D and HI_D if 'type' = 'd' (Decomposition filters)
%   LO_R and HI_R if 'type' = 'r' (Reconstruction filters)
%   LO_D and LO_R if 'type' = 'l' (Low-pass filters)
%   HI_D and HI_R if 'type' = 'h' (High-pass filters)
%
%   See also BIORFILT, ORTHFILT, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 30-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
% $Revision: 1.1 $

% Check arguments.
nbIn = nargin;
if nbIn < 1
  error('Wavelet:FunctionInput:NotEnough_ArgNum', ...
      'Not enough input arguments.');
end
nbOut = nargout;
if ~any([0 1 2 4 8]==nbOut)
    error('Wavelet:FunctionOutput:Invalid_ArgNum', ...
        'Invalid number of output arguments.');
end
if errargtX(mfilename,wname,'str')
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');    
end

wname         = deblanklX(wname);
[wtype,fname] = wavemngrX('fields',wname,'type','file');
mat_f         = findstr('.mat',fname);
if mat_f
   try
     load(fname,'-mat');
   catch
     msg = sprintf('Invalid wavelet file : %s', fname);
     errargtX(mfilename,msg,'msg');
     error(msg); %#ok<SPERR>
   end
end

if wtype==1                % orth. wavelet
    if ~isempty(mat_f)
        F = eval(wname);
    else
        F = feval(fname,wname);
    end
    [Lo_D,Hi_D,Lo_R,Hi_R] = orthfiltX(F);

elseif wtype==2            % biorth. wavelet
    if isempty(mat_f)
        [Rf,Df] = feval(fname,wname);
    else
        if exist('Rf','var')~=1 || exist('Df','var')~=1
            msg = sprintf('invalid biorthogonal wavelet file : %s', fname);
            errargtX(mfilename,msg,'msg');
            error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
                'Invalid argument value.');
        end
    end
    [Lo_D,Hi_D1,Lo_R1,Hi_R,Lo_D2,Hi_D,Lo_R,Hi_R2] = biorfiltX(Df,Rf,1);
    if (nbOut>4) && (nbIn<2)
        varargout(5:8) = {Lo_D2,Hi_D1,Lo_R1,Hi_R2};
    end

else
    msg = sprintf('The wavelet %s is not valid!',wname);
    errargtX(mfilename,msg,'msg');
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end

if nbIn==1
    varargout(1:4) = {Lo_D,Hi_D,Lo_R,Hi_R};
else
    o = lower(o(1));
    switch o
        case 'd' , varargout = {Lo_D,Hi_D};
        case 'r' , varargout = {Lo_R,Hi_R};
        case 'l' , varargout = {Lo_D,Lo_R};
        case 'h' , varargout = {Hi_D,Hi_R};
        otherwise  
            errargtX(mfilename,'invalid argument value','msg');
            error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
                'Invalid argument value.');
    end
end
