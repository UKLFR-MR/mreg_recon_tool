function rpath = mreg_recon_tool_sge_init(data,recon_details,frames_per_job)

% function rpath = mreg_recon_tool_sge_init(data,recon_details,frames_per_job)
%
% Submits jobs to the GridEngine.
% 
% arguments:
% data = struct with necessary data
% recon_details = struct recon parameters
% frames_per_job = number of timeframes for each job
%
% Jakob Asslaender
% jakob.asslaender@uniklinik-freiburg.de
% 07.03.2013

% This sets whether the grid engine uses the compiled version. If this
% doesn't work for some reason: set it to zero and you  are back to the old
% version. If you change it: Change it in mreg_recon_tool_resubmit as well!
use_compiled_function = 0;

cdir = pwd;

if nargin<=2 || isempty(frames_per_job)
    frames_per_job = min([20,length(recon_details.timeframes)]);
else
    frames_per_job = min([frames_per_job,length(recon_details.timeframes)]);
end

setenv('PATH',[getenv('PATH') ':/usr/local/sge_amd/bin/lx24-amd64']);
setenv('SGE_ROOT','/usr/local/sge_amd');



if ~exist(recon_details.pname,'dir')
    mkdir(recon_details.pname);
    job_start_number = 0;
else % don't overwrite any jobs that are already in this folder
%     L = flist(fullfile(recon_details.pname,'job_data*.mat'));
%     job_start_number = length(L);
    error('mreg_recon_tool_sge_init:Dir_exists', 'Directory already exists. Please choose another directory');
end

all_tpts = length(recon_details.timeframes);

save([recon_details.pname '/data.mat'], 'data','-v7.3');
save([recon_details.pname, '/recon_details.mat'], 'recon_details','-v7.3');

ge_queue = 'all.q';

if use_compiled_function
    % which sets the correct path; matlabroot sets the path of the runtime
    mcmd = [which('run_mreg_recon_tool_recon.sh'), ' ', matlabroot];
    ustr = ['echo "', mcmd, ' sge %i %s" | qsub -r y -q ', ge_queue, ' -o ', recon_details.pname, ' -wd ', recon_details.pname,' -N recon_%i'];
else
    mcmd = 'matlab -nodisplay -singleCompThread -r';
    ustr = ['echo "', mcmd, ' \\"run(''/home/extern/riemensc/pathdef.m'');addpath(ans);mreg_recon_tool_recon(''sge'',%i,''%s'');\\"" | qsub -r y -q ', ge_queue, ' -o ', recon_details.pname, ' -wd ', recon_details.pname,' -N recon_%i'];
%    ustr = ['echo "', mcmd, ' \\"mreg_recon_tool_recon(''sge'',%i,''%s'');\\"" | qsub -p -10 -r y -q ', ge_queue, ' -o ', recon_details.pname, ' -wd ', recon_details.pname,' -N recon_%i'];
end

job.frames_per_job = frames_per_job;


for k=0:(floor(all_tpts/frames_per_job)-1)
    
    pts = k*frames_per_job+1:(k+1)*frames_per_job;
    job.args = {k+job_start_number};
    job.timeframes = recon_details.timeframes(pts);
    save(fullfile(recon_details.pname, ['/job_data_', num2str(k+job_start_number, '%i')]),'job');
    
    unix(sprintf(ustr,job.args{1},recon_details.pname,job.args{1}));
        
end

if ~(rem(all_tpts/frames_per_job,1)==0)

    pts = (k+1)*frames_per_job+1:length(recon_details.timeframes);
    job.args = {k+1+job_start_number};
    job.timeframes = recon_details.timeframes(pts);
    save(fullfile(recon_details.pname, ['/job_data_', num2str(k+1+job_start_number)]),'job');

    unix(sprintf(ustr,job.args{1},recon_details.pname,job.args{1}));

end

cd(cdir);
