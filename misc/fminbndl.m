function [xf,fval,exitflag,output] = fminbndl(funfcn,ax,bx,options,varargin)

% function [xf,fval,exitflag,output] = fminbndl(funfcn,ax,bx,options,varargin)
%
% works as fminbnd, but specially tailored for regularization
% paramter optimization using the minimum product criterion.
% Since we know that the minimum lies left of bx, it prevents the search
% from going into the wrong direction.

if nargin<=3,
    options = [];
end

c = 0.5*(3.0 - sqrt(5.0));


fbx = funfcn(bx,varargin{:});
fx = funfcn(ax + c*(bx-ax),varargin{:});
while fx>fbx
    bx = ax + c*(bx-ax);
    fbx = fx;
    fx = funfcn(ax + c*(bx-ax),varargin{:});
end
bx = ax + c*(bx-ax);

[xf,fval,exitflag,output] = fminbnd(funfcn,ax,bx,options,varargin{:});