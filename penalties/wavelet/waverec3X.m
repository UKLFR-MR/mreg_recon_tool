function X = waverec3X(wdec,varargin)
%WAVEREC3 Multilevel 3-D wavelet reconstruction.
%   WAVEREC3 performs a multilevel 3-D wavelet reconstruction
%   starting from a multilevel 3-D wavelet decomposition.
%
%   X = WAVEREC3(WDEC) reconstructs the 3-D array X based
%   on the multilevel wavelet decomposition structure WDEC.
%
%   In addition, you can use WAVEREC3 to simply extract coefficients 
%   from a 3-D wavelet decomposition (see below).
%
%   WDEC is a structure with the following fields:
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
%   C = WAVEREC3(WDEC,TYPE,N) reconstructs the multilevel
%   components at level N of a 3-D wavelet decomposition. N must be
%   a positive integer less or equal to the level of the decomposition.
%   The valid values for TYPE are:
%       - A group of 3 chars 'xyz', one per direction, with 'x','y' and 'z' 
%         in the set {'a','d','l','h'} or in the corresponding upper case  
%         set {'A','D','L','H'}), where 'A' (or 'L') stands for low pass 
%         filter and 'D' (or 'H') stands for high pass filter.
%       - The char 'd' (or 'h' or 'D' or 'H') gives directly the sum of 
%         all the components different from the low pass one.
%       - The char 'a' (or 'l' or 'A' or 'L') gives the low pass 
%         component (the approximation at level N).
%
%   For extraction purpose, the valid values for TYPE are the same as
%   above prefixed by 'c' or 'C'.
%
%   X = WAVEREC3(WDEC,'a',0) or X = WAVEREC3(WDEC,'ca',0) is equivalent
%   to X = WAVEREC3(WDEC).
%
%	C = WAVEREC3(WDEC,TYPE) is equivalent to C = WAVEREC3(WDEC,TYPE,N)
%   with N equal to the level of the decomposition.
%
%   Examples:
%       M = magic(8);
%       X = repmat(M,[1 1 8]);
%       wd = wavedec3X(X,2,'db2','mode','per');
%       XR = waverec3X(wd);
%       err1 = max(abs(X(:)-XR(:)))
%       A = waverec3X(wd,'aaa');
%       CA = waverec3X(wd,'ca');
%       D = waverec3X(wd,'d');
%       err2 = max(abs(X(:)-A(:)-D(:)))
%       A1 = waverec3X(wd,'aaa',1);
%       D1 = waverec3X(wd,'d',1);
%       err3 = max(abs(X(:)-A1(:)-D1(:)))
%       DDD = waverec3X(wd,'ddd',2);
%       disp(DDD(:,:,1))
%
%   See also idwt3X, wavedec3X, waveinfoX.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Dec-2008.
%   Last Revision: 12-Oct-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Check arguments.
nbIn = length(varargin);

% Initialization.
cfs   = wdec.dec;
sizes = wdec.sizes;
level = wdec.level;
cfsFLAG = false;
nbREC_UP = level;

if nbIn>0
    errorFLAG = false;
    type = varargin{1};
    nbChar = length(type);
    if nbChar==2 || nbChar==4
        if isequal(upper(type(1)),'C')
            type(1) = []; nbChar = nbChar-1; cfsFLAG = true;
        else
            errorFLAG = true;
        end
    end
    switch nbChar
        case {1,3}
            num = ones(1,3);
            switch type
                case {'a','l','A','L','1'} , num = Inf;
                case {'d','h','D','H','0'} , num = -num;
                otherwise
                    if nbChar==3
                        for k = 1:3
                            switch type(k)
                                case {'a','l','A','L','1'}
                                case {'d','h','D','H','0'} , num(k) = 2;
                                otherwise , errorFLAG = true;
                            end
                        end
                    else
                        errorFLAG = true;
                    end
            end                        
        otherwise , errorFLAG = true;
    end
    if isequal(num,[1 1 1]) , num = Inf; end
    
    if errorFLAG
        error('Wavelet:FunctionInput:ArgVal', ...
            'Invalid argument value!');
    end
    
    if nbIn>1
        levREC = varargin{2};
        OKval = isnumeric(levREC) && isequal(levREC,fix(levREC)) && ...
            levREC<=level && (levREC>0 || ...
            (levREC==0 && (isequal(num,[1 1 1]) || isinf(num))) );
        if ~OKval
                error('Wavelet:FunctionInput:ArgVal', ...
                    'Invalid argument value!');
        end
    else
        levREC = level;
    end
    if isinf(num)
        First_toDEL = 2+7*(level-levREC);
        for k = First_toDEL:(7*level+1) , cfs{k}(:) = 0; end
        if cfsFLAG
            if isequal(level,levREC) , X = cfs{1}; return; end
            nbREC_UP = level-levREC;
        end
        
    elseif isequal(num,[-1,-1,-1])
        cfs{1}(:) = 0;
        for k = 1:(level-levREC)
            for j = 1:7 , cfs{7*(k-1)+j+1}(:) = 0; end
        end
        if cfsFLAG , X = cfs; end
        
    else
        num(num==2) = 0;
        Idx_toKeep = 1+7*(level-levREC+1) - bin2dec(dec2bin(num)');
        if cfsFLAG
            if (~isequal(num,[1,1,1]) || isequal(level,levREC))
                X = cfs{Idx_toKeep};
                return
            elseif isequal(num,[1,1,1])
                nbREC_UP = level-levREC;
            end
        end
        for k = 1:(7*level+1)
            if k~=Idx_toKeep , cfs{k}(:) = 0; end
        end
        
    end
end

idxBeg = 1;
for k=1:nbREC_UP
    idxEnd = idxBeg+7;
    wdec.dec = reshape(cfs(idxBeg:idxEnd),2,2,2);
    X = idwt3X(wdec,sizes(k+1,:));
    cfs{idxEnd} = X;
    idxBeg = idxEnd;
end
