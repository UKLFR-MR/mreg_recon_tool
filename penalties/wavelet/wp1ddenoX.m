function varargout = wp1ddenoX(option,varargin)
%WP1DDENO Wavelet packets 1-D de-noising.
%   VARARGOUT = WP1DDENO(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 29-Apr-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $

% Memory Blocks of stored values.
%================================
% MB1 (main window).
%-------------------
n_param_anal   = 'WP1D_Par_Anal';
ind_sig_name   = 1;
ind_wav_name   = 2;
% ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_sig_size   = 6;
% ind_act_option = 7;
ind_thr_val    = 8;

% MB1 (local).
%-------------
n_misc_loc  = ['MB1_' mfilename];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
ind_cfsMode    = 6;
nbLOC_1_stored = 6;

% MB2 (local).
%-------------
n_thrDATA = 'thrDATA';
ind_value = 1;
nbLOC_2_stored = 1;

% Tag property (Main Window).
%----------------------------
tag_pop_colm = 'Txt_PopM';
tag_axe_cfs  = 'Axe_Cfs';

if ~isequal(option,'create') , win_denoise = varargin{1}; end
switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Btn_Height,Y_Spacing,Def_FraBkColor] = ...
            mextglobX('get','Def_Btn_Height','Y_Spacing','Def_FraBkColor');

        % Calling figure.
        %----------------
        win_caller = varargin{1};
        pop = wfindobjX(win_caller,'style','popupmenu','tag',tag_pop_colm);
        cfsMode = get(pop,'Value');

        % Window initialization.
        %----------------------
        win_name = 'Wavelet Packet 1-D  --  De-noising';
        [win_denoise,pos_win,win_units,str_win_denoise,pos_frame0] = ...
            wfigmngrX('create',win_name,'','ExtFig_CompDeno',...
            {mfilename,'cond'},1,1,0);
        set(win_denoise,'userdata',win_caller,'Tag','WP1D_DEN');
        if nargout>0 , varargout{1} = win_denoise; end
		
		% Add Help for Tool.
		%------------------
		wfighelpX('addHelpTool',win_denoise,'Signal De-noising','WP1D_DENO_GUI');

		% Add Help Item.
		%----------------
		wfighelpX('addHelpItem',win_denoise,'De-noising Procedure','DENO_PROCEDURE');
		wfighelpX('addHelpItem',win_denoise,'Available Methods','COMP_DENO_METHODS');

        % Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngrX('getmenus',win_denoise,'save');
        sav_menus(1) = uimenu(m_save,...
            'Label','De-noised &Signal ',...
            'Position',1,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            [mfilename '(''save_synt'','    ...
            str_win_denoise ');']   ...
            );
        sav_menus(2) = uimenu(m_save,...
            'Label','&Decomposition ', ...
            'Position',2,                  ...
            'Enable','Off',                ...
            'Callback',                    ...
            [mfilename '(''save_dec'','    ...
            str_win_denoise ');']  ...
            );

        % Begin waiting.
        %---------------
        wwaitingX('msg',win_denoise,'Wait ... initialization');

        % Getting variables from wp1dtoolX figure memory block.
        %-----------------------------------------------------
        WP_Tree = wtbxappdataX('get',win_caller,'WP_Tree');
        depth = treedpthX(WP_Tree);
        [Sig_Name,Sig_Size,Wav_Name,Ent_Nam,Ent_Par] =      ...
                 wmemtoolX('rmb',win_caller,n_param_anal, ...
                                ind_sig_name,ind_sig_size,...
                                ind_wav_name,ind_ent_anal,ind_ent_par);

        % General graphical parameters initialization.
        %--------------------------------------------
        dy = Y_Spacing;

        % Command part of the window.
        %============================
        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanaparX('create_copy',win_denoise, ...
                    {'xloc',xlocINI,'top',ytopINI},...
                    {'n_s',{Sig_Name,Sig_Size},'wav',Wav_Name,'lev',depth} ...
                    );

        % Entropy parameters.
        %--------------------
        ytopENT = toolPos(2)-4*dy;
        toolPos = utentparX('create_copy',win_denoise, ...
                    {'xloc',xlocINI,'top',ytopENT,...
                     'ent',{Ent_Nam,Ent_Par}} ...
                    );

        % Global De-noising tool.
        %------------------------        
        ytopTHR = toolPos(2)-4*dy;
        utthrwpdX('create',win_denoise,'toolOPT','wpdeno1', ...
                 'xloc',xlocINI,'top',ytopTHR ...
                 );

        % View Compressed Signal in another window.
        %==========================================
        [Pus_EST,Tog_RES] = ...
            utthrwpdX('get',win_denoise,'pus_est','tog_res');
        pos_Pus_EST = get(Pus_EST,'Position');
        pos_Tog_RES = get(Tog_RES,'Position');
        dx = pos_Tog_RES(1)-(pos_Pus_EST(1)+pos_Pus_EST(3));
        xleft = pos_Pus_EST(1)+dx/2;
        width = pos_Pus_EST(3)+pos_Tog_RES(3);
        pos_Pus_SigDorC = ...
            [xleft , pos_Pus_EST(2)-pos_Pus_EST(4)-3*dy , ...
             width , pos_Pus_EST(4)];
         
        Pus_SigDorC = uicontrol('Parent',win_denoise,...
                  'Style','pushbutton',...
                  'String','View Denoised Signal', ...
                  'Unit',win_units,...
                  'Position',pos_Pus_SigDorC, ...
                  'Enable','Off', ...
                  'Backgroundcolor',get(Pus_EST,'Backgroundcolor'), ...
                  'Userdata','Compressed', ...
                  'Tag','Pus_SigDorC' ...
                  );
        HDL = num2mstrX(win_denoise);
        cb_Pus_SigDorC = ['dw1dview_dorcX(' HDL ');'];
        set(Pus_SigDorC,'Callback',cb_Pus_SigDorC);
        %==================================================================
             
             
        % Adding colormap GUI.
        %---------------------
        pop_pal_caller = cbcolmapX('get',win_caller,'pop_pal');
        prop_pal = get(pop_pal_caller,{'String','Value','Userdata'});
        utcolmapX('create',win_denoise, ...
                 'xloc',xlocINI, ...
                 'bkcolor',Def_FraBkColor, ...
                 'briflag',0, ...
                 'enable','on');
        pop_pal_loc = cbcolmapX('get',win_denoise,'pop_pal');
        set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                        'Userdata',prop_pal{3});
        set(win_denoise,'Colormap',get(win_caller,'Colormap'));

        % Axes construction.
        %===================
        % General graphical parameters initialization.
        %--------------------------------------------
        bdx     = 0.08*pos_win(3);
        bdy     = 0.06*pos_win(4);
        ecy     = 0.03*pos_win(4);
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph;
        w_graph = pos_frame0(1);

        % Axes construction parameters.
        %------------------------------
        w_left     = (w_graph-3*bdx)/2;
        x_left     = bdx;
        w_right    = w_left;
        x_right    = x_left+w_left+5*bdx/4;
        n_axeright = 3;

        % Vertical separation.
        %---------------------
        w_fra   = 0.01*pos_win(3);
        x_fra   = (w_graph-w_fra)/2;
        uicontrol('Parent',win_denoise,...
                  'Style','frame',...
                  'Unit',win_units,...
                  'Position',[x_fra,y_graph,w_fra,h_graph],...
                  'Backgroundcolor',Def_FraBkColor ...
                  );

        % Building axes on the right part.
        %---------------------------------
        ecy_right = 2*ecy;
        h_right =(h_graph-2*bdy-(n_axeright-1)*ecy_right)/n_axeright;
        y_right = y_graph+bdy-ecy/2;
        axe_datas = zeros(1,n_axeright);
        pos_right = [x_right y_right w_right h_right];
        for k = 1:n_axeright
            axe_datas(k) = axes('Parent',win_denoise,...
                                'Units',win_units,...
                                'Position',pos_right,...
                                'Drawmode','fast',...
                                'Box','On'...
                                );
            pos_right(2) = pos_right(2)+pos_right(4)+ecy_right;
        end
        set(axe_datas(1),'visible','off');

        % Computing and Drawing Original Signal.
        %---------------------------------------
        Sig_Anal = get(wp1ddrawX('r_orig',win_caller),'Ydata');
        hdl_datas = [NaN NaN];
        axeAct = axe_datas(3);
        axes(axeAct)
        curr_color = wtbutilsX('colors','sig');
        xmin = 1;                       
        xmax = length(Sig_Anal);       
        hdl_datas(1) = line(xmin:xmax,Sig_Anal,...
                            'Color',curr_color, ...
                            'Parent',axeAct);
        wtitleX('Original signal','Parent',axeAct);
        ylim = [min(Sig_Anal) max(Sig_Anal)];
        if ylim(1)==ylim(2) , ylim = ylim+[-0.01 0.01]; end
        set(axeAct,'Xlim',[xmin xmax],'Ylim',ylim);

        % Displaying original details coefficients.
        %------------------------------------------
        axe_handles = findobj(get(win_caller,'Children'),'flat','type','axes');
        WP_Axe_Cfs  = findobj(axe_handles,'flat','Tag',tag_axe_cfs);
        xylim = get(WP_Axe_Cfs,{'Xlim','Ylim'});
        commonProp = {...
            'Xlim',xylim{1}, ...
            'Ylim',xylim{2}, ...
            'YTicklabelMode','manual', ...
            'YTicklabel',[], ...
            'YTick',[],      ...
            'Box','On'       ...
            };
        axeAct = axe_datas(2);
        axes(axeAct)
        wtitleX('Original coefficients','Parent',axeAct);
        set(axeAct,commonProp{:});
        wpplotcf(WP_Tree,cfsMode,axeAct);
        set(axe_datas(1),commonProp{:});

        % Initializing threshold.
        %------------------------
        [valTHR,maxTHR,cfs] = wp1ddenoX('compute_GBL_THR',win_denoise,win_caller);
        utthrwpdX('setThresh',win_denoise,[0,valTHR,maxTHR]);

        % Displaying perfos.
        %-------------------
        y_axe = y_graph+bdy+3*h_right/2+3*ecy;
        h_axe = 3*h_right/2+ecy/2;
        pos_axe_perfo = [x_left y_axe w_left h_axe];
        y_axe = y_graph+bdy-ecy/2;
        h_axe = 3*h_right/2+ecy/2;
        pos_axe_histo = [x_left y_axe w_left h_axe];
        utthrwpdX('displayPerf',win_denoise,pos_axe_perfo,pos_axe_histo,cfs);

        % Memory blocks update.
        %----------------------
        utthrwpdX('set',win_denoise,'handleORI',hdl_datas(1));        
        wmemtoolX('ini',win_denoise,n_misc_loc,nbLOC_1_stored);
        wmemtoolX('wmb',win_denoise,n_misc_loc,    ...
                       ind_sav_menus,sav_menus,   ...
                       ind_status,0,              ...
                       ind_win_caller,win_caller, ...
                       ind_axe_datas,axe_datas,   ...
                       ind_hdl_datas,hdl_datas,   ...
                       ind_cfsMode,cfsMode        ...
                       );
        wmemtoolX('ini',win_denoise,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = axe_datas(3);
        axe_act = axe_datas(1:2);
        dynvtoolX('init',win_denoise,[],axe_cmd,axe_act,[1 0]);

        % Setting units to normalized.
        %-----------------------------
        wfigmngrX('normalize',win_denoise);

        % End waiting.
        %-------------
        wwaitingX('off',win_denoise);

    case 'denoise'
        wp1ddenoX('clear_GRAPHICS',win_denoise);
 
        % Waiting message.
        %-----------------
        wwaitingX('msg',win_denoise,'Wait ... computing');

        % Getting memory blocks.
        %-----------------------
        [axe_datas,hdl_datas] = wmemtoolX('rmb',win_denoise,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);
        win_caller = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_win_caller);
        WP_Tree = wtbxappdataX('get',win_caller,'WP_Tree');

        % De-noising depending on the selected thresholding mode.
        %--------------------------------------------------------
        [numMeth,meth,threshold,sorh] = utthrwpdX('get_GBL_par',win_denoise); %#ok<ASGLU>
        thrParams = {sorh,'nobest',threshold,1};
        [C_Sig,C_Tree] = wpdencmpX(WP_Tree,thrParams{:}); C_Data = [];

        % Displaying de-noised signal.
        %-----------------------------
        lin_deno = hdl_datas(2);
        if ~ishandle(lin_deno)
            curr_color  = wtbutilsX('colors','ssig');
            lin_deno = line(...
                            'Parent',axe_datas(3),...
                            'Xdata',1:length(C_Sig),...
                            'Ydata',C_Sig,...
                            'color',curr_color);
            hdl_datas(2) = lin_deno;
            utthrwpdX('set',win_denoise,'handleTHR',hdl_datas(2));
            wmemtoolX('wmb',win_denoise,n_misc_loc,ind_hdl_datas,hdl_datas);
        else
            set(lin_deno,'Ydata',C_Sig,'Visible','on');
        end
        wtitleX('Original and de-noised signals','Parent',axe_datas(3));

        % Displaying thresholded details coefficients.
        %---------------------------------------------
        cfsMode = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_cfsMode);
        axeAct = axe_datas(1);
        delete(findobj(axeAct,'type','image'));
        wpplotcf(C_Tree,cfsMode,axeAct);
        xylim = get(axe_datas(2),{'Xlim','Ylim'});
        set(axeAct,'Xlim',xylim{1},'Ylim',xylim{2});
        wtitleX('Thresholded coefficients','Parent',axeAct);
        set(findobj(axeAct),'Visible','on');       

        % Memory blocks update.
        %----------------------
        wmemtoolX('wmb',win_denoise,n_thrDATA,ind_value,...
                 {C_Sig,C_Tree,C_Data,threshold});
        wp1ddenoX('enable_menus',win_denoise,'on');
 
        % End waiting.
        %-------------
        wwaitingX('off',win_denoise);

    case 'compute_GBL_THR'
        win_caller = varargin{2};
        pause(0.01)
        [numMeth,meth] = utthrwpdX('get_GBL_par',win_denoise); %#ok<ASGLU>
        WP_Tree = wtbxappdataX('get',win_caller,'WP_Tree');
        [valTHR,maxTHR,cfs] = wthrmngrX('wp1ddenoXGBL',meth,WP_Tree);
        if   nargout==1
            varargout = {valTHR};
        else
            varargout = {valTHR,maxTHR,cfs};
        end

    case 'update_GBL_meth'
        wp1ddenoX('clear_GRAPHICS',win_denoise);
        win_caller = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_win_caller);
        valTHR = wp1ddenoX('compute_GBL_THR',win_denoise,win_caller);
        utthrwpdX('update_GBL_meth',win_denoise,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_status);
        if status == 0 , return; end

        % Disable save Menus.
        %--------------------
        wp1ddenoX('enable_menus',win_denoise,'off');

        % Get Handles.
        %-------------
        [axe_datas,hdl_datas] = wmemtoolX('rmb',win_denoise,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);

        % Setting the de-noised coefs axes invisible.
        %--------------------------------------------
        lin_deno = hdl_datas(2);
        if ishandle(lin_deno)
            vis = get(lin_deno,'Visible');
            if isequal(vis(1:2),'on')
                axes(axe_datas(3));
                set(lin_deno,'Visible','off');
                wtitleX('Original signal','Parent',axe_datas(3));
                set(findobj(axe_datas(1)),'Visible','off');       
            end
        end
        drawnow

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_sav_menus);
        set(sav_menus,'Enable',enaVal);
        utthrwpdX('enable_tog_res',win_denoise,enaVal);
        if strncmpi(enaVal,'on',2) , status = 1; else status = 0; end
        wmemtoolX('wmb',win_denoise,n_misc_loc,ind_status,status);

    case 'save_synt'

       % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_denoise, ...
                                     '*.mat','Save De-noised Signal');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_denoise,'Wait ... saving');

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtoolX('rmb',win_caller,n_param_anal,ind_wav_name); %#ok<NASGU>
        thrDATA = wmemtoolX('rmb',win_denoise,n_thrDATA,ind_value);
        xc = thrDATA{1}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        try
          saveStr = name;
          eval([saveStr '= xc ;']);
        catch
          saveStr = 'xc';
        end
        wwaitingX('off',win_denoise);
        try
          save([pathname filename],saveStr,'valTHR','wname');
        catch
          errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_denoise, ...
                                   '*.wp1','Save Wavelet Packet Analysis (1D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_denoise,'Wait ... saving decomposition');

        % Getting Analysis parameters.
        %-----------------------------
        win_caller = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_win_caller);
        data_name  = wmemtoolX('rmb',win_caller,n_param_anal,ind_sig_name); %#ok<NASGU>

        % Getting Analysis values.
        %-------------------------
        thrDATA = wmemtoolX('rmb',win_denoise,n_thrDATA,ind_value);
        tree_struct = thrDATA{2}; %#ok<NASGU>
        valTHR  = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wp1'; filename = [name ext];
        end
        saveStr = {'tree_struct','data_name','valTHR'};
        wwaitingX('off',win_denoise);
        try
            save([pathname filename],saveStr{:});
        catch
            errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'close'
        [status,win_caller] = wmemtoolX('rmb',win_denoise,n_misc_loc,...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitansX({win_denoise,'WP1D De-noising'},...
                              'Update the synthesized signal ?',2,'cancel');
        end
        switch status
          case 1
            wwaitingX('msg',win_denoise,'Wait ... computing');
            thrDATA = wmemtoolX('rmb',win_denoise,n_thrDATA,ind_value);
            valTHR  = thrDATA{4};
            wmemtoolX('wmb',win_caller,n_param_anal,ind_thr_val,valTHR);
            hdl_datas = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_hdl_datas);
            lin_deno = hdl_datas(2);
            wp1dmngrX('return_deno',win_caller,status,lin_deno);
            wwaitingX('off',win_denoise);

          case 0 , wp1dmngrX('return_deno',win_caller,status);
        end
        if nargout>0 , varargout{1} = status; end

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid argument value.');
end
