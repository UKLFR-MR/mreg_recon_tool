function [d,pmin,xmin] = linmin(p,xi,func)
% LINMIN Given point p, direction xi, finds minimum
% bracket first, then returns fret the value of func at returned location
% pmin. From Num Recipes p419
% LINMIN_SENSE variant for sense code 1d. Given start position p, finds minimum along direction
% xi. Func = 0.5*norm(Eb-m) needs s_fit_decorr, nc, trajectory_coords
% and m.
global xicom pcom % global variables to be used in brentn.m and mnbrakn.m
ax = 0;
xx = 10;
pcom = p;
xicom = xi/norm(xi(:)); % normalize xi in case it's big
[a,b,c,fa,fb,fc] = mnbrakn(ax,xx,func);
[xmin,fret] = brentn(a,b,c,func,0.01);
% Construct vector to return
pmin = pcom + xmin*xicom; % minimum pmin
d = pmin - pcom; % displacement vector from p to pmin 