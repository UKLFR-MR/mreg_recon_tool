function t = wfustreeX(x,depth,wname,userdata)
%WFUSTREE Creation of a wavelet decomposition TREE.
%   T = WFUSTREE(X,DEPTH,WNAME) returns a wavelet decomposition 
%   tree T (WDECTREE Object) of order 4 corresponding to 
%   a wavelet decomposition of the matrix (image) X, at level 
%   DEPTH with a particular wavelet WNAME.
%   The DWT extension mode used is the current one.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 01-Aug-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Check arguments.
%-----------------
msg = nargchk(3,4,nargin);
if ~isempty(msg)
    error('Wavelet:FunctionInput:NbArg',msg)
end
if nargin<4 , userdata = {}; end
dimData = 2;
dwtXATTR = dwtmodeX('get');
WT_Settings = struct(...
    'typeWT','dwtX','wname',wname,...
    'extMode',dwtXATTR.extMode,'shift',dwtXATTR.shift2D);

% Tree creation.
%---------------
t = wdectree(x,dimData,depth,WT_Settings,userdata);
