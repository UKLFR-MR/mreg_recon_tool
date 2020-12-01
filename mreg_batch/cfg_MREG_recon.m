function MREG_recon = cfg_MREG_recon

% Batch interface to reconstruct MREG data. Calls cfg_run_MREG_recon
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Jakob Asslaender Oct. 2011 (jakob.asslaender@uniklinik-freiburg.de)



%% Session
data         = cfg_files;
data.name    = 'MREG raw data';
data.tag     = 'data';
data.help    = {'Raw data (''.dat'') of the MREG scan. You can get them from the siemens scanner using twix.'};
data.filter  = 'any';
data.ufilter = '.dat';
data.num     = [1 1];

reference         = cfg_files;
reference.name    = 'reference image';
reference.tag     = 'reference';
reference.help    = {'Reference image either as raw data (''.dat''), or already read by the recon tool and saved as ''.mat''. To see ''.mat'' files click ''Filt''.'};
reference.filter  = 'any';
reference.ufilter = '.dat';
reference.num     = [1 1];

t_search      = cfg_const;
t_search.name = 'search for ''.grad'' file';
t_search.tag  = 't_search';
t_search.help = {'Takes the trajectory name out of the raw data header and looks the trajectory up. It first searches in directory of the raw data. If not found there it is searched in the ''matlab_new/fmri/mreg/grad_files/'' folder, where all common ''.grad'' files should be stored.'};
t_search.val  = {0};

t_set         = cfg_files;
t_set.name    = 'trajectory file';
t_set.tag     = 't_set';
t_set.filter  = 'any';
t_set.ufilter = '.grad';
t_set.help    = {'Input either a .mat (saved) file, a .grad (origninal file from the scanner) file or three .dat files (measured trajectory). If .dat files are used make sure that the number of Interleaves is set correctly. The filter here is set to ''.mat''. Click filter to see all types.'};
t_set.num     = [1 3];

trajectory        = cfg_choice;
trajectory.name   = 'trajectory';
trajectory.tag    = 'trajectory';
trajectory.help   = {'You can either read it from the trajectory file, if the values in there make any sense. Otherwise you set it manually. If you need to do so, load the trajectory with loadTrajectory, plot it and pick the non-zero part in of the trajectory. You can load the trajctory in the mreg_recon_tool, select the range and save the trajectory.'};
trajectory.values = {t_search, t_set};
trajectory.val    = {t_search};

save_path         = cfg_files;
save_path.name    = 'parent directory';
save_path.tag     = 'save_path';
save_path.filter  = 'dir';
save_path.ufilter = '.*';
save_path.num     = [1 1];
save_path.help    = {'Parent folder to save data at. Data will be saved one frame/file. The folder system will be ''parent direcotry/subdirectory/0001-0200'', where the subsubdirectories will merge 200 frames per forlder.'};
save_path.val     = {cellstr(pwd)};

dir_name         = cfg_entry;
dir_name.tag     = 'dir_name';
dir_name.name    = 'subdirectory name';
dir_name.help    = {'Name for the subdirectory, where all data is saved.'};
dir_name.strtype = 's';
dir_name.val     = {['Reconstructions_',datestr(now,'yyyy.mm.dd-HH-MM-SS')]};

session         = cfg_branch;
session.tag     = 'session';
session.name    = 'session';
session.help    = {'For each subject you need a referce scan, the MREG data and the trajectory you used.'};
session.val     = {data, reference, trajectory, save_path, dir_name};

session_rep         = cfg_repeat;
session_rep.tag     = 'session_rep';
session_rep.name    = 'sessions';
session_rep.help    = {'Add new sessions for this subject.'};
session_rep.values  = {session};
session_rep.num     = [1 Inf];

%% Save details
save_as        = cfg_menu;
save_as.name   = 'save results as';
save_as.tag    = 'save_as';
save_as.help   = {'You can save the reconstructed images either as niftis or as ''.mat'' files. In niftis only the absolute value of the reconstructions is saved! Choose ''not'' if you just want check the data. In this case you won''t have access to the data except the plot done during the reconstruction.'};
save_as.labels = {'don''t save', 'nifti', 'mat'};
save_as.values = {'not', 'nifti', 'mat'};
save_as.val    = {'nifti'};

%% Trajectory details
t_range_traj      = cfg_const;
t_range_traj.name = 'read trajectory range from gradient file';
t_range_traj.tag  = 't_range_traj';
t_range_traj.help = {'Make sure that it is written in there. (Does not work for old ''.grad'' files.'};
t_range_traj.val  = {0};

t_range_change         = cfg_entry;
t_range_change.name    = 'set range manually';
t_range_change.tag     = 't_range_change';
t_range_change.help    = {'Here you can set the range of the trajectory manually. It is in units of the dwell time.'};
t_range_change.strtype = 'n';
t_range_change.num     = [1 2];
t_range_change.val     = {[1 Inf]};

t_range        = cfg_choice;
t_range.name   = 'range of trajectory';
t_range.tag    = 't_range';
t_range.help   = {'You can either read it from the trajectory file, if the values in there make any sense. Otherwise you set it manually. If you need to do so, load the trajectory with loadTrajectory, plot it and pick the non-zero part in of the trajectory. You can load the trajctory in the mreg_recon_tool, select the range and save the trajectory.'};
t_range.values = {t_range_traj, t_range_change};
t_range.val    = {t_range_traj};


%% Image parameters
timeframes         = cfg_entry;
timeframes.name    = 'timeframes';
timeframes.tag     = 'timeframes';
timeframes.strtype = 'n';
timeframes.num     = [1 2];
timeframes.val     = {[1 Inf]};
timeframes.help    = {'Timeframes that you want to reconstruct. If you want to reconstruct all set it to [1 Inf].'};

image_dim_traj      = cfg_const;
image_dim_traj.name = 'read FOV and voxel size from trajectory file';
image_dim_traj.tag  = 'image_dim_traj';
image_dim_traj.val  = {0};

FOV_change         = cfg_entry;
FOV_change.name    = 'set FOV manually';
FOV_change.tag     = 'FOV_change';
FOV_change.strtype = 'r';
FOV_change.num     = [1 3];
FOV_change.val     = {[192 192 192]};
FOV_change.help    = {'FOV in [x y z] direction in [mm]'};

voxel_size_change         = cfg_entry;
voxel_size_change.name    = 'set voxel size manually';
voxel_size_change.tag     = 'voxel_size_change';
voxel_size_change.strtype = 'r';
voxel_size_change.num     = [1 3];
voxel_size_change.val     = {[3.0 3.0 3.0]};
voxel_size_change.help    = {'Voxel size in [x y z] direction in [mm]'};

image_dim_change     = cfg_branch;
image_dim_change.name = 'set FOV and voxel size manually';
image_dim_change.tag  = 'image_dim_change';
image_dim_change.val  = {FOV_change, voxel_size_change};

image_dim        = cfg_choice;
image_dim.name   = 'FOV and voxel size';
image_dim.tag    = 'image_dim';
image_dim.help   = {'You can either read FOV and voxel size from the trajectory file or set it manually. Note that currently only isotropic values can be stored in ''.grad'' files.'};
image_dim.values = {image_dim_traj, image_dim_change};
image_dim.val    = {image_dim_traj};


image_para      = cfg_branch;
image_para.name = 'image parameters';
image_para.tag  = 'image_para';
image_para.val  = {timeframes, image_dim};


%% Reconstruction Details

% Grid engine
sge_no        = cfg_const;
sge_no.name   = 'no';
sge_no.tag    = 'sge_no';
sge_no.help   = {'no'};
sge_no.val    = {0};

sge_fpj         = cfg_entry;
sge_fpj.name    = 'frames per job';
sge_fpj.tag     = 'sge_fpj';
sge_fpj.help    = {'Number of frames that are reconstructed by each job.'};
sge_fpj.strtype = 'n';
sge_fpj.num     = [1 1];
sge_fpj.val     = {20};

sge_yes      = cfg_branch;
sge_yes.name = 'yes';
sge_yes.tag  = 'sge_yes';
sge_yes.val  = {sge_fpj};

sge        = cfg_choice;
sge.name   = 'use grid engine';
sge.tag    = 'sge';
sge.help   = {'Grid engine distributes reconstruction jobs over a cluster. Works only if you have got a grid engine running on your cluster - and the que in mreg_recon_tool_sge_init is set correctly.'};
sge.values = {sge_no, sge_yes};
sge.val    = {sge_no};


% Conjugate gradient
max_iter         = cfg_entry;
max_iter.name    = 'maximum number of iterations';
max_iter.tag     = 'max_iter';
max_iter.help    = {'The inverse reconstruction problem is solved by the iterative conjugate gradient methode. Maximum number of iterations is set here.'};
max_iter.strtype = 'n';
max_iter.num     = [1 1];
max_iter.val     = {40};

tol         = cfg_entry;
tol.name    = 'abortion tolerance of relative residuum';
tol.tag     = 'tol';
tol.help    = {'The inverse reconstruction problem is solved by the iterative conjugate gradient methode. Relative (to the size of the signal vector) residuum that leads to a abortion is set here.'};
tol.strtype = 'r';
tol.num     = [1 1];
tol.val     = {1e-5};

cg_branch      = cfg_branch;
cg_branch.name = 'Conjugate gradient settings';
cg_branch.tag  = 'cg_branch';
cg_branch.help = {'The inverse reconstruction problem is solved by the iterative conjugate gradient methode. You can set the maximum number of iterations and the residuum at which to stop here. What ever is reached first leads to a abortion.'};
cg_branch.val  = {max_iter, tol};

% Offresonance correction
orc_flag        = cfg_menu;
orc_flag.name   = 'Offresonance correction';
orc_flag.tag    = 'orc_flag';
orc_flag.help   = {'Correction corrects for destortions and blurring due to offresonance. Signal dropouts from itra voxel dephasing cannot be corrected completly so far. Takes approx. 10 times as long to reconstruct.'};
orc_flag.labels = {'Yes', 'No'};
orc_flag.values = {1, 0};
orc_flag.val    = {0};

% Use z0 - TO BE IMPLEMENTED

% Recon Type
recon_type        = cfg_menu;
recon_type.name   = 'reconstruction type';
recon_type.tag    = 'recon_type';
recon_type.labels = {'standard', 'sliding window', 'KWIC'};
recon_type.values = {'standard', 'sliding window', 'KWIC'};
recon_type.help   = {'Can be used for multishot MREG. For singleshot MREG always use ''standard''.'};
recon_type.val    = {'standard'};

% Offresonance correction
dork        = cfg_menu;
dork.name   = 'DORK';
dork.tag    = 'dork';
dork.help   = {'Corrects for global frequency drifts due to scanner instabilities, respiration etc.. Should be used since it is cheap.'};
dork.labels = {'Yes', 'No'};
dork.values = {1, 0};
dork.val    = {1};

% 4D Global OR
global_or         = cfg_entry;
global_or.name    = 'Global off-resonance';
global_or.tag     = 'global_or';
global_or.help    = {'In case the frequency adjustment was not correct, the value can be adjusted here.'};
global_or.strtype = 'r';
global_or.num     = [1 1];
global_or.val     = {0};



% Regularisation
lambda         = cfg_entry;
lambda.name    = 'regularisation parameter (lambda)';
lambda.tag     = 'lambda';
lambda.help    = {'MREG reconstruction is regularized. If lambda is chosen too high it leads to blurring. If the value on the other hand is chosen too small, the reconstruction problem is ill conditioned what leads to spiking and noiselike artefacts. For normed coilmaps (as used here) of a 32 channel head coil 0.2 usually gives the best results.'};
lambda.strtype = 'r';
lambda.num     = [1 1];
lambda.val     = {.2};

norm = cfg_menu;
norm.name   = 'regularisation norm';
norm.tag    = 'norm';
norm.help   = {'MREG reconstruction is regularized. Currenctly two regularisation norms are implemented. l2-norm has the better and faster covergation behavior. On the other hand l1-norm leads to better results. Use the latter one only if you know what you are doing (Or someone else does :) ).'};
norm.labels = {'l2-norm', 'l1-norm'};
norm.values = {@L2Norm, @L1Norm};
norm.val    = {@L2Norm};

operator        = cfg_menu;
operator.name   = 'operator';
operator.tag    = 'operator';
operator.help   = {'Identity operator is the most well behaved. Use the other ones only in special cases or to play around.'};
operator.labels = {'identity operator', 'finite difference operator', 'wavelet operator'};
operator.values = {'id', 'fd', 'wl'};
operator.val    = {'id'};

regularisation  = cfg_branch;
regularisation.name = 'regularisation';
regularisation.tag  = 'regularisation';
regularisation.help = {'Regularisation details are set here. They are all preconfigured.'};
regularisation.val  = {lambda, norm, operator};



reco_details      = cfg_branch;
reco_details.name = 'reconstruction details';
reco_details.tag  = 'reco_details';
reco_details.help = {'Reconstruction details are set here. They are all preconfigured.'};
reco_details.val  = {sge, cg_branch, orc_flag, recon_type, dork, global_or, regularisation};



%% Executable Branch
MREG_recon      = cfg_exbranch;       % This is the branch that has information about how to run this module
MREG_recon.name = 'MREG_recon';             % The display name
MREG_recon.tag  = 'cfg_MREG_recon'; % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
MREG_recon.val  = {session_rep, save_as, t_range, image_para, reco_details};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
MREG_recon.prog = @cfg_run_MREG_recon;  % A function handle that will be called with the harvested job to run the computation
% MREG_recon.vout = @cfg_example_vout_add2; % A function handle that will be called with the harvested job to determine virtual outputs
MREG_recon.help = {'Reconstruction of MREG data. What you really have to set: The reference image that you hopefully acquired when scanning you volunteer. The raw data of your MREG scan and the trajectory you used for the scan.'};


% %% Local Functions
% % The cfg_example_vout_add2 function can go here, it is not useful outside
% % the batch environment.
% function vout = cfg_example_vout_add2(job)
% % Determine what outputs will be present if this job is run. In this case,
% % the structure of the inputs is fixed, and the output is always a single
% % number. Note that input items may not be numbers, they can also be
% % dependencies.
% 
% vout = cfg_dep;                        % The dependency object
% vout.sname      = 'Add2: a + b';       % Displayed dependency name
% vout.src_output = substruct('()',{1}); % The output subscript reference. This could be any reference into the output variable created during computation
