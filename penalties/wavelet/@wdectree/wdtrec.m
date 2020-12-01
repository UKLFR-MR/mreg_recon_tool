function x = wdtrec(t,node)
%WDTREC Wavelet decomposition tree reconstruction.
%   X = WDTREC(T) returns the reconstructed vector
%   corresponding to a wavelet tree T.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Mar-2003.
%   Last Revision: 24-Jan-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:55:34 $ 

% Check arguments.
msg = nargoutchk(0,1,nargout);
if ~isempty(msg)
    error('Wavelet:FunctionOutput:Invalid_ArgNum',msg);
end
msg = nargchk(1,2,nargin);
if ~isempty(msg)
    error('Wavelet:FunctionInput:Invalid_ArgNum',msg);
end
if nargin==1, node = 0; end

% Get node coefficients.
[t,x] = nodejoin(t,node); %#ok<ASGLU>
% if ndims(x)>2 && node==0
%     x(x<0) = 0;
%     x = uint8(x);    
% end
