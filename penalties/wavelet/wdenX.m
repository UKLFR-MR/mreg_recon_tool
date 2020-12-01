function [xd,cxd,lxd] = wdenX(in1,in2,in3,in4,in5,in6,in7)
%WDEN Automatic 1-D de-noising using wavelets.
%   WDEN performs an automatic de-noising process of a 1-D
%   signal using wavelets.
%
%   [XD,CXD,LXD] = WDEN(X,TPTR,SORH,SCAL,N,'wname') returns 
%   a de-noised version XD of input signal X obtained by 
%   thresholding the wavelet coefficients. 
%   Additional output arguments [CXD,LXD] are the wavelet 
%   decomposition structure of de-noised signal XD.
%
%   TPTR string contains threshold selection rule:
%   'rigrsure' use principle of Stein's Unbiased Risk.
%   'heursure' is an heuristic variant of the first option.
%   'sqtwolog' for universal threshold sqrt(2*log(.)).
%   'minimaxi' for minimax thresholding.
%       (see THSELECT for more details).
%   SORH ('s' or 'h') is for soft or hard thresholding
%       (see WTHRESH for more details).
%   SCAL defines multiplicative threshold rescaling:
%     'one' for no rescaling.
%     'sln' for rescaling using a single estimation 
%       of level noise based on first level coefficients.
%     'mln' for rescaling done using level dependent
%       estimation of level noise.
%   Wavelet decomposition is performed at level N and 'wname'
%   is a string containing the name of desired orthogonal
%   wavelet.
%
%   [XD,CXD,LXD] = WDEN(C,L,TPTR,SORH,SCAL,N,'wname') returns 
%   same output arguments, using the same options as above, but 
%   obtained directly from the input wavelet decomposition 
%   structure [C,L] of the signal to be de-noised, at level N
%   and using 'wname' orthogonal wavelet.
%
%   See also THSELECT, WAVEDEC, WDENCMP, WFILTERS, WTHRESH.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 30-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
% $Revision: 1.1 $

% Check arguments.
nbIn = nargin;
switch nbIn
  case {0,1,2,3,4,5}
        error('Wavelet:FunctionInput:NotEnough_ArgNum', ...
            'Not enough input arguments.');
  case 6 ,
      x = in1; tptr = in2; sorh = in3; 
      scal = in4; n = in5; w = in6;
  case 7 ,
      c = in1; l = in2; tptr = in3; 
      sorh = in4; scal = in5; n = in6; w = in7;
end
if errargtX(mfilename,tptr,'str')
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end
if errargtX(mfilename,sorh,'str')
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end
if errargtX(mfilename,scal,'str')
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end
if errargtX(mfilename,n,'int')
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end
if errargtX(mfilename,w,'str')
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end

if nbIn==6
    % Wavelet decomposition of x.
    [c,l] = wavedecX(x,n,w);
end

% Threshold rescaling coefficients.
switch scal
  case 'one' , s = ones(1,n);
  case 'sln' , s = ones(1,n)*wnoisestX(c,l,1);
  case 'mln' , s = wnoisestX(c,l,1:n);
    otherwise
        error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
            'Invalid argument value.');
end

% Wavelet coefficients thresholding.
first = cumsum(l)+1;
first = first(end-2:-1:1);
ld   = l(end-1:-1:2);
last = first+ld-1;
cxd = c;
lxd = l;
for k = 1:n
    flk = first(k):last(k);
    if strcmp(tptr,'sqtwolog') || strcmp(tptr,'minimaxi')
        thr = thselectX(c,tptr);
    else
        if s(k) < sqrt(eps) * max(c(flk))
            thr = 0;
        else
            thr = thselectX(c(flk)/s(k),tptr);
        end
    end                                     % threshold.
    thr      = thr * s(k);                  % rescaled threshold.
    cxd(flk) = wthreshX(c(flk),sorh,thr);    % thresholding or shrinking.
end

% Wavelet reconstruction of xd.
xd = waverecX(cxd,lxd,w); 
