function xl = xtight(ha)

if nargin==0
    ha = gca;
else
    axes(ha);
end

limits = objbounds(findall(ha));
xl = limits(1:2);

set(gca,'XLim',xl);
