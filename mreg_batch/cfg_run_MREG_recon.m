function out = cfg_run_MREG_recon(job)

% Reconstructs MREG data.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Jakob Asslaender Oct. 2011 (jakob.asslaender@uniklinik-freiburg.de)

for session = 1:length(job.session)

%% load Data header
[~,data_header] = loadData(job.session(session).data{1},1);

%% load Reference
if strcmp(job.session(session).reference{1}(end-3:end), '.dat')
    reference = loadReference(job.session(session).reference{1});
elseif strcmp(job.session(session).reference{1}(end-3:end), '.mat')
    load(job.session(session).reference{1});
end

%% load Trajectory
if isfield(job.session(session).trajectory, 't_search')
    path = fileparts(job.session(session).data{1});
    t_name = find_trajectory(data_header.trajectory, path);
    trajectory = loadTrajectory(t_name, []);
elseif isfield(job.session(session).trajectory, 't_set')
    trajectory = loadTrajectory(job.session(session).trajectory.t_set, []);
else
    error('cfg_run_MREG_recon:trajectory', 'Not a valid trajectory option');
end


%% recon_details
if job.image_para.timeframes(2) ~= Inf
    recon_details.timeframes = job.image_para.timeframes(1):job.image_para.timeframes(2);
else
    recon_details.timeframes = job.image_para.timeframes(1):data_header.Nt;
end
recon_details.timeframes_string = [num2str(recon_details.timeframes(1)), ':', num2str(recon_details.timeframes(end))];
recon_details.z0 = 0;
recon_details.cg_method = 'fr+pr';

if isfield(job.image_para.image_dim, 'image_dim_traj')
    recon_details.recon_resolution = ceil(trajectory.resolution);
    recon_details.recon_voxel_size = trajectory.fov ./ trajectory.resolution;
    recon_details.trajectory_scaling = [1 1 1];
else
    recon_details.recon_resolution = job.image_para.FOV ./ job.image_para.voxel_size;
    recon_details.recon_voxel_size = job.image_para.voxel_size./1000; % convertion [mm] to [m]
    recon_details.trajectory_scaling = job.image_para.voxel_size./1000./(trajectory.fov ./ trajectory.resolution);
end

recon_details.nInterleaves                 = size(trajectory.trajectory, 1);
recon_details.tolerance                    = job.reco_details.cg_branch.tol;
recon_details.max_iterations               = job.reco_details.cg_branch.max_iter;
recon_details.offresonance_correction_flag = job.reco_details.orc_flag;
recon_details.recon_output_format          = job.save_as;
recon_details.recon_type                   = job.reco_details.recon_type;
recon_details.dwelltime                    = data_header.dwelltime;
recon_details.Nt                           = data_header.Nt;
recon_details.rawdata_filename             = job.session(session).data{1};
recon_details.TR                           = data_header.tr;
recon_details.global_frequency_shift       = job.reco_details.global_or;

if job.reco_details.dork
    recon_details.DORK_frequency           = DORK_frequency(job.session.data{1});
end

% this means it is a spin echo sequence
% ToDo: Once, te[1] is the traj. te for all sequences, this can
% be calculated without D.trajectory and moved to the update f.
if strcmp(data_header.sequence(end-3:end), 'diff')
    if isfield(trajectory, 'TE_s')
        recon_details.DeltaT = - trajectory.TE_s + data_header.trajectIndices(1)*data_header.dwelltime;
    else
        warning('trajectory was not loaded from grad file. Therefore it does not contain TE_s. DeltaT is set to 0. This can corrupt the reconstuction when Total Variation is used in combination with off-resonance correction');
        recon_details.DeltaT = 0;
    end
else
    % This is for the gradient echo sequences
    % Till now te(1) is the time between the pulse and the
    % beginning of the trajectory for all GE-MREG sequences.
    recon_details.DeltaT = data_header.te(1) + data_header.trajectIndices(1)*data_header.dwelltime;
end

recon_details.penalty.lambda               = job.reco_details.regularisation.lambda;
recon_details.penalty.norm                 = job.reco_details.regularisation.norm;
if strcmp(job.reco_details.regularisation.operator, 'id')
    recon_details.penalty.operator(1).handle      = @identityOperator;
    recon_details.penalty.operator(1).args        = {};
elseif strcmp(job.reco_details.regularisation.operator, 'fd')
    recon_details.penalty.operator(1).handle = @finiteDifferenceOperator;
    recon_details.penalty.operator(1).args = {1};
    recon_details.penalty.operator(2).handle = @finiteDifferenceOperator;
    recon_details.penalty.operator(2).args = {2};
    recon_details.penalty.operator(3).handle = @finiteDifferenceOperator;
    recon_details.penalty.operator(3).args = {3};
elseif strcmp(job.reco_details.regularisation.operator, 'wl')
    recon_details.penalty.operator(1).handle = @waveletDecompositionOperator;
    recon_details.penalty.operator(1).args = {D.recon.recon_details.recon_resolution,3,'db2'};
else
    error('cfg_run_MREG_recon:operator', 'other operators not yet implemented');
end

if ~isempty(job.session(session).dir_name)
    recon_details.pname                     = full_filename(job.session(session).save_path{1}, job.session(session).dir_name);
else
    recon_details.pname                     = job.session(session).save_path{1};
end

%% resize Reference
reference = resizeReference(reference, recon_details.recon_resolution .* recon_details.recon_voxel_size, recon_details.recon_resolution, data_header);

%% more recon_details
if size(reference.fov, 2) == 2
    recon_details.nCoils = size(reference.smaps, 3);
elseif size(reference.fov, 2) == 3
    recon_details.nCoils = size(reference.smaps, 4);
else
    error('cfg_run_MREG_recon:dimensions', 'Reference data must be either 2D or 3D');
end


%% recon_data
recon_data.smaps      = reference.smaps;
recon_data.cmaps      = reference.cmaps;
recon_data.wmap       = reference.wmap;
recon_data.trajectory = trajectory;
recon_data.shift      = reference.shift;


%% Reconstruction
if isfield(job.reco_details.sge , 'sge_yes')
    mreg_recon_tool_sge_init(recon_data,recon_details,job.reco_details.sge.sge_yes.sge_fpj)
else
    mreg_recon_tool_recon('local',recon_data,recon_details);
end

end

out = 1;

end