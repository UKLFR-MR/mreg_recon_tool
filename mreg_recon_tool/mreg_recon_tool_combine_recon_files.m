function [recon, timeframes, I] = mreg_recon_tool_combine_recon_files(path)

% function [recon, timeframes, I] = mreg_recon_tool_combine_recon_files(path)
%
% Loads reconstruction files and combines them to one array.
%
% output:
% recon = 3d or 4d array containing the combined timeframes. If a timeframe
%         could not be loaded, the corresponding bin is in recon is filled with zeros
% timeframes = the timeframes that correspond to the last dimension of recon
% I = logical 1d-array that indicates which of the timeframes could be loaded
% 
% Thimo Hugger
% 23.09.2011

recon = [];

if nargin==0
    path = pwd;
end

cdir = pwd;
cd(path);


L = load('recon_details.mat');
recon_details = L.recon_details;
timeframes = recon_details.timeframes;
I = false(1,length(recon_details.timeframes));

if length(recon_details.recon_resolution)==2
    flag = '2d';
elseif length(recon_details.recon_resolution)==3
    flag = '3d';
end
    
[status,D] = unix('ls -d */ | sed ''s/\(.*\)./\1/'''); % list all directories
D = textscan(D,'%s');
D = D{1};
if status~=0
    error('No reconstruction subfolders found.');
end

recon = zeros([recon_details.recon_resolution,length(recon_details.timeframes)]);
for k=1:length(D)
    cd(D{k});
    L = flist('recon*.mat');
    for n=1:length(L)
        ct = strrep(L{n},'recon_','');
        ct = strrep(ct,['.mat'],'');
        ct = str2num(ct);
        cidx = find(recon_details.timeframes==ct);
        I(cidx) = true;
        if strcmp(flag,'2d');
            recon(:,:,cidx) = load_data(L{n});
        else
            recon(:,:,:,cidx) = load_data(L{n});
        end
        
    end
    cd('..');
end

if sum(I) ~= length(recon_details.timeframes)
    warning('Not all frames are reconstructed yet (or have an error). Those frames are filled with zeros.');
end
if sum(I) ~= recon_details.Nt
    warning(['You chose not to reconstruct all timeframes. The output array concists of the frames ', recon_details.timeframes_string, ' without any zerofilling in between.']);
end

cd(cdir);

end

function data = load_data(path,k)

if nargin<=1
    L = load(path, '-mat'); % path is actually a filename here
else
    L = load([path,'/recon_job',num2str(k),'.mat'], '-mat');
end

L_field = fieldnames(L);
data = L.(L_field{1});

end
