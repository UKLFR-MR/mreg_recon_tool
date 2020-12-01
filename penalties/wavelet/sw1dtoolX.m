function varargout = sw1dtoolX(option,varargin)
%SW1DTOOL Stationary Wavelet Transform 1-D tool.
%   VARARGOUT = SW1DTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Dec-97.
%   Last Revision: 29-Oct-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidivX('ini',option,varargin{:});

% Default values.
%----------------
max_lev_anal = 8;
def_lev_anal = 5;

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_membloc1   = 'MB_1';
ind_status   = 1;
ind_sav_menu = 2;
ind_filename = 3;
ind_pathname = 4;
ind_sig_name = 5;
ind_NB_lev   = 6;
ind_wave     = 7;
nb1_stored   = 7;

% MB2.
%-----
n_membloc2   = 'MB_2';
ind_pus_dec  = 1;
ind_chk_den  = 2;
ind_axe_hdl  = 3;
ind_lin_hdl  = 4;
ind_txt_hdl  = 5;
ind_lin_den  = 6;
ind_gra_area = 7;
nb2_stored   = 7;

% MB3.
%-----
n_membloc3 = 'MB_3';
ind_coefs  = 1;

% Tag property.
%---------------
tag_sig_ori = 'Sig_ori';
tag_app     = 'App';
tag_sig_den = 'Sig_den';
tag_noise   = 'Noise';

if ~isequal(option,'create') , win_tool = varargin{1}; end
switch option
    case 'create'

        % Get Globals.
        %-------------
        [Def_Btn_Height,Y_Spacing] = ...
            mextglobX('get','Def_Btn_Height','Y_Spacing');

        % Window initialization.
        %-----------------------
        win_title = 'Stationary Wavelet Transform Denoising 1-D';
        [win_tool,pos_win,win_units,str_numwin,...
            pos_frame0,Pos_Graphic_Area] = ...
                wfigmngrX('create',win_title,winAttrb, ...
                   'ExtFig_WTMOTION',mfilename,1,1,0);
        if nargout>0 , varargout{1} = win_tool; end
		
		% Add Help for Tool.
		%------------------
		wfighelpX('addHelpTool',win_tool, ...
			'One-Dimensional Analysis for Denoising','SW1D_GUI');

		% Add Help Item.
		%----------------
		wfighelpX('addHelpItem',win_tool,'Stationary Wavelet Transform','SWT');
		wfighelpX('addHelpItem',win_tool,'Available Methods','COMP_DENO_METHODS');
		wfighelpX('addHelpItem',win_tool,'Variance Adaptive Thresholding','VARTHR');
		wfighelpX('addHelpItem',win_tool,'Loading and Saving','SW1D_LOADSAVE');

        % Menu construction for current figure.
        %--------------------------------------
        m_files = wfigmngrX('getmenus',win_tool,'file');
        
        uimenu(m_files, ...
            'Label','&Load Signal', ...
            'Position',1, ...
            'Callback',[mfilename '(''load'',' str_numwin ');']  ...
            );

        m_save = uimenu(m_files,...
            'Label','&Save De-Noised Signal',...
            'Position',2,'Enable','Off',  ...
            'Callback',[mfilename '(''save'','  str_numwin ');'] ...
            );

		m_demo = uimenu(m_files,'Label','&Example Analysis','Position',3);
        uimenu(m_files, ...
            'Label','Import Signal from Workspace',   ...
            'Position',4,'Separator','On',...
            'Callback',[mfilename '(''load'',' str_numwin ',''load_wrks'');']...
            );
        m_exp_sig = uimenu(m_files, ...
            'Label','Export Signal to Workspace',   ...
            'Position',5,'Enable','Off','Separator','Off',...
            'Callback',[mfilename '(''exp_wrks'',' str_numwin ');']  ...
            );
        
        m_demo_1 = uimenu(m_demo,'Label','Noisy Signals');
        m_demo_2 = uimenu(m_demo,...
			'Label','Noisy Signals - Interval Dependent Noise Variance');

        demoSET = {...
          'Noisy blocks'    , 'noisbloc' , 'haar', 5 , '{}'  ; ...
          'Noisy bumps'     , 'noisbump' , 'sym4', 5 , '{}'  ; ...
          'Noisy heavysin'  , 'heavysin' , 'sym8', 5 , '{}'  ; ...
          'Noisy Doppler'   , 'noisdopp' , 'sym4', 5 , '{}'  ; ...
          'Noisy quadchirp' , 'noischir' , 'db1' , 5 , '{}'  ; ...
          'Noisy mishmash'  , 'noismima' , 'db3' , 6 , '{}'  ; ...
          'Noisy blocks'    , 'noisbloc' , 'haar', 5 , '{''penallo''}' ...
          };			   
        setDEMOS(m_demo_1,mfilename,str_numwin,demoSET,0)

        demoSET = {...
          'Noisy blocks (I)  - 3 intervals' , 'nblocr1' , 'haar', 5 , '{3}'  ; ...
          'Noisy blocks (II) - 3 intervals' , 'nblocr2' , 'haar', 5 , '{3}'  ; ...
          'Noisy Doppler (I) - 3 intervals' , 'ndoppr1' , 'haar', 5 , '{3}'  ; ...
          'Noisy bumps (I)   - 3 intervals' , 'nbumpr1' , 'haar', 5 , '{3}'  ; ...
          'Noisy bumps (II)  - 2 intervals' , 'nbumpr2' , 'haar', 5 , '{2}'  ; ...
          'Noisy bumps (III) - 4 intervals' , 'nbumpr3' , 'haar', 5 , '{4}'  ; ...
          'Elec. consumption - 3 intervals' , 'nelec'   , 'haar', 4 , '{3}'    ...
          };
        setDEMOS(m_demo_2,mfilename,str_numwin,demoSET,0)

        % Begin waiting.
        %---------------
        wwaitingX('msg',win_tool,'Wait ... initialization');

        % General parameters initialization.
        %-----------------------------------
        dy = Y_Spacing;
        str_pus_dec = 'Decompose Signal';
        str_chk_den = 'Overlay De-noised Signal';

        % Command part of the window.
        %============================
        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanaparX('create',win_tool, ...
                    'xloc',xlocINI,'top',ytopINI,...
                    'enable','off',        ...
                    'wtype','dwtX',         ...
                    'deflev',def_lev_anal, ...
                    'maxlev',max_lev_anal  ...
                    );
        
        % Decompose pushbutton.
        %----------------------
        h_uic = 3*Def_Btn_Height/2;
        y_uic = toolPos(2)-h_uic-2*dy;
        w_uic = (3*pos_frame0(3))/4;
        x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
        pos_pus_dec = [x_uic, y_uic, w_uic, h_uic];
        pus_dec = uicontrol(...
                            'Parent',win_tool,      ...
                            'Style','Pushbutton',   ...
                            'Unit',win_units,       ...
                            'Position',pos_pus_dec, ...
                            'String',xlate(str_pus_dec),   ...
                            'Enable','off',         ...
                            'Tag','Pus_Dec',        ...
                            'Interruptible','On'    ...
                            );

        % De-noising tool.
        %-----------------
        ytopTHR = pos_pus_dec(2)-4*dy;
        toolPos = utthrw1dX('create',win_tool, ...
                    'xloc',xlocINI,'top',ytopTHR,...
                    'ydir',-1, ...
                    'levmax',def_lev_anal,    ...
                    'levmaxMAX',max_lev_anal, ...
                    'status','Off',  ...
                    'toolOPT','deno' ...
                    );

        x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
        h_uic = Def_Btn_Height;
        y_uic = toolPos(2)-Def_Btn_Height/2-h_uic;
        pos_chk_den = [x_uic, y_uic, w_uic, h_uic];
        chk_den = uicontrol(...
                            'Parent',win_tool,      ...
                            'Style','checkbox',     ...
                            'Visible','on',         ...
                            'Unit',win_units,       ...
                            'Position',pos_chk_den, ...
                            'String',str_chk_den,   ...
                            'Tag','Chk_Den',        ...
                            'Enable','off'          ...
                            );

        % Callbacks update.
        %------------------
        hdl_den = utthrw1dX('handles',win_tool);
        utanaparX('set_cba_num',win_tool,[m_files;hdl_den(:)]);
        pop_lev = utanaparX('handles',win_tool,'lev');
        tmp     = num2mstrX([pop_lev chk_den]);
        end_cba = [str_numwin ',' tmp ');'];
        cba_pop_lev = [mfilename '(''update_level'',' end_cba];
        cba_pus_dec = [mfilename '(''decompose'',' str_numwin ');'];
        cba_chk_den = [mfilename '(''show_lin_den'',' str_numwin ');'];
        set(pop_lev,'Callback',cba_pop_lev);
        set(pus_dec,'Callback',cba_pus_dec);
        set(chk_den,'Callback',cba_chk_den);

        % General graphical parameters initialization.
        %--------------------------------------------
        txtfontsize = 14;
               
        % Axes parameters initialization.
        %--------------------------------
        w_gra_rem = Pos_Graphic_Area(3);
        h_gra_rem = Pos_Graphic_Area(4);
        NB_lev    = max_lev_anal;      % dummy
        ecx_left  = 0.08*pos_win(3);
        ecx_med   = 0.07*pos_win(3);
        ecx_right = 0.06*pos_win(3);
        w_left    = (w_gra_rem-ecx_left-ecx_med-ecx_right)/2;
        w_right   = w_left;
        w_medium  = w_left;
        x_left    = ecx_left;
        x_right   = x_left+w_left+ecx_med;
        x_medium  = (w_gra_rem-w_medium)/2;
        ecy_up    = 0.06*pos_win(4);
        ecy_mid_1 = 0.08*pos_win(4);
        ecy_mid_2 = 0.08*pos_win(4);
        ecy_det   = (0.04*pos_win(4))/1.4;
        ecy_mid_3 = ecy_det;
        ecy_down  = 0.04*pos_win(4);        
        h_min     = h_gra_rem/12;
        h_max     = h_gra_rem/5;
        h_axe_std = (h_min*NB_lev+h_max*(max_lev_anal-NB_lev))/max_lev_anal;
        h_space   = ecy_up+ecy_mid_1+ecy_mid_2+ecy_mid_3+ ...
                    NB_lev*ecy_det+ecy_down;
        h_detail  = (h_gra_rem-2*h_axe_std-h_space)/(NB_lev+1);
        y_low_ini = pos_win(4);

        % Building data axes.
        %--------------------
        commonProp = {...
           'Parent',win_tool,...
           'Visible','Off', ...
           'Units',win_units,...
           'Drawmode','fast',...
           'Box','On'...
           };
        y_low_ini   = y_low_ini-h_axe_std-ecy_up;
        pos_left    = [x_left y_low_ini w_left h_axe_std];
        axe_left_1  = axes(commonProp{:},'Position',pos_left);

        pos_right   = [x_right y_low_ini w_right h_axe_std];
        axe_right_1 = axes(commonProp{:},'Position',pos_right);

        y_low_ini   = y_low_ini-h_axe_std-ecy_mid_1;
        pos_medium  = [x_medium y_low_ini w_medium h_axe_std];
        axe_medium  = axes(commonProp{:},'Position',pos_medium);
        y_low_ini   = y_low_ini-ecy_mid_2;

        % Building approximation & details axes on the left part.
        %--------------------------------------------------------
        axe_left = zeros(1,max_lev_anal);
        txt_left = zeros(1,max_lev_anal);
        y_left   = y_low_ini;
        pos_left = [x_left y_left w_left h_detail];

        % Left approximation axes.
        %-------------------------
        pos_left(2) = pos_left(2)-pos_left(4);
        axe_app_l = axes(commonProp{:},'Position',pos_left);
        str_txt = ['a_' int2str(max_lev_anal)];
        txt_app_l = txtinaxeX('create',str_txt, ...
                              axe_app_l,'l','off','bold',txtfontsize);
        pos_left(2) = pos_left(2)-ecy_mid_3;

        % Left details axes.
        %-------------------
        for j = 1:NB_lev
            k =  NB_lev-j+1;
            pos_left(2) = pos_left(2)-pos_left(4)-ecy_det;
            axe_left(k) = axes(commonProp{:}, ...
                            'Position',pos_left,      ...
                            'XTicklabelMode','manual',...
                            'XTickLabel',[]           ...
                            );
            str_txt     = ['d' wnsubstrX(k)];
            txt_left(k) = txtinaxeX('create',str_txt, ...
                              axe_left(k),'l','off','bold',txtfontsize);
        end
        set(axe_left(1),'XTicklabelMode','auto');

        % Building approximation & details axes on the right part.
        %---------------------------------------------------------
        axe_right = zeros(1,max_lev_anal);
        txt_right = zeros(1,max_lev_anal);
        y_right   = y_low_ini;
        pos_right = [x_right y_right w_right h_detail];

        % Right approximation axes.
        %--------------------------
        pos_right(2) = pos_right(2)-pos_right(4);
        axe_app_r = axes(commonProp{:},'Position',pos_right);
        str_txt = ['a' wnsubstrX(max_lev_anal)];
        txt_app_r = txtinaxeX('create',str_txt, ...
                              axe_app_r,'r','off','bold',txtfontsize);
        pos_right(2) = pos_right(2)-ecy_mid_3;

        % Right details axes.
        %--------------------
        for j = 1:NB_lev
            k =  NB_lev-j+1;
            pos_right(2) = pos_right(2)-pos_right(4)-ecy_det;
            axe_right(k) = axes(commonProp{:}, ...
                            'Position',pos_right,     ...
                            'XTicklabelMode','manual',...
                            'XTickLabel',[]           ...
                            );
            str_txt      = ['d' wnsubstrX(k)];
            txt_right(k) = txtinaxeX('create',str_txt, ...
                              axe_right(k),'r','off','bold',txtfontsize);
        end
        set(axe_right(1),'XTicklabelMode','auto');

        %  Normalization.
        %----------------
        Pos_Graphic_Area = wfigmngrX('normalize',win_tool, ...
            Pos_Graphic_Area,'On');
        drawnow

        % Handles and Positions.
        %-----------------------
        axes_hdl = [axe_left_1 axe_right_1 axe_medium ... 
                    axe_left axe_app_l axe_right axe_app_r];
        lin_hdl  = NaN*ones(1,length(axes_hdl));
        text_hdl = [NaN NaN NaN txt_left txt_app_l txt_right txt_app_r];

        % Memory blocks update.
        %----------------------
        utthrw1dX('set',win_tool,'axes',axe_left);
        wmemtoolX('ini',win_tool,n_membloc1,nb1_stored);
        wmemtoolX('ini',win_tool,n_membloc2,nb2_stored);
        wmemtoolX('wmb',win_tool,n_membloc1, ...
                       ind_status,-1,      ...
                       ind_sav_menu,m_save ...
                       );
        wtbxappdataX('set',win_tool,'m_exp_sig',m_exp_sig);                   
        wmemtoolX('wmb',win_tool,n_membloc2,  ...
                       ind_pus_dec,pus_dec,  ...
                       ind_chk_den,chk_den,  ...
                       ind_axe_hdl,axes_hdl, ...
                       ind_lin_hdl,lin_hdl,  ...
                       ind_gra_area,Pos_Graphic_Area, ...
                       ind_txt_hdl,text_hdl, ...
                       ind_lin_den,NaN       ...
                       );

        % End waiting.
        %---------------
        wwaitingX('off',win_tool);

    case {'load','demo'}
        switch option
          case 'load'
              if length(varargin)<2       % LOAD SIGNAL
                  [sigInfos,sig_Anal,ok] = ...
                      utguidivX('load_sig',win_tool,'Signal_Mask','Load Signal');
                  
              elseif isequal(varargin{2},'load_wrks')  % LOAD from WORKSPACE
                  [sigInfos,sig_Anal,ok] = wtbximportX('1d');
              end
              if ~ok, return; end
              sig_Name = sigInfos.name;

          case 'demo'
            sig_Name = deblank(varargin{2});
            wav_Name = deblank(varargin{3});
            lev_Anal = varargin{4};
            if length(varargin)>4  && ~isempty(varargin{5})
                par_Demo = varargin{5};
            else
                par_Demo = '';
            end
            filename = [sig_Name '.mat'];
            pathname = utguidivX('WTB_DemoPath',filename);
            [sigInfos,sig_Anal,ok] = ...
                utguidivX('load_dem1D',win_tool,pathname,filename);
            if ~ok, return; end
        end

        % Begin waiting.
        %---------------
        wwaitingX('msg',win_tool,'Wait ... cleaning');

        % Setting Analysis parameters.
        %-----------------------------
        wmemtoolX('wmb',win_tool,n_membloc1, ...
                       ind_status,-1,       ...
                       ind_filename,sigInfos.filename, ...
                       ind_pathname,sigInfos.pathname, ...
                       ind_sig_name,sigInfos.name  ...
                       );

        % Cleaning and setting GUI. 
        %--------------------------
        cbanaparX('enable',win_tool,'Off');
        dynvtoolX('stop',win_tool)
        utthrsetX('stop',win_tool);
        ax_hdl  = wmemtoolX('rmb',win_tool,n_membloc2,ind_axe_hdl);
        obj2del = findobj(ax_hdl,'type','line');
        delete(obj2del)
        utthrw1dX('clean_thr',win_tool);
 
        % Setting analysis  & GUI values.
        %--------------------------------
        levm   = wmaxlevX(sigInfos.size,'haar');
        levmax = min(levm,max_lev_anal);
        if isequal(option,'demo')
            anaPar = {'wav',wav_Name};
        else
            lev_Anal = min(nextpow2(sigInfos.size),def_lev_anal);
            anaPar = {};
        end
        strlev = int2str((1:levmax)');
        anaPar = {anaPar{:},'n_s',{sig_Name,sigInfos.size}, ...
                  'lev',{'String',strlev,'Value',lev_Anal}}; %#ok<CCAT>
        cbanaparX('set',win_tool,anaPar{:});

        % Initial drawing (& analysis). 
        %------------------------------
        chk_den = wmemtoolX('rmb',win_tool,n_membloc2,ind_chk_den);
        sw1dtoolX('position',win_tool,lev_Anal,chk_den);
        sw1dtoolX('set_axes',win_tool,-1);
        sw1dtoolX('enable',win_tool,'ini','on');
        sw1dtoolX('plot_ini',win_tool,sig_Anal);
        if isequal(option,'demo')
            sw1dtoolX('decompose',win_tool);
            if ~isempty(par_Demo)
                 utthrw1dX('demo',win_tool,'sw1d',par_Demo);
            end
            sw1dtoolX('denoise',win_tool);
            sw1dtoolX('show_lin_den',win_tool,'On')
        end
        cbanaparX('enable',win_tool,'On');

        % End waiting.
        %-------------
        wwaitingX('off',win_tool);
        
    case 'save'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_tool, ...
                                     '*.mat','Save De-noised Signal');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_tool,'Wait ... saving');

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end

        % Get de-noising parameters & de-noised signal.
        %-----------------------------------------------
        [NB_lev,wname] = ...
            wmemtoolX('rmb',win_tool,n_membloc1,ind_NB_lev,ind_wave); %#ok<NASGU>
        [thrStruct,hdl_den] = utthrw1dX('get',win_tool,'thrstruct','handleTHR');
        thrParams = {thrStruct(1:NB_lev).thrParams}; %#ok<NASGU>
        sig_den   = get(hdl_den,'Ydata');
        try
            try
                eval([name ' = sig_den ;']);
            catch 
                x = sig_den; %#ok<NASGU>
                name = 'x';
            end
          saveStr = {name,'thrParams','wname'};
          save([pathname filename],saveStr{:});
        catch %#ok<*CTCH>
          errargtX(mfilename,'Save FAILED !','msg');
        end
   
        % End waiting.
        %-------------
        wwaitingX('off',win_tool);

    case 'exp_wrks'
        wwaitingX('msg',win_tool,'Wait ... exporting data');
        hdl_den = utthrw1dX('get',win_tool,'handleTHR');
        sig_den = get(hdl_den,'Ydata');
        wtbxexportX(sig_den,'name','sig_1D','title','Signal');
        wwaitingX('off',win_tool);        
        
    case 'decompose'
        % Compute decomposition and plot.                   
        %--------------------------------
        wwaitingX('msg',win_tool,'Wait ... computing');

        % Analysis parameters.
        %---------------------
        [wname,lev_Anal] = cbanaparX('get',win_tool,'wav','lev');

        % Test decomposition.
        %--------------------
        hdl_ori = utthrw1dX('get',win_tool,'handleORI');
        sig_ori = get(hdl_ori,'Ydata');
        xmin = 1;
        xmax = length(sig_ori);
        pow = 2^lev_Anal;
        if rem(xmax,pow)>0
            LenOK = ceil(xmax/pow)*pow;
            wwaitingX('off',win_tool);
            msg = sprintf([...
            [ '\n', 'The level of decomposition ' int2str(lev_Anal) '\n'],...
            ['and the length of the signal ' int2str(xmax)  '\n'],...
            'are not compatible.', '\n',...
            ['Suggested length: ' int2str(LenOK)],  '\n',...
            '(see Signal Extension Tool)', '\n', ...
            ' ', '\n', ...
            '2^Level has to divide the length of the signal.',  '\n' ...
            ]);
            errargtX(mfilename,msg,'msg');
            return
        end        

        % Clean.
        %--------
        utthrw1dX('clean_thr',win_tool);
        sw1dtoolX('show_lin_den',win_tool,'off')
        wmemtoolX('wmb',win_tool,n_membloc1, ...
                       ind_status,0,ind_NB_lev,lev_Anal,ind_wave,wname);

        % Decomposition.
        %---------------
        wDEC = swtX(sig_ori,lev_Anal,wname);
        wmemtoolX('wmb',win_tool,n_membloc3,ind_coefs,wDEC);

        % Initializing by level threshold.
        %---------------------------------
        maxTHR = zeros(1,lev_Anal);
        for k = 1:lev_Anal , maxTHR(k) = max(abs(wDEC(k,:))); end
        valTHR = sw1dtoolX('compute_LVL_THR',win_tool);
        valTHR = min(valTHR,maxTHR);

        % Plotting Decomposition.
        %------------------------
        hdl_lines = sw1dtoolX('plot_dec',win_tool,wDEC,valTHR,maxTHR,'Off');

        % Initialization of Denoising structure.
        %--------------------------------------- 
        utthrw1dX('set',win_tool,...
                       'thrstruct',{xmin,xmax,valTHR,hdl_lines},...
                       'intdepthr',[]);

        % Enabling HDLG.
        %---------------
        sw1dtoolX('enable',win_tool,'dec','on');

        % End waiting.
        %-------------
        wwaitingX('off',win_tool);

    case 'denoise'
        % De-noise and Plot.
        %-----------------------------------------------------
        % axes_hdl = [axe_left_1 axe_right_1 axe_medium ... 
        %             axe_left axe_app_l axe_right axe_app_r];
        %----------------------------------------------------

        % Begin waiting.
        %---------------
        wwaitingX('msg',win_tool,'Wait ... computing');


        % Disable De-noising Tool.
        %---------------------------
        utthrw1dX('enable',win_tool,'off');

        [axe_hdl,lin_hdl] = wmemtoolX('rmb',win_tool,n_membloc2, ...
                                           ind_axe_hdl,ind_lin_hdl);
        NB_lev  = wmemtoolX('rmb',win_tool,n_membloc1,ind_NB_lev);
        sig  = get(lin_hdl(1),'Ydata');
        wDEC = wmemtoolX('rmb',win_tool,n_membloc3,ind_coefs);
        wDEC = utthrw1dX('den_M1',win_tool,wDEC,length(sig));
        d_axe = 3+max_lev_anal+1;
        for k = 1:NB_lev
            ind = k+d_axe;
            vis = get(axe_hdl(ind),'Visible');
            set(lin_hdl(ind),'Ydata',wDEC(k,:),'Visible',vis);
        end

        % Set right approximation visible'.
        %----------------------------------
        set(lin_hdl(end),'Visible','On');

        % Plotting de-noised Signal.
        %---------------------------
        wname   = wmemtoolX('rmb',win_tool,n_membloc1,ind_wave);
        den_sig = iswtX(wDEC,wname);
        set(lin_hdl(2),'Ydata',den_sig,'Visible','On');
        lin_den = wmemtoolX('rmb',win_tool,n_membloc2,ind_lin_den);
        set(lin_den,'Ydata',den_sig);

        % Plotting "Noise".
        %-------------------
        residual = sig-den_sig;
        set(lin_hdl(3),'Ydata',residual,'Visible','On');

        % Dynvtool Attachment.
        %---------------------
        dynvtoolX('ini_his',win_tool,0);
        set(axe_hdl(3),'Ylim',getylim(residual));
        dynvtoolX('put',win_tool)

        % Enabling HDLG.
        %---------------
        utthrw1dX('enable',win_tool,'on');
        sw1dtoolX('enable',win_tool,'den','on');

        % End waiting.
        %-------------
        wwaitingX('off',win_tool);

    case 'show_lin_den'
        chk_den = wmemtoolX('rmb',win_tool,n_membloc2,ind_chk_den);
        if length(varargin)>1
            vis = lower(varargin{2});
            if isequal(vis,'on') , val = 1; else val = 0; end 
            set(chk_den,'value',val);
        else
            vis = deblank(getonoffX(get(chk_den,'value')));
        end
        [axe_hdl,lin_den] = wmemtoolX('rmb',win_tool,n_membloc2,...
                                           ind_axe_hdl,ind_lin_den);
        strTitle = 'Signal (S)';
        if isequal(vis,'on')
            strTitle = [strTitle ' and De-Noised Signal (D_S)'];
        end
        set(lin_den,'Visible',vis);
        wtitleX(strTitle,'Parent',axe_hdl(1))

    case 'position'
        lev_Anal = varargin{2};
        chk_den  = varargin{3};
        set(chk_den,'Visible','off');
        pos_old  = utthrw1dX('get',win_tool,'position');
        utthrw1dX('set',win_tool,'position',{1,lev_Anal})
        pos_new  = utthrw1dX('get',win_tool,'position');
        ytrans   = pos_new(2)-pos_old(2);
        pos_chk  = get(chk_den,'Position');        
        pos_chk(2) = pos_chk(2)+ytrans;
        set(chk_den,'Position',pos_chk,'Visible','on');

    case 'update_level'
        pop_lev = varargin{2}(1);
        chk_den  = varargin{2}(2);
        if ~ishandle(pop_lev)
            handles = guihandles(gcbf);
            pop_lev = handles.Pop_Lev;
            chk_den = handles.Chk_Den;
        end
        lev_New  = get(pop_lev,'value');
        sw1dtoolX('position',win_tool,lev_New,chk_den);
        [status,lev_Anal] = wmemtoolX('rmb',win_tool,n_membloc1,...
            ind_status,ind_NB_lev);
        sw1dtoolX('set_axes',win_tool,status);
        vis_Lines = 'off';
        vis_den_ovr = 'off';
        if isequal(lev_New,lev_Anal)
            switch status
                case -1 , 
                    sw1dtoolX('enable',win_tool,'ini');
                case  0 ,
                    sw1dtoolX('enable',win_tool,'dec');
                case  1 ,
                    vis_Lines = 'on';
                    val = get(chk_den,'Value');
                    if val==1 , vis_den_ovr = 'on'; end
                    sw1dtoolX('enable',win_tool,'dec','on');
                    sw1dtoolX('enable',win_tool,'den','on');
                    set(chk_den,'Value',val);
            end
        else
            sw1dtoolX('enable',win_tool,'ini');
        end
        
        % Get Handles.
        %-------------
        [axe_hdl,lin_den] = wmemtoolX('rmb',win_tool,n_membloc2,...
            ind_axe_hdl,ind_lin_den);
        NBaxes = length(axe_hdl);
        %-----------------------------------------------------
        % axes_hdl = [axe_left_1 axe_right_1 axe_medium ...
        %             axe_left axe_app_l axe_right axe_app_r];
        %-----------------------------------------------------
        NBaxdet = (NBaxes-5)/2;
        i_app_l = 3+NBaxdet+1;
        indOff  = [2,3,i_app_l+(1:NBaxdet),NBaxes];
        axe_Off = axe_hdl(indOff);
        axe_Off = axe_Off(ishandle(axe_Off));
        lin_Off = findobj(axe_Off,'type','line');
        set(lin_Off,'Visible',vis_Lines);
        set(lin_den(1),'Visible',vis_den_ovr);

    case 'compute_LVL_THR'
        [numMeth,meth,alfa] = utthrw1dX('get_LVL_par',win_tool); %#ok<ASGLU>
        wDEC = wmemtoolX('rmb',win_tool,n_membloc3,ind_coefs);
        varargout{1} = wthrmngrX('sw1ddenoLVL',meth,wDEC,alfa);

    case 'update_LVL_meth'
        sw1dtoolX('clear_GRAPHICS',win_tool);
        valTHR = sw1dtoolX('compute_LVL_THR',win_tool);
        utthrw1dX('update_LVL_meth',win_tool,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtoolX('rmb',win_tool,n_membloc1,ind_status);
        if status<1 , return; end

        % Disable Toggle and Menus.
        %---------------------------
        sw1dtoolX('enable',win_tool,'den','off');

        % Get Handles.
        %-------------
        [axe_hdl,lin_hdl] = wmemtoolX('rmb',win_tool,n_membloc2,...
                                           ind_axe_hdl,ind_lin_hdl);
        NBaxes = length(axe_hdl);
        %-----------------------------------------------------
        % axes_hdl = [axe_left_1 axe_right_1 axe_medium ...
        %             axe_left axe_app_l axe_right axe_app_r];
        %-----------------------------------------------------
        lin_den = wmemtoolX('rmb',win_tool,n_membloc2,ind_lin_den);
        sw1dtoolX('show_lin_den',win_tool,'off')
        set(lin_den,'Ydata',get(lin_hdl(1),'Ydata'));
        NBaxdet = (NBaxes-5)/2;
        i_app_l = 3+NBaxdet+1;
        indOff  = [2,3,i_app_l+(1:NBaxdet),NBaxes];
        axe_Off = axe_hdl(indOff);
        axe_Off = axe_Off(ishandle(axe_Off));
        lin_Off = findobj(axe_Off,'type','line');
        set(lin_Off,'Visible','off');

    case 'enable'
        type    = varargin{2};
        m_save   = wmemtoolX('rmb',win_tool,n_membloc1,ind_sav_menu);
        m_exp_sig = wtbxappdataX('get',win_tool,'m_exp_sig');
        m_SAV_EXP = [m_save,m_exp_sig];        
        chk_den = wmemtoolX('rmb',win_tool,n_membloc2,ind_chk_den);
        switch type 
          case 'ini'
            pus_dec = wmemtoolX('rmb',win_tool,n_membloc2,ind_pus_dec);
            set([m_SAV_EXP,chk_den],'Enable','off');
            utthrw1dX('status',win_tool,'off');
            set(pus_dec,'Enable','on');

          case 'dec'
            level = wmemtoolX('rmb',win_tool,n_membloc1,ind_NB_lev);
            set(m_SAV_EXP,'Enable','off');
            utthrw1dX('status',win_tool,'on');
            utthrw1dX('enable',win_tool,'on',(1:level));

          case 'den'
            enaVal = varargin{3};
            set([m_SAV_EXP,chk_den],'Enable',enaVal);
            utthrw1dX('enable_tog_res',win_tool,enaVal);
            if strncmpi(enaVal,'on',2) , status = 1; else status = 0; end
            wmemtoolX('wmb',win_tool,n_membloc1,ind_status,status);
        end

    case 'set_axes'
        %*************************************************************%
        %** OPTION = 'set_axes' - Set axes positions and visibility **%
        %*************************************************************%
        status = varargin{2};
        [ax_hdl,lin_hdl,Pos_Graphic_Area] = ...
            wmemtoolX('rmb',win_tool,n_membloc2, ...
                     ind_axe_hdl,ind_lin_hdl,ind_gra_area);
        NB_lev = cbanaparX('get',win_tool,'lev');

        % Hide axes
        %-----------
        lin_den = wmemtoolX('rmb',win_tool,n_membloc2,ind_lin_den);
        if ishandle(lin_den)
            vis_den = get(lin_den,'Visible');
        else
            vis_den = 'off';
        end
        obj_in_axes = findobj(ax_hdl);
        set(obj_in_axes,'Visible','off');

        % Plots.
        %---------------------------------------------------
        % ax_hdl = [axe_left_1 axe_right_1 axe_medium ... 
        %           axe_left axe_app_l axe_right axe_app_r];
        %---------------------------------------------------
        NBaxes  = length(ax_hdl);
        ax_l_1  = ax_hdl(1);
        ax_r_1  = ax_hdl(2);
        ax_med  = ax_hdl(3);
        NBaxdet = (NBaxes-5)/2;
        i_app_l = 3+NBaxdet+1;
        i_app_r = NBaxes;
        ax_det   = ax_hdl(4:i_app_l-1);
        ax_app_l = ax_hdl(i_app_l);
        ax_deno  = ax_hdl(i_app_l+1:i_app_r-1);
        ax_app_r = ax_hdl(i_app_r);

        % Axes parameters initialization.
        %--------------------------------
        pos_win   = get(win_tool,'Position');
        h_gra_rem = Pos_Graphic_Area(4);
        ecy_up    = 0.06*pos_win(4);
        ecy_mid_1 = 0.08*pos_win(4);
        ecy_mid_2 = 0.08*pos_win(4);
        ecy_det   = (0.04*pos_win(4))/1.4;
        ecy_mid_3 = ecy_det;
        ecy_down  = 0.04*pos_win(4);        
        h_min     = h_gra_rem/12;
        h_max     = h_gra_rem/5;
        h_axe_std = (h_min*NB_lev+h_max*(max_lev_anal-NB_lev))/max_lev_anal;
        h_space   = ecy_up+ecy_mid_1+ecy_mid_2+ecy_mid_3+ ...
                    NB_lev*ecy_det+ecy_down;
        h_detail  = (h_gra_rem-2*h_axe_std-h_space)/(NB_lev+1);
        y_low_ini = 1;
 
        % Building data axes.
        %--------------------
        y_low_ini       = y_low_ini-h_axe_std-ecy_up;
        pos_axes        = get(ax_l_1,'Position');
        pos_axes([2 4]) = [y_low_ini h_axe_std];
        set(ax_l_1,'Position',pos_axes);
        axe_vis         = ax_l_1;

        pos_axes        = get(ax_r_1,'Position');
        pos_axes([2 4]) = [y_low_ini h_axe_std];
        set(ax_r_1,'Position',pos_axes)
        axe_vis         = [axe_vis ax_r_1];
        
        y_low_ini       = y_low_ini-h_axe_std-ecy_mid_1;
        pos_axes        = get(ax_med,'Position');
        pos_axes([2 4]) = [y_low_ini h_axe_std];
        set(ax_med,'Position',pos_axes)
        axe_vis         = [axe_vis ax_med];

        % Position for approximation & details axes on the left part.
        %------------------------------------------------------------
        y_low_ini = y_low_ini-ecy_mid_2;
        pos_axes  = get(ax_l_1,'Position');
        pos_y     = [y_low_ini , h_detail];

        % Left approximation axes.
        %-------------------------
        pos_y(1) = pos_y(1)-h_detail;
        pos_axes([2 4]) = pos_y;
        set(ax_app_l,'Position',pos_axes);
        axe_vis  = [axe_vis ax_app_l];
        pos_y(1) = pos_y(1)-ecy_mid_3;

        % Left details axes.
        %-------------------
        for j = 1:NB_lev
            i_axe   = NB_lev-j+1;
            ax_act  = ax_det(i_axe);
            pos_axes = get(ax_act,'Position');
            pos_y(1) = pos_y(1)-h_detail-ecy_det;
            pos_axes([2 4]) = pos_y;
            set(ax_act,'Position',pos_axes);
            axe_vis = [axe_vis ax_act]; %#ok<AGROW>
        end
        i_ax_det_Title = NB_lev;

        % Position for approximation & details axes on the right part.
        %-------------------------------------------------------------
        pos_axes = get(ax_r_1,'Position');
        pos_y    = [y_low_ini , h_detail];

        % Right approximation axes.
        %--------------------------
        pos_y(1) = pos_y(1)-h_detail;
        pos_axes([2 4]) = pos_y;
        set(ax_app_r,'Position',pos_axes);
        axe_vis = [axe_vis ax_app_r];
        pos_y(1) = pos_y(1)-ecy_mid_3;

        % Right details axes.
        %--------------------
        for j = 1:NB_lev
            i_axe   = NB_lev-j+1;
            ax_act  = ax_deno(i_axe);
            pos_axes = get(ax_act,'Position');
            pos_y(1) = pos_y(1)-h_detail-ecy_det;
            pos_axes([2 4]) = pos_y;
            set(ax_act,'Position',pos_axes);
            axe_vis = [axe_vis ax_act]; %#ok<AGROW>
        end
        i_ax_den_Title = NB_lev;

        % Modification of app_text.
        %--------------------------
        if status<0  % Initialize
            txt_hdl = wmemtoolX('rmb',win_tool,n_membloc2,ind_txt_hdl);
            txt_app_l = txt_hdl(i_app_l);
            txt_app_r = txt_hdl(i_app_r);
            num_app = NB_lev;
            str_app = ['a' wnsubstrX(num_app)];
            set(txt_app_l,'string',str_app);
            set(txt_app_r,'string',str_app);
        end

        % Set axes.
        %-----------
        axeNoXTick = [ax_app_l,ax_det((2:NB_lev)),ax_app_r,ax_deno(2:NB_lev)];
        set(axeNoXTick,'Xtick',[],'XtickLabel',[]);
        titles = get([ax_det;ax_deno],'title');
        set(cat(1,titles{:}),'String','');
        obj_in_axes_vis = findobj(axe_vis);
        
        if isequal(vis_den,'off')
            indLineDEN = [2,3,i_app_l+1:i_app_r];
            notVisible = lin_hdl(indLineDEN)';
            obj_in_axes_vis = setdiff(obj_in_axes_vis,notVisible);
        end
        set(obj_in_axes_vis,'Visible','on');
        if ishandle(lin_den) , set(lin_den,'Visible',vis_den); end

        % Setting axes title
        %--------------------
        wtitleX('Signal (S)','Parent',ax_l_1)
        wtitleX('Residuals = S - D_S','Parent',ax_med)
        wtitleX('De-Noised Signal (D_S)','Parent',ax_r_1)
        axAct = ax_det(i_ax_det_Title);
        wtitleX('Non-decimated Details Coefficients','Parent',axAct);
        axAct = ax_deno(i_ax_den_Title);
        wtitleX('De-noised non-decimated Details Coefficients','Parent',axAct);
        wtitleX('Non-decimated Approximation Coefficients','Parent',ax_app_l);
        wtitleX('Non-decimated Approximation Coefficients','Parent',ax_app_r);

    case 'plot_ini'
        sig_anal = varargin{2};
        [ax_hdl,lin_hdl] = wmemtoolX('rmb',win_tool,n_membloc2, ...
                                          ind_axe_hdl,ind_lin_hdl);
        ax_data = ax_hdl(1);
        color   = wtbutilsX('colors','sig');
        xmin    = 1;
        xmax    = length(sig_anal);
        xdata   = (xmin:xmax);
        lin_hdl(1) = line(...
                          'Parent',ax_data, ...
                          'Xdata',xdata,    ...
                          'Ydata',sig_anal, ...
                          'Color',color,    ...
                          'tag',tag_sig_ori ...
                          );
        color = wtbutilsX('colors','ssig');
        lin_den = line(...
                       'Parent',ax_data,    ...
                       'Visible','off',     ...
                       'Xdata',xdata,       ...
                       'Ydata',sig_anal,    ...
                       'Color',color        ...
                       );

        ylim = getylim(sig_anal);
        set(ax_data,'Ylim',ylim)
        wtitleX('Signal (S)','Parent',ax_data);
        set(ax_hdl,'Xlim',[xmin xmax]);
        wmemtoolX('wmb',win_tool,n_membloc2,...
                       ind_lin_hdl,lin_hdl,ind_lin_den,lin_den);
        utthrw1dX('set',win_tool,'handleORI',lin_hdl(1));

    case 'plot_dec'
        %****************************%
        %** OPTION = 'plot_dec' -  **%
        %****************************%
        % out1 = hdl_line_cfs
        %------------------
        wDEC   = varargin{2};
        valTHR = varargin{3};
        maxTHR = varargin{4};
        visFLG = varargin{5};

        %------------------
        [nbrow,lon] = size(wDEC);

        % Plots.
        %-----------------------------------------------------
        % axes_hdl = [axe_left_1 axe_right_1 axe_medium ... 
        %             axe_left axe_app_l axe_right axe_app_r];
        %----------------------------------------------------
        nbdet   = nbrow-1;
        [ax_hdl,lin_hdl,txt_hdl,lin_den] = ...
                wmemtoolX('rmb',win_tool,n_membloc2, ...
                               ind_axe_hdl,ind_lin_hdl,ind_txt_hdl,ind_lin_den);
        NBaxes  = length(ax_hdl);
        % ax_l_1  = ax_hdl(1);
        ax_r_1  = ax_hdl(2);
        ax_med  = ax_hdl(3);
        NBaxdet = (NBaxes-5)/2;
        i_app_l = 3+NBaxdet+1;
        i_app_r = NBaxes;
        ax_det   = ax_hdl(4:i_app_l-1);
        ax_app_l = ax_hdl(i_app_l);
        ax_deno  = ax_hdl(i_app_l+1:i_app_r-1);
        ax_app_r = ax_hdl(i_app_r);
        ind_den  = i_app_l+(1:nbdet);

        % Reset lin_den.
        %---------------
        set(lin_den,'Ydata',get(lin_hdl(1),'Ydata'));

        % Clean axes.
        %------------
        axes2clean = [ax_r_1,ax_med,ax_det,ax_app_l,ax_deno,ax_app_r];
        obj2del = findobj(axes2clean,'type','line');
        delete(obj2del)
        lin_hdl((2:NBaxes)) = NaN;

        % Compute X-interval.
        %--------------------
        xmin = 1;   xmax = lon;

        % Plotting details.
        %------------------
        delta_i_axe = 0;
        colorDET = wtbutilsX('colors','det',nbdet);
        out1  = zeros(nbdet,1);
        for k = 1:nbdet
          i_axe  = k+delta_i_axe;
          ax_act = ax_det(i_axe);
          ybounds = [-valTHR(k) , valTHR(k) , -maxTHR(k) , maxTHR(k)];
          tag     = ['cfs_' int2str(i_axe)];
          out1(k) = plotline(ax_act,xmin:xmax,wDEC(k,:), ...
                             colorDET(k,:),tag,'On',ybounds);
          utthrw1dX('plot_dec',win_tool,i_axe,{maxTHR(k),valTHR(k),xmin,xmax,k});
        end
        lin_hdl(3+(1:nbdet)) = out1;

        % Plotting coarse approximation.
        %-------------------------------
        app = wDEC(nbrow,:);
        txt = ['a' wnsubstrX(nbdet)];
        color = wtbutilsX('colors','app',1);
        lin_hdl(i_app_l) = plotline(ax_app_l,(xmin:xmax),app,color,tag_app,'On');
        set(txt_hdl(i_app_l),'String',txt);
        lin_hdl(i_app_r) = plotline(ax_app_r,(xmin:xmax),app,...
                                    color,tag_app,visFLG);
        set(txt_hdl(i_app_r),'String',txt);

        % Plotting de-noised details.
        %----------------------------
        for k = 1:nbdet
            i_axe = k+delta_i_axe;
            tag_det = ['det_' int2str(i_axe)];
            ax_act  = ax_deno(i_axe);
            lin_hdl(ind_den(k)) = ...  
             plotline(ax_act,(xmin:xmax),wDEC(k,:),colorDET(k,:),tag_det,visFLG);
        end

        % Plotting de-noised Signal.
        %---------------------------
        color = wtbutilsX('colors','ssig');
        sig  = get(lin_hdl(1),'Ydata');
        lin_hdl(2) = plotline(ax_r_1,(xmin:xmax),sig,color,tag_sig_den,visFLG);

        % Plotting residuals.
        %--------------------
        color = wtbutilsX('colors','res');
        lin_hdl(3) = plotline(ax_med,(xmin:xmax),zeros(size(sig)),...
                     color,tag_noise,'Off');
        wmemtoolX('wmb',win_tool,n_membloc2,ind_lin_hdl,lin_hdl);
        utthrw1dX('set',win_tool,'handleTHR',lin_hdl(2),'handleRES',lin_hdl(3));
        axeNoXTick = [ax_det(2:NBaxdet),ax_app_l,ax_deno(2:NBaxdet),ax_app_r];
        set(axeNoXTick,'Xtick',[],'XtickLabel',[]);
        set(ax_hdl,'Xlim',[xmin xmax])

        % Dynvtool Attachment.
        %---------------------
        dynvtoolX('init',win_tool,[],ax_hdl,[],[1 0],'','','')
 
        varargout = {out1};
 
    case 'close'

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid Input Argument.');
end


%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function setDEMOS(m_demo,funcName,str_numwin,demoSET,sepFlag)

beg_call_str = [funcName '(''demo'',' str_numwin ','''];
nbDEM = size(demoSET,1);
for k=1:nbDEM
    nam = demoSET{k,1};
    fil = demoSET{k,2};
    wav = demoSET{k,3};
    lev = int2str(demoSET{k,4});
    par = demoSET{k,5};       
    libel = ['with ' wav ' at level ' lev  '  --->  ' nam];
    action = [beg_call_str fil ''',''' wav ''',' lev ',' par ');'];
    if sepFlag && (k==1) , sep = 'on'; else sep = 'off'; end
    uimenu(m_demo,'Label',libel,'Separator',sep,'Callback',action);
end
%-----------------------------------------------------------------------------%
function ylim = getylim(sig)

mini = min(sig);
maxi = max(sig);
if abs(maxi-mini)<eps
    maxi = maxi+0.0001;
    mini = mini-0.0001;
end;
yec  = 0.05*(maxi-mini);
ylim = [mini-yec maxi+yec];
%-----------------------------------------------------------------------------%
function ll = plotline(axe,x,y,color,tag,vis,ylimplus)

ll = findobj(axe,'type','line','tag',tag);
if isempty(ll)
    ll = line('Parent',axe,'Xdata',x,'Ydata',y,...
              'Visible',vis,'Color',color,'tag',tag);
else
    set(ll,'Xdata',x,'Ydata',y,'Color','Visible',vis,color,'tag',tag);
end
if nargin<7
    ylim = getylim(y);
else
    ylim = getylim([y(:) ; ylimplus(:)]);
end
set(axe,'Ylim',ylim);
%-----------------------------------------------------------------------------%
%=============================================================================%
