function [xmin,fx] = brentn(ax,bx,cx,f,tol)
% BRENTN One dimension minimization
% From Num Recipes p404
% Given a function f, and bracketing triplet ax,bx,cx s.t. ax < bx < cx,
% and f(ax) > f(bx) < f(cx), this routine isolates minimum to a fractional
% precision of tol using Brent's method.
% BRENTN is the multidimensional version of BRENT
% func has to be passed to function f1dim as an argument
% BRENTN_sense is version for nonlinear conjugate gradient used with
% SENSE. The func has to be passed to function f1dim, together with s_fit_decorr,nc,trajectory_coords,m.

ITMAX = 100;
CGOLD = 0.3819660;
ZEPS = 1e-10;

e = 0;
a = min(ax,cx);
b = max(ax,cx);
v = bx; w = v; x = w;
fx = f1dim(x,f);
fv = fx; fw = fv;
for iter = 1:ITMAX
    xm = 0.5*(a+b);
    tol1 = tol*abs(x)+ZEPS;
    tol2 = 2*tol1;
    if (abs(x-xm) <= (tol2-0.5*(b-a))) % Done
        xmin = x;
        return
    end
    if (abs(e) > tol1) % construct trial parabolic fit
        r = (x-w)*(fx-fv);
        q = (x-v)*(fx-fw);
        p = (x-v)*q - (x-w)*r;
        q = 2*(q-r);
        if (q > 0)
            p = -p;
        end
        q = abs(q);
        etemp = e;
        e = d;
        if (abs(p) >= abs(0.5*q*etemp) | p <= q*(a-x) | p >=q*(b-x))
            if x >= xm
                e = a-x;
            else
                e = b-x;
            end
            d = CGOLD*e; % Take golden section step
        else
            d = p/q; % take parabolic step
            u = x+d;
            if (u-a < tol2 | b-u < tol2)
                d = abs(tol1)*sign(xm-x);
            end
        end
    else
        if x >= xm
            e = a-x;
        else
            e = b-x;
        end
        d = CGOLD*e;
    end
    if abs(d) >= tol1
        u = x+d;
    else
        u = x + abs(tol1)*sign(d);
    end
    fu = f1dim(u,f);
    if (fu <= fx)
        if u >= x
            a = x;
        else
            b = x;
        end
        v = w; w = x; x = u;
        fv = fw; fw = fx; fx = fu;
    else
        if u < x
            a = u;
        else
            b = u;
        end
        if (fu <= fw | w == x)
            v = w;
            w = u;
            fv = fw;
            fw = fu;
        elseif (fu <= fv | v == x | v == w)
            v = u;
            fv = fu;
        end
    end
end
disp(['ITMAX= ' num2str(ITMAX) ': Too many iterations in brentn_sense'])
xmin = x;

function [fval] = f1dim(x,func)
% returns value of func at point pcom + x*xicom
global xicom pcom % defined in linmin.m
xt = pcom + x*xicom;
fval = feval(func,xt);