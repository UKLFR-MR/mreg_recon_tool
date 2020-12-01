function rpath = mreg_recon_tool_slurm_init(data,recon_details,frames_per_job)

% function rpath = mreg_recon_tool_slurm_init(data,recon_details,frames_per_job)
% 
% Submits jobs to the Slurm.
% 
% arguments:
% data = struct with necessary data
% recon_details = struct recon parameters
% frames_per_job = number of timeframes for each job
% 
% Jakob Asslaender
% jakob.asslaender@uniklinik-freiburg.de
% 07.03.2013
% Slurm edit: Bruno Riemenschneider
% 05.10.2017

% This sets whether the grid engine uses the compiled version. If this
% doesn't work for some reason: set it to zero and you  are back to the old
% version. If you change it: Change it in mreg_recon_tool_resubmit as well!

cdir = pwd;

if nargin<=2 || isempty(frames_per_job)
    frames_per_job = min([20,length(recon_details.timeframes)]);
else
    frames_per_job = min([frames_per_job,length(recon_details.timeframes)]);
end

if ~exist(recon_details.pname,'dir')
    mkdir(recon_details.pname);
    job_start_number = 0;
else % don't overwrite any jobs that are already in this folder
%     L = flist(fullfile(recon_details.pname,'job_data*.mat'));
%     job_start_number = length(L);
    error('mreg_recon_tool_slurm_init:Dir_exists', 'Directory already exists. Please choose another directory');
end

all_tpts = length(recon_details.timeframes);

save([recon_details.pname '/data.mat'], 'data','-v7.3');
save([recon_details.pname, '/recon_details.mat'], 'recon_details','-v7.3');

mcmd = 'matlab -nodisplay -singleCompThread -r';
%ustr = [mcmd, ' "mreg_recon_tool_recon(''sge'',%i,''%s'');" '];
ustr = [mcmd, ' "run(''/home/extern/riemensc/Documents/MATLAB/pathdef.m'');addpath(ans);mreg_recon_tool_recon(''slurm'',%i,''%s'');" '];

job.frames_per_job = frames_per_job;

for k=0:(floor(all_tpts/frames_per_job))
    
    if k == floor(all_tpts/frames_per_job)
        pts = k*frames_per_job+1:length(recon_details.timeframes);
    else
        pts = k*frames_per_job+1:(k+1)*frames_per_job;
    end

    if ~isempty(pts)
    job.args = {k+job_start_number};
    job.timeframes = recon_details.timeframes(pts);
    save(fullfile(recon_details.pname, ['/job_data_', num2str(k+job_start_number, '%i')]),'job');

    outfname = fullfile(recon_details.pname, ['/job_' num2str(k+job_start_number, '%i') '.out']);
    errfname = fullfile(recon_details.pname, ['/job_' num2str(k+job_start_number, '%i') '.err']);
    fname = fullfile(recon_details.pname, ['/job_' num2str(k+job_start_number, '%i') '.sbatch']);
    fid = fopen(fname,'w');
    %...do the slurmy stuff
    fprintf(fid,'%s\n\n','#!/bin/bash');
    fprintf(fid,'%s\n','#SBATCH --job-name=MREG_reco');
    fprintf(fid,'%s\n',['#SBATCH --output=' outfname]);
    fprintf(fid,'%s\n',['#SBATCH --error=' errfname]);
%    fprintf(fid,'%s\n','#SBATCH --nodes=1');
    fprintf(fid,'%s\n','#SBATCH --partition=engine');
    fprintf(fid,'%s\n','#SBATCH --ntasks=1');
    fprintf(fid,'%s\n','#SBATCH --cpus-per-task=1');
    fprintf(fid,'%s\n','#SBATCH --time=01-00:00:00');
%    fprintf(fid,'%s\n','#SBATCH --mem=100');
%    fprintf(fid,'%s\n','#SBATCH --mail-type=ALL');
%    fprintf(fid,'%s\n','#SBATCH --mail-user=');

    fprintf(fid,'\n%s',sprintf(ustr,job.args{1},recon_details.pname));
    fclose(fid);

%    unix(['chmod 777 ' fname]);
    unix(['sbatch ' fname]);
    end
end

cd(cdir);
