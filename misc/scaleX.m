function scaleX(hf,l)

if nargin<=1
    l = 2;
end
if nargin==0 || isempty(hf)
    hf = gcf;
end

ha = get(hf,'CurrentAxes');

set(ha,'Units',get(hf,'Units'));

pf = get(hf,'Position');
pa = get(ha,'Position');

new_width_f = l*pf(3);
new_width_a = l*pa(3);
new_x_a = l*pa(1);

set(hf,'Position',[pf(1)-new_width_f/2 pf(2) new_width_f pf(4)]);
set(ha,'Position',[new_x_a pa(2) new_width_a pa(4)]);
