function  varargout = blockdatamngrX(block_OPT,varargin)
%BLOCKDATAMNGR Manage data blocks (Structures and Objects).
%   VARARGOUT = BLOCKDATAMNGR(OPT,VARARGIN)
%   Valid options OPT are 'set' and 'get'.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-May-2006.
%   Last Revision: 26-Sep-2006.
%   Copyright 1995-2006 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

nbIN = length(varargin);
if ishandle(varargin{1})
    fig        = varargin{1};
    block_Name = varargin{2};
    block_DATA = wtbxappdataX('get',fig,block_Name);
    last = 2;
else
    block_DATA = varargin{1};
    last = 1;
end

first = last+1;
switch block_OPT
    case 'get'
        if nbIN<first , varargout{1} = block_DATA; return; end
        [varargout{1:nbIN-last}] = ...
            wgfieldsX(Inf,block_DATA,varargin{first:end});

    case 'set'
        if nbIN>first
            block_DATA = wsfieldsX(block_DATA,varargin{first:end});
        else
            block_DATA = varargin{first};
        end
        varargout{1} = block_DATA;
        if last==2 , wtbxappdataX('set',fig,block_Name,block_DATA); end
end
