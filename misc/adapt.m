function [recon,cmap]=adapt(im,donorm,rn)
%   Adaptive recon based on Walsh et al.
%   Walsh DO, Gmitro AF, Marcellin MW.
%   Adaptive reconstruction of phased array MR imagery. 
%   Magn Reson Med. 2000 May;43(5):682-90.
%
%    and
%
%   Mark Griswold, David Walsh, Robin Heidemann, Axel Haase, Peter Jakob. 
%   The Use of an Adaptive Reconstruction for Array Coil Sensitivity Mapping and Intensity Normalization, 
%   Proceedings of the Tenth  Scientific Meeting of the International Society for Magnetic Resonance in Medicine pg 2410 (2002)
%
%   IN:         im                 image to be reconstructed          (#coils, Ny, Nx)
%               donorm             flag determining whether to normalize image intensity    
%               rn                 input noise covariance matrix.     [#coils, #coils)  
%   
%   OUT:        recon              Reconstructed image                (Ny, Nx)    
%               cmap               "Coil maps"                        (# coils,  Ny, Nx) 
%
%   This non-optimized function will calculate adaptively estimated coil maps
%   based on the Walsh algorithm for use in either optimal combination of 
%   array images, or for parallel imaging applications. The donorm flag can be
%   used to include the normalization described in the abstract above. This is
%   only optimal for birdcage type arrays, but will work reasonably for many other geometries.
%   This normalization is only applied to the recon'd image, not the coil maps.
%
%   The rn matrix should be the noise covariances as decribed in Walsh et al.
%   This could also be a covariance of a region of distrubing artifact as 
%   described by Walsh et al.
%
%   The default block size is 4x4. One can also use interpolation to speed
%   up the calculation (see code), but this could cause some phase errors in practice.
%   Just pay attention to what you are doing.
%
%   Please read the license text at the bottom of this program. By using this program, you 
%   implicity agree with the license. 
%
%   The main points of the license:
%
%   1) This code is strictly for non-commercial applications. The code is protected by
%      multiple patents.
%   2) This code is strictly for research purposes, and should not be used in any
%      diagnostic setting.
%

%   10/1/2001  Mark Griswold
%   22/10/2004  MG - Updated help and changed interpolation to be more stable.

[nc,ny,nx]=size(im);

[mm,maxcoil]=max(sum(sum(permute(abs(im),[3 2 1]))));   %find coil with maximum intensity
                                                        %for correcting the phase of all 
                                                        %of the other coils.

if nargin<3
    rn=eye(nc);
end

if nargin<2
    donorm=0;
end


% bs1=4;  %x-block size
% bs2=4;  %y-block size

bs1=6;  %x-block size
bs2=6;  %y-block size
st=1;   %increase to set interpolation step size


wsmall=zeros(nc,round(ny./st),nx./st);
cmapsmall=zeros(nc,round(ny./st),nx./st);


for x=st:st:nx
   for y=st:st:ny

%       ymin1=max([y-bs1./2 1]);                  %Collect block for calculation of 
%       xmin1=max([x-bs2./2 1]);                  %blockwise values. 
% 
%       ymax1=min([y+bs1./2 ny]);                 %Edges are cropped so the results
%       xmax1=min([x+bs2./2 nx]);                 %near the edges of the image could 

      
      ymin1=max([y-floor(bs1./2) 1]);                  %Collect block for calculation of 
      xmin1=max([x-floor(bs2./2) 1]);                  %blockwise values. 

      ymax1=min([y+floor(bs1./2) ny]);                 %Edges are cropped so the results
      xmax1=min([x+floor(bs2./2) nx]);                 %near the edges of the image could 
                                                %be in error. Not normally a problem.
                                                %But watch out for aliased regions.
      
      ly1=length(ymin1:ymax1);
      lx1=length(xmin1:xmax1);

      
      m1=reshape(im(:,ymin1:ymax1,xmin1:xmax1),nc,lx1*ly1);
      
            
      m=m1*m1';                                %Calculate signal covariance
      
      [e,v]=eig(inv(rn)*m);                    %Eigenvector with max eigenval gives
                                               %the correct combination coeffs.
      v=diag(v);
      [mv,ind]=max(v);
      
      mf=e(:,ind);                      
      mf=mf/(mf'*inv(rn)*mf);               
      normmf=e(:,ind);
         
      mf=mf.*exp(-j*angle(mf(maxcoil)));        %Correct phase based on coil with max intensity
      normmf=normmf.*exp(-j*angle(normmf(maxcoil)));

      wsmall(:,y./st,x./st)=mf;
      cmapsmall(:,y./st,x./st)=normmf;
                    
    end
end

recon=zeros(ny,nx);


%Now have to interpolate these weights up to the full resolution. This is done separately for
%magnitude and phase in order to avoid 0 magnitude pixels between +1 and -1 pixels.

for i=1:nc
        wfull(i,:,:)=conj(imresize(squeeze(abs(wsmall(i,:,:))),[ny nx],'bilinear').*exp(j.*imresize(angle(squeeze(wsmall(i,:,:))),[ny nx],'nearest')));
        cmap(i,:,:)=imresize(squeeze(abs(cmapsmall(i,:,:))),[ny nx],'bilinear').*exp(j.*imresize(squeeze(angle(cmapsmall(i,:,:))),[ny nx],'nearest'));
end

recon=squeeze(sum(wfull.*im));   %Combine coil signals. 

if donorm
    recon=recon.*squeeze(sum(abs(cmap))).^2;    %This is the normalization proposed in the abstract 
                                                %referenced in the header.
end

% You should carefully read the following terms and conditions before installing or using the 
% software. Unless you have entered into a separate written license agreement with 
% Universit�t W�rzburg providing otherwise, installation or use of the software indicates your 
% agreement to be bound by these terms and conditions. 
% 
% Use of the software provided with this agreement constitutes your acceptance of these terms. 
% If you do NOT agree to the terms of this agreement, promptly remove the software together 
% with all copies from your computer. User's use of this software is conditioned upon compliance 
% by user with the terms of this agreement. 
% 
% Upon ordering, downloading, copying, installing or unencrypting any version of the software, you
% are reaffirming that you agree to be bound by the terms of this agreement. 
% 
% License to use 
% 
% Universit�t W�rzburg grants to you a limited, non-exclusive, non-transferable and non-assignable 
% license to install and use this software for research purposes. Use of this software for any 
% diagnostic imaging procedure is strictly forbidden.
% 
% License to distribute 
% 
% Please feel free to offer the non-commercial version of this software on any website, CD, or 
% bulletin board, demonstrate the non-commercial version of the software and its capabilities, or 
% give copies of the non-commercial version of the software to other potential users, so that others 
% may have the opportunity to obtain a copy for use in accordance with the license terms contained
% here. 
% 
% You agree you will only copy the non-commercial version of the software in whole with this 
% license and all delivered files, but not in part. 
% 
% Termination 
% 
% This license is effective until terminated. You may terminate it at any point by destroying 
% the software together with all copies of the software. 
% 
% If you have acquired a non-commercial version, the license granted herein shall automatically 
% terminate if you fail to comply with any term or condition of this Agreement. 
% 
% Also, Universit�t W�rzburg has the option to terminate any license granted herein if you fail 
% to comply with any term or condition of this Agreement. 
% 
% You agree upon such termination to destroy the software together with all copies of the software.
% 
% 
% Copyright 
% 
% The software is protected by copyright law. You acknowledge that no title to the intellectual 
% property in the software is transferred to you. You further acknowledge that title and full 
% ownership rights to the software will remain the exclusive property of Universit�t W�rzburg, 
% and you will not acquire any rights to the software except as expressly set forth in this 
% license. You agree that any copies of the software will contain the same proprietary notices 
% which appear on and in the software. 
% 
% Rent, lease, loan 
% 
% You may NOT rent, lease or loan the software without first negotiating a specific license
% for that purpose with Universit�t W�rzburg. 
%     
% No warranties 
% 
% Universit�t W�rzburg does NOT warrant that the software is error free. Universit�t W�rzburg 
% disclaims all warranties with respect to the software, either express or implied, including 
% but not limited to implied warranties of merchantability, fitness for a particular purpose and 
% noninfringement of third party rights. The software is provided "AS IS." 
% 
% No liability for consequential damages 
% 
% In no event will Universit�t W�rzburg be liable for any loss of profits, business, use, or data 
% or for any consequential, special, incidental or indirect damages of any kind arising out of 
% the delivery or performance or as a result of using or modifying the software, even if 
% Universit�t W�rzburg has been advised of the possibility of such damages. In no event will 
% Universit�t W�rzburg's liability for any claim, whether in contract, negligence, tort or any 
% other theory of liability, exceed the license fee paid by you, if any. 
% The licensed software is not designed for use in high-risk activities requiring fail-safe 
% performance. Universit�t W�rzburg disclaims any express or implied warranty of fitness for 
% high-risk activities. 
% 
% Severability 
% 
% In the event of invalidity of any provision of this license, the parties agree that such 
% invalidity shall not affect the validity of the remaining portions of this license.
% 
