function x = waverec2X(c,s,varargin)
%WAVEREC2  Multilevel 2-D wavelet reconstruction.
%   WAVEREC2 performs a multilevel 2-D wavelet reconstruction
%   using either a specific wavelet ('wname', see WFILTERS) or
%   specific reconstruction filters (Lo_R and Hi_R).
%
%   X = WAVEREC2(C,S,'wname') reconstructs the matrix X
%   based on the multi-level wavelet decomposition structure
%   [C,S] (see WAVEDEC2).
%
%   For X = WAVEREC2(C,S,Lo_R,Hi_R),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
%
%   NOTE: If C and S are obtained from an indexed image analysis
%   (respectively a truecolor image analysis) then X is an
%   m-by-n matrice (respectively an m-by-n-by-3 array).
%   For more information on image formats, see the reference
%   pages of IMAGE and IMFINFO functions.
%   
%   See also APPCOEF2, IDWT2, WAVEDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 07-Oct-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
% $Revision: 1.1 $

% Check arguments.
msg = nargchk(3,4,nargin);
if ~isempty(msg)
    error('Wavelet:FunctionInput:NbArg',msg)
end

x = appcoef2X(c,s,varargin{:},0);
