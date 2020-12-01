function x = mat2variable(matFile, varname)

% usage:
%   x = mat2variable(matFile, varname)

if nargin<=1
    S = load(matFile);
else 
    S = load(matFile, varname);
end

Sn = fieldnames(S);
x = S.(Sn{1});