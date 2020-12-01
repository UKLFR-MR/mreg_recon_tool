function varargout = wp2dtoolX(option,varargin)
%WP2DTOOL Wavelet packets 2-D tool.
%   VARARGOUT = WP2DTOOL(OPTION,VARARGIN)
%
%   OPTION = 'create' , 'close' , 'read' , 'show'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Sep-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidivX('ini',option,varargin{:});

% Default values.
%----------------
% max_lev_anal = 5;
default_nbcolors = 255;

% Memory Blocks of stored values.
%================================
% MB0.
%-----
n_InfoInit   = 'WP2D_InfoInit';
% ind_filename = 1;
% ind_pathname = 2;
nb0_stored   = 2;

% MB1.
%-----
n_param_anal   = 'WP2D_Par_Anal';
% ind_img_name   = 1;
% ind_wav_name   = 2;
% ind_lev_anal   = 3;
% ind_ent_anal   = 4;
% ind_ent_par    = 5;
% ind_img_size   = 6;
% ind_img_t_name = 7;
% ind_act_option = 8;
% ind_thr_val    = 9;
nb1_stored     = 9;

% MB2.
%-----
n_wp_utils = 'WP_Utils';
% ind_tree_lin  = 1;
% ind_tree_txt  = 2;
% ind_type_txt  = 3;
% ind_sel_nodes = 4;
% ind_nb_colors = 6;
ind_gra_area  = 5;
nb2_stored    = 6;

% Tag property of objects.
%-------------------------
tag_m_exp_wrks = 'm_exp_wrks';
% tag_m_savesyn = 'Save_Syn';
% tag_m_savedec = 'Save_Dec';
tag_pus_anal  = 'Pus_Anal';
tag_pus_deno  = 'Pus_Deno';
tag_pus_comp  = 'Pus_Comp';
tag_pus_btree = 'Pus_Btree';
tag_pus_blev  = 'Pus_Blev';
tag_inittree  = 'Pus_InitTree';
tag_wavtree   = 'Pus_WavTree';
tag_curtree   = 'Pop_CurTree';
tag_nodlab    = 'Pop_NodLab';
tag_nodact    = 'Pop_NodAct';
tag_nodsel    = 'Pus_NodSel';
tag_txt_full  = 'Txt_Full';
tag_pus_full  = {'Pus_Full.1';'Pus_Full.2';'Pus_Full.3';'Pus_Full.4'};
tag_axe_t_lin = 'Axe_TreeLines';
tag_axe_sig   = 'Axe_Sig';
tag_axe_pack  = 'Axe_Pack';
tag_axe_cfs   = 'Axe_Cfs';
tag_axe_col   = 'Axe_Col';
tag_sli_size  = 'Sli_Size';
tag_sli_pos   = 'Sli_Pos';

switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,  ...
         X_Spacing,Y_Spacing,Def_FraBkColor] = ...
            mextglobX('get',...
              'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width', ...
              'X_Spacing','Y_Spacing','Def_FraBkColor');

        % Wavelet Packets 2-D window initialization.
        %-------------------------------------------
        [win_wptool,pos_win,win_units,str_numwin,...
             pos_frame0,Pos_Graphic_Area] = ...
                 wfigmngrX('create','Wavelet Packets 2-D',winAttrb,'ExtFig_Tool',...
                               mfilename,1,1,0);
        set(win_wptool,'tag',mfilename);
        if nargout>0 , varargout{1} = win_wptool; end
		
		% Add Coloration Mode Submenu.
		%-----------------------------
		wfigmngrX('add_CCM_Menu',win_wptool);
		
		% Add Help for Tool.
		%------------------
		wfighelpX('addHelpTool',win_wptool,'T&wo-Dimensional Analysis','WP2D_GUI');

		% Add Help Item.
		%----------------
		wfighelpX('addHelpItem',win_wptool,'Wavelet Packets','WP_PACKETS');
		wfighelpX('addHelpItem',win_wptool,'Tool Features','WP_TOOLS');
		wfighelpX('addHelpItem',win_wptool,'Loading and Saving','WP_LOADSAVE');

        % Menu construction for current figure.
        %--------------------------------------
		[m_files,m_load,m_save] = ...
			wfigmngrX('getmenus',win_wptool,'file','load','save');
        set(m_save,'Enable','Off')
        m_loadtst= uimenu(m_files,...
            'Label','&Example Analysis ', ...
            'Position',3,             ...
            'Separator','Off'         ...
            );
        m_demoIDX = uimenu(m_loadtst, ...
            'Label','Indexed Images ','Position',1);
        m_demoCOL = uimenu(m_loadtst, ...
            'Label','Truecolor Images ','Position',2);
        
        
        m_imp_wrks = uimenu(m_files,...
            'Label','Import from Workspace', ...
            'Position',4,'Separator','On'   ...
            );
        m_exp_wrks = uimenu(m_files,...
            'Label','Export to Workspace', ...
            'Position',5,'Enable','Off','Separator','Off', ...
            'Tag',tag_m_exp_wrks ...      
            );
        
        uimenu(m_load,...
            'Label','&Image ', ...
            'Position',1,          ...
            'Callback',['wp2dmngrX(''load_img'',' str_numwin ');'] ...
            );
        uimenu(m_load,...
            'Label','&Decomposition ', ...
            'Position',2,                  ...
            'Callback',['wp2dmngrX(''load_dec'',' str_numwin ');'] ...
            );

        uimenu(m_save,...
            'Label','&Synthesized Image ',...
            'Position',1,         ...
            'Callback',['wp2dmngrX(''save_synt'',' str_numwin ');'] ...
            );
        uimenu(m_save,...
            'Label','&Decomposition ', ...
            'Position',2,              ...
            'Callback',['wp2dmngrX(''save_dec'','  str_numwin ');']  ...
            );
                            
        beg_call_str = ['wp2dmngrX(''demo'',' str_numwin];

        lab             = 'db1 - depth : 1 - ent : shannon ---> woman ';
        end_call_str    = ',''woman'',''db1'',1,''shannon'',0,''BW'');';
        uimenu(m_demoIDX,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = 'db1 - depth : 1 - ent : shannon ---> detail  ';
        end_call_str    = ',''detail'',''db1'',1,''shannon'',0,''BW'');';
        uimenu(m_demoIDX,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = 'haar - depth : 2 - ent : shannon ---> tartan  ';
        end_call_str    = ',''tartan'',''haar'',2,''shannon'',0,''BW'');';
        uimenu(m_demoIDX,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = 'haar - depth : 2 - ent : shannon ---> detfingr  ';
        end_call_str    = ',''detfingr'',''haar'',2,''shannon'',0,''BW'');';
        uimenu(m_demoIDX,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = 'db2 - depth : 2 - ent : shannon ---> geometry  ';
        end_call_str    = ',''geometry'',''db2'',2,''shannon'',0,''BW'');';
        uimenu(m_demoIDX,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = 'db2 - depth : 2 - ent : shannon ---> sinsin  ';
        end_call_str    = ',''sinsin'',''db2'',2,''shannon'',0,''BW'');';
        uimenu(m_demoIDX,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = 'db2 - depth : 2 - ent : shannon ---> tire  ';
        end_call_str    = ',''tire'',''haar'',2,''shannon'',0,''BW'');';
        uimenu(m_demoIDX,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = 'sym6 - depth : 2 - ent : shannon ---> Barb ';
        end_call_str    = ',''wbarb'',''sym6'',2,''shannon'',0,''BW'');';
        uimenu(m_demoIDX,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = 'coif4 - depth : 2 - ent : shannon ---> facets  ';
        end_call_str    = ',''facets'',''coif4'',2,''shannon'',0,''BW'');';
        uimenu(m_demoIDX,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = 'bior4.4 - depth : 3- ent : shannon ---> noiswom  ';
        end_call_str    = ',''noiswom'',''bior4.4'',3,''shannon'',0,''BW'');';
        uimenu(m_demoIDX,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab             = 'bior6.8 - depth : 3- ent : shannon ---> Belmont 1  ';
        end_call_str    = ',''belmont1'',''bior6.8'',3,''shannon'',0,''BW'');';
        uimenu(m_demoIDX,'Label',lab,'Callback',[beg_call_str end_call_str]);
        
        lab = 'db1 - depth : 1 - ent : shannon ---> Jelly Fish';
        end_call_str     = ',''jellyfish256'',''db1'',1,''shannon'',0,''COL'');';
        uimenu(m_demoCOL,'Label',lab,'Callback',[beg_call_str end_call_str]);

        lab = 'sym4 - depth : 2 - ent : shannon ---> Wood Sculpture';
        end_call_str     = ',''woodsculp256.jpg'',''sym4'',2,''shannon'',0,''COL'');';
        uimenu(m_demoCOL,'Label',lab,'Callback',[beg_call_str end_call_str]);
        
        lab = 'bior4.4 - depth : 2 - ent : shannon ---> Arms (colored)';
        end_call_str     = ',''arms.jpg'',''bior4.4'',2,''shannon'',0,''COL'');';
        uimenu(m_demoCOL,'Label',lab,'Callback',[beg_call_str end_call_str]);

        uimenu(m_imp_wrks,...
            'Label','Import Image',...
            'Callback',['wp2dmngrX(''import_img'',' str_numwin ');'] ...
            );
        uimenu(m_imp_wrks,...
            'Label','Import Decomposition', ...
            'Callback',['wp2dmngrX(''import_dec'',' str_numwin ');'] ...
            );
        
        cb_beg = ['wp2dmngrX(''exp_wrks'',' str_numwin];        
        uimenu(m_exp_wrks,...
            'Label','Export Image','Callback',[cb_beg ',''sig'');'] ...
            );
        uimenu(m_exp_wrks,...
            'Label','Export Decomposition','Callback',[cb_beg ',''dec'');'] ...
            );        

        % Begin waiting.
        %---------------
        wwaitingX('msg',win_wptool,'Wait ... initialization');

        % General graphical parameters initialization.
        %--------------------------------------------
        dx = X_Spacing; dx2 = 2*dx;
        dy = Y_Spacing; dy2 = 2*dy;
        d_txt = (Def_Btn_Height-Def_Txt_Height);
        x_frame0   = pos_frame0(1);
        cmd_width  = pos_frame0(3);
        push_width = (cmd_width-3*dx2)/2;

        % Position property of objects.
        %------------------------------
        btn_H_1    = Def_Btn_Height;
        btn_H_2    = 1.5*Def_Btn_Height;
        btn_H_3    = 1.25*Def_Btn_Height;   
        ySpace_1   = dy2;
        ySpace_2   = 2*dy2;        
        xlocINI    = [x_frame0 cmd_width];
        ybottomINI = pos_win(4)-3.5*btn_H_1-ySpace_1;
        ybottomENT = ybottomINI-(btn_H_1+dy2)-dy;

        bdx        = (cmd_width-1.5*Def_Btn_Width)/2;
        x_left     = x_frame0+bdx;
        y_low      = ybottomENT - 2*(btn_H_1 + 1.5*dy2);
        pos_anal   = [x_left, y_low, 1.5*Def_Btn_Width, btn_H_2];

        x_left     = x_frame0+dx2;
        y_low      = y_low - btn_H_2 - ySpace_1;
        pos_comp   = [x_left, y_low, push_width, btn_H_2];

        pos_deno        = pos_comp;
        pos_deno(1)     = pos_deno(1)+pos_deno(3)+dx2;

        y_low           = y_low-btn_H_3-ySpace_2;
        pos_inittree    = [x_left, y_low, push_width, btn_H_3];

        pos_wavtree     = pos_inittree;
        pos_wavtree(1)  = pos_inittree(1)+pos_inittree(3)+dx2;

        y_low           = y_low-btn_H_3-dy/4;
        pos_btree       = [x_left, y_low, push_width, btn_H_3];
        pos_blev        = pos_btree;
        pos_blev(1)     = pos_btree(1)+pos_btree(3)+dx2;

        y_low         = y_low-btn_H_1-dy;
        wx            = cmd_width-2*dx2-dx;
        pos_t_curtree = [x_left, y_low+d_txt/2, (2*wx)/3, Def_Txt_Height];
        x_leftB       = pos_t_curtree(1)+pos_t_curtree(3)+dx;
        pos_curtree   = [x_leftB, y_low, wx/3, btn_H_1];

        y_low         = y_low-btn_H_1-ySpace_2;
        pos_t_nodlab  = [x_left, y_low+d_txt/2, wx/2, Def_Txt_Height];
        x_leftB       = pos_t_nodlab(1)+pos_t_nodlab(3)+dx;
        pos_nodlab    = [x_leftB, y_low, wx/2, btn_H_1];
 
        y_low         = y_low-btn_H_1-dy;
        pos_t_nodact  = [x_left, y_low+d_txt/2, wx/2, Def_Txt_Height];
        x_leftB       = pos_t_nodact(1)+pos_t_nodact(3)+dx;
        pos_nodact    = [x_leftB, y_low, wx/2, btn_H_1];

        y_low         = y_low-btn_H_1-dy;
        pos_t_nodsel  = [x_left, y_low+d_txt/2, wx/2+2*dx, Def_Txt_Height];
        x_leftB       = pos_t_nodsel(1)+pos_t_nodsel(3);
        pos_nodsel    = [x_leftB, y_low, wx/2-dx, btn_H_1];

        pos_t_nodlab(3) = pos_t_nodlab(3)-dx2;
        pos_nodlab(1)   = pos_nodlab(1)-dx2;
        pos_nodlab(3)   = pos_nodlab(3)+dx2;
        pos_t_nodact(3) = pos_t_nodact(3)-dx2;
        pos_nodact(1)   = pos_nodact(1)-dx2;
        pos_nodact(3)   = pos_nodact(3)+dx2;

        y_low           = pos_nodsel(2)-btn_H_1-ySpace_2;
        yl              = y_low-btn_H_1/2;
        pos_txt_full    = [x_left, yl, wx/3,btn_H_1];

        xl                = pos_txt_full(1)+pos_txt_full(3)+dx;
        pos_pus_full      = zeros(4,4);
        pos_pus_full(1,:) = [xl, y_low, wx/3, btn_H_1];
        pos_pus_full(2,:) = pos_pus_full(1,:);
        pos_pus_full(2,2) = pos_pus_full(2,2)-btn_H_1;
        pos_pus_full(3,:) = pos_pus_full(1,:);
        pos_pus_full(3,1) = pos_pus_full(3,1)+pos_pus_full(3,3);
        pos_pus_full(4,:) = pos_pus_full(3,:);
        pos_pus_full(4,2) = pos_pus_full(4,2)-pos_pus_full(4,4);

        % String property of objects.
        %----------------------------
        str_anal      = 'Analyze';
        str_btree     = 'Best Tree';
        str_comp      = 'Compress';
        str_blev      = 'Best Level';
        str_deno      = 'De-noise';
        str_inittree  = 'Initial Tree';
        str_wavtree   = 'Wavelet Tree';
        str_t_curtree = 'Cut Tree at Level : ';
        str_curtree   = '0';
        str_t_nodlab  = 'Node Label : ';
        str_nodlab    = 'Depth_Pos|Index|Entropy|Opt. Ent.|Size|None|Type|Energy';
        str_t_nodact  = 'Node Action : ';
        str_nodact    = 'Visualize|Split / Merge|Recons.|Select On';
        str_nodact    = [str_nodact '|Select Off|Statistics|View Col. Cfs'];
        str_t_nodsel  = 'Select Nodes and';
        str_nodsel    = 'Reconstruct';
        str_txt_full  = 'Full Size';

        % Callback property of objects.
        %------------------------------
        cba_WPOpt      = 'wptreeopX';
        cba_anal       = ['wp2dmngrX(''anal'',' str_numwin ');'];
        cba_comp       = ['wp2dmngrX(''comp'',' str_numwin ');'];
        cba_deno       = ['wp2dmngrX(''deno'',' str_numwin ');'];
        cba_btree      = [cba_WPOpt '(''best'',' str_numwin ');'];
        cba_blev       = [cba_WPOpt '(''blvl'',' str_numwin ');'];
        cba_inittree   = [cba_WPOpt '(''restore'',' str_numwin ');'];
        cba_wavtree    = [cba_WPOpt '(''wp2wtree'',' str_numwin ');'];
        cba_nodact     = [cba_WPOpt '(''nodact'',' str_numwin ');'];
        cba_nodlab     = [cba_WPOpt '(''nodlab'',' str_numwin ');'];
        cba_pus_nodsel = [cba_WPOpt '(''recons'',' str_numwin ');'];

        % Command part of the window.
        %============================

        % Data, Wavelet and Level parameters.
        %-------------------------------------
        utanaparX('create',win_wptool, ...
                 'xloc',xlocINI,'bottom',ybottomINI,...
                 'enable','off', ...
                 'wtype','dwtX'   ...
                 );

        % Entropy parameters.
        %--------------------
        utentparX('create',win_wptool, ...
                 'xloc',xlocINI,'bottom',ybottomENT, ...
                 'enable','off' ...
                 );

        comFigProp = {'Parent',win_wptool,'Unit',win_units};
        comPusProp = {comFigProp{:},'Style','Pushbutton','Enable','Off'};
        comPopProp = {comFigProp{:},'Style','Popupmenu','Enable','Off'};
        comTxtProp = {comFigProp{:},'Style','text', ...
           'HorizontalAlignment','left','Backgroundcolor',Def_FraBkColor};
        pus_anal = uicontrol(...
            comPusProp{:},       ...
            'Position',pos_anal, ...
            'String',xlate(str_anal),   ...
            'Tag',tag_pus_anal,  ...
            'Callback',cba_anal, ...
            'Interruptible','On' ...
            );

        uicontrol(...
            comPusProp{:},       ...
            'Position',pos_comp, ...
            'String',xlate(str_comp),   ...
            'Tag',tag_pus_comp,  ...
            'Callback',cba_comp  ...
            );

        uicontrol(...
            comPusProp{:},       ...
            'Position',pos_deno, ...
            'String',xlate(str_deno),   ...
            'Tag',tag_pus_deno,  ...
            'Callback',cba_deno  ...
            );

        uicontrol(...
            comPusProp{:},          ...
            'Position',pos_inittree,...
            'String',xlate(str_inittree),  ...
            'Tag',tag_inittree,     ...
            'Callback',cba_inittree ...
            );

        uicontrol(...
            comPusProp{:},          ...
            'Position',pos_wavtree, ...
            'String',xlate(str_wavtree),   ...
            'Tag',tag_wavtree,      ...
            'Callback',cba_wavtree  ...
            );

        pus_btree = uicontrol(...
            comPusProp{:},        ...
            'Position',pos_btree, ...
            'String',xlate(str_btree),   ...
            'Tag',tag_pus_btree,  ...
            'Callback',cba_btree  ...
            );

        uicontrol(...
            comPusProp{:},       ...
            'Position',pos_blev, ...
            'String',xlate(str_blev),   ...
            'Tag',tag_pus_blev,  ...
            'Callback',cba_blev  ...
            );

        pop_curtree = uicontrol(...
            comPopProp{:},          ...
            'Position',pos_curtree, ...
            'String',str_curtree,   ...
            'Tag',tag_curtree       ...
            );

        uicontrol(...
            comTxtProp{:},            ...
            'Position',pos_t_curtree, ...
            'String',str_t_curtree    ...
            );

        txt_nodlab = uicontrol(...
            comTxtProp{:},           ...
            'Position',pos_t_nodlab, ...
            'String',str_t_nodlab    ...
            );

        pop_nodlab = uicontrol(...
            comPopProp{:},         ...
            'Position',pos_nodlab, ...
            'String',str_nodlab,   ...
            'CallBack',cba_nodlab, ...
            'Tag',tag_nodlab       ...
            );

        txt_nodact = uicontrol(...
            comTxtProp{:},           ...
            'Position',pos_t_nodact, ...
            'String',str_t_nodact    ...
            );

        pop_nodact   = uicontrol(...
            comPopProp{:},         ...
            'Position',pos_nodact, ...
            'String',str_nodact,   ...
            'CallBack',cba_nodact, ...
            'Tag',tag_nodact       ...
            );

        txt_nodsel = uicontrol(...
            comTxtProp{:},           ...
            'Position',pos_t_nodsel, ...
            'String',str_t_nodsel    ...
            );

        pus_nodsel = uicontrol(...
            comPusProp{:},        ...
            'Position',pos_nodsel,  ...
            'String',xlate(str_nodsel),  ...
            'Tag',tag_nodsel,       ...
            'Callback',cba_pus_nodsel...
            );

        uicontrol(...
            comTxtProp{:},           ...
            'Position',pos_txt_full, ...
            'String',str_txt_full,   ...
            'Tag',tag_txt_full       ...
            );

        tooltip = {...
            'View decomposition tree',  ...
            'View node action result',...
            'View analyzed image', ...
            'View colored coefficients' ...
            };
        pus_full = zeros(1,4);
        for k=1:4
            pus_full(k) = uicontrol(...
                comPusProp{:},        ...
                'Position',pos_pus_full(k,:), ...
                'String',sprintf('%.0f',k),   ...
                'Userdata',0,                 ...
                'ToolTip',tooltip{k},         ...
                'Tag',tag_pus_full{k}         ...
                );
        end
        drawnow;

        % Adding colormap GUI.
        %---------------------
        utcolmapX('create',win_wptool, ...
                 'xloc',xlocINI, ...
                 'bkcolor',Def_FraBkColor);

        % Normalisation.
        %----------------
        Pos_Graphic_Area = wfigmngrX('normalize',win_wptool, ...
            Pos_Graphic_Area,'On');
        drawnow

        % Axes Construction.
        %---------------------
        [pos_axe_pack,   pos_axe_tree,   pos_axe_cfs, ...
         pos_axe_sig,    pos_sli_size,   pos_sli_pos  ...
         pos_axe_col] =  wpposaxeX(win_wptool,2,Pos_Graphic_Area);

        comFigProp = {'Parent',win_wptool,'Units','normalized','Visible','off'};
        WP_Sli_Siz = uicontrol(...
            comFigProp{:},          ...
            'Style','slider',       ...
            'Position',pos_sli_size,...
            'Min',0.5,              ...
            'Max',10,               ...
            'Value',1,              ...
            'UserData',1,           ...
            'Tag',tag_sli_size      ...
            );

        WP_Sli_Pos = uicontrol(...
            comFigProp{:},          ...
            'Style','slider',       ...
            'Position',pos_sli_pos, ...
            'Min',0,                ...
            'Max',1,                ...
            'Value',0,              ...
            'Tag',tag_sli_pos       ...
            );
        drawnow;
        commonProp = {...
           comFigProp{:},                  ...
           'XTicklabelMode','manual',      ...
           'YTicklabelMode','manual',      ...
           'XTicklabel',[],'YTicklabel',[],...
           'XTick',[],'YTick',[],          ...
           'Box','On'                      ...
           };

        axes(commonProp{:}, ...
            'XLim',[-0.5,0.5],       ...
            'YDir','reverse',        ...
            'YLim',[0 1],            ...
            'Position',pos_axe_tree, ...
            'Tag',tag_axe_t_lin      ...
            );
        axes(commonProp{:},'Position',pos_axe_pack,'Tag',tag_axe_pack);
        axes(commonProp{:},'Position',pos_axe_cfs,'Tag',tag_axe_cfs);
        axes(commonProp{:},'Position',pos_axe_sig,'Tag',tag_axe_sig);
        axes(commonProp{:},'Position',pos_axe_col,'Tag',tag_axe_col);

        % Callbacks update.
        %------------------
        utanaparX('set_cba_num',win_wptool,[m_files;pus_anal]);

        cba_curtree = [cba_WPOpt '(''cuttree'',' str_numwin ',' ...
                       num2mstrX(pop_curtree) ');'];

        cba_sli_siz = [cba_WPOpt '(''slide_size'',' str_numwin ',' ...
                       num2mstrX(WP_Sli_Siz) ',' ...
                       num2mstrX(WP_Sli_Pos) ');'];

        cba_sli_pos = [cba_WPOpt '(''slide_pos'',' str_numwin ',' ...
                       num2mstrX(WP_Sli_Pos) ');'];

        set(pop_curtree,'Callback',cba_curtree);
        set(WP_Sli_Siz,'Callback',cba_sli_siz);
        set(WP_Sli_Pos,'Callback',cba_sli_pos);
        beg_cba = ['wpfullsiX(''full'',' str_numwin ','];
        for k=1:4
            cba_pus_full = [beg_cba  sprintf('%.0f',k) ');'];
            set(pus_full(k),'Callback',cba_pus_full);
        end
        drawnow;

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_WP_TOOLS = [...
				txt_nodlab,pop_nodlab, ...
				txt_nodact,pop_nodact, ...
				txt_nodsel,pus_nodsel  ...
				];
		wfighelpX('add_ContextMenu',win_wptool,pus_btree,'WP_BESTTREE');
		wfighelpX('add_ContextMenu',win_wptool,hdl_WP_TOOLS,'WP_TOOLS');		
		%-------------------------------------

        % Memory for stored values.
        %--------------------------
        wmemtoolX('ini',win_wptool,n_InfoInit,nb0_stored);
        wmemtoolX('ini',win_wptool,n_param_anal,nb1_stored);
        wmemtoolX('ini',win_wptool,n_wp_utils,nb2_stored);
        wtbxappdataX('set',win_wptool,'WP_Tree',[]);
        wtbxappdataX('set',win_wptool,'WP_Tree_Saved',[]);
        wmemtoolX('wmb',win_wptool,n_wp_utils,ind_gra_area,Pos_Graphic_Area);

        % Setting Initial Colormap.
        %--------------------------
        cbcolmapX('set',win_wptool,'pal',{'pink',default_nbcolors});
        

        % End waiting.
        %---------------
        wwaitingX('off',win_wptool);

    case 'close'
        fig = varargin{1};
        called_win = wfindobjX('figure','Userdata',fig);
        delete(called_win);
        ssig_file = ['ssig_rec.' sprintf('%.0f',fig)];
        if exist(ssig_file,'file')==2 , 
           try  delete(ssig_file); catch end
        end

    case 'read'
        %****************************************************%
        %** OPTION = 'read' - read tree (and data struct). **%
        %****************************************************%
        % in2 = hdl fig
        %--------------
        % out1 = tree struct
        % (out2 = data struct - optional)
        %--------------------------------
        fig = varargin{1};
        err = 1-ishandle(fig);
        if err==0
            if ~strcmp(get(fig,'tag'),mfilename) , err = 1; end
        end
        if err
            errargtX(mfilename,'Invalid figure !','msg');
            return;
        end
        varargout{1} = wtbxappdataX('get',fig,'WP_Tree');

    case 'show'
        %**************************************************%
        %** OPTION = 'show' - show tree and data struct. **%
        %**************************************************%
        % in2 = hdl fig
        % in3 = tree struct
        % (in4 = data struct)
        %---------------------
        fig = varargin{1};
        err = 1-ishandle(fig);
        if err
            wp2dtoolX; err = 0;
        elseif ~strcmp(get(fig,'tag'),mfilename)
            err = 1;
        end
        if err
            errargtX(mfilename,'Invalid figure !','msg');
            return;
        end
        wp2dmngrX('load_dec',varargin{:});

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid argument value.');
end
