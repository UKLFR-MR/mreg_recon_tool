function [K PHASE]= trajectoryCalib3D_wip(mids,fov,trajectCalibMode)

%IN: 
%mids = array containing raw data measurement ID's
%distance = distane of slices or voxels
%splits = #Of ADC's used to acquire the trajectory

%fov = 0.256; %m
%N = 64;
%kmax = (pi*N)/fov;
%distance  = 10/1000; %m
%splits =1;

if nargin == 1
    fov = 0.256;
    trajectCalibMode = 1;
end

if (length(mids) == 1)
    mids = mids:1:mids+5;
end




%% alternating trajectory and phase reference measurement
if (trajectCalibMode == 1)
    
    for n=1:3;
        data=loadRawData(filenameByMID(mids(n)),1);
        data=squeeze(data.dataAy);
        data=permute(data,[1 2 4 3]);
        data=reshape(data,[size(data,1) size(data,2)*size(data,3) size(data,4)]); 
        
        ABS{n}=abs(data);
        data=unwrap(angle(data),[],2);
        
         for k=1:size(data,1)
             for m=1:size(data,3)
                 data(k,:,m)=data(k,:,m) - data(k,1,m);
             end
        end
        
        %data1=squeeze(data(1:2:(ds(1)-mod(ds(1),2)),:,:,:));
        %data2=squeeze(data(2:2:(ds(1)-mod(ds(1),2)),:,:,:));
        
        %phase_diff=data1 - data2;
        
     PHASE{n}=data(1:(size(data,1)-mod(size(data,1),2)),:,:);  
    end
 
phase_filt=squeeze(cutoffFilter(PHASE{1}(2,:,:), 1, 0, 1/50, 'bandstop', 2, 1));
read_filt=squeeze(cutoffFilter(PHASE{2}(2,:,:), 1, 0, 1/50, 'bandstop', 2, 1));
slice_filt=squeeze(cutoffFilter(PHASE{3}(2,:,:), 1, 0, 1/50, 'bandstop', 2, 1));

std_y=std(phase_filt(100:end-100,:));
std_x=std(read_filt(100:end-100,:)); 
std_z=std(slice_filt(100:end-100,:)); 

[a idx_y]=sort(std_y);
[a idx_x]=sort(std_x);
[a idx_z]=sort(std_z);

 ky=squeeze(PHASE{1}(1:2:end,:,idx_y(1:4)) - PHASE{1}(2:2:end,:,idx_y(1:4)));
 ky=squeeze(mean(ky,1));
 ky=squeeze(mean(ky,2));
 ky=ky(:);

kx=squeeze(PHASE{2}(1:2:end,:,idx_x(1:4)) - PHASE{2}(2:2:end,:,idx_x(1:4)));
kx=squeeze(mean(kx,1));
kx=squeeze(mean(kx,2));
kx=kx(:);

kz=squeeze(PHASE{3}(1:2:end,:,idx_z(1:4)) - PHASE{3}(2:2:end,:,idx_z(1:4)));
kz=squeeze(mean(kz,1));
kz=squeeze(mean(kz,2));
kz=kz(:);

% Trajectory is reoriented according to nuFFT-operator
K=[kx -ky -kz];
K=K/0.01;
K(:,1:2)=K(:,1:2)*fov/64;
K(:,3)=K(:,3)*fov/64;


figure; plot3(K(:,1),K(:,2),K(:,3),'.')
figure; plot(sqrt(abs(K(:,1)).^2 + abs(K(:,2)).^2  +abs(K(:,3)).^2 ))
 
end
    