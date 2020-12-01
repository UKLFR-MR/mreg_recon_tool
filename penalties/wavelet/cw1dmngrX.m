function varargout = cw1dmngrX(option,fig,varargin)
%CW1DMNGR Continuous wavelet 1-D drawing manager.
%   CW1DMNGR(OPTION,WIN_CW1DTOOL,IN3)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 29-Aug-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Default values.
%----------------
max_lev_anal = 12;
default_nbcolors = 128;

% Memory bloc of stored values.
%==============================
% MB0.
%-----
n_InfoInit   = 'InfoInit';
ind_filename = 1;
ind_pathname = 2;
% nb0_stored   = 2;

% MB1.
%-----
n_param_anal   = 'Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
% ind_lev_anal   = 4;
ind_act_option = 5;
% ind_gra_area   = 6;
% nb1_stored     = 6;

% MB2.
%-----
n_coefs_sca    = 'Coefs_Scales';
ind_coefs      = 1;
ind_scales     = 2;
ind_frequencies = 3;
ind_sca_OR_frq = 4;
% nb2_stored     = 4;

% Handles of objects.
%====================
handles  = wfigmngrX('getValue',fig,'CW1D_handles');
toolATTR = wfigmngrX('getValue',fig,'ToolSettings');
toolMode = toolATTR.Mod;

% UIC.
%-----
hdl_UIC = handles.hdl_UIC;
 
% AXES.
%------
hdl_Re_AXES = handles.hdl_Re_AXES;
hdl_Im_AXES = [];

% MENUS.
%-------
men_SAV_EXP = handles.hdl_MEN([2 5]);


% Separate Real and Complex tools.
%---------------------------------
switch toolMode
  case {'real'}
    hdl_Im_AXES = [];
    dummy = struct2cell(hdl_UIC);
    [...
     fra_sam , txt_sam , edi_sam , ...
     fra_sca , txt_sca , pop_sca , ...
     pus_ana ,                     ...
     txt_min , edi_min ,           ...
     txt_stp , edi_stp ,           ...
     txt_max , edi_max ,           ...
     txt_pow , pop_pow ,           ...
     txt_msc , edi_msc ,           ...
     pus_lin , pus_ref ,           ...
     fra_axe , txt_axe ,           ...
     chk_DEC , chk_LC  , chk_LML , ...
     rad_SCA , rad_FRQ ,           ...
     fra_ccm , txt_ccm , pop_ccm   ...
                                      ] = deal(dummy{:});
  
  case {'abs','arg','all'}
    hdl_Im_AXES = handles.hdl_Im_AXES;
    dummy = struct2cell(hdl_UIC);
    [...
     fra_sam , txt_sam , edi_sam , ...
     fra_sca , txt_sca , pop_sca , ...
     pus_ana ,                     ...
     txt_min , edi_min ,           ...
     txt_stp , edi_stp ,           ...
     txt_max , edi_max ,           ...
     txt_pow , pop_pow ,           ...
     txt_msc , edi_msc ,           ...
     pus_lin , pus_ref ,           ...
     fra_axe , txt_axe ,           ...
     rad_MOD , rad_ANG , rad_ALL,  ...
     chk_DEC , chk_LC  , chk_LML , ...
     rad_SCA , rad_FRQ ,           ...
     fra_ccm , txt_ccm , pop_ccm   ...
                                      ] = deal(dummy{:});
end
chk_for_AXES = [chk_DEC,chk_LC,chk_LML];

switch option
    case 'plotSignal'
      sig_Anal = varargin{1};
      cw1dutilX('plotSignal',fig, ...
          hdl_Re_AXES(1),sig_Anal,hdl_Re_AXES(1:4));
      if ~isequal(toolMode,'real')
           cw1dutilX('plotSignal',fig, ...
              hdl_Im_AXES(1),sig_Anal,hdl_Im_AXES(1:4));
      end

    case 'setSamPer'
      delta = wstr2numX(get(edi_sam,'String'));
      err = isempty(delta);
      if ~err , err = delta<eps; end
      if ~err
          wav_Name = wmemtoolX('rmb',fig,n_param_anal,ind_wav_name);
          scales   = wmemtoolX('rmb',fig,n_coefs_sca,ind_scales);
          frequencies = scal2frqX(scales,wav_Name,delta);
          wmemtoolX('wmb',fig,n_coefs_sca,ind_frequencies,frequencies);
          cw1dmngrX('newCfsLine',fig);
      else
          set(edi_sam,'String',get(edi_sam,'Userdata'));
      end

    case 'newScaleMode'
      new_mode = get(pop_sca,'Value');
      old_mode = get(pop_sca,'Userdata');
      if new_mode==old_mode ,  return; end
      set(pop_sca,'Userdata',new_mode);

      Y_Spacing = mextglobX('get','Y_Spacing');
      win_units = get(fig,'units');
      if strcmp(win_units,'pixels')
          dy = Y_Spacing;
      else
          [dx,dy] = wfigutilX('prop_size',fig,1,Y_Spacing);
      end
      p12 = get(pus_ana,'Position');
      switch new_mode
        case 1
          hdl_of = [txt_pow pop_pow txt_msc edi_msc];
          hdl_on = [txt_min,edi_min,txt_stp,edi_stp,txt_max,edi_max];
          p2 = get(edi_max,'Position');

        case 2
          hdl_of = [txt_min,edi_min,txt_stp,edi_stp,txt_max,edi_max,...
                    txt_msc,edi_msc];
          hdl_on = [txt_pow,pop_pow];
          p2 = get(pop_pow,'Position');

        case 3
          hdl_of = [txt_min,edi_min,txt_stp,edi_stp,txt_max,edi_max,...
                    txt_pow,pop_pow];
          hdl_on = [txt_msc,edi_msc];
          p2 = get(edi_msc,'Position');
      end
      pos_fra_sca = get(fra_sca,'Position');
      pos_txt_sca = get(txt_sca,'Position');
      pos_fra_sca(2) = p2(2)-dy;
      pos_fra_sca(4) = pos_txt_sca(2)+pos_txt_sca(4)/2-pos_fra_sca(2);
      hdl_move = [fra_sca,pus_ana];
      set([hdl_of , hdl_move],'Visible','off');
      if isequal(toolMode,'real') , deltaY = 4*dy; else deltaY = 3*dy; end
      p12(2) = p2(2)-p12(4)-deltaY;
      set(fra_sca,'Position',pos_fra_sca);
      set(pus_ana,'Position',p12);
      set([hdl_on,hdl_move],'Visible','on');

    case 'newCfsLine'
      switch toolMode
        case {'real'}
          vis = lower(get(hdl_Re_AXES(3),'Visible'));
          if isequal(vis,'off') , return; end
          axeLIN = hdl_Re_AXES([2 4]);

        case {'abs','arg','all'}
          visRe = lower(get(hdl_Re_AXES(3),'Visible'));
          visIm = lower(get(hdl_Im_AXES(3),'Visible'));
          if isequal(visRe,'off') && isequal(visIm,'off'), return; end
          axeLIN = [hdl_Re_AXES([2 4]) ; hdl_Im_AXES([2 4])];
      end
      scales = wmemtoolX('rmb',fig,n_coefs_sca,ind_scales);
      if isempty(varargin)
          lHor = mngmbtnX('getLines',fig,'Hor');
          if isempty(lHor) , return; end

          par = find(axeLIN==get(lHor,'Parent'),1);
          if isempty(par) , return; end
 
          ind_sca = get(lHor,'Ydata');
          ind_sca = round(ind_sca(1));
      else
          ind_sca = round(length(scales)/2);
      end
      [coefs,frequencies] = wmemtoolX('rmb',fig,n_coefs_sca, ...
                                          ind_coefs,ind_frequencies);
      if (ind_sca<=0) || (ind_sca>size(coefs,1)) , return; end
      scale = scales(ind_sca);
      freq  = frequencies(ind_sca);
      coefs = coefs(ind_sca,:);      
      toolATTR.Sca = scale;
      toolATTR.Frq = freq;
      wfigmngrX('storeValue',fig,'ToolSettings',toolATTR);
      linTitles = cw1dutilX('cfsLineTitle',fig);
      switch toolMode
        case {'real'}          
          cw1dutilX('plotCfsLine',fig,hdl_Re_AXES(3),coefs,linTitles{1});

        case {'abs','arg','all'}
          cw1dutilX('plotCfsLine',fig,hdl_Re_AXES(3),abs(coefs),linTitles{1});
          cw1dutilX('plotCfsLine',fig,hdl_Im_AXES(3),angle(coefs),linTitles{2});
      end

    case 'newChainLine'
      switch toolMode
        case {'real'}
          vis = lower(get(hdl_Re_AXES(4),'Visible'));
          if isequal(vis,'off') , return; end
          axeLIN = hdl_Re_AXES([2 4]);

        case {'abs','arg','all'}
          visRe = lower(get(hdl_Re_AXES(4),'Visible'));
          visIm = lower(get(hdl_Im_AXES(4),'Visible'));
          if isequal(visRe,'off') && isequal(visIm,'off'), return; end
          axeLIN = [hdl_Re_AXES([2 4]) ; hdl_Im_AXES([2 4])];
      end
	  
      if isempty(varargin)
          lHor = mngmbtnX('getLines',fig,'Hor');
          if isempty(lHor) , return; end
          par = find(axeLIN==get(lHor,'Parent'),1);
          if isempty(par) , return; end
		  yInd = get(lHor,'Ydata');
          yInd = round(yInd(1));		  
      else
          yInd = [];
      end

	  % Begin waiting.
      %----------------
      wwaitingX('msg',fig,'Wait ... computing');

	  set(pus_ref,'enable','Off');
	  [coefs,scales] = wmemtoolX('rmb',fig,n_coefs_sca, ...
                                      ind_coefs,ind_scales);
      nbRow  = size(coefs,1);
	  if isempty(yInd) , yInd = nbRow; end;
      indBeg = nbRow;
      if (0<yInd) && (yInd<=nbRow)
          indBeg = yInd;
          coefs(yInd+1:end,:) = 0;
      end
      switch toolMode
        case 'real'
          [coefs,strTitle] = cw1dutilX('computeChainLine',fig, ...
                                   scales,coefs,indBeg);
          cw1dutilX('plotChainLine',fig,hdl_Re_AXES(4),scales,coefs,strTitle);
                     
        otherwise
          [tmpCoefs,strTitle] = cw1dutilX('computeChainLine',fig, ...
                                    scales,abs(coefs),indBeg);
          cw1dutilX('plotChainLine',fig,hdl_Re_AXES(4),scales,tmpCoefs,strTitle);
          [tmpCoefs,strTitle] = cw1dutilX('computeChainLine',fig, ...
                                    scales,angle(coefs),indBeg);
          cw1dutilX('plotChainLine',fig,hdl_Im_AXES(4),scales,tmpCoefs,strTitle);
      end

      % End waiting.
      %-------------
      wwaitingX('off',fig);
    
    case 'setPosAxes'
      % Axes Visibility.
      %-----------------
      % 1 1 1 1 ;
      % 1 1 1 0 ;
      % 1 1 0 1 ;
      % 1 0 1 1 ;
      % 1 1 0 0 ;
      % 1 0 1 0 ;
      % 1 0 0 1 ;
      % 1 0 0 0 ;
      %------------
      if ~isempty(varargin) , newTITLE = 1; else newTITLE = 0; end
      vis = toolATTR.Vis;
      pos = toolATTR.Pos;
      vis = vis(:,2:end);
      flgDEC = get(chk_DEC,'Value');
      flgLC  = get(chk_LC ,'Value');
      flgLML = get(chk_LML,'Value');
      flgVIS = [flgDEC,flgLC,flgLML];

	  [flag_lin,flag_ref,hdl_axe] = cw1dmngrX('get_Ena_Flag',fig);
	  
      if flgLC && flgDEC && flag_lin , ena_lin = 'on'; else ena_lin = 'off'; end
	  if flgLML && flag_ref , ena_ref = 'on'; else ena_ref = 'off'; end  
	  set(pus_lin,'enable',ena_lin);
	  set(pus_ref,'enable',ena_ref);
      ind = 0;
      for k = 1:size(vis,1)
         ok = isequal(vis(k,:),flgVIS);
         if ok , ind = k; break; end
      end
      toolATTR.Num = ind;
      wfigmngrX('storeValue',fig,'ToolSettings',toolATTR);

	  % Set View Axes Btn.
	  %-------------------
	  if (ind==8 ) && ~isequal(toolMode,'all')
		  ena_zaxe = 'Off';
	  else
		  ena_zaxe = 'On';
	  end
	  dynvtoolX('dynvzaxeX_BtnOnOff',fig,ena_zaxe);

      pos = pos(:,:,ind);
      vis = getonoffX([1,flgVIS,flgDEC]);
      switch toolMode
        case 'real'
          hdl_OFF = []; hdl_ON = hdl_Re_AXES; indTitle = 1;

        case 'abs'
          hdl_OFF = hdl_Im_AXES; hdl_ON = hdl_Re_AXES; indTitle = 1;
		  if ~isempty(find(hdl_OFF==hdl_axe,1))
			  set([pus_lin,pus_ref],'Enable','Off');
		  end
		  
	    case 'arg' 
          hdl_OFF = hdl_Re_AXES; hdl_ON = hdl_Im_AXES; indTitle = 2;
		  if ~isempty(find(hdl_OFF==hdl_axe,1))
			  set([pus_lin,pus_ref],'Enable','Off');
		  end

        case 'all'
         hdl_OFF = [];
         hdl_ON  = [hdl_Re_AXES,hdl_Im_AXES];
         indTitle = [1 2];
         pos(:,:,2) = pos;
         bdx   = pos(1,1,1);
         w_axe = pos(1,3,1)/2-bdx;
         pos(1:4,3,1:2) = w_axe;
         pos(1:4,1,2)   = bdx+w_axe+2*bdx;
      end
      set(wfindobjX([hdl_OFF;hdl_ON]),'Visible','off')

      if newTITLE
          cfsTitles = cw1dutilX('cfsColorTitle',fig,toolMode,pop_ccm);
          linTitles = cw1dutilX('cfsLineTitle',fig);
          for j = 1:size(hdl_ON,2)
              k = indTitle(j);
              wtitleX(cfsTitles{k},'Parent',hdl_ON(2,j),'Visible','off');
              wtitleX(linTitles{k},'Parent',hdl_ON(3,j),'Visible','off');
          end
      end
      
      for k = 1:4
        for j = 1:size(hdl_ON,2)
            hdl_IN = wfindobjX(hdl_ON(k,j));
            set(hdl_ON(k,j),'Position',pos(k,:,j))
            set(hdl_IN,'Visible',vis(k,:))
        end
      end      
      for k = 5
          hdl_IN = wfindobjX(hdl_Re_AXES(k));
          set(hdl_Re_AXES(k),'Position',pos(k,:,1))
          set(hdl_IN,'Visible',vis(k,:))
      end

    case 'setPosAxesIMAG'
      if isempty(varargin)
          rad_SEL = gcbo;
          paramSET = {fig,'dummy'};
      else
          rad_SEL = varargin{1};
          paramSET = {fig};
      end       
      rad_OLD = wfindobjX([rad_MOD,rad_ANG,rad_ALL],'Userdata',1);
      set([rad_MOD,rad_ANG,rad_ALL],'Value',0,'Userdata',[]);
      set(rad_SEL,'Value',1,'Userdata',1);
      if isequal(rad_SEL,rad_OLD) , return; end
      toolATTR = wfigmngrX('getValue',fig,'ToolSettings');
      indMOD = find(rad_SEL==[rad_MOD,rad_ANG,rad_ALL]);
      switch indMOD
        case 1 , toolATTR.Mod = 'abs';
        case 2 , toolATTR.Mod = 'arg';
        case 3 , toolATTR.Mod = 'all';        
      end
      wfigmngrX('storeValue',fig,'ToolSettings',toolATTR);
      cw1dmngrX('setPosAxes',paramSET{:});    

    case 'sca_OR_frq'
      rad_SEL = gcbo;
      rad_OLD = wfindobjX([rad_SCA,rad_FRQ],'Userdata',1);
      set([rad_SCA,rad_FRQ],'Value',0,'Userdata',[]);
      set(rad_SEL,'Value',1,'Userdata',1);
      if isequal(rad_SEL,rad_OLD) , return; end
      if isequal(rad_SEL,rad_SCA)
          sca_OR_frq = ind_scales;
      else
          sca_OR_frq = ind_frequencies;
      end
      wmemtoolX('wmb',fig,n_coefs_sca,ind_sca_OR_frq,sca_OR_frq);
      mngmbtnX('cleanXYPos',fig);

    case 'getScales'
      % Getting  Analysis parameters.
      %------------------------------
      [sig_Name,wav_Name,sig_Size] = ...
          wmemtoolX('rmb',fig,n_param_anal, ...
                         ind_sig_name,ind_wav_name,ind_sig_size);
      powmax = fix(log(sig_Size)/log(2));
      scamax = 2^(powmax-1);
      sca_mod = get(pop_sca,'Value');
      col_mod = get(pop_ccm,'Value');
      set(pop_ccm,'Userdata',col_mod);
      err = 0;
      switch sca_mod
        case 1
          mi = wstr2numX(get(edi_min,'String'));
          st = wstr2numX(get(edi_stp,'String'));
          ma = wstr2numX(get(edi_max,'String'));
          if     isempty(st) , st = 1; err = 1;
          elseif st<=0       , st = 1; err = 1;
          end
          if     isempty(mi) , mi = 1; err = 1;
          elseif mi<sqrt(eps), mi = 1; err = 1;
          end
          if     isempty(ma) , ma = min(32,scamax); err = 1;
          elseif ma>scamax   , ma = min(32,scamax); err = 1;
          end
          if ma<mi
              if     ma<sqrt(eps) , ma = mi;   err = 1;
              elseif mi>scamax    , mi = ma;   err = 1;
              else
                  tmp = mi; mi = ma; ma = tmp; err = 1;
              end
          end
          if err==1
              set(edi_min,'String',num2str(mi));
              set(edi_stp,'String',num2str(st));
              set(edi_max,'String',num2str(ma));
              col = get(edi_min,'ForegroundColor');
              for k=1:10
                  set([edi_min,edi_stp,edi_max],'ForegroundColor','r');
                  pause(0.5);
                  set([edi_min,edi_stp,edi_max],'ForegroundColor',col);
              end
              err = 0;
          end
          level  = [ '[' num2str(mi) ':' num2str(st) ':' num2str(ma) ']'];
          scales = eval(level);

        case 2
          powmax = get(pop_pow,'Value');
          scales = 2.^(1:powmax);

        case 3
          level = get(edi_msc,'String');
          try
              levs = eval(level);
          catch %#ok<CTCH>
              err = 1;
          end
          if err==1
              set(edi_msc,'String',xlate('Error ...'));
              col = get(edi_msc,'ForegroundColor');
              set(edi_msc,'ForegroundColor','r');
              pause(2)
              set(edi_msc,'String','[ ]');
              set(edi_msc,'ForegroundColor',col);
              varargout = {err,[],[]};
              return
          end
          levs = levs(:)';
          scales = levs(levs>0);
          scales = scales(scales<=scamax);
          if ~isequal(levs,scales) , err = 1; end
          if err==1
              old_txt = get(edi_msc,'String');
              set(edi_msc,'String',xlate('Warning ...'));
              col = get(edi_msc,'ForegroundColor');
              for k=1:10
                  set(edi_msc,'ForegroundColor','r');
                  pause(0.50);
                  set(edi_msc,'ForegroundColor',col);
              end
              set(edi_msc,'String',old_txt);
              err = 0;
          end
      end
      delta = wstr2numX(get(edi_sam,'String'));
      frequencies = scal2frqX(scales,wav_Name,delta);
      err = (err | isempty(scales));
      if ~err , set(pop_ccm,'Userdata',-1); end
      varargout = {err,scales,frequencies};

    case 'computeCoefs'
      sig_Anal = varargin{1};
      scales   = varargin{2};
      wav_Name = varargin{3};
      %----------------------
      txt_msg = wwaitingX('handle',fig);
      dynvtoolX('hide',fig);
      drawnow
      precis   = 10;
      len      = length(sig_Anal);
      nbscales = length(scales);
      varargout{1} = zeros(nbscales,len);
      wtype = wavemngrX('type',wav_Name);
      numALG   = 1;
      switch numALG
        case 1
          [psi,psi_xval] = intwaveX(wav_Name,precis);
          % if wtype==5 , psi = conj(psi); end
          psi_xval = psi_xval-psi_xval(1);
          dxval = psi_xval(2);
          xmax  = psi_xval(length(psi_xval));
          ind   = 1;
          for a = scales
              msg ={' ',sprintf('Computing - scale a = %5.3f',a)};
              set(txt_msg,'String',msg);
              drawnow
              j = 1+floor((0:a*xmax)/(a*dxval));
              if length(j)==1 , j = [1 1]; end
              f = fliplr(psi(j));
              varargout{1}(ind,:) = -sqrt(a)*wkeep1X(diff(conv(sig_Anal,f)),len);
              ind = ind+1;
          end
        case 2        
          switch wtype
            case {1,3} , [A,psi,psi_xval] = wavefunX(wav_Name,precis);
            case 2     , [A,psi,A,A,psi_xval] = wavefunX(wav_Name,precis);
            case {4,5} , [psi,psi_xval] = wavefunX(wav_Name,precis);
          end
          % if wtype==5 , psi = conj(psi); end
          psi_xval = psi_xval-psi_xval(1);
          dxval = psi_xval(2);
          xmax  = psi_xval(end);
          ind   = 1;
          for a = scales
              msg = {' ',sprintf('Computing - scale a = %5.3f',a)};
              set(txt_msg,'String',msg);
              drawnow
              j = 1 + floor((0:a*xmax)/(a*dxval));
              if length(j)==1 , j = [1 1]; end
              f = fliplr(psi(j));
              varargout{1}(ind,:) = wkeep1X(conv(sig_Anal,f),len);
              ind = ind+1;
          end
      end
      set(txt_msg,'String','');
      dynvtoolX('show',fig);

    case 'computeCoefsMNGR'
      sig_Anal = wtbxappdataX('get',fig,'sig_Anal');

      % Getting scales and frequencies.
      %-------------------------------
      [err,scales,frequencies] = cw1dmngrX('getScales',fig);
      if err , return; end

      % Setting Dynamic Visualization tool.
      %------------------------------------
      mngmbtnX('delLines',fig,'All');

      % Setting Axes.
      %--------------
      sig_Size = length(sig_Anal);
      NB_Img  = size(scales,2);
      xValMin = 1;
      xValMax = sig_Size;
      axeProp = {...
          'Drawmode','fast',         ...
          'Layer','top',             ...
          'Ydir','reverse',          ...
          'Xlim',[xValMin xValMax],  ...
          'Ylim',[0.5 NB_Img+0.5],   ...
          'YTicklabelMode','manual', ...
          'YTick',[],                ...
          'YTicklabel',[],           ...
          'Box','On',                ...
          'XGrid','Off',             ...
          'YGrid','Off',             ...
          'Nextplot','Replace'       ...
          };

      h_AXES = [hdl_Re_AXES,hdl_Im_AXES];
      set(h_AXES(2,:),axeProp{:});

      axes(hdl_Re_AXES(5));
      image([0 1],[0 1],(1:default_nbcolors),'Parent',hdl_Re_AXES(5));
      ud.dynvzaxeX.enable = 'off';
      set(hdl_Re_AXES(5),...
              'XTicklabel',[],'YTicklabel',[],...
              'XGrid','Off','YGrid','Off',...
              'userdata',ud);
      wsetxlabX(hdl_Re_AXES(5),'Scale of colors from MIN to MAX');

      % Computing coefficients.
      %------------------------
      wav_Name = wmemtoolX('rmb',fig,n_param_anal,ind_wav_name);
      coefs    = cw1dmngrX('computeCoefs',fig,sig_Anal,scales,wav_Name);
      wmemtoolX('wmb',fig,n_coefs_sca,ind_coefs,coefs,...
                     ind_scales,scales,ind_frequencies,frequencies);

      % Begin waiting.
      %---------------
      wwaitingX('msg',fig,'Wait ... computing');

      % Coloration of coefficients.
      %----------------------------
      cw1dmngrX('colorCoefs',fig,'draw');

      % Plot line of coefficients.
      %---------------------------
      cw1dmngrX('newCfsLine',fig,'init');

      % Computing local maxima.
      %------------------------
      cw1dmngrX('newChainLine',fig,'init');

      % Setting Dynamic Visualization tool.
      %------------------------------------
      axeCMD = h_AXES(1:4,:);
      axeCMD = axeCMD(:)';
      axeCOO = h_AXES([2,4],:);
      axeCOO = axeCOO(:)';
      dynvtoolX('init',fig,[],axeCMD,[],[1 0],...
               '','','cw1dcoorX',axeCOO,'','','r');

      % End waiting.
      %-------------
      wwaitingX('off',fig);

    case 'initColorCoefs'
      testFirst = varargin{1};
      continu   = 0;
      varargout = {continu,{},0,0,'',[]};
      img_cfs   = findobj(hdl_Re_AXES(2),'type','image');
      old_para  = get(pop_ccm,'userdata');
      if testFirst && (isempty(img_cfs) || old_para(1)==0) , return; end
      col_mod   = get(pop_ccm,'value');
      switch toolMode
        case 'real'
           switch col_mod
            case 1 , absval = 1; levval = 'row'; view_m = 'gbl';
            case 2 , absval = 0; levval = 'row'; view_m = 'gbl';
            case 3 , absval = 1; levval = 'mat'; view_m = 'gbl';
            case 4 , absval = 0; levval = 'mat'; view_m = 'gbl';
            case 5 , absval = 1; levval = 'row'; view_m = 'cur';
            case 6 , absval = 0; levval = 'row'; view_m = 'cur';
            case 7 , absval = 1; levval = 'mat'; view_m = 'cur';
            case 8 , absval = 0; levval = 'mat'; view_m = 'cur';
          end

        otherwise
          absval = 0;
          switch col_mod
            case 1 , levval = 'row'; view_m = 'gbl';
            case 2 , levval = 'mat'; view_m = 'gbl';
            case 3 , levval = 'row'; view_m = 'cur';
            case 4 , levval = 'mat'; view_m = 'cur';
          end
      end
      sig_Size = wmemtoolX('rmb',fig,n_param_anal,ind_sig_size);
      xind1 = 1;
      xind2 = sig_Size;
      if isequal(view_m,'cur')
          xlim_selbox = mngmbtnX('getbox',fig);
          if ~isempty(xlim_selbox)
              xlim_selbox = [min(xlim_selbox) max(xlim_selbox)];
          else
              xlim_selbox = get(hdl_Re_AXES(1),'XLim');
          end
          xlim_selbox = round(xlim_selbox);
          xind1 = max(1,xlim_selbox(1));
          xind2 = min(sig_Size,xlim_selbox(2));
      end
      new_para = [col_mod xind1 xind2];
      if isequal(new_para,old_para) , return; end
      set(pop_ccm,'userdata',new_para);

      % Axes properties & Ytickslabel construction .
      %---------------------------------------------
      scales = wmemtoolX('rmb',fig,n_coefs_sca,ind_scales);
      len  = length(scales);
      nb   = ceil(len/20);
      tics = 1:nb:len;
      tmp  = scales(1:nb:nb*length(tics));
      labs = num2str(tmp(:));
      axeProp = {...
        'XGrid','Off',             ...
        'YGrid','Off',             ...
        'YTicklabelMode','manual', ...
        'YTick',tics,              ...
        'YTicklabel',labs,         ...
        'YDir','normal',           ...
        'Box','On'                 ...
       };

      % Setting outputs.
      %------------------
      continu = 1;
      varargout = {continu,axeProp,levval,absval,view_m,xind1:xind2};

    case 'plotColorCoefs'
      [type,axeCOEFS,axeProp,levval,absval,view_m,xVal] = deal(varargin{:});

      % Waiting message.
      %-----------------
      msg_ini = 'Wait ... coefficients coloration';
      txt_msg = wwaitingX('msg',fig,msg_ini);

      % Getting coefs and scales.
      %--------------------------
      [coefs,scales] = wmemtoolX('rmb',fig,n_coefs_sca,...
                                      ind_coefs,ind_scales);
      switch type
        case 'abs'   , coefs = abs(coefs);
        case 'angle' , coefs = angle(coefs);
      end

      % Coloration of coefficients.
      %-----------------------------
      if strcmp(view_m,'cur')
          if strcmp(levval,'mat')
              cmin = min(min(coefs(:,xVal)));
              cmax = max(max(coefs(:,xVal)));
              coefs(coefs<cmin) = cmin;
              coefs(coefs>cmax) = cmax;
          else
              cmin = min((coefs(:,xVal)),[],2);
              cmax = max((coefs(:,xVal)),[],2);
              fprf = 'Coloration - scale a = %5.3f';
              for k=1:length(scales)
                  msg = {' ',sprintf(fprf,scales(k))};
                  set(txt_msg,'String',msg);
                  drawnow
                  coefs(k,coefs(k,:)<cmin(k)) = cmin(k);
                  coefs(k,coefs(k,:)>cmax(k)) = cmax(k);
              end
              wwaitingX('msg',fig,msg_ini);
              drawnow
          end
      end
      coefs = wcodematX(coefs,default_nbcolors,levval,absval);

      % Plot coefficients.
      %-------------------
      cfsTitles = cw1dutilX('cfsColorTitle',fig,toolMode,pop_ccm);
      indTitle = find(axeCOEFS==[hdl_Re_AXES(2);hdl_Im_AXES]);
      if indTitle>1 , indTitle = 2; end
      axes(axeCOEFS);
      vis = get(axeCOEFS,'Visible');
      img_cfs = findobj(axeCOEFS,'type','image');
      if isempty(img_cfs)
          image('Cdata',coefs,'Visible',vis,'Parent',axeCOEFS);
      else
          set(img_cfs,'Cdata',coefs,'Visible',vis);
      end
      set(axeCOEFS,axeProp{:});
      wtitleX(cfsTitles{indTitle},'Parent',axeCOEFS,'Visible',vis);

    case 'colorCoefs'
      %******************************************%
      %** changing color mode for coefficients **%
      %******************************************%
      testFirst = (length(varargin)<1);
      [continu,axeProp,levval,absval,view_m,xVal] = ...
           cw1dmngrX('initColorCoefs',fig,testFirst);
      if ~continu , return; end

      % Waiting message.
      %-----------------
      msg_ini = 'Wait ... coefficients coloration';
      wwaitingX('msg',fig,msg_ini);

      switch toolMode
        case 'real'
          cw1dmngrX('plotColorCoefs',fig,'real',...
          hdl_Re_AXES(2),axeProp,levval,absval,view_m,xVal)
 
        otherwise
          cw1dmngrX('plotColorCoefs',fig,'abs',...
          hdl_Re_AXES(2),axeProp,levval,absval,view_m,xVal);
          cw1dmngrX('plotColorCoefs',fig,'angle',...
          hdl_Im_AXES(2),axeProp,levval,absval,view_m,xVal);
      end

      % End waiting.
      %-------------
      wwaitingX('off',fig);

    case 'clean'
      calling_opt = varargin{1};

      % Testing first use. End of Cleaning when first is true.
      %-------------------------------------------------------
      active_option = wmemtoolX('rmb',fig,n_param_anal,ind_act_option);
      if isempty(active_option) , first = 1; else first = 0; end

      % Cleaning UIC.
      %--------------
      if ~strcmp(calling_opt,'new_anal')
          [sig_nam,sig_len] = wmemtoolX('rmb',fig,n_param_anal,...
                                ind_sig_name,ind_sig_size);
          sig_len = max(sig_len);
          sca_def = int2str(min(64,sig_len));
          lev_def = min(6,nextpow2(sig_len+1)-1);

          pow_max = fix(log(sig_len)/log(2));
          sca_max = 2^(pow_max-1);
          lev_max = min(pow_max,max_lev_anal);

          cbanaparX('set',fig,'n_s',{sig_nam,sig_len});
          set(edi_sam,'String','1','Userdata','1');
          set(pop_sca,'Value',1,'Userdata',0);
          set(pop_ccm,'Value',1,'Userdata',0);
          str_pop_pow = int2str((1:lev_max)');
          set(pop_pow,'String',str_pop_pow,'Value',lev_def);
          set(edi_min,'String','1');
          set(edi_stp,'String','1');
          set(edi_max,'String',sca_def);
          set(edi_msc,'String',[ '[1:1:' sca_def ']' ]);
          str_txt_max = sprintf('Max  ( <= %.0f )', sca_max); 
          set(txt_max,'String',str_txt_max);
          action = get(pop_sca,'Callback');
          eval(action);
      end
      if first
          switch toolMode
            case 'real' , set(hdl_Re_AXES,'Visible','on');
            otherwise   , cw1dmngrX('setPosAxesIMAG',fig,rad_ALL);
          end
          return;
      end

      % Setting enable property of objects.
      %------------------------------------
      cbanaparX('enable',fig,'off');

      % Cleaning DynVTool.
      %-------------------
      dynvtoolX('stop',fig);

      % Cleaning Axes.
      %---------------
      h_AXES = [hdl_Re_AXES , hdl_Im_AXES];
      toDEL = h_AXES(2:4,:);
      toDEL = allchild(toDEL(:));
      toDEL = cat(1,toDEL{:});
      delete(toDEL);
      if ~strcmp(calling_opt,'new_anal')
          toDEL = h_AXES(1,:);
          toDEL = allchild(toDEL(:));
          if iscell(toDEL),  toDEL = cat(1,toDEL{:}); end
          delete(toDEL)
      end
      set(h_AXES([2,4],:), ...
          'YTicklabelMode','manual','YTick',[],'YTicklabel',[]);
      numView  = toolATTR.Num;
      optDRAW  = 'nothing';
      if ~isequal(toolMode,'real') && ~isequal(toolMode,'all')
          optDRAW = 'setPosAxesIMAG';
      else
          if ~isequal(numView,1) || ...
             (isequal(numView,1) && isequal(toolMode,'all')) 
              optDRAW = 'setPosAxes'; 
          end
      end
  
      switch optDRAW
        case 'nothing'
          set(h_AXES,'Visible','on');

        case 'setPosAxes'
          set([chk_DEC,chk_LC,chk_LML],'Value',1)
          cw1dmngrX('setPosAxes',fig)

        case 'setPosAxesIMAG'
          set([chk_DEC,chk_LC,chk_LML],'Value',1)
          cw1dmngrX('setPosAxesIMAG',fig,rad_ALL)
      end

    case 'set_gui'
      calling_opt = varargin{1};
      switch calling_opt
        case {'demo'}
          wav_Name = wmemtoolX('rmb',fig,n_param_anal,ind_wav_name);
          cbanaparX('set',fig,'wav',wav_Name);
          set(edi_min,'String',sprintf('%.0f',varargin{2}));
          set(edi_stp,'String',sprintf('%.0f',varargin{3}));
          set(edi_max,'String',sprintf('%.0f',varargin{4}));
          set(pop_ccm,'Value',varargin{5});
          if length(varargin)>5
              cbcolmapX('set',fig,'pal',{'same',varargin{6}});
          end
      end

    case 'enable'
      calling_opt  = varargin{1};
      HDL_1 = [...
        edi_sam , pop_sca , pus_ana , ...
        edi_min , edi_stp , edi_max , ...
        pop_pow , edi_msc             ...
        ];

      HDL_2 = [...
        chk_DEC , chk_LC  , chk_LML , ...
        rad_SCA , rad_FRQ , pop_ccm   ...
        ];

	  HDL_3 = [pus_lin , pus_ref];
		
      switch toolMode
        case {'real'}
        case {'abs','arg','all'}
          HDL_2 = [HDL_2 , rad_MOD , rad_ANG , rad_ALL];
      end

      switch calling_opt
        case 'load'
          cbanaparX('enable',fig,'On');
          cbcolmapX('enable',fig,'On');
          set(HDL_1,'enable','On');
          set(HDL_2,'enable','Off');
          set(men_SAV_EXP,'enable','Off');
          set(chk_for_AXES,'enable','On')

        case {'demo','anal'}
          cbanaparX('enable',fig,'On');
          cbcolmapX('enable',fig,'On');
          set(HDL_1,'enable','On');
          set(HDL_2,'enable','On');
          set(men_SAV_EXP,'enable','On');
      end
	  
	  set(HDL_3,'enable','Off');

    case 'load'
      nbIn = length(varargin);
      if nbIn==0
          % Loading file.
          %--------------
          [sigInfos,sig_Anal,ok] = ...
              utguidivX('load_sig',fig,'Signal_Mask','Load Signal');
      else
          % val = varargin{2};
          % switch val
          %     case 0 , opt = '1d';
          %     case 1 , opt = '1d_Im';
          % end
          opt = '1d';
          [sigInfos,sig_Anal,ok] = wtbximportX(opt);
      end
      if ~ok, return; end

      % Setting Analysis parameters.
      %-----------------------------
      wtbxappdataX('set',fig,'sig_Anal',sig_Anal);
      wmemtoolX('wmb',fig,n_param_anal, ...
                     ind_sig_name,sigInfos.name,...
                     ind_sig_size,sigInfos.size ...
                     );
      wmemtoolX('wmb',fig,n_InfoInit, ...
                     ind_filename,sigInfos.filename, ...
                     ind_pathname,sigInfos.pathname  ...
                     );

      % Get the current view.
      %---------------------     
      old_valCHK = get(chk_for_AXES,'Value');      

      % Cleaning.
      %----------
      wwaitingX('msg',fig,'Wait ... cleaning');
      cw1dmngrX('clean',fig,option);
      wmemtoolX('wmb',fig,n_param_anal,ind_act_option,option);
 
      % Drawing.
      %---------
      cw1dmngrX('plotSignal',fig,sig_Anal);

      % Setting enabled values.
      %------------------------
      cw1dmngrX('enable',fig,option);

      % Restore the previous view.
      %---------------------------
      restoreView(fig,chk_for_AXES,old_valCHK);

      % End waiting.
      %---------------
      wwaitingX('off',fig);
      
    case 'demo'
      % Loading file.
      %--------------
      sig_Name = deblank(varargin{1});
      wav_Name = deblank(varargin{2});
      filename = [sig_Name '.mat'];
      pathname = utguidivX('WTB_DemoPath',filename);
      [sigInfos,sig_Anal,ok] = ...
          utguidivX('load_dem1D',fig,pathname,filename);
      if ~ok, return; end

      % Setting Analysis parameters.
      %-----------------------------
      wtbxappdataX('set',fig,'sig_Anal',sig_Anal);
      wmemtoolX('wmb',fig,n_param_anal, ...
                     ind_sig_name,sigInfos.name,...
                     ind_sig_size,sigInfos.size ...
                     );
      wmemtoolX('wmb',fig,n_InfoInit, ...
                     ind_filename,sigInfos.filename, ...
                     ind_pathname,sigInfos.pathname  ...
                     );

      % Get the current view.
      %---------------------     
      old_valCHK = get(chk_for_AXES,'Value');      

      % Cleaning.
      %----------      
      wwaitingX('msg',fig,'Wait ... cleaning');
      cw1dmngrX('clean',fig,option);

      % Setting GUI values.
      %--------------------
      wmemtoolX('wmb',fig,n_param_anal, ...
                     ind_act_option,option,ind_wav_name,wav_Name);
      cw1dmngrX('set_gui',fig,option,varargin{3:end});

      % Drawing & Computing .
      %----------------------
      cw1dmngrX('plotSignal',fig,sig_Anal);
      wwaitingX('msg',fig,'Wait ... computing');
      cw1dmngrX('computeCoefsMNGR',fig);
 
      % Setting enabled values.
      %------------------------
      cw1dmngrX('enable',fig,option);

      % Restore the previous view.
      %---------------------------
      restoreView(fig,chk_for_AXES,old_valCHK);
      
      % End waiting.
      %---------------
      wwaitingX('off',fig);

    case 'save'
      % Testing file.
      %--------------
      [filename,pathname,ok] = utguidivX('test_save',fig, ...
                                   '*.mat','Save Coefficients (CW1D)');
      if ~ok, return; end

      % Begin waiting.
      %--------------
      wwaitingX('msg',fig,'Wait ... saving coefficients');

      % Getting Analysis values.
      %-------------------------
      [coefs,scales] = wmemtoolX('rmb',fig,n_coefs_sca,ind_coefs,ind_scales); %#ok<NASGU>
      wname = wmemtoolX('rmb',fig,n_param_anal,ind_wav_name); %#ok<NASGU>

      % Saving file.
      %--------------
      [name,ext] = strtok(filename,'.');
      if isempty(ext) || isequal(ext,'.')
          ext = '.wc1'; filename = [name ext];
      end
      saveStr = {'coefs','scales','wname'};
      wwaitingX('off',fig);
      try
        save([pathname filename],saveStr{:});
      catch %#ok<CTCH>
        errargtX(mfilename,'Save FAILED !','msg');
      end

    case 'exp_wrks'
      wwaitingX('msg',fig,'Wait ... exporting coefficients');
      [coefs,scales] = wmemtoolX('rmb',fig,n_coefs_sca,ind_coefs,ind_scales);
      wname = wmemtoolX('rmb',fig,n_param_anal,ind_wav_name);
      S = struct('coefs',coefs,'scales',scales,'wname',wname);
      wtbxexportX(S,'name','dec_CW1D','title','Coefficients');      
      wwaitingX('off',fig);

    case 'anal'
      active_option = wmemtoolX('rmb',fig,n_param_anal,ind_act_option);

      % Waiting message.
      %-----------------
      wwaitingX('msg',fig,'Wait ... cleaning and computing');

      % Get the current view.
      %---------------------     
      old_valCHK = get(chk_for_AXES,'Value');      
      
      if ~strcmp(active_option,'load')
          % Cleaning.
          %----------
          cw1dmngrX('clean',fig,'new_anal');

          % Setting enabled values.
          %------------------------
          cw1dmngrX('enable',fig,'load');
      end

      % Setting Analysis parameters
      %-----------------------------
      wav_Name = cbanaparX('get',fig,'wav');
      wmemtoolX('wmb',fig,n_param_anal,  ...
                     ind_act_option,option,ind_wav_name,wav_Name);

      % Computing & Drawing.
      %--------------------
      cw1dmngrX('computeCoefsMNGR',fig);

      % Restore the previous view.
      %---------------------------
      restoreView(fig,chk_for_AXES,old_valCHK);

      % Setting enabled values.
      %------------------------
      cw1dmngrX('enable',fig,option);

      % End waiting.
      %-------------
      wwaitingX('off',fig);

    case 'WindowButtonUpFcn'
		[flag_lin,flag_ref] = cw1dmngrX('get_Ena_Flag',fig);
		if flag_lin , ena_lin = 'On'; else ena_lin = 'Off'; end
		if flag_ref , ena_ref = 'On'; else ena_ref = 'Off'; end
		set(pus_lin,'Enable',ena_lin); 
		set(pus_ref,'Enable',ena_ref);

    case 'get_Ena_Flag'
		flag_lin = 0;
        flag_ref = 0;
		hdl_axe  = NaN;
		switch toolMode
			case {'real'}
				axeLIN = hdl_Re_AXES([2,4]);
                axeFLG = hdl_Re_AXES([3,4]);
			case {'abs','arg','all'}
				axeLIN = [hdl_Re_AXES([2,4]) ; hdl_Im_AXES([2,4])];
                axeFLG = [hdl_Re_AXES([3,4]) ; hdl_Im_AXES([3,4])];
                axeFLG = axeFLG(:)';
		end
		lHor = mngmbtnX('getLines',fig,'Hor');
		if ~isempty(lHor) && ishandle(lHor)
			idx = find(axeLIN==get(lHor,'Parent'));
			if ~isempty(idx)
				hdl_axe  = axeLIN(idx);
                visFLG = get(axeFLG,'Visible');
                switch toolMode
                    case {'real'}
                        flag_lin = isequal(visFLG{1},'on');
                        flag_ref = isequal(visFLG{2},'on');
                    case {'abs','arg','all'}
                        flag_lin = isequal(visFLG{1},'on') | ...
                                   isequal(visFLG{3},'on');
                        flag_ref = isequal(visFLG{2},'on') | ...
                                   isequal(visFLG{4},'on');
                end
			end
		end	
		varargout = {flag_lin,flag_ref,hdl_axe};
		
	otherwise
      errargtX(mfilename,'Unknown Option','msg');
      error('Wavelet:Invalid_ArgVal_Or_ArgType','Unknown Option');
end


%---------------------------------------------------------%
function restoreView(fig,chk_for_AXES,old_valCHK)

new_valCHK = get(chk_for_AXES,'Value'); 
if ~isequal(old_valCHK,new_valCHK)
    for k=1:length(old_valCHK) , 
        set(chk_for_AXES(k),'Value',old_valCHK{k}); 
    end
    cw1dmngrX('setPosAxes',fig);   
end
%---------------------------------------------------------%
