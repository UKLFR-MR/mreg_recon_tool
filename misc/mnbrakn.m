function [ax,bx,cx,fa,fb,fc] = mnbrakn(ax,bx,func)
% MNBRAKN Brackets a minimum
% Given a function func, and distinct initial points ax and bx, this
% routine searches in downhill direction and finds new points a,b,c that bracket the minimum. 
% Also returns function values at these points. From Num Recipes p400
% MNBRAKN is the multidimensional version of MNBRAK
% func has to be passed to function f1dim as an argument
% MNBRAKN_sense is version for nonlinear conjugate gradient used with
% SENSE. The func has to be passed to function f1dim, together with s_fit_decorr,nc,trajectory_coords,m.

GOLD = 1.618034; % Golden ratio
GLIMIT = 100;

fa = f1dim(ax,func);
fb = f1dim(bx,func);
if fb > fa
    dum = fb;
    fb = fa;
    fa = dum;
    dum = bx;
    bx = ax;
    ax = dum;
end
% first guess for c
cx = bx + GOLD*(bx-ax);
fc = f1dim(cx,func);
while (fb > fc) % Keep returning here until we bracket
    r = (bx-ax)*(fb-fc); % compute u by parabolic extrapolation from a,b,c
    q = (bx-cx)*(fb-fa);
    u = bx - ((bx-cx)*q - sign(q-r)*(bx-ax)*r)/(2*abs(max(abs(q-r),eps)));
    ulim = bx + GLIMIT*(cx-bx);
    if ((bx-u)*(u-cx) > 0) % parabolic u is between b and c: try it
        fu = f1dim(u,func);
        if (fu < fc) % got a minimum between b and c
            ax = bx;
            bx = u;
            fa = fb;
            fb = fu;
            return
        elseif (fu > fb) % got a minimum between a and u
            cx = u;
            fc = fu;
            return;
        end
        u = cx + GOLD*(cx-bx); % parabolic fit was no use. Jump beyond cx.
        fu = f1dim(u,func);
    elseif ((cx-u)*(u-ulim) > 0) % parabolic fit is between c and limit
        fu = f1dim(u,func);
        if (fu < fc)
            bx = cx;
            cx = u;
            u = cx + GOLD*(cx-bx);
            fb = fc;
            fc = fu;
            fu = f1dim(u,func);
        end
    elseif ((u-ulim)*(ulim-cx) >= 0) % parabolic fit is beyond limit: set to ulim
        u = ulim;
        fu = f1dim(u,func);
    else
        u = cx + GOLD*(cx-bx);
        fu = f1dim(u,func);
    end
    ax = bx;
    bx = cx;
    cx = u;
    fa = fb;
    fb = fc;
    fc = fu;
end

function [fval] = f1dim(x,func)
% returns value of func at point pcom + x*xicom
global xicom pcom % defined in linmin.m
xt = pcom + x*xicom;
fval = feval(func,xt);