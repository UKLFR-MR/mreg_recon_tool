function t = entrupd(t,ent,in3)
%ENTRUPD Entropy update (wavelet packet tree).
%   T = ENTRUPD(T,ENT) or  T = ENTRUPD(T,ENT,PAR) 
%   updates the entropy of wavelet packet tree T 
%   using the entropy function ENT with optional
%   parameter PAR (see WENTROPY for more information).
%
%   See also WENTROPY, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:55:47 $

if nargin==2 , par = 0; else par = in3; end
if strcmp(lower(ent),'user')
    if ~ischar(par)
        error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
            'Invalid function name for user entropy.');
    end
end

% Keep tree nodes.
nods      = read(t,'an');
ent_nods  = zeros(size(nods));
ento_nods = NaN;
ento_nods = ento_nods(ones(size(nods)));

% Update entropy.
for i = 1:length(nods)
    % read or reconstruct packet coefficients.
    if istnode(t,nods(i))
        coefs = read(t,'data',nods(i));
    else
        coefs = wpcoef(t,nods(i));
    end
    % compute entropy.
    ent_nods(i) = wentropy(coefs,ent,par);
end

% Update data structure.
t = write(t, ...
          'entname',ent,        ...
          'entpar',par,         ...
          'ent',ent_nods,nods,  ...
          'ento',ento_nods,nods ...
          );
