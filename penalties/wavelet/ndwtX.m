function varargout = ndwtX(x,level,varargin)
%NDWT Non-decimated 1-D wavelet transform.
%   NDWT performs a multilevel 1-D non-decimated wavelet 
%   decomposition with respect to either a particular wavelet 
%   ('wname', see WFILTERS for more information) or particular  
%   wavelet filters you specify, and using a specified  
%   DWT extension mode (see DWTMODE).
%
%   WT = NDWT(X,N,'wname','mode','ExtM') returns a structure 
%   which contains the non-decimated wavelet transform of the 
%   vector X at the level N, N must be a strictly positive integer
%   (see WMAXLEV), 'wname' is a string containing the wavelet 
%   name and 'ExtM' is a string containing the extension mode.
%   WT = NDWT(X,N,'wname') uses the default extension mode: 'sym'.
%
%   WT is a structure with the following fields:
%     rowvect: is a logical which is true if X is a row vector.
%     level:   contains the level of the decomposition.
%     mode:    contains the name of the wavelet transform extension mode.
%     filters: is a structure with 4 fields LoD, HiD, LoR, HiR which
%              contain the filters used for DWT.
%         dec: is a 1 by (level+1) cell array containing the coefficients 
%              of the decomposition. dec{1} contains the coefficients of
%              the approximation and dec{j} (j = 2 to level+1), contains  
%              the coefficients of the detail of level (level+1-j).
%       longs: is a 1 by (level+2) vector containing the lengths of  
%              the components. Let us denote the level by N, longs is 
%              organized as follows:
%                longs(1)   = length of app. coef.(N)
%                longs(i)   = length of det. coef.(N-i+2) for i = 2,...,N+1
%                longs(N+2) = length(X). 
%
%   Instead of a wavelet you may specify four filters (two for 
%   decomposition and two for reconstruction): WT = NDWT(X,N,WF,...),
%   where WF must be a 1 by four cell array: {LoD,HiD,LoR,HiR},
%   or a structure with the four fields 'LoD', 'HiD', 'LoR', 'HiR'.
%
%   Examples:
%       load noissin; 
%       x = noissin;
%       W1 = ndwtX(x,3,'db1');
%       W2 = ndwtX(x,3,'db3','mode','per')
%
%   See also DWTMODE, INDWT, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Nov-2007.
%   Last Revision: 04-Oct-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Check arguments.
nbIn = length(varargin);
msg  = nargchk(1,3,nbIn); %#ok<NCHK>
if ~isempty(msg)
    error('Wavelet:FunctionInput:NbArg',msg)
end

nextArg = 2;
if ischar(varargin{1})     % Wavelet name
    [LoD,HiD,LoR,HiR] = wfiltersX(varargin{1});
    
elseif iscell(varargin{1}) % Wavelet Filters
    [LoD,HiD,LoR,HiR] = deal(varargin{1}{:});
else                       % Wavelet Filters
    if isfield(varargin{1},'LoD') && isfield(varargin{1},'HiD') && ...
            isfield(varargin{1},'LoR') && isfield(varargin{1},'HiR')
        LoD = varargin{1}.LoD; HiD = varargin{1}.HiD;
        LoR = varargin{1}.LoR; HiR = varargin{1}.HiR;
    else
        error('Wavelet:FunctionInput:ArgVal','Invalid argument value!');
    end
end
lf = length(LoD);

dwtXEXTM = 'sym';
while nbIn>=nextArg
    argName = varargin{nextArg};
    argVal  = varargin{nextArg+1};
    nextArg = nextArg + 2;
    switch argName
        case 'mode' , dwtXEXTM = argVal;
    end
end

% Initialization.
rowvect =  size(x,1)<=1;
lx = length(x);
longs = zeros(1,level+2);
longs(end) = lx;
dec = cell(1,level+1);
% idx = 1;
idx = level+1;
for k=1:level
    lx = length(x);
    x = wextendX('1d',dwtXEXTM,x,lf-1,'b');
    lkeep = lx+lf-1;
    dec{idx} = wkeepX(conv(HiD,x),lkeep);
    x = wkeepX(conv(LoD,x),lkeep);
    idx = idx-1;
end
dec{idx} = x;
for k = 1:level+1 , longs(k) = length(dec{k}); end

% Non Decimated Wavelet Transform.
wt.rowvect = rowvect;
wt.level = level;
wt.mode  = dwtXEXTM;
wt.filters.LoD = LoD;
wt.filters.HiD = HiD;
wt.filters.LoR = LoR;
wt.filters.HiR = HiR;
wt.dec = dec;
wt.longs = longs;

switch nargout
    case 1
        varargout{1} = wt;
    case 2        
        if ~rowvect , catDIR = 1; longs = longs'; else catDIR = 2; end
        varargout{1} = cat(catDIR,dec{:});
        varargout{2} = longs;
    case 3        
        NbCd1 = length(wt.dec{1});
        A = wt.dec{end}(end-NbCd1+1:end);
        D = zeros(level,NbCd1);
        for k = 1:level
            D(k,:) = wt.dec{k}(end-NbCd1+1:end);
        end
        varargout = {A,D,wt};        
end
