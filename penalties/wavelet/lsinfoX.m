function lsinfoX
%LSINFO Information about liftingX schemes.
%   A liftingX scheme (LS) is a N x 3 cell array. The N-1 first
%   rows of the array are "elementary liftingX steps" (ELS).
%   The last row gives the normalization of LS.
%
%   Each ELS has the following format: 
%      {type , coefficients , max_degree}
%   where:
%     - "type" is equal to 'p' (primal) or 'd' (dual).
%     - "coefficients" is a vector C of real numbers defining
%        the coefficients of a Laurent polynomial P described
%        below.
%     - "max_degree" is the highest degree d of the monomials
%        of P.
%     The Laurent polynomial P is of the form:
%       P(z) = C(1)*z^d + C(2)*z^(d-1) + ... + C(m)*z^(d-m+1)
%   
%   So the Lifting Scheme LS is such that:
%     for k = 1:N-1 , LS{k,:} is an ELS:
%         LS{k,1} is the liftingX "type" 'p' (primal) or 'd' (dual).
%         LS{k,2} is the corresponding liftingX filter.
%         LS{k,3} is the highest degree of the Laurent polynomial
%                 corresponding to the filter LS{k,2}.
%     LS{N,1} is the primal normalization (real number).
%     LS{N,2} is the dual normalization (real number).
%     LS{N,3} is not used.
%     Usually, the normalizations are such that LS{N,1}*LS{N,2} = 1.
%
%   For example, the liftingX scheme associated to the wavelet db1 is:
%
%       LS = {...
%             'd'         [    -1]    [0]
%             'p'         [0.5000]    [0]
%             [1.4142]    [0.7071]     []
%            }
%
%   See also DISPLS, LP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Jun-2003.
%   Last Revision: 11-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

help(mfilename)