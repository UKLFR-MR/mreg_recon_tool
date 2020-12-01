function B = subsref(A,index)
%SUBSREF Subscripted reference for Laurent matrix.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2001.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:54:03 $ 

switch index.type
case '()',
    MA = A.Matrix;
    B = laurmat(MA(index.subs{:}));
    
case '{}',
    B = A.Matrix(index.subs{:});
    if length(B)<2
        B = B{:};
    end
    
case '.',
    if isequal(index.subs,'Matrix')
       B = A.Matrix;
    else
       error('Wavelet:FunctionArgVal:Invalid_ArgVal',...
           'Invalid field name.')
    end
end
