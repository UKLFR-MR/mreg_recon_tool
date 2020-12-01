Toolbox for reconstructing MREG data. Call mreg_recon_tool for starting the GUI.



Dependencies: 
You need the MIRT toolbox which you can download from 
http://web.eecs.umich.edu/~fessler/code/ 
Adhere to its readme and use the MIRT toolbox's setup.m for installation.

Nice to have: You don't really need the FSL Toolbox, but it's used to create nicer B0-maps that can be used for off-resonance correction. You can download it here:
http://fsl.fmr

Files that contain the remark "% Needs the toolbox of Benni Zahneisen" refer to the contents of the folder trajectories/common



For more details see manual_mreg_recon_tool.pdf

The folder 'psf' contains a sample of trajectory creation, and point spread function calculation, reproducing results from Riemenschneider et al., MRM, 2021.
The command mreg_recon_tool_noise_simulation opens a GUI that is identical to the mreg_recon_tool, but replaces every frame with kspace noise - to be used for the calculation of a g-factor simulation.



This toolbox works with Siemens data and uses the (included) mapVBVD tool from Philipp Ehses.
For the spirals in the creation of a spherical stack of spirals, modified code from Brian Hargreaves (mrsrl.stanford.edu/~brian/vdspiral/) is used.



Contributions to this toolbox have been made by:
Thimo Hugger
Benjamin Zahneisen
Jakob Assländer
Bruno Riemenschneider

