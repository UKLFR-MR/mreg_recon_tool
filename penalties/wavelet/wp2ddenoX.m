function varargout = wp2ddenoX(option,varargin)
%WP2DDENO Wavelet packets 2-D de-noising.
%   VARARGOUT = WP2DDENO(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 17-Jul-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Memory Blocks of stored values.
%================================
% MB1 (main window).
%-------------------
n_param_anal   = 'WP2D_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
% ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_img_size   = 6;
% ind_img_t_name = 7;
% ind_act_option = 8;
ind_thr_val    = 9;
% nb1_stored     = 9;

% MB2 (main window).
%-------------------
n_wp_utils = 'WP_Utils';
% ind_tree_lin  = 1;
% ind_tree_txt  = 2;
% ind_type_txt  = 3;
% ind_sel_nodes = 4;
% ind_gra_area  = 5;
ind_nb_colors = 6;
% nb2_stored    = 6;

% MB1 (local).
%-------------
n_misc_loc = ['MB1_' mfilename];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
% ind_cfsMode    = 6;
nbLOC_1_stored = 6;

% MB2 (local).
%-------------
n_thrDATA = 'thrDATA';
ind_value = 1;
nbLOC_2_stored = 1;

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

        % Window initialization.
        %----------------------
        win_name = 'Wavelet Packet 2-D  --  De-noising';
        [win_denoise,pos_win,win_units,str_win_denoise,pos_frame0] = ...
                    wfigmngrX('create',win_name,'','ExtFig_CompDeno', ...
                                {mfilename,'cond'},1,1,0);
        set(win_denoise,'userdata',win_caller);
        if nargout>0 , varargout{1} = win_denoise; end

		% Add Help Item.
		%----------------
		wfighelpX('addHelpItem',win_denoise,'De-noising Procedure','DENO_PROCEDURE');
		wfighelpX('addHelpItem',win_denoise,'Available Methods','COMP_DENO_METHODS');

        % Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngrX('getmenus',win_denoise,'save');
        sav_menus(1) = uimenu(m_save,...
            'Label','De-noised &Image ',    ...
            'Position',1,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            [mfilename '(''save_synt'','    ...
            str_win_denoise ');']   ...
            );
        sav_menus(2) =uimenu(m_save,...
            'Label','&Decomposition ',     ...
            'Position',2,                  ...
            'Enable','Off',                ...
            'Callback',                    ...
            [mfilename '(''save_dec'','    ...
            str_win_denoise ');']  ...
            );

        % Begin waiting.
        %---------------
        wwaitingX('msg',win_denoise,'Wait ... initialization');

        % Getting variables from wp2dtoolX figure memory block.
        %-----------------------------------------------------
        WP_Tree = wtbxappdataX('get',win_caller,'WP_Tree');
        depth = treedpthX(WP_Tree);
        [Img_Name,Wav_Name,Img_Size,Ent_Nam,Ent_Par] =  ...
                  wmemtoolX('rmb',win_caller,n_param_anal, ...
                                 ind_img_name,ind_wav_name, ...
                                 ind_img_size,    ...
                                 ind_ent_anal,ind_ent_par);
        vis_UTCOLMAP = wtbxappdataX('get',win_caller,'vis_UTCOLMAP');
        wtbxappdataX('set',win_denoise,'vis_UTCOLMAP',vis_UTCOLMAP);

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
                    {'n_s',{Img_Name,Img_Size},'wav',Wav_Name,'lev',depth} ...
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
        utthrwpdX('create',win_denoise,'toolOPT','wpdeno2', ...
                 'xloc',xlocINI,'top',ytopTHR ...
                 );

        % Adding colormap GUI.
        %---------------------
        pop_pal_caller = cbcolmapX('get',win_caller,'pop_pal');
        prop_pal = get(pop_pal_caller,{'String','Value','Userdata'});
        utcolmapX('create',win_denoise, ...
                 'xloc',xlocINI, ...
                 'bkcolor',Def_FraBkColor, ...
                 'enable','on');
        pop_pal_loc = cbcolmapX('get',win_denoise,'pop_pal');
        set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                        'Userdata',prop_pal{3});
        set(win_denoise,'Colormap',get(win_caller,'Colormap'));
        cbcolmapX('visible',win_denoise,vis_UTCOLMAP);

        % Axes construction.
        %===================
        % General graphical parameters initialization.
        %--------------------------------------------
        bdx     = 0.08*pos_win(3);
        ecx     = 0.04*pos_win(3);
        bdy     = 0.06*pos_win(4);
        % ecy     = 0.03*pos_win(4);
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph;
        w_graph = pos_frame0(1);

        % Building axes for original image.
        %----------------------------------
        x_axe  = bdx;
        w_axe  = (w_graph-ecx-3*bdx/2)/2;
        h_axe  = (h_graph-3*bdy)/2;
        y_axe  = y_graph+h_graph-h_axe-bdy;
        cx_ori = x_axe+w_axe/2;
        cy_ori = y_axe+h_axe/2;
        cx_den = cx_ori+w_axe+ecx;
        cy_den = cy_ori;
        [w_used,h_used] = wpropimgX(Img_Size,w_axe,h_axe,'pixels');
        pos_axe  = [cx_ori-w_used/2 cy_ori-h_used/2 w_used h_used];
        axe_datas(1) = axes('Parent',win_denoise,...
                            'Units',win_units,...
                            'Position',pos_axe,...
                            'Drawmode','fast',...
                            'Box','On');

        % Displaying original image.
        %---------------------------
        Img_Anal  = get(wp2ddrawX('r_orig',win_caller),'Cdata');
        hdl_datas = [NaN NaN];
        hdl_datas(1) = image([1 Img_Size(1)],[1,Img_Size(2)],Img_Anal,...
                             'Parent',axe_datas(1));
        wtitleX('Original image','Parent',axe_datas(1));

        % Building axes for de-noised image.
        %-----------------------------------
        pos_axe = [cx_den-w_used/2 cy_den-h_used/2 w_used h_used];
        xylim   = get(axe_datas(1),{'Xlim','Ylim'});
        axe_datas(2) = axes('Parent',win_denoise,...
                            'Units',win_units,...
                            'Position',pos_axe,...
                            'Drawmode','fast',...
                            'Visible','off',...
                            'Box','On',...
                            'Xlim',xylim{1},...
                            'Ylim',xylim{2});

        % Initializing threshold.
        %------------------------
        [valTHR,maxTHR,cfs] = ...
            wp2ddenoX('compute_GBL_THR',win_denoise,win_caller);
        utthrwpdX('setThresh',win_denoise,[0,valTHR,maxTHR]);

        % Displaying perfos.
        %-------------------
        x_axe = bdx;
        y_axe = y_graph+bdy;
        pos_axe_perfo = [x_axe y_axe w_axe h_axe];
        x_axe = bdx+w_axe+ecx;
        y_axe = y_graph+bdy;
        pos_axe_histo = [x_axe y_axe w_axe h_axe];
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
                       ind_hdl_datas,hdl_datas    ...
                       );
        wmemtoolX('ini',win_denoise,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = axe_datas;
        dynvtoolX('init',win_denoise,[],axe_cmd,[],[1 1]);

        % Setting units to normalized.
        %-----------------------------
        wfigmngrX('normalize',win_denoise);
 
        % End waiting.
        %-------------
        wwaitingX('off',win_denoise);

    case 'denoise'
        wp2ddenoX('clear_GRAPHICS',win_denoise);

        % Waiting message.
        %-----------------
        wwaitingX('msg',win_denoise,'Wait ... computing');

        % Getting memory blocks.
        %-----------------------
        [axe_datas,hdl_datas] = wmemtoolX('rmb',win_denoise,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);
        win_caller = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_win_caller);
        WP_Tree = wtbxappdataX('get',win_caller,'WP_Tree');
        Img_Size = wmemtoolX('rmb',win_caller,n_param_anal,ind_img_size);

        % De-noising depending on the selected thresholding mode.
        %--------------------------------------------------------
        [numMeth,meth,threshold,sorh] = utthrwpdX('get_GBL_par',win_denoise); %#ok<ASGLU>
        thrParams = {sorh,'nobest',threshold,1};
        [C_Img,C_Tree] = wpdencmpX(WP_Tree,thrParams{:}); C_Data = [];

        % Displaying de-noised image.
        %----------------------------
        img_deno = hdl_datas(2);
        if ~ishandle(img_deno)
            xylim = get(axe_datas(1),{'Xlim','Ylim'});
            img_deno = image([1 Img_Size(1)],[1,Img_Size(2)],...
                wd2uiorui2dX('d2uint',C_Img),'Parent',axe_datas(2));
            set(axe_datas(2),'Xlim',xylim{1},'Ylim',xylim{2});
            hdl_datas(2) = img_deno;
            utthrwpdX('set',win_denoise,'handleTHR',hdl_datas(2));
            wmemtoolX('wmb',win_denoise,n_misc_loc,ind_hdl_datas,hdl_datas);
        else
            set(img_deno,'Cdata',wd2uiorui2dX('d2uint',C_Img));
        end
        set(findobj(axe_datas(2)),'Visible','on');       
        wtitleX('De-noised image','Parent',axe_datas(2));

        % Memory blocks update.
        %----------------------
        wmemtoolX('wmb',win_denoise,n_thrDATA,ind_value, ...
                 {C_Img,C_Tree,C_Data,threshold});
        wp2ddenoX('enable_menus',win_denoise,'on');

        % End waiting.
        %-------------
        wwaitingX('off',win_denoise);

    case 'compute_GBL_THR'
        win_caller = varargin{2};
        pause(0.01)
        [numMeth,meth] = utthrwpdX('get_GBL_par',win_denoise); %#ok<ASGLU>
        WP_Tree = wtbxappdataX('get',win_caller,'WP_Tree');
        [valTHR,maxTHR,cfs] = wthrmngrX('wp2ddenoXGBL',meth,WP_Tree);
        if   nargout==1
            varargout = {valTHR};
        else
            varargout = {valTHR,maxTHR,cfs};
        end

    case 'update_GBL_meth'
        wp2ddenoX('clear_GRAPHICS',win_denoise);
        win_caller = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_win_caller);
        valTHR = wp2ddenoX('compute_GBL_THR',win_denoise,win_caller);
        utthrwpdX('update_GBL_meth',win_denoise,valTHR);

    case 'clear_GRAPHICS'
        % Disable save Menus.
        %--------------------
        wp2ddenoX('enable_menus',win_denoise,'off');

        % Get Handles.
        %-------------
        axe_datas = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_axe_datas);

        % Setting the de-noised coefs axes invisible.
        %--------------------------------------------
        axe_deno = axe_datas(2);
        if strcmpi(get(axe_deno,'Visible'),'on')
            set(findobj(axe_deno),'Visible','off');
            wtitleX('Original signal','Parent',axe_datas(1));
            drawnow
        end

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_sav_menus);
        set(sav_menus,'Enable',enaVal);
        utthrwpdX('enable_tog_res',win_denoise,enaVal);
        if strncmpi(enaVal,'on',2) , status = 1; else status = 0; end
        wmemtoolX('wmb',win_denoise,n_misc_loc,ind_status,status);

	case 'save_synt'
        win_caller = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtoolX('rmb',win_caller,n_param_anal,ind_wav_name); 
        thrDATA = wmemtoolX('rmb',win_denoise,n_thrDATA,ind_value);
        X = round(thrDATA{1});
        valTHR = thrDATA{4};
        utguidivX('save_img','Save De-noised Image as', ...
            win_denoise,X,'wname',wname,'valTHR',valTHR);

    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_denoise, ...
                                   '*.wp2','Save Wavelet Packet Analysis (2D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_denoise,'Wait ... saving decomposition');

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_win_caller);
        map = cbcolmapX('get',win_caller,'self_pal');
        if isempty(map)
            nb_colors = wmemtoolX('rmb',win_caller,n_wp_utils,ind_nb_colors);
            map = pink(nb_colors); %#ok<NASGU>
        end
        data_name = wmemtoolX('rmb',win_caller,n_param_anal,ind_img_name); %#ok<NASGU>
        thrDATA = wmemtoolX('rmb',win_denoise,n_thrDATA,ind_value);
        tree_struct = thrDATA{2}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wp2'; filename = [name ext];
        end
        saveStr = {'tree_struct','map','data_name','valTHR'};
        wwaitingX('off',win_denoise);
        try
          save([pathname filename],saveStr{:});
        catch %#ok<CTCH>
          errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'close'
        [status,win_caller] = wmemtoolX('rmb',win_denoise,n_misc_loc,...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitansX({win_denoise,'WP2D De-noising'},...
                              'Update the synthesized image ?',2,'cancel');
        end
        switch status
            case 1
              wwaitingX('msg',win_denoise,'Wait ... computing');
              thrDATA = wmemtoolX('rmb',win_denoise,n_thrDATA,ind_value);
              valTHR  = thrDATA{4};
              wmemtoolX('wmb',win_caller,n_param_anal,ind_thr_val,valTHR);
              hdl_datas = wmemtoolX('rmb',win_denoise,n_misc_loc,ind_hdl_datas);
              img_deno = hdl_datas(2);
              wp2dmngrX('return_deno',win_caller,status,img_deno);
              wwaitingX('off',win_denoise);

            case 0 , wp2dmngrX('return_deno',win_caller,status);
        end
        if nargout>0 , varargout{1} = status; end

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid argument value.');
end
