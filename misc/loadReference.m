function [out] = loadReference(filename)

% function [reference, header] = loadReference(filename)
%
% This code is designed for the siemens vb15/vb17/vd13 a_gre sequence in 2d
% multi-slice and true 3D mode (two phase encode directions). Other
% sequences might have a different data structure.
%
% Benjamin Zahneisen, Thimo Hugger
% 21.09.2011
% Jakob Asslaender 2011-2015
% Bruno Riemenschneider 2016
% be careful!!! twix object is saved to folder twx_obj, and may later be
% retrieved. If at that later point of time, the dataset has moved on the
% hard drive, I am not sure the pointer in twx_obj.image() still points at
% the correct location!
% In doubt, delete the twx_obj from the folder and rerun loadReference.m

if isnumeric(filename)
    mid = filename;
    filename = filenameByMID(mid);
end

[pathname,filename_no_ext,ext] = fileparts(filename);
if isempty(pathname)
    pathname = '.';
end

twx_obj_name = [filename_no_ext, '_twx_obj.mat'];

if ~exist([pathname,'/twx_obj'],'dir')
    mkdir([pathname,'/twx_obj']);
end

if ~exist(fullfile([pathname,'/twx_obj'],twx_obj_name),'file')
    twx = mapVBVD(filename);
    if iscell(twx)
        twx = twx{end};
    end
    save(fullfile([pathname,'/twx_obj'],twx_obj_name),'twx');
else
    load(fullfile([pathname,'/twx_obj'],twx_obj_name));
end

if iscell(twx)
    twx = twx{end};
end

% determine acquisition mode from number of slices
if twx.hdr.Config.SeqDimension == 2
    if twx.hdr.Config.NSlc == 1
        mode = '2d';
    else
        mode = 'multi_slice';
    end
else
    mode = '3d';
end



% load k-space data
try
    ref = squeeze(twx.image());
catch
    twx = mapVBVD(filename);
    if iscell(twx)
        twx = twx{end};
    end
    save(fullfile([pathname,'/twx_obj'],twx_obj_name),'twx');
    ref = squeeze(twx.image());
end

if strcmp(mode,'3d') || strcmp(mode,'2d')
%    ref=permute(ref,[3 1 2 5 4]); % Nx Ny Nz Ncoils Nechos
    ref=permute(ref,[3 1 4 2 5]); % Nx Ny Nz Ncoils Nechos
else
    ref=permute(ref,[3 1 4 2 5]); % Nx Ny Nz Ncoils Nechos
    %reorder interleaved slices
    idx = zeros(1,size(ref,3));
    if mod(size(ref,3),2)==0
        idx(1:2:size(ref,3)) = (size(ref,3)/2+1):size(ref,3);
        idx(2:2:size(ref,3)) = 1:size(ref,3)/2;
    elseif mod(size(ref,3),2)==1
        idx(1:2:end) = [1:ceil(size(ref,3)/2)];
        idx(2:2:end) = [ceil(size(ref,3)/2)+1:size(ref,3)];
    end
    ref = ref(:,:,idx,:,:);
end

% FFTs
%ref = ref(end/4+1:end*3/4,end/4+1:end*3/4,:,:,:);
ref = fff(ref,1);
ref = fff(ref,2);
ref = ref(:,end/4+1:end*3/4,:,:,:);   % geting rid of oversampling

if(strcmp(mode,'3d'))
    ref = fff(ref,3);
end



if isfield(twx.hdr.MeasYaps.sSliceArray.asSlice{1}, 'dInPlaneRot')
    reference.InPlaneRot = twx.hdr.MeasYaps.sSliceArray.asSlice{1}.dInPlaneRot;
else
    reference.InPlaneRot = 0;
end

%%

reference.cmaps = ref;
reference.anatomical = squeeze(sqrt(sum(abs(ref(:,:,:,:,1)).^2, 4)));

reference.mode = mode;
reference.header = twx.hdr;
s = size(reference.cmaps);
reference.dim = s(1:end-2);

[pname, fname, extension] = fileparts(filename);
if isempty(pname) || strcmp(pname, '.')
    reference.reference_filename = fullfile(pwd, [fname, extension]);
else
    reference.reference_filename = fullfile(pname, [fname, extension]);
end
reference.reference_mid = midByFilename(reference.reference_filename);

reference.fov(1) = twx.hdr.Config.ReadFoV;
reference.fov(2) = twx.hdr.Config.PhaseFoV;
reference.fov(3) = twx.hdr.Config.NSlc*twx.hdr.MeasYaps.sSliceArray.asSlice{1}.dThickness;
reference.fov = reference.fov / 1000; % mm to m

if isfield(twx.hdr.MeasYaps.sSliceArray.asSlice{1}.sNormal, 'dCor')
    reference.Cor_angle = twx.hdr.MeasYaps.sSliceArray.asSlice{1}.sNormal.dCor/2/pi*360;
else
    reference.Cor_angle = 0;
end

reference.shift = zeros(1,3);
for j = 1:length(twx.hdr.MeasYaps.sSliceArray.asSlice)
  if isfield(twx.hdr.MeasYaps.sSliceArray.asSlice{1},'sPosition')
    if isfield(twx.hdr.MeasYaps.sSliceArray.asSlice{1}.sPosition, 'dCor')
        reference.shift(1) = reference.shift(1) + twx.hdr.MeasYaps.sSliceArray.asSlice{j}.sPosition.dCor;
    end
    if isfield(twx.hdr.MeasYaps.sSliceArray.asSlice{1}.sPosition, 'dSag')
        reference.shift(2) = reference.shift(2) + twx.hdr.MeasYaps.sSliceArray.asSlice{j}.sPosition.dSag;
    end
    if isfield(twx.hdr.MeasYaps.sSliceArray.asSlice{1}.sPosition, 'dTra')
        reference.shift(3) = reference.shift(3) + twx.hdr.MeasYaps.sSliceArray.asSlice{j}.sPosition.dTra;
    end
  end
end
reference.shift = reference.shift/length(twx.hdr.MeasYaps.sSliceArray.asSlice)/1000;


out.raw = reference;
end
