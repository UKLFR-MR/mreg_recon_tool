function A = getdec(t,option)
%GETDEC Get decomposition components.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 29-Dec-2006.
%   Copyright 1995-2006 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:55:34 $ 

tn  = leaves(t);
lev = treedpth(t);
d = read(t,'data',tn);

NA = 2^lev;
A  = d{1}/NA;
mA = max(abs(A(:)));
for k = 2:3:length(d)
    A = wkeep2(A,size(d{k}));
    A = [ A , normCFS(d{k},mA); normCFS(d{k+1},mA) , normCFS(d{k+2},mA) ];
end
%--------------------------------------
function Y = normCFS(X,mA,option)

mX = max(abs(X(:)));
if mX==0
    Y  = mA*ones(size(X)); 
else
    Y  = mA*(1-abs(X)/mX);
end
%--------------------------------------
