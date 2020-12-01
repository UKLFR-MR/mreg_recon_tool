function [a,h,v,d] = hlwt2X(x,integerFlag) %#ok<INUSD>
%HLWT2 Haar (Integer) Wavelet decomposition 2-D using liftingX.
%
%   [CA,CH,CV,CD] = HLWT2(X) computes the approximation
%   coefficients matrix CA and detail coefficients matrices
%   CH, CV and CD obtained by a liftingX wavelet decomposition, 
%   of the matrix X.
%
%     [a,h,v,d] = hlwt2X(x) ou
%     [a,h,v,d] = hlwt2X(x,integerFlag)
%     Dans le cas 2, on a une transformation en entiers
%     modulo la normalisation.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-Jan-2000.
%   Last Revision 24-Jan-2008
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $ 

% Test si transformation en entiers.
notInteger = nargin<2;

% Splitting.
if ndims(x)>2 , x = double(x); end
L = x(:,2:2:end,:);
H = x(:,1:2:end,:);

% Lifting.
H = H-L;        % Dual liftingX.
if notInteger
    L = (L+H/2);      % Primal liftingX.
else
    L = (L+fix(H/2)); % Primal liftingX.
end

% Splitting.
a = L(2:2:end,:);
h = L(1:2:end,:);
clear L

% Lifting.
h = h-a;        % Dual liftingX.
if notInteger
    a = (a+h/2);      % Primal liftingX.
else
    a = (a+fix(h/2)); % Primal liftingX.
end

% Splitting.
v = H(2:2:end,:);
d = H(1:2:end,:);

% Lifting.
d = d-v;         % Dual liftingX.
if notInteger
    v = (v+d/2); % Primal liftingX.
    % Normalization.
    h = h/2;
    v = v/2;
    d = d/4;
else
    v = (v+fix(d/2)); % Primal liftingX.
end

