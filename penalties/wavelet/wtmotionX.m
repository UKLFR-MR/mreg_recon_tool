function wtmotionX
%WTMOTION Wavelet Toolbox default WindowButtonMotionFcn.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Oct-98.
%   Last Revision: 07-Apr-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:46 $

fig = get(0,'PointerWindow');
if isempty(fig) || (fig==0) , return; end
figCurPt = get(fig,'CurrentPoint');
axeInFig = findobj(fig,'-depth',1,'type','axes','Visible','On');
nbAxes   = length(axeInFig);
pAx = get(axeInFig,'Position');
if nbAxes>1 ,  pAx = cat(1,pAx{:}); end

panInFig = findobj(fig,'type','uipanel','Visible','On');
axeInPan = findobj(panInFig,'-depth',1,'type','axes','Visible','On');
nbInPan = length(axeInPan);
if nbInPan>0
    par = get(axeInPan,'Parent');
    if nbInPan>1 , par = cat(1,par{:}); end
    posPan = get(par,'Position');
    if nbInPan>1 , posPan = cat(1,posPan{:}); end
    pAxInPan = get(axeInPan,'Position');
    if nbInPan>1 ,  pAxInPan = cat(1,pAxInPan{:}); end
    pAx(nbAxes+nbInPan,4) = 0;
    for k=1:nbInPan
        pAx(nbAxes+k,:) = [posPan(k,1:2) 0 0] + ...
            pAxInPan(k,:).*[posPan(k,3:4) posPan(k,3:4)];
    end
    nbAxes = nbAxes + nbInPan;
    axeInFig = [axeInFig;axeInPan];
end

indAxe = 0;
for k = 1:nbAxes
   xflag = (pAx(k,1)-figCurPt(1))*(pAx(k,1)+pAx(k,3)-figCurPt(1));
   yflag = (pAx(k,2)-figCurPt(2))*(pAx(k,2)+pAx(k,4)-figCurPt(2));
   if xflag<0 && yflag<0 , indAxe = k; break; end
end
pointer = 'arrow';
if indAxe~=0 
   selAxes = axeInFig(indAxe);
   lines   = findobj(selAxes,'type','line');
   nbLines = length(lines);
   if nbLines>0
       indLines = false(nbLines,1);
       for k = 1:nbLines
          indLines(k) = isappdata(lines(k),'selectPointer');
       end
       selLines = lines(indLines);
       nbLines  = length(selLines);
       if nbLines>0
           xlim   = get(selAxes,'Xlim');
           rx     = (figCurPt(1)-pAx(indAxe,1))/pAx(indAxe,3);
           xPoint = xlim(1)+rx*(xlim(2)-xlim(1));
           ylim   = get(selAxes,'Ylim');
           ry     = (figCurPt(2)-pAx(indAxe,2))/pAx(indAxe,4);
           yPoint = ylim(1)+ry*(ylim(2)-ylim(1));
           dx     = Inf;
           dy     = Inf;
           iLx    = 0;
           iLy    = 0;
           for k = 1:nbLines
             xd = get(selLines(k),'Xdata')-xPoint;
             yd = get(selLines(k),'Ydata')-yPoint;
             mx = min(abs(xd));
             my = min(abs(yd));
             if mx<dx , dx = mx; iLx = k; end
             if my<dy , dy = my; iLy = k; end
           end
           [xpix,ypix] = wfigutilX('xyprop',fig,1,1);
           tolx = 3*abs(xlim(2)-xlim(1))/(pAx(indAxe,3)/xpix);
           toly = 3*abs(ylim(2)-ylim(1))/(pAx(indAxe,4)/ypix);
           if iLx>0 && dx<tolx
               val = getappdata(selLines(iLx),'selectPointer');
               switch val
                 case 'H', pointer = 'uddrag';
                 case 'V', pointer = 'lrdrag';
               end
           elseif iLy>0 && dy<toly
               val = getappdata(selLines(iLy),'selectPointer');
               switch val
                 case 'H', pointer = 'uddrag';
                 case 'V', pointer = 'lrdrag';
               end
           end
       end
   end
end
setptr(fig,pointer);
% drawnow
