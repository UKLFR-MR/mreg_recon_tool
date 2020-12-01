function [recon,cmap]=adapt3D(im,donorm,bs)
%   Adaptive recon based on Walsh et al.
%   Walsh DO, Gmitro AF, Marcellin MW.
%   Adaptive reconstruction of phased array MR imagery.
%   Magn Reson Med. 2000 May;43(5):682-90.
%


im=permute(im,[4 1 2 3]);
[nc,ny,nx,nz]=size(im);

[mm,maxcoil]=max(sum(sum(sum(permute(abs(im),[4 3 2 1])))));   %find coil with maximum intensity
%for correcting the phase of all
%of the other coils.

if nargin<3
    bs=[4 4 4];
end

if nargin<2
    donorm=1;
end


bs1=bs(1);  %x-block size
bs2=bs(2);  %y-block size
bs3=bs(3);  %z-block size

%noise corrrelation matrix is always set to identity
rn=eye(nc);
irn=inv(rn);


wfull=zeros(nc,ny,nx,nz);
cmaps=zeros(nc,ny,nx,nz);

progresscounter('clear');
for x=1:nx
    for y=1:ny
        for z=1:nz
            
            ymin1=max([y-floor(bs1./2) 1]);                  %Collect block for calculation of
            xmin1=max([x-floor(bs2./2) 1]);                   %blockwise values.
            zmin1=max([z-floor(bs3./2) 1]);
            
            ymax1=min([y+floor(bs1./2) ny]);                 %Edges are cropped so the results
            xmax1=min([x+floor(bs2./2) nx]);                 %near the edges of the image could
            zmax1=min([z+floor(bs3./2) nz]);
            %be in error. Not normally a problem.
            %But watch out for aliased regions
            ly1=length(ymin1:ymax1);
            lx1=length(xmin1:xmax1);
            lz1=length(zmin1:zmax1);
            
            
            m1=reshape(im(:,ymin1:ymax1,xmin1:xmax1,zmin1:zmax1),nc,lx1*ly1*lz1);
            
            
            m=m1*m1';                                %Calculate signal covariance
            
            %[e,v]=eig(irn*m); %Eigenvector with max eigenval gives
            %the correct combination coeffs.
            
            [e,v]=eig(m);
            v=diag(v);
            [mv,ind]=max(v);
            
            mf=e(:,ind);
            mf=mf/(mf'*(mf));
            normmf=e(:,ind);
            
            mf=mf.*exp(-1i*angle(mf(maxcoil)));        %Correct phase based on coil with max intensity
            normmf=normmf.*exp(-1i*angle(normmf(maxcoil)));
            
            wfull(:,y,x,z)=mf;
            cmaps(:,y,x,z)=normmf;
            
            progresscounter(nx*ny*nz,'Adaptive sensitivity map estimation ... ');
        end
    end
end


recon=squeeze(sum(wfull.*im));   %Combine coil signals.

cmap=permute(cmaps,[2 3 4 1]);

if donorm
    recon=recon.*squeeze(sum(abs(cmap),4).^2);    %This is the normalization proposed in the abstract
    %referenced in the header.
end