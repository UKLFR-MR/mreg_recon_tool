function [trajectory, status] = loadTrajectory(filename, pname, delay)

%% usage: function [trajectory, status] = loadTrajectory(fname, pname)

% in:
% filename: Cell with name(s) of the file(s)
%           Three extensions are valid:
%           '.mat':  One file with a saved trajectory as a trajectory struct (see
%                    trajectStruct_init).
%           '.grad': One gradfile as used on the scanner
%           '.dat':  Two (2D) or three (3D) raw datafiles from a Siemens scanner
%                    (use twix)
% delay: array [dx dy dz] with gradient delay to be corrected in µs
% (gradient raster time/10)
% pname: name of path (can be left empty if you are either in that path or
%        the path is already part of the name.
%
% out:
% trajectory: Trajectory struct (see trajectStruct_init).
% status:     Used by the mreg_recon_tool.

if nargin < 3
    delay = [0 0 0];
end

if nargin == 0 || isempty(filename)
    if nargin < 3 || isempty(pname)
        [filename, pname] = uigetfile({'*.dat;*.mat;*.grad','Data, grad and mat files (*.dat,*.grad,*.mat)';'*.dat','Data files (*.dat)';'*.mat','mat files (*.mat)'},'MultiSelect','on');
    else
        [filename, pname] = uigetfile({'*.dat;*.mat;*.grad','Data, grad and mat files (*.dat,*.grad,*.mat)';'*.dat','Data files (*.dat)';'*.mat','mat files (*.mat)'},[],pname,'MultiSelect','on');
    end
    if isnumeric(filename)
        trajectory = [];
        status = 'Loading canceled.';
        return;
    end
    if ~iscell(filename)
        filename = {filename};
    end
    [~,~,ext] = fileparts(filename{1});
    fullfilename = cell(1,length(filename));
    for k=1:length(filename)
        fullfilename{k} = fullfile(pname, filename{k});
    end
else
    if ~iscell(filename)
        filename = {filename};
    end
    fullfilename = cell(1,length(filename));
    if nargin < 3 || isempty(pname) || strcmp(pname, '.')
        for k=1:length(filename)
            [pname,filename{k},ext] = fileparts(filename{k});
            if strcmp(pname, '')
                pname = pwd;
            end
            fullfilename{k} = fullfile(pname, [filename{k}, ext]);
        end
    else
        for k=1:length(filename)
            [~,filename{k},ext] = fileparts(filename{k});
            fullfilename{k} = fullfile(pname, [filename{k}, ext]);
        end
    end
end

switch ext
    case '.mat'
        trajectory = mat2variable(fullfilename{1}, 'trajectory');
        if ~iscell(trajectory.trajectory)
            trajectory.trajectory = {trajectory.trajectory};
        end
        if ~iscell(trajectory.idx)
            trajectory.idx = {trajectory.idx};
        end
        
    case '.grad'
        trajectory = loadTrajectory_Grad(fullfilename{1},delay);
        
    case '.dat'
        
        if length(fullfilename)==2 || length(fullfilename)==3
            trajectory = loadTrajectory_Dat(fullfilename);
        else
            if nargout < 2
                status = 'Selected files don''t comprise a trajectory.';
            else
                error('loadTrajectory:wrong_size', 'Selected files don''t comprise a trajectory.');
            end
            trajectory =[];
            return;
        end
        
    otherwise
        status = 'Unknown file extension.';
        trajectory =[];
        return;
end

status = 'Trajectory loaded.';

end


function [trajectory headerOut] = loadTrajectory_Dat(filename,nInterleaves,fov,N)

% function [trajectory headerOut] = loadTrajectory(filename,nInterleaves,fov,N)
%
% in:
% filename     = cell array containing raw data filenames or an array containing
%                the mids of the filenames
% nInterleaves = number of views/interleaves (leave it empty, it will be
%                taken from the header.
% fov          = field of view in meters
% N            = resolution

% out:
% trajectory   = trajectory struct
% headerOut    = header of the first input file


if isnumeric(filename)
    mids = filename;
    filename = cell(1,length(mids));
    for k=1:length(mids)
        filename{k} = filenameByMID(mids(k));
    end
end

dim = length(filename); % 2d or 3d

%read all headers and reorder input array of filenames
for k=dim:-1:1
    header(k) = readHeader(filename{k});
end

%% Checking data consistency
right = 1;
s = 0; p = 0; r = 0;
for k=1:dim
    if ~strcmp(header(1).trajectory, header(k).trajectory)
        right = 0;
    end
    if strcmp(header(k).exc_axis,'phase')
        p = 1;
    elseif strcmp(header(k).exc_axis,'read')
        r = 1;
    elseif strcmp(header(k).exc_axis,'slice')
        s = 1;
    end
end
if s == 2 || p == 2 || r == 2
    right = 0;
end
if right == 0
    error('loadTrajectory_Dat:input', 'Data does not compromise a trajecotry');
end

%%
headerOut = header(1);
headerOut.exc_axis='';

new_fileorder = cell(1,dim);
for n=1:dim
    if strcmp(header(n).exc_axis,'phase')
        new_fileorder{1}=filename{n};
    elseif strcmp(header(n).exc_axis,'read')
        new_fileorder{2}=filename{n};
    elseif strcmp(header(n).exc_axis,'slice')
        new_fileorder{3}=filename{n};
    end
end
filename = new_fileorder;

if nargin <= 1 || isempty(nInterleaves)
    nInterleaves = header(1).trajectorySegments;
end

if nargin <= 2 || isempty(fov)
    fov = header(1).fov(1);
end

if nargin<=3 || isempty(N)
    N = header(1).resolution(1);
end


%% alternating trajectory and phase reference measurement
PHASE = cell(1,dim);
for n=1:dim
    data = loadRawData(filename{n},1);
    Nc = size(data,5);
    if Nc==1
        one_coil_flag = 1;
    else
        one_coil_flag = 0;
    end
    data = permute(data,[1 7 10 2 9 5 3 4 6 8]);
    data = reshape(data,[size(data,1)*size(data,2)*size(data,3) size(data,4)*size(data,5) size(data,6)]);
    
    crop = rem(size(data,1),2*nInterleaves);
    if header(1).B0 == 7
        data = data(1:end-crop,65:end,:);
        data(:,:,[1 2 4 5 6 7 8 17])=[];
        Nc = size(data,3);
    else
        data = data(1:end-crop,1:end,:);
    end
    data = unwrap(angle(data),[],2);
    
    pref = col(squeeze(data(:,1,:)));
    pref = repmat(pref,[1 size(data,2)]);
    pref = reshape(pref, [size(data,1) size(data,3) size(data,2)]);
    pref = permute(pref, [1 3 2]);
    data = data - pref;
    
    data = reshape(data, [2 size(data,1)/2, size(data,2) size(data,3)]);
    PHASE{n} = zeros(size(pref,1)/nInterleaves, nInterleaves, size(pref,2), size(pref,3));
    for k=1:nInterleaves
        PHASE{n}(:,k,:,:) = reshape(data(:,k:nInterleaves:end,:,:),[size(data,1)*size(data,2)/nInterleaves size(data,3) size(data,4)]);
    end
    
end

filt = cell(1,dim);
for n=1:dim
    filt{n} = cutoffFilter(PHASE{n}(2,:,:,:), 1, 0, 1/50, 'bandstop', 3, 1);
end

K = cell(1,nInterleaves);
for n=1:nInterleaves
    std_filt = cell(1,dim);
    for k=1:dim
        std_filt{k} = std(squeeze(filt{k}(1,n,100:end-100,:)));
    end
    
    idx = cell(1,dim);
    if one_coil_flag==0
        for k=1:dim
            [~, idx{k}]=sort(std_filt{k});
        end
        I = [1:min([Nc 4])];
    else
        for k=1:dim
            idx{k}=1;
        end
        I = 1;
    end
    
    traj = cell(1,dim);
    for k=1:dim
        traj{k} = PHASE{k}(1:2:end,n,:,idx{k}(I)) - PHASE{k}(2:2:end,n,:,idx{k}(I));
        traj{k} = mean(traj{k},1);
        traj{k} = mean(traj{k},4);
        traj{k} = traj{k}(:);
    end
    
    % Trajectory is reoriented according to nuFFT-operator
    if dim==3
        K{n} = [traj{2}, -traj{1}, -traj{3}];
    elseif dim==2
        K{n} = [traj{2}, -traj{1}];
    end
    K{n} = K{n}/(header(1).sPosition(3));
    K{n} = K{n}*fov/N;
end

c = lines(nInterleaves);
figure;
hold on;
for n=1:nInterleaves
    if dim==2
        plot(K{n}(:,1),K{n}(:,2),'-','Color',c(n,:))
    elseif dim==3
        plot3(K{n}(:,1),K{n}(:,2),K{n}(:,3),'-','Color',c(n,:))
        view(45,30);
    end
end


%% Builds trajectory struct
trajectory.trajectory = K;
SYS = GradSystemStructure();
trajectory.idx = cell(1,length(trajectory.trajectory));
for n=1:length(trajectory.trajectory)
    idx_start = (headerOut.trajectIndices(n,1) - 1) ./ headerOut.dwelltime .* SYS.GRT_SI + 1;
    idx_stop  =  headerOut.trajectIndices(n,2)      ./ headerOut.dwelltime .* SYS.GRT_SI;
    trajectory.idx{n} = idx_start : idx_stop;
end
trajectory.resolution = repmat(headerOut.resolution(1),[1 length(filename)]);
trajectory.fov = repmat(headerOut.fov(1),[1 length(filename)]);

end

function trajectory = loadTrajectory_Grad(filename,delay,amp_scaling)
%% trajectory = loadTrajectory_Grad(filename,delay,amp_scaling)
% filename: String
% delay: A three element array containing the gradient delays for every
%        axis in microsec and ordered as [phase read slice]. Doing the
%        interpolation the right way this should be unnecessary on a state
%        of the art (Siemens) scanner. If left empty [0 0 0] is used.
% amp_scaling: E.g. [2 2 2] doubles the resolution of the reconstructed
%              image with respect to the aqurired resolution. If left empty
%              [1 1 1] is used.
% Call without argument in order to get a pop up window for file selection.

% returns a trajectory structure:
% i.e. trajectory.trajectory{n} =>k-space data of 1 interleave (out of n)
%                .idx{n} => k-space points used for recon
%                .resolution  => global nominal pixel resolution
%                .fov  => nominal fov
%
% Jakob Assländer 09.07.2013 (jakob.asslaender@uniklinik-freiburg.de)
% revised by Bruno Riemenschneider 2016-

if nargin < 3
    amp_scaling = [1 1 1];
end
if nargin < 2
    delay = [0 0 0];
end
if nargin ==0 || isempty(filename)
    [filename,PathName] = uigetfile('*.grad');
    fullFile = [PathName filename];
else
    [pname, fname, extension] = fileparts(filename);
    if isempty(pname) || strcmp(pname, '.')
        fullFile = fullfile(pwd, [fname, extension]);
    else
        fullFile = filename;
    end
end

%get proper constants and specifications
SYS=GradSystemStructure('slow');

fid = fopen(fullFile);
tline = fgetl(fid);
counter = 1;

D = textscan(tline,'%f');
D = D{1};

while isempty(D)
    
    S = textscan(tline,'%s');
    S = S{1};
    
    if ~isempty(strfind(tline,'Number_of_Samples'))
        NumSamples = str2num(S{2});
    elseif ~isempty(strfind(tline,'Maximum_Gradient_Amplitude_[mT/m]'))
        max_grad = str2num(S{2});
    elseif ~isempty(strfind(tline,'Number_of_Elements'))
        NumOfElem = str2num(S{2});
    elseif ~isempty(strfind(tline,'Element_length'))
        ElementLength = str2num(S{2});
    elseif ~isempty(strfind(tline,'Field_Of_View_[mm]'))
        fov = str2num(S{2})/1e3;
    elseif ~isempty(strfind(tline,'Base_Resolution'))
        N = str2num(S{2});
    elseif ~isempty(strfind(tline,'TE_[micros]'))
        TE = str2num(S{2});
    elseif ~isempty(strfind(tline,'Dwell_[ns]'))
        dwell = str2num(S{2})/1e3;
    elseif ~isempty(strfind(tline,'index')) && ~isempty(strfind(tline,'_start'))
        i1 = strfind(S{1},'index') + 5;
        i2 = strfind(S{1},'_start') - 1;
        idx = str2num(S{1}(i1:i2));
        n1 = str2num(S{2});
        tline = fgetl(fid);
        S = textscan(tline,'%s'); S=S{1};
        counter = counter + 1;
        n2 = str2num(S{2});
        Idx{idx}=(SYS.GRT/dwell)*(n1-1)+1 : (SYS.GRT/dwell)*n2;
    end
    
    tline = fgetl(fid);
    D = textscan(tline,'%f');
    D = D{1};
    counter = counter + 1;
end

fclose(fid);

A = importdata(fullFile,' ',counter-1);

G = A.data;

upfactor_from_grt = 10;
upfactor = SYS.GRT_SI*1e6*upfactor_from_grt;
G_up(:,1) = interp1(0:size(G,1)-1,G(:,1), 0:1/upfactor:size(G,1),'nearest');
G_up(:,2) = interp1(0:size(G,1)-1,G(:,2), 0:1/upfactor:size(G,1),'nearest');
G_up(:,3) = interp1(0:size(G,1)-1,G(:,3), 0:1/upfactor:size(G,1),'nearest');
G_up = [G_up(1:upfactor/2,:); G_up(1:end-upfactor/2,:)];

% BR: Version below had a precision issue
% G_up(:,1) = interp1(0:SYS.GRT_SI:size(G,1)*SYS.GRT_SI - SYS.GRT_SI,G(:,1),...
%     0:SYS.GRT_SI/upfactor:size(G,1)*SYS.GRT_SI ,'nearest');
% G_up(:,2) = interp1(0:SYS.GRT_SI:size(G,1)*SYS.GRT_SI - SYS.GRT_SI,G(:,2),...
%     0:SYS.GRT_SI/upfactor:size(G,1)*SYS.GRT_SI ,'nearest');
% G_up(:,3) = interp1(0:SYS.GRT_SI:size(G,1)*SYS.GRT_SI - SYS.GRT_SI,G(:,3),...
%     0:SYS.GRT_SI/upfactor:size(G,1)*SYS.GRT_SI ,'nearest');
% Convert nearest neigbor interpolation into left neighbor. Left neigbor
% interpolation give the best result when comparing to a measured
% trajectory as well as in the gradient impulse response function (see
% dissertation of Frederic Testud, once it is out there...).
% G_up = [G_up(1:upfactor/2,:); G_up(1:end-upfactor/2,:)];

G = G_up;

kmax=(1/fov)*N/2;

for n=1:NumOfElem
    Gel{n}=G((n-1)*ElementLength*upfactor+1:n*ElementLength*upfactor,:);
    K{n} = (cumsum(Gel{n},1)*(max_grad/1000)*SYS.GRT_SI/upfactor)*SYS.GAMMA_SI/(2*pi);
    K{n}(:,2:3) = - K{n}(:,2:3);
    K{n}=(K{n}/kmax)*pi;
end

%K = (cumsum(G,1)*(max_grad/1000)*SYS.GRT_SI/upfactor)*SYS.GAMMA_SI/(2*pi);

%match with nuFFT-Operator
%K(:,2:3) = - K(:,2:3);

%kmax=(1/fov)*N/2;

%K=(K/kmax)*pi;

%Kout is still in 1 microsec
%for n=1:NumOfElem
%    Kout{n}=K((n-1)*ElementLength*upfactor+1:n*ElementLength*upfactor,:);
%end
Kout = K;

fraction = dwell/1*upfactor/10;
delay = delay*upfactor_from_grt; %delay input is in µs
tmp=CorrectK(Kout,delay,amp_scaling);
for n=1:NumOfElem
    trajectory.trajectory{n}=downsample(tmp{n},fraction);
    trajectory.idx{n} = Idx{n};
end

trajectory.fov = [fov fov fov];
trajectory.resolution = [N N N];
trajectory.trajectory_filename = fullFile;
trajectory.dwelltime_s = dwell/1e6;
try
    trajectory.TE_s = TE/1e6;
catch
    trajectory.TE_s = [];
end
%figure; plot(K{1},'b'); %hold on;  plot(K{2},'c')

end

%subfunctions !
function K=CorrectK(Kin,delay,amp)

for n=1:length(Kin)
    K{n}(:,1) = amp(1)*shift_data(Kin{n}(:,1),delay(1));
    K{n}(:,2) = amp(2)*shift_data(Kin{n}(:,2),delay(2));
    K{n}(:,3) = amp(3)*shift_data(Kin{n}(:,3),delay(3));
end
end

function out = shift_data(in,l)

if l<0 % shift to the left
    out=[in(abs(l)+1:end); zeros(abs(l),1)];
elseif l>0 % shift to the rigth
    out=[zeros(l,1); in(1:end-l)];
else
    out = in;
end

end