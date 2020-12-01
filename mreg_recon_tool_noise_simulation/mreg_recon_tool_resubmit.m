function mreg_recon_tool_resubmit(job_numbers)

% function mreg_recon_tool_resubmit(job_numbers)
%
% Resubmits jobs given in the argument "job_numbers" to the GridEngine.
% Must be executed in path of job files. If no "job_numbers" are specified
% then by default all unfinished jobs (with no flag file) are resubmitted.
% Instead 
% 
% arguments:
% job_numbers = the jobs that shall be resubmitted.
%               If the argument is not given or if it is empty, then by default
%               all unfinished jobs are resubmitted.
%               job_numbers can also be the string 'all'. In that case, every
%               job is resubmitted.
%
% Jakob Assländer
% 18.03.2013


% This sets whether the grid engine uses the compiled version. If this
% doesn't work for some reason: set it to zero and you  are back to the old
% version. If you change it: Change it in mreg_recon_tool_sge_init as well!
use_compieled_function = 0;

setenv('PATH',[getenv('PATH') ':/usr/local/sge_amd/bin/lx24-amd64']);
setenv('SGE_ROOT','/usr/local/sge_amd');

ge_queue = 'all.q';

dir = pwd;

load recon_details.mat;
load data.mat;


if use_compieled_function
    % which sets the correct path; matlabroot sets the path of the runtime
    mcmd = [which('run_mreg_recon_tool_recon.sh'), ' ', matlabroot];
    ustr = ['echo "', mcmd, ' sge %i %s" | qsub -r y -q ', ge_queue, ' -o ', recon_details.pname, ' -wd ', recon_details.pname,' -N recon_%i'];
else
    mcmd = 'matlab -nodisplay -singleCompThread -r';
    ustr = ['echo "', mcmd, ' \\"mreg_recon_tool_recon(''sge'',%i,''%s'');\\"" | qsub -r y -q ', ge_queue, ' -o ', recon_details.pname, ' -wd ', recon_details.pname,' -N recon_%i'];
end

% compare available job_data files and flag files and resubmit the nonfinished jobs by default
if nargin==0 || isempty(job_numbers)
    L = flist('job_data_*.mat');
    for k=1:length(L)
        L{k} = strrep(L{k},'job_data_','');
        L{k} = strrep(L{k},'.mat','');
        L{k} = str2num(L{k});
    end
    L = cell2mat(L);
    L = sort(L);
    
    F = flist('recon*.flag');
    for k=1:length(F)
        F{k} = strrep(F{k},'recon_','');
        F{k} = strrep(F{k},'.flag','');
        F{k} = str2num(F{k});
    end
    F = cell2mat(F);
    F = sort(F);
    
    I = zeros(length(F),1);
    for k=1:length(F)
        I(k) = find(L==F(k));
    end
    
    L(I) = [];
    
    for k=1:length(L)
        delete(['recon_',num2str(L(k)),'.o*']);
        delete(['recon_',num2str(L(k)),'.e*']);
    end
    
    job_numbers = L.';
    
else
    if isstr(job_numbers) && strcmp(job_numbers,'all')
        L = flist('job_data_*.mat');
        for k=1:length(L)
            L{k} = strrep(L{k},'job_data_','');
            L{k} = strrep(L{k},'.mat','');
            L{k} = str2num(L{k});
        end
        L = cell2mat(L);
        L = sort(L);
        
        for k=1:length(L)
            delete(['recon_',num2str(L(k)),'.o*']);
            delete(['recon_',num2str(L(k)),'.e*']);
            if exist(['recon_',num2str(L(k)),'.flag'])
                delete(['recon_',num2str(L(k)),'.flag']);
            end
        end
        
        job_numbers = L.';
    else
        job_numbers = col(job_numbers).';
    end
    
end

for k=job_numbers
    
    unix(sprintf(ustr,k,dir,k));
    
end
