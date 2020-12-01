function varargout = re1dtoolX(option,varargin)
%RE1DTOOL Regression estimation 1-D tool.
%   VARARGOUT = RE1DTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Nov-98.
%   Last Revision: 29-Aug-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
switch option
    case 'create'
        win_tool = wdretoolX('createREG');
        if nargout>0 , varargout{1} =  win_tool; end

    case 'close' , wdretoolX('close');

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid Input Argument.');
end
