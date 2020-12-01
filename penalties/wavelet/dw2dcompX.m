function varargout = dw2dcompX(option,varargin)
%DW2DCOMP Discrete wavelet 2-D compression.
%   VARARGOUT = DW2DCOMP(OPTION,VARARGIN)
              
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 16-May-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_param_anal   = 'DWAn2d_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
% ind_img_t_name = 4;
ind_img_size   = 5;
ind_nbcolors   = 6;
% ind_act_option = 7;
% ind_simg_type  = 8;
ind_thr_val    = 9;
% nb1_stored     = 9;

% MB2.1 and MB2.2.
%-----------------
n_coefs = 'MemCoefs';
n_sizes = 'MemSizes';

% MB1 (local).
%-------------
n_misc_loc = ['MB1_' mfilename];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
ind_pop_mod    = 6;
nbLOC_1_stored = 6;

% MB2 (local).
%-------------
n_thrDATA = 'thrDATA';
ind_value = 1;
nbLOC_2_stored = 1;

if ~isequal(option,'create') , win_compress = varargin{1}; end                
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
        win_name = 'Wavelet 2-D  --  Compression';
        [win_compress,pos_win,win_units,str_win_compress,pos_frame0] = ...
                 wfigmngrX('create',win_name,'',...
                     'ExtFig_CompDeno',{mfilename,'cond'});
        set(win_compress,'userdata',win_caller);
        varargout{1} = win_compress;

		% Add Help for Tool.
		%------------------
		wfighelpX('addHelpTool',win_compress,'Image Compression','DW2D_COMP_GUI');

		% Add Help Item.
		%----------------
		wfighelpX('addHelpItem',win_compress,'Compression Procedure','COMP_PROCEDURE');
		wfighelpX('addHelpItem',win_compress,'Available Methods','COMP_DENO_METHODS');
		wfighelpX('addHelpItem',win_compress,'Compressing Images','COMP_IMAGES');

		% Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngrX('getmenus',win_compress,'save');
        sav_menus(1) = uimenu(m_save,...
            'Label','Compressed &Image ',...
            'Position',1,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            [mfilename '(''save_synt'','    ...
            str_win_compress ');']  ...
            );
        sav_menus(2) = uimenu(m_save,...
            'Label','&Coefficients ',   ...
            'Position',2,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            [mfilename '(''save_cfs'','     ...
            str_win_compress ');']  ...
            );
        sav_menus(3) = uimenu(m_save,...
            'Label','&Decomposition ',  ...
            'Position',3,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            [mfilename '(''save_dec'','     ...
            str_win_compress ');'] ...
            );

        % Begin waiting.
        %---------------
        wwaitingX('msg',win_compress,'Wait ... initialization');

        % Getting  Analysis parameters.
        %------------------------------
        [Img_Name,Img_Size,Wav_Name,Lev_Anal] = ...
        wmemtoolX('rmb',win_caller,n_param_anal, ...
            ind_img_name,   ...
            ind_img_size,   ...
            ind_wav_name,   ...
            ind_lev_anal    ...
            );
        Wav_Fam = wavemngrX('fam_num',Wav_Name);
        isBior = wavemngrX('isbior',Wav_Fam);
        
        % To manage colormap tool for truecolor images.
        %----------------------------------------------
        vis_UTCOLMAP = wtbxappdataX('get',win_caller,'vis_UTCOLMAP');
        wtbxappdataX('set',win_compress,'vis_UTCOLMAP',vis_UTCOLMAP);

        % General parameters initialization.
        %-----------------------------------
        dy = Y_Spacing;
        str_dir_det = ...
            strvcat('Horizontal','Diagonal','Vertical'); %#ok<VCAT>
        str_pop_mod = ...
            strvcat('Global thresholding','By Level thresholding'); %#ok<VCAT>

        % Command & Graphic parts (common & global thresholding).
        %========================================================
        comFigProp = {'Parent',win_compress,'Unit',win_units};

        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanaparX('create_copy',win_compress, ...
                    {'xloc',xlocINI,'top',ytopINI},...
                    {'n_s',{Img_Name,Img_Size},'wav',Wav_Name,'lev',Lev_Anal} ...
                    );

        % Popup for mode.
        %----------------
        w_uic = (3*pos_frame0(3))/4;
        x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
        h_uic = Def_Btn_Height;
        y_uic = toolPos(2)-4*dy-h_uic;
        pos_pop_mod = [x_uic, y_uic, w_uic, h_uic];            
        pop_mod = uicontrol(comFigProp{:},...
            'Style','Popup',...
            'Position',pos_pop_mod,...
            'Userdata',1,...
            'String',str_pop_mod...
            );
        cba_pop_mod = [mfilename '(''change_mode'',' ...
                          str_win_compress ',' num2mstrX(pop_mod) ');'];
        set(pop_mod,'Callback',cba_pop_mod);

        % Global Compression tools.
        %-------------------------
        ytopTHR = pos_pop_mod(2)-4*dy;
        utthrgblX('create',win_compress,'toolOPT','dw2dcompX', ...
                 'xloc',xlocINI,'top',ytopTHR, ...
                 'isbior',isBior,   ...
                 'caller',mfilename ...
                 );
        % Adding colormap GUI.
        %---------------------
        briflag = (Lev_Anal<6); 
        if Lev_Anal<6
            pop_pal_caller = cbcolmapX('get',win_caller,'pop_pal');
            prop_pal = get(pop_pal_caller,{'String','Value','Userdata'});
            utcolmapX('create',win_compress, ...
                     'xloc',xlocINI, ...
                     'bkcolor',Def_FraBkColor, ...
                     'briflag',briflag, ...
                     'enable','on');
            pop_pal_loc = cbcolmapX('get',win_compress,'pop_pal');
            set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                            'Userdata',prop_pal{3});
            set(win_compress,'Colormap',get(win_caller,'Colormap'));
            cbcolmapX('visible',win_compress,vis_UTCOLMAP);
        end
 
        
        % Displaying the window title.
        %-----------------------------
        strX = sprintf('%.0f',Img_Size(2));
        strY = sprintf('%.0f',Img_Size(1));
        str_nb_val   = [' (' strX ' x ' strY ')'];
        str_wintitle = [Img_Name,str_nb_val,' analyzed at level ',...
            sprintf('%.0f',Lev_Anal),' with ',Wav_Name];
        wfigtitlX('string',win_compress,str_wintitle,'on');
        drawnow


        % Common axes properties.
        %------------------------
        comAxeProp = {...
            comFigProp{:},    ...
            'Units',win_units,...
            'Drawmode','fast',...
            'Box','On',       ...
            'Visible','off'   ...
            };


        % General graphical parameters initialization.
        %--------------------------------------------
        bdx_l   = 0.10*pos_win(3);
        bdx     = 0.08*pos_win(3);
        ecx     = 0.04*pos_win(3);
        w_graph = pos_frame0(1);
        if Lev_Anal<6
            bdy = 0.07*pos_win(4);
            ecy = 0.03*pos_win(4);
            div = 2.5;
        else
            bdy     = 0.06*pos_win(4);
            ecy     = 0.02*pos_win(4);
            div = 3.5;
        end
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph-Def_Btn_Height;
        
        
        % Building axes for original image.
        %----------------------------------
        x_axe           = bdx;
        w_axe           = (w_graph-ecx-3*bdx/2)/2;
        h_axe           = (h_graph-bdy)/div;
        y_axe           = y_graph+h_graph-h_axe-bdy;
        cx_ori          = x_axe+w_axe/2;
        cy_ori          = y_axe+h_axe/2;
        cx_cmp          = cx_ori+w_axe+ecx;
        cy_cmp          = cy_ori;
        [w_used,h_used] = wpropimgX(Img_Size,w_axe,h_axe,'pixels');
        pos_axe         = [cx_ori-w_used/2 cy_ori-h_used/2 w_used h_used];
        axe_datas(1)    = axes(comAxeProp{:},'Position',pos_axe);
        axe_orig        = axe_datas(1);
        
        
        % Displaying original image.
        %---------------------------
        Img_Anal  = get(dw2drwcdX('r_orig',win_caller),'Cdata');
        hdl_datas = [NaN;NaN];
        set(win_compress,'Colormap',get(win_caller,'Colormap'));
        hdl_datas(1) = image([1 Img_Size(1)],[1,Img_Size(2)],Img_Anal, ...
                            'Parent',axe_orig);
        wtitleX('Original image','Parent',axe_orig);

        % Building axes for compressed image.
        %------------------------------------
        pos_axe = [cx_cmp-w_used/2 cy_cmp-h_used/2 w_used h_used];
        xylim   = get(axe_orig,{'Xlim','Ylim'});
        axe_datas(2) = axes(comAxeProp{:},...
                            'Position',pos_axe,'Xlim',xylim{1},'Ylim',xylim{2});
        axe_comp = axe_datas(2);

        % Initializing global threshold.
        %-------------------------------
        [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
            dw2dcompX('compute_GBL_THR',win_compress,win_caller);
        utthrgblX('set',win_compress,'thrBOUNDS',[0,valTHR,maxTHR]);

        % Displaying perfos & legend.
        %----------------------------
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph-Def_Btn_Height;
        w_graph = pos_frame0(1);
        w_axe  = (w_graph-ecx-3*bdx/2)/2;
        h_axe  = (h_graph-3*bdy)/2;
        x_axe = bdx;
        y_axe = y_graph+bdy;
        pos_axe_perfo = [x_axe y_axe w_axe h_axe];
        x_axe = bdx+w_axe+ecx;
        y_axe = y_graph+w_axe/3+bdy;
        h_axe = w_axe/3;
        pos_axe_legend = [x_axe y_axe w_axe h_axe];
        utthrgblX('displayPerf',win_compress, ...
                  pos_axe_perfo,pos_axe_legend,thresVALUES,n0SCR,rl2SCR,valTHR);
        [perfl2,perf0] = utthrgblX('getPerfo',win_compress);
        utthrgblX('set',win_compress,'perfo',[perfl2,perf0]);
        drawnow

        % Command & Graphic parts (by Level thresholding).
        %=================================================
        % Compression tool.
        %-------------------
        utthrw2dX('create',win_compress, ...
                 'xloc',xlocINI,'top',ytopTHR,...
                 'ydir',-1, ...
                 'visible','off', ...
                 'enable','on', ...
                 'levmax',Lev_Anal, ...
                 'levmaxMAX',Lev_Anal, ...
                 'isbior',isBior,  ...
                 'toolOPT','comp' ...
                 );

        % Building axes for histograms.
        %------------------------------
        x_axe    = bdx;
        y_axe    = y_graph+bdy;
        h_axe_I  = (h_graph-bdy)/div;        
        h_axe    = (h_graph-h_axe_I-3*bdy-(Lev_Anal-1)*ecy)/Lev_Anal;
        w_axe    = (w_graph-2*ecx-3*bdx/2)/3;
        pos_axe  = [x_axe y_axe w_axe h_axe];
        axe_hist = zeros(3,Lev_Anal);
        for k = 1:Lev_Anal
            pos_axe(1) = bdx_l;
            pos_axe(2) = y_graph+bdy+(k-1)*(h_axe+ecy);
            for direct=1:3
                axe_hist(direct,k) = axes(comAxeProp{:},'Position',pos_axe);
                pos_axe(1) = pos_axe(1)+pos_axe(3)+ecx;
            end
        end
        utthrw2dX('set',win_compress,'axes',axe_hist);
        drawnow

        % Initializing by level threshold.
        %---------------------------------
        maxTHR = zeros(3,Lev_Anal);
        valTHR = dw2dcompX('compute_LVL_THR',win_compress,win_caller);
        coefs = wmemtoolX('rmb',win_caller,n_coefs,1);
        sizes = wmemtoolX('rmb',win_caller,n_sizes,1);
        for d=1:3
            for i=Lev_Anal:-1:1
                dir = lower(str_dir_det(d,1));
                c   = detcoef2X(dir,coefs,sizes,i);
                tmp = max(abs(c(:)));
                if tmp<eps , maxTHR(d,i) = 1; else maxTHR(d,i) = 1.1*tmp; end
            end
        end
        valTHR = min(maxTHR,valTHR);

        % Displaying details coefficients histograms.
        %--------------------------------------------
        dirDef   = 1;
        fontsize = wmachdepX('fontsize','normal');
        col_det  = wtbutilsX('colors','det',Lev_Anal);
        nb_bins  = 50;
        axeXColor = get(win_compress,'DefaultAxesXColor');        
        for level = 1:Lev_Anal
            for direct=1:3
                axeAct  = axe_hist(direct,level);
                axes(axeAct);
                dir        = lower(str_dir_det(direct,1));
                curr_img   = detcoef2X(dir,coefs,sizes,level);
                curr_color = col_det(level,:);
                his        = wgethistX(curr_img(:),nb_bins);
                his(2,:)   = his(2,:)/length(curr_img(:));
                wplothisX(axeAct,his,curr_color);
                if direct==dirDef
                    txt_hist(direct) = ...
                    txtinaxeX('create',['L_' sprintf('%.0f',level)],...
                             axeAct,'left','on',...
                             'bold',fontsize); %#ok<AGROW>
                    set(txt_hist(direct),'color',axeXColor);
                end
                if level==1
                    wxlabelX([deblank(str_dir_det(direct,:)) ' Details'],...
                            'color',axeXColor,...
                            'Parent',axeAct);
                end
                thr_val = valTHR(direct,level);
                thr_max = maxTHR(direct,level);
                ylim    = get(axeAct,'Ylim');
                utthrw2dX('plot_dec',win_compress,dirDef, ...
                          {thr_max,thr_val,ylim,direct,level,axeAct})
                xmax = 1.1*max([thr_max, max(abs(his(1,:)))]);
                set(axeAct,'Xlim',[-xmax xmax]);
                set(findall(axeAct),'Visible','off');
            end
        end

        % Initialization of Compression structure.
        %----------------------------------------
        utthrw2dX('set',win_compress,'valthr',valTHR,'maxthr',maxTHR);

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		wfighelpX('add_ContextMenu',win_compress,pop_mod,'DW2D_COMP_GUI');
		%-------------------------------------

        % Memory blocks update.
        %----------------------
        utthrgblX('set',win_compress,'handleORI',hdl_datas(1));
        utthrw2dX('set',win_compress,'handleORI',hdl_datas(1));
        wmemtoolX('ini',win_compress,n_misc_loc,nbLOC_1_stored);
        wmemtoolX('wmb',win_compress,n_misc_loc,  ...
                       ind_sav_menus,sav_menus,  ...
                       ind_status,0,             ...
                       ind_win_caller,win_caller,...
                       ind_axe_datas,axe_datas,  ...
                       ind_hdl_datas,hdl_datas,  ...
                       ind_pop_mod,pop_mod       ...
                       );
        wmemtoolX('ini',win_compress,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = [axe_orig axe_comp];
        axe_act = [];
        dynvtoolX('init',win_compress,[],axe_cmd,axe_act,[1 1],'','','','int');

        % Setting units to normalized.
        %-----------------------------
        wfigmngrX('normalize',win_compress);

        % End waiting.
        %-------------
        wwaitingX('off',win_compress);

    case 'compress'

        % Waiting message.
        %-----------------
        wwaitingX('msg',win_compress,'Wait ... computing');

        % Clear & Get Handles.
        %----------------------
        dw2dcompX('clear_GRAPHICS',win_compress);
        [win_caller,pop_mod]  = wmemtoolX('rmb',win_compress,n_misc_loc, ...
                                               ind_win_caller,ind_pop_mod);
        [axe_datas,hdl_datas] = wmemtoolX('rmb',win_compress,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);
        axe_orig = axe_datas(1);
        axe_comp = axe_datas(2);

        % Getting  Analysis parameters.
        %------------------------------
        [Img_Size,Wav_Name,Lev_Anal] = ...
         wmemtoolX('rmb',win_caller,n_param_anal, ...
                        ind_img_size, ...
                        ind_wav_name, ...
                        ind_lev_anal  ...
                        );
        coefs   = wmemtoolX('rmb',win_caller,n_coefs,1);
        sizes   = wmemtoolX('rmb',win_caller,n_sizes,1);
        Wav_Fam = wavemngrX('fam_num',Wav_Name);
        isBior  = wavemngrX('isbior',Wav_Fam);

        % Compression.
        %-------------
        mode_val = get(pop_mod,'value');
        switch mode_val
          case 1
            valTHR = utthrgblX('get',win_compress,'valthr');
            thrParams = {'gbl',coefs,sizes,Wav_Name,Lev_Anal,valTHR,'h',1};
          case 2
            valTHR = utthrw2dX('get',win_compress,'valthr');
            thrParams = {'lvd',coefs,sizes,Wav_Name,Lev_Anal,valTHR,'h'};
        end
        [xc,cxc,lxc] = wdencmpX(thrParams{:});
        clear thrParams
        
        switch mode_val
          case 1 , [perfl2,perf0] = utthrgblX('getPerfo',win_compress);
          case 2 , perf0 = 100*(length(find(cxc==0))/length(cxc));
        end
        
        if isBior
            img_orig = hdl_datas(1);
            Img_Anal = get(img_orig,'Cdata');
            if ndims(Img_Anal)<3
                n_ori = norm(Img_Anal);
                n_cfs = norm(xc);
            else
                n_ori = norm(coefs);
                n_cfs = norm(cxc);
            end
        elseif mode_val==2
            n_ori = norm(coefs);
            n_cfs = norm(cxc);
        end
        
        if isBior || mode_val==2
            if n_ori>eps
                perfl2 = 100*(norm(n_cfs)/n_ori)^2;
            else
                perfl2 = 100; 
            end
        end
        
        if isBior && ndims(Img_Anal)<3
            topTitle = 'Energy ratio ';
        else
            topTitle = 'Retained energy ';
        end

        % Displaying compressed image.
        %------------------------------
        hdl_comp = hdl_datas(2);
        if ishandle(hdl_comp)
            set(hdl_comp,'Cdata',wd2uiorui2dX('d2uint',xc),'Visible','on');
        else
            hdl_comp = image([1 Img_Size(1)],[1,Img_Size(2)],...
                wd2uiorui2dX('d2uint',xc),'Parent',axe_comp);
            hdl_datas(2) = hdl_comp;
            utthrgblX('set',win_compress,'handleTHR',hdl_comp);
            utthrw2dX('set',win_compress,'handleTHR',hdl_comp);
            wmemtoolX('wmb',win_compress,n_misc_loc,ind_hdl_datas,hdl_datas);
        end
        xylim = get(axe_orig,{'Xlim','Ylim'});
        set(axe_comp,'Xlim',xylim{1},'Ylim',xylim{2},'Visible','on');

        % Set a text as a super title.
        %-----------------------------
        wtitleX('Compressed image','Parent',axe_comp)
        txt_comp = [topTitle num2str(perfl2,'%5.2f') ...
                          ' % -- Zeros ' num2str(perf0,'%5.2f') ' %'];
        wtxttitlX(axe_comp,txt_comp);
        % Update the edit values (G492502)
        utthrgblX('set',win_compress,'perfo',[perfl2,perf0]);
        
        if mode_val==2
            utthrw2dX('set',win_compress,'perfos',{perfl2,perf0});
        end 

        % Memory blocks & HG update.
        %---------------------------
        switch mode_val
          case 1 , valTHR = utthrgblX('get',win_compress,'valthr');
          case 2 , valTHR = utthrw2dX('get',win_compress,'valthr');
        end
        wmemtoolX('wmb',win_compress,n_thrDATA,ind_value,{xc,cxc,lxc,valTHR});
        dw2dcompX('enable_menus',win_compress,'on');

        % End waiting.
        %-------------
        wwaitingX('off',win_compress);

    case 'change_mode'
        pop_mod = varargin{2}(1);
        mod_val = get(pop_mod,'value');
        old_mod = get(pop_mod,'userdata');
        if isequal(mod_val,old_mod) , return; end
        set(pop_mod,'userdata',mod_val);
        dw2dcompX('clear_GRAPHICS',win_compress);
        win_caller = wmemtoolX('rmb',win_compress,n_misc_loc,ind_win_caller);
        Lev_Anal = wmemtoolX('rmb',win_caller,n_param_anal,ind_lev_anal);        
        switch mod_val
          case 1
              visGBL = 'on';  visLVL = 'off'; visMAP = 'on';
          case 2
            visGBL = 'off'; visLVL = 'on';
            if Lev_Anal>3 , visMAP = 'off'; else visMAP = 'on'; end          
        end
        vis_UTCOLMAP = wtbxappdataX('get',win_compress,'vis_UTCOLMAP');
        if strcmpi(vis_UTCOLMAP,'off') , visMAP = 'Off'; end
        if Lev_Anal<6 , cbcolmapX('visible',win_compress,visMAP); end
        utthrgblX('visible',win_compress,visGBL);
        utthrw2dX('visible',win_compress,visLVL);

    case 'compute_GBL_THR'
        win_caller = varargin{2};
        [numMeth,meth] = utthrgblX('get_GBL_par',win_compress);
        coefs = wmemtoolX('rmb',win_caller,n_coefs,1);
        sizes = wmemtoolX('rmb',win_caller,n_sizes,1);
        thrFLAGS = 'dw2dcompXGBL';
        switch numMeth
          case {1,3}
            [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
                wthrmngrX(thrFLAGS,meth,coefs,sizes);
            if nargout==1
                varargout = {valTHR};
            else
                varargout = {valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR};
            end

          case 2
            img = get(dw2drwcdX('r_orig',win_caller),'Cdata');
            valTHR = wthrmngrX(thrFLAGS,meth,img);
            maxTHR = max(coefs(:));
            valTHR = min(valTHR,maxTHR);
            varargout = {valTHR};
        end

    case 'update_GBL_meth'
        dw2dcompX('clear_GRAPHICS',win_compress);
        win_caller = wmemtoolX('rmb',win_compress,n_misc_loc,ind_win_caller);
        valTHR = dw2dcompX('compute_GBL_THR',win_compress,win_caller);
        utthrgblX('update_GBL_meth',win_compress,valTHR);

    case 'show_LVL_perfos'
        win_caller = wmemtoolX('rmb',win_compress,n_misc_loc,ind_win_caller);
        coefs = wmemtoolX('rmb',win_caller,n_coefs,1);
        sizes = wmemtoolX('rmb',win_caller,n_sizes,1);
        lev_anal = wmemtoolX('rmb',win_caller,n_param_anal,ind_lev_anal);
        [numMeth,meth,scal,sorh] = utthrw2dX('get_LVL_par',win_compress); %#ok<ASGLU>
        valTHR = utthrw2dX('get',win_compress,'valTHR');
        [perfl2,perf0] = wscrupdX(coefs,sizes,lev_anal,valTHR,sorh);      
        utthrw2dX('set',win_compress,'perfos',{perfl2,perf0}); 

    case 'compute_LVL_THR'
        win_caller = varargin{2};
        [numMeth,meth,alfa,sorh] = utthrw2dX('get_LVL_par',win_compress);
        coefs = wmemtoolX('rmb',win_caller,n_coefs,1);
        sizes = wmemtoolX('rmb',win_caller,n_sizes,1);
        level = wmemtoolX('rmb',win_caller,n_param_anal,ind_lev_anal);

        thrFLAGS = 'dw2dcompXLVL';
        switch numMeth
          case {1,2,3,4,6} , valTHR = wthrmngrX(thrFLAGS,meth,coefs,sizes,alfa);
          case 5          
            img = get(dw2drwcdX('r_orig',win_caller),'Cdata');
            valTHR = wthrmngrX(thrFLAGS,meth,img,level);
        end
        [perfl2,perf0] = wscrupdX(coefs,sizes,level,valTHR,sorh);
        utthrw2dX('set',win_compress,'perfos',{perfl2,perf0}); 
        varargout = {valTHR,perfl2,perf0};

    case 'update_LVL_meth'
        dw2dcompX('clear_GRAPHICS',win_compress);
        win_caller = wmemtoolX('rmb',win_compress,n_misc_loc,ind_win_caller);
        valTHR = dw2dcompX('compute_LVL_THR',win_compress,win_caller);
        utthrw2dX('update_LVL_meth',win_compress,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtoolX('rmb',win_compress,n_misc_loc,ind_status);
        if status == 0 , return; end
 
        % Disable Toggles and Menus.
        %---------------------------
        dw2dcompX('enable_menus',win_compress,'off');

        % Get Handles.
        %-------------
        axe_datas = wmemtoolX('rmb',win_compress,n_misc_loc,ind_axe_datas);
        axe_comp = axe_datas(2);

        % Setting compressed axes invisible.
        %-----------------------------------
        set(findobj(axe_comp),'visible','off');
        drawnow

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtoolX('rmb',win_compress,n_misc_loc,ind_sav_menus);
        set(sav_menus,'Enable',enaVal);
        utthrgblX('enable_tog_res',win_compress,enaVal);
        utthrw2dX('enable_tog_res',win_compress,enaVal);
        if strncmpi(enaVal,'on',2) , status = 1; else status = 0; end
        wmemtoolX('wmb',win_compress,n_misc_loc,ind_status,status);
        
	case 'save_synt'
        win_caller = wmemtoolX('rmb',win_compress,n_misc_loc,ind_win_caller);
        wname = wmemtoolX('rmb',win_caller,n_param_anal,ind_wav_name); 
        thrDATA = wmemtoolX('rmb',win_compress,n_thrDATA,ind_value);
        X = round(thrDATA{1});
        valTHR = thrDATA{4};
        utguidivX('save_img','Save Compressed Image as', ...
            win_compress,X,'wname',wname,'valTHR',valTHR);
      
    case 'save_cfs'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_compress, ...
                                     '*.mat','Save Coefficients (2D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_compress,'Wait ... saving coefficients');

        % Getting Analysis values.
        %-------------------------
        win_caller  = wmemtoolX('rmb',win_compress,n_misc_loc,ind_win_caller);
        wname = wmemtoolX('rmb',win_caller,n_param_anal,ind_wav_name); %#ok<NASGU>
        map = cbcolmapX('get',win_caller,'self_pal');
        if isempty(map)
            nb_colors = wmemtoolX('rmb',win_caller,n_param_anal,ind_nbcolors);
            map = pink(nb_colors); %#ok<NASGU>
        end
        thrDATA = wmemtoolX('rmb',win_compress,n_thrDATA,ind_value);
        coefs = thrDATA{2}; %#ok<NASGU>
        sizes = thrDATA{3}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','map','valTHR','wname'};
        wwaitingX('off',win_compress);
        try
          save([pathname filename],saveStr{:});
        catch
          errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_compress, ...
                                     '*.wa2','Save Wavelet Analysis (2D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_compress,'Wait ... saving decomposition');


        % Getting Analysis values.
        %-------------------------
        win_caller  = wmemtoolX('rmb',win_compress,n_misc_loc,ind_win_caller);
        [wave_name,data_name,nb_colors] =    ...
                wmemtoolX('rmb',win_caller,n_param_anal, ...
                               ind_wav_name, ...
                               ind_img_name, ...
                               ind_nbcolors  ...
                               ); %#ok<ASGLU>
        map = cbcolmapX('get',win_caller,'self_pal');
        if isempty(map) , map = pink(nb_colors); end %#ok<NASGU>
        thrDATA = wmemtoolX('rmb',win_compress,n_thrDATA,ind_value);
        coefs = thrDATA{2}; %#ok<NASGU>
        sizes = thrDATA{3}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wa2'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','wave_name','map','valTHR','data_name'};
        wwaitingX('off',win_compress);
        try
          save([pathname filename],saveStr{:});
        catch
          errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'close'
        [status,win_caller] = wmemtoolX('rmb',win_compress,n_misc_loc, ...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitansX(win_compress,...
                              'Update the synthesized image ?',2,'cancel');
        end
        switch status
            case 1
              wwaitingX('msg',win_compress,'Wait ... computing');
              thrDATA = wmemtoolX('rmb',win_compress,n_thrDATA,ind_value);
              valTHR  = thrDATA{4};
              wmemtoolX('wmb',win_caller,n_param_anal,ind_thr_val,valTHR);
              hdl_datas = wmemtoolX('rmb',win_compress,n_misc_loc,ind_hdl_datas);
              img_comp  = hdl_datas(2);
              dw2dmngrX('return_comp',win_caller,status,img_comp);
              wwaitingX('off',win_compress);

            case 0 , dw2dmngrX('return_comp',win_caller,status);
        end
        if nargout>0 , varargout{1} = status; end


    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid Input Argument.');
end
