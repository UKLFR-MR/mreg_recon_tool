function [hf, hdf] = NonNegativity(lambda)

% usage:
%   [hf, hdf] = NonNegativity(lambda,varargin)

    function y1 = R(z)
        I = (real(z)<0);
%         y1 = lambda * real(z(I))'*real(z(I));
        tmp = real(z(I));
        y1 = lambda * tmp(:)'*tmp(:);
    end

    function y2 = dR(z)
        I = (real(z)<0);
        y2 = 2 * lambda * (I .* real(z));
    end

hf = @R;
hdf = @dR;
    
end