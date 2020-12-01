function trajectStruct_export(T,filename, isVD)
% exports trajectory structure to scanner readable text file
% if T is an array of trajectories, the elements are stored in one text
% file and the number of elements is stored in the header

if nargin < 3 
    isVD = 0;
end

if nargin <2
    filename ='arb_gradient.grad';
end

if length(filename) <=7 || ~strcmp(filename(end-4:end), '.grad')
    filename = [filename, '.grad'];
end

%dwell is set to a fixed value; must be decreased for higher resolution
dwell = 5000; %[ns]

total_samples=length(T)*size(T(1).G,1);
element_samples = size(T(1).G,1);

if ~trajectStruct_check(T(1))==1;
    return;
end


%% All segments must have equal length; if not pad with zeros
points_max=0;
for k=1:length(T)
    points_max=max(points_max,size(T(k).G,1)); 
end

for k=1:length(T)
    if size(T(k).K,1) < points_max
        T(k) = trajectStruct_zeroFill(T(k),points_max - size(T(k).K,1));
    end
end

%% check if index file is provided
Index=zeros(2,16);
for n=1:length(T)
    if ~isfield(T(n),'index') || isempty(T(n).index)
        Index(1,n)=1;
        Index(2,n)=element_samples;
    else
        Index(1,n)=T(n).index(1);
        Index(2,n)=T(n).index(2);
    end
end        


%% get all gradients
for n=1:length(T)
    G(n,:,:)=1000*T(n).G; %because G comes in T/m and has to be mT/m
end

%maximum gradient amplitude
gmax=max(abs(G(:)));

% normalized gradient
G_norm= G/gmax;


%open text file
fid=fopen(filename,'w+');

    %text must be one word
    if isVD
        fprintf(fid,'##GradientFileHeader## \n');
    end
    fprintf(fid,'Number_of_Samples %g \n',total_samples);
    fprintf(fid,'Maximum_Gradient_Amplitude_[mT/m] %g \n',gmax);
    fprintf(fid,'Number_of_Elements %g \n',length(T));
    fprintf(fid,'Element_length %g \n',element_samples);
    %FOV comes in [m] must be exported as [mm]
    if isVD
%        fprintf(fid,'Field_Of_View_[mm] %g %g %g \n',1000*T(1).fov(1),1000*T(1).fov(2),1000*T(1).fov(3));
        fprintf(fid,'Field_Of_View_[mm] %g %g %g \n',1000*T(1).fov(1),1000*T(1).fov(1),1000*T(1).fov(1));
    else
        fprintf(fid,'Field_Of_View_[mm] %g \n',1000*T(1).fov);
    end
    fprintf(fid,'Base_Resolution %g %g %g\n',T(1).N);
    fprintf(fid,'TE_[micros] %g \n',T(1).TE);
    fprintf(fid,'Dwell_[ns] %g \n',dwell);
    if isVD
        fprintf(fid,'##EndOfHeader## \n');
    end
    for n=1:16
        fprintf(fid,['index',num2str(n),'_start %g \n'],Index(1,n));
        fprintf(fid,['index',num2str(n),'_end %g \n'],Index(2,n));
    end
    if isVD
        fprintf(fid,'##EndOfIndices## \n');
    end    
    for n=1:length(T)
        for k=1:element_samples
            fprintf(fid, '%1.4f %1.4f %1.4f \n', G_norm(n,k,:));
        end
    end

    fclose(fid);
end


    
    
