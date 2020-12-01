function Q = mtimes(A,B)

% nufft_simple(B .* A.sensmaps{k}, A.scaling_factor, A.interpolation_matrix{m}, A.oversampling)
% nufft_adj_simple(B .* A.sensmaps{k}, A.scaling_factor, A.interpolation_matrix{m}, A.oversampling, A.imageDim)


if strcmp(class(A),'orc_segm_nuFTOperator')
    
    if A.adjoint
        Q = zeros(size(A));
        for k=1:A.numCoils
            tmp = B((k-1)*A.trajectory_length+1:k*A.trajectory_length);

            y = zeros(size(A));
            for m=1:length(A.segment_index)
                x = nufft_adj_simple(A.segment_filter{m} .* tmp(A.segment_index{m}), A.scaling_factor, A.interpolation_matrix{m}, A.oversampling, A.imageDim);
                if ndims(A.wmap) == 3
                    y = y + conj(A.wmap(:,:,m)) .* x;
                elseif ndims(A.wmap) == 4
                    y = y + conj(A.wmap(:,:,:,m)) .* x;
                else
                    error('orc_sgm_nuFTOperator.mtimes: Only for 2D and 3D implemented');
                end
            end
            Q = Q + (y .* conj(A.sensmaps{k}));
        end
        Q = Q / sqrt(prod(A.imageDim));
        

    else
        Q = zeros(A.trajectory_length*A.numCoils, 1);
        for k=1:A.numCoils
            tmp = B .* A.sensmaps{k};

            y = zeros(A.trajectory_length,1);
            for m=1:length(A.segment_index)
                if ndims(A.wmap) == 3
                    x = A.wmap(:,:,m) .*tmp;
                elseif ndims(A.wmap) == 4
                    x = A.wmap(:,:,:,m) .*tmp;
                else
                    error('orc_sgm_nuFTOperator.mtimes: Only for 2D and 3D implemented');
                end
                x = nufft_simple(x, A.scaling_factor, A.interpolation_matrix{m}, A.oversampling);
                x = A.segment_filter{m} .* x;
                y(A.segment_index{m}) = y(A.segment_index{m}) + x;
            end
            
            Q((k-1)*A.trajectory_length+1:k*A.trajectory_length) = y;
        end
        Q = Q / sqrt(prod(A.imageDim));
        
    end
    
    
% now B is the operator and A is the vector
elseif strcmp(class(B),'orc_segm_nuFTOperator')
    Q = mtimes(B',A')';

else
   error('orc_segm_nuFTOperator:mtimes', 'Neither A nor B is of class orc_segm_nuFTOperator');
end
    
end