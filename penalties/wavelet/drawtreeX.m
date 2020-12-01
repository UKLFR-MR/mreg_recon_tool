function fig = drawtreeX(t,varargin)
%DRAWTREE Draw wavelet packet decomposition tree.
%   DRAWTREE(T) draws the wavelet packet tree T.
%   F = DRAWTREE(T) returns the figure's handle.
%
%   For an existing figure F produced by a previous call
%   to the DRAWTREE function, DRAWTREE(T,F) draws the wavelet 
%   packet tree T in the figure whose handle is F.
%
%   Example:
%     x   = sin(8*pi*[0:0.005:1]);
%     t   = wpdecX(x,3,'db2');
%     fig = drawtreeX(t);
%     %---------------------------------------
%     % Use command line function to modify t
%     %---------------------------------------
%     t   = wpjoin(t,2);
%     drawtreeX(t,fig);
%
%   See also READTREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-97.
%   Last Revision: 27-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $

% Check arguments.
%-----------------
nbIn = nargin;
switch nbIn
    case 0
        error('Wavelet:FunctionInput:NotEnough_ArgNum',...
            'Not enough input arguments.');

    case {1,2}
        maxarg = 2;

    otherwise
        error('Wavelet:FunctionInput:TooMany_ArgNum',...
            'Too many input arguments.');
end

% Draw tree.
%-----------
order = treeordX(t);
switch order
    case 2 , prefix = 'wp1d';
    case 4 , prefix = 'wp2d';
end
func1 = [prefix 'tool'];
func2 = [prefix 'mngr'];

newfig = 1;
if nargin==maxarg
    fig = varargin{end};
    varargin(end) = [];
    wins = wfindobjX('figure');
    if ~isempty(find(wins==fig,1))
        tagfig = lower(get(fig,'tag'));
        if isequal(func1,tagfig) , newfig = 0; end
    end
end
if newfig , fig = feval(func1); end
feval(func2,'load_dec',fig,t,varargin{:});
