function S = wscalogramX(typePLOT,coefs,varargin)
%WSCALOGRAM Scalogram for continuous wavelet transform.
%   SC = WSCALOGRAM(TYPEPLOT,COEFS) computes the scalogram 
%   SC (percentage of energy for each coefficient). COEFS is
%   the matrix of continuous wavelet coefficients (see CWT).
%   The scalogram is obtained by computing:
%       S = abs(coefs.*coefs); SC = 100*S./sum(S(:))
%  
%   When typePLOT is equal to 'image', a scaled image of
%   scalogram is displayed, when TYPEPLOT is equal to 'contour', 
%   a contour representation of scalogram is displayed.
%   Otherwise the scalogram is returned without plot 
%   representation. 
%
%   SC = WSCALOGRAM(...,'PropNAME',PropVAL,...)
%   Available values for 'PropNAME' are: 
%       - 'scales': scales used for CWT
%       - 'ydata':  signal used for CWT 
%       - 'xdata':  x values corresponding to signal
%       - 'power':  (positive) real value
%   
%   The default value for 'power' is zero. if power>0,
%   the coefficients are normalized: 
%       coefs(k,:) = coefs(k,:)/(scales(k)^power)
%   then the scalogram is computed as explained above.
%
%   Examples of valid uses are:
%     wname = 'mexh';
%     scales = (1:128);
%     load cuspamax
%     signal = cuspamax;
%     coefs = cwtX(signal,scales,wname);
%     figure; SCimg = wscalogramX('image',coefs);
%     figure; SCcnt = wscalogramX('contour',coefs);
%     figure; SCimg = wscalogramX('image',coefs,'scales',scales,'ydata',signal);
%     figure; SCcnt = wscalogramX('contour',coefs,'scales',scales,'ydata',signal);
%
%   See also CWT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 16-Jan-2007.
%   Last Revision: 12-Sep-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Check arguments.
nbIN = nargin;
error(nargchk(2,10,nbIN));
nb_SCALES = size(coefs,1);
nbIN = nbIN-2;
flagSIG = false;
flagXDATA = false;
power = 0;
scales = 1:nb_SCALES;

if nbIN>0
    firstIN = nbIN+1;
    if isnumeric(varargin{1})
        scales = varargin{1};
        if nbIN>1
            if isnumeric(varargin{2})
                SIG = varargin{2};
                flagSIG = true;
                if nbIN>2
                    if isnumeric(varargin{3})
                        xSIG = varargin{3};
                        flagXDATA = true;
                        if nbIN>3
                            if isnumeric(varargin{4})
                                power = varargin{4};
                            else
                                firstIN = 4;
                            end
                        end
                    else
                        firstIN = 3;
                    end
                end
            else
                firstIN = 2;
            end
        end
    else
        firstIN = 1;
    end
    for k = firstIN:2:nbIN
        argNAM = varargin{k};
        switch argNAM
            case 'scales' , scales = varargin{k+1};
            case 'ydata'  ,  SIG = varargin{k+1}; flagSIG = true;
            case 'xdata'  ,  xSIG = varargin{k+1}; flagXDATA = true;
            case 'power'  ,  power = varargin{k+1}; 
        end
    end
end
if flagSIG && ~flagXDATA , xSIG = 1:length(SIG); end

% Compute scalogram.
if power>0;
    for k=1:size(coefs,1)
        coefs(k,:) = coefs(k,:)/scales(k)^power;
    end
end
S = abs(coefs.*coefs);
S = 100*S./sum(S(:));

switch typePLOT
    case {'image','contour','surface'}
    otherwise , return;
end

% Plot scalogram.
if flagSIG
    axeAct = subplot(4,1,1);
    plot(xSIG,SIG,'r','Parent',axeAct);
    title(xlate('Analyzed Signal'),'Parent',axeAct);
    set(axeAct,'Xlim',[xSIG(1) xSIG(end)]);
    pos_axeAct = get(axeAct,'Position');
    pos_axeAct(2) = 0.1; 
    pos_axeAct(4) = 3.2*pos_axeAct(4);
    axeAct = axes('Position',pos_axeAct);
else
    axeAct = subplot(1,1,1);
    pos_axeAct = get(axeAct,'Position');
    pos_axeAct(4) = 0.95*pos_axeAct(4);
    set(axeAct,'Position',pos_axeAct);
end

nb     = ceil(nb_SCALES/20);
ytics  = 1:nb:nb_SCALES;
tmp    = scales(1:nb:nb*length(ytics));
ylabs  = num2str(tmp(:));
if flagSIG , xdata = xSIG; else xdata = 1:size(coefs,2); end
switch typePLOT
    case 'image'   , imagesc(S,'Xdata',xdata);
    case 'contour' , contour(S,'Xdata',xdata);
    case 'surface' , surf(S); shading interp; axis tight
end
set(axeAct, ...
        'YTick',ytics, ...
        'YTickLabel',ylabs, ...
        'YDir','normal', ...
        'Box','On' ...
        );
titleSTR = ...
    sprintf('Scalogram \nPercentage of energy for each wavelet coefficient');  
title(titleSTR,'Parent',axeAct);
xlabel(xlate('Time (or Space) b'),'Parent',axeAct);
ylabel(xlate('Scales a'),'Parent',axeAct);
pos = get(axeAct,'Position');
pos(1) = pos(1)+pos(3)+0.025;
pos(3) = 0.02;
colorbar('peer',axeAct,'EastOutside','FontSize',8,'Position',pos);
