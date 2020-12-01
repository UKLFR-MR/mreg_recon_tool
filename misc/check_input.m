function B = check_input(x,varargin)

% function B = check_input(x,varargin)
%
% Checks x against various conditions.
%
% The follwoing conditions are allowed:
% 'scalar'
% 'column_vector', 'colvec'
% 'row_vector', 'rowvec'
% '1d', '1d-array', 'vector'
% '2d', '2d-array'
% '3d', '3d-array'
% 'numeric'
% 'int', 'integer'
% 'string', 'char'
% 'logical', 'boolean', 'bool'
% 'cell'
% 'struct'
%
% These conditions need additional input
% 'size'
% 'length'
% 'lt', 'less_than'
% 'le', 'less_equal'
% 'gt', 'greather_than'
% 'ge', 'greater_equal'
%
%
% Examples:
%   x = ones(2,1);
%   B = check_input(x,'rowvec','int');
% This returns true, since all conditions are met.
%
%   x = {1,2}; % a cell array
%   B = check_input(x,'vector');
% This returns true, since x is a cell array.
%
%   x = {1,2}; % a cell array
%   B = check_input(x,'vector','numeric');
% This returns false, since x is not a numeric array.
%
%   x = rand(100,1);
%   B = check_input(x,'size',[100 1],'length',50);
% The size and length of x is checked here. Returns false
% since the length is equal to 100.
%
% Important note: If you want to make sure that e.g. x is a
% 2d array of numbers, then 'numeric' needs to be checked along
% with '2d', since '2d' alone can also be true for an array of
% chars, cells or structs
%
% Thimo Hugger
% 20.09.2011



B = true;

k = 1;
doloop = true;
while doloop
    switch varargin{k}
        case 'scalar' % please note: this can also be true if x is a single char
            b = isscalar(x);
        case {'vector','1d-array','1d'}
            b = isvector(x);
        case {'column_vector','colvec'}
            b = iscolumn(x);
        case {'row_vector','rowvec'}
            b = isrow(x);
        case {'2d-array','2d'}
            b = false;
            s = size(x);
            if length(s)==2
                if s(1)>=2 && s(2)>=2
                    b = true;
                end
            end
        case {'3d-array','3d'}
            b = false;
            if length(size(x))==3
                b = true;
            end
        case {'string','char'}
            b = isstr(x);
        case 'numeric'
            b = isnumeric(x);
        case {'int','integer'}
            b = false;
            if isnumeric(x)
                b = all(col(floor(x)-x)==0);
            end
        case {'logical','boolean','bool'}
            b = islogical(x);
        case 'struct'
            b = isstruct(x);
        case 'cell'
            b = iscell(x);
        case 'size'
            b = all(size(x)==varargin{k+1});
            k = k + 1;
        case 'length'
            b = false;
            if isvector(x)
                b = (length(x)==varargin{k+1});
            end
            k = k + 1;
        case {'lt','less_than'}
            if ~isnumeric(x)
                error('Input must be a numeric array to check for ''less_than'' condition.');
            end
            b = all(lt(x,varargin{k+1}));
            k = k + 1;
        case {'le','less_equal'}
            if ~isnumeric(x)
                error('Input must be a numeric array to check for ''less_equal'' condition.');
            end
            b = all(le(x,varargin{k+1}));
            k = k + 1;
        case {'gt','greater_than'}
            if ~isnumeric(x)
                error('Input must be a numeric array to check for ''greater_than'' condition.');
            end
            b = all(gt(x,varargin{k+1}));
            k = k + 1;
        case {'ge','greater_equal'}
            if ~isnumeric(x)
                error('Input must be a numeric array to check for ''greater_equal'' condition.');
            end
            b = all(ge(x,varargin{k+1}));
            k = k + 1;
        otherwise
            error(['Unknown option "',varargin{k},'".']);
    end
    
    if b==false % if one of the conditions is violated, then we can exit the while loop
        B = false;
        doloop = false;
    end
    
    k = k + 1;
    
    if k>length(varargin)
        doloop = false;
    end
end
