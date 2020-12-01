function [t,d] = readtreeX(fig)
%READTREE Read wavelet packet decomposition tree from a figure.
%   T = READTREE(F) reads the wavelet packet
%   decomposition tree from the figure F.
%
%   Example:
%     x   = sin(8*pi*[0:0.005:1]);
%     t   = wpdecX(x,3,'db2');
%     fig = drawtreeX(t);
%     %-------------------------------------
%     % Use the GUI to split or merge Nodes.
%     %-------------------------------------
%     t = readtreeX(fig)
%
%   See also DRAWTREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-97.
%   Last Revision: 13-Sep-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $

wins = wfindobjX('figure');
if ~isempty(find(wins==fig,1))
    func = lower(get(fig,'tag'));
    if isequal(func,'wp1dtoolX') || isequal(func,'wp2dtoolX')
        t = feval(func,'read',fig);
    else
        t = []; d = [];
        msg = sprintf('no tree and data structures in the figure %s', num2str(fig));
        warndlg(msg,'WARNING');
    end
else
    msg = sprintf('invalid number for figure : %s', num2str(fig));
    warndlg(msg,'WARNING');
end
