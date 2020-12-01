function o = wtbo(userdata)
%WTBO Constructor for the class WTBO.
%   OBJ = WTBO returns a WTBO object. Any object in
%   the Wavelet Toolbox is parented by a WTBO object.
%
%   With OBJ = WTBO(USERDATA) you may set an userdata field.
%
% Class WTBO (Parent objects: none)
% Fields:
%   wtboInfo - Object information.
%     (Not used in the current version of the Toolbox).
%   ud       - Userdata field.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 05-Jun-98.
%   Last Revision: 30-Jul-1999.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:56:01 $

o.wtboInfo = 'wtbo';
if nargin>0 , o.ud = userdata; else , o.ud = []; end
o = class(o,'wtbo');