function M = horzcat(varargin)
%HORZCAT Horizontal concatenation of Laurent polynomials.
%   M = HORZCAT(P1,P2,...) performs the concatenation 
%   operation M = [P1 , P2 , ...]. M is a Laurent matrix.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Jun-2003.
%   Last Revision: 21-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:54:39 $

M = laurmat(varargin(:)');
