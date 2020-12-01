function [smaps, recon] = coilSensitivities(cmaps, method, varargin)

% function [smaps, recon] = coilSensitivities(cmaps, method, varargin)
%
% varargin contains additional arguments of the different methods
% 'sos': varargin = mask threshold

if nargin<=1 || isempty(method)
    method = 'adaptive';
end

if length(size(cmaps))==3
    flag3d = 0;
    cI = 3;
elseif length(size(cmaps))==4
    flag3d = 1;
    cI = 4;
else
    error('cmaps should be 3 or 4 dimensional.');
end

sc = size(cmaps);
Nc = sc(cI);

if strcmp(method,'adaptive') || strcmp(method,'adapt')
    if flag3d==0
        [recon, smaps] = adapt(permute(cmaps,[cI 1:cI-1]));
        smaps = ipermute(smaps,[cI 1:cI-1]);
    else
        [recon, smaps] = adapt3D(cmaps);
    end
      
elseif strcmp(method,'sos')
    % varargin{1} specifies the threshold for the masking of the sensitivity profiles.
    % if no varargin is given, no mask will be applied
    if nargin<=2
        mask_flag = 0;
    else
        mask_thresh = varargin{1};
        mask_flag = 1;
    end
    if flag3d==0
        for k=1:size(cmaps,3)
            cmaps(:,:,k) = imfilter(cmaps(:,:,k),fspecial('gauss',[5 5], 2));
        end
    else
        for k=1:size(cmaps,4)
%            cmaps(:,:,:,k) = imfilter(cmaps(:,:,:,k),fspecial3D('gauss',[5 5 5], 2));
            cmaps(:,:,:,k) = smooth3(cmaps(:,:,:,k),'gaussian',[5 5 5], 2);
        end
    end
    sos = sqrt(sum(abs(cmaps).^2,cI));
    sos = repmat(sos(:),[1 Nc]);
    sos = reshape(sos, sc);
    smaps = cmaps ./ sos;
    if mask_flag==1
        mask = (abs(sos)>mask_thresh*max(abs(sos(:))));
        smaps = smaps .* mask;
    end
    
    recon = sos;
    
elseif strcmp(method,'phase optimized') || strcmp(method,'po') || strcmp(method,'PO')
    sos = sqrt(sum(abs(cmaps).^2,cI));
    sos = repmat(sos(:),[1 Nc]);
    sos = reshape(sos, sc);
    cmo = cmaps ./ sos;
    
    tmp = sum(cmaps,cI);
    tmp = tmp ./ abs(tmp); % keep only phase
    tmp = repmat(tmp(:),[1 Nc]);
    tmp = reshape(tmp, sc);
        
    cpo = cmaps ./ tmp;
    
    ccom = abs(cmo) .* (cpo./abs(cpo));
    
    smaps = ccom;    
    
    recon = sos;
    
elseif strcmp(method,'polyfit')
    smaps = zeros(size(cmaps));
    %kb = kaiserBesselWindow([sqrt(2) sqrt(2)],[],linspace(-0.5,0.5,sc(1)),linspace(-0.5,0.5,sc(2)));
    for k=1:Nc
        smaps(:,:,k) = pmri_poly_sensitivity(cmaps(:,:,k),5);
    end
    
    recon = sqrt(sum(abs(cmaps).^2,cI));
    
    
elseif strcmp(method,'lowres')
    if nargin<=2
        t = 16;
    else
        t = varargin{1};
    end
    smaps = zeros(size(cmaps));
    if flag3d==0
        for k=1:Nc
            ksize = [size(cmaps,1) size(cmaps,2)]/10;
            fwidth = mean(ksize)/2;
            tmp = imfilter(cmaps(:,:,k),fspecial('gauss',ceil(ksize),fwidth));
            tmp = ifff2(tmp);
            tmp = tmp(sc(1)/2-t+1:sc(1)/2+t,sc(2)/2-t+1:sc(2)/2+t);
            smaps(sc(1)/2-t+1:sc(1)/2+t,sc(2)/2-t+1:sc(2)/2+t,k) = tmp;
            smaps(:,:,k) = fff2(smaps(:,:,k));
        end
    else
        for k=1:Nc
            ksize = [size(cmaps,1) size(cmaps,2) size(cmaps,3)]/10;
            fwidth = mean(ksize)/2;
            tmp = imfilter(cmaps(:,:,:,k),fspecial3D('gauss',ceil(ksize),fwidth));
            tmp = ifffn(tmp);
            tmp = tmp(sc(1)/2-t+1:sc(1)/2+t,sc(2)/2-t+1:sc(2)/2+t,sc(3)/2-t+1:sc(3)/2+t);
            smaps(sc(1)/2-t+1:sc(1)/2+t,sc(2)/2-t+1:sc(2)/2+t,sc(3)/2-t+1:sc(3)/2+t,k) = tmp;
            smaps(:,:,:,k) = fffn(smaps(:,:,:,k));
        end        
    end
    
    recon = sqrt(sum(abs(cmaps).^2,cI));
else
    error('Unknown method.');
    
end