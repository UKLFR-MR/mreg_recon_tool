function [Hs,Gs,Ha,Ga,PRCond,AACond] = wave2lpX(wname,PmaxHS,AddPOW)
%WAVE2LP Laurent polynomials associated to a wavelet.
%   [Hs,Gs,Ha,Ga] = WAVE2LP(W) returns the four Laurent polynomials
%   associated to the wavelet which name is W (see LIFTWAVE). 
%   The pairs (Hs,Gs) and (Ha,Ga) are the synthesis and the analysis
%   pair respectively.
%   The H-polynomials (G-polynomials) are "low pass" ("high pass")
%   polynomials. 
%   For an orthogonal wavelet, Hs = Ha and Gs = Ga.
%
%   See also LP.

%   In addition, [...,PRCond,AACond] = WAVE2LP(W) computes the
%   perfect reconstruction (PRCond) and the anti-aliasing (AACond)
%   conditions (see PRAACOND).
%
%   [...] = WAVE2LP(W,PmaxHS) lets specify the maximum power of 
%   Hs. PmaxHS must be an integer. The default value is zero.
%
%   [...] = WAVE2LP(...,AddPOW) lets change the default maximum
%   power of Gs: PmaxGS = PmaxHS + length(Gs) - 2, adding the
%   integer AddPOW. The default value for AddPOW is zero.
%   AddPOW must be an even integer to preserve the perfect 
%   condition reconstruction.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jun-2003.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

switch nargin
    case 0
        error('Wavelet:FunctionInput:NotEnough_ArgNum', ...
            'Not enough input arguments.');        
    case 1 , AddPOW = 0; PmaxHS = 0;
    case 2 , AddPOW = 0;
end

tw = wavetypeX(wname);
if ~isequal(lower(tw),'unknown')
    wn = wname(1:2);
    switch wn
        case {'co','db','sy'} , mode = 'orthfiltX';  % orthogonal wavelet.
        case {'bi','rb'}      , mode = 'biorfiltX';  % biorthogonal wavelet.
        otherwise , mode = 'liftscheme';
    end
else
    mode = 'unknown';
end

switch mode
    case 'liftscheme'  % lazy wavelet and others ...
        LS = liftwaveX(wname);
        [Hs,Gs,Ha,Ga] = ls2lpX(LS);
        
    case 'orthfiltX' ,  % orthogonal wavelet.
        LoR = wfiltersX(wname,'r');
        [Ha,Ga,Hs,Gs] = filters2lpX('orth',LoR,PmaxHS,AddPOW);
        
    case 'biorfiltX'    % biorthogonal wavelet.
        first = wname(1);
        switch first
            case 'b' , [Rf,Df] = biorwavfX(wname);
            case 'r' , [Rf,Df] = rbiowavfX(wname);
        end
        %------------------------------------------------------
        % === Comment if Modification of biorwavfX (July 2003) ===
        if isequal(wname,'bior6.8') || isequal(wname,'rbio6.8')
            Df = -Df;  
        end
        %------------------------------------------------------
        % Special case for bior3.X and rbio3.X.
        if nargin<3 && wname(5)=='3' , AddPOW = 1; end
        %------------------------------------------------------
        LoR = sqrt(2)*Rf;
        LoD = sqrt(2)*Df;
        [Ha,Ga,Hs,Gs] = filters2lpX('bior',LoR,LoD,PmaxHS,AddPOW);
      
    otherwise
        error('Wavelet:FunctionArgVal:Invalid_ArgVal',...
            'Invalid wavelet name: %s.',wname)
end
if nargout>4
    [PRCond,AACond] = praacond(Hs,Gs,Ha,Ga);
end
