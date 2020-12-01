% Main documented liftingX functions
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
%   laurpoly     - Constructor for the class LAURPOLY (Laurent Polynomial).
%
% Laurent Matrix [OBJECT in @laurmat directory]
%   laurmat      - Constructor for the class LAURMAT (Laurent Matrix).
%
% Demonstrations.
%   demolift    - Demonstrates Lifting functions in the Wavelet Toolbox.  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Full description of Lifting Directories                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Lifting directory (Main).
%==========================
%   readmeLIFT  - SOME COMMENTS about LIFTING FUNCTIONALITIES
%   ContentsX    - ContentsX for Wavelet Toolbox Lifting Tools.
%   demolift    - Demonstrates Lifting functions in the Wavelet Toolbox.  
%---+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--%
%   addliftX     - Adding primal or dual liftingX steps.
%   apmf2lsX     - Analyzis polyphase matrix factorization to liftingX scheme.
%   biorliftX    - Biorthogonal spline liftingX schemes.
%   bswfunX      - Biorthogonal scaling and wavelet functions.
%   cdfliftX     - Cohen-Daubechies-Feauveau liftingX schemes.
%   coifliftX    - Coiflets liftingX schemes.
%   dbliftX      - Daubechies liftingX schemes.
%   displmfX     - Display a Laurent matrices factorization.
%   displsX      - Display liftingX scheme.
%   errlsdecX    - Errors for liftingX scheme decompositions.
%   fact_and_lsX - Factorizations and liftingX schemes for wavelets.
%   filt2lsX     - Filters to liftingX scheme.
%   filters2lpX  - Filters to Laurent polynomials.
%   hlwtX        - Haar (Integer) Wavelet decomposition 1-D using liftingX.  # UD #
%   hlwt2X       - Haar (Integer) Wavelet decomposition 2-D using liftingX.  # UD #
%   ihlwtX       - Haar (Integer) Wavelet reconstruction 1-D using liftingX. # UD #
%   ihlwt2X      - Haar (Integer) Wavelet reconstruction 2-D using liftingX. # UD #
%   ilwtX        - Inverse 1-D lifted wavelet transform.
%   ilwt2X       - Inverse 2-D lifted wavelet transform.
%   inp2sqX      - In Place to "square" storage of coefficients.
%   isbiorwX     - True for a biorthogonal wavelet.
%   isorthwX     - True for an orthogonal wavelet.
%   liftfiltX    - Apply elementary liftingX steps on filters.
%   liftwaveX    - Lifting scheme for usual wavelets.
%   ls2apmfX     - Lifting scheme to analyzis polyphase matrix factorization.
%   ls2filtX     - Lifting scheme to filters.
%   ls2filtersX  - Lifting scheme to filters.
%   ls2lpX       - Lifting scheme to Laurent polynomials.
%   ls2pmfX      - Lifting scheme(s) to polyphase matrix factorization(s).
%   lsdualX      - Dual liftingX scheme.
%   lsinfoX      - Information about liftingX schemes.
%   lsupdateX    - Compute liftingX scheme update.
%   lwtX         - Wavelet decomposition 1-D using liftingX.
%   lwt2X        - Wavelet decomposition 2-D using liftingX.
%   lwtcoefX     - Extract or reconstruct 1-D LWT wavelet coefficients.
%   lwtcoef2X    - Extract or reconstruct 2-D LWT wavelet coefficients.
%   orfilen4X    - Orthogonal filters of length 4.
%   pmf2apmfX    - Polyphase matrix factorization to analyzis polyphase matrix 
%                 factorization.
%   pmf2lsX      - Polyphase matrix factorization(s) to liftingX scheme(s).
%   symliftX     - Symlets liftingX schemes.
%   show_etX     - Show table obtained by the Euclidean division algorithm.
%   tablseqX     - Equality test for liftingX schemes.
%   wave2lpX     - Laurent polynomial associated to a wavelet.
%   wave2lsX     - Lifting scheme associated to a wavelet.
%   wavenamesX   - Wavelet names information.
%   wavetypeX    - Wavelet type information.
%
% Laurent Matrix [OBJECT in @laurmat directory]
%=========================================
%   ctranspose  - Laurent matrix transpose (non-conjugate).
%   det         - Laurent matrix determinant.
%   disp        - Display a Laurent matrix object as text.
%   display     - Display function for LAURMAT objects.
%   eq          - Laurent matrix equality test.
%   isequal     - True if Laurent matrices are numerically equal.
%   laurmat     - Constructor for the class LAURMAT (Laurent Matrix).
%   mftable     - Matrix factorization table.
%   minus       - Laurent matrix subtraction.
%   mtimes      - Laurent matrix multiplication.
%   ne          - Laurent matrix inequality test.
%   newvar      - Change variable in a Laurent matrix.
%   plus        - Laurent matrix addition.
%   pm2ls       - Polyphase matrix to liftingX scheme(s).
%   prod        - Product of Laurent matrices.
%   reflect     - Reflection for a Laurent matrix.
%   subsasgn    - Subscripted assignment for Laurent matrix.
%   subsref     - Subscripted reference for Laurent matrix.
%   uminus      - Unary minus for Laurent matrix.
%
% Laurent Polynomial [OBJECT in @laurpoly directory]
%=============================================
%   degree      - Degree for Laurent polynomial.
%   disp        - Display a Laurent polynomial object as text.
%   display     - Display function for LAURPOLY objects.
%   dyaddownX    - Dyadic downsampling for a Laurent polynomial.
%   dyadupX      - Dyadic upsampling for a Laurent polynomial.
%   eo2lp       - Recover a Laurent polynomial from its even and odd parts.
%   eq          - Laurent polynomial equality test.
%   eucfacttab  - Euclidean factor table for Euclidean division algorithm.
%   euclidediv  - Euclidean Algorithm for Laurent polynomials.
%   euclidedivtab - Table obtained by the Euclidean division algorithm.
%   even        - Even part of a Laurent polynomial.
%   get         - Get LAURPOLY object field contents.
%   horzcat     - Horizontal concatenation of Laurent polynomials.
%   inline      - Construct an INLINE object associated to a Laurent polynomial.
%   isconst     - True for a constant Laurent polynomial.
%   isequal     - Laurent polynomials equality test.
%   ismonomial  - True for a monomial Laurent polynomial.
%   laurpoly    - Constructor for the class LAURPOLY (Laurent Polynomial).
%   lp2filters  - Laurent polynomials to filters.
%   lp2ls       - Laurent polynomial to liftingX schemes.
%   lp2num      - Coefficients of a Laurent polynomial object.
%   lpstr       - String to display a Laurent polynomial object.
%   makelift    - Make an elementary liftingX step.
%   minus       - Laurent polynomial subtraction.
%   mldivide    - Laurent polynomial matrix left division.
%   modmat      - Modulation matrix associated to two Laurent polynomials.
%   modulate    - Modulation for a Laurent polynomial.
%   mpower      - Laurent polynomial exponentiation.
%   mrdivide    - Laurent polynomial matrix right division.
%   mtimes      - Laurent polynomial multiplication.
%   ne          - Laurent polynomial inequality test.
%   newvar      - Change variable in a Laurent polynomial.
%   odd         - Odd part of a Laurent polynomial.
%   plus        - Laurent polynomial addition.
%   pnorm       - Pseudo-norm for a Laurent polynomial.
%   powers      - Powers of a Laurent polynomial.
%   ppm         - Polyphase matrix associated to two Laurent polynomials.
%   ppmfact     - Polyphase matrix factorizations.
%   praacond    - Perfect reconstruction and anti-aliasing conditions.
%   prod        - Product of Laurent polynomials.
%   reflect     - Reflection for a Laurent polynomial.
%   rescale     - Rescale Laurent polynomials.
%   sameswfplotX - Same BSWFUN and WAVEFUN plots.
%   uminus      - Unary minus for Laurent polynomial.
%   vertcat     - Vertical concatenation of Laurent polynomials.
%   wlift       - Make elementary liftingX steps.
%
% @laurpoly/private directory
%----------------------
%   reduce      - Simplification for Laurent polynomial.
%
% test directory
%===============
% Main directory tests
%   tlwtXilwtX    - Unit test for the function LWT.
%   tlwtXilwt2X   - Unit test for the function LWT2.
%   tls2filtersX - Unit test for the function LS2FILTERS.
%   tls2lpX      - Unit test for the function LS2LP.
%   tpmf2apmfX   - Unit test for the function PMF2APMF.
%   twave2lpX    - Unit test for the function WAVE2LP.
%---+--+--+--+--+--+--+--+--+--+--+--+--+--%
% Laurent Matrix object (LAURMAT)
%   tlm         - Unit test for LAURMAT (constructor in @LAURMAT).
%   tlm_ovr_m   - Unit test for LAURMAT object overloaded methods.
%   tlm_own_m   - Unit test for LAURMAT object own methods.
%---+--+--+--+--+--+--+--+--+--+--+--+--+--%
% Laurent Polynomial object (LAURPOLT)
%   tlp         - Unit test for LAURPOLY (constructor in @LAURPOLY).
%   tlp_ovr_m   - Unit test for LAURPOLY object overloaded methods.
%   tlp_own_m   - Unit test for LAURPOLY object own methods.
%   tlp_wlift   - Unit test for WLIFT.
%
%========================================================================%
%                UNDER DEVELOPMENT and TEMPORARY FILES                   %
%========================================================================%
%
% demo_and_misc/demo directory
%=============================
%   dem_1       - Demo 1 for  Lifting functions.
%   dem_2       - Demo 2 for  Lifting functions.         
%   dem_3       - Demo 3 for  Lifting functions.
%   dem_4       - Demo 4 for  Lifting functions.
%   dem_liftfiltX - Demonstrates liffilt function capabilities.
%   dem_wlift_1 - Demo 1 for WLIFT.
%   dem_wlift_2 - Demo 2 for WLIFT.
%   dem_wlift_3 - Demo 3 for WLIFT.
%   demoliftwav - Demonstrates Lifting functions in the Wavelet Toolbox.
%   wlift_str_util - String utilities for liftingX demos. 
%   make_wave    - Built Scaling function and Wavelet. 
%   view_dec     - Show Polyphase Matrix decompositions.
%
% demo_and_misc/misc directory
%=============================
%
% VARIOUS TESTS (some are which are also DEMOS)
%----------------------------------------------
%   t_lwtX_1     - Test liftingX decomposition and reconstruction (1-D).
%                 (TEST for functions LWT and ILWT).
%
%   t_lwtX_2     - Test liftingX decomposition and reconstruction (1-D).
%                 (TEST for the function LWTCOEF).
%
%   t_lwtX_2bis  - Test liftingX decomposition and reconstruction (1-D).
%                 (TEST for the function LWTCOEF).
%
%   t_lwtX_3     - Test liftingX decomposition and reconstruction (1-D).
%                 (GUI for thresholding).
%                 
%   t_lwtX_4     - Test liftingX decomposition and reconstruction (1-D).
%                 (GUI for thresholding).
%
%   t_lwt2X_1    - Test liftingX decomposition and reconstruction (2-D).
%                 (TEST for functions LWT2 and ILWT2).
%
%   t_lwt2X_2    - Test liftingX decomposition and reconstruction (2-D).
%                 (TEST for the function LWTCOEF2).
%
%   t_lwt2X_3    - Test liftingX decomposition and reconstruction (2-D).
%                 (GUI for thresholding).
%
%---------------
%   t_lwtX_dwtX_01 - Comparison between DWT and LWT (level 1).
%   t_lwtX_dwtX_db - Comparison between DWT and LWT (DB wavelets - level 1).
%   t_lwtX_dwtX_02 - Comparison between DWT and LWT coefficients (1-D).
%   t_lwtX_dwtX_03 - Comparison between DWT and LWT coefficients (2-D).
%---------------

% Last Revision: 06-May-2008
% Copyright 1995-2008 The MathWorks, Inc.
% Generated from ContentsX.m_template revision $Date: 2012/02/08 09:52:45 $
