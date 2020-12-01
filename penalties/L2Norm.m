function [hf, hdf] = L2Norm(lambda,varargin)

% usage:
%   [hf, hdf] = L2Norm(lambda,varargin)
%
% varargin enthaelt Operatoren die auf 'z' wirken vor der
% Bildung der Norm, z.B.:
%   varargin = {Dx, Dy} fuer Berechnung der quadratischen Variation in 2D.
%
% 30.09.2011
% Thimo Hugger

if nargin==1
    varargin{1} = 1;
end

    function y1 = R(z,alpha,d,update_flag)
        persistent Vz Vd;
        if nargin>1 && update_flag==1
            Vz = cell(1,length(varargin));
            Vd = cell(1,length(varargin));
        end
        
        y1 = 0;
        for k=1:length(varargin)
            if nargin==1
                tmp = varargin{k}*z;
                y1 = y1 + tmp(:)'*tmp(:);
            else
                if update_flag==1
                    Vz{k} = varargin{k}*z;
                    Vd{k} = varargin{k}*d;
                end
                Vy = Vz{k} + alpha * Vd{k};                
                y1 = y1 + Vy(:)'*Vy(:);
            end
        end
        y1 = lambda * y1;
    end

    function y2 = dR(z,alpha,d,update_flag)
        persistent VVz VVd;
        if nargin>1 && update_flag==1
            VVz = cell(1,length(varargin));
            VVd = cell(1,length(varargin));
        end
        
        y2 = 0;
        for k=1:length(varargin)
            if nargin==1
                y2 = y2 + varargin{k}'*(varargin{k}*z);
            else
                if update_flag==1
                    VVz{k} = varargin{k}'*(varargin{k}*z);
                    VVd{k} = varargin{k}'*(varargin{k}*d);
                end
                y2 = y2 + (VVz{k} + alpha * VVd{k});
            end
        end
        y2 = (2 * lambda) * y2;
    end

hf = @R;
hdf = @dR;

end