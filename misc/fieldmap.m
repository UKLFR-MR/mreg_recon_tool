function wmap = fieldmap(pdiff_map,maske,sos,delta_te)
%returns unwrapped wmap is [radians/sec]
%delta_te must be in [s]

% [status fsl_dir]=unix('echo $FSLDIR');
old_dir=pwd;
fsl_dir = getenv('FSLDIR');
if isempty(fsl_dir)
    fsl_dir='/home/extern/asslaend/Documents/MATLAB/fsl';
    % set FSLDIR
    setenv('FSLDIR',fsl_dir);
end

% call fsl.sh
cd(fullfile(fsl_dir,'etc','fslconf'));
unix('. fsl.sh');
fsl_bin=fullfile(fsl_dir,'bin');
setenv('PATH', [getenv('PATH') ':' fsl_bin]);
setenv('FSLOUTPUTTYPE','NIFTI');
cd(old_dir);

save_nii(make_nii(sos.*maske),'MagImage.nii');
save_nii(make_nii(pdiff_map.*maske),'pmap1.nii');

status=unix([fsl_bin '/prelude -a MagImage.nii -p pmap1.nii -o pmap1_unwrp.nii']);

pdiff_map = load_nii('pmap1_unwrp.nii');
status=unix('rm MagImage.nii pmap1.nii pmap1_unwrp.nii');

wmap=pdiff_map.img/(delta_te);




