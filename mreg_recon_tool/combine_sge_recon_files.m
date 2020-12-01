function recon = combine_sge_recon_files(path)

if nargin==0
    path = pwd;
end

[~, S] = unix(['ls ',path,'/recon_job_*.mat']);
S = textscan(S,'%s');
S = S{1};
N = length(S);
progresscounter('clear');

tfirst = load_data(path,0);
Nt = size(tfirst,4);

tlast = load_data(path,N-1);
Nlast = size(tlast,4);

Ntot = Nt*(N-1)+Nlast;

recon = single(zeros(size(tfirst,1),size(tfirst,2),size(tfirst,3),Ntot));
recon(:,:,:,1:Nt) = tfirst;
recon(:,:,:,Ntot-Nlast+1:Ntot) = tlast;

for k=1:N-2
    recon(:,:,:,k*Nt+1:(k+1)*Nt) = load_data(path,k);
    progresscounter(N-2);
end

end

function data = load_data(path,k)

L = load([path,'/recon_job_',num2str(k),'.mat'], '-mat');
L_field = fieldnames(L);
data = L.(L_field{1});

end
