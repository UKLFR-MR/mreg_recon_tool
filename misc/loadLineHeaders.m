function header=loadLineHeaders(filename, IDEA_version)
% loads the block headers for Siemens raw files. If they are already stored
% in /line_header/headername.mat, that version is taken. If not, it is read
% out of the raw data file and stored in /line_header for faster access in
% future.
% Works for VB17 and VD11. For either of it, subfunctions are called.
%
% Input: filename: The name of the raw data file
%        IDEA_version: 'VB17' or 'VD11'. Leave blank if unknown (takes
%                      time)
%
% Jakob Asslaender, University Medical Center Freiburg, Feb 2012



% Find out the version, if unknown (takes times).
if nargin < 2 || isempty(IDEA_version)
    meas_header = readHeader(filename);
    IDEA_version = meas_header.IDEA_version;
end

[pathname,filename_no_ext,ext] = fileparts(filename);
if isempty(pathname)
    pathname = '.';
end

headername = [filename_no_ext, '_header.mat'];

if ~exist([pathname,'/line_header'],'dir')
    mkdir([pathname,'/line_header']);
end

if ~exist(fullfile([pathname,'/line_header'],headername),'file')
    if strcmp(IDEA_version, 'VB17') || strcmp(IDEA_version, 'VB15')
        header = loadLineHeaders_vb17(fullfile(pathname,[filename_no_ext ext]));
    elseif strcmp(IDEA_version, 'VD11') || strcmp(IDEA_version, 'VD13')
        header = loadLineHeaders_vd11(fullfile(pathname,[filename_no_ext ext]));
    else
        error('idea_version must be either ''VB17'' or ''VD11''.');
    end
    save(fullfile([pathname,'/line_header'],headername),'header');
else
    load(fullfile([pathname,'/line_header'],headername));
end


end


function header=loadLineHeaders_vb17(filename)

fid = fopen(filename,'r','ieee-le');

% Pointer to start of raw data
h_raw_start=double(fread(fid,1,'*uint32'));
b_float = 4;

fseek(fid, h_raw_start, -1);
short_buff = fread(fid, 64,'*uint16');
n = double(short_buff(15)); % Number of complex data points
offset = h_raw_start;

% Attempt to read all remaining line headers, assuming constant line length
fseek(fid,offset,-1);
short_buff = fread(fid,[64 Inf],'64*uint16=>uint16',n*b_float*2);
line_lengths = short_buff(15,:);

last_valid_index = find(line_lengths ~= n,1);
if ~isempty(last_valid_index)
    short_buff = short_buff(:,1:last_valid_index);
end
EvalInfoMask1 = typecast(reshape(short_buff(11:12,:),[],1),'uint32');
end_index = find(bitget(EvalInfoMask1,1),1);

if ~isempty(end_index)
    short_buff = short_buff(:,1:end_index-1);
end

% Only get necessary fields
header.length = short_buff(15,:);
header.address = short_buff([17 19 21 63 18 20 22 24 23 26 27],:);
header.mask = typecast(reshape(short_buff(11:12,:),[],1),'uint32');
header.k_center_row = short_buff(39,:)+1;
acq_time = double(typecast(reshape(short_buff(7:8,:),[],1),'uint32'))*2.5;

offset = offset + (128+n*b_float*2)*(size(short_buff,2)-1);
n = double(short_buff(15,end));
offset = offset + (128+n*b_float*2);

while isempty(end_index) % Read the rest sequentially
    if fseek(fid,offset,-1)==-1
        error('Unexpected end of file');
    end
    
    short_buff = fread(fid,64,'*uint16');
    n = double(short_buff(15));
    EvalInfoMask1 = typecast(reshape(short_buff(11:12),[],1),'uint32');
    if bitget(EvalInfoMask1,1)
        break;
    end
    
    header.length = [header.length short_buff(15)];
    header.address = [header.address short_buff([17 19 21 63 18 20 22 24 23 26 27])];
    header.mask = [header.mask; EvalInfoMask1];
    header.k_center_row = [header.k_center_row short_buff(39)+1];
    offset = offset + (128+n*b_float*2);
end
fclose(fid);

% Calculate offset for each line
header.offset = h_raw_start + cumsum([0 double(header.length(1:end-1))*b_float*2+128]);

% Only keep normal lines
line_index = find(bitget(header.mask,4));
header.length = header.length(line_index);
header.address = header.address(:,line_index);
header.mask = header.mask(line_index);
header.k_center_row = header.k_center_row(line_index);
header.offset = header.offset(line_index);

end

function header=loadLineHeaders_vd11(filename)

fid = fopen(filename,'r','ieee-le');
fseek(fid,4,-1);
count = fread(fid,1,'*uint32'); % number of measurements

% Go to the MrParcRaidFileEntry of the last measurement
fseek(fid,152*(count-1),0);

% Skip measId and fileId
fseek(fid,8,0);
meas_offset = fread(fid,1,'*uint64');

% Skip measurement header
fseek(fid,double(meas_offset),-1);
meas_header_size = fread(fid,1,'*uint32');
fseek(fid,double(meas_offset)+meas_header_size,-1);

% Read scan header
scan_header = fread(fid,96,'*uint16');

scan_length = uint32(scan_header(1)) + bitshift(uint32(scan_header(2)),16); % Number of bytes per scan

n = double(scan_header(25)); % Number of complex data points per channel
n_channels = double(scan_header(26));

% Attempt to read all remaining headers, assuming constant scan length
fseek(fid,double(meas_offset)+meas_header_size,-1);

buff = fread(fid,[96 Inf],'96*uint16=>uint16',scan_length-192);

scan_lengths = uint32(buff(1,:)) + bitshift(uint32(buff(2,:)),16);
EvalInfoMask1 = uint32(buff(21,:)) + bitshift(uint32(buff(22,:)),16);

end_index = find(bitget(EvalInfoMask1,1),1);

diff_length_index = find(scan_lengths(1:end_index-1) ~= scan_length,1);
if ~isempty(diff_length_index)
    fclose(fid);
    error('Not all raw data blocks have the same length');
end

buff = buff(:,1:end_index-1);
EvalInfoMask1 = EvalInfoMask1(1:end_index-1);

% [line slice echo channel_id acqu part phase set rep diffend Bvalue]
header.address = [buff([27 29 31],:); zeros(4,end_index-1); buff([34 33],:); zeros(2,end_index-1)];
header.mask = EvalInfoMask1;
header.offset = double(meas_offset) + double(meas_header_size) + double(scan_length)*(0:size(buff,2)-1) + 192 + 32;
header.n_channels = n_channels;
header.n = n;

fclose(fid);

end

