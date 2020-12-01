function wdec = wavedec3X(X,level,varargin)
%WAVEDEC3 Multilevel 3-D wavelet decomposition.
%   WDEC = WAVEDEC3(X,N,'wname','mode','ExtM') returns the wavelet
%   decomposition of the 3-D array X at level N, using the wavelet 
%   named in string 'wname' (see WFILTERS) or particular wavelet filters
%   you specify, and using a specified DWT extension mode (see DWTMODE).
%   WDEC = WAVEDEC3(X,N,'wname') uses the default extension mode: 'sym'.
%   
%   N must be a strictly positive integer (see WMAXLEV).
%
%   WDEC is the output decomposition structure, with the following fields:
%     sizeINI: contains the size of the 3-D array X.
%     level:   contains the level of the decomposition.
%     mode:    contains the name of the wavelet transform extension mode.
%     filters: is a structure with 4 fields LoD, HiD, LoR, HiR which
%              contain the filters used for DWT.
%     dec:     is a Nx1 cell array containing the coefficients 
%              of the decomposition. N is equal to 7*level+1.
%              dec(1) contains the low pass component (approximation),
%              dec(k+2),...,dec(k+8) contain the components of level L,
%              L = (level-k) with k = 0,...,level-1, in the following
%              order: 'LLH','LHL','LHH','HLL','HLH','HHL','HHH'.
%     sizes:   contains the successive sizes of the decomposition
%              components.
%
%   Examples:
%       M = magic(8);
%       X = repmat(M,[1 1 8]);
%       wd1 = wavedec3X(X,1,'db1')
%       [LoD,HiD,LoR,HiR] = wfiltersX('db2');
%       wd2 = wavedec3X(X,2,{LoD,HiD,LoR,HiR})
%       wd3 = wavedec3X(X,2,{LoD,HiD,LoR,HiR},'mode','per')
%
%   See also dwtmodeX, dwt3X, waverec3X, waveinfoX.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Dec-2008.
%   Last Revision: 04-Oct-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Check arguments.
nbIn = nargin;
LoD = cell(1,3); HiD = cell(1,3); LoR = cell(1,3); HiR = cell(1,3);
if ischar(varargin{1})
    [LD,HD,LR,HR] = wfiltersX(varargin{1}); 
    for k = 1:3
        LoD{k} = LD; HiD{k} = HD; LoR{k} = LR; HiR{k} = HR;
    end
    
elseif isstruct(varargin{1})
    if isfield(varargin{1},'w1') && isfield(varargin{1},'w2') && ...
            isfield(varargin{1},'w3')
        for k = 1:3
            [LoD{k},HiD{k},LoR{k},HiR{k}] = ...
                wfiltersX(varargin{1}.(['w' int2str(k)]));
        end
    elseif isfield(varargin{1},'LoD') && isfield(varargin{1},'HiD') && ...
           isfield(varargin{1},'LoR') && isfield(varargin{1},'HiR')
        for k = 1:3
            LoD{k} = varargin{1}.LoD{k}; HiD{k} = varargin{1}.HiD{k};
            LoR{k} = varargin{1}.LoR{k}; HiR{k} = varargin{1}.HiR{k};
        end
    else
        error('Wavelet:FunctionInput:ArgVal','Invalid argument value!');
    end
    
elseif iscell(varargin{1})
    if ischar(varargin{1}{1})
        for k = 1:3
            [LoD{k},HiD{k},LoR{k},HiR{k}] = wfiltersX(varargin{1}{k});
        end
    else
        LoD(1:end) = varargin{1}(1); HiD(1:end) = varargin{1}(2);
        LoR(1:end) = varargin{1}(3); HiR(1:end) = varargin{1}(4);
    end
else
    error('Wavelet:FunctionInput:ArgVal','Invalid argument value!');
end

% Check arguments for Extension.
dwtXEXTM = 'sym';
for k = 2:2:nbIn-2
    switch varargin{k}
      case 'mode'  , dwtXEXTM = varargin{k+1};
    end
end

% Initialization.
if isempty(X) , wdec = {}; return; end
sizes = zeros(level+1,3);
sizes(level+1,1:3) = size(X);
for k=1:level
    wdec = dwt3X(X,{LoD,HiD,LoR,HiR},'mode',dwtXEXTM);
    X = wdec.dec{1,1,1};
    if length(size(X))>2
        sizes(level+1-k,1:3) = size(X);
    else
        sizes(level+1-k,1:3) = ceil(sizes(level+2-k,1:3)/2);
    end
    wdec.dec = reshape(wdec.dec,8,1,1);
    if k>1
        cfs(1) = [];
        cfs = cat(1,wdec.dec,cfs);
    else
        cfs = wdec.dec;
    end
end
wdec.sizeINI = sizes(end,:);
wdec.level = level;
wdec.dec   = cfs;
wdec.sizes = sizes;
wdec = orderfields(wdec,{'sizeINI','level','filters','mode','dec','sizes'});

