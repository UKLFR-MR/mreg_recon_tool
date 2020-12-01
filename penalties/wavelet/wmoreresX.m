function varargout = wmoreresX(option,varargin)
%WMORERES "More information" on wavelet residuals tool.
%   VARARGOUT = WMORERES(OPTION,VARARGIN)
%
%------------------------------------------------------------
%   Internal options:
%   OPTION =    'create', 'select', 'update_bins', 'close'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jul-98.
%   Last Revision: 29-Apr-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% MemBloc1 of stored values.
%---------------------------
n_membloc1     = [mfilename '_MB1'];
ind_loc_struct = 1;

% Tag property.
%--------------
tag_figRes = 'Fig_Residual';

% Parameters initialization.
%---------------------------
default_bins = 50;
curr_color   = wtbutilsX('colors','res');
nb_bins      = default_bins;
        
if ~isequal(option,'create') , fig = varargin{1}; end

switch option
    case 'create'
        %**************************************************************%
        %** OPTION = 'create' - Create the current figure            **%
        %**************************************************************%
        caller   = varargin{1};
        oldFig   = wfindobjX('figure','tag',tag_figRes);
        existFig = ~isempty(oldFig);
        if existFig
            existFig = 0;
            for k = 1:length(oldFig)
                ls = wmemtoolX('rmb',oldFig(k),n_membloc1,ind_loc_struct);
                if isequal(ls.caller,caller)
                   existFig = oldFig(k);
                   break
                end
            end
        end

        if existFig ~= 0
            try delete(existFig); catch end
            return
        end    

        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,Pop_Min_Width, ...
         X_Spacing,Y_Spacing,Def_EdiBkColor,Def_FraBkColor] = ...
            mextglobX('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width', ...
                'Pop_Min_Width','X_Spacing','Y_Spacing', ...
                'Def_EdiBkColor','Def_FraBkColor' ...
                );
 
        % Window initialization.
        %-----------------------
        CallerTitle = get(caller,'Name');
        strTitle = sprintf('More on Residuals for %s', CallerTitle);
        [fig,pos_win,win_units,str_numwin,...
            pos_frame0,Pos_Graphic_Area] = ...
                wfigmngrX('create',strTitle,[],'ExtFig_Tool_3',mfilename,1,1,0);
        varargout{1} = fig;
        set(fig,'tag',tag_figRes);

		% Add Help for Tool.
		%------------------
		% See Below, after detection of typeDATA

        % Menu construction for current figure.
        %--------------------------------------
        m_files = wfigmngrX('getmenus',fig,'file');		
        uimenu(m_files,...
            'Label','&Save Residuals',               ...
            'Position',1,                            ...
            'Enable','On',                           ...
            'Callback',                              ...
            [mfilename '(''save'',' str_numwin ');'] ...
            );
        
        % Begin waiting.
        %---------------
        set(wfindobjX('figure'),'Pointer','watch');

        % Setting local structure.
        %-------------------------
        ls = struct('caller',caller,'toggle',varargin{2},...
                    'handleRES',varargin{3},'handleORI',[],'handleTHR',[]);
        Nb_Hdls_Inputs = length(varargin)-3;        
        blocPAR = 0;
        if Nb_Hdls_Inputs>0
            ls.handleORI = varargin{4};
            if Nb_Hdls_Inputs>1
               ls.handleTHR = varargin{5};
               if Nb_Hdls_Inputs>2 , blocPAR = 1; end
            end           
        end
        
        if ishandle(ls.handleRES)
            [typeDATA,propDATA] = getDataType(ls.handleRES);
            resVal = wd2uiorui2dX('uint2d',get(ls.handleRES,propDATA));
            
        elseif ishandle(ls.handleORI)
            [typeDATA,propDATA] = getDataType(ls.handleORI);
            resVal = wd2uiorui2dX('uint2d',get(ls.handleORI,propDATA));
            if ishandle(ls.handleTHR)
                if isequal(propDATA,'Ydata');
                  xdata = get(ls.handleORI,'Xdata');
                  xTHR  = get(ls.handleTHR,'Xdata');
                  if ~isequal(xdata,xTHR)
                    typeDATA = 'regress';
                    yTHR   = get(ls.handleTHR,'Ydata');
                    resVal = resVal-interp1(xTHR,yTHR,xdata);
                  else
                    resVal = resVal-...
                        wd2uiorui2dX('uint2d',get(ls.handleTHR,propDATA));
                  end
                else
                  resVal = resVal-...
                      wd2uiorui2dX('uint2d',get(ls.handleTHR,propDATA));
                end
            else
                resVal = zeros(size(resVal));
            end
        else
            error('Wavelet:FunctionArgVal:Invalid_Handle', ...
                'Invalid handle!')
        end       
        wmemtoolX('wmb',fig,n_membloc1,ind_loc_struct,ls);

		% Add Help for Tool.
		%-------------------
        switch typeDATA
            case {'line','regress'}
                helpName = 'RESI1D_GUI';
                helpItem = 'One-Dimensional Residuals';
            case 'image'
                helpName = 'RESI2D_GUI';
                helpItem = 'Two-Dimensional Residuals';
            otherwise
                helpName = 'Error';
        end
		wfighelpX('addHelpTool',fig,helpItem,helpName);

        % Creating the Command part of the window.
        %=========================================
       
        % Building the "Data, Wavelet and Level" block.
        %----------------------------------------------
        if blocPAR , utanaparX('create_copyB',caller,fig); end
       
        % General parameters initialization.
        %-----------------------------------
        dx = X_Spacing;  dx2 = 2*dx;
        dy = Y_Spacing;  dy2 = 2*dy;
        d_txt           = (Def_Btn_Height-Def_Txt_Height);
        x_frame0        = pos_frame0(1);
        xlocINI         = pos_frame0([1 3]);
        cmd_width       = pos_frame0(3);
        push_width      = (cmd_width-4*dx)/2;
        pop_width       = Pop_Min_Width;
        ybottomINI      = pos_win(4)-3.5*Def_Btn_Height-dy2;
        
        % Position property of objects.
        %------------------------------
        x_fra           = x_frame0+3*dx/2;
        y_fra           = ybottomINI-13*Def_Btn_Height;
        w_fra           = cmd_width-3*dx;
        h_fra           = 10*Def_Btn_Height;
        pos_fra         = [x_fra y_fra w_fra h_fra];
        y_low           = ybottomINI-11*Def_Btn_Height/4;
        w_uic           = 15*push_width/8;
        px              = x_frame0+(cmd_width-w_uic)/2;
        pos_hist_chist  = [px, y_low-3*Def_Btn_Height,   ...
                           w_uic, 3*Def_Btn_Height/2];     
        y_low           = pos_hist_chist(2)-3*Def_Btn_Height;
        pos_corr_spec   = [px, y_low , 1.05*w_uic, 3*Def_Btn_Height/2];
        y_low           = pos_corr_spec(2)-3*Def_Btn_Height;
        pos_info_stat   = [px, y_low , w_uic, 3*Def_Btn_Height/2];
        y_low           = pos_fra(2)-2*Def_Btn_Height;
        pos_txt_bin     = [px, y_low+d_txt/2, 2*pop_width,          ...
                            Def_Txt_Height];
        pos_edi_bin     = [px+2*pop_width+dx, y_low, pop_width,     ...
                           Def_Btn_Height];
        y_low           = ybottomINI-3*Def_Btn_Height-Def_Btn_Height/2;
        w_uic           = 1.2*(Def_Btn_Width+dx2);
        x_uic           = x_fra+(w_fra-w_uic)/2; 
        pos_txt_axe     = [x_uic, y_low, w_uic, Def_Txt_Height];
                                   
        % String property of objects.
        %----------------------------
        str_hist_chist  = 'Histogram and Cumul. Hist.';
        str_txt_bin     = 'Number of bins';
        str_edi_bin     = sprintf('%.0f',default_bins);       
        str_corr_spec   = 'Autocorrelations and Spectrum';
        str_info_stat   = 'Descriptive Statistics';
        str_txt_axe     = 'Selected Axes';
        
        % Callbacks property of objects.
        %-------------------------------
        cba_chk         = [mfilename '(''select'',' str_numwin ');'];
        cba_edi_bin     = [mfilename '(''update_bins'',' str_numwin ');'];
        
        % Uicontrols definition.
        %-----------------------
        commonProp      = {'Parent',fig,'Unit',win_units};
        comChkProp      = {commonProp{:},'Style','Checkbox'};
        comFraProp      = {commonProp{:},                                   ...
                                    'BackGroundColor',Def_FraBkColor,       ...
                                    'Style','frame'                         ...
                                    };
        comPropTxtCENT  = {commonProp{:},                                   ...
                                    'Style','text',                         ...
                                    'HorizontalAlignment','center',         ...
                                    'Backgroundcolor',Def_FraBkColor        ...
                                    };
        fra_utl         = uicontrol(comFraProp{:},                          ...
                                    'Style','frame',                        ...
                                    'Position',pos_fra,                     ...
                                    'Visible','off'                         ...
                                    );
        txt_axe         = uicontrol(comPropTxtCENT{:},                      ...
                                    'Position',pos_txt_axe,                 ...
                                    'String',str_txt_axe,                   ...
                                    'Visible','off'                         ...
                                    );
        chk_hist_chist  = uicontrol(comChkProp{:},                          ...
                                    'Position',pos_hist_chist,              ...
                                    'String',str_hist_chist,                ...
                                    'ToolTipString',                        ...
                                    'Histogram and Cumulative Histogram',   ...
                                    'UserData',1,                           ...
                                    'Value',1,                              ...
                                    'Callback',cba_chk,                     ...
                                    'Visible','off'                         ...
                                    );
        txt_bin         = uicontrol(commonProp{:},                          ...
                                    'Style','text',                         ...
                                    'Position',pos_txt_bin,                 ...
                                    'String',str_txt_bin,                   ...
                                    'Backgroundcolor',Def_FraBkColor,       ...
                                    'Visible','off'                         ...
                                    );
        edi_bin         = uicontrol(commonProp{:},                          ...
                                    'Style','Edit',                         ...
                                    'Position',pos_edi_bin,                 ...
                                    'String',str_edi_bin,                   ...
                                    'Backgroundcolor',Def_EdiBkColor,       ...
                                    'Callback',cba_edi_bin,                 ...
                                    'Visible','off'                         ...
                                    );
        chk_corr_spec   = uicontrol(comChkProp{:},                          ...
                                    'Position',pos_corr_spec,               ...
                                    'String',str_corr_spec,                 ...
                                    'UserData',1,                           ...
                                    'Value',1,                              ...
                                    'Callback',cba_chk,                     ...
                                    'Visible','off'                         ...
                                    );
        chk_info_stat   = uicontrol(comChkProp{:},                          ...
                                    'Position',pos_info_stat,               ...
                                    'String',str_info_stat,                 ...
                                    'UserData',1,                           ...
                                    'Value',1,                              ...
                                    'Callback',cba_chk,                     ...
                                    'Visible','off'                         ...
                                    );

        % End of Uicontrols definitions depending on signal or image case.
        %-----------------------------------------------------------------
        switch typeDATA
          case 'line'
            set([chk_info_stat;chk_corr_spec;chk_hist_chist;fra_utl;txt_axe]...
                ,'Visible','On');
          case 'image'
            % Adding colormap GUI.
            %---------------------
            pos_txt_bin(2) = pos_txt_bin(2)+10*Def_Btn_Height;
            pos_edi_bin(2) = pos_edi_bin(2)+10*Def_Btn_Height;
            set(txt_bin,'Position',pos_txt_bin);
            set(edi_bin,'Position',pos_edi_bin);
            try 
                pop_pal_caller = cbcolmapX('get',caller,'pop_pal');
                ok = true;
            catch
                ok = false;
            end
            if ok
                prop_pal = get(pop_pal_caller,{'String','Value','Userdata'});
                utcolmapX('create',fig, ...
                    'xloc',xlocINI, ...
                    'bkcolor',Def_FraBkColor, ...
                    'enable','on');
                pop_pal_loc = cbcolmapX('get',fig,'pop_pal');
                set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                    'Userdata',prop_pal{3});
                set(fig,'Colormap',get(caller,'Colormap'));
            end

          case 'regress'
            pos_txt_bin(2) = pos_txt_bin(2)+10*Def_Btn_Height;
            pos_edi_bin(2) = pos_edi_bin(2)+10*Def_Btn_Height;
            set(txt_bin,'Position',pos_txt_bin);
            set(edi_bin,'Position',pos_edi_bin);
        end
        set([txt_bin;edi_bin],'Visible','On');

        % Creating the Graphical part of the window.
        %===========================================

        % Frame Stats. construction.
        %---------------------------
        infos_hdls = utstatsX('create',fig,...
                                        'xloc',Pos_Graphic_Area([1,3]), ...
                                        'bottom',Pos_Graphic_Area(2)+dy2);
        fra_sta     = infos_hdls(1);
        pos_fra_sta = get(fra_sta,'Position');

        % Axes Positions.
        %----------------
        gra_width  = Pos_Graphic_Area(3);
        xspace     = gra_width/12;
        ecy_up     = 0.06*pos_win(4);
        ecy_down   = 0.06*pos_win(4);
        ecy_mid    = 0.08*pos_win(4);
        y_rem      = pos_frame0(4)-(pos_fra_sta(2)+pos_fra_sta(4)) ...
                                  -ecy_up-ecy_down;
        switch typeDATA
          case 'line'    ,  y_rem = y_rem-2*ecy_mid;
          case 'image'   ,  y_rem = y_rem-ecy_mid;
          case 'regress' ,  y_rem = y_rem-ecy_mid;
        end
        axe_width  = gra_width-2*xspace;
        half_width = axe_width/2-xspace/2;
        
        switch typeDATA
          case 'line'
            axe_height     = y_rem/3;
            y_low          = pos_fra_sta(2)+pos_fra_sta(4)+ecy_down;
            pos_ax_corr    = [xspace y_low half_width axe_height];
            pos_ax_spec    = [2*xspace+half_width y_low half_width axe_height];
            y_low          = y_low+axe_height+ecy_mid;
            pos_ax_hist    = [xspace y_low half_width axe_height];
            pos_ax_cumhist = [2*xspace+half_width y_low half_width axe_height];
            y_low          = y_low+axe_height+ecy_mid;
            pos_ax_signal  = [xspace y_low axe_width axe_height];

          case 'image'
            axe_height     = y_rem/3;
            y_low          = pos_fra_sta(2)+pos_fra_sta(4)+ecy_down;
            pos_ax_hist    = [xspace y_low half_width axe_height];
            pos_ax_cumhist = [2*xspace+half_width y_low half_width axe_height];
            y_low          = y_low+axe_height+ecy_mid;
            axe_height     = 2*y_rem/3;
            cx             = xspace+axe_width/2;
            cy             = y_low+axe_height/2;
            imageSize      = size(resVal);    
            imageSize      = imageSize([2 1]);
            [w_use,h_use]  = wpropimgX(imageSize,axe_width,axe_height,'pixels');
            pos_ax_signal  = [cx-w_use/2,cy-h_use/2,w_use,h_use];
            
          case 'regress'
            axe_height     = y_rem/2;
            y_low          = pos_fra_sta(2)+pos_fra_sta(4)+ecy_down;
            pos_ax_hist    = [xspace y_low half_width axe_height];
            pos_ax_cumhist = [2*xspace+half_width y_low half_width axe_height];
            y_low          = y_low+axe_height+ecy_mid;
            pos_ax_signal  = [xspace y_low axe_width axe_height];
        end

        % Axes Definitions.
        %------------------
        commonProp = {...
           'Parent',fig,...
           'Units',win_units,...
           'Visible','Off',...
           'box','on',...
           'NextPlot','Replace',...
           'Drawmode','fast'...
           };
        axe_signal  = axes(commonProp{:},'Position',pos_ax_signal);
        axe_hist    = axes(commonProp{:},'Position',pos_ax_hist);
        axe_cumhist = axes(commonProp{:},'Position',pos_ax_cumhist);
        switch typeDATA
          case 'line'
            axe_corr = axes(commonProp{:},'Position',pos_ax_corr);
            axe_spec = axes(commonProp{:},'Position',pos_ax_spec);
        end

        % Displaying signal or image.
        %----------------------------        
        axes(axe_signal);
        switch typeDATA
            case {'line','regress'}
                len = length(resVal);
                if ishandle(ls.handleORI)
                    xdata = get(ls.handleORI,'Xdata');
                elseif ishandle(ls.handleTHR)
                    xdata = get(ls.handleTHR,'Xdata');
                else
                    xdata = (1:len);
                end
                hdl_Sig = line('Xdata',xdata,'Ydata',resVal,...
                    'Color',curr_color,'Visible','Off');
                set(axe_signal,'Xlim',[xdata(1),xdata(end)])

            case 'image'
                X = wd2uiorui2dX('d2uint',wcodematX(resVal,128,'mat',0));
                hdl_Sig = image(X,'Parent',axe_signal);
        end
        wtitleX('Residuals','Parent',axe_signal);

        % Setting units to normalized.
        %-----------------------------
        wfigmngrX('normalize',fig);

        % Displaying histogram.
        %----------------------
        his       = wgethistX(resVal(:),nb_bins);
        [xx,imod] = max(his(2,:)); %#ok<ASGLU>
        mode_val  = (his(1,imod)+his(1,imod+1))/2;
        his(2,:)  = his(2,:)/length(resVal(:));
        axes(axe_hist);
        wplothisX(axe_hist,his,curr_color);
        wtitleX('Histogram','Parent',axe_hist);

        % Displaying cumulated histogram.
        %--------------------------------
        for i=6:4:length(his(2,:));
            his(2,i)   = his(2,i)+his(2,i-4);
            his(2,i+1) = his(2,i);
        end
        axes(axe_cumhist);
        wplothisX(axe_cumhist,[his(1,:);his(2,:)],curr_color);
        wtitleX('Cumulative histogram','Parent',axe_cumhist);

        switch typeDATA
          case 'line'
            % Displaying Autocorrelations.
            %-----------------------------       
            [corr,lags] = wautocor(resVal);
            lenLagsPos  = (length(lags)-1)/2;
            lenKeep     = min(200,lenLagsPos);
            first       = lenLagsPos+1-lenKeep;
            last        = lenLagsPos+1+lenKeep;
            Xval        = lags(first:last);
            Yval        = corr(first:last);
            axes(axe_corr);
            line('Xdata',Xval,'Ydata',Yval,'Color',curr_color);
            set(axe_corr,'Xlim',[Xval(1) Xval(end)],...
                         'Ylim',[min(0,1.1*min(Yval)) 1]);
            wtitleX('Autocorrelations','Parent',axe_corr);
            
            % Displaying Spectrum.
            %---------------------
            [sp,f]  = wspecfft(resVal);
            axes(axe_spec);
            line('Xdata',f,'Ydata',sp,'Color',curr_color);
            set(axe_spec,'Xlim',[min(f) max(f)]);
            wtitleX('FFT - Spectrum','Parent',axe_spec);
            xlabel('Frequency','Parent',axe_spec);
            ylabel('Energy','Parent',axe_spec);

        end

        % Displaying statistics.
        %-----------------------
        switch typeDATA
          case {'line','regress'}
             errtol    = 1.0E-12;
             mean_val  = mean(resVal);
             max_val   = max(resVal);
             min_val   = min(resVal);
             range_val = max_val-min_val;
             std_val   = std(resVal);
             med_val   = median(resVal);

           case 'image'
             errtol    = 1.0E-12;
             mean_val  = mean(resVal(:));
             if abs(mean_val)<errtol , mean_val = 0; end
             max_val   = max(resVal(:));
             if abs(max_val)<errtol , max_val = 0; end
             min_val   = min(resVal(:));
             if abs(min_val)<errtol , min_val = 0; end
             range_val = max_val-min_val;
             if abs(range_val)<errtol , range_val = 0; end
             std_val   = std(resVal(:));
             if abs(std_val)<errtol , std_val = 0; end
             med_val   = median(resVal(:));
             if abs(med_val)<errtol , med_val = 0; end
        end
        medDev_val = median(abs(resVal(:)-med_val)); 
        if abs(medDev_val)<errtol , medDev_val = 0; end
        meanDev_val = mean(abs(resVal(:)-mean_val));      
        if abs(meanDev_val)<errtol , meanDev_val = 0; end
        L1_val = norm(resVal(:),1);
        L2_val = norm(resVal(:),2);
        LM_val = norm(resVal(:),Inf);        
        utstatsX('display',fig, ...
            [mean_val; med_val ; mode_val;  ...
             max_val ; min_val ; range_val; ...
             std_val ; medDev_val; meanDev_val; ...
             L1_val ; L2_val ; LM_val]);

        % Set axes visible.
        %------------------
        set([infos_hdls;axe_signal;axe_hist;axe_cumhist;hdl_Sig],...
            'visible','on');
        
        switch typeDATA
          case 'line' , set([axe_corr;axe_spec],'visible','on');
        end

        % Store values.
        %--------------
        group_hdls  = struct(...
            'chk_hist_chist',   chk_hist_chist,     ...
            'txt_bin',          txt_bin,            ...
            'edi_bin',          edi_bin,            ...
            'chk_corr_spec',    chk_corr_spec,      ...
            'chk_info_stat',    chk_info_stat       ...
            );
        set(axe_signal,'Userdata',get(axe_signal,'Position'));
        set(axe_hist,'Userdata',get(axe_hist,'Position'));
        set(axe_cumhist,'Userdata',get(axe_cumhist,'Position'));
        Glb_Infos = struct(...
            'typeDATA',      typeDATA,   ...
            'resVal',        resVal,     ...
            'infos_hdls',    infos_hdls, ...
            'axe_signal',    axe_signal, ...
            'axe_hist',      axe_hist,   ...
            'axe_cumhist',   axe_cumhist ...
            );
         switch typeDATA
          case 'line'
            set(axe_corr,'Userdata',get(axe_corr,'Position'));
            set(axe_spec,'Userdata',get(axe_spec,'Position'));
            Glb_Infos.axe_corr = axe_corr;
            Glb_Infos.axe_spec = axe_spec;

          case {'image','regress'}
        end
        
        wfigmngrX('storeValue',fig,'group_hdls',group_hdls);
        wfigmngrX('storeValue',fig,'Glb_Infos',Glb_Infos);
        wfigmngrX('storeValue',fig,'Old_nb_bins',nb_bins);
                
        % Dynvtool Attachment.
        %---------------------
        switch typeDATA
            case 'line' , axe_ind = [axe_signal axe_corr axe_spec];
            case {'image','regress'} , axe_ind = axe_signal;
        end
        axe_cmd = [];
        axe_act = [];
        dynvtoolX('attach',fig,axe_ind,axe_cmd,axe_act,[1 0],'','','');
        dynvtoolX('put',fig);

        % End waiting.
        %-------------
        wwaitingX('off',fig);

    case 'select'
        %**************************************************************%
        %** OPTION = 'select' - GROUP AXES SELECTION                 **%
        %**************************************************************%
        sel_chk_btn = gcbo;

        % Get stored structure.
        %----------------------
        group_hdls     = wfigmngrX('getValue',fig,'group_hdls');
        chk_hist_chist = group_hdls.chk_hist_chist;
        txt_bin        = group_hdls.txt_bin;
        edi_bin        = group_hdls.edi_bin;
        chk_corr_spec  = group_hdls.chk_corr_spec;
        chk_info_stat  = group_hdls.chk_info_stat;

        Glb_Infos      = wfigmngrX('getValue',fig,'Glb_Infos');
        infos_hdls     = Glb_Infos.infos_hdls;
        axe_signal     = Glb_Infos.axe_signal;
        axe_hist       = Glb_Infos.axe_hist;
        axe_cumhist    = Glb_Infos.axe_cumhist;
        axe_corr       = Glb_Infos.axe_corr;
        axe_spec       = Glb_Infos.axe_spec;
        fra_sta        = infos_hdls(1);
        
        % Get the current selection.
        %---------------------------
        hist_chist = (get(chk_hist_chist,'Userdata')~=0);
        corr_spec  = (get(chk_corr_spec,'Userdata')~=0);
        info_stat  = (get(chk_info_stat,'Userdata')~=0);

        % Get the axes original positions.
        %---------------------------------
        pos_axe_signal  = get(axe_signal,'Userdata');
        pos_axe_hist    = get(axe_hist,'Userdata');
        pos_axe_cumhist = get(axe_cumhist,'Userdata');
        pos_axe_corr    = get(axe_corr,'Userdata');
        pos_axe_spec    = get(axe_spec,'Userdata');
        pos_fra_sta     = get(fra_sta,'Position');
        
        % Graphical parameters.
        %----------------------
        yspace    = 2*pos_fra_sta(2);
        heigh_max = pos_axe_signal(2)+pos_axe_signal(4)+yspace;
        
        % Redraw depending on the current selection.
        %-------------------------------------------
        switch sel_chk_btn
            case chk_hist_chist
                if hist_chist
                    set(chk_hist_chist,'Value',0,'Userdata',0);
                    if info_stat
                        y_rem = heigh_max-(pos_fra_sta(2)+ ...
                                pos_fra_sta(4))-7*yspace/4;
                        y_low = pos_fra_sta(2)+pos_fra_sta(4)+yspace/3;
                        if corr_spec
                            axe_height        = y_rem/2;
                            pos_axe_corr(2)   = y_low;
                            pos_axe_corr(4)   = axe_height;
                            pos_axe_spec(2)   = y_low;
                            pos_axe_spec(4)   = axe_height;
                            y_low             = y_low+axe_height+yspace/3;
                            pos_axe_signal(2) = y_low;
                            pos_axe_signal(4) = axe_height;
                        else
                            axe_height        = y_rem;
                            pos_axe_signal(2) = y_low+yspace/6;
                            pos_axe_signal(4) = axe_height;
                        end
                    else
                        y_rem = heigh_max-9*yspace/4;
                        y_low = pos_fra_sta(2)+yspace/3;
                        if corr_spec
                            axe_height        = y_rem/2;
                            pos_axe_corr(2)   = y_low;
                            pos_axe_corr(4)   = axe_height;
                            pos_axe_spec(2)   = y_low;
                            pos_axe_spec(4)   = axe_height;
                            y_low             = y_low+axe_height+yspace/3;
                            pos_axe_signal(2) = y_low;
                            pos_axe_signal(4) = axe_height;
                        else
                            axe_height        = y_rem;
                            pos_axe_signal(2) = y_low+yspace/6;
                            pos_axe_signal(4) = axe_height;
                        end
                    end
                else
                    set(chk_hist_chist,'Value',1,'Userdata',1);
                    if info_stat
                        y_rem = heigh_max-(pos_fra_sta(2)+ ...
                                pos_fra_sta(4))-8*yspace/4;
                        y_low = pos_fra_sta(2)+pos_fra_sta(4)+yspace/3;
                        if corr_spec
                            axe_height         = y_rem/3;
                            pos_axe_corr(2)    = y_low;
                            pos_axe_corr(4)    = axe_height;
                            pos_axe_spec(2)    = y_low;
                            pos_axe_spec(4)    = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        else
                            axe_height         = y_rem/2;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        end
                    else
                        y_rem = heigh_max-10*yspace/4;
                        y_low = pos_fra_sta(2)+yspace/3;
                        if corr_spec
                            axe_height         = y_rem/3;
                            pos_axe_corr(2)    = y_low;
                            pos_axe_corr(4)    = axe_height;
                            pos_axe_spec(2)    = y_low;
                            pos_axe_spec(4)    = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        else
                            axe_height         = y_rem/2;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        end
                    end
                end

            case chk_corr_spec
                if corr_spec
                    set(chk_corr_spec,'Value',0,'Userdata',0);
                    if info_stat
                        y_rem = heigh_max-(pos_fra_sta(2)+ ...
                                pos_fra_sta(4))-7*yspace/4;
                        y_low = pos_fra_sta(2)+pos_fra_sta(4)+yspace/3;
                        if hist_chist
                            axe_height         = y_rem/2;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        else
                            axe_height         = y_rem;
                            pos_axe_signal(2)  = y_low+yspace/6;
                            pos_axe_signal(4)  = axe_height;
                        end
                    else
                        y_rem = heigh_max-9*yspace/4;
                        y_low = pos_fra_sta(2)+yspace/3;
                        if hist_chist
                            axe_height         = y_rem/2;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        else
                            axe_height        = y_rem;
                            pos_axe_signal(2) = y_low+yspace/6;
                            pos_axe_signal(4) = axe_height;
                        end
                    end
                else
                    set(chk_corr_spec,'Value',1,'Userdata',1);
                    if info_stat
                        y_rem = heigh_max-(pos_fra_sta(2)+ ...
                                pos_fra_sta(4))-8*yspace/4;
                        y_low = pos_fra_sta(2)+pos_fra_sta(4)+yspace/3;
                        if hist_chist
                            axe_height         = y_rem/3;
                            pos_axe_corr(2)    = y_low;
                            pos_axe_corr(4)    = axe_height;
                            pos_axe_spec(2)    = y_low;
                            pos_axe_spec(4)    = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        else
                            axe_height         = y_rem/2;
                            pos_axe_corr(2)    = y_low;
                            pos_axe_corr(4)    = axe_height;
                            pos_axe_spec(2)    = y_low;
                            pos_axe_spec(4)    = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        end
                    else
                        y_rem = heigh_max-10*yspace/4;
                        y_low = pos_fra_sta(2)+yspace/3;
                        if hist_chist
                            axe_height         = y_rem/3;
                            pos_axe_corr(2)    = y_low;
                            pos_axe_corr(4)    = axe_height;
                            pos_axe_spec(2)    = y_low;
                            pos_axe_spec(4)    = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        else
                            axe_height         = y_rem/2;
                            pos_axe_corr(2)    = y_low;
                            pos_axe_corr(4)    = axe_height;
                            pos_axe_spec(2)    = y_low;
                            pos_axe_spec(4)    = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        end
                    end
                end
            case chk_info_stat
                if info_stat
                    set(chk_info_stat,'Value',0,'Userdata',0);
                    y_low = pos_fra_sta(2)+yspace/3;
                    if corr_spec
                        y_rem = heigh_max-10*yspace/4;
                        if hist_chist
                            axe_height         = y_rem/3;
                            pos_axe_corr(2)    = y_low;
                            pos_axe_corr(4)    = axe_height;
                            pos_axe_spec(2)    = y_low;
                            pos_axe_spec(4)    = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        else
                            axe_height         = y_rem/2;
                            pos_axe_corr(2)    = y_low;
                            pos_axe_corr(4)    = axe_height;
                            pos_axe_spec(2)    = y_low;
                            pos_axe_spec(4)    = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low+yspace/6;
                            pos_axe_signal(4)  = axe_height;
                        end
                    else
                        y_rem = heigh_max-9*yspace/4;
                        if hist_chist
                            axe_height         = y_rem/2;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        else
                            axe_height        = y_rem;
                            pos_axe_signal(2) = y_low+yspace/6;
                            pos_axe_signal(4) = axe_height;
                        end
                    end
                else
                    set(chk_info_stat,'Value',1,'Userdata',1);
                    y_low = pos_fra_sta(2)+pos_fra_sta(4)+yspace/3;
                    if corr_spec
                        if hist_chist
                            y_rem = heigh_max-(pos_fra_sta(2)+ ...
                                    pos_fra_sta(4))-8*yspace/4;
                            axe_height         = y_rem/3;
                            pos_axe_corr(2)    = y_low;
                            pos_axe_corr(4)    = axe_height;
                            pos_axe_spec(2)    = y_low;
                            pos_axe_spec(4)    = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        else
                            y_rem = heigh_max-(pos_fra_sta(2)+ ...
                                    pos_fra_sta(4))-7*yspace/4;
                            axe_height         = y_rem/2;
                            pos_axe_corr(2)    = y_low;
                            pos_axe_corr(4)    = axe_height;
                            pos_axe_spec(2)    = y_low;
                            pos_axe_spec(4)    = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        end
                    else
                        y_rem = heigh_max-(pos_fra_sta(2)+ ...
                            pos_fra_sta(4))-7*yspace/4;
                        if hist_chist
                            axe_height         = y_rem/2;
                            pos_axe_hist(2)    = y_low;
                            pos_axe_hist(4)    = axe_height;
                            pos_axe_cumhist(2) = y_low;
                            pos_axe_cumhist(4) = axe_height;
                            y_low              = y_low+axe_height+yspace/3;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        else
                            y_rem = heigh_max-(pos_fra_sta(2)+ ...
                                pos_fra_sta(4))-6*yspace/4;
                            axe_height         = y_rem;
                            pos_axe_signal(2)  = y_low;
                            pos_axe_signal(4)  = axe_height;
                        end
                    end
                end
        end
        
        % Set the current positions.
        %---------------------------
        set(axe_signal,'Position',pos_axe_signal);
        set(axe_hist,'Position',pos_axe_hist);
        set(axe_cumhist,'Position',pos_axe_cumhist);
        set(axe_corr,'Position',pos_axe_corr);
        set(axe_spec,'Position',pos_axe_spec);

        % Set enability and visibility for each controlable axes or frames.
        %------------------------------------------------------------------
        set(axe_signal,'Visible','on');
        set(get(axe_signal,'Children'),'Visible','on');
                 
        if  get(chk_hist_chist,'Value')
            set(txt_bin,'Visible','on');
            set(edi_bin,'Visible','on');
            set(axe_hist,'Visible','on');
            set(get(axe_hist,'Children'),'Visible','on');
            set(axe_cumhist,'Visible','on');
            set(get(axe_cumhist,'Children'),'Visible','on');
        else
            set(txt_bin,'Visible','off');
            set(edi_bin,'Visible','off');
            set(axe_hist,'Visible','off');
            set(get(axe_hist,'Children'),'Visible','off');
            set(axe_cumhist,'Visible','off');
            set(get(axe_cumhist,'Children'),'Visible','off');            
        end

        if  get(chk_corr_spec,'Value')
            set(axe_corr,'Visible','on');
            set(get(axe_corr,'Children'),'Visible','on');
            set(axe_spec,'Visible','on');
            set(get(axe_spec,'Children'),'Visible','on');
        else
            set(axe_corr,'Visible','off');
            set(get(axe_corr,'Children'),'Visible','off');
            set(axe_spec,'Visible','off');
            set(get(axe_spec,'Children'),'Visible','off');        
        end
                   
        if  get(chk_info_stat,'Value')
            set(infos_hdls,'Visible','on');
        else
            set(infos_hdls,'Visible','off');
        end
               
    case 'update_bins'
        %**************************************************************%
        %** OPTION = 'update_bins' - UPDATE HISTOGRAMS WITH NEW BINS **%
        %**************************************************************%
        edi_bin     = gcbo;

        % Get stored structure.
        %----------------------
        Old_nb_bins = wfigmngrX('getValue',fig,'Old_nb_bins');
        Glb_Infos   = wfigmngrX('getValue',fig,'Glb_Infos');
        resVal      = Glb_Infos.resVal;
        axe_hist    = Glb_Infos.axe_hist;
        axe_cumhist = Glb_Infos.axe_cumhist;

        % Return if no current display.
        %------------------------------
        vis = get(axe_hist,'Visible');
        if isequal(vis(1:2),'of') , return, end

        % Check the bins number.
        %-----------------------
        if ~isempty(Old_nb_bins)
            default_bins = Old_nb_bins;
        end
        nb_bins = wstr2numX(get(edi_bin,'String'));
        if isempty(nb_bins) || (nb_bins<2)
            nb_bins = default_bins;   
            set(edi_bin,'String',sprintf('%.0f',default_bins))
        end
        if default_bins==nb_bins , return; end

        % Waiting message.
        %-----------------
        wwaitingX('msg',fig,'Wait ... computing');

        % Save Userdata.
        %---------------
        pos_axe_hist    = get(axe_hist,'Userdata');
        pos_axe_cumhist = get(axe_cumhist,'Userdata');
        
        % Updating histograms.
        %---------------------
        if ~isempty(resVal)
            Old_nb_bins = nb_bins;
            wfigmngrX('storeValue',fig,'Old_nb_bins',Old_nb_bins);
            his      = wgethistX(resVal(:),nb_bins);
            his(2,:) = his(2,:)/length(resVal(:));
            axes(axe_hist);
            wplothisX(axe_hist,his,curr_color);
            wtitleX('Histogram','Parent',axe_hist);
            for i=6:4:length(his(2,:));
                his(2,i)   = his(2,i)+his(2,i-4);
                his(2,i+1) = his(2,i);
            end
            axes(axe_cumhist);
            wplothisX(axe_cumhist,[his(1,:);his(2,:)],curr_color);
            wtitleX('Cumulative histogram','Parent',axe_cumhist);
        end
        
        % Restore Userdata.
        %------------------
        set(axe_hist,'Userdata',pos_axe_hist);
        set(axe_cumhist,'Userdata',pos_axe_cumhist);
        
        % End waiting.
        %-------------
        wwaitingX('off',fig);
        		
    case 'save'
    %---------------------------------%
    % Option: SAVE : Saving residuals %
    %---------------------------------%
						
        % Get arguments.
        %---------------
        fig = varargin{1};

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',fig, ...
                                    '*.mat','Save Residuals');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',fig,'Wait ... saving');		

        % Get the residuals to save.
        %---------------------------
        Glb_Infos = wfigmngrX('getValue',fig,'Glb_Infos');
        resVal    = Glb_Infos.resVal;
        typeDATA  = Glb_Infos.typeDATA;

        % Saving transformed Signal.
        %---------------------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        switch typeDATA
          case 'image'
            X   = resVal; %#ok<NASGU>
            map = get(fig,'Colormap'); %#ok<NASGU>
            saveStr = {'X','map'};
            
          case 'regress'
            ls = wmemtoolX('rmb',fig,n_membloc1,ind_loc_struct);
            xdata = get(ls.handleTHR,'Xdata');
            ydata = interp1(resVal,xdata); %#ok<NASGU>
            saveStr = {'xdata','ydata'};

            otherwise
              try
                eval([name ' = resVal;']);
                saveStr = {name};
              catch
                x = resVal; %#ok<NASGU>
                saveStr = {'x'};  
              end
        end
        try
          save([pathname filename],saveStr{:});
        catch
          errargtX(mfilename,'Save FAILED !','msg');
        end
        
        % End waiting.
        %-------------
        wwaitingX('off',fig);

    case 'close'
        %**************************************************************%
        %** OPTION = 'close' - Close the current figure              **%
        %**************************************************************%
        fig = varargin{1};        
        ls     = wmemtoolX('rmb',fig,n_membloc1,ind_loc_struct);
        toggle = ls.toggle;
        if ishandle(toggle) , set(toggle,'Value',0); end

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid argument value.');
end

%-------------------------------------------------------------------------%
function [type,prop] = getDataType(handle)
type = get(handle,'Type');
switch type
  case 'line'  , prop = 'Ydata';
  case 'image' , prop = 'Cdata';
end    
%-------------------------------------------------------------------------%


%-------------------------------------------------------------------------%
function [sp,f] = wspecfft(signal)
%WSPECFFT FFT spectrum of a signal.
%
% f is the frequency 
% sp is the energy, the square of the FFT transform

% The input signal is empty.
%---------------------------
if isempty(signal)
    sp = [];f =[];return
end

% Compute the spectrum.
%----------------------
n   = length(signal);
XTF = fft(fftshift(signal));
m   = ceil(n/2) + 1;

% Compute the output values.
%---------------------------
f   = linspace(0,0.5,m);
sp  = (abs(XTF(1:m))).^2;
%-------------------------------------------------------------------------%


%-------------------------------------------------------------------------%
function [c,lags] = wautocor(a,maxlag)
%WAUTOCOR Auto-correlation function estimates.
%   [C,LAGS] = WAUTOCOR(A,MAXLAG) computes the 
%   autocorrelation function c of a one dimensional
%   signal a, for lags = [-maxlag:maxlag]. 
%   The autocorrelation c(maxlag+1) = 1.
%   If nargin==1, by default, maxlag = length(a)-1.

if nargin == 1, maxlag = size(a,2)-1;end
lags = -maxlag:maxlag;
if isempty(a) , c = []; return; end
epsi = sqrt(eps);
a    = a(:);
a    = a - mean(a);
nr   = length(a); 
if std(a)>epsi
    % Test of the variance.
    %----------------------
    mr     = 2 * maxlag + 1;
    nfft   = 2^nextpow2(mr);
    nsects = ceil(2*nr/nfft);
    if nsects>4 && nfft<64
        nfft = min(4096,max(64,2^nextpow2(nr/4)));
    end
    c      = zeros(nfft,1);
    minus1 = (-1).^(0:nfft-1)';
    af_old = zeros(nfft,1);
    n1     = 1;
    nfft2  = nfft/2;
    while (n1<nr)
       n2 = min( n1+nfft2-1, nr );
       af = fft(a(n1:n2,:), nfft);
       c  = c + af.* conj( af + af_old);
       n1 = n1 + nfft2;
       af_old = minus1.*af;
    end
    if n1==nr
        af = ones(nfft,1)*a(nr,:);
   	c  = c + af.* conj( af + af_old );
    end
    mxlp1 = maxlag+1;
    c = real(ifft(c));
    c = [ c(mxlp1:-1:2,:); c(1:mxlp1,1) ];

    % Compute the autocorrelation function.
    %-------------------------------------- 
    cdiv = c(mxlp1,1);
    c = c / cdiv;
else
    % If  the variance is too small.
    %-------------------------------
    c = ones(size(lags));
end
%-------------------------------------------------------------------------%
