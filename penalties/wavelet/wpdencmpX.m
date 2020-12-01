function varargout = wpdencmpX(varargin)
%WPDENCMP De-noising or compression using wavelet packets.
%   [XD,TREED,PERF0,PERFL2] =
%   WPDENCMP(X,SORH,N,'wname',CRIT,PAR,KEEPAPP)
%   returns a de-noised or compressed version XD of input
%   signal X (1-D or 2-D) obtained by wavelet packet
%   coefficients thresholding.
%   The additional output argument TREED is the
%   wavelet packet best tree decomposition of XD.
%   PERFL2 and PERF0 are L^2 recovery and compression
%   scores in percentages.
%   PERFL2 = 100*(vector-norm of WP-cfs of XD)^2 over
%   (vector-norm of WP-cfs of X)^2
%
%   SORH ('s' or 'h') is for soft or hard thresholding
%   (see WTHRESH for more details).
%   Wavelet packet decomposition is performed at level N,
%   and 'wname' is a string containing the wavelet name.
%   Best decomposition is performed using entropy criterion
%   defined by string CRIT and parameter PAR (see WENTROPY
%   for details). Threshold parameter is also PAR.
%   If KEEPAPP = 1, approximation coefficients cannot be
%   thresholded; otherwise, they can be.
%   ---------------------------------------------------------
%   [XD,TREED,PERF0,PERFL2] =
%   WPDENCMP(TREE,SORH,CRIT,PAR,KEEPAPP)
%   has same output arguments, using the same options as
%   above, but obtained directly from the input wavelet
%   packet tree decomposition TREE of the
%   signal to be de-noised or compressed.
%   In addition if CRIT = 'nobest' no optimization is done
%   and the current decomposition is thresholded.
%
%   See also DDENCMP, WDENCMP, WENTROPY, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 23-Aug-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $

% Check arguments and set problem dimension.
nbIN    = nargin;
nbOUT   = nargout;
if ~any([5 7]==nbIN)
    error('Wavelet:FunctionInput:Invalid_ArgNum', ...
        'Invalid number of input arguments.');
end
if ~any(0:4==nbOUT)
    error('Wavelet:FunctionOutput:Invalid_ArgNum', ...
        'Invalid number of output arguments.');
end

switch nbIN
    case 5
        Ts = varargin{1};        
        num_IN = 2;        
        [sorh,crit,par,keepapp] = deal(varargin{num_IN:end});
        sizdat = read(Ts,'sizes');
        dim = size(sizdat,1);

    case 7
        [x,sorh,n,w,crit,par,keepapp] = deal(varargin{1:7});
        if errargtX(mfilename,n,'int')
            error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
                'Invalid argument value.');
        end
        if errargtX(mfilename,w,'str')
            error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
                'Invalid argument value.');
        end
        dim = 1; if min(size(x)) ~= 1, dim = 2; end
end
if errargtX(mfilename,sorh,'str')
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end
if errargtX(mfilename,crit,'str')
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end
num_OUT = 1;

if nargin==7
    % Wavelet packet decomposition of x.
    switch dim
        case 1 , Ts = wpdecX(x,n,w,crit,par);
        case 2 , Ts = wpdec2X(x,n,w,crit,par);
    end

elseif strcmp(crit,'nobest') == 0
    % Update entropy.
    Ts = entrupd(Ts,crit,par);
end
if strcmp(crit,'nobest') == 0
    % Perform best tree.
    Ts = besttree(Ts);
end

% Wavelet packet coefficients thresholding.
Tsd = wpthcoef(Ts,keepapp,sorh,par);

% Wavelet packet reconstruction of xd.
varargout{num_OUT} = wpcoef(Tsd,0);
if nbOUT<2 , return; else num_OUT = num_OUT+1; end

varargout{num_OUT} = Tsd;
if nbOUT<3 , return; else num_OUT = num_OUT+1; end

% Compute L^2 recovery and compression scores.
% Extract final coefficients after thresholding.
cfs = read(Tsd,'allcfs');

% Compute compression score.
varargout{num_OUT} = 100*(length(find(cfs==0))/length(cfs));
if nbOUT<4 , return; else num_OUT = num_OUT+1; end

% Extract final coefficients before thresholding.
orcfs = read(Ts,'allcfs');

% Compute L^2 recovery score.
nc = norm(orcfs);
if nc<eps
    varargout{num_OUT} = 100;
else
    varargout{num_OUT} = 100*((norm(cfs)/nc)^2);
end
