function mreg_recon_tool_write_file(how,recon,k,pname,fname,Nt,Nf,voxel_size,shift)

% function mreg_recon_tool_write_nifti(recon,k,pname,fname,Nt,Nf,voxel_size,shift)
%
% Exports recon data as files.
%
% arguments:
% how = 'mat' or 'nifti'
% recon = 3d recon timeframe
% k = number of the timeframe
% pname = folder for saving (one or more additional subfolders will be created in here)
% fname = first part of the filename (a number corresponding to "k" will be appended)
% Nt = total number of time frames
% Nf = range of frames in one subfolder. if Nf=inf all files will be saved in one subfolder
% voxel_size = size of a voxel in m
% shift = usually this is equal to -FOV/2
%
% Thimo Hugger
% 21.09.2011


dim = size(recon);

if nargin<=6 || isempty(Nf)
    Nf = 200; 
end
if nargin<=7 || isempty(voxel_size)
    voxel_size = 1e-3*[1 1 1]; % voxel_size should be given in m
end
if nargin<=8 || isempty(shift)
    fov = dim .* voxel_size;
    shift = -fov/2;
end


Nd = floor(log10(Nt)) + 1;

bin = floor((k-1)/Nf)+1;
if Nf==inf
    bin_start = 1;
    bin_end = Nt;
else
    bin_start = (bin-1)*Nf+1;
    bin_end = bin*Nf;
    if bin_end > Nt
        bin_end = Nt;
    end
end
bin_str = [frame2str(bin_start,Nd),'-',frame2str(bin_end,Nd)];

if ~exist(fullfile(pname,bin_str),'dir')
    mkdir(fullfile(pname,bin_str));
end

switch how
    case 'mat'
        save(fullfile(pname,bin_str,[fname,'_',frame2str(k,Nd),'.mat']), 'recon');
    case 'nifti'
        V.fname = fullfile(pname,bin_str,[fname,'_',frame2str(k,Nd),'.nii']);
        V.mat = diag([1e3*col(voxel_size); 1]); % transformation matrix (rotation, translation) to get from index space into spatial coordinates in mm
        V.mat(:,4) = [1e3*col(shift); 1];
        V.mat = [0 1 0 0; -1 0 0 0; 0 0 1 0; 0 0 0 1]*V.mat;
        V.pinfo = [inf;inf;0];
        V.dim = size(recon);
        V.dt = [spm_type('int16'), spm_platform('bigend')];
        spm_write_vol(V,abs(recon));
end

end


function nstr = frame2str(k,Nd)

tmp = num2str(k);
nstr = repmat('0',[1 Nd]);
nstr([Nd-length(tmp)+1:Nd]) = tmp;

end
