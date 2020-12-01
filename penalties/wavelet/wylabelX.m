function hh = wylabelX(string,varargin)
%WYLABEL Y-axis label.
%   WYLABEL('text') adds text beside the Y-axis on the current axis.
%
%   WYLABEL('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the ylabel.
%
%   H = WYLABEL(...) returns the handle to the text object used
%   as the label.
%
%   See also WXLABEL, WTITLE, XLABEL, YLABEL, ZLABEL, TITLE, TEXT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-97.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $

nbin = nargin;
if nbin>1
    for k=1:2:nbin-1
        p = deblank(lower(varargin{k}));
        if isequal(p,'parent')
            ax = varargin{k+1};
            varargin(k:k+1) = [];
            break
        end
    end
end

if isempty(ax) , ax = gca; end
h = get(ax,'ylabel');

narg = (nargin-1)/2;
if nargin > 1 && (narg-fix(narg)~=0)
  error('Wavelet:FunctionInput:Invalid_ArgNum', ...
      'Invalid number of input arguments.');
end

%Over-ride text objects default font attributes with
%the Axes' default font attributes.
set(h, 'FontAngle',  get(ax, 'FontAngle'), ...
        'FontName',   get(ax, 'FontName'), ...
        'FontSize',   get(ax, 'FontSize'), ...
        'FontWeight', get(ax, 'FontWeight'), ...
        'string',     string, varargin{:});

if nargout > 0
  hh = h;
end

