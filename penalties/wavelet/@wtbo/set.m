function [O,ME] = set(O,varargin)
%SET Set WTBO object field contents.
%   O = SET(O,'FieldName1',FieldValue1,'FieldName2',FieldValue2,...)
%   sets the contents of the specified fields for the WTBO object O.
%   
%   The valid choices for 'FieldName' are:
%     'wtboInfo' : Object information
%     'ud'       : Userdata field
%
%   Caution: Don't use the WTBO SET function!
%
%   See also GET.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Aug-2000.
%   Last Revision: 08-Feb-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:56:01 $

nbin = length(varargin);
for k=1:2:nbin
    try   
        field = varargin{k}; O.(field) = varargin{k+1};
        ME = [];
    catch ME
    end
end
