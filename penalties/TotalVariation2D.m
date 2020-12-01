function [hf, hdf] = TotalVariation2D(lambda)

% usage:
%   [hf, hdf] = TotalVariation(lambda)


Dx = derivativeOperator2D(N,N,'x');
Dy = derivativeOperator2D(N,N,'y');


    function y1 = f(z)
        persistent Dx;
        persistent Dy;
        if isempty(Dx)
            Dx = derivativeOperator2D(N,N,'x');
        end
        if isempty(Dy)
            Dy = derivativeOperator2D(N,N,'y');
        end
        y1 = lambda * ( norm(Dx*z, 1) + norm(Dy*z, 1) );
    end

    function y2 = df(z)
        PSIz = PSI*z;
        y2 = lambda * PSI'*( PSIz ./ sqrt(conj(PSIz).*PSIz + mu) );
    end

    hf = @f;
    hdf = @df;
    
end