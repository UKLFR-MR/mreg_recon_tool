function OUT = waveletfamiliesX(ARG)
%WAVELETFAMILIES Wavelet families and family members.
%   WAVELETFAMILIES or WAVELETFAMILIES('f') displays the 
%   names of all available wavelet families.
%
%   WAVELETFAMILIES('n') displays the names of all available
%   wavelets in each family.
%
%   WAVELETFAMILIES('a') displays all available wavelet 
%   families with their corresponding properties.
%
%   See also WAVEMNGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Aug-2007.
%   Last Revision: 08-Feb-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

if nargin<1 , ARG = 'fam'; end
switch lower(ARG(1))
    case 'f' , S = wavemngrX('read');
    case 'n' , S = wavemngrX('read','all');
    case 'a' , 
        S = wavemngrX('read_asc');
        S(abs(S)==13) = [];
end
clc; disp(S); disp(' ');
if nargout>0 , OUT = S; end
