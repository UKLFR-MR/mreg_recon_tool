function S = flist(pattern)

% function S = flist(pattern)
%
% returns file names as cell array that match the specified pattern
% e.g. flist('~/mfiles/*.mat') returns all files with the extension 'mat' in
% the folder '~/mfiles/'

[status,S] = unix(['ls -d ', pattern]);
if status~=0
    S = {};
else
    S = textscan(S,'%s');
    S = S{1};
    S = sort(S);
end
