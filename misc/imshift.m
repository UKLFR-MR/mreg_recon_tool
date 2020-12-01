%% usage: function [ima] = imshift(matrix, shift)
% Like circshift, but fractional shifts are allowed
% If shift contains only integers circshift is used instead.

% input: matrix: can have an arbitrary number of dimensions.
%                It can be non-square and complex 
%        shift: vector with the shift in voxel, fractions allowed
%               The length of shift can be less than the dimensions of 
%               matrix. They other dimensions are not shifted.
% output: ima:  The shifted image
%
% I put the same file in matlab_new/utils and matlab_new/fmri/mreg because
% the latter folder is distributed to our cooperation partners and I didn't
% want to delete it in the utils folder. I know this is bad practice...
% 
% Jakob Asslaender, July 2012
% University Medical Center Freiburg
% jakob.asslaender@uniklinik-freiburg.de

function [ima] = imshift(matrix, shift)

if all(shift == round(shift));
    ima = circshift(matrix, shift);
else
    
    phase = ones(size(matrix));
    
    for s = 1 : length(shift)
        ns = size(matrix, s);
        
        % build an array that is singular in all dimensions except s
        sh = ones(1, size(size(matrix),2));
        sh(s) = size(matrix, s);
        sh = ones(sh);
        
        % fill the dimension s with the phase in that dimension
        sh(:)=exp(-1i*pi*shift(s)*(-1:2/ns:1-2/ns));
        
        % convert sh to an array with the size of matrix and multiply it to the
        % phase of the shift in the other dimensions
        repvec = size(matrix);
        repvec(s) = 1;
        phase = phase .* repmat(sh, repvec);
    end
    
    % The actual shift: The phase is multiplied in k-space
    ima=ifftn(fftn(matrix).*fftshift(phase));
    
end
