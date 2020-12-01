function [out, hdr] = loadData(filename,t)

% function out = loadData(filename,t)
%
%
% out = data
% header = header information
%
% Bruno Riemenschneider, 2016
% twix object is saved to folder twx_obj, and may later be
% retrieved. If at that later point of time, the dataset has moved on the
% hard drive, I am not sure the pointer in twx_obj.image() still points at
% the correct location!
% In doubt, delete the twx_obj from the folder and rerun loadData.m

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
    save(fullfile([pathname,'/twx_obj'],twx_obj_name),'twx');
else
    load(fullfile([pathname,'/twx_obj'],twx_obj_name));
end

hdr = readhdr(filename,twx);

if iscell(twx)
    twx = twx{end};
end

%get data
try
    tmp = twx.image(:,:,1,1,1,1,1,1,1,:);
catch
    twx = mapVBVD(filename);
    save(fullfile([pathname,'/twx_obj'],twx_obj_name),'twx');
    if iscell(twx)
        twx = twx{end};
    end
    tmp = twx.image(:,:,1,1,1,1,1,1,1,:);
end

if nargin<2
    out = squeeze(twx.image(:,:,:,1,1,1,1,1,:,:));
    out = permute(out,[1 5 2 3 4]);
    out = reshape(out,[size(out,1)*size(out,2) size(out,3) size(out,4)*size(out,5)]);
elseif length(t)>1
    reps = [ceil(t(1)/twx.hdr.Config.NLinMeas):ceil(t(end)/twx.hdr.Config.NLinMeas)];
    out = zeros([size(tmp,1) size(tmp,2) length(t) size(tmp,10)]);
    counter = 1;
    for i=1:length(reps)
        lins = t((t>twx.hdr.Config.NLinMeas*(reps(i)-1))&(t<=twx.hdr.Config.NLinMeas*reps(i)))-twx.hdr.Config.NLinMeas*(reps(i)-1);
        out(:,:,counter:counter+length(lins)-1,:) = squeeze(twx.image(:,:,lins,1,1,1,1,1,reps(i),:));
        counter = counter+length(lins);
    end
    out = permute(out,[1 4 2 3]);
    out = reshape(out,[size(out,1)*size(out,2) size(out,3) size(out,4)]);
else
    lin = mod(t-1,twx.hdr.Config.NLinMeas)+1;
    rep = ceil(t/twx.hdr.Config.NLinMeas);
    out = squeeze(twx.image(:,:,lin,1,1,1,1,1,rep,:));

%out = fftshift(fft(out,[],1));
%out = ifft(ifftshift(out(126:375,:,:)),[],1);
    
    out = permute(out,[1 3 2]);
    out = reshape(out,[size(out,1)*size(out,2) size(out,3)]);

%out = fftshift(fft(out,[],1));
%out = ifft(ifftshift(out(size(out,1)/4+1:3*size(out,1)/4,:,:)),[],1);

end

if hdr.B0 == 7
    disp('7 Tesla data is not implemented yet in the latest loadData.m. Have a look at the commented lines.')
%     out = out(65:end,:,:);
%     out(:,[1 2 4 5 6 7 8 17],:)=[];%from the old loadData.m
end
end