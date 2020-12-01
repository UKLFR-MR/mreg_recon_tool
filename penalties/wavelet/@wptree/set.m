function t = set(t,varargin)
%SET Set WPTREE object field contents.
%   T = SET(T,'FieldName1',FieldValue1,'FieldName2',FieldValue2,...)
%   sets the contents of the specified fields for the WPTREE object T.
%   
%   The valid choices for 'FieldName' are:
%     'dtree'   : dtree parent object.
%     'wavInfo' : Structure (wavelet infos)
%        'wavName' - Wavelet Name
%        'Lo_D'    - Low Decomposition filter
%        'Hi_D'    - High Decomposition filter
%        'Lo_R'    - Low Reconstruction filter
%        'Hi_R'    - High Reconstruction filter
%
%     'entInfo' : Structure (entropy infos)
%        'entName' - Entropy Name
%        'entPar'  - Entropy Parameter
%
%   Or fields in DTREE parent object:
%     'ntree' : ntree parent object
%     'allNI' : All nodes Infos
%     'terNI' : Terminal nodes Infos
%
%   Or fields in NTREE parent object:
%     'wtbo'  : wtbo parent object
%     'order' : Order of tree
%     'depth' : Depth of tree
%     'spsch' : Split scheme for nodes
%     'tn'    : Array of terminal nodes of tree
%
%   Or fields in WTBO parent object:
%     'wtboInfo' : Object information
%     'ud'       : Userdata field
%
%   Caution: Use the SET function only for the field 'ud'.
%
%   See also DISP, GET, READ, WRITE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.
%   Last Revision: 15-Mar-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:55:47 $

nbin  = length(varargin);
if rem(nbin,2)
   str1 = 'Invalid Number of arguments!';
   str2 = 'Use property/value pairs.';
   msg = strvcat(str1,str2); %#ok<VCAT>
   errargt(caller,msg,'msg');
   error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
       'Invalid argument value.');
end
nbArg = nbin/2;
okArg = ones(1,nbArg);
for k=1:2:nbin
    field = varargin{k};
    try 
      t.(field) = varargin{k+1};
    catch ME %#ok<NASGU>
      [t.dtree,ME] = set(t.dtree,field,varargin{k+1});
      if ~isempty(ME) && ~isempty(ME.message) , okArg((k+1)/2) = 0; end
    end
end
notOk = find(okArg==0);
if ~isempty(notOk)
    notOkTMP = sort([2*notOk-1,2*notOk]);
    t = setwtbo(t,varargin{notOkTMP});
end
