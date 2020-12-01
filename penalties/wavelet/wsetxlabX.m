function wsetxlabX(axe,strxlab,col,vis)
%WSETXLAB Plot xlabel.
%    WSETXLAB(AXE,STRXLAB,COL,VIS)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 08-Apr-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
% $Revision: 1.1 $

xlab = get(axe,'Xlabel');
if nargin<4 , 
    vis = 'on';
    if nargin<3 , col = get(xlab,'Color'); end
end
set(xlab,...
        'String',xlate(strxlab), ...
        'Visible',vis, ...
        'FontSize',get(axe,'FontSize'),...
        'Color',col ...
        );
