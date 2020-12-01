function [hf, hdf] = L1Norm(lambda,varargin)

% usage:
%   [hf, hdf] = L1Norm(lambda,varargin)
%
% varargin enthaelt Operatoren die auf 'z' wirken vor der
% Bildung der Norm, z.B.:
%   Dx = finiteDifferenceOperator(1);
%   Dy = finiteDifferenceOperator(2);
%   varargin = {Dx, Dy} fuer Berechnung der TV in 2D.
%
% 30.09.2011
% Thimo Hugger

mu = 1e-15;

if nargin==1
    varargin{1} = 1;
end

    function y1 = R(z,alpha,d,update_flag) % nargin>=2 is meant for efficient line search
        persistent Vz Vd;
        if nargin>1 && update_flag==1
            Vz = cell(1,length(varargin));
            Vd = cell(1,length(varargin));
        end

        y1 = 0;
        for k=1:length(varargin)
            if nargin==1
                y1 = y1 + sum(col(abs(varargin{k}*z + mu)));
            else
                if update_flag==1
                    Vz{k} = varargin{k}*z;
                    Vd{k} = varargin{k}*d;
                end
                y1 = y1 + sum(col(abs(Vz{k} + alpha * Vd{k} + mu)));
            end
        end
        y1 = lambda * y1;
    end

    function y2 = dR(z,alpha,d,update_flag)
        persistent Vz Vd;
        if nargin>1 && update_flag==1
            Vz = cell(1,length(varargin));
            Vd = cell(1,length(varargin));
        end

        y2 = 0;
        for k=1:length(varargin)
            if nargin==1
                Vz = varargin{k}*z;
                y2 = y2 + varargin{k}'*( Vz ./ sqrt(conj(Vz).*Vz + mu) );
            else
                if update_flag==1
                    Vz{k} = varargin{k}*z;
                    Vd{k} = varargin{k}*d;
                end
                Vy = Vz{k} + alpha * Vd{k};
                y2 = y2 + varargin{k}'*( Vy ./ sqrt(conj(Vy).*Vy + mu) );
            end
        end
        y2 = lambda * y2;
    end

    hf = @R;
    hdf = @dR;
    
end