function raw = DORK_correct(raw,header,dork_freq,phi)

    %this function wants raw in dimensions adcs x channels x time
    t = header.te(1)*ones(size(raw,1),1) + (0:size(raw,1)-1)'*header.dwelltime;
    raw = raw .* permute(repmat(exp(-1i*(repmat(phi,[1 length(t)])+dork_freq*t')), [1 1 size(raw, 2)]),[2 3 1]);

end