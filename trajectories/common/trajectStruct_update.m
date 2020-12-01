function trajectStruct=trajectStruct_update(trajectStruct,type,varargin)
%updates trajectStruct 
%type must be one of 'trajectory','direction'

if strcmp(type,'direction')
    if length(varargin) == 1
        trajectStruct.direction     = varargin{1}/norm(varargin{1}); %three element vector pointing in z-direction as default 
    end
    if length(varargin) == 2
        trajectStruct.direction     = varargin{1}/norm(varargin{1}); 
        trajectStruct.angle         = varargin{2};
    end
end

if strcmp(type,'init')
    trajectStruct.K_bound=varargin(1);
end