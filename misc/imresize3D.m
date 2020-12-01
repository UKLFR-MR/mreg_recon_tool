function out = imresize3D(A, dim, fov_ratio, method)

% function Z = imresize3D(A, dim, fov_ratio, method)
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
    fov_ratio = repmat(fov_ratio,[1 3]);
end

[Nr, Nc, Ns, ~, ~, ~] = size(A);
Mr = dim(1);
Mc = dim(2);
Ms = dim(3);

%[X, Y, Z] = meshgrid(1:Nc, 1:Nr, 1:Ns);
[X, Y, Z] = meshgrid(-Nc/2+0.5:Nc/2-0.5, -Nr/2+0.5:Nr/2-0.5, -Ns/2+0.5:Ns/2-0.5);

Ir = linspace(0.5*(1+Nr/Mr),Nr+0.5*(1-Nr/Mr),Mr) - (Nr/2+0.5);
Ic = linspace(0.5*(1+Nc/Mc),Nc+0.5*(1-Nc/Mc),Mc) - (Nc/2+0.5);
Is = linspace(0.5*(1+Ns/Ms),Ns+0.5*(1-Ns/Ms),Ms) - (Ns/2+0.5);

Ir = Ir*fov_ratio(1);
Ic = Ic*fov_ratio(2);
Is = Is*fov_ratio(3);

[Xi,Yi,Zi] = meshgrid(Ic,Ir,Is);
out = complex(zeros([Mr,Mc,Ms,size(A,4),size(A,5),size(A,6)]));
% implemented for an tesor with up to 6 dimensions
for i = 1:size(A,4)
    for k = 1:size(A,5)
        for l = 1:size(A,6)
            out(:,:,:,i,k,l) = interp3(X,Y,Z,squeeze(A(:,:,:,i,k,l)),Xi,Yi,Zi,method,0); % values lieing outside of the grid will be set to zero
        end
    end
end
out = squeeze(out);
