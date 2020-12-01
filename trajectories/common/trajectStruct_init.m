function trajectStruct = trajectStruct_init(K,G,SYS)

%SYS contains the gradient system specifications

%%%%% init and error check
trajectStruct     = [];

%%%%% create default struct
trajectStruct.K             = [];     % trajectory
%trajectStruct.K_bound       = [];
trajectStruct.G             = [];     % gradient_file
%trajectStruct.G_bound       = [];
trajectStruct.duration      = [];   %supposed to be ms
trajectStruct.rampUp        = 'false';
trajectStruct.rampDown      = 'false';
trajectStruct.direction     = [0 0 1]; %three element vector pointing in z-direction as default 
trajectStruct.angle         = 0;
if nargin < 3
trajectStruct.SYS           = GradSystemStructure([]);
else
trajectStruct.SYS           = SYS;
end

%%%%% End of: create default struct



%%%%% set data specific properties
% if strcmp(typeStr,'image')
%    % default
%    
% elseif strcmp(typeStr,'imageEchos')
%    mrStruct.dim3    = 'echos';
%    
% end
%%%%% End of: set data specific properties



%%%%% checkin data if desired
if ~isempty(K)
   trajectStruct      = check_input(trajectStruct,'trajectory',K,G);
end
%%%%% End of: checkin data if desired



end

function out=check_input(trajectStruct,type,dataK,dataG)
SYS = GradSystemStructure([]);
if strcmp(type,'trajectory')
    if not(length(size(dataK))) == 2
        warning('data is not 2D')
        return 
    end
    %if not(size(dataK) ==size(dataG) - [1 0]);
    %    warning('data is not consistent')
    %    return
    %end
    if size(dataK,2) > 3
        dataK=dataK';
        dataG=dataG';
    end
    %trajectStruct.K_bound = [dataK(1,:) ; dataK(end,:)];
    %trajectStruct.G_bound = [dataG(1,:) ; dataG(end,:)];
    trajectStruct.K=dataK;
    trajectStruct.G=dataG;
    trajectStruct.duration = size(dataG,1)*SYS.GRT_SI;
    
out = trajectStruct;
end
end



% Copyright (c) March 15th, 2010 by University of Freiburg, Dept. of Radiology, Section of Medical Physics
