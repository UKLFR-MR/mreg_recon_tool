function [sos]=makesos(data,dim)

% Berechnet ein "Sum-Of-Squares"-Bild (SOS) aus einem 3D-Datensatz
%
% Aufruf: [SOS]=MAKESOS(DATA)
%
% Input:        3D-Datensatz 'DATA'
% Output:      "Sum-Of-Squares"-Bild 'SOS'

[nc,ny,nx]=size(data);

if nargin <2, dim=1; end
sos=squeeze(sqrt(sum(abs(data).^2,dim)));
% figure, imagesc(abs(sos)); colorbar;