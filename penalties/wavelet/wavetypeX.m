function T = wavetypeX(wname,TYPE)
%WAVETYPE Wavelet type information.
%   T = WAVETYPE(W) returns the type T of the wavelet is W.
%   The valid values for T are:
%       - 'lazy' : for the "lazy" wavelet.
%       - 'orth' : for orthogonal wavelets.
%       - 'bior' : for biorthogonal wavelets.
%       - 'unknown' : for unknown names.
%
%   R = WAVETYPE(W,T) returns 1 if the wavelet W is of 
%   type T and 0 otherwise.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Jun-2003.
%   Last Revision 13-Sep-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $ 

waveCell = wavenamesX('lazy');
if any(strcmpi(wname,waveCell))
    T = 'lazy';
else
    waveCell = wavenamesX('orth');
    if any(strcmpi(wname,waveCell))
        T = 'orth';
    else
        waveCell = wavenamesX('bior');
        if any(strcmpi(wname,waveCell))
            T = 'bior';
        else
            T = 'unknown';
        end
    end
end
if nargin>1
    T  = (lower(TYPE(1)) == T(1));
end