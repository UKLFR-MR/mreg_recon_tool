function varargout = wthrmngrX(option,varargin)
%WTHRMNGR Threshold settings manager.
%   THR = WTHRMNGR(OPTION,METHOD,VARARGIN) returns a 
%   global threshold or level dependent thresholds
%   depending on OPTION. The inputs VARARGIN depend
%   on OPTION and METHOD.
%
%   This function returns the thresholds used throughout
%   the MATLAB Wavelet Toolbox for de-noising and 
%   compression tools (command line M-files or GUI 
%   tools).
%
%   The options for the METHOD parameter are:
%
%   - 'scarcehi'            (see WDCBM or WDCBM2 with high 
%                                predefined value of parameter M).
%   - 'scarceme'            (see WDCBM or WDCBM2 with medium  
%                                predefined value of parameter M).
%   - 'scarcelo'            (see WDCBM or WDCBM2 with low  
%                                predefined value of parameter M).
%
%   - 'sqtwolog'            (see THSELECT option 'sqtwolog' 
%                                and see also WDEN).
%   - 'sqtwologuwn'         (see THSELECT option 'sqtwolog' 
%                                and see also WDEN option 'sln').
%   - 'sqtwologswn'         (see THSELECT option 'sqtwolog' 
%                                and see also WDEN option 'mln').
%   - 'rigrsure'            (see THSELECT option 'rigrsure' 
%                                and see also WDEN).
%   - 'heursure'            (see THSELECT option 'heursure' 
%                                and see also WDEN).
%   - 'minimaxi'            (see THSELECT option 'minimaxi' 
%                                and see also WDEN).
%
%   - 'penalhi'             (see WBMPEN or WPBMPEN with high 
%                                value of parameter ALPHA).
%   - 'penalme'             (see WBMPEN or WPBMPEN with medium  
%                                value of parameter ALPHA).
%   - 'penallo'             (see WBMPEN or WPBMPEN with low  
%                                value of parameter ALPHA).
%
%   - 'rem_n0'              this option returns a threshold
%                           close to 0, a typical THR value is  
%                           median(abs(coefficients)).
%
%   - 'bal_sn'              this option returns a threshold
%                           such that the percentages of retained
%                           energy and number of zeros are 
%                           the same.
%
%   - 'sqrtbal_sn'          this option returns a threshold
%                           equal to the square root of the value
%                           such that the percentages of retained
%                           energy and number of zeros are 
%                           the same.
%
%   #############################  
%   Discrete Wavelet 1-D options:
%   #############################  
%
%    Compression using a global threshold:
%    -------------------------------------
%    X is the signal to be compressed and [C,L] is the wavelet 
%    decomposition structure of the signal to be compressed. 
%     THR = WTHRMNGR('dw1dcompXGBL','rem_n0',X) 
%     THR = WTHRMNGR('dw1dcompXGBL','bal_sn',C,L)
%
%    Compression using level dependent thresholds:
%    ---------------------------------------------
%    X is the signal to be compressed and [C,L] is the wavelet 
%    decomposition structure of the signal to be compressed.
%    ALFA is a sparsity parameter (see WDCBM).
%
%     THR = WTHRMNGR('dw1dcompXLVL','scarcehi',C,L,ALFA)
%            ALFA must be such that 2.5 < ALFA < 10
%     THR = WTHRMNGR('dw1dcompXLVL','scarceme',C,L,ALFA)
%            ALFA must be such that 1.5 < ALFA < 2.5
%     THR = WTHRMNGR('dw1dcompXLVL','scarcelo',C,L,ALFA)
%            ALFA must be such that 1 < ALFA < 2
%
%    De-noising using level dependent thresholds:
%    --------------------------------------------
%    [C,L] is the wavelet decomposition structure of the
%    signal to be de-noised, SCAL defines the 
%    multiplicative threshold rescaling (see WDEN) and
%    ALFA is a sparsity parameter (see WBMPEN).
%
%     THR = WTHRMNGR('dw1ddenoXLVL','sqtwolog',C,L,SCAL)
%     THR = WTHRMNGR('dw1ddenoXLVL','rigrsure',C,L,SCAL)
%     THR = WTHRMNGR('dw1ddenoXLVL','heursure',C,L,SCAL)
%     THR = WTHRMNGR('dw1ddenoXLVL','minimaxi',C,L,SCAL)
%
%     THR = WTHRMNGR('dw1ddenoXLVL','penalhi',C,L,ALFA)
%            ALFA must be such that 2.5 < ALFA < 10
%     THR = WTHRMNGR('dw1ddenoXLVL','penalme',C,L,ALFA)
%            ALFA must be such that 1.5 < ALFA < 2.5
%     THR = WTHRMNGR('dw1ddenoXLVL','penallo',C,L,ALFA)
%            ALFA must be such that 1 < ALFA < 2
%
%   ########################################    
%   Discrete Stationary Wavelet 1-D options:
%   ########################################    
%
%    De-noising using level dependent thresholds:
%    --------------------------------------------
%    SWTDEC is the stationary wavelet decomposition structure 
%    of the signal to be de-noised, SCAL defines the 
%    multiplicative threshold rescaling (see WDEN) and
%    ALFA is a sparsity parameter (see WBMPEN).
%     THR = WTHRMNGR('sw1ddenoLVL',METHOD,SWTDEC,SCAL)
%     THR = WTHRMNGR('sw1ddenoLVL',METHOD,SWTDEC,ALFA)
%     The options for METHOD are the same as in the 'dw1ddenoXLVL'
%     case.
%
%   #############################  
%   Discrete Wavelet 2-D options:
%   #############################  
%
%    Compression using a global threshold:
%    -------------------------------------
%    X is the image to be compressed and [C,S] is the wavelet 
%    decomposition structure of the image to be compressed.
%     THR = WTHRMNGR('dw2dcompXGBL','rem_n0',X)
%     THR = WTHRMNGR('dw2dcompXGBL','bal_sn',C,S)
%     THR = WTHRMNGR('dw2dcompXGBL','sqrtbal_sn',C,S)
%
%    Compression using level dependent thresholds:
%    ---------------------------------------------
%    X is the image to be compressed and [C,S] is the wavelet 
%    decomposition structure of the image to be compressed.
%    ALFA is a sparsity parameter (see WDCBM2).
%
%     THR = WTHRMNGR('dw2dcompXLVL','scarcehi',C,S,ALFA)
%            ALFA must be such that 2.5 < ALFA < 10
%     THR = WTHRMNGR('dw2dcompXLVL','scarceme',C,S,ALFA)
%            ALFA must be such that 1.5 < ALFA < 2.5
%     THR = WTHRMNGR('dw2dcompXLVL','scarcelo',C,S,ALFA)
%            ALFA must be such that 1 < ALFA < 2
%
%    De-noising using level dependent thresholds:
%    --------------------------------------------
%    [C,S] is the wavelet decomposition structure of the
%    image to be de-noised, SCAL defines the 
%    multiplicative threshold rescaling (see WDEN) and
%    ALFA is a sparsity parameter (see WBMPEN).
%
%     THR = WTHRMNGR('dw2ddenoXLVL','penalhi',C,S,ALFA)
%            ALFA must be such that 2.5 < ALFA < 10
%     THR = WTHRMNGR('dw2ddenoXLVL','penalme',C,S,ALFA)
%            ALFA must be such that 1.5 < ALFA < 2.5
%     THR = WTHRMNGR('dw2ddenoXLVL','penallo',C,S,ALFA)
%            ALFA must be such that 1 < ALFA < 2
%
%     THR = WTHRMNGR('dw2ddenoXLVL','sqtwolog',C,S,SCAL)
%     THR = WTHRMNGR('dw2ddenoXLVL','sqrtbal_sn',C,S)
%
%   ########################################  
%   Discrete Stationary Wavelet 2-D options:
%   ########################################  
%
%    De-noising using level dependent thresholds:
%    --------------------------------------------
%    SWTDEC is the stationary wavelet decomposition structure 
%    of the image to be de-noised, SCAL defines the 
%    multiplicative threshold rescaling (see WDEN) and
%    ALFA is a sparsity parameter (see WBMPEN).
%     THR = WTHRMNGR('sw2ddenoLVL',METHOD,SWTDEC,SCAL)
%     THR = WTHRMNGR('sw2ddenoLVL',METHOD,SWTDEC,ALFA)
%     The options for METHOD are the same as in the 'dw2ddenoXLVL'
%     case.
%
%   ####################################  
%   Discrete Wavelet Packet 1-D options:
%   #################################### 
% 
%    Compression using a global threshold:
%    -------------------------------------
%    X is the signal to be compressed and WPT is the wavelet 
%    packet decomposition structure of the signal to be compressed.
%     THR = WTHRMNGR('wp1dcompXGBL','bal_sn',WPT)
%     THR = WTHRMNGR('wp1dcompXGBL','rem_n0',X)
%
%    De-noising using a global threshold:
%    ------------------------------------
%    WPT is the wavelet packet decomposition structure of the signal
%    to be de-noised.
%     THR = WTHRMNGR('wp1ddenoXGBL','sqtwologuwn',WPT)
%     THR = WTHRMNGR('wp1ddenoXGBL','sqtwologswn',WPT)
%     THR = WTHRMNGR('wp1ddenoXGBL','bal_sn',WPT)
%
%     THR = WTHRMNGR('wp1ddenoXGBL','penalhi',WPT)
%            see WPBMPEN with ALFA = 6.25
%     THR = WTHRMNGR('wp1ddenoXGBL','penalme',WPT)
%            see WPBMPEN with ALFA = 2
%     THR = WTHRMNGR('wp1ddenoXGBL','penallo',WPT)
%            see WPBMPEN with ALFA = 1.5
%
%   ####################################  
%   Discrete Wavelet Packet 2-D options:
%   #################################### 
% 
%    Compression using a global threshold:
%    -------------------------------------
%    X is the image to be compressed and WPT is the wavelet 
%    packet decomposition structure of the image to be compressed.
%     THR = WTHRMNGR('wp2dcompXGBL','bal_sn',WPT)
%     THR = WTHRMNGR('wp2dcompXGBL','rem_n0',X)
%     THR = WTHRMNGR('wp2dcompXGBL','sqrtbal_sn',WPT)
%
%    De-noising using a global threshold:
%    ------------------------------------
%    WPT is the wavelet packet decomposition structure of the image
%    to be de-noised.
%     THR = WTHRMNGR('wp2ddenoXGBL','sqtwologuwn',WPT)
%     THR = WTHRMNGR('wp2ddenoXGBL','sqtwologswn',WPT)
%     THR = WTHRMNGR('wp2ddenoXGBL','sqrtbal_sn',WPT)
%
%     THR = WTHRMNGR('wp2ddenoXGBL','penalhi',WPT)
%            see WPBMPEN with ALFA = 6.25
%     THR = WTHRMNGR('wp2ddenoXGBL','penalme',WPT)
%            see WPBMPEN with ALFA = 2
%     THR = WTHRMNGR('wp2ddenoXGBL','penallo',WPT)
%            see WPBMPEN with ALFA = 1.5
%
%   See also THSELECT, WBMPEN, WDCBM, WDCBM2, WDEN, WDENCMP,  
%            WNOISEST, WPBMPEN, WPDENCMP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-Oct-98.
%   Last Revision: 31-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $


meth = varargin{1};
switch option
   case {'dw1dcompXGBL','dw1dcompXLVL','dw1ddenoXLVL','dw1ddenoXDEN'} ,
   case {'dw2dcompXGBL','dw2dcompXLVL','dw2ddenoXLVL'} ,
   case {'wp1dcompXGBL','wp2dcompXGBL'} ,
   case {'wp1ddenoXGBL','wp2ddenoXGBL'} ,
     switch meth
       case 'sqtwologswn' , meth = 'sqtwolog'; scal = 'sln';
       case 'sqtwologuwn' , meth = 'sqtwolog'; scal = 'one';
     end
   case 'sw1ddenoLVL' ,
   case 'sw2ddenoLVL' ,
    otherwise
        errargtX(mfilename,'invalid option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid argument value.');
end
flgTYPE = option(1:2);
flgDIM  = str2double(option(3));
flgTOOL = option(5:8);
flgMODE = option(9:11);

if ~isequal(meth,'rem_n0')
    switch option
        case {'dw1dcompXGBL','dw1dcompXLVL','dw1ddenoXLVL','dw1ddenoXDEN'}
            level = length(varargin{3})-2;

        case {'dw2dcompXGBL','dw2dcompXLVL','dw2ddenoXLVL'}
            level = size(varargin{3},1)-2;

        case {'wp1dcompXGBL','wp1ddenoXGBL','wp2dcompXGBL','wp2ddenoXGBL'}
            level = treedpthX(varargin{2});

        case 'sw1ddenoLVL'
            level = size(varargin{2},1)-1;

        case 'sw2ddenoLVL'
            ND = ndims(varargin{2});
            switch ND
                case 3 , level = (size(varargin{2},3)-1)/3;
                case 4 , level = (size(varargin{2},4)-1)/3;
            end
    end
else
    if length(varargin)>2 , level = varargin{3}; end
end

switch option
   case 'sw1ddenoLVL'
       tmp = varargin{2};
       varargin{4} = varargin{3};
       varargin{2} = [];
       varargin{3} = size(tmp,2);
       for k=1:level
           cfs  = tmp(k,1:2^k:end);
           varargin{2} = [cfs , varargin{2}];
           varargin{3} = [length(cfs) , varargin{3}];
       end
       cfs = tmp(level+1,1:2^level:end);
       varargin{2} = [cfs , varargin{2}];
       varargin{3} = [length(cfs) , varargin{3}];

   case 'sw2ddenoLVL'
       tmp = varargin{2};
       varargin{4} = varargin{3};
       varargin{2} = [];
       varargin{3} = size(tmp(:,:,1));
       for k=1:level
           cfs  = tmp(1:2^k:end,1:2^k:end,3*k);
           varargin{2} = [cfs(:)' , varargin{2}];
           cfs  = tmp(1:2^k:end,1:2^k:end,2*k);
           varargin{2} = [cfs(:)' , varargin{2}];
           cfs  = tmp(1:2^k:end,1:2^k:end,1*k);
           varargin{2} = [cfs(:)' , varargin{2}];
           varargin{3} = [size(cfs) ; varargin{3}];
       end
       cfs = tmp(1:2^level:end,1:2^level:end,end);
       varargin{2} = [cfs(:)' , varargin{2}];
       varargin{3} = [size(cfs) ; varargin{3}];
       %----------------------------------------------------
       %      NEW VERSION in preparation for V2008a
       %----------------------------------------------------
       % tmp = varargin{2};
       % sX = size(tmp);
       % lenSX = length(sX);
       % level = (sX(end)-1)/3;
       % a3d_Flag = lenSX>3;
       % idxColon = repmat({'1:2^k:end'},1,lenSX-1);
       % S.type = '()';
       % varargin{4} = varargin{3};
       % varargin{2} = [];
       % varargin{3} = size(tmp(:,:,1));
       % for k=1:level
       %     S.subs = {idxColon{:},3*k};
       %     cfs = subsref(tmp,S);
       %     varargin{2} = [cfs(:)' , varargin{2}];
       %     S.subs = {idxColon{:},2*k};
       %     cfs = subsref(tmp,S);
       %     varargin{2} = [cfs(:)' , varargin{2}];
       %     S.subs = {idxColon{:},k};
       %     cfs = subsref(tmp,S);
       %     varargin{2} = [cfs(:)' , varargin{2}];
       %     varargin{3} = [size(cfs) ; varargin{3}];
       % end
       % cfs = tmp(1:2^level:end,1:2^level:end,end);
       % varargin{2} = [cfs(:)' , varargin{2}];
       % varargin{3} = [size(cfs) ; varargin{3}];
       %---------------------------------------------------------
end

switch flgTOOL
  %============================= COMPRESSION ==============================%
  case 'comp'
    switch flgMODE
      case 'GBL'
        switch meth
           case 'rem_n0'
             % sig = varargin{2};
             %----------------------
             varargout{1} = remNearZero(flgTOOL,flgTYPE,varargin{2});

           case {'bal_sn','sqrtbal_sn'}
             % coefs = varargin{2};
             % sizes = varargin{3};
             %------------------------------
             % tree or wptree = varargin{2};
             % data = varargin{3};
             %-------------------------------
             if length(varargin)<3 , varargin{3} = []; end 
             [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
                   balanceSparsityNorm(meth,flgTYPE,varargin{2:3});
             varargout = {valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR};
        end

      case 'LVL'
        switch meth
           case {'scarcehi','scarceme','scarcelo'}
             % coefs = varargin{2};
             % sizes = varargin{3};
             % alfa  = varargin{4};
             %----------------------
             varargout{1} = scarceStrategies(meth,flgDIM,varargin{2:4});

           case 'rem_n0'
             % sig = varargin{2};
             % lev = varargin{3};
             %-------------------
             valTHR = remNearZero(flgTOOL,flgTYPE,varargin{2});
             varargout{1} = expandTHR(valTHR,flgDIM,level);

           case {'bal_sn','sqrtbal_sn'}
             % coefs = varargin{2};
             % sizes = varargin{3};
             %----------------------
             valTHR = balanceSparsityNorm(meth,flgTYPE,varargin{2:3});
             varargout{1} = expandTHR(valTHR,flgDIM,level);
       end
    end
  %========================================================================%
 
  %============================= DE-NOISING ===============================%
  case 'deno'
    switch flgMODE
      case 'GBL'        % WP only.
        % tree or wptree = varargin{2};
        % data = varargin{3};
        %-----------------------------
        if length(varargin)==2 , varargin{3} = []; end
        switch meth
           case 'sqtwolog'
             [valTHR,maxTHR,cfs] = fixedFormWP(flgDIM,varargin{2:3},scal);
             varargout = {valTHR,maxTHR,cfs};

           case {'bal_sn','sqrtbal_sn'}
             [valTHR,maxTHR,thresVALUES] = ...
                   balanceSparsityNorm(meth,flgTYPE,varargin{2:3});
             varargout = {valTHR,maxTHR,thresVALUES};

           case {'penalhi','penalme','penallo'}
             [valTHR,maxTHR,cfs] = WPpenalStrategies(meth,flgDIM,varargin{2});
             varargout = {valTHR,maxTHR,cfs};
        end

      case 'LVL'
        switch meth
           case 'sqtwolog', % DW & SW only.
             switch flgDIM
                case 1 , varargout{1} = fixedForm1D(varargin{2:4});
                case 2 , varargout{1} = fixedForm2D(varargin{2:4},level);
             end

           case {'rigrsure','heursure','minimaxi'}  % DW1D & SW1D only.
             % coefs = varargin{2};
             % sizes = varargin{3};
             % scal  = varargin{4};
             %----------------------
             coefs = detcoefX(varargin{2:3},'all');
             sigma = sigmaHAT(varargin{4},coefs);
             varargout{1} = getTHR(meth,sigma,coefs);

           case {'penalhi','penalme','penallo'}
             % coefs = varargin{2};
             % sizes = varargin{3};
             % alfa  = varargin{4};
             %----------------------
             valTHR = penalStrategies(meth,flgDIM,varargin{2:4});
             varargout{1} = expandTHR(valTHR,flgDIM,level);

           case {'scarcehi','scarceme','scarcelo'}
             % coefs = varargin{2};
             % sizes = varargin{3};
             % alfa  = varargin{4};
             %----------------------
             varargout{1} = scarceStrategies(meth,flgDIM,varargin{2:4});

           case {'bal_sn','sqrtbal_sn'}
             % coefs = varargin{2};
             % sizes = varargin{3};
             %----------------------
             valTHR = balanceSparsityNorm(meth,flgTYPE,varargin{2:3});
             varargout{1} = expandTHR(valTHR,flgDIM,level);
        end


      case 'DEN'  % estimation de densite
        switch meth
           case 'globalth', 
             % coefs = varargin{2};
             % sizes = varargin{3};
             %----------------------
             varargout{1} = GlobDens(varargin{2:3});

           case {'bylevth1'}
             % coefs = varargin{2};
             % sizes = varargin{3};
             %----------------------
             varargout{1} = LvldDens(varargin{2:3},1);
             
           case {'bylevth2'}
             % coefs = varargin{2};
             % sizes = varargin{3};
             %----------------------
             varargout{1} = LvldDens(varargin{2:3},2);

           case {'bylevsth'}
             % coefs = varargin{2};
             % sizes = varargin{3};
             % alfa  = varargin{4};
             %----------------------
             varargout{1} = LvdsDens(varargin{2:4});
        end
    end
  %========================================================================%

end


%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
                         balanceSparsityNorm(meth,flgTYPE,A,B)

switch flgTYPE
  case {'dw','sw'}
    % coefs = A;
    % sizes = B;
    %-----------
    [thresVALUES,rl2SCR,n0SCR,imin] = wcmpscrX(A,B);

 case 'wp'
    % WP_Tree = varargin{2};
    %-----------------------
    [thresVALUES,rl2SCR,n0SCR,imin] = wpcmpscrX(A);
end
valTHR = thresVALUES(imin);
maxTHR = thresVALUES(end);
if isequal(meth,'sqrtbal_sn') , valTHR = min(sqrt(valTHR),maxTHR); end
%-----------------------------------------------------------------------------%
function valTHR = remNearZero(flgTOOL,flgTYPE,X)

switch flgTOOL
  case 'comp' , argTOOL = 'cmp';
  case 'deno' , argTOOL = 'den';
end
switch flgTYPE
  case 'dw' , argTYPE = 'wv';
  case 'wp' , argTYPE = 'wp';
end
valTHR = ddencmpX(argTOOL,argTYPE,X);
%-----------------------------------------------------------------------------%
function valTHR = scarceStrategies(meth,flgDIM,coefs,sizes,alfa)

switch flgDIM
  case 1 , M = [1 , 1.5 ,   2] * sizes(1);
  case 2 , M = 4 * [1 , 4/3 , 8/3] * prod(sizes(1,:));
end
switch meth
    case 'scarcehi' , M = M(1);
    case 'scarceme' , M = M(2);
    case 'scarcelo' , M = M(3);
end
if flgDIM==1
    valTHR = wdcbmX(coefs,sizes,alfa,M);
else
    valTHR = wdcbm2X(coefs,sizes,alfa,M);
end
%-----------------------------------------------------------------------------%
function valTHR = penalStrategies(meth,flgDIM,coefs,sizes,sliBMVal)

switch flgDIM
  case 1
    sigma = wnoisestX(coefs,sizes,1);
  case 2 
    det   = detcoef2X('compact',coefs,sizes,1);
    sigma = wnoisestX(det);
end
switch meth
  case 'penalhi' , alfa = 5*(3*sliBMVal+1)/8;
  case 'penalme' , alfa = (sliBMVal+5)/4;
  case 'penallo' , alfa = (sliBMVal+3)/4;
end
valTHR = wbmpenX(coefs,sizes,sigma,alfa);
%-----------------------------------------------------------------------------%
function [valTHR,maxTHR,cfs] = WPpenalStrategies(meth,flgDIM,wpt)

sliBMVal = 3;
switch meth
  case 'penalhi' , alfa = 5*(3*sliBMVal+1)/8;
  case 'penalme' , alfa = (sliBMVal+5)/4;
  case 'penallo' , alfa = (sliBMVal+3)/4;
end

% Compute sigma.
%---------------
depth = treedpthX(wpt);
if depth==0 , valTHR = 0; return; end
switch flgDIM
  case 1
    cD1 = wpcoef(wpt,[1,1]);
    sigma = wnoisestX(cD1);
  case 2
    cH1 = wpcoef(wpt,[1,1]);
    cV1 = wpcoef(wpt,[1,2]);
    cD1 = wpcoef(wpt,[1,3]);
    sigma = wnoisestX([cH1(:)',cV1(:)',cD1(:)']);
end
cfs = read(wpt,'allcfs');
valTHR = wpbmpenX(wpt,sigma,alfa);
maxTHR = max(abs(cfs));
valTHR = min(valTHR,maxTHR);
%-----------------------------------------------------------------------------%
function valTHR = expandTHR(valTHR,flgDIM,nbLEV)
switch flgDIM
   case 1 , nbDIR = 1;
   case 2 , nbDIR = 3;
end
valTHR = valTHR*ones(nbDIR,nbLEV);
%-----------------------------------------------------------------------------%
function s = sigmaHAT(scal,coefs)

level = length(coefs);
switch scal
  case 'one' , s = ones(1,level);
  case 'sln' , s = ones(1,level)*wnoisestX(coefs{1});
  case 'mln' , s = wnoisestX(coefs);
end
%-----------------------------------------------------------------------------%
function thr = getTHR(meth,s,coefs)

switch meth
    case 'minimaxi'
      nbcfs = 0;
      for k=1:length(s) , nbcfs = nbcfs+length(coefs{k}); end
      if nbcfs <= 32
          thr = 0*s;
      else
          thr = (0.3936 + 0.1829*(log(nbcfs)/log(2)))*s;
      end

    case {'rigrsure','heursure'}
      thr = zeros(size(s));
      for k=1:length(s)
          mk = max(coefs{k});
          if (mk<sqrt(eps)) || (s(k)<sqrt(eps)*mk)
              thr(k) = 0;
          else
              thr(k) = sureTHR(meth,coefs{k}/s(k));
          end
      end
      thr = thr.*s;
end
%-----------------------------------------------------------------------------%
function thr = sureTHR(meth,x)

x = x(:)';
n = length(x);
switch meth
  case 'rigrsure'
    sx2 = sort(abs(x)).^2;
    risks = (n-(2*(1:n))+(cumsum(sx2)+(n-1:-1:0).*sx2))/n;
    [risk,best] = min(risks);
    thr = sqrt(sx2(best));

  case 'heursure'
    hthr = sqrt(2*log(n));
    eta = (norm(x).^2-n)/n;
    crit = (log(n)/log(2))^(1.5)/sqrt(n);
    if eta < crit
        thr = hthr;
    else
        thr = min(sureTHR('rigrsure',x),hthr);
    end
end
%-----------------------------------------------------------------------------%
function valTHR = fixedForm1D(coefs,sizes,scal)

coefs  = detcoefX(coefs,sizes,'all');
sigma  = sigmaHAT(scal,coefs);
nbcfs = 0;
for k=1:length(coefs)
    nbcfs = nbcfs+length(coefs{k});
end
valTHR = sqrt(2*log(nbcfs))*sigma;
%-----------------------------------------------------------------------------%
function valTHR = fixedForm2D(coefs,sizes,scal,level)

strDET = ['h','d','v'];
s = ones(3,level);
switch scal
  case 'one'
  case 'sln'
    det  = detcoef2X('compact',coefs,sizes,1);
    s = wnoisestX(det) * s;  
  case 'mln'
    for k = 1:level
      det = detcoef2X('compact',coefs,sizes,k);
      s(:,k) = wnoisestX(det) * ones(3,1);
    end
end
valTHR = zeros(3,level);
for d = 1:3
  for k = 1:level
    det = detcoef2X(strDET(d),coefs,sizes,k);
    univTHR     = sqrt(2*log(numel(det)));
    valTHR(d,k) = univTHR*s(d,k);
  end
end
%-----------------------------------------------------------------------------%
function [valTHR,maxTHR,cfs] = fixedFormWP(flgDIM,A,B,scal) %#ok<INUSL>

order = treeordX(A);
nodes = (2:order)'; % nodes for details of level 1.
det = [];
for k =1:length(nodes)
    tmp = wpcoef(A,nodes(k));
    det = [det , tmp(:)']; %#ok<AGROW>
end
cfs = read(A,'allcfs');
univTHR = sqrt(2*log(length(det)));
switch scal
  case 'one' , s = 1;
  case 'sln' , s = wnoisestX(det);
end
valTHR = s*univTHR;
maxTHR = max(abs(cfs));
valTHR = min(valTHR,maxTHR);
%-----------------------------------------------------------------------------%
function valTHR = GlobDens(coefs,sizes)

n = sizes(end);
J = size(sizes,2)-2;
coefs = coefs(sizes(1)+1:end);
valTHR = max(abs(coefs))*log(n)/sqrt(n);
valTHR = expandTHR(valTHR,1,J);
%-----------------------------------------------------------------------------%
function valTHR = LvldDens(coefs,sizes,flag)

J = size(sizes,2)-2;
valTHR = zeros(1,J);
for j=1:J
    d = detcoefX(coefs,sizes,j);
    switch flag
        case 1 , valTHR(j) = 0.4*max(abs(d));
        case 2 , valTHR(j) = 0.8*max(abs(d));
    end
end
%-----------------------------------------------------------------------------%
function valTHR = LvdsDens(coefs,sizes,alfa)

J = size(sizes,2)-2;
valTHR = zeros(1,J);
for j=1:J
    d = detcoefX(coefs,sizes,j);
    valTHR(j) = max(abs(d));
end
valTHR = valTHR * (alfa/(5-sqrt(eps)));
%-----------------------------------------------------------------------------%
function medad = med_ad(x) %#ok<DEFNU>

medad = median(abs(x-median(x)));
%-----------------------------------------------------------------------------%
%=============================================================================%


