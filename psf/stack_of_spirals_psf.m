%% Create and save trajectories 
%  from Riemenschneider et al. 2021, 1-4 shots:
trajectory_name = {'SoS1_Orig_sr170.grad',...
    'SoS2_48172_sr170.grad',...
    'SoS3_77172_sr170.grad',...
    'SoS4_881616_sr170.grad'};
Rparams = {[3 6 2*150/192 5*150/192],...
    [4 8 1.7 2],...
    [7 7 1.7 2],...
    [8 8 1.6 1.6]};
resolution = 0.003;
traj_fov = [0.192 0.150];

for Nshots = 1:4
    T{Nshots} = stack_of_spirals_mod(Rparams{Nshots},Nshots,traj_fov,resolution,1);
    % Saving and reloading is necessary, as it halves the dwelltime from
    % 10mus in the creation script, i.e., oversamples the output in T with 
    % factor 2 to 5mus
    trajectStruct_export(T{Nshots},trajectory_name{Nshots},1);
end

%% Load trajectories from .grad files

for Nshots = 1:4
    trajectory{Nshots} = loadTrajectory(trajectory_name{Nshots});
end

%% Load reference scan and estimate sensitivities

% First download the phantom reference dataset from zenodo.org as provided in
% the MRM Riemenschneider et al. 2021 paper
% https://zenodo.org/record/4213385#.X6GCuVlOlMA
MID = 586;
reference = loadReference(MID);
fov = reference.raw.fov;
grid_dim = fov./resolution;

% For psf calculation, the simulation resolution should be significantly 
% higher than the reconstruction's. However, computational restrictions apply,
% so if the integer 'upsampling' of the grid (upsampled referring to the 
% reconstruction grid) is too high, go lower. For a rough approximation or 
% prototyping go as low as 1:
upsampling = 5;
dim_upsampled = grid_dim*upsampling;

% These relative position parameters are usually given by the MREG scan:
a.shift = [0 0 0]*resolution;
a.Cor_angle = 0;
a.fov = fov;

% Sensitivity map estimation:
% Use option 'sos' for fast prototyping with sum of squares method,
% instead of 'adapt' for more expensive adaptive recombine. For simulation
% purpose fidelity of the maps is not governing reconstruction quality
% though.
% reference = resizeReference(reference,fov,dim_upsampled,a,'adapt');
reference = resizeReference(reference,fov,dim_upsampled,a,'sos');

%% Create forward operator for signal simulation

% Select trajectory
Nshots = 3;

trajectory_combined{Nshots} = zeros(size(trajectory{Nshots}.idx{1},2)*Nshots,3);
for j = 1:Nshots
    trajectory_combined{Nshots}(j:Nshots:end) = trajectory{Nshots}.trajectory{j}(trajectory{Nshots}.idx{j},:);
end

E = nuFTOperator(trajectory_combined{Nshots}/upsampling,dim_upsampled,reference.smaps);
% Simulated signal of point source:
delta = zeros(dim_upsampled);
delta(dim_upsampled(1)/2,dim_upsampled(2)/2,dim_upsampled(3)/2) = 1;
s = E*delta;


%% Reconstruction of (simulated point/reference) signal

lambda = 0.05;
iterations = 50;

psf{Nshots} = regularizedReconstruction(E,s,'maxit',iterations,@L2Norm,lambda);
psf{Nshots} = psf{Nshots}/max(psf{Nshots}(:));

figure()
imagesc(log10(squeeze(abs(psf{Nshots}(:,dim_upsampled(1)/2,:)))));
caxis([-4 0])
colormap(gca(),'jet')
view(-90,90)

%% Using the same recipe, you can play with simulating/reconstructing image signals
%  e.g., incorporating an off-resonance/B0-inhomogeneity map.
%  For more realistic, but mostly negligible, effects you could also use a
%  higher resolution operator for forward operation than for reconstruction

dwelltime_s = 5e-6;
rf_pulse_to_readout_start_s = 1.5e-3;
segments = 10;
E_offres = orc_segm_nuFTOperator(trajectory_combined{Nshots}/upsampling, ...
    dim_upsampled, reference.smaps, reference.wmap, dwelltime_s/Nshots,...
    segments,rf_pulse_to_readout_start_s);
s_ref = E_offres*reference.anatomical;
lambda = 0.05;
iterations = 50;
rec_sim{Nshots} = regularizedReconstruction(E_offres,s_ref,'maxit',iterations,@L2Norm,lambda);
