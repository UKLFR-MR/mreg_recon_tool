function K = trajectoryCalib_old(filename,fov)

%IN: 
%mids = array containing raw data measurement ID's
%distance = distane of slices or voxels
%splits = #Of ADC's used to acquire the trajectory

%fov = 0.256; %m
%N = 64;
%kmax = (pi*N)/fov;
%distance  = 10/1000; %m
%splits =1;

if isnumeric(filename)
    mids = filename;
    filename = cell(1,length(mids));
    for k=1:length(mids)
        filename{k} = filenameByMID(mids(k));
    end
end

if nargin == 1
    fov = 0.256;
end


for n=1:6;
    data=loadRawData(filename{n},1);
    data=squeeze(data.dataAy);
    data=squeeze(sum(data,4));
    data=squeeze(sum(data,1));
    data=permute(data,[1 3 2]);
    data=reshape(data,[size(data,1)*size(data,2) size(data,3)]);
    max_data=max(abs(data(:)));
    if mod(n,2)
        highSNRcoils{n}=max(abs(data)) >0.5*max_data;
    end
    data=unwrap(angle(data(:,:)),[],1);
    
    PHASE{n}=data;
end


ky=PHASE{1} - PHASE{2};
kx=PHASE{3} - PHASE{4};
kz=PHASE{5} - PHASE{6};

ky=ky(:,highSNRcoils{1});
kx=kx(:,highSNRcoils{3});
kz=kz(:,highSNRcoils{5});

for k=1:size(ky,2)
    ky(:,k)=ky(:,k)-ky(1,k);
end
for k=1:size(kx,2)
    kx(:,k)=kx(:,k)-kx(1,k);
end
for k=1:size(kz,2)
    kz(:,k)=kz(:,k)-kz(1,k);
end

expected_max_phase = 0.01*((1/fov)*64)*pi;
 init_mean_kx=mean(kx(300:end,:),2);
 init_mean_ky=mean(ky(300:end,:),2);
 init_mean_kz=mean(kz(300:end,:),2);
 index_kx=[];
 index_ky=[];
 index_kz=[];
 for n=1:size(ky,2)
    deviation_ky=(ky(300:end,n)-init_mean_ky)/expected_max_phase;
    max_deviation_ky = max(abs(deviation_ky));
         if 0.1 > max_deviation_ky
            index_ky=[index_ky n];
         end
 end
mean_ky=mean(ky(:,index_ky),2);
%% Kx
 for n=1:size(kx,2)
    deviation_kx=(kx(300:end,n)-init_mean_kx)/expected_max_phase;
    max_deviation_kx = max(abs(deviation_kx));
         if 0.1 > max_deviation_kx
            index_kx=[index_kx n];
         end
 end
mean_kx=mean(kx(:,index_kx),2);
%% kz

 for n=1:size(kz,2)
    deviation_kz=(kz(300:end,n)-init_mean_kz)/expected_max_phase;
    max_deviation_kz = max(abs(deviation_kz));
         if 0.1 > max_deviation_kz
            index_kz=[index_kz n];
         end
 end
mean_kz=mean(kz(:,index_kz),2);

kx=mean_kx;
ky=mean_ky;
kz=mean_kz;

% Trajectory is reoriented according to nuFFT-operator
K=[kx -ky -kz];
K=K/0.01;
K(:,1:2)=K(:,1:2)*fov/64;
K(:,3)=K(:,3)*fov/64;

K = {K};
 