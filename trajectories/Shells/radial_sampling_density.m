function [k_vd n]=radial_sampling_density(R0,Rend,plot_flag,N)

if nargin == 0
    R0 =2;
    Rend =4;
end
if nargin < 3
    plot_flag =1;
end

if nargin < 4
N=32;
end

R=2;
deltak_full = 1/N;

kradial_full = deltak_full:deltak_full:1;

kradial_unders = 0:deltak_full*R:1;


slope=Rend-R0;
k_vd = R0*deltak_full;
%k_vd = deltak_full;
while k_vd(end)<=1
    ktmp=k_vd(end);
    R_eff = R0 + slope*ktmp;
    k_vd = [k_vd ktmp+R_eff*deltak_full];
end

if k_vd(end)>1.001
    k_vd(end)=[];
end

n=length(k_vd);

if plot_flag
display('Number of shells:')
display(length(k_vd))
figure; 
plot(kradial_full,ones(length(kradial_full),1),'o');
axis([-0.1 1.2 0.8 1.6])
hold on
plot(kradial_unders,1.1*ones(length(kradial_unders),1),'ro');
plot(k_vd,1.2*ones(length(k_vd),1),'go');
end