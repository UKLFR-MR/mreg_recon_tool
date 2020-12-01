function gendensX(opt,nb,fname)
%GENDENS Generate random samples.
%   GENDENS(OPT,NB,FNAME) generates random samples of 
%   length NB from a given density and stores the result
%   in a MAT-file of name FNAME.
%
%   OPT = 1, y = c1*exp(-128*((x-0.3).^2))-3*(abs(x-0.7).^0.4)
%   OPT = 2, y = c2*exp(-128*((x-0.3).^2))-1*(abs(x-0.7).^0.4)
%   OPT = 3, Gaussian density

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Jun-99.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

ingen = 1; %#ok<NASGU>
switch opt
  case 1
    x = linspace(0,1,max(3*nb,100)); 
    y = exp(-128*((x-0.3).^2))-3*(abs(x-0.7).^0.4); %#ok<NASGU>
    eval([fname, ' = genSIG(x,y,nb,ingen);'])

  case 2
    x = linspace(0,1,max(3*nb,100)); 
    y = exp(-128*((x-0.3).^2))-1*(abs(x-0.7).^0.4); %#ok<NASGU>
    eval([fname, ' = genSIG(x,y,nb,ingen);'])

  case 3
    eval([fname,' = randn(1,nb);'])

  otherwise
      msg = 'input argument must be 1,2 or 3';
      errargtX(mfilename,msg,'msg');
      error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
          'Invalid Input Argument.');
end
eval(['save ',fname,' ',fname])

%--------------------------------------------------
function sig = genSIG(x,y,nb,ingen) %#ok<DEFNU>

y = y -((y(end)-y(1))*x + y(1)) +  sqrt(eps);
d = y/sum(y);
r = randd(d,nb,ingen);
sig = x(r);
%--------------------------------------------------
function r = randd(proba,nb,ingen)

reps = sqrt(eps);
s = sum(proba);
if s<(1-reps) || s>(1+reps)
    msg = 'Invalid argument value for proba';
    errargtX(mfilename,msg,'msg');
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid Input Argument.');
end
n = length(proba);
q = cumsum(proba);
tab = [[0 q]' (0:n)'];
% Draw values from a random number stream equivalent to rand('state',ingen)
s = RandStream('swb2712','seed',ingen);
u = rand(s,nb,1);
r = 1 + fix(interp1(tab(:,1),tab(:,2),u));
%--------------------------------------------------


