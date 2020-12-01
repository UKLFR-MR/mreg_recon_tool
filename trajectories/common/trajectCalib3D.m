function [K PHASE]= trajectCalib3D(mids,segments,fov,distance)

%ONLY VOLUME COILS !!

%IN: 
%mids = array containing raw data measurement ID's
%distance = distane of slices or voxels

%fov = 0.256; %m
%N = 64;
%kmax = (pi*N)/fov;
%distance  = 10/1000; %m
%splits =1;

if nargin == 1
    fov = 0.256;
    segments = 1;
    distance = 10/1000;
end


%% alternating trajectory and phase reference measurement
    
    for n=1:3;
        %data=loadRawData(filenameByMID(mids(n)),1);
        %data=squeeze(data.dataAy);
        data = mapVBVD(mids(n))
        data = data.image(:,:,:,1,1,1,1,1,1,:);
        
        %now data is lines x adcs
        data=reshape(data,[size(data,1) size(data,2)*size(data,3)]);
        
        %data must be a multiple of 2 times number of segments
        data=data(1:(size(data,1)-mod(size(data,1),2*segments)),:);
        
        %reshape index for segments
        data=reshape(data,[2 size(data,1)/2 size(data,2)]);
        data=reshape(data,[2 segments size(data,2)/segments size(data,3)]);
        
        data=unwrap(angle(data),[],4);
        
        
     temp=data(1,:,:,:) - data(2,:,:,:); 
     PHASE{n}=squeeze(temp(1,:,1,:));
    end
 


ky=squeeze(PHASE{1})';
kx=squeeze(PHASE{2})';
kz=squeeze(PHASE{3})';

kx=kx(:);
ky=ky(:);
kz=kz(:);

% Trajectory is reoriented according to nuFFT-operator
K=[kx -ky -kz];
K=K/distance;
K(:,1:2)=K(:,1:2)*fov/64;
K(:,3)=K(:,3)*fov/64;


figure; plot3(K(:,1),K(:,2),K(:,3),'.')
figure; plot(sqrt(abs(K(:,1)).^2 + abs(K(:,2)).^2  +abs(K(:,3)).^2 ))
 
end
    