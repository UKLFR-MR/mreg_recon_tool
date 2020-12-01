function [sx,sy] = cw1dcoorX(x,y,axe,in4)
%CW1DCOOR Continuous wavelet 1-D coordinates.
%   [SX,SY] = CW1DCOOR(X,Y,AXE,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 01-May-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $

% MB2.
%-----
n_coefs_sca = 'Coefs_Scales';
% ind_coefs   = 1;
ind_scales  = 2;
ind_frequencies = 3;
ind_sca_OR_frq = 4;
% nb2_stored  = 4;

sx = ['X = ' , wstrcoorX(x,5,7)];
i_axe = find(axe==in4,1);
if ~isempty(i_axe)
  fig = get(axe,'Parent');
  idx = wmemtoolX('rmb',fig,n_coefs_sca,ind_sca_OR_frq);
  infos = wmemtoolX('rmb',fig,n_coefs_sca,idx);
  len = length(infos);
  if (len>0) && (1<=y) && (y<=len)
      y = round(y);
	  t = num2str(infos(y));
      switch idx
        case ind_scales     , sy = ['Sca = ' t];
        case ind_frequencies , sy = ['Frq = ' t];
      end
	  sy = sy(1:min(11,length(sy)));
  else
      sy = ['Y = ' , wstrcoorX(y,5,7)];
  end
else
    sy = ['Y = ' , wstrcoorX(y,5,7)];
end
