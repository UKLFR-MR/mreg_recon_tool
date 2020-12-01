function S = plus(A,B)
%PLUS Laurent matrices addition.
%   S = PLUS(A,B) returns a Laurent polynomial which is
%   the sum of the two Laurent polynomials A and B.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2001.
%   Last Revision 01-Mar-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:54:03 $ 

if      isnumeric(A) && length(A)==1 , A = laurmat(A);
elseif  isnumeric(B) && length(B)==1 , B = laurmat(B);
end

MA = A.Matrix;
MB = B.Matrix;
[rA,cA] = size(MA);
[rB,cB] = size(MB);
if (rA~=rB) || (cA~=cB)
    error('Wavelet:FunctionInput:ArgVal',...
        'Error using ==> +\nMatrix dimensions must agree.')
end
MS = cell(rA,cA);
for i=1:rA
    for j=1:cA
        MS{i,j} = MA{i,j}+MB{i,j};
    end
end
S = laurmat(MS);
