function varargout = cf1dtoolX(option,varargin)
%CF1DTOOL Wavelet Coefficients Selection 1-D tool.
%   VARARGOUT = CF1DTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 25-Jul-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidivX('ini',option,varargin{:});

% Default values.
%----------------
max_lev_anal = 9;

% Stem parameters.
%-----------------
absMode = 0;
appView = 1;

% Memory Blocs of stored values.
%===============================
% MB0.
%-----
n_membloc0 = 'MB0';
ind_sig    = 1;
ind_coefs  = 2;
ind_longs  = 3;
ind_first  = 4;
ind_last   = 5;
ind_sort   = 6;
ind_By_Lev = 7;
ind_sizes  = 8;  % Dummy
nb0_stored = 8;

% MB1.
%-----
n_param_anal = 'MB1';
ind_sig_name =  1;
ind_sig_size =  2;
ind_wav_name =  3;
ind_lev_anal =  4;
nb1_stored   =  4;

% MB2.
%-----
n_InfoInit   = 'MB2';
ind_filename =  1;
ind_pathname =  2;
nb2_stored   =  2;

% MB3.
%-----
n_synt_sig = 'MB3';
% ind_ssig   =  1;
nb3_stored =  1;

% MB4.
%-----
n_miscella     = 'MB4';
ind_graph_area =  1;
ind_axe_hdl    =  2;
ind_lin_hdl    =  3;
nb4_stored     =  3;

if ~isequal(option,'create') , win_tool = varargin{1}; end
switch option
  case {'create','close'} ,
  otherwise
    toolATTR = wfigmngrX('getValue',win_tool,'ToolATTR');
    hdl_UIC  = toolATTR.hdl_UIC;
    hdl_MEN  = toolATTR.hdl_MEN;
    pus_ana  = hdl_UIC.pus_ana;
    chk_sho  = hdl_UIC.chk_sho;
end
switch option
  case 'create'
    % Get Globals.
    %--------------
    [Def_Btn_Height,Def_Btn_Width,Y_Spacing] = ...
        mextglobX('get','Def_Btn_Height','Def_Btn_Width','Y_Spacing');

    % Window initialization.
    %----------------------
    win_title = 'Wavelet Coefficients Selection 1-D';
    [win_tool,pos_win,win_units,str_numwin,...
        pos_frame0,Pos_Graphic_Area] = ...
           wfigmngrX('create',win_title,winAttrb,'ExtFig_Tool_3',mfilename,1,1,0);
    if nargout> 0 , varargout{1} = win_tool; end
	
	% Add Help for Tool.
	%------------------
	wfighelpX('addHelpTool',win_tool,'One-Dimensional &Selection','CF1D_GUI');
	
    % Menu construction.
    %-------------------
    m_files = wfigmngrX('getmenus',win_tool,'file');	
    m_load  = uimenu(m_files, ...
        'Label','&Load Signal', ...
        'Position',1,...
        'Callback',[mfilename '(''load'',' str_numwin ');']  ...
        );
    m_save = uimenu(m_files,...
                    'Label','&Save Synthesized Signal', ...
                    'Position',2,     ...
                    'Enable','Off',   ...
                    'Callback',       ...
                    [mfilename '(''save'',' str_numwin ');'] ...
                    );
    m_demo = uimenu(m_files,...
                    'Label','&Example Analysis ','Position',3);
    uimenu(m_files, ...
        'Label','Import Signal from Workspace',   ...
        'Position',4,'Separator','On',...
        'Callback',[mfilename '(''load'',' str_numwin ',''wrks'');']...
        );
     m_exp_sig = uimenu(m_files, ...
        'Label','Export Signal to Workspace',   ...
        'Position',5,'Enable','Off','Separator','Off',...
        'Callback',[mfilename '(''exp_wrks'',' str_numwin ');'] ...
        );
               
    m_demo_1 = uimenu(m_demo,'Label','Basic Signals');
    m_demo_2 = uimenu(m_demo,'Label','Noisy Signals');
    m_demo_3 = uimenu(m_demo,'Label','Noisy Signals - Movie');
	
    % Submenu of test signals.
    %-------------------------
    names(1,:)  = 'Sum of sines               ';
    names(2,:)  = 'Frequency breakdown        ';
    names(3,:)  = 'Uniform white noise        ';
    names(4,:)  = 'AR(3) noise                ';
    names(5,:)  = 'Noisy polynomial           ';
    names(6,:)  = 'Noisy polynomial           ';
    names(7,:)  = 'Step signal                ';
    names(8,:)  = 'Two nearby discontinuities ';
    names(9,:)  = 'Two nearby discontinuities ';
    names(10,:) = 'Second derivative breakdown';
    names(11,:) = 'Second derivative breakdown';
    names(12,:) = 'Ramp + white noise         ';
    names(13,:) = 'Ramp + colored noise       ';
    names(14,:) = 'Sine + white noise         ';
    names(15,:) = 'Triangle + sine            ';
    names(16,:) = 'Triangle + sine + noise    ';
    names(17,:) = 'Electrical consumption     ';
    names(18,:) = 'Cantor curve               ';
    names(19,:) = 'Koch curve                 ';

    files = [ 'sumsin  ' ; 'freqbrk ' ; 'whitnois' ; 'warma   ' ; ...
              'noispol ' ; 'noispol ' ; 'wstep   ' ; 'nearbrk ' ; ...
              'nearbrk ' ; 'scddvbrk' ; 'scddvbrk' ; 'wnoislop' ; ...
              'cnoislop' ; 'noissin ' ; 'trsin   ' ; 'wntrsin ' ; ...
              'leleccum' ; 'wcantor ' ; 'vonkoch '                    ];

    waves = ['db3' ; 'db5' ; 'db3' ; 'db3' ; 'db2' ; 'db3' ; 'db2' ; ...
             'db2' ; 'db7' ; 'db1' ; 'db4' ; 'db3' ; 'db3' ; 'db5' ; ...
             'db5' ; 'db5' ; 'db3' ; 'db1' ; 'db1'                      ];

    levels = ['5';'5';'5';'5';'4';'4';'5';'5';'5';'2';'2';'6';'6';'5';...
                    '6';'7';'5';'5';'5'];

    beg_call_str = [mfilename '(''demo'',' str_numwin ','''];
    for i=1:size(files,1)
            libel = ['with ' waves(i,:) ' at level ' levels(i,:) ...
                            '  --->  ' names(i,:)];
            action = [beg_call_str files(i,:) ''',''' ...
                            waves(i,:) ''',' levels(i,:) ');'];
            uimenu(m_demo_1,'Label',libel,'Callback',action);
    end

    names = {...
              'Noisy blocks','Noisy bumps','Noisy heavysin',     ...
              'Noisy Doppler','Noisy quadchirp','Noisy mishmash' ...
              };
    files      = [ 'noisbloc' ; 'noisbump' ; 'heavysin' ; ...
                   'noisdopp' ; 'noischir' ; 'noismima'      ];
    waves  = ['sym8';'sym4';'sym8';'sym4';'db1 ';'db3 '];
    levels = ['5';'5';'5';'5';'5';'5'];
    beg_call_str = [mfilename '(''demo'',' str_numwin ','''];
    for i=1:size(files,1)
        libel = ['with ' waves(i,:) ' at level ' levels(i,:) ...
                        '  --->  ' names{i}];
        action = [beg_call_str files(i,:) ''',''' ...
                        waves(i,:) ''',' levels(i,:) ');'];
        uimenu(m_demo_2,'Label',libel,'Callback',action);
    end

    for i=1:size(files,1)
        libel = ['with ' waves(i,:) ' at level ' levels(i,:) ...
                        '  --->  ' names{i}];
        action = [beg_call_str files(i,:) ''',''' ...
                               waves(i,:) ''',' levels(i,:) ',' ...
                               '{''Stepwise''}' ');'];
        uimenu(m_demo_3,'Label',libel,'Callback',action);
    end

    % Begin waiting.
    %---------------
    wwaitingX('msg',win_tool,'Wait ... initialization');

    % General parameters initialization.
    %-----------------------------------
    dy = Y_Spacing;
 
    % Command part of the window.
    %============================
    % Data, Wavelet and Level parameters.
    %------------------------------------
    xlocINI = pos_frame0([1 3]);
    ytopINI = pos_win(4)-dy;
    toolPos = utanaparX('create',win_tool, ...
                  'xloc',xlocINI,'top',ytopINI,...
                  'enable','off', ...
                  'wtype','dwtX'   ...
                  );
 
    w_uic   = 1.5*Def_Btn_Width;
    h_uic   = 1.5*Def_Btn_Height;
    bdx     = (pos_frame0(3)-w_uic)/2;
    x_left  = pos_frame0(1)+bdx;
    y_low   = toolPos(2)-1.5*Def_Btn_Height-2*dy;
    pos_ana = [x_left, y_low, w_uic, h_uic];

    commonProp = {...
        'Parent',win_tool, ...
        'Unit',win_units,  ...
        'Enable','off'     ...
        };

    str_ana = xlate('Analyze');
    cba_ana = [mfilename '(''anal'',' str_numwin ');'];
    pus_ana = uicontrol(commonProp{:},...
                         'Style','Pushbutton', ...
                         'Position',pos_ana,   ...
                         'String',str_ana,     ...
                         'Callback',cba_ana,   ...
                         'Interruptible','On'  ...
                         );

    % Create coefficients tool.
    %--------------------------
    ytopCFS = pos_ana(2)-4*dy;
    toolPos = utnbcfsX('create',win_tool,...
                      'toolOPT','cf1d',  ...
                      'xloc',xlocINI,'top',ytopCFS);

    % Create show checkbox.
    %----------------------
    w_uic = (3*pos_frame0(3))/4;
    x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
    h_uic = Def_Btn_Height;
    y_uic = toolPos(2)-Def_Btn_Height/2-h_uic;
    pos_chk_sho = [x_uic, y_uic, w_uic, h_uic];
    str_chk_sho = 'Show Original Signal';
    chk_sho = uicontrol(commonProp{:},...
                        'Style','checkbox',     ...
                        'Visible','on',         ...
                        'Position',pos_chk_sho, ...
                        'Tag','Chk_Sho',        ...
                        'String',str_chk_sho    ...
                        );

    %  Normalisation.
    %----------------
    Pos_Graphic_Area = wfigmngrX('normalize',win_tool, ...
        Pos_Graphic_Area,'On');
 
    % Axes construction.
    %------------------
    ax     = zeros(4,1);
    pos_ax = zeros(4,4);
    bdx = 0.05;
     ecy_top = 0.04;
    ecy_bot = 0.04;
    ecy_mid = 0.06;
    w_ax = (Pos_Graphic_Area(3)-3*bdx)/2;
    h_ax = (Pos_Graphic_Area(4)-ecy_top-ecy_mid-ecy_bot)/3;
    x_ax = bdx;
    y_ax = Pos_Graphic_Area(2)+Pos_Graphic_Area(4)-ecy_top-h_ax;
    pos_ax(1,:) = [x_ax y_ax w_ax h_ax];
    x_ax = x_ax+w_ax+bdx;
    pos_ax(4,:) = [x_ax y_ax w_ax h_ax];
    x_ax = bdx;
    y_ax = Pos_Graphic_Area(2)+ecy_bot;
    pos_ax(2,:) = [x_ax y_ax w_ax 2*h_ax];
    x_ax = x_ax+w_ax+bdx;
    pos_ax(3,:) = [x_ax y_ax w_ax 2*h_ax];
    for k = 1:4
        ax(k) = axes(...
                     'Parent',win_tool,      ...
                     'Unit','normalized',    ...
                     'Position',pos_ax(k,:), ...
                     'Xtick',[],'Ytick',[],  ...
                     'Box','on',             ...
                     'Visible','off'         ...
                     );
    end

    % Callbacks update.
    %------------------
    hdl_den = utnbcfsX('handles',win_tool);
    utanaparX('set_cba_num',win_tool,[m_files;hdl_den(:)]);
    pop_lev = utanaparX('handles',win_tool,'lev');
    tmp     = num2mstrX([pop_lev chk_sho]);
    end_cba = [str_numwin ',' tmp ');'];
    cba_pop_lev = [mfilename '(''update_level'',' end_cba];
    cba_chk_sho = [mfilename '(''show_ori_sig'',' str_numwin ');'];
    set(pop_lev,'Callback',cba_pop_lev);
    set(chk_sho,'Callback',cba_chk_sho);

    % Memory for stored values.
    %--------------------------
    hdl_UIC  = struct('pus_ana',pus_ana,'chk_sho',chk_sho);
    hdl_MEN  = struct('m_load',m_load,'m_save',m_save, ...
        'm_demo',m_demo,'m_exp_sig',m_exp_sig);
    toolATTR = struct('hdl_UIC',hdl_UIC,'hdl_MEN',hdl_MEN);
    wfigmngrX('storeValue',win_tool,'ToolATTR',toolATTR);
    hdl_STEM = struct(...
                      'Hstems_O',[], ...
                      'H_vert_O',[], ...
                      'H_stem_O',[], ...
                      'H_vert_O_Copy',[], ...
                      'H_stem_O_Copy',[], ...
                      'Hstems_M',[], ...
                      'H_vert_M',[], ...
                      'H_stem_M',[], ...
                      'H_vert_M_Copy',[], ...
                      'H_stem_M_Copy',[]  ...
                      );
    wfigmngrX('storeValue',win_tool,'Stems_struct',hdl_STEM);
    wmemtoolX('ini',win_tool,n_InfoInit,nb0_stored);
    wmemtoolX('ini',win_tool,n_param_anal,nb1_stored);
    wmemtoolX('ini',win_tool,n_membloc0,nb2_stored);
    wmemtoolX('ini',win_tool,n_synt_sig,nb3_stored);
    wmemtoolX('ini',win_tool,n_miscella,nb4_stored);
    wmemtoolX('wmb',win_tool,n_miscella,...
                   ind_graph_area,Pos_Graphic_Area,ind_axe_hdl,ax);

    % End waiting.
    %---------------
    wwaitingX('off',win_tool);

  case 'load'
    if length(varargin)<2       % LOAD SIGNAL
       [sigInfos,sig_Anal,ok] = ...
            utguidivX('load_sig',win_tool,'Signal_Mask','Load Signal');
        demoFlag = 0;
    elseif isequal(varargin{2},'wrks')  % LOAD from WORKSPACE
        [sigInfos,sig_Anal,ok] = wtbximportX('1d');
        demoFlag = 0;
    else                        % DEMO
        sig_Name = deblank(varargin{2});
        wav_Name = deblank(varargin{3});
        lev_Anal = varargin{4};
        filename = [sig_Name '.mat'];
        pathname = utguidivX('WTB_DemoPath',filename);
        [sigInfos,sig_Anal,ok] = ...
            utguidivX('load_dem1D',win_tool,pathname,filename);
        demoFlag = 1;
    end
    if ~ok, return; end

    % Begin waiting.
    %---------------
    wwaitingX('msg',win_tool,'Wait ... loading');

    % Get Values.
    %------------
    axe_hdl = wmemtoolX('rmb',win_tool,n_miscella,ind_axe_hdl);

    % Cleaning.
    %----------
    dynvtoolX('stop',win_tool);
    utnbcfsX('clean',win_tool)
    set([hdl_MEN.m_save,hdl_MEN.m_exp_sig],'Enable','Off');
    set(axe_hdl(2:end),'Visible','Off');
    children = allchild(axe_hdl);
    delete(children{:});
    set(axe_hdl,'Xtick',[],'Ytick',[],'Box','on');

    % Setting GUI values.
    %--------------------
    sig_Name = sigInfos.name;
    sig_Size = sigInfos.size;
    sig_Size = max(sig_Size);
    levm     = wmaxlevX(sig_Size,'haar');
    levmax   = min(levm,max_lev_anal);
    lev      = min(levmax,5);
    str_lev_data = int2str((1:levmax)');
    if ~demoFlag
        cbanaparX('set',win_tool, ...
                 'n_s',{sig_Name,sig_Size}, ...
                 'lev',{'String',str_lev_data,'Value',lev});
    else
        cbanaparX('set',win_tool, ...
                 'n_s',{sig_Name,sig_Size}, ...
                 'wav',wav_Name, ...
                 'lev',{'String',str_lev_data,'Value',lev_Anal});
        lev = lev_Anal;
    end
    set(chk_sho,'Value',0)
    cf1dtoolX('position',win_tool,lev,chk_sho);

    % Drawing.
    %---------
    axeAct = axe_hdl(1);
    lsig   = length(sig_Anal);
    wtitleX('Original Signal','Parent',axeAct);
    col_s = wtbutilsX('colors','sig');
    lin_hdl(1) = line(...
      'Parent',axeAct,  ...
      'Xdata',(1:lsig), ...
      'Ydata',sig_Anal, ...
      'Color',col_s,'Visible','on'...
      );
    ymin = min(sig_Anal);
    ymax = max(sig_Anal);
    dy   = (ymax-ymin)/20;
    set(axeAct,...
        'Xlim',[1 lsig],'Ylim',[ymin-dy ymax+dy], ...
        'XtickMode','auto','YtickMode','auto','Visible','on' ...
        );
    axeAct = axe_hdl(4);
    wtitleX('Synthesized Signal','Parent',axeAct);
    lin_hdl(2) = line(...
      'Parent',axeAct,  ...
      'Xdata',(1:lsig), ...
      'Ydata',sig_Anal, ...
      'Color',col_s,'Visible','off'...
      );
    col_ss = wtbutilsX('colors','ssig');
    lin_hdl(3) = line(...
      'Parent',axeAct,  ...
      'Xdata',(1:lsig), ...
      'Ydata',sig_Anal, ...
      'Color',col_ss,'Visible','off'...
      );
    set(axeAct,...
        'Xlim',[1 lsig],'Ylim',[ymin-dy ymax+dy], ...
        'XtickMode','auto','YtickMode','auto'     ...
        );

    % Setting Analysis parameters.
    %-----------------------------
    wmemtoolX('wmb',win_tool,n_membloc0,ind_sig,sig_Anal);
    wmemtoolX('wmb',win_tool,n_param_anal, ...
                   ind_sig_name,sigInfos.name,...
                   ind_sig_size,sigInfos.size ...
                   );
    wmemtoolX('wmb',win_tool,n_InfoInit, ...
                   ind_filename,sigInfos.filename, ...
                   ind_pathname,sigInfos.pathname  ...
                   );

    % Store Values.
    %--------------
    wmemtoolX('wmb',win_tool,n_miscella,ind_lin_hdl,lin_hdl);

    % Setting enabled values.
    %------------------------
    utnbcfsX('set',win_tool,'handleORI',lin_hdl(1),'handleTHR',lin_hdl(3))
    cbanaparX('enable',win_tool,'on');
    set(pus_ana,'Enable','On' );
 
    % End waiting.
    %-------------
    wwaitingX('off',win_tool);

  case 'demo'
    cf1dtoolX('load',varargin{:})
    if length(varargin)>4 
        parDEMO = varargin{5};
    else
        parDEMO = {'Global'};
    end

    % Begin waiting.
    %---------------
    wwaitingX('msg',win_tool,'Wait ... computing');

    % Computing.
    %-----------
    cf1dtoolX('anal',win_tool);
    pause(1)
    utnbcfsX('demo',win_tool,parDEMO);

    % End waiting.
    %-------------
    wwaitingX('off',win_tool);

  case 'save'
    % Testing file.
    %--------------
    [filename,pathname,ok] = utguidivX('test_save',win_tool, ...
                                 '*.mat','Save Synthesized Signal');
    if ~ok, return; end

    % Begin waiting.
    %--------------
    wwaitingX('msg',win_tool,'Wait ... saving');

    % Getting Synthesized Signal.
    %---------------------------
    wname   = wmemtoolX('rmb',win_tool,n_param_anal,ind_wav_name); %#ok<NASGU>
    lin_hdl = wmemtoolX('rmb',win_tool,n_miscella,ind_lin_hdl);
    lin_hdl = lin_hdl(3);
    x     = get(lin_hdl,'Ydata'); %#ok<NASGU>

    % Saving file.
    %--------------
    [name,ext] = strtok(filename,'.');
    if isempty(ext) || isequal(ext,'.')
        ext = '.mat'; filename = [name ext];
    end
    try
      eval([name ' = x ;']);
    catch %#ok<CTCH>
      name = 'x';
    end
    saveStr = {name,'wname'};
    wwaitingX('off',win_tool);
    try
      save([pathname filename],saveStr{:});
    catch %#ok<CTCH>
      errargtX(mfilename,'Save FAILED !','msg');
    end

  case 'exp_wrks'
    wwaitingX('msg',win_tool,'Wait ... exporting');
    lin_hdl = wmemtoolX('rmb',win_tool,n_miscella,ind_lin_hdl);
    x = get(lin_hdl(3),'Ydata');
    wtbxexportX(x,'name','sig_1D','title','Signal');
    wwaitingX('off',win_tool);        
    
  case 'anal'
    % Waiting message.
    %-----------------
    wwaitingX('msg',win_tool,'Wait ... computing');
 
    % Reading Analysis Parameters.
    %-----------------------------
    sig_Anal = wmemtoolX('rmb',win_tool,n_membloc0,ind_sig);
    [wav_Name,lev_Anal] = cbanaparX('get',win_tool,'wav','lev');

    % Setting Analysis parameters
    %-----------------------------
    wmemtoolX('wmb',win_tool,n_param_anal, ...
                   ind_wav_name,wav_Name, ...
                   ind_lev_anal,lev_Anal ...
                   );
    % Get Values.
    %------------
    [axe_hdl,lin_hdl] = wmemtoolX('rmb',win_tool,n_miscella,...
                                  ind_axe_hdl,ind_lin_hdl);

    % Analyzing.
    %-----------
    [coefs,longs] = wavedecX(sig_Anal,lev_Anal,wav_Name);
    [tmp,idxsort] = sort(abs(coefs)); %#ok<ASGLU>
    last  = cumsum(longs(1:end-1));
    first = ones(size(last));
    first(2:end) = last(1:end-1)+1;
    len = length(last);
    idxByLev = cell(1,len);
    for k=1:len
        idxByLev{k} = find((first(k)<=idxsort) & (idxsort<=last(k)));
    end

    % Writing coefficients.
    %----------------------
    wmemtoolX('wmb',win_tool,n_membloc0,...
             ind_coefs,coefs,ind_longs,longs, ...
             ind_first,first,ind_last,last, ...
             ind_sort,idxsort,ind_By_Lev,idxByLev,...
             ind_sizes,[]);
 
    % Clean axes and reset dynvtoolX.
    %-------------------------------
    hdls_all = get(axe_hdl(2:3),'Children');
    delete(hdls_all{:});
    set(axe_hdl(2:3),'YTickLabel',[],'YTick',[]);
    dynvtoolX('ini_his',win_tool,'reset')

    % Plot original decomposition.
    %-----------------------------
    xlim = [1,length(sig_Anal)];
    set(axe_hdl(1:4),'Xlim',xlim);
    ax_prop = {'Xlim',xlim,'box','on','XtickMode','auto','Visible','On'};
    axeAct = axe_hdl(2);
    Hstems_O = dw1dstemX(axeAct,coefs,longs,absMode,appView,'WTBX');
    set(axeAct,ax_prop{:});
    wtitleX('Original Coefficients','Parent',axeAct);

    % Plot modified decomposition.
    %-----------------------------
    axeAct = axe_hdl(3);
    Hstems_M = dw1dstemX(axeAct,coefs,longs,absMode,appView,'WTBX');
    set(axeAct,ax_prop{:});
    wtitleX('Selected Coefficients','Parent',axeAct);

    % Plot signal and synthesized signal.
    %------------------------------------
    axeAct = axe_hdl(4);
    set(axeAct,'Visible','on');
    set(lin_hdl(3),'Ydata',sig_Anal,'Visible','on');

    % Reset tool coefficients.
    %-------------------------
    utnbcfsX('update_NbCfs',win_tool,'anal');
    utnbcfsX('update_methode',win_tool,'anal');
    utnbcfsX('enable',win_tool,'anal');
    set([hdl_MEN.m_save,hdl_MEN.m_exp_sig],'Enable','On');

    % Construction of the invisible Stems.
    %-------------------------------------
    cf1dtoolX('set_Stems_HDL',win_tool,'anal',Hstems_O,Hstems_M);

    % Connect dynvtoolX.
    %------------------
    params = [axe_hdl(2:3)' , -lev_Anal];
    dynvtoolX('init',win_tool,[],axe_hdl,[],[1 0], ...
            '','','cf1dcoorX',params,'cf1dselcX',params);

    % End waiting.
    %-------------
    wwaitingX('off',win_tool);
        
  case 'apply'
    % Waiting message.
    %-----------------
    wwaitingX('msg',win_tool,'Wait ... computing');
 
    % Analysis Parameters.
    %--------------------
    [first,idxsort,idxByLev] = ...
        wmemtoolX('rmb',win_tool,n_membloc0,ind_first,ind_sort,ind_By_Lev);
    [nameMeth,nbkept] = utnbcfsX('get',win_tool,'nameMeth','nbkept');
    len = length(idxByLev);

    switch nameMeth
      case {'Global','ByLevel'}
        [dummy,dim] = max(size(idxByLev{1})); %#ok<ASGLU>
        ind = [];
        switch dim
            case 1
                 for k=1:len
                    ind = [ind ; idxByLev{k}(end-nbkept(k)+1:end)]; %#ok<AGROW>
                 end               
            case 2
                for k=1:len
                    ind = [ind , idxByLev{k}(end-nbkept(k)+1:end)]; %#ok<AGROW>
                end
        end
        idx_Cfs = idxsort(ind);

        % Computing & Drawing.
        %---------------------
        Hstems_M = cf1dtoolX('plot_NewDec',win_tool,idx_Cfs,nameMeth);

        % Construction of the invisible Stems.
        %-------------------------------------
        cf1dtoolX('set_Stems_HDL',win_tool,'apply',Hstems_M);

      case {'Manual'}
        [H_stem_O,H_stem_O_Copy] = ...
            cf1dtoolX('get_Stems_HDL',win_tool,'Manual');
        idx_Cfs = [];
        for k=1:len
            y = len+1-k;
            x_stem = get(H_stem_O(y),'Xdata');
            x_stem_Copy = get(H_stem_O_Copy(y),'Xdata');
            TF = ismember(x_stem,x_stem_Copy);
            Idx     = find(TF==1);
            idx_Cfs = [idx_Cfs , Idx+first(k)-1]; %#ok<AGROW>
        end

        % Computing & Drawing.
        %---------------------
        cf1dtoolX('plot_NewDec',win_tool,idx_Cfs,nameMeth);
    end 

    % End waiting.
    %-------------
    wwaitingX('off',win_tool);

  case 'Apply_Movie'
    movieSET = varargin{2};
    if isempty(movieSET)
        cf1dtoolX('plot_NewDec',win_tool,[],'Stepwise');
        return
    end
    nbInSet = length(movieSET);  
    appFlag = varargin{3};
    popStop = varargin{4};

    % Waiting message.
    %-----------------
    if nbInSet>1
        txt_msg = wwaitingX('msg',win_tool,'Wait ... computing');
    end

    % Get Analysis Parameters.
    %-------------------------
    [first,last,idxsort,idxByLev] = ...
        wmemtoolX('rmb',win_tool,n_membloc0, ...
                       ind_first,ind_last,ind_sort,ind_By_Lev);

    % Computing.
    %-----------
    len = length(last);
    nbKept = zeros(1,len+1);
    switch appFlag
      case 1
        idx_App = idxsort(idxByLev{1});
        App_Len = length(idx_App);
        idxsort(idxByLev{1}) = [];

      case 2
        idx_App = [];
        App_Len = 0;
       
      case 3
        idx_App = [];
        App_Len = 0;       
        idxsort(idxByLev{1}) = [];
    end
    for jj = 1:nbInSet
        nbcfs = movieSET(jj);
        nbcfs  = nbcfs-App_Len;
        idx_Cfs = [idx_App , idxsort(end-nbcfs+1:end)];
        if nbInSet>1 , 
            for k=1:len
              dummy  = find((first(k)<=idx_Cfs) & (idx_Cfs<=last(k)));
              nbKept(k) = length(dummy);
            end
            nbKept(end) = sum(nbKept(1:end-1));
            msg2 = [int2str(nbKept(end)) '  = [' int2str(nbKept(1:end-1)) ']'];
            % msg  = strvcat(' ', sprintf('Number of kept coefficients:  %s', msg2)); 
            
            msg  = {' ', sprintf('Number of kept coefficients:  %s', msg2)}; 
            set(txt_msg,'String',msg);
        end

        % Computing & Drawing.
        %---------------------
        Hstems_M = cf1dtoolX('plot_NewDec',win_tool,idx_Cfs,'Stepwise');

        if nbInSet>1 , 
            % Test for stopping.
            %-------------------
            user = get(popStop,'Userdata');
            if isequal(user,1)
               set(popStop,'Userdata',[]);
               break
            end
            pause(0.1);
        end
    end

    % Construction of the invisible Stems.
    %-------------------------------------
    cf1dtoolX('set_Stems_HDL',win_tool,'apply',Hstems_M);

    % End waiting.
    %-------------
    if nbInSet>1 , wwaitingX('off',win_tool); end

  case {'select','unselect'}
     OK_Select = isequal(option,'select');

     % Find Select Box.
     %-----------------
     [X,Y] = mngmbtnX('getbox',win_tool);
     xmin = ceil(min(X));
     xmax = floor(max(X));
     ymin = min(Y);
     ymax = max(Y);

     % Get stored Stems.
     %------------------
     [H_vert_O,H_stem_O,H_vert_O_Copy,H_stem_O_Copy,...
      H_vert_M,H_stem_M,H_vert_M_Copy,H_stem_M_Copy] = ...
          cf1dtoolX('get_Stems_HDL',win_tool,'allComponents'); %#ok<ASGLU>
     nb_Stems = length(H_stem_O);

     % Find points.
     %-------------         
     nbKept = utnbcfsX('get',win_tool,'nbKept');
     ylow = max(1,floor(ymin));
     ytop = min(ceil(ymax),nb_Stems);
     for y = ylow:ytop
        xy_stem      = get(H_stem_O(y),{'Xdata','Ydata'});
        xy_stem_Copy = get(H_stem_O_Copy(y),{'Xdata','Ydata'});
        Idx = find(xmin<=xy_stem{1} & xy_stem{1}<=xmax & ...
                   ymin<=xy_stem{2} & xy_stem{2}<=ymax);
        if OK_Select
            Idx = Idx(~ismember(xy_stem{1}(Idx),xy_stem_Copy{1}));
        else
            Idx = find(ismember(xy_stem_Copy{1},xy_stem{1}(Idx)));
        end
        if ~isempty(Idx)
            xy_vert_Copy = get(H_vert_O_Copy(y),{'Xdata','Ydata'});
            if OK_Select
                xy_stem_Copy{1} = [xy_stem_Copy{1} , xy_stem{1}(Idx)];
                xy_stem_Copy{2} = [xy_stem_Copy{2} , xy_stem{2}(Idx)];
                tmp = [xy_stem{1}(Idx); xy_stem{1}(Idx) ; xy_stem{1}(Idx)];
                xy_vert_Copy{1} = [xy_vert_Copy{1} , tmp(:)'];
                nbIdx = length(Idx);
                tmp = [y*ones(1,nbIdx); xy_stem{2}(Idx) ; NaN*ones(1,nbIdx)];
                xy_vert_Copy{2} = [xy_vert_Copy{2} , tmp(:)'];
            else
                xy_stem_Copy{1}(Idx) = [];
                xy_stem_Copy{2}(Idx) = [];
                Idx = 3*Idx-4;
                Idx = [Idx,Idx+1,Idx+2]; %#ok<AGROW>
                xy_vert_Copy{1}(Idx) = [];
                xy_vert_Copy{2}(Idx) = [];
            end
            set([H_stem_O_Copy(y),H_stem_M_Copy(y)],...
                'Xdata',xy_stem_Copy{1},...
                'Ydata',xy_stem_Copy{2} ...
                );
            set([H_vert_O_Copy(y),H_vert_M_Copy(y)],...
                'Xdata',xy_vert_Copy{1},...
                'Ydata',xy_vert_Copy{2} ...
                );        
            nbInd = length(xy_stem_Copy{1})-1;
            nbKept(nb_Stems+1-y) = nbInd;
        end               
     end
     nbKept(end) = sum(nbKept(1:end-1));
     utnbcfsX('set',win_tool,'nbKept',nbKept);

  case 'plot_NewDec'
    % Indices of preserved coefficients & Methode.
    %---------------------------------------------
    idx_Cfs  = varargin{2};
    nameMeth = varargin{3};
    
    % Get Handles.
    %-------------
    [axe_hdl,lin_hdl] = wmemtoolX('rmb',win_tool,n_miscella,...
                                  ind_axe_hdl,ind_lin_hdl);

    % Get Analysis Parameters.
    %-------------------------
    wav_Name = wmemtoolX('rmb',win_tool,n_param_anal,ind_wav_name);
    [coefs,longs] = wmemtoolX('rmb',win_tool,n_membloc0,ind_coefs,ind_longs);

    % Compute synthezized signal.
    %---------------------------
    Cnew = zeros(size(coefs));
    Cnew(idx_Cfs) = coefs(idx_Cfs);
    SS  = waverecX(Cnew,longs,wav_Name);

    % Plot modified decomposition.
    %-----------------------------
    xlim    = get(axe_hdl(1),'Xlim');
    ax_prop = {'Xlim',xlim,'box','on'};
    axeAct = axe_hdl(3);
    if ~isequal(nameMeth,'Manual')
        varargout{1} = dw1dstemX(axeAct,Cnew,longs,absMode,appView,'WTBX');
        set(axeAct,ax_prop{:});
    else
        varargout{1} = [];
    end

    % Plot synthesized signal.
    %-------------------------
    axeAct = axe_hdl(4);
    set(lin_hdl(3),'Ydata',SS);
    cf1dtoolX('show_ori_sig',win_tool)
    % wtitleX('Synthesized Signal','Parent',axeAct);
    set(axeAct,...
        'Xlim',xlim,  ...
        'XtickMode','auto','YtickMode','auto', ...
        'Box','on'  ...
        );
    set([hdl_MEN.m_save,hdl_MEN.m_exp_sig],'Enable','On');   

  case 'get_Stems_HDL'
    % Output parameter.
    %------------------
    mode = varargin{2};

    % Get stored Stems.
    %------------------
    hdl_STEM  = wfigmngrX('getValue',win_tool,'Stems_struct');
    varargout = struct2cell(hdl_STEM);
    if isequal(mode,'All') , return; end
    
    [...
     Hstems_O,H_vert_O,H_stem_O,H_vert_O_Copy,H_stem_O_Copy, ...
     Hstems_M,H_vert_M,H_stem_M,H_vert_M_Copy,H_stem_M_Copy  ...
     ] = deal(varargout{:}); %#ok<ASGLU>
     switch mode
       case 'allComponents'
         varargout = {... 
           H_vert_O,H_stem_O,H_vert_O_Copy,H_stem_O_Copy, ...
           H_vert_M,H_stem_M,H_vert_M_Copy,H_stem_M_Copy};

       case 'Manual'
         varargout = {H_stem_O,H_stem_O_Copy};
     end

  case 'set_Stems_HDL'
    mode = varargin{2};
    axe_hdl  = wmemtoolX('rmb',win_tool,n_miscella,ind_axe_hdl);
    lev_Anal = wmemtoolX('rmb',win_tool,n_param_anal,ind_lev_anal);
    nb_STEMS = lev_Anal+1;
    hdl_STEM = wfigmngrX('getValue',win_tool,'Stems_struct'); 
    switch mode
      case 'anal'
        Hstems_O = varargin{3};
        Hstems_M = varargin{4};

        % Construction of the invisible duplicated coefficients axes.
        %------------------------------------------------------------
        [H_vert_O,H_stem_O,Hstems_O] = extractSTEMS(Hstems_O);
        [H_vert_M,H_stem_M,Hstems_M] = extractSTEMS(Hstems_M);

        % Store values.
        %--------------
        hdl_STEM.Hstems_O = Hstems_O;
        hdl_STEM.H_vert_O = H_vert_O;
        hdl_STEM.H_stem_O = H_stem_O;
        hdl_STEM.Hstems_M = Hstems_M;
        hdl_STEM.H_vert_M = H_vert_M;
        hdl_STEM.H_stem_M = H_stem_M;

      case 'apply'
        Hstems_M = varargin{3};

        % Modification of Stems.
        %-----------------------
        [H_vert_M,H_stem_M,Hstems_M] = extractSTEMS(Hstems_M);
        hdl_STEM.Hstems_M = Hstems_M;
        hdl_STEM.H_vert_M = H_vert_M;
        hdl_STEM.H_stem_M = H_stem_M;

      case 'reset'
        nameMeth = varargin{3};
        hdl_DEL = [hdl_STEM.H_vert_O_Copy,hdl_STEM.H_stem_O_Copy,...
                   hdl_STEM.H_vert_M_Copy,hdl_STEM.H_stem_M_Copy];

        hdl_DEL = hdl_DEL(ishandle(hdl_DEL));
        delete(hdl_DEL)
        if ~isempty(hdl_STEM.Hstems_M)
            HDL_VIS = hdl_STEM.Hstems_M(:,(2:4));
            HDL_VIS = HDL_VIS(ishandle(HDL_VIS(:)));
        else
            HDL_VIS = [];
        end
        switch nameMeth
          case {'Global','ByLevel','Stepwise'}
            H_vert_O_Copy = [];  H_stem_O_Copy = [];
            H_vert_M_Copy = [];  H_stem_M_Copy = [];
            if ~isequal(nameMeth,'Stepwise')
                vis_VIS = 'On';
            else
                vis_VIS = 'Off';
            end

          case {'Manual'}
            [H_vert_O_Copy,H_stem_O_Copy] = initSTEMS(axe_hdl(2),nb_STEMS);
            [H_vert_M_Copy,H_stem_M_Copy] = initSTEMS(axe_hdl(3),nb_STEMS);
            HDL_Copy = [H_vert_O_Copy(:);H_stem_O_Copy(:);...
                        H_vert_M_Copy(:);H_stem_M_Copy(:)];
            vis_VIS = 'Off';
            set(HDL_Copy,'Visible','On');
        end
        set(HDL_VIS,'Visible',vis_VIS);
        hdl_STEM.H_vert_O_Copy = H_vert_O_Copy;
        hdl_STEM.H_stem_O_Copy = H_stem_O_Copy;
        hdl_STEM.H_vert_M_Copy = H_vert_M_Copy;
        hdl_STEM.H_stem_M_Copy = H_stem_M_Copy;
    end
    wfigmngrX('storeValue',win_tool,'Stems_struct',hdl_STEM);

  case 'show_ori_sig'
    lin_hdl = wmemtoolX('rmb',win_tool,n_miscella,ind_lin_hdl);
    vis = getonoffX(get(chk_sho,'Value'));
    set(lin_hdl(2),'Visible',vis);
    strTitle = 'synthesized Signal';
    if isequal(vis(1:2),'on')
        strTitle = [strTitle ' and Original Signal'];
    end
    wtitleX(strTitle,'Parent',get(lin_hdl(2),'Parent'))

  case 'position'
    lev_view = varargin{2};
    chk_sho  = varargin{3};
    set(chk_sho,'Visible','off');
    pos_old  = utnbcfsX('get',win_tool,'position');
    utnbcfsX('set',win_tool,'position',{1,lev_view})
    pos_new  = utnbcfsX('get',win_tool,'position');
    ytrans   = pos_new(2)-pos_old(2);
    pos_chk  = get(chk_sho,'Position');
    pos_chk(2) = pos_chk(2)+ytrans;
    set(chk_sho,'Position',pos_chk,'Visible','on');

  case 'update_level'
    pop_lev = varargin{2}(1);
    chk_sho = varargin{2}(2);
    if ~ishandle(pop_lev)
        handles = guihandles(gcbf);
        pop_lev = handles.Pop_Lev;
        chk_sho = handles.Chk_Sho;
    end
    levmax  = get(pop_lev,'value');

    % Get Values.
    %------------
    axe_hdl = wmemtoolX('rmb',win_tool,n_miscella,ind_axe_hdl);
    
    % Clean axes.
    %------------
    hdls_all = get(axe_hdl(2:3),'Children');
    delete(hdls_all{:});
    set(axe_hdl(2:3),'Visible','Off','YTickLabel',[],'YTick',[]);

    % Hide synthesized signal.
    %-------------------------
    set(chk_sho,'Value',0);
    set(wfindobjX(axe_hdl(4)),'Visible','Off');
    set([hdl_MEN.m_save,hdl_MEN.m_exp_sig],'Enable','Off');

    % Reset coefficients tool and dynvtoolX.
    %--------------------------------------
    utnbcfsX('clean',win_tool)
    cf1dtoolX('position',win_tool,levmax,chk_sho);
    dynvtoolX('ini_his',win_tool,'reset')

  case 'handles'

  case 'close'
 
  otherwise
    errargtX(mfilename,'Unknown Option','msg');
    error('Wavelet:Invalid_ArgVal_Or_ArgType','Unknown Option');
end


%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function varargout = extractSTEMS(HDL_Stems)

nbrow = 4;
nbcol = length(HDL_Stems)/nbrow;
HDL_Stems = reshape(HDL_Stems(:),nbrow,nbcol)';
H_vert = HDL_Stems(:,2);
H_stem = HDL_Stems(:,3);
varargout = {H_vert,H_stem,HDL_Stems};
%-----------------------------------------------------------------------------%
function varargout = initSTEMS(axe,nbSTEMS)

stemColor = wtbutilsX('colors','stem');
linProp   = {...
             'Visible','Off',             ...
             'Xdata',NaN,'Ydata',NaN,     ...
             'MarkerEdgeColor',stemColor, ...
             'MarkerFaceColor',stemColor  ...
             };
linPropVert = [linProp,'linestyle','-','Color',stemColor];
linPropStem = [linProp,'linestyle','none','Marker','o','MarkerSize',3];
linTmpVert = line(linPropVert{:},'Parent',axe);
linTmpStem = line(linPropStem{:},'Parent',axe);
dupli      = ones(nbSTEMS,1);
HDL_vert = copyobj(linTmpVert,axe(dupli));
HDL_stem = copyobj(linTmpStem,axe(dupli));
delete([linTmpVert,linTmpStem]);
varargout = {HDL_vert,HDL_stem};
%-----------------------------------------------------------------------------%
%=============================================================================%
