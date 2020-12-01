function out = imresize2D(A, dim, fov_ratio, method)

% function Z = imresize2D(A, dim, fov_ratio, method)
%
% for other methods than cubic consult 'doc interp3'
%
% A = image
% dim = new image size
% fov_ratio = fov_new/fov_old, e.g. to crop the
%             resized image to half of the orig. fov use
%             fov_ratio = [0.5 0.5 0.5]


if nargin<=3 || isempty(method)
    method = 'cubic';
end
if nargin<=2 || isempty(fov_ratio)
    fov_ratio = 1;
end
if isempty(dim)
    dim = size(A);
end

if length(fov_ratio)==1
    fov_ratio = repmat(fov_ratio,[1 2]);
end

[Nr, Nc, ~] = size(A);
Mr = dim(1);
Mc = dim(2);

[X, Y] = meshgrid(-Nc/2+0.5:Nc/2-0.5, -Nr/2+0.5:Nr/2-0.5);

Ir = linspace(0.5*(1+Nr/Mr),Nr+0.5*(1-Nr/Mr),Mr) - (Nr/2+0.5);
Ic = linspace(0.5*(1+Nc/Mc),Nc+0.5*(1-Nc/Mc),Mc) - (Nc/2+0.5);

Ir = Ir*fov_ratio(1);
Ic = Ic*fov_ratio(2);

[Xi,Yi] = meshgrid(Ic,Ir);

% implemented for an tesor with up to 6 dimensions
for i = 1:size(A,3)
    for k = 1:size(A,4)
        for l = 1:size(A,5)
            out(:,:,i,k,l) = interp2(X,Y,squeeze(A(:,:,i,k,l)),Xi,Yi,method,0); % values lieing outside of the grid will be set to zero
        end
    end
end

% Z = interp2(X,Y,A,Xi,Yi,method,0); % values lieing outside of the grid will be set to zero
