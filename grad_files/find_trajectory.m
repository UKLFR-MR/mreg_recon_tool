function fullname = find_trajectory(name, path)

%% usage: fullname = find_trajectory(name)
% takes the name of a trajectory (without path), looks up, if it is in the
% current workin directory (or the path you told it), if not it looks it up in
% matlab_new/fmri/mreg/grad_files and returns the full filename including
% the path.

% Jakob Asslaender Oct. 2011 (jakob.asslaender@uniklinik-freiburg.de)

try
    if nargin < 2 || isempty(path)
        temp = ls(name);
        fullname = fullfile(pwd, name);
    else
        temp = ls(fullfile(path, name));
        fullname = fullfile(path, name);
    end
catch
    path = which('find_trajectory');
    [path, ~, ~] = fileparts(path);
    fullname = fullfile(path, name);
end

try
    temp = ls(fullname);
catch
    error('find_trajectory:file', ['File ''', name, ''' does neither exist in the current working directory (', pwd, '), nor in the grad_files directory (', path, ').']);
end