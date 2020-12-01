function wt = dwt3X(X,varargin)
%DWT3 Single-level discrete 3-D wavelet transform.
%   DWT3 performs a single-level 3-D wavelet decomposition
%   with respect to either a particular wavelet ('wname',
%   see WFILTERS for more information) or particular wavelet 
%   decomposition and reconstruction filters you specify, and 
%   using a specified DWT extension mode (see DWTMODE).
%
%   WT = DWT3(X,'wname','mode','ExtM') returns the 3-D wavelet transform
%   of the 3-D array X, 'wname' is a string containing the wavelet 
%   name and 'ExtM' is a string containing the extension mode.
%   WT = DWT3(X,'wname') uses the default extension mode: 'sym'.
%   
%   WT is a structure with the following fields:
%     sizeINI: contains the size of the 3-D array X.
%     mode:    contains the name of the wavelet transform extension mode.
%     filters: is a structure with 4 fields LoD, HiD, LoR, HiR which
%              contain the filters used for DWT.
%     dec:     is a 2x2x2 cell array containing the coefficients 
%              of the decomposition.
%              dec{i,j,k} for i,j,k = 1 or 2 contains the coefficients
%              obtained by low-pass filtering (for i or j or k = 1)
%              or high-pass filtering (for i or j or k = 2).              
%
%   Instead of a single wavelet, you may specify three wavelets (i.e. 
%   one wavelet for each direction):
%   WT = DWT3(X,W,...) with W = {'wname1','wname2','wname3'} or W a 
%   structure with 3 fields 'w1', 'w2', 'w3' containing strings which
%   are the names of wavelets.
%
%   Instead of wavelets you may specify filters: 4 filters (2 for
%   decomposition and 2 for reconstruction) or 3x4 filters (one 
%   quadruplet by direction): WT = DWT3(X,WF,...)
%   Where WF must be a cell array (1x4) or (3x4) : {LoD,HiD,LoR,HiR},
%   or a structure with the four fields 'LoD', 'HiD', 'LoR', 'HiR'.
%
%   Examples:
%       X = reshape(1:64,4,4,4)
%       wt = dwt3X(X,'db1')
%       [LoD,HiD,LoR,HiR] = wfiltersX('db2');
%       wt = dwt3X(X,{LoD,HiD,LoR,HiR})
%       WS = struct('w1','db1','w2','db2','w3','db1');
%       wt = dwt3X(X,WS,'mode','per')
%       WF = wt.filters;
%       wtBIS = dwt3X(X,WF,'mode','sym')
%
%   See also dwtmodeX, idwt3X, wavedec3X, waverec3X, waveinfoX.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Dec-2008.
%   Last Revision: 21-Oct-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Check arguments.
nbIn = nargin;
msg = nargchk(2,4,nbIn); %#ok<NCHK>
if ~isempty(msg)
    error('Wavelet:FunctionInput:NbArg',msg)
end
LoD = cell(1,3); HiD = cell(1,3); LoR = cell(1,3); HiR = cell(1,3);
argStatus = true;
nextARG = 2;
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
        argStatus = false;
    end
    
elseif iscell(varargin{1})
    if ischar(varargin{1}{1})
        for k = 1:3
            [LoD{k},HiD{k},LoR{k},HiR{k}] = wfiltersX(varargin{1}{k});
        end
    elseif iscell(varargin{1})
        Sarg = size(varargin{1});
        if isequal(Sarg,[1 4])
            if ~iscell(varargin{1}{1})
                LoD(1:end) = varargin{1}(1); HiD(1:end) = varargin{1}(2);
                LoR(1:end) = varargin{1}(3); HiR(1:end) = varargin{1}(4);
            else
                LoD = varargin{1}{1}; HiD = varargin{1}{2};
                LoR = varargin{1}{3}; HiR = varargin{1}{4};
            end
        elseif isequal(Sarg,[3 4])
            LoD = varargin{1}(:,1)'; HiD = varargin{1}(:,2)';
            LoR = varargin{1}(:,3)'; HiR = varargin{1}(:,4)';
        else
            argStatus = false;
        end
    end
else
    argStatus = false;
end
if ~argStatus
    error('Wavelet:FunctionInput:ArgVal','Invalid argument value!');
end
sX = size(X);

% Check arguments for Extension.
dwtXEXTM = 'sym';
for k = nextARG:2:nbIn-1
    switch varargin{k}
      case 'mode'  , dwtXEXTM = varargin{k+1};
    end
end

X = double(X);
dec = cell(2,2,2);
permVect = [];
[a_Lo,d_Hi] = wdec1D(X,LoD{1},HiD{1},permVect,dwtXEXTM);
permVect = [2,1,3];
[aa_Lo_Lo,da_Lo_Hi] = wdec1D(a_Lo,LoD{2},HiD{2},permVect,dwtXEXTM);
[ad_Hi_Lo,dd_Hi_Hi] = wdec1D(d_Hi,LoD{2},HiD{2},permVect,dwtXEXTM);
permVect = [1,3,2];
[dec{1,1,1},dec{1,1,2}] = wdec1D(aa_Lo_Lo,LoD{3},HiD{3},permVect,dwtXEXTM);
[dec{2,1,1},dec{2,1,2}] = wdec1D(da_Lo_Hi,LoD{3},HiD{3},permVect,dwtXEXTM);
[dec{1,2,1},dec{1,2,2}] = wdec1D(ad_Hi_Lo,LoD{3},HiD{3},permVect,dwtXEXTM);
[dec{2,2,1},dec{2,2,2}] = wdec1D(dd_Hi_Hi,LoD{3},HiD{3},permVect,dwtXEXTM);
wt.sizeINI = sX;
wt.filters.LoD = LoD;
wt.filters.HiD = HiD;
wt.filters.LoR = LoR;
wt.filters.HiR = HiR;
wt.mode = dwtXEXTM;
wt.dec = dec;

%-----------------------------------------------------------------------%
function [L,H] = wdec1D(X,Lo,Hi,perm,dwtXEXTM)

if ~isempty(perm) , X = permute(X,perm); end
sX = size(X);
if length(sX)<3 , sX(3) = 1; end

lf = length(Lo);
lx = sX(2);
lc = lx+lf-1;
if lx<lf+1
    nbAdd = lf-lx+1;
    switch dwtXEXTM
        case {'sym','symh','symw','asym','asymh','asymw','ppd'}
            Add = zeros(sX(1),nbAdd,sX(3));
            X = [Add , X , Add];
    end
end

switch dwtXEXTM
    case 'zpd'             % Zero extension.
        
    case {'sym','symh'}    % Symmetric extension (half-point).
        X = [X(:,lf-1:-1:1,:) , X , X(:,end:-1:end-lf+1,:)];
        
    case 'sp0'             % Smooth extension of order 0.
        X = [X(:,ones(1,lf-1),:) , X , X(:,lx*ones(1,lf-1),:)];
        
    case {'sp1','spd'}     % Smooth extension of order 1.
        Z = zeros(sX(1),sX(2)+ 2*lf-2,sX(3));
        Z(:,lf:lf+lx-1,:) = X;
        last = sX(2)+lf-1;
        for k = 1:lf-1
            Z(:,last+k,:) = 2*Z(:,last+k-1,:)- Z(:,last+k-2,:);
            Z(:,lf-k,:)   = 2*Z(:,lf-k+1,:)- Z(:,lf-k+2,:);
        end
        X = Z; clear Z;
        
    case 'symw'            % Symmetric extension (whole-point).
        X = [X(:,lf:-1:2,:) , X , X(:,end-1:-1:end-lf,:)];
        
    case {'asym','asymh'}  % Antisymmetric extension (half-point).
        X = [-X(:,lf-1:-1:1,:) , X , -X(:,end:-1:end-lf+1,:)];        
        
    case 'asymw'           % Antisymmetric extension (whole-point).
        X = [-X(:,lf:-1:2,:) , X , -X(:,end-1:-1:end-lf,:)];

    case 'rndu'            % Uniformly randomized extension.
        X = [randn(sX(1),lf-1,sX(3)) , X , randn(sX(1),lf-1,sX(3))];        
                        
    case 'rndn'            % Normally randomized extension.
        X = [randn(sX(1),lf-1,sX(3)) , X , randn(sX(1),lf-1,sX(3))];        
                
    case 'ppd'             % Periodized extension (1).
        X = [X(:,end-lf+2:end,:) , X , X(:,1:lf-1,:)];
        
    case 'per'             % Periodized extension (2).
        if rem(lx,2) , X = [X , X(:,end,:)]; lx = lx + 1; end
        I = [lx-lf+1:lx , 1:lx , 1:lf];
        if lx<lf
            I = mod(I,lx);
            I(I==0) = lx;
        end
        X = X(:,I,:);
end
L = convn(X,Lo);
H = convn(X,Hi);
clear X
switch dwtXEXTM
    case 'zpd'
    otherwise
        lenL = size(L,2);
        first = lf; last = lenL-lf+1;
        L = L(:,first:last,:); H = H(:,first:last,:);
        lenL = size(L,2);
        first = 1+floor((lenL-lc)/2);  last = first+lc-1;
        L = L(:,first:last,:); H = H(:,first:last,:);
end
L = L(:,2:2:end,:);
H = H(:,2:2:end,:);
if isequal(dwtXEXTM,'per')
    last = ceil(lx/2);
    L = L(:,1:last,:);
    H = H(:,1:last,:);
end

if ~isempty(perm)
    L = permute(L,perm);
    H = permute(H,perm);
end
%-----------------------------------------------------------------------%
