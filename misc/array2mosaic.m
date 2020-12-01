function M = array2mosaic(X, rc)

% usage:
%   M = array2mosaic(X, rc)
%
% Arranges 3d data in a mosaic-like 2d pattern.
% The data may also be 4-dimensional, then the mosaic is generated
% for n=1:size(X,4) separately and recombined in the end to a 3d array.
% This is useful for arrays that contain the colormap in the last dimension.
% The result may for example be displayed using image().
%
% X = 3d data array or 4d rgb-data (last dim. has to be color)
% rc = [#rows #cols] of the mosaic image.


nr = size(X,1);
nc = size(X,2);
slices = size(X,3);

if nargin==1
    rows = floor(sqrt(slices));
    cols = ceil(slices / rows);
elseif prod(rc)<slices
    error('Number of rows and columns is too small for specified data.');
else
    rows = rc(1);
    cols = rc(2);
end

if length(size(X))==3
    
    M = zeros(rows*nr, cols*nc);

    c = 1;
    r = 1;
    for k=1:slices
        M((r-1)*nr+1:r*nr, (c-1)*nc+1:c*nc) = X(:,:,k);
        c = c + 1;
        if c > cols
            c = 1;
            r = r + 1;
        end
    end

elseif length(size(X))==4
    if size(X,4)~=3
        display('size(X,4) is not equal to 3. result won''n be an RGB image');
    end

    M = zeros(rows*nr, cols*nc, size(X,4));
    for k=1:size(X,4)
        M(:,:,k) = array2mosaic(X(:,:,:,k), [rows cols]);
    end

else
    
    error('Input must be 3- or 4-dimensional.');

end
