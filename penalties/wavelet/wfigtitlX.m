function out1 = wfigtitlX(option,fig,in3,in4,in5,in6)
%WFIGTITL Titlebar for Wavelet Toolbox figures.
%   OUT1 = WFIGTITL(OPTION,FIG,IN3,IN4,IN5,IN6)
%
%   OUT1 is the handle of the text containing the
%   the title of the figure which handle is FIG.
%
%   OPTION = 'vis'
%   IN3 = 'on' or 'off'
%
%   OPTION = 'string'
%   IN3 is a string (the title of the figure)
%   IN4 = 'on' or 'off' is optional.
%
%   OPTION = 'set'
%   IN3 is the height of the title (in pixels).
%   IN4 is a string (the title of the figure)
%   IN5 is 'on' or 'off' (visibility value).
%   IN6 is the Background Color of the title.
%
%   OPTION = 'handle'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 30-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Tag property of objects.
%-------------------------
tag_fig_title = 'UIC_Fig_Title';
UIC_style = 'Edit';

out1 = findobj(fig,'Style',UIC_style,'Tag',tag_fig_title);
opt  = option(1:3);

switch opt
  case 'vis'
    if isempty(out1) , return; end
    set(out1,'Visible',in3);

  case 'str'  % string
    if isempty(out1) , return; end
    if nargin==3 , in4 = get(out1,'Visible'); end
    set(out1,'String',in3,'Visible',in4);

  case 'set'
    tmp   = get(0,'defaultUicontrolPosition');
    h_tit = tmp(4);
    uni   = get(fig,'Units');
    pos_f = get(fig,'Position');
    if strcmp(uni,'pixels')
        pos_t = [0,pos_f(4)-h_tit,pos_f(3)*in3,1.1*h_tit];
    elseif strcmp(uni,'normalized')
        h = h_tit/pos_f(4);
        pos_t = [0,1-h,in3,1.1*h];
    end
    if isempty(out1)
        out1 = uicontrol(fig,...
            'Style',UIC_style,     ...
            'Units',uni,           ...
            'Position',pos_t,      ...
            'Backgroundcolor',in6, ...
            'Enable','Inactive',   ...
            'Visible',in5,         ...
            'String',in4,          ...
            'Tag',tag_fig_title    ...
            );
    else
        set(out1,...
            'Units',uni,           ...
            'Position',pos_t,      ...
            'String',in4,          ...
            'Backgroundcolor',in6, ...
            'Visible',in5          ...
            );
    end

  case 'han'

  otherwise
    errargtX(mfilename,'Unknown Option','msg');
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid argument value.');
end

