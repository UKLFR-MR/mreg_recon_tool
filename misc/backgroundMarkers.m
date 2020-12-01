function backgroundMarkers(pos,width,c,ha)

if nargin<=1
    if rem(length(pos),2)==0
        width = pos(2:2:end)-pos(1:2:end);
        pos = pos(1:2:end);
    else
        error('If only one argument is used it must have an even number of elements.');
    end
end
if nargin<=2
    c = [0.85 0.85 1];
end
if nargin<=3
    ha = gca;
else
    axes(ha);
end

if length(width)==1
    width = repmat(width, [1 length(pos)]);
end

yl = ylim(ha);
hflag = ishold(ha);

hold on;

for k=1:length(pos)
    fill([pos(k) pos(k) pos(k)+width(k) pos(k)+width(k)],[yl(1) yl(2) yl(2) yl(1)],c,'EdgeColor','none','FaceAlpha',0);
end

if ~hflag
    hold off;
end