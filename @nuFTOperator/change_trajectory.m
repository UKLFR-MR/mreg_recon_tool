function A = change_trajectory(A, p)

% if isempty(A.nufftStruct.storage) 
%     if n~= 1
%         error('only one trajectory present');
%     end
% else
%     A.nufftStruct.p = A.nufftStruct.storage{n};
%     A.nufftStruct.storage = {};
% end

A.nufftStruct.p = p;

end