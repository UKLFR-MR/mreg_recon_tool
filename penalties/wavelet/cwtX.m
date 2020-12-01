function [coefs,varargout] = cwtX(SIG,scales,WAV,plotmode,xlim)
%CWT Real or Complex Continuous 1-D wavelet coefficients.
%   COEFS = CWT(S,SCALES,'wname') computes the continuous
%   wavelet coefficients of the vector S at real, positive
%   SCALES, using wavelet whose name is 'wname'.
%   The signal S is real, the wavelet can be real or complex. 
%
%   COEFS = CWT(S,SCALES,'wname','plot') computes
%   and, in addition, plots the continuous wavelet
%   transform coefficients.
%
%   COEFS = CWT(S,SCALES,'wname',PLOTMODE) computes and,
%   plots the continuous wavelet transform coefficients.
%   Coefficients are colored using PLOTMODE.
%   PLOTMODE = 'lvl' (By scale) or 
%   PLOTMODE = 'glb' (All scales) or
%   PLOTMODE = 'abslvl' or 'lvlabs' (Absolute value and By scale) or
%   PLOTMODE = 'absglb' or 'glbabs' (Absolute value and All scales)
%
%   CWT(...,'plot') is equivalent to CWT(...,'absglb')
%
%   You get 3-D plots (surfaces) using the same keywords listed
%   above for the PLOTMODE parameter, preceded by '3D'. For example:
%   COEFS = CWT(...,'3Dplot') or COEFS = CWT(...,'3Dlvl').
%
%   COEFS = CWT(S,SCALES,'wname',PLOTMODE,XLIM) computes, and
%   plots, the continuous wavelet transform coefficients.
%   Coefficients are colored using PLOTMODE and XLIM.
%   XLIM = [x1 x2] with 1 <= x1 < x2 <= length(S).
%
%   COEFS = CWT(...,'scal') or [COEFS,SC] = CWT(...,'scal') or
%   COEFS = CWT(...,'scalCNT') or [COEFS,SC] = CWT(...,'scalCNT') 
%   computes the continuous wavelet transform coefficients and 
%   the corresponding scalogram (percentage of energy for each 
%   coefficient). When PLOTMODE is equal to 'scal', a scaled 
%   image of scalogram is displayed and when PLOTMODE is equal to 
%   'scalCNT', a contour representation of scalogram is displayed.
%
%   For each given scale a within the vector SCALES, the  
%   wavelet coefficients C(a,b) are computed for b = 1 to
%   ls = length(S), and are stored in COEFS(i,:)
%   if a = SCALES(i). 
%   Output argument COEFS is a la-by-ls matrix where la is
%   the length of SCALES. COEFS is a real or complex matrix
%   depending on the wavelet type.
%
%   Examples of valid uses are:
%     t = linspace(-1,1,512);
%     s = 1-abs(t);
%     c = cwtX(s,1:32,'cgau4');
%     c = cwtX(s,[64 32 16:-2:2],'morl');
%     c = cwtX(s,[3 18 12.9 7 1.5],'db2');
%     c = cwtX(s,1:32,'sym2','lvl');
%     c = cwtX(s,1:64,'sym4','abslvl',[100 400]);
%     [c,Sc] = cwtX(s,1:64,'sym4','scal');
%     [c,Sc] = cwtX(s,1:64,'sym4','scalCNT');
%
%   See also WAVEDEC, WAVEFUN, WAVEINFO, WCODEMAT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 02-Apr-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Check scales.
%--------------
err = 0;
if isempty(scales) ,         err = 1;
elseif min(size(scales))>1 , err = 1;
elseif min(scales)<eps,      err = 1;
end
if err
    errargtX(mfilename,'Invalid Value for Scales !','msg');
    error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
        'Invalid Value for Scales !')
end

% Check signal.
%--------------
if isnumeric(SIG)
    val_SIG = SIG;
    lenSIG  = length(val_SIG);
    xSIG    = (1:lenSIG);
    stepSIG = 1;
    
elseif isstruct(SIG)
    try
        val_SIG = SIG.y;
    catch ME  %#ok<NASGU>
        err = 1;
    end
    if err~=1
        lenSIG = length(val_SIG);
        try
            xSIG = SIG.x; stepSIG = xSIG(2)-xSIG(1);
        catch ME  %#ok<NASGU>
            try
                stepSIG = SIG.step;
                xSIG = (0:stepSIG:(lenSIG-1)*stepSIG);
            catch ME  %#ok<NASGU>
                try
                    xlim = SIG.xlim;
                    xSIG = linspace(xlim(1),xlim(2),lenSIG);
                    stepSIG = xSIG(2)-xSIG(1);
                catch ME  %#ok<NASGU>
                    xSIG = (1:lenSIG); stepSIG = 1;
                end
            end
        end
    end
    
elseif iscell(SIG)
    val_SIG = SIG{1};
    xATTRB  = SIG{2};
    lenSIG  = length(val_SIG);
    len_xATTRB = length(xATTRB);
    if len_xATTRB==lenSIG
        xSIG = xATTRB; 
        stepSIG = xSIG(2)-xSIG(1);

    elseif len_xATTRB==2
        xlim = xATTRB;
        xSIG = linspace(xlim(1),xlim(2),lenSIG);
        stepSIG = xSIG(2)-xSIG(1);

    elseif len_xATTRB==1
        stepSIG = xATTRB;
        xSIG = (0:stepSIG:(lenSIG-1)*stepSIG);
    else
        xSIG = (1:length(SIG)); stepSIG = 1;
    end
else
    err = 1;
end
if err
    errargtX(mfilename,'Invalid Value for Signal !','msg');
    error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
        'Invalid Value for Signal !')
end

% Check wavelet.
%---------------
getINTEG = 1;
getWTYPE = 1;
if ischar(WAV)
    precis = 10; % precis = 15;
    [val_WAV,xWAV] = intwaveX(WAV,precis);
    stepWAV = xWAV(2)-xWAV(1);
    wtype = wavemngrX('type',WAV);
    if wtype==5 , val_WAV = conj(val_WAV); end
    getINTEG = 0;
    getWTYPE = 0;

elseif isnumeric(WAV)
    val_WAV = WAV;
    lenWAV  = length(val_WAV);
    xWAV = linspace(0,1,lenWAV);
    stepWAV = 1/(lenWAV-1);
    
elseif isstruct(WAV)
    try
        val_WAV = WAV.y; 
    catch ME  %#ok<NASGU>
        err = 1; 
    end
    if err~=1
        lenWAV = length(val_WAV);
        try
            xWAV = WAV.x; stepWAV = xWAV(2)-xWAV(1);
        catch ME  %#ok<NASGU>
            try
                stepWAV = WAV.step;
                xWAV = (0:stepWAV:(lenWAV-1)*stepWAV);
            catch ME  %#ok<NASGU>
                try
                    xlim = WAV.xlim;
                    xWAV = linspace(xlim(1),xlim(2),lenWAV);
                    stepWAV = xWAV(2)-xWAV(1);
                catch ME  %#ok<NASGU>
                    xWAV = (1:lenWAV); stepWAV = 1;
                end
            end
        end
    end
    
elseif iscell(WAV)
    if isnumeric(WAV{1})
        val_WAV = WAV{1};
    elseif ischar(WAV{1})
        precis  = 10;
        val_WAV = intwaveX(WAV{1},precis);
        wtype = wavemngrX('type',WAV{1});        
        getINTEG = 0;
        getWTYPE = 0;
    end
    xATTRB  = WAV{2};
    lenWAV  = length(val_WAV);
    len_xATTRB = length(xATTRB);
    if len_xATTRB==lenWAV
        xWAV = xATTRB; stepWAV = xWAV(2)-xWAV(1);

    elseif len_xATTRB==2
        xlim = xATTRB;
        xWAV = linspace(xlim(1),xlim(2),lenWAV);
        stepWAV = xWAV(2)-xWAV(1);

    elseif len_xATTRB==1
        stepWAV = xATTRB;
        xWAV = (0:stepWAV:(lenWAV-1)*stepWAV);
    else
        xWAV = linspace(0,1,lenWAV);
        stepWAV = 1/(lenWAV-1);
    end
end
if err
    errargtX(mfilename,'Invalid Value for Wavelet !','msg');
    error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
        'Invalid Value for Wavelet !')
end
xWAV = xWAV-xWAV(1);
xMaxWAV = xWAV(end);
if getWTYPE ,  wtype = 4; end
if getINTEG ,  val_WAV = stepWAV*cumsum(val_WAV); end

val_SIG   = val_SIG(:)';
nb_SCALES = length(scales);
coefs     = zeros(nb_SCALES,lenSIG);
ind  = 1;
for k = 1:nb_SCALES
    a = scales(k);
    a_SIG = a/stepSIG;
    j = 1+floor((0:a_SIG*xMaxWAV)/(a_SIG*stepWAV));     
    if length(j)==1 , j = [1 1]; end
    f            = fliplr(val_WAV(j));
    coefs(ind,:) = -sqrt(a)*wkeep1X(diff(wconv1X(val_SIG,f)),lenSIG);
    ind          = ind+1;
end

% Test for plots.
%----------------
if nargin<4 , return; end

% Display Continuous Analysis.
%-----------------------------
dummyCoefs = coefs;
NBC = 240;
if strmatch('3D',plotmode)
    dim_plot = '3D';
elseif strmatch('scal',plotmode)
    dim_plot = 'SC';    
else
    dim_plot = '2D';
end

if isequal(wtype,5)
   if ~isempty(findstr(plotmode,'lvl')) 
       plotmode = 'lvl';
   else
       plotmode = 'glb';   
   end
end
switch plotmode
  case {'lvl','3Dlvl'}
    lev_mode  = 'row';   abs_mode  = 0;   beg_title = 'By scale';

  case {'glb','3Dglb'}
    lev_mode  = 'mat';   abs_mode  = 0;   beg_title = '';

  case {'abslvl','lvlabs','3Dabslvl','3Dlvlabs'}
    lev_mode  = 'row';   abs_mode  = 1;    beg_title = 'Abs. and by scale';

  case {'absglb','glbabs','plot','2D','3Dabsglb','3Dglbabs','3Dplot','3D'}
    lev_mode  = 'mat';   abs_mode  = 1;   beg_title = 'Absolute';

  case {'scal','scalCNT'}
    lev_mode  = 'mat';   abs_mode  = 1;   beg_title = 'Absolute';
    
  otherwise
    plotmode  = 'absglb';
    lev_mode  = 'mat';   abs_mode  = 1;   beg_title = 'Absolute';
    dim_plot  = '2D';
end

if abs_mode , dummyCoefs = abs(dummyCoefs); end
if nargin==5 && ~isequal(plotmode,'scal') && ~isequal(plotmode,'scalCNT')
    if xlim(2)<xlim(1) , xlim = xlim([2 1]); end    
    if xlim(1)<1      , xlim(1) = 1;   end
    if xlim(2)>lenSIG , xlim(2) = lenSIG; end
    indices = xlim(1):xlim(2);
    switch plotmode
      case {'glb','absglb'}
        cmin = min(min(dummyCoefs(:,indices)));
        cmax = max(max(dummyCoefs(:,indices)));
        dummyCoefs(dummyCoefs<cmin) = cmin;
        dummyCoefs(dummyCoefs>cmax) = cmax;

      case {'lvl','abslvl'}
        cmin = min(dummyCoefs(:,indices),[],2);
        cmax = max(dummyCoefs(:,indices),[],2);
        for k=1:nb_SCALES
            ind = dummyCoefs(k,:)<cmin(k);
            dummyCoefs(k,ind) = cmin(k);
            ind = dummyCoefs(k,:)>cmax(k);
            dummyCoefs(k,ind) = cmax(k);
        end
    end
end

nb    = min(5,nb_SCALES);
level = '';
for k=1:nb , level = [level ' '  num2str(scales(k))]; end %#ok<AGROW>
if nb<nb_SCALES , level = [level ' ...']; end
nb     = ceil(nb_SCALES/20);
ytics  = 1:nb:nb_SCALES;
tmp    = scales(1:nb:nb*length(ytics));
ylabs  = num2str(tmp(:));
plotPARAMS = {NBC,lev_mode,abs_mode,ytics,ylabs,'',xSIG};

switch dim_plot
  case 'SC'
      switch plotmode
          case 'scal',     typePLOT = 'image';
          case 'scalCNT' , typePLOT = 'contour';
      end
      SC = wscalogramX(typePLOT,coefs,scales,SIG,xSIG);
      if nargout>1 , varargout{1} = SC; end
      
  case '2D'
    if wtype<5
        titleSTR = [beg_title ' Values of Ca,b Coefficients for a = ' level];
        plotPARAMS{6} = titleSTR;
        axeAct = gca;
        plotCOEFS(axeAct,dummyCoefs,plotPARAMS);
    else
        axeAct = subplot(2,2,1);
        titleSTR = ['Real part of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        plotCOEFS(axeAct,real(dummyCoefs),plotPARAMS);
        axeAct = subplot(2,2,2);
        titleSTR = ['Imaginary part of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        plotCOEFS(axeAct,imag(dummyCoefs),plotPARAMS);
        axeAct = subplot(2,2,3);
        titleSTR = ['Modulus of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        plotCOEFS(axeAct,abs(dummyCoefs),plotPARAMS);
        axeAct = subplot(2,2,4);
        titleSTR = ['Angle of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        plotCOEFS(axeAct,angle(dummyCoefs),plotPARAMS);
    end
    colormap(pink(NBC));

  case '3D'
    if wtype<5
        titleSTR = [beg_title ' Values of Ca,b Coefficients for a = ' level];
        plotPARAMS{6} = titleSTR;
        axeAct = gca;
        surfCOEFS(axeAct,dummyCoefs,plotPARAMS);
    else
        axeAct = subplot(2,2,1);
        titleSTR = ['Real part of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        surfCOEFS(axeAct,real(dummyCoefs),plotPARAMS);
        axeAct = subplot(2,2,2);
        titleSTR = ['Imaginary part of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        surfCOEFS(axeAct,imag(dummyCoefs),plotPARAMS);
        axeAct = subplot(2,2,3);
        titleSTR = ['Modulus of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        surfCOEFS(axeAct,abs(dummyCoefs),plotPARAMS);
        axeAct = subplot(2,2,4);
        titleSTR = ['Angle of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        surfCOEFS(axeAct,angle(dummyCoefs),plotPARAMS);
    end
end

%----------------------------------------------------------------------
function plotCOEFS(axeAct,coefs,plotPARAMS)

[NBC,lev_mode,abs_mode,ytics,ylabs,titleSTR] = deal(plotPARAMS{1:6});

coefs = wcodematX(coefs,NBC,lev_mode,abs_mode);
image(coefs);
set(axeAct, ...
        'YTick',ytics, ...
        'YTickLabel',ylabs, ...
        'YDir','normal', ...
        'Box','On' ...
        );
title(titleSTR,'Parent',axeAct);
xlabel('time (or space) b','Parent',axeAct);
ylabel('scales a','Parent',axeAct);
%----------------------------------------------------------------------
function surfCOEFS(axeAct,coefs,plotPARAMS)

[NBC,lev_mode,abs_mode,ytics,ylabs,titleSTR] = deal(plotPARAMS{1:6});

surf(coefs);
set(axeAct, ...
        'YTick',ytics, ...
        'YTickLabel',ylabs, ...
        'YDir','normal', ...
        'Box','On' ...
        );
title(titleSTR,'Parent',axeAct);
xlabel('time (or space) b','Parent',axeAct);
ylabel('scales a','Parent',axeAct);
zlabel('COEFS','Parent',axeAct);

xl = [1 size(coefs,2)];
yl = [1 size(coefs,1)];
zl = [min(min(coefs)) max(max(coefs))];
set(axeAct,'Xlim',xl,'Ylim',yl,'Zlim',zl,'view',[-30 40]);

colormap(pink(NBC));
shading('interp')
%----------------------------------------------------------------------
