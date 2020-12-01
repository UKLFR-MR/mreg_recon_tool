function [y,I] = localmaxX(x,rowInit,reguleFLG)
%LOCALMAX Compute local maxima positions.
%   For a matrix X, LOCALMAX computes and chains the local 
%   maxima along the rows.
%       [Y,I] = LOCALMAX(X,ROWINIT,REGFLAG); or 
%       [Y,I] = LOCALMAX(X,ROWINIT); or
%       [Y,I] = LOCALMAX(X);
%   The default values are: ROWINIT = size(X,1) and REGFLAG = true.
%
%   First, LOCALMAX computes the local maxima positions on each 
%   row of X. Then, starting from the row (ROWINIT-1), LOCALMAX chains
%   the maxima positions along the columns. If p0 is a local maxima 
%   position on the row R0, then p0 is linked to the nearest maxima 
%   position on the row R0+1.
%       Y is a matrix of the same size of X such that:
%       When R = ROWINIT, Y(ROWINIT,j) = j if X(ROWINIT,j) is a local
%       maximum and 0 otherwise.
%       When R < ROWINIT, if X(R,j) is not a local maximum then Y(R,j) = 0.
%       Otherwise if X(R,j) is a local maximum, then Y(R,j) = k,
%       where k is such that: X(R+1,k) is a local maximum and k is the 
%       nearest position of j.
%       I contains the indices of non zero values of Y
%
%   If REGFLAG = true, S = X(ROWINIT,:) is first regularized using
%   the wavelet 'sym4'. Instead of S, the approximation of level 5
%   is used to start the algorithm.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 05-Oct-96.
%   Last Revision: 01-Oct-20057.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

r = size(x,1);
if nargin<2
    rowInit = r; reguleFLG = true;
elseif nargin<3
    reguleFLG = true;
end
if isempty(rowInit) || (rowInit<1) || (rowInit>r)
    rowInit = r;
end

% Regularization of  x (!?)
%--------------------------
if reguleFLG
    wav = 'sym4';
    lev = 5;
    [cfs,len] = wavedecX(x(rowInit,:),lev,wav);
    x(rowInit,:) = wrcoefX('a',cfs,len,wav);
end
y = [zeros(r,1) diff(abs(x),1,2)];
y(abs(y)<sqrt(eps)) = 0;
y(y<0) = -1;
y(y>0) = 1;
y = diff(y,1,2);
I = find(y==-2);
y = zeros(size(x));
y(I) = 1;


% Chain maxima - Eliminate "false" maxima.
%-----------------------------------------
ideb = rowInit ; step = -1; ifin = 1;
max_down = find(y(ideb,:));
y(ideb,max_down) = max_down;
if rowInit<2 , return; end

for jj = ideb+step:step:ifin
    max_curr = find(y(jj,:));
    val_max  = zeros(size(max_curr));
    for k = 1:length(max_down)
        [nul,ind] = min(abs(max_curr-max_down(k)));
        val_max(ind) = max_down(k);
    end
    y(jj,max_curr) = val_max;
    max_down = max_curr(val_max~=0);
end
