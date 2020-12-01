function [hf, hdf] = Entropy(lambda)

% usage:
%   [hf, hdf] = Entropy(lambda)


    function y1 = R(z)
        tmp = real(z) .* log(real(z));
        y1 = -lambda * sum(tmp(:));
    end

    function y2 = dR(z)
        y2 = -lambda * (log(real(z)) + real(z));
    end

hf = @R;
hdf = @dR;

end