function phasemaps=phasemaps(RefMeas)
%RefMeas must come as [Nx Ny Nz Ncoils Nechos]
%output is [Nx Ny Nz Nechos] and contains Nechos phasemaps (still as
%complex data)


dim=size(RefMeas);

%find max intensity coil for every pixel
idx=max_intensity_coils(RefMeas(:,:,:,:,1));
%pdiff_maps=angle( RefMeas(:,:,:,:,2)./RefMeas(:,:,:,:,1) );
phasemaps=complex(zeros(dim(1),dim(2),dim(3),dim(5)));
for k=1:dim(1)
    for l=1:dim(2)
        for m=1:dim(3)
            %for n=1:dim(5)
            %temp(:,n)=RefMeas(k,l,m,idx(k,l,m,1:5),n).*coeffs(k,l,m,1:5);
            %end
            phasemaps(k,l,m,:)=RefMeas(k,l,m,idx(k,l,m,1),:);
        end
    end
end

end
% END OF MAIN FUNCTION

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function idx=max_intensity_coils(cimages)
    
    [nx ny nz nc]=size(cimages);
%     coeff=zeros(size(cimages));
    idx=zeros(size(cimages));
    for k=1:nx
        for l=1:ny
            for m=1:nz
                [~, idx(k,l,m,:)]=sort(abs(cimages(k,l,m,:)),'descend');
%                 coeff(k,l,m,:)=coeff(k,l,m,:)./max(coeff(k,l,m,:));
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

