function out1 = dw1dstatX(option,in2,in3,in4,in5,in6)
%DW1DSTAT Discrete wavelet 1-D statistics.
%   OUT1 = DW1DSTAT(OPTION,IN2,IN3,IN4,IN5,IN6)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 29-Aug-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Memory Blocks of stored values.
%================================
% MB1 (main Window).
%-------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
% ind_act_option = 6;
ind_ssig_type  = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% MB1 (local).
%-------------
n_misc_loc = ['MB1_' mfilename];
ind_selbox     = 1;
ind_curr_sig   = 2;
ind_curr_color = 3;
nbLOC_1_stored = 3;

% Tag property of objects.
%-------------------------
tag_appdet_txt = 'Appdet_Txt';
tag_appdet_val = 'Appdet_Val';
tag_sel_cfs    = 'Sel_Cfs';
tag_sel_rec    = 'Sel_Rec';
tag_orig_sig   = 'Orig_sig';
tag_synt_sig   = 'Synt_sig';
tag_app_sig    = 'App_sig';
tag_det_sig    = 'Det_sig';
tag_bins_txt   = 'Bins_Txt';
tag_bins_data  = 'Bins_Data';
% tag_levels     = 'Levels';
tag_ax_signal  = 'Ax_Signal';
tag_ax_hist    = 'Ax_Hist';
tag_ax_cumhist = 'Ax_Cumhist';
tag_show_stat  = 'Show_Stat';

if ~isequal(option,'create') , win_stats = in2; end
switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Pop_Min_Width, ...
         X_Spacing,Y_Spacing,Def_EdiBkColor,Def_FraBkColor] = ...
            mextglobX('get',...
                'Def_Txt_Height','Def_Btn_Height','Pop_Min_Width', ...
                'X_Spacing','Y_Spacing','Def_EdiBkColor','Def_FraBkColor' ...
                );

        % Calling figure.
        %----------------
        win_dw1dtoolX = in2;
        str_win_dw1dtoolX = sprintf('%.0f',win_dw1dtoolX);

        % Window initialization.
        %----------------------
        win_name = 'Wavelet 1-D  --  Statistics';
        [win_stats,pos_win,win_units,str_numwin,...
                pos_frame0,Pos_Graphic_Area] = ...
                    wfigmngrX('create',win_name,'','ExtFig_HistStat',mfilename,0);
        if nargout>0 , out1 = win_stats; end
		
		% Add Help for Tool.
		%------------------
		wfighelpX('addHelpTool',win_stats,'Statistics','DW1D_STAT_GUI');

        % Begin waiting.
        %---------------
        set(wfindobjX('figure'),'Pointer','watch');

        % Getting variables from dw1dtoolX figure memory block.
        %-----------------------------------------------------
        [Sig_Name,Wav_Name,Lev_Anal,Sig_Size,Axe_Ref] = ...
                wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,  ...
                        ind_sig_name,ind_wav_name,         ...
                        ind_lev_anal,ind_sig_size,ind_axe_ref);

        % General graphical parameters initialization.
        %--------------------------------------------
        dx = X_Spacing;
        dy = Y_Spacing;  dy2 = 2*dy;
        gra_width = Pos_Graphic_Area(3);
        x_frame0  = pos_frame0(1);
        cmd_width = pos_frame0(3);

        % Buttons width
        push_width = (cmd_width-4*dx)/2;
        pop_width  = Pop_Min_Width;

        % Parameters initialization.
        %---------------------------
        default_bins = 30;

        % Position property of objects.
        %------------------------------
        xlocINI    = pos_frame0([1 3]);
        ybottomINI = pos_win(4)-3.5*Def_Btn_Height-dy2;
        w_chk      = 7*push_width/4;
        h_chk      = 3*Def_Btn_Height/2;
        d_higth    = Def_Btn_Height;
        d_txt      = Def_Btn_Height-Def_Txt_Height;

        % For 640x480 resolution
        %-----------------------
        d_higth = depOfMachine(d_higth);
        
        x_left          = x_frame0+(cmd_width-w_chk)/2;
        y_low           = ybottomINI-Def_Btn_Height-10*dy;
        pos_orig_sig    = [x_left , y_low , w_chk , h_chk];
        y_low           = y_low-Def_Btn_Height-d_higth;        
        pos_synt_sig    = [x_left , y_low , w_chk , h_chk];
        y_low           = y_low-Def_Btn_Height-d_higth;        
        pos_app_sig     = [x_left , y_low , w_chk , h_chk];
        y_low           = y_low-Def_Btn_Height-d_higth;        
        pos_det_sig     = [x_left , y_low , w_chk , h_chk];

        x_left          = x_frame0+(cmd_width-3*push_width/2)/2;
        y_low           = pos_det_sig(2)-2*Def_Btn_Height;
        pos_appdet_txt  = [x_left , y_low+d_txt/2 , 3*push_width/2 , Def_Txt_Height];
        y_low           = y_low-Def_Btn_Height;
        pos_appdet_val  = [x_left , y_low , 3*push_width/2 , Def_Btn_Height];

        x_left          = x_frame0+(cmd_width-5*push_width/4)/2;
        y_low           = pos_appdet_val(2)-2*Def_Btn_Height;

        pos_sel_cfs     = [x_left , y_low , 5*push_width/4 , Def_Btn_Height];
        y_low           = y_low-h_chk;
        pos_sel_rec     = [x_left , y_low , 5*push_width/4 , Def_Btn_Height];

        x_left          = x_frame0+(cmd_width-3*pop_width)/2;
        y_low           = pos_sel_rec(2)-Def_Btn_Height-d_higth;
        pos_bins_txt    = [x_left , y_low+d_txt/2 , 2*pop_width , Def_Txt_Height];
        x_left          = x_left+2*pop_width+dx;
        pos_bins_data   = [x_left , y_low , pop_width , Def_Btn_Height];

        x_left          = x_frame0+(cmd_width-3*push_width/2)/2;
        y_low           = pos_bins_data(2)-2*Def_Btn_Height-d_higth;
        pos_show_stat   = [x_left , y_low , 3*push_width/2 , 2*Def_Btn_Height];

        % String property of objects.
        %----------------------------
        ss_type = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_ssig_type);
        switch ss_type
            case 'ss', str_ss = 'Synthesized signal';
            case 'ds', str_ss = 'De-noised signal';
            case 'cs', str_ss = 'Compressed signal';
        end
        str_synt_sig    = str_ss;

        str_orig_sig    = 'Original signal';
        str_app_sig     = 'Approximation';
        str_det_sig     = 'Detail';
        str_app_txt     = 'Approximation at';
        str_sel_cfs     = 'Coefficients';
        str_sel_rec     = 'Reconstructed';
        str_bins_txt    = 'Number of bins';
        str_bins_data   = sprintf('%.0f',default_bins);
        str_show_stat   = 'Show statistics';
        str_appdet_val  = [];
        for i = 1:Lev_Anal
			 str_appdet_val = [str_appdet_val ; sprintf('Level %2.0f', i)]; %#ok<AGROW>
        end

        % Command part construction of the window.
        %-----------------------------------------
        if ~isequal(get(0,'CurrentFigure'),win_stats) , figure(win_stats); end
        utanaparX('create_copy',win_stats, ...
                 {'xloc',xlocINI,'bottom',ybottomINI},...
                 {'n_s',{Sig_Name,Sig_Size},'wav',Wav_Name,'lev',Lev_Anal} ...
                 );

        commomProp = {'Parent',win_stats,'Unit',win_units};
        comRadProp = {commomProp{:},'Style','Radiobutton','Enable','off'};
        rad_orig_sig    = uicontrol(comRadProp{:},...
            'Position',pos_orig_sig,...
            'String',str_orig_sig,...
            'Value',1,...
            'Userdata',1,...
            'Tag',tag_orig_sig...
            );
        rad_synt_sig    = uicontrol(comRadProp{:},...
            'Position',pos_synt_sig,...
            'String',str_synt_sig,...
            'Tag',tag_synt_sig...
            );
        rad_app_sig     = uicontrol(comRadProp{:},...
            'Position',pos_app_sig,...
            'String',str_app_sig,...
            'Tag',tag_app_sig...
            );
        rad_det_sig     = uicontrol(comRadProp{:},...
            'Position',pos_det_sig,...
            'String',str_det_sig,...
            'Tag',tag_det_sig...
            );
        txt_appdet_txt  = uicontrol(commomProp{:},...
            'Style','Text',...
            'Position',pos_appdet_txt,...
            'String',str_app_txt,...
            'Visible','off',...
            'Tag',tag_appdet_txt,...
            'Backgroundcolor',Def_FraBkColor...
            );
        pop_appdet_val  = uicontrol(commomProp{:},...
            'Style','Popup',...
            'Position',pos_appdet_val,...
            'String',str_appdet_val,...
            'Visible','off',...
            'Userdata',1,...
            'Tag',tag_appdet_val...
            );
        rad_sel_cfs     = uicontrol(commomProp{:},...
            'Style','Radiobutton',...
            'Position',pos_sel_cfs,...
            'String',str_sel_cfs,...
            'Visible','off',...
            'Tag',tag_sel_cfs,...
            'Userdata',0,...
            'Value',0);
        rad_sel_rec     = uicontrol(commomProp{:},...
            'Style','Radiobutton',...
            'Unit',win_units,...
            'Position',pos_sel_rec,...
            'String',str_sel_rec,...
            'Visible','off',...
            'Tag',tag_sel_rec,...
            'Userdata',1,...
            'Value',1);
        txt_bins_txt    = uicontrol(commomProp{:},...
            'Style','text',...
            'Position',pos_bins_txt,...
            'String',str_bins_txt,...
            'Backgroundcolor',Def_FraBkColor,...
            'Visible','off',...
            'Tag',tag_bins_txt...
            );
        edi_bins_data   = uicontrol(commomProp{:},...
            'Style','Edit',...
            'Position',pos_bins_data,...
            'String',str_bins_data,...
            'Backgroundcolor',Def_EdiBkColor,...
            'Visible','off',...
            'Tag',tag_bins_data...
            );
        pus_show_stat   = uicontrol(commomProp{:},...
            'Style','Pushbutton',...
            'Position',pos_show_stat,...
            'String',xlate(str_show_stat),...
            'Visible','off',...
            'Userdata',[],...
            'Tag',tag_show_stat...
            );
        coeff_vari_pos  = 2;
        pos_bins_txt(2) = pos_det_sig(2)-coeff_vari_pos*2*pos_det_sig(4)/3;
        pos_bins_data(2)= pos_bins_txt(2);
        pos_show_stat(2)= pos_bins_data(2)-3*2*pos_det_sig(4)/3;
        set(txt_bins_txt,'Position',pos_bins_txt,'Visible','on');
        set(edi_bins_data,'Position',pos_bins_data,'Visible','on');
        set(pus_show_stat,'Position',pos_show_stat,'Visible','on');

        % Frame Stats. construction.
        %---------------------------
        [infos_hdls,h_frame1] = utstatsX('create',win_stats,   ...
                                        'xloc',Pos_Graphic_Area([1,3]), ...
                                        'bottom',dy2);
        
        % Sets of handles.
        %-----------------
        set1_hdls = [txt_appdet_txt;pop_appdet_val;rad_sel_cfs;rad_sel_rec];
        set2_hdls = [txt_bins_txt;edi_bins_data;pus_show_stat];

        % Selected box limits.
        %---------------------
        xlim_selbox = mngmbtnX('getbox',win_dw1dtoolX); 
        if ~isempty(xlim_selbox)
            xlim_selbox = [min(xlim_selbox) max(xlim_selbox)];
        else
            xlim_selbox = get(Axe_Ref,'XLim');
        end
        xlim_selbox = round(xlim_selbox);
        xlim1       = xlim_selbox(1);
        xlim2       = xlim_selbox(2);
        if xlim1<1,        xlim1 = 1;        end
        if xlim2>Sig_Size, xlim2 = Sig_Size; end
        if (xlim2<1) || (xlim1>Sig_Size), return; end
        selbox = [xlim1 xlim2];

        % Callbacks update.
        %------------------
        str_infos_hdls     = num2mstrX(infos_hdls);
        str_group_hdls     = num2mstrX([set2_hdls;set1_hdls]);
        str_set2_hdls      = num2mstrX(set2_hdls);
        str_rad_orig_sig   = num2mstrX(rad_orig_sig);
        str_rad_synt_sig   = num2mstrX(rad_synt_sig);
        str_rad_app_sig    = num2mstrX(rad_app_sig);
        str_rad_det_sig    = num2mstrX(rad_det_sig);
        str_pop_appdet_val = num2mstrX(pop_appdet_val);
        str_rad_sel_rec    = num2mstrX(rad_sel_rec);
        str_rad_sel_cfs    = num2mstrX(rad_sel_cfs);
        str_edi_bins_data  = num2mstrX(edi_bins_data);

        cba_orig_sig       = [mfilename '(''select'','  ...
            str_numwin ','       ...
            str_rad_orig_sig ',' ...
            str_infos_hdls ','   ...
            str_group_hdls ','   ...
            str_set2_hdls        ...
            ');'];
        cba_synt_sig       = [mfilename '(''select'','  ...
            str_numwin ','       ...
            str_rad_synt_sig ',' ...
            str_infos_hdls ','   ...
            str_group_hdls ','   ...
            str_set2_hdls        ...
            ');'];
        cba_app_sig        = [mfilename '(''select'',' ...
            str_numwin ','      ...
            str_rad_app_sig ',' ...
            str_infos_hdls ','  ...
            str_group_hdls ','  ...
            str_group_hdls      ...
            ');'];
        cba_det_sig        = [mfilename '(''select'',' ...
            str_numwin ','      ...
            str_rad_det_sig ',' ...
            str_infos_hdls ','  ...
            str_group_hdls ','  ...
            str_group_hdls      ...
            ');'];
        cba_pop_appdet_val = [mfilename '(''upd'','       ...
            str_numwin ',''lvl'',' ...
            str_infos_hdls ','     ...
            str_pop_appdet_val     ...
            ');'];
        cba_sel_rec        = [mfilename '(''upd'','       ...
            str_numwin ',''cfs'',' ...
            str_infos_hdls ','     ...
            str_rad_sel_rec        ...
            ');'];
        cba_sel_cfs        = [mfilename '(''upd'','       ...
            str_numwin ',''cfs'',' ...
            str_infos_hdls ','     ...
            str_rad_sel_cfs        ...
            ');'];
        cba_bins_data      = [mfilename '(''update_bins'',' ...
            str_numwin ','           ...
            str_edi_bins_data        ...
            ');'];
        cba_show_stat      = [mfilename '(''draw'','    ...
            str_numwin ','       ...
            str_win_dw1dtoolX ',' ...
            str_infos_hdls ');'];

        set(rad_orig_sig,'Callback',cba_orig_sig);
        set(rad_synt_sig,'Callback',cba_synt_sig);
        set(rad_app_sig,'Callback',cba_app_sig);
        set(rad_det_sig,'Callback',cba_det_sig);
        set(pop_appdet_val,'Callback',cba_pop_appdet_val);
        set(rad_sel_rec,'Callback',cba_sel_rec);
        set(rad_sel_cfs,'Callback',cba_sel_cfs);
        set(edi_bins_data,'Callback',cba_bins_data);
        set(pus_show_stat,'Callback',cba_show_stat);

        % Memory blocks update.
        %----------------------
        wmemtoolX('ini',win_stats,n_misc_loc,nbLOC_1_stored);
        wmemtoolX('wmb',win_stats,n_misc_loc,ind_selbox,selbox);

        % Axes construction.
        %-------------------
        xspace         = gra_width/10;
        yspace         = pos_frame0(4)/10;
        axe_height     = (pos_frame0(4)-Def_Btn_Height-h_frame1-4*dy)/2-yspace;
        axe_width      = gra_width-2*xspace;
        half_width     = axe_width/2-xspace/2;
        pos_ax_signal  = [xspace h_frame1+2*dy2+axe_height+4*yspace/3 ...
                                axe_width axe_height];
        pos_ax_hist    = [xspace h_frame1+2*dy2+yspace/3 ...
                                half_width axe_height];
        pos_ax_cumhist = [2*xspace+half_width h_frame1+2*dy2+yspace/3 ...
                                half_width axe_height];

        commonProp = {...
           'Parent',win_stats,...
           'Units',win_units,...
           'Visible','Off',...
           'box','on',...
           'NextPlot','Replace',...
           'Drawmode','fast'...
           };
        axes(commonProp{:},'Position',pos_ax_signal,'Tag',tag_ax_signal);
        axes(commonProp{:},'Position',pos_ax_hist,'Tag',tag_ax_hist);
        axes(commonProp{:},'Position',pos_ax_cumhist,'Tag',tag_ax_cumhist);
        drawnow

        % Displaying the window title.
        %-----------------------------
        str_nb_val   = [' (' sprintf('%.0f',Sig_Size) ' values)'];
        str_wintitle = [Sig_Name,str_nb_val,' analyzed at level ',...
                        sprintf('%.0f',Lev_Anal),' with ',Wav_Name];
        str_wintitle = [str_wintitle '.  Components :   ' ,...
                        sprintf('%.0f',selbox(1)) ' --> ' ...
                        sprintf('%.0f',selbox(2))];
        wfigtitlX('string',win_stats,str_wintitle,'off');

        % Setting units to normalized.
        %-----------------------------
        wfigmngrX('normalize',win_stats);

		% Initialization with signal statistics (31/08/2000).
		%----------------------------------------------------
        dw1dstatX('draw',win_stats,win_dw1dtoolX,infos_hdls);

        % End waiting.
        %-------------
		set(wfindobjX('figure'),'Pointer','arrow');
        set([rad_orig_sig rad_synt_sig rad_app_sig rad_det_sig],'Enable','on');

    case 'select'
        %***********************************************%
        %** OPTION = 'select' - SIGNAL TYPE SELECTION **%
        %***********************************************%
        sel_rad_btn = in3;
        infos_hdls  = in4;
        group_hdls  = in5;
        curr_hdls   = in6;

        % Set to the current selection.
        %------------------------------
        rad_handles  = findobj(win_stats,'Style','radiobutton');
        rad_orig_sig = findobj(rad_handles,'Tag',tag_orig_sig);
        rad_synt_sig = findobj(rad_handles,'Tag',tag_synt_sig);
        rad_app_sig  = findobj(rad_handles,'Tag',tag_app_sig);
        rad_det_sig  = findobj(rad_handles,'Tag',tag_det_sig);
        rad_opt      = [rad_orig_sig rad_synt_sig rad_app_sig rad_det_sig];

        old_rad      = findobj(rad_opt,'Userdata',1);
        set(rad_opt,'Value',0,'Userdata',[]);
        set(sel_rad_btn,'Value',1,'Userdata',1)
        if old_rad==sel_rad_btn , return; end

        % Reset all.
        %-----------
        axe_handles    = findobj(win_stats,'Type','axes');
        axe_ax_signal  = findobj(axe_handles,'flat','Tag',tag_ax_signal);
        axe_ax_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_ax_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);
        set([infos_hdls',group_hdls'],'Visible','off');
        set(findobj([axe_ax_signal,axe_ax_hist,axe_ax_cumhist]),...
                'visible','off');
        drawnow

        % Redraw the command part depending on the current selection.
        %------------------------------------------------------------
        pos_det_sig    = get(rad_det_sig,'Position');
        pos_bins_txt   = get(curr_hdls(1),'Position');
        pos_bins_data  = get(curr_hdls(2),'Position');
        pos_show_stat  = get(curr_hdls(3),'Position');
        coeff_vari_pos = 9;
        if sel_rad_btn==rad_app_sig
            set(curr_hdls(4),'String',xlate('Approximation at'))
        elseif sel_rad_btn==rad_det_sig
            set(curr_hdls(4),'String',xlate('Detail at'))
        elseif sel_rad_btn==rad_orig_sig || sel_rad_btn==rad_synt_sig
            coeff_vari_pos = 2;
        end
        pos_bins_txt(2) = pos_det_sig(2)-coeff_vari_pos*2*pos_det_sig(4)/3;
        pos_bins_data(2)= pos_bins_txt(2);
        pos_show_stat(2)= pos_bins_data(2)-3*2*pos_det_sig(4)/3;
        set(curr_hdls(1),'Position',pos_bins_txt);
        set(curr_hdls(2),'Position',pos_bins_data);
        set(curr_hdls(3),'Position',pos_show_stat);
        set(curr_hdls,'Visible','On');

    case 'upd'
        %***************************************%
        %** OPTION = 'upd' - UPDATE :         **%
        %**     COEFFICIENTS TYPE SELECTION   **%
        %**     LEVEL NUMBER SELECTION        **%
        %***************************************%
        opt        = in3;
        infos_hdls = in4;

        % Set to the current selection.
        %------------------------------
        if strcmp(opt,'cfs')
            sel_rad_btn = in5;
            rad_handles = findobj(win_stats,'Style','radiobutton');
            rad_sel_rec = findobj(rad_handles,'Tag',tag_sel_rec);
            rad_sel_cfs = findobj(rad_handles,'Tag',tag_sel_cfs);
            rad_opt     = [rad_sel_rec rad_sel_cfs];
            old_rad     = findobj(rad_opt,'Userdata',1);
            set(rad_opt,'Value',0,'Userdata',0);
            set(sel_rad_btn,'Value',1,'Userdata',1)
            if old_rad==sel_rad_btn , return; end

        elseif strcmp(opt,'lvl')
            pop_level = in5;
            val_pop = get(pop_level,'value');
            usr_pop = get(pop_level,'userdata');
            if usr_pop==val_pop , return; end
            set(pop_level,'userdata',val_pop);
        end

        % Reset all.
        %-----------
        axe_handles    = findobj(win_stats,'Type','axes');
        axe_ax_signal  = findobj(axe_handles,'flat','Tag',tag_ax_signal);
        axe_ax_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_ax_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);
        set(infos_hdls,'Visible','off');
        set(findobj([axe_ax_signal,axe_ax_hist,axe_ax_cumhist]),...
                'visible','off');
        drawnow

    case 'draw'
        %*********************************%
        %** OPTION = 'draw' - DRAW AXES **%
        %*********************************%
        win_dw1dtoolX = in3;
        infos_hdls   = in4;

        % Handles of tagged objects.
        %---------------------------
        children       = get(win_stats,'Children');
        uic_handles    = findobj(children,'flat','type','uicontrol');
        pus_show_stat  = findobj(uic_handles,...
                                       'Style','pushbutton',...
                                       'Tag',tag_show_stat...
                                       );
        rad_handles    = findobj(uic_handles,'Style','radiobutton');
        edi_handles    = findobj(uic_handles,'Style','edit');
        pop_handles    = findobj(uic_handles,'Style','popupmenu');
        rad_sel_cfs    = findobj(rad_handles,'Tag',tag_sel_cfs);
        rad_orig_sig   = findobj(rad_handles,'Tag',tag_orig_sig);
        rad_synt_sig   = findobj(rad_handles,'Tag',tag_synt_sig);
        rad_app_sig    = findobj(rad_handles,'Tag',tag_app_sig);
        rad_det_sig    = findobj(rad_handles,'Tag',tag_det_sig);
        edi_bins_data  = findobj(edi_handles,'Tag',tag_bins_data);
        pop_appdet_val = findobj(pop_handles,'Tag',tag_appdet_val);

        % Handles of tagged objects continuing.
        %-------------------------------------
        axe_handles    = findobj(children,'flat','type','axes');
        axe_ax_signal  = findobj(axe_handles,'flat','Tag',tag_ax_signal);
        axe_ax_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_ax_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);

        % Main parameters selection before drawing.
        %------------------------------------------
        sel_cfs  = (get(rad_sel_cfs,'Value')~=0);
        orig_sig = (get(rad_orig_sig,'Value')~=0);
        synt_sig = (get(rad_synt_sig,'Value')~=0);
        app_sig  = (get(rad_app_sig,'Value')~=0);
        det_sig  = (get(rad_det_sig,'Value')~=0);

        % Check the bins number.
        %-----------------------
        default_bins = 30;
        old_params   = get(pus_show_stat,'Userdata');
        if ~isempty(old_params) , default_bins = old_params(1); end
        nb_bins = wstr2numX(get(edi_bins_data,'String'));
        if isempty(nb_bins) || (nb_bins<2)
            nb_bins = default_bins;   
            set(edi_bins_data,'String',sprintf('%.0f',default_bins))
        end
        level = get(pop_appdet_val,'value');
        new_params = [ nb_bins sel_cfs orig_sig synt_sig ...
                       app_sig det_sig level             ...
                       ];

        if ~isempty(old_params) && (isequal(new_params,old_params))
            vis = get(axe_ax_hist,'Visible');
            if strcmp(vis(1:2),'on'), return, end
        end

        % Deseable new selection.
        %-------------------------
        pop_handles = cbanaparX('no_pop',win_stats,pop_handles);
        set([pop_handles;rad_handles;edi_bins_data],'Enable','off');

        % Updating parameters.
        %--------------------- 
        set(pus_show_stat,'Userdata',new_params);

        % Show the status line.
        %----------------------
        wfigtitlX('vis',win_stats,'on');

        % Cleaning the graphical part.
        %-----------------------------
        set(infos_hdls,'Visible','off');
        set(findobj([axe_ax_signal,axe_ax_hist,axe_ax_cumhist]),...
                'visible','off');
        drawnow

        % Waiting message.
        %-----------------
        wwaitingX('msg',win_stats,'Wait ... computing');

        % Getting memory blocks.
        %-----------------------
        Lev_Anal = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_lev_anal);
        selbox_orig = wmemtoolX('rmb',win_stats,n_misc_loc,ind_selbox);

        % Definition of the complete selection box.
        %-----------------------------------------
        selbox_orig     = selbox_orig(1):selbox_orig(2);

        % Current signal construction.
        %-----------------------------
        if orig_sig
            curr_sig   = dw1dfileX('sig',win_dw1dtoolX);
            curr_color = wtbutilsX('colors','sig');
            str_title  = 'Original signal';
        elseif synt_sig
            curr_sig   = dw1dfileX('ssig',win_dw1dtoolX);
            curr_color = wtbutilsX('colors','ssig');

            ss_type = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,...
                                                    ind_ssig_type);
            switch ss_type
                case 'ss', str_ss = 'Synthesized signal';
                case 'ds', str_ss = 'De_noised signal';
                case 'cs', str_ss = 'Compressed signal';
            end
            str_title = str_ss;

        elseif app_sig
            if sel_cfs
                [curr_sig,set_ylim,ymin,ymax] = ...
                        dw1dfileX('app_cfs',win_dw1dtoolX,level,1);
                str_title= sprintf('Coefficients of approximation at level ');
            else
                [curr_sig,set_ylim,ymin,ymax] = ...
                        dw1dfileX('app',win_dw1dtoolX,level,1);
                str_title= sprintf('Reconstructed approximation at level ');
            end
            col_app    = wtbutilsX('colors','app',Lev_Anal);
            curr_color = col_app(level,:);
            str_title  = [str_title, sprintf('%.0f',level)];
        elseif det_sig
            if sel_cfs
                [curr_sig,set_ylim,ymin,ymax] = ...
                        dw1dfileX('det_cfs',win_dw1dtoolX,level,1);

                str_title= sprintf('Coefficients of detail at level ');
            else
                [curr_sig,set_ylim,ymin,ymax] = ...
                        dw1dfileX('det',win_dw1dtoolX,level,1);
                str_title= sprintf('Reconstructed detail at level ');
            end
            col_det    = wtbutilsX('colors','det',Lev_Anal);
            curr_color = col_det(level,:);

            str_title  = [str_title, sprintf('%.0f',level)];
        end
        selbox  = selbox_orig;
        if sel_cfs && ~orig_sig && ~synt_sig
            min_box = ceil(min(selbox)/2^level);
            max_box = ceil(max(selbox)/2^level);
            selbox  = min_box:max_box;
        end
        if length(selbox)<=2
            wwarndlgX([' Not enough coefficients remaining at level ' ...
                      sprintf('%.0f',level)],...
                      'Wavelet 1-D -- Statistics','block');
            set([pop_handles;rad_handles;edi_bins_data],'Enable','on');
            wwaitingX('off',win_stats);
            return;
        else
            curr_sig = curr_sig(selbox);
        end

        % Displaying the signal.
        %-----------------------
        xlim = [min(selbox)    max(selbox)];
        ylim = [min(curr_sig)  max(curr_sig)];
        if xlim(1)==xlim(2) , xlim = xlim+[-0.01 0.01]; end
        if ylim(1)==ylim(2) , ylim = ylim+[-0.01 0.01]; end
        if (app_sig || det_sig) && set_ylim
            if ylim(1)<ymin , ylim(1) = ymin; end
            if ylim(2)>ymax , ylim(2) = ymax; end
        end
        axes(axe_ax_signal);
        plot(selbox,curr_sig,'Color',curr_color,'Parent',axe_ax_signal);

        set(axe_ax_signal,'Visible','on','Xlim',xlim,'Ylim',ylim,...
                'Tag',tag_ax_signal);
        wtitleX(str_title,'Parent',axe_ax_signal);

        % Displaying histogram.
        %----------------------
        his       = wgethistX(curr_sig,nb_bins);
        [xx,imod] = max(his(2,:)); %#ok<ASGLU>
        mode_val  = (his(1,imod)+his(1,imod+1))/2;
        his(2,:)  = his(2,:)/length(curr_sig);
        axes(axe_ax_hist);
        wplothisX(axe_ax_hist,his,curr_color);
        wtitleX('Histogram','Parent',axe_ax_hist);

        % Displaying cumulated histogram.
        %--------------------------------
        for i=6:4:length(his(2,:));
            his(2,i)   = his(2,i)+his(2,i-4);
            his(2,i+1) = his(2,i);
        end
        axes(axe_ax_cumhist);
        wplothisX(axe_ax_cumhist,[his(1,:);his(2,:)],curr_color);
        wtitleX('Cumulative histogram','Parent',axe_ax_cumhist);

        % Displaying statistics.
        %-----------------------
        errtol = 1.0E-12;
        mean_val = mean(curr_sig);
        if abs(mean_val)<errtol , mean_val = 0; end
        max_val  = max(curr_sig);
        if abs(max_val)<errtol , max_val = 0; end
        min_val  = min(curr_sig);
        if abs(min_val)<errtol , min_val = 0; end
        range_val = max_val-min_val;
        if abs(range_val)<errtol , range_val = 0; end
        std_val = std(curr_sig);
        if abs(std_val)<errtol , std_val = 0; end
        med_val = median(curr_sig);
        if abs(med_val)<errtol , med_val = 0; end        
        L1_val = norm(curr_sig,1);
        L2_val = norm(curr_sig,2);
        LM_val = norm(curr_sig,Inf);
        utstatsX('display',win_stats, ...
            [mean_val; med_val ; mode_val;  ...
             max_val ; min_val ; range_val; ...
             std_val ; median(abs(curr_sig-med_val)); ...
             mean(abs(curr_sig-mean_val)); ...
             L1_val ; L2_val ; LM_val]);

        % Memory blocks update.
        %----------------------
        wmemtoolX('wmb',win_stats,n_misc_loc,...
                       ind_curr_sig,curr_sig,ind_curr_color,curr_color);

        % End waiting.
        %-------------
        wwaitingX('off',win_stats);

        % Setting infos visible.
        %-----------------------
        set(infos_hdls,'Visible','on');

        % Enable new selection.
        %----------------------
        set([pop_handles;rad_handles;edi_bins_data],'Enable','on');

    case 'update_bins'
        %**************************************************************%
        %** OPTION = 'update_bins' - UPDATE HISTOGRAMS WITH NEW BINS **%
        %**************************************************************%
        edi_bins_data = in3;

        % Handles of tagged objects.
        %---------------------------
        pus_show_stat  = findobj(win_stats,...
                                   'Style','pushbutton',...
                                   'Tag',tag_show_stat...
                                   );
        axe_handles    = findobj(win_stats,'Type','axes');
        axe_ax_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_ax_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);

        % Return if no current display.
        %------------------------------
        vis = get(axe_ax_hist,'Visible');
        if strcmp(vis(1:2),'of'), return, end

        % Check the bins number.
        %-----------------------
        default_bins    = 30;
        old_params      = get(pus_show_stat,'Userdata');
        if ~isempty(old_params)
            default_bins = old_params(1);
        end
        nb_bins = wstr2numX(get(edi_bins_data,'String'));
        if isempty(nb_bins) || (nb_bins<2)
            nb_bins = default_bins;   
            set(edi_bins_data,'String',sprintf('%.0f',default_bins))
        end
        if default_bins==nb_bins , return; end

        % Getting memory blocks.
        %-----------------------
        [curr_sig,curr_color] = wmemtoolX('rmb',win_stats,n_misc_loc,...
                                               ind_curr_sig,ind_curr_color);

        % Updating histograms.
        %---------------------
        if ~isempty(curr_sig)
            old_params(1) = nb_bins;
            set(pus_show_stat,'Userdata',old_params);
            his      = wgethistX(curr_sig,nb_bins);
            his(2,:) = his(2,:)/length(curr_sig);
            wplothisX(axe_ax_hist,his,curr_color);
            wtitleX('Histogram','Parent',axe_ax_hist);
            for i=6:4:length(his(2,:));
                his(2,i)   = his(2,i)+his(2,i-4);
                his(2,i+1) = his(2,i);
            end
            wplothisX(axe_ax_cumhist,[his(1,:);his(2,:)],curr_color);
            wtitleX('Cumulative histogram','Parent',axe_ax_cumhist);
        end

    case 'demo'
        %****************************************%
        %** OPTION = 'demo' -  DEMOS or TESTS  **%
        %****************************************%
        pus_show_stat = findobj(win_stats,...
                                'Style','pushbutton',...
                                'Tag',tag_show_stat...
                                );
        eval(get(pus_show_stat,'Callback'));

    case 'close'

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid Input Argument.');
end

%-------------------------------------------------
function varargout = depOfMachine(varargin)

d_higth = varargin{1};
scrSize = get(0,'ScreenSize');
if scrSize(4)<600 , d_higth = d_higth/2; end
varargout = {d_higth};
%-------------------------------------------------
