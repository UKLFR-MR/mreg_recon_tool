function R=arbRot(alpha,v)
 %returns rotation matrix R for arbitrary rotation around axes v
 if nargin < 2
     v = [0 0 1]; %rotation around z-axis as default
 end
 
 v=v/sqrt(v(1).*v(1) + v(2).*v(2) + v(3).*v(3));
    R = [cos(alpha)+v(1).*v(1).*(1-cos(alpha)), v(1).*v(2).*(1-cos(alpha))-v(3).*sin(alpha), v(1).*v(3).*(1-cos(alpha))+v(2).*sin(alpha);...
        v(2).*v(1).*(1-cos(alpha))+v(3).*sin(alpha), cos(alpha)+v(2).*v(2).*(1-cos(alpha)), v(2).*v(3).*(1-cos(alpha))-v(1).*sin(alpha);...
        v(3).*v(1).*(1-cos(alpha))-v(2).*sin(alpha), v(3).*v(2).*(1-cos(alpha))+v(1).*sin(alpha), cos(alpha)+v(3).*v(3)*(1-cos(alpha))];
 end