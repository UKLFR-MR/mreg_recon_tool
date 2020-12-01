function [out, fout] = cutoffFilter(in, TR, lf, hf, type, dim, dcflag)

if nargin<=5
    dim = 1;
end
if nargin<=6
    dcflag = 0;
end

si = size(in);
ind = 1:length(size(in));
ind(dim) = [];

total_time = size(in,dim) * TR;
lf_i = round(lf * total_time)+1;
hf_i = round(hf * total_time);

dummy = fft(in,[],dim);

filt = zeros(size(in,dim),1);
filt(lf_i:hf_i) = 1;
filt((size(in,dim)-lf_i+2):-1:(size(in,dim)-hf_i)+2) = 1;
if (length(filt)>size(in,dim))
    filt(size(in,dim)+1:length(filt)) = [];
end
if dcflag
    if strcmp(type, 'bandstop')
        filt(1) = 0;
    elseif strcmp(type, 'bandpass')
        filt(1) = 1;                            % keep the dc-component
    end
end
filt = repmat(filt, [1 si(ind)]);
filt = ipermute(filt, [dim, ind]);


if strcmp(type, 'bandstop')
    dummy = dummy.*(1-filt);
elseif strcmp(type, 'bandpass')
    dummy = dummy.*filt;
end
if nargout==2
    fout = dummy;
end

out = ifft(dummy,[],dim);