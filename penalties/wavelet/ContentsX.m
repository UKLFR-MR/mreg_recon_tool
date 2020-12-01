% Wavelet Toolbox
% Version 4.5 (R2010a) 25-Jan-2010
%
% Wavelet Toolbox GUI (Graphical User Interface).
%   wavemenuX    - Start Wavelet Toolbox graphical user interface tools.
%
% Wavelets: General.
%   biorfiltX    - Biorthogonal wavelet filter set.
%   centfrqX     - Wavelet center frequency.
%   dyaddownX    - Dyadic downsampling.
%   dyadupX      - Dyadic upsampling.
%   intwaveX     - Integrate wavelet function psi.
%   orthfiltX    - Orthogonal wavelet filter set.
%   qmfX         - Quadrature mirror filter.
%   scal2frqX    - Scale to frequency.
%   wavefunX     - Wavelet and scaling functions.
%   wavefun2X    - Wavelets and scaling functions 2-D.
%   wavemngrX    - Wavelet manager. 
%   wfiltersX    - Wavelet filters.
%   wmaxlevX     - Maximum wavelet decomposition level.
%   wscalogramX  - Scalogram for continuous wavelet transform.
%
% Wavelet Families.
%   biorwavfX    - Biorthogonal spline wavelet filters.
%   cgauwavfX    - Complex Gaussian wavelet.
%   cmorwavfX    - Complex Morlet wavelet.
%   coifwavfX    - Coiflet wavelet filter.
%   dbauxX       - Daubechies wavelet filter computation.
%   dbwavfX      - Daubechies wavelet filters.
%   fbspwavfX    - Complex Frequency B-Spline wavelet.
%   gauswavfX    - Gaussian wavelet.
%   mexihatX     - Mexican Hat wavelet.
%   meyerX       - Meyer wavelet.
%   meyerauxX    - Meyer wavelet auxiliary function.
%   morletX      - Morlet wavelet.
%   rbiowavfX    - Reverse Biorthogonal spline wavelet filters.
%   shanwavfX    - Complex Shannon wavelet.
%   symauxX      - Symlet wavelet filter computation.
%   symwavfX     - Symlet wavelet filter.
%
% Continuous Wavelet: One-Dimensional.
%   cwtX         - Real or Complex Continuous 1-D wavelet coefficients.
%   cwtextX      - Real or Complex Continuous 1-D wavelet coefficients using
%                 extension parameters.
%   pat2cwavX    - Construction of a wavelet starting from a pattern.
%
% Discrete Wavelets: One-Dimensional.
%   appcoefX     - Extract 1-D approximation coefficients.
%   detcoefX     - Extract 1-D detail coefficients.
%   dwtX         - Single-level discrete 1-D wavelet transform.
%   dwtmodeX     - Discrete wavelet transform extension mode.
%   idwtX        - Single-level inverse discrete 1-D wavelet transform.
%   upcoefX      - Direct reconstruction from 1-D wavelet coefficients.
%   upwlevX      - Single-level reconstruction of 1-D wavelet decomposition.
%   wavedecX     - Multi-level 1-D wavelet decomposition.
%   waverecX     - Multi-level 1-D wavelet reconstruction.
%   wenergyX     - Energy for 1-D wavelet decomposition.
%   wrcoefX      - Reconstruct single branch from 1-D wavelet coefficients.
%
% Discrete Wavelets: Two-Dimensional.
%   appcoef2X    - Extract 2-D approximation coefficients.
%   detcoef2X    - Extract 2-D detail coefficients.
%   dwt2X        - Single-level discrete 2-D wavelet transform.
%   dwtmodeX     - Discrete wavelet transform extension mode.
%   idwt2X       - Single-level inverse discrete 2-D wavelet transform.
%   upcoef2X     - Direct reconstruction from 2-D wavelet coefficients.
%   upwlev2X     - Single-level reconstruction of 2-D wavelet decomposition.
%   wavedec2X    - Multi-level 2-D wavelet decomposition.
%   waverec2X    - Multi-level 2-D wavelet reconstruction.
%   wenergy2X    - Energy for 2-D wavelet decomposition.
%   wrcoef2X     - Reconstruct single branch from 2-D wavelet coefficients.
%
% Discrete Wavelets: Three-Dimensional.
%   dwt3X        - Single-level discrete 3-D wavelet transform.
%   dwtmodeX     - Discrete wavelet transform extension mode.
%   idwt3X       - Single-level inverse discrete 2-D wavelet transform.
%   wavedec3X    - Multi-level 3-D wavelet decomposition.
%   waverec3X    - Multi-level 3-D wavelet reconstruction.
%
% Wavelets Packets Algorithms.
%   bestlevt    - Best level tree (wavelet packet).
%   besttree    - Best tree (wavelet packet).
%   entrupd     - Entropy update (wavelet packet).
%   wenergyX     - Energy for a wavelet packet decomposition.
%   wentropyX    - Entropy (wavelet packet).
%   wp2wtree    - Extract wavelet tree from wavelet packet tree.
%   wpcoef      - Wavelet packet coefficients.
%   wpcutree    - Cut wavelet packet tree.
%   wpdecX       - Wavelet packet decomposition 1-D.
%   wpdec2X      - Wavelet packet decomposition 2-D.
%   wpfunX       - Wavelet packet functions.
%   wpjoin      - Recompose wavelet packet.
%   wprcoef     - Reconstruct wavelet packet coefficients.
%   wprec       - Wavelet packet reconstruction 1-D. 
%   wprec2      - Wavelet packet reconstruction 2-D.
%   wpsplt      - Split (decompose) wavelet packet.
%
% Discrete Stationary Wavelet Transform Algorithms.
%   iswtX        - Inverse discrete stationary wavelet transform 1-D.
%   iswt2X       - Inverse discrete stationary wavelet transform 2-D.
%   swtX         - Discrete stationary wavelet transform 1-D.
%   swt2X        - Discrete stationary wavelet transform 2-D.
%
% Non-Decimated Wavelet Transform Algorithms.
%   indwtX        - Inverse non-decimated wavelet transform 1-D.
%   indwt2X       - Inverse non-decimated wavelet transform 2-D.
%   ndwtX         - Non-decimated wavelet transform 1-D.
%   ndwt2X        - Non-decimated  wavelet transform 2-D.
%
% Multisignal Wavelet Analysis: One-Dimensional.
%   chgwdeccfs  - Change Multisignal 1-D decomposition coefficients.
%   mdwtXdec     - Multisignal 1-D wavelet decomposition. 
%   mdwtXrec     - Multisignal 1-D wavelet reconstruction. 
%   mswcmp      - Multisignal 1-D compression using wavelets. 
%   mswcmpscrX   - Multisignal 1-D wavelet compression scores.
%   mswcmptp    - Multisignal 1-D compression thresholds and performances.
%   mswdenX      - Multisignal 1-D denoising using wavelets. 
%   mswthreshX   - Performs Multisignal 1-D thresholding. 
%   wdecenergy  - Multisignal 1-D decomposition energy repartition. 
%   wmspca      - Multiscale principal component analysis. 
%   wmulden     - Wavelet multivariate 1-D denoising. 
%
% Lifting Functions
%   addliftX     - Adding primal or dual liftingX steps.
%   bswfunX      - Biorthogonal scaling and wavelet functions.
%   displsX      - Display liftingX scheme.
%   filt2lsX     - Filters to liftingX scheme.
%   ilwtX        - Inverse 1-D liftingX wavelet transform.
%   ilwt2X       - Inverse 2-D liftingX wavelet transform.
%   liftfiltX    - Apply elementary liftingX steps on filters.
%   liftwaveX    - Lifting scheme for usual wavelets.
%   lsinfoX      - Information about liftingX schemes.
%   lwtX         - Lifting wavelet decomposition 1-D.
%   lwt2X        - Lifting wavelet decomposition 2-D.
%   lwtcoefX     - Extract or reconstruct 1-D LWT wavelet coefficients.
%   lwtcoef2X    - Extract or reconstruct 2-D LWT wavelet coefficients.
%   wave2lpX     - Laurent polynomial associated to a wavelet.
%   wavenamesX   - Wavelet names information.
%
% Laurent Polynomial [OBJECT in @laurpoly directory]
%   laurpoly    - Constructor for the class LAURPOLY (Laurent Polynomial).
%
% Laurent Matrix [OBJECT in @laurmat directory]
%   laurmat     - Constructor for the class LAURMAT (Laurent Matrix).
%
% De-noising and Compression for Signals and Images.
%   cmddenoiseX  - Command line interval dependent denoising.
%   ddencmpX     - Default values for de-noising or compression.
%   thselectX    - Threshold selection for de-noising.
%   wbmpenX      - Penalized threshold for wavelet 1-D or 2-D de-noising.
%   wdcbmX       - Thresholds for wavelet 1-D using Birge-Massart strategy.
%   wdcbm2X      - Thresholds for wavelet 2-D using Birge-Massart strategy.
%   wdenX        - Automatic 1-D de-noising using wavelets.
%   wdencmpX     - De-noising or compression using wavelets.
%   wnoiseX      - Generate noisy wavelet test data.
%   wnoisestX    - Estimate noise of 1-D wavelet coefficients.
%   wpbmpenX     - Penalized threshold for wavelet packet de-noising.
%   wpdencmpX    - De-noising or compression using wavelet packets.
%   wpthcoef    - Wavelet packet coefficients thresholding.
%   wthcoefX     - Wavelet coefficient thresholding 1-D.
%   wthcoef2X    - Wavelet coefficient thresholding 2-D.
%   wthreshX     - Perform soft or hard thresholding.
%   wthrmngrX    - Threshold settings manager.
%
% Other Wavelet Applications.
%   wfbmX        - Synthesize fractional Brownian motion.
%   wfbmestiX    - Estimate fractal index.
%   wfusimgX     - Fusion of two images.
%   wfusmatX     - Fusion of two matrices or arrays.
%
% Tree Management Utilities.
%   allnodesX    - Tree nodes.
%   cfs2wptX     - Wavelet packet tree construction from coefficients.
%   depo2indX    - Node depth-position to node index.
%   disp        - Display information of WPTREE object.
%   drawtreeX    - Draw wavelet packet decomposition tree (GUI).
%   dtree       - Constructor for the class DTREE.
%   get         - Get tree object field contents.
%   ind2depoX    - Node index to node depth-position.
%   isnodeX      - True for existing node.
%   istnodeX     - Determine indices of terminal nodes.
%   leavesX      - Determine terminal nodes.
%   nodeascX     - Node ascendants.
%   nodedescX    - Node descendants.
%   nodejoin    - Recompose node.
%   nodeparX     - Node parent.
%   nodesplt    - Split (decompose) node.
%   noleavesX    - Determine nonterminal nodes.
%   ntnodeX      - Number of terminal nodes.
%   ntree       - Constructor for the class NTREE.
%   plot        - Plot tree object.
%   read        - Read values in tree object fields.
%   readtreeX    - Read wavelet packet decomposition tree from a figure.
%   set         - Set tree object field contents.
%   tnodesX      - Determine terminal nodes (obsolete - use LEAVES).
%   treedpthX    - Tree depth.
%   treeordX     - Tree order.
%   wptree      - Constructor for the class WPTREE.
%   wpviewcf    - Plot wavelet packets colored coefficients.
%   write       - Write values in tree object fields.
%   wtbo        - Constructor for the class WTBO.
%   wtreemgr    - NTREE object manager.
%
% General Utilities.
%   localmaxX    - Compute local maxima positions.   
%   wcodematX    - Extended pseudocolor matrix scaling.
%   wextendX     - Extend a Vector or a Matrix.
%   wkeepX       - Keep part of a vector or a matrix.
%   wrevX        - Flip vector.
%   wtbxmngrX    - Wavelet Toolbox manager.
%
% Other.
%   wvarchgX     - Find variance change points.
%
% Wavelets Information.
%   waveinfoX    - Information on wavelets.
%   waveletfamiliesX - Wavelet families and families members. 
%
% Demonstrations.
%   wavedemo    - Wavelet Toolbox demos.
%   demolift    - Demonstrates Lifting functions in the Wavelet Toolbox.  
%
% See also WAVEDEMO.

% Last Revision: 12-Oct-2009.
% Copyright 1995-2010 The MathWorks, Inc.
% Generated from ContentsX.m_template revision 1.42.4.9 $Date: 2012/02/08 09:52:45 $



