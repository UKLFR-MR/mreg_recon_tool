function [Lo_D,Hi_D,Lo_R,Hi_R] = orthfiltX(W,P)
%ORTHFILT Orthogonal wavelet filter set.
%   [LO_D,HI_D,LO_R,HI_R] = ORTHFILT(W) computes the
%   four filters associated with the scaling filter W 
%   corresponding to a wavelet:
%   LO_D = decomposition low-pass filter
%   HI_D = decomposition high-pass filter
%   LO_R = reconstruction low-pass filter
%   HI_R = reconstruction high-pass filter.
%
%   See also BIORFILT, QMF, WFILTERS.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 13-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.1 $

% Check arguments.
if nargin<2 , P = 0; end

% Normalize filter sum.
W = W/sum(W);

% Associated filters.
Lo_R = sqrt(2)*W;
Hi_R = qmfX(Lo_R,P);
Hi_D = wrevX(Hi_R);
Lo_D = wrevX(Lo_R);
