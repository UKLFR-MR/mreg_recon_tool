function [t,varargout] = wdtsplit(t,node)
%WDTSPLIT Split (decompose) wavelet packet.
%   WDTSPLIT updates a wavelet packet tree after
%   the decomposition of a node.
%
%   T = WDTSPLIT(T,N) returns the modified tree T
%   corresponding to the decomposition of the node N.
%
%   For a 1-D decomposition: [T,CA,CD] = WDTSPLIT(T,N)
%   with CA = approximation and CD = detail of node N.
%
%   For a 2-D decomposition: [T,CA,CH,CV,CD] = WDTSPLIT(T,N)
%   with CA = approximation and CH, CV, CD = (Horiz., Vert. and
%   Diag.) details of node N.
%
%   See also WAVEDEC, WAVEDEC2, WPDEC, WPDEC2, WPJOIN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Mar-2003.
%   Last Revision: 23-Aug-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:55:34 $

% Check arguments.
msg = nargoutchk(1,5,nargout);
if ~isempty(msg)
    error('Wavelet:FunctionOutput:Invalid_ArgNum',msg);
end
msg = nargchk(2,2,nargin);
if ~isempty(msg)
    error('Wavelet:FunctionInput:Invalid_ArgNum',msg);
end

% Decomposition of the node.
[t,child,varargout] = nodesplt(t,node);
if isempty(child)
    errargt(mfilename,'Invalid node value','msg');
    return
end
