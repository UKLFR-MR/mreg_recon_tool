function x = indwtX(varargin)
%INDWT Inverse non-decimated 1-D wavelet transform.
%   INDWT performs a multilevel non-decimated 1-D wavelet reconstruction
%   starting from a multilevel non-decimated 1-D wavelet decomposition.
%
%   In addition, you can use INDWT to simply extract coefficients 
%   from a multilevel non-decimated 1-D wavelet decomposition (see below).
%
%   C = INDWT(W,TYPE,N) computes the reconstructed components at 
%   level N of a non-decimated 1-D wavelet decomposition. 
%   N must be a positive integer less or equal to the level of the
%   decomposition.
%   The valid value for TYPE is a char:
%       - 'a' (or 'l' or 'A' or 'L'), which gives the low pass
%         component.
%       - 'd' (or 'h' or 'D' or 'H'), which gives the high pass
%         component.
%   where 'A' (or 'L') stands for low pass filter and 'D' (or 'H') 
%   stands for high pass filter.
%
%   For extraction purpose, the valid values for TYPE are the same as
%   above prefixed by 'c' or 'C'.
%
%   See NDWT for more information about the decomposition structure W.
%
%   C = INDWT(W,TYPE) is equivalent to C = INDWT(W,TYPE,N)
%   with N equal to the level of the decomposition.
%
%   X = INDWT(W), X = INDWT(W,'a',0) or X = INDWT(W,'ca',0)  
%   reconstruct the vector X based on the non-decimated 1-D wavelet  
%   decomposition structure W.
%  
%   Examples:
%       load noissin; 
%       x = noissin;
%       W1 = ndwtX(x,3,'db1');
%       a0 = indwtX(W1,'a',0);
%       err = max(abs(x(:)-a0(:)))
%       W2 = ndwtX(x,3,'db3','mode','per');
%       a2 = indwtX(W2,'a',2);
%       d2 = indwtX(W2,'d',2);
%       d1 = indwtX(W2,'d',1);
%       err = max(abs(x(:)-a2(:)-d1(:)-d2(:)))
%
%   See also DWTMODE, NDWT, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Nov-2007.
%   Last Revision: 04-Oct-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Check arguments.
nbIn = nargin;
msg = nargchk(1,6,nbIn); %#ok<NCHK>
if ~isempty(msg)
    error('Wavelet:FunctionInput:NbArg',msg)
end
if ~isstruct(varargin{1})
    error('Wavelet:FunctionInput:ArgVal', ...
        'Invalid argument value!');
end

wt = varargin{1};
ndCell = wt.dec;
LoR = wt.filters.LoR;
HiR = wt.filters.HiR;
LX  = wt.longs(end);
level = wt.level;
nextArg = 2;

nam_Rec = 's';
lev_Rec = 0;
while nbIn>=nextArg
    argName = lower(varargin{nextArg});
    argVal  = varargin{nextArg+1};
    nextArg = nextArg + 2;
    switch argName
        case {'a','d','ca','cd'}
            nam_Rec = argName;
            lev_Rec = argVal;
    end
end

fistIDX  = 1;
lastSTEP = level;
switch nam_Rec
    case 's'
        
    case 'cd'
        num2keep = level+1-(lev_Rec-1);
        x = ndCell{num2keep};
        return;
        
    case 'ca'
        if lev_Rec==level
             x = ndCell{1};
             return
        end
        for k = level+1:-1:2+(level-lev_Rec)
            ndCell{k} = zeros(size(ndCell{k}));
        end
        lastSTEP = level-lev_Rec;
        
    case 'd'
        set2zero = (1:level+1);
        num2keep = level+2-lev_Rec;
        set2zero = setdiff(set2zero,num2keep);
        for k = set2zero
            ndCell{k} = zeros(size(ndCell{k}));
        end        
        
    case 'a'
        for k = level+1:-1:2+(level-lev_Rec)
            ndCell{k} = zeros(size(ndCell{k}));
        end
end

idx = fistIDX;
for k=1:lastSTEP
    a = conv(ndCell{idx},LoR);
    d = conv(ndCell{idx+1},HiR);
    ndCell{idx+1} = (a+d)/2;
    if idx<level
        ndCell{idx+1} = wkeepX(ndCell{idx+1},length(ndCell{idx+2}),'c');
    end
    idx = idx+1;
end
if isequal(nam_Rec,'ca') && ~isequal(lev_Rec,0)
    x = ndCell{idx}; return; 
end
x = wkeepX(ndCell{end},LX,'c');

