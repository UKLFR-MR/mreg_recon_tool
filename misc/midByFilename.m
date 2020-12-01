function mid = midByFilename(filename)

[~,f] = fileparts(filename);
idx = strfind(f,'_MID');
f = f(idx+4:end);
idx = strfind(f,'_');
mid = f(1:idx-1);
mid = str2num(mid);
