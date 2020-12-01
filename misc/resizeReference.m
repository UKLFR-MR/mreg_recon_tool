function reference = resizeReference(reference, newFOV, newRes, mreg_header, sensmode)

%% Usage: out = resizeReference(reference, newFOV, newRes, mreg_header, sensmode)
%  Input: reference:   refence structure
%         newFOV:      [x y z]: new FOV in m
%         newRes:      [x y z]: new resolution (matrix size)
%         mreg_header: For reading resolution and FOV autoatically, leave
%                      empty otherwise
%         sensmode:    'adapt' (default), 'sos' etc. (see
%                      coilSensitivities.m)
%
%         If newFOV and/or newRes are empty, they are taken from
%         mreg_header.
%
% Output: out:         reference structure
%
% 2011-2013 Jakob Asslaender
% 2015-2016 Bruno Riemenschneider, fixes and changes



if nargin < 5
    sensmode = 'adapt';
end
if nargin < 4  || isempty(mreg_header)
    mreg_header.shift = zeros(1, 3);
    mreg_header.Cor_angle = 0;
    mreg_header.fov = [.192 .192 .192];
    mreg_header.resolution = 64;
end
if isempty(newFOV)
    newFOV = mreg_header.fov;
end
if isempty(newRes)
    newRes = repmat(mreg_header.resolution(1), [1 3]);
end


% basically replacing old adj. ref. and replacing it with raw one, to be
% ajusted
reference.raw.raw = reference.raw;
reference = reference.raw;

% first compute the fov_ratio to crop or enlarge the smaps and cmaps to fit the desired FOV
fov_ratio      = newFOV ./ reference.fov;
voxel_size_old = reference.fov ./ [size(reference.cmaps, 1) size(reference.cmaps, 2) size(reference.cmaps,3)];
voxel_size_new = newFOV ./ newRes;

if length(newRes) == 2
    fov_ratio = [fov_ratio 1];
    newRes =  [newRes size(reference.cmaps, 3)];
end


%% adjust for inplane roation (e.g. change of PE direction) !!! not all cases in there, better not rotate

if abs(reference.InPlaneRot) < 1e-5  % PE = A >> P
    reference.InPlaneRot_now = reference.InPlaneRot;    
elseif (abs(reference.InPlaneRot - pi/2) < 1e-5 || ...
        abs(reference.InPlaneRot - mreg_header.InPlaneRot - pi/2) < 1e-5) % PE = L >> R until VD11
    reference.cmaps = permute(reference.cmaps, [2 1 3 4 5]);
    reference.cmaps = flipdim(reference.cmaps, 2);
    reference.InPlaneRot_now = reference.InPlaneRot - pi/2;
elseif (abs(reference.InPlaneRot + pi/2) < 1e-5 || ...
        abs(reference.InPlaneRot -mreg_header.InPlaneRot + pi/2) < 1e-5)  % PE = L >> R @ VD13
    reference.cmaps = permute(reference.cmaps, [2 1 3 4 5]);
    reference.cmaps = flipdim(reference.cmaps, 1);
    reference.InPlaneRot_now = reference.InPlaneRot + pi/2;
else
    error('Only relative rotations of 0 and plus/minus pi/2 are implemented so far.');
end

%% Shift

%shift = -(mreg_header.shift - reference.shift) ./ voxel_size_old; % in scanner coordinates in pixel
shift = -(mreg_header.shift - reference.shift) ./ voxel_size_old + [0 1 0]; % in scanner coordinates in pixel


% conversion to reference coordinates
R = [cosd(reference.Cor_angle), -sind(reference.Cor_angle); sind(reference.Cor_angle), cosd(reference.Cor_angle)];
shift(1:2:3) = R * shift(1:2:3).';


if sum(abs(shift)) > 1e-3 % to save some time
    %     reference.cmaps = circshift(reference.cmaps, shift);
    reference.cmaps = imshift(reference.cmaps, shift);
end

%% Rotate
alpha = mreg_header.Cor_angle - reference.Cor_angle;
if alpha ~= 0  % to save some time
    reference.cmaps = cat(1, reference.cmaps(end/2+1:end,:,:,:,:), reference.cmaps, reference.cmaps(1:end/2,:,:,:,:));
    reference.cmaps = cat(3, reference.cmaps(:,:,end/2+1:end,:,:), reference.cmaps, reference.cmaps(:,:,1:end/2,:,:));
    fov_ratio(1) = fov_ratio(1)/2;
    fov_ratio(3) = fov_ratio(3)/2;
    
    reference.cmaps = imrotate3D(reference.cmaps, - alpha, 'xaxis', 'bicubic', 'crop');
end

%% Resize
reference.cmaps = imresize3D(reference.cmaps, newRes, fov_ratio, 'linear');


%% Smaps

% calculate sos and mask
reference.anatomical = sqrt(sum(abs(reference.cmaps(:,:,:,:,1)).^2,4));
reference.mask      = reference.anatomical > 0.05*max(reference.anatomical(:));

% calculate coil sensitivites using adapt3D
reference.smaps = coilSensitivities(reference.cmaps(:,:,:,:,1),sensmode);
%reference.SENSEreco = squeeze(sum(reference.cmaps.*repmat(conj(reference.smaps),[1 1 1 1 size(reference.cmaps,5)]),4));

%% w-map
% calculate sos and mask and phase difference map from big Reference image


% Get delta_te from Siemens header
te = cell2mat(reference.raw.header.MeasYaps.alTE);
te = te(1:size(reference.cmaps,5))/1e6;
reference.te = te;

%delta_te = (reference.raw.header.MeasYaps.alTE{2}-reference.raw.header.MeasYaps.alTE{1})/1e6; %[s]
delta_te = (te(2)-te(1)); %[s]

pmaps = phasemaps(reference.cmaps);

try
    reference.wmap = fieldmap(angle(pmaps(:,:,:,2)./pmaps(:,:,:,1)),reference.mask,reference.anatomical,delta_te);
    
    if strcmp(reference.mode,'3d') || strcmp(reference.mode,'multi_slice') % 3D
        reference.wmap = mri_field_map_reg3D(pmaps,te,'l2b',-1,'winit',reference.wmap,'mask',reference.mask);
    else                                                                   % 2D
        reference.wmap = mri_field_map_reg(squeeze(pmaps),[reference.raw.header.MeasYaps.alTE{1}, reference.raw.header.MeasYaps.alTE{2}]/1e6,'l2b',-1,'winit',reference.wmap,'mask',reference.mask);
    end
catch
    warning('Wasn''t able to calculate start value for fieldmap. Maybe FSL Toolbox is not installed or the path is not set correctly. Fessler toolbox is started without a startvalue. Unwrapping of the fieldmap might be inaccurate.')
    
    if strcmp(reference.mode,'3d') || strcmp(reference.mode,'multi_slice') % 3D
        reference.wmap = mri_field_map_reg3D(pmaps,[reference.raw.header.MeasYaps.alTE{1}, reference.raw.header.MeasYaps.alTE{2}]/1e6,'l2b',-1,'mask',reference.mask);
    else                                                                   % 2D
        reference.wmap = mri_field_map_reg(squeeze(pmaps),[reference.raw.header.MeasYaps.alTE{1}, reference.raw.header.MeasYaps.alTE{2}]/1e6,'l2b',-1,'mask',reference.mask);
    end
end

reference.wmap = smooth3(reference.wmap, 'gaussian', 5, 0.8);


%% return output as a structure
s = size(reference.smaps);
reference.dim = s(1:end-1);
reference.sensmode = sensmode;
reference.shift = mreg_header.shift ./ voxel_size_new;   % in voxel
reference.Cor_angle = mreg_header.Cor_angle;


end