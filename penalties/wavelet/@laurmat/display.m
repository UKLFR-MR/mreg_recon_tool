function display(M)
%DISPLAY Display function for LAURMAT objects.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2001.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:54:03 $ 

% Use the "DISP" method if it exits.
varName = inputname(1);
disp(M,varName);
