function LS = liftwaveX(wname,flag) %#ok<INUSD>
%LIFTWAVE Lifting scheme for usual wavelets.
%   LS = LIFTWAVE(WNAME) returns the liftingX scheme 
%   associated to the wavelet specified by WNAME.
%
%   LS = LIFTWAVE(WNAME,'Int2Int') allows to perform an
%   integer to integer wavelet transform.
%
%   The valid values for WNAME are:
%      'lazy'
%      'haar', 
%      'db1', 'db2', 'db3', 'db4', 'db5', 'db6', 'db7', 'db8'
%      'sym2', 'sym3', 'sym4', 'sym5', 'sym6', 'sym7', 'sym8'
%      Cohen-Daubechies-Feauveau wavelets:
%         'cdf1.1','cdf1.3','cdf1.5' - 'cdf2.2','cdf2.4','cdf2.6'
%         'cdf3.1','cdf3.3','cdf3.5' - 'cdf4.2','cdf4.4','cdf4.6'
%         'cdf5.1','cdf5.3','cdf5.5' - 'cdf6.2','cdf6.4','cdf6.6'
%      'biorX.Y' , see WAVEINFO
%      'rbioX.Y' , see WAVEINFO
%      'bs3'  : identical to 'cdf4.2'
%      'rbs3' : reverse of 'bs3'
%      '9.7'  : identical to 'bior4.4' 
%      'r9.7' : reverse of '9.7'
%
%      Note:
%        'cdfX.Y' == 'biorX.Y' except for bior4.4 and bior5.5.
%        'rbioX.Y'  is the reverse of 'biorX.Y'
%        'haar' == 'db1' == 'bior1.1' == 'cdf1.1'
%        'db2'  == 'sym2'  and  'db3' == 'sym4'  
%
%   For more information about liftingX schemes type: lsinfoX.

%      -------------------------------------------------------
%      'db1INT' : Non-normalized integer Haar transform
%      -------------------------------------------------------

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Feb-2000.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Check arguments.
tw = wavetypeX(wname);
if isequal(lower(tw),'unknown')
    error('Wavelet:FunctionArgVal:Invalid_WavName',...
        'Invalid wavelet name.');
end

% Get liftingX structure.
if isequal(wname,'haar') , wname = 'db1'; end

errNAME = false;
switch wname
	case 'lazy' , LS = {1, 1 , []};         % lazy wavelet
	case 'bs3'  , LS = liftwaveX('cdf4.2');  % cubic B-spline
        
    case 'rbs3' ,
        LS = liftwaveX('bs3');
        LS(end-1:-1:1,:) = LS(1:end-1,:);
        
	case '9.7' , LS = liftwaveX('bior4.4');  % Quasi-Symmetric wavelet.
        
	case 'r9.7'
        LS = liftwaveX('9.7');
        LS(end-1:-1:1,:) = LS(1:end-1,:);
        
    otherwise       
		switch wname(1)
          case 'b' , LS = biorliftX(wname);  % Biorthogonal wavelets
          case 'c' ,
              switch wname(2)
                case 'd' , LS = cdfliftX(wname);   % C.D.F. wavelets
                case 'o' , LS = coifliftX(wname);  % Coiflets.
                otherwise , errNAME = true;
              end
          case 'd' , LS = dbliftX(wname);    % Daubechies wavelets
          case 's' , LS = symliftX(wname);   % Symmetric wavelets
          case 'r' ,  % Reverse biorthogonal wavelets
              switch wname(2)
                case 'b' ,
                    wname(1:4) = 'bior';
                    LS = biorliftX(wname); % Reverse biorthogonal wavelets
                case 'c' , 
                    wname(1:3) = 'cdf';
                    LS = cdfliftX(wname);   % C.D.F. wavelets
                otherwise , errNAME = true;
              end
              LS = lsdualX(LS);
          otherwise , errNAME = true;
		end
end
if errNAME
    error('Wavelet:FunctionArgVal:Invalid_WavName',...
        'Invalid wavelet name.');
end
if nargin>1 , LS{end,3} = 'I'; end
