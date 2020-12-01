function varargout = sigxtoolX(option,varargin)
%SIGXTOOL Signal extension tool.
%   VARARGOUT = SIGXTOOL(OPTION,VARARGIN)
%
%   GUI oriented tool which allows the construction of a new
%   signal from an original one by truncation or extension.
%   Extension is done by selecting different possible modes:
%   Symmetric, Periodic, Zero Padding, Continuous or Smooth.
%   A special mode is provided to extend a signal in order 
%   to be accepted by the SWT decomposition.
%------------------------------------------------------------
%   Internal options:
%
%   OPTION = 'create'          'load'           'demo'
%            'update_deslen'   'extend_truncate'
%            'draw'            'save'
%            'clear_graphics'  'mode'
%            'close'
%
%   See also WEXTEND.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 23-Oct-98.
%   Last Revision: 01-May-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidivX('ini',option,varargin{:});


% Initialisations for all options excepted 'create'.
%---------------------------------------------------
switch option

  case 'create'
  
  otherwise
    % Get figure handle.
    %-------------------
    win_sigxtoolX = varargin{1};

    % Get stored structure.
    %----------------------
    Hdls_UIC1 = wfigmngrX('getValue',win_sigxtoolX,'Hdls_UIC1');
    Hdls_UIC2 = wfigmngrX('getValue',win_sigxtoolX,'Hdls_UIC2');
    Hdls_UIC3 = wfigmngrX('getValue',win_sigxtoolX,'Hdls_UIC3');
    Hdls_Axes = wfigmngrX('getValue',win_sigxtoolX,'Hdls_Axes');

    % Get UIC Handles.
    %-----------------
    [m_load,m_save,m_demo,txt_signal,edi_signal,...
     txt_mode,pop_mode,pus_extend] = deal(Hdls_UIC1{:}); %#ok<ASGLU>
    m_exp_sig = wtbxappdataX('get',win_sigxtoolX,'m_exp_sig');
 
    [frm_fra1,txt_length,edi_length,txt_nextpow2,edi_nextpow2,   ...
     txt_prevpow2,edi_prevpow2,txt_deslen,edi_deslen,txt_direct, ...
     pop_direct] = deal(Hdls_UIC2{:}); %#ok<ASGLU>

    [frm_fra2,txt_swtXdec,pop_swtXdec,txt_swtXlen,edi_swtXlen, ...
     txt_swtXclen,edi_swtXclen,txt_swtXdir,                   ...
     edi_swtXdir] = deal(Hdls_UIC3{:}); %#ok<ASGLU>
end

% Process control depending on the calling option.
%-------------------------------------------------
switch option

    case 'create'
    %-------------------------------------------------------%
    % Option: 'CREATE' - Create Figure, Uicontrols and Axes %
    %-------------------------------------------------------%
	
        % Get Globals.
        %-------------
        [btn_Height,Def_Btn_Width, ...
        X_Spacing,Y_Spacing,ediActBkColor,ediInActBkColor,    ...
        Def_FraBkColor] =                                     ...
                mextglobX('get',                               ...
                'Def_Btn_Height','Def_Btn_Width',             ...
                'X_Spacing','Y_Spacing',                      ...
                'Def_Edi_ActBkColor','Def_Edi_InActBkColor',  ...
                'Def_FraBkColor' ...
                );

        % Window initialization.
        %-----------------------
        [win_sigxtoolX,pos_win,win_units,str_numwin,pos_frame0] = ...
                    wfigmngrX('create','Signal Extension / Truncation',  ...
                                        winAttrb,'ExtFig_Tool_3',       ...
                                        {mfilename,'cond'},1,1,0);
        if nargout>0 , varargout{1} = win_sigxtoolX; end
		
		% Add Help for Tool.
		%------------------
		wfighelpX('addHelpTool',win_sigxtoolX, ...
			'One-Dimensional &Extension','SIGX_GUI');

		% Add Help Item.
		%----------------
		wfighelpX('addHelpItem',win_sigxtoolX,...
			'Dealing with Border Distortion','BORDER_DIST');

        % Menu construction for current figure.
        %--------------------------------------
        m_files = wfigmngrX('getmenus',win_sigxtoolX,'file');		
        m_load  = uimenu(m_files,'Label','&Load Signal',...
            'Position',1, ...
            'Callback',[mfilename '(''load'',' str_numwin ');']  ...            
            );
        m_save = uimenu(m_files,...
            'Label','&Save Transformed Signal ',     ...
            'Position',2,'Enable','Off',             ...
            'Callback',[mfilename '(''save'',' str_numwin ');'] ...
            );
        m_demo = uimenu(m_files,'Label','&Example Extension','Position',3);
        uimenu(m_files,...
            'Label','Import Signal from Workspace', ...
            'Position',4,'Separator','On', ...
            'Callback',[mfilename '(''load'',' str_numwin ',''wrks'');']...
            );
        m_exp_sig = uimenu(m_files,...
            'Label','Export Signal to Workspace',  ...
            'Position',5,'Enable','Off','Separator','Off', ...
            'Callback',[mfilename '(''exp_wrks'',' str_numwin ');']...
            );

        demoSET = {...
         'noisbloc' , 'ext'   , '{''zpd'' , 1236 , ''both''}'  ; ...
         'noisbloc' , 'trunc' , '{''nul'',   865 , ''both'' }' ; ...
         'cuspamax' , 'ext'   , '{''spd'' , 1400 , ''right''}' ; ...
         'cuspamax' , 'ext'   , '{''spd'' , 1400 , ''left''}'  ; ...
         'cuspamax' , 'ext'   , '{''spd'' , 1400 , ''both''}'  ; ...
         'noisbump' , 'ext'   , '{''sym'' , 1600 , ''both''}'  ; ...
         'freqbrk'  , 'trunc' , '{''nul'',   666 , ''left'' }' ; ...
         'freqbrk'  , 'ext'   , '{''swtX'' ,   10 , ''right''}'   ...
         };
       nbDEM = size(demoSET,1);
       beg_call_str = [mfilename '(''demo'',' str_numwin ','''];

	   names = demoSET(:,1);
	   tab   = char(9);
       for k = 1:nbDEM
           typ = demoSET{k,2};
           fil = demoSET{k,1};
           par = demoSET{k,3};
           parVal = eval(par);
           switch parVal{1}
             case 'swtX' , lenSTR = ' - level: ';
             otherwise  , lenSTR = ' - length: ';
           end
           strPAR = ['mode: ' ,  parVal{1} , lenSTR, int2str(parVal{2})  ...
                     ' - direction: ', parVal{3}];  
           switch  typ
             case 'ext'   , strTYPE = 'Extension  - ';
             case 'trunc' , strTYPE = 'Truncation - '; 
           end
           libel = [names{k} tab '  -  ' strTYPE strPAR];
           action = [beg_call_str fil  ''',''' typ ''',' par ');'];
           uimenu(m_demo,'Label',libel,'Callback',action);
       end

        % Borders and double borders.
        %----------------------------
        dx = X_Spacing;  dx2 = 2*dx;
        dy = Y_Spacing;  dy2 = 2*dy;

        % General graphical parameters initialization.
        %--------------------------------------------
        x_frame0  = pos_frame0(1);
        cmd_width = pos_frame0(3);
        pus_width = cmd_width-4*dx2;
        txt_width = 7*Def_Btn_Width/4;
        edi_width = 3*Def_Btn_Width/4;
        bdx       = 0.08*pos_win(3);
        bdy       = 0.06*pos_win(4);
        x_graph   = bdx;
        y_graph   = 2*btn_Height+dy;
        h_graph   = pos_frame0(4)-y_graph;
        w_graph   = pos_frame0(1);

        % Command part of the window.
        %============================

        % Position property of objects.
        %------------------------------
        delta_Xleft      = wtbutilsX('extension_PREFS');                  
        ybottomINI       = pos_win(4)-dy2;
        x_left_0           = x_frame0 + dx2 + dx;
        x_left_1           = x_left_0 + txt_width/2 + delta_Xleft;
        x_left_2           = x_left_1 + edi_width;

        y_low            = ybottomINI-btn_Height-2*dy2;
        pos_txt_signal   = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_signal   = [x_left_1, y_low+dy, 2*edi_width , btn_Height];

        y_low            = y_low-1.5*(btn_Height+2*dy2);
        pos_txt_length   = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_length   = [x_left_2, y_low+dy, edi_width , btn_Height];

        y_low            = y_low-(btn_Height+2*dy2);
        pos_txt_nextpow2 = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_nextpow2 = [x_left_2, y_low+dy, edi_width , btn_Height];

        y_low            = y_low-(btn_Height+2*dy2);
        pos_txt_prevpow2 = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_prevpow2 = [x_left_2, y_low+dy, edi_width , btn_Height];

        y_low            = y_low-(btn_Height+2*dy2);
        pos_txt_deslen   = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_deslen   = [x_left_2, y_low+dy, edi_width , btn_Height];

        y_low            = y_low-(btn_Height+2*dy2);
        pos_txt_direct   = [x_left_0, y_low, txt_width, btn_Height];
        pos_pop_direct   = [x_left_2, y_low+dy, edi_width , btn_Height];
        
        y_low            = y_low-dy;
        pos_fra1         = [x_left_0-dx2, y_low, cmd_width-dx2, ...
                            5*(btn_Height+2*dy2)+dy];

        y_low            = y_low-(2*btn_Height+2*dy2);
        pos_txt_mode     = [x_left_0, y_low, txt_width, btn_Height];
        
        y_low            = y_low-btn_Height;
        pos_pop_mode     = [x_left_0, y_low, pus_width+2*dx2 , btn_Height];

        y_low            = y_low-2*(btn_Height+2*dy2);
        pos_pus_extend   = [x_left_0+dx2, y_low, pus_width, 1.5*btn_Height];

        pos_fra2         = pos_fra1;
        pos_fra2(4)      = 3*(btn_Height+2*dy2)+dy;
        
        x_left           = x_left_0-dx2;        
        y_low            = pos_fra2(2)+pos_fra2(4)+3*dy2;
        pos_txt_swtXdec   = [x_left, y_low, 9*txt_width/8, btn_Height];
        x_left           = x_left + pos_txt_swtXdec(3) ;        
        pos_pop_swtXdec   = [x_left, y_low+dy, edi_width, btn_Height];
        
        y_low            = pos_fra2(2)+pos_fra2(4)-(btn_Height+2*dy2);
        pos_txt_swtXlen   = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtXlen   = [x_left_2, y_low+dy, edi_width, btn_Height];
        
        y_low            = y_low-(btn_Height+2*dy2);
        pos_txt_swtXclen  = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtXclen  = [x_left_2, y_low+dy, edi_width, btn_Height];
                  
        y_low            = y_low-(btn_Height+2*dy2);
        pos_txt_swtXdir   = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtXdir   = [x_left_2, y_low+dy, edi_width, btn_Height];
        
        % String property of objects.
        %----------------------------
        str_txt_signal   = 'Signal';
        str_edi_signal   = '';
        str_txt_length   = 'Length';
        str_edi_length   = '';
        str_txt_nextpow2 = 'Next Power of 2';
        str_edi_nextpow2 = '';
        str_txt_prevpow2 = 'Previous Power of 2';
        str_edi_prevpow2 = '';
        str_txt_deslen   = 'Desired Length';
        str_edi_deslen   = '';
        str_txt_direct   = 'Direction to extend';
        str_pop_direct   = ['Both ' ; 'Left ' ; 'Right'];
        str_txt_mode     = 'Extension Mode';
        str_pop_mode     = {...
            'Symmetric (Half-Point)', ...
            'Symmetric (Whole-Point)', ...
            'Antisymmetric (Half-Point)', ...
            'Antisymmetric (Whole-Point)', ...
            'Periodic', ...
            'Zero Padding', ...
            'Continuous', ...
            'Smooth', ...
            'For SWT'  ...
            };
        str_pus_extend   = 'Extend';
        str_txt_swtXdec   = 'SWT Decomposition Level';
        str_pop_swtXdec   = num2str((1:10)');
        str_txt_swtXlen   = 'Length';
        str_edi_swtXlen   = '';
        str_txt_swtXclen  = 'Computed Length';
        str_edi_swtXclen  = '';
        str_txt_swtXdir   = 'Direction to extend';
        str_edi_swtXdir   = 'Right';
        str_tip_swtXclen  = ['Minimal length of the ',    ...
                            'periodic extended signal ', ...
                            'for SWT decomposition'];

        % Construction of uicontrols.
        %----------------------------
        commonProp = {'Parent',win_sigxtoolX,'Unit',win_units,'Visible','off'};
        comFraProp = {commonProp{:},                              ...
            'BackGroundColor',Def_FraBkColor, ...
            'Style','frame'                   ...
            };
        comPusProp = {commonProp{:},'Style','Pushbutton'};
        comPopProp = {commonProp{:},'Style','Popupmenu'};
        comTxtProp = {commonProp{:},                              ...
            'ForeGroundColor','k',            ...
            'BackGroundColor',Def_FraBkColor, ...
            'HorizontalAlignment','left',     ...
            'Style','Text'                    ...
            };
        comEdiProp = {commonProp{:},                              ...
            'ForeGroundColor','k',            ...
            'HorizontalAlignment','center',   ...
            'Style','Edit'                    ...
            };

        txt_signal      = uicontrol(  ...
            comTxtProp{:},                    ...
            'Position',pos_txt_signal,        ...
            'String',str_txt_signal           ...
            );
        edi_signal      = uicontrol(  ...
            comEdiProp{:},                    ...
            'Position',pos_edi_signal,        ...
            'String',str_edi_signal,          ...
            'BackGroundColor',ediInActBkColor, ...
            'Enable','Inactive'               ...
            );
        frm_fra1        = uicontrol(  ...
            comFraProp{:},                    ...
            'Position',pos_fra1               ...
            );
        txt_length      = uicontrol(  ...
            comTxtProp{:},                    ...
            'Position',pos_txt_length,        ...
            'String',str_txt_length           ...
            );
        edi_length      = uicontrol(  ...
            comEdiProp{:},                    ...
            'Position',pos_edi_length,        ...
            'String',str_edi_length,          ...
            'Backgroundcolor',ediInActBkColor, ...
            'Enable','Inactive'               ...
            );
        txt_nextpow2    = uicontrol(  ...
            comTxtProp{:},                    ...
            'Position',pos_txt_nextpow2,      ...
            'String',str_txt_nextpow2         ...
            );
        edi_nextpow2    = uicontrol(  ...
            comEdiProp{:},                    ...
            'Position',pos_edi_nextpow2,      ...
            'String',str_edi_nextpow2,        ...
            'Backgroundcolor',ediInActBkColor, ...
            'Enable','Inactive'               ...
            );
        txt_prevpow2    = uicontrol(  ...
            comTxtProp{:},                    ...
            'Position',pos_txt_prevpow2,      ...
            'String',str_txt_prevpow2         ...
            );
        edi_prevpow2    = uicontrol(  ...
            comEdiProp{:},                    ...
            'Position',pos_edi_prevpow2,      ...
            'String',str_edi_prevpow2,        ...
            'Backgroundcolor',ediInActBkColor, ...
            'Enable','Inactive'               ...
            );
        txt_deslen      = uicontrol(  ...
            comTxtProp{:},                    ...
            'Position',pos_txt_deslen,        ...
            'String',str_txt_deslen           ...
            );
        edi_deslen      = uicontrol(  ...
            comEdiProp{:},                    ...
            'Position',pos_edi_deslen,        ...
            'String',str_edi_deslen,          ...
            'Backgroundcolor',ediActBkColor  ...
            );
        txt_direct       = uicontrol(  ...
            comTxtProp{:},                    ...
            'Position',pos_txt_direct,        ...
            'String',str_txt_direct           ...
            );
        pop_direct      = uicontrol(  ...
            comPopProp{:},                    ...
            'Position',pos_pop_direct,        ...
            'String',str_pop_direct           ...
            );
        txt_mode        = uicontrol(  ...
            comTxtProp{:},                    ...
            'Position',pos_txt_mode,          ...
            'String',str_txt_mode             ...
            );
        pop_mode        = uicontrol(  ...
            comPopProp{:},                    ...
            'Position',pos_pop_mode,          ...
            'String',str_pop_mode             ...
            );
        pus_extend      = uicontrol(  ...
            comPusProp{:},                    ...
            'Position',pos_pus_extend,        ...
            'String',xlate(str_pus_extend),          ...
            'Interruptible','On'              ...
            );
        frm_fra2        = uicontrol(  ...
            comFraProp{:},                    ...
            'Position',pos_fra2               ...
            );
        txt_swtXdec      = uicontrol(  ...
            comTxtProp{:},                    ...
            'Position',pos_txt_swtXdec,        ...
            'String',str_txt_swtXdec           ...
            );
        pop_swtXdec      = uicontrol(  ...
            comPopProp{:},                    ...
            'Position',pos_pop_swtXdec,        ...
            'String',str_pop_swtXdec           ...
            );
        txt_swtXlen      = uicontrol(  ...
            comTxtProp{:},                    ...
            'Position',pos_txt_swtXlen,        ...
            'String',str_txt_swtXlen           ...
            );
        edi_swtXlen      = uicontrol( ...
            comEdiProp{:},                    ...
            'Position',pos_edi_swtXlen,        ...
            'String',str_edi_swtXlen,          ...
            'Backgroundcolor',ediInActBkColor, ...
            'Enable','Inactive'               ...
            );
        txt_swtXclen     = uicontrol(  ...
            comTxtProp{:},                    ...
            'Position',pos_txt_swtXclen,       ...
            'ToolTipString',str_tip_swtXclen,  ...
            'String',str_txt_swtXclen          ...
            );
        edi_swtXclen     = uicontrol(  ...
            comEdiProp{:},                    ...
            'Position',pos_edi_swtXclen,       ...
            'String',str_edi_swtXclen,         ...
            'Backgroundcolor',ediInActBkColor, ...
            'Enable','Inactive'               ...
            );
        txt_swtXdir      = uicontrol(  ...
            comTxtProp{:},                    ...
            'Position',pos_txt_swtXdir,        ...
            'String',str_txt_swtXdir           ...
            );
        edi_swtXdir      = uicontrol(  ...
            comEdiProp{:},                    ...
            'Position',pos_edi_swtXdir,        ...
            'String',str_edi_swtXdir,          ...
            'Backgroundcolor',ediInActBkColor, ...
            'Enable','Inactive'               ...
            );
                              
        % Callback property of objects.
        %------------------------------
        str_win_sext = num2mstrX(win_sigxtoolX);
        cba_edi_deslen = [mfilename '(''update_deslen'',' str_win_sext ');'];
        cba_pop_swtXdec = [mfilename '(''update_swtXdec'',' str_win_sext ');'];
        cba_pop_direct = [mfilename '(''clear_GRAPHICS'',' str_win_sext ');'];
        cba_pop_mode   = [mfilename '(''mode'',' str_win_sext ');'];
        cba_pus_extend = [mfilename '(''extend_truncate'',' str_win_sext ');'];
        set(edi_deslen,'Callback',cba_edi_deslen);
        set(pop_swtXdec,'Callback',cba_pop_swtXdec);
        set(pop_direct,'Callback',cba_pop_direct);
        set(pop_mode,'Callback',cba_pop_mode);
        set(pus_extend,'Callback',cba_pus_extend);

        % Graphic part of the window.
        %============================

        % Axes Construction.
        %-------------------
        commonProp  = {...
           'Parent',win_sigxtoolX,           ...
           'Visible','off',                 ...
           'Units','pixels',                ...
           'XTicklabelMode','manual',       ...
           'YTicklabelMode','manual',       ...
           'XTicklabel',[],'YTicklabel',[], ...
           'XTick',[],'YTick',[],           ...
           'Box','On'                       ...
           };

        % Signal Axes construction.
        %--------------------------
        x_left      = x_graph;
        x_wide      = w_graph-2*x_left;
        y_low       = y_graph+h_graph/10+2*bdy;
        y_height    = 9*h_graph/10-y_low-bdy;
        Pos_Axe_Sig = [x_left, y_low, x_wide, y_height];
        Axe_Sig     = axes(commonProp{:},'Position',Pos_Axe_Sig);
						   
        % Legend Axes construction.
        %--------------------------
        X_Leg       = Pos_Axe_Sig(1);
        Y_Leg       = Pos_Axe_Sig(2) + 11*Pos_Axe_Sig(4)/10;
        W_Leg       = (Pos_Axe_Sig(3) - Pos_Axe_Sig(1)) / 2.5;
        H_Leg       = (Pos_Axe_Sig(4) - Pos_Axe_Sig(2)) / 2;
        Pos_Axe_Leg = [X_Leg Y_Leg W_Leg H_Leg];
        ud.dynvzaxeX.enable = 'Off';
        Axe_Leg = axes(commonProp{:}, ...
            'Position',Pos_Axe_Leg, ...
            'Xlim',[0 180],         ...
            'Ylim',[0 20],          ...
            'Drawmode','fast',      ...
            'userdata',ud           ...
            );
        line(                            ...
            'Parent',Axe_Leg,           ...
            'Xdata',11:30,              ...
            'Ydata',ones(1,20)*14,      ...
            'LineWidth',3,              ...
            'Visible','off',            ...
            'Color','yellow'            ...
            );
        line(                            ...
            'Parent',Axe_Leg,           ...
            'Xdata',11:30,              ...
            'Ydata',ones(1,20)*7,       ...
            'LineWidth',3,              ...
            'Visible','off',            ...
            'Color','red'               ...
            );
        text(40,14,xlate('Transformed signal'), ...
            'Parent',Axe_Leg,           ...
            'FontWeight','normal',      ...
            'Visible','off'             ...
            );
        text(40,7,xlate('Original signal'), ...
                  'Parent',Axe_Leg,           ...
                  'FontWeight','normal',      ...
                  'Visible','off'             ...
                  );

        % Setting units to normalized.
        %-----------------------------
        wfigmngrX('normalize',win_sigxtoolX);

        % Store values.
        %--------------
        Hdls_UIC1 = { ...
            m_load,m_save,m_demo,  ...
            txt_signal,edi_signal, ...
            txt_mode,pop_mode,pus_extend ...
            };
        Hdls_UIC2 = { ...
            frm_fra1,txt_length,edi_length, ...
            txt_nextpow2,edi_nextpow2,      ...
            txt_prevpow2,edi_prevpow2,      ...
            txt_deslen,edi_deslen,          ...
            txt_direct,pop_direct           ...
            };
        Hdls_UIC3 = { ...
            frm_fra2,txt_swtXdec,pop_swtXdec, ...
            txt_swtXlen,edi_swtXlen,          ...
            txt_swtXclen,edi_swtXclen,        ...
            txt_swtXdir,edi_swtXdir           ...
            };
        Hdls_Axes = struct('Axe_Sig',Axe_Sig,'Axe_Leg',Axe_Leg);

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_BORDER_DIST = [txt_mode,pop_mode];
		wfighelpX('add_ContextMenu',win_sigxtoolX,...
			hdl_BORDER_DIST,'BORDER_DIST');
		%-------------------------------------
        
		% Store handles.
        %---------------
        wfigmngrX('storeValue',win_sigxtoolX,'Hdls_UIC1',Hdls_UIC1);
        wfigmngrX('storeValue',win_sigxtoolX,'Hdls_UIC2',Hdls_UIC2);
        wfigmngrX('storeValue',win_sigxtoolX,'Hdls_UIC3',Hdls_UIC3);
        wfigmngrX('storeValue',win_sigxtoolX,'Hdls_Axes',Hdls_Axes);
        wtbxappdataX('set',win_sigxtoolX,'m_exp_sig',m_exp_sig);

        % Set Figure Visible 'On'
        %------------------------
        set(win_sigxtoolX,'Visible','On');

    case 'load'
    %-------------------------------------------%
    % Option: 'LOAD' - Load the original signal %
    %-------------------------------------------%
        % Loading file.
        %-------------
        if length(varargin)<2  % LOAD Option
            [sigInfos,Signal_Anal,ok] = ...
                utguidivX('load_sig',win_sigxtoolX,'*.mat','Load Signal');
            
        elseif isequal(varargin{2},'wrks')  % LOAD from WORKSPACE
            [sigInfos,Signal_Anal,ok] = wtbximportX('1d');

        else   % DEMO Option
            Signal_Name  = deblank(varargin{2});
            filename = [Signal_Name '.mat'];
            pathname = utguidivX('WTB_DemoPath',filename);
            [sigInfos,Signal_Anal,ok] = ...
                utguidivX('load_dem1D',win_sigxtoolX,pathname,filename);
        end
        if ~ok, return; end

        % Begin waiting.
        %---------------
        wwaitingX('msg',win_sigxtoolX,'Wait ... loading');

        % Cleaning.
        %----------
        sigxtoolX('clear_GRAPHICS',win_sigxtoolX,'load');

        % Compute UIC values.
        %--------------------
        Signal_Length = length(Signal_Anal);
        pow           = fix(log(Signal_Length)/log(2));
        Next_Pow2     = 2^(pow+1);
        if isequal(2^pow,Signal_Length)
            Prev_Pow2 = 2^(pow-1);
            swtXpow    = pow;
        else
            Prev_Pow2 = 2^pow;
            swtXpow    = pow+1;
        end

        % Compute the default level for SWT.
        %-----------------------------------
        def_pow = 1;
        if ~rem(Signal_Length,2)
            while ~rem(Signal_Length,2^def_pow), def_pow = def_pow + 1; end
            def_level = def_pow-1;
        else
            def_level = def_pow;
        end

        % Compute the extended length for SWT.
        %-------------------------------------
        C_Length = Signal_Length;
        while rem(C_Length,2^def_level), C_Length = C_Length + 1; end
        
        % Set UIC values.
        %----------------
        set(edi_signal,'String',sigInfos.name);
        set(edi_length,'String',sprintf('%.0f',Signal_Length));
        set(edi_nextpow2,'String',sprintf('%.0f',Next_Pow2));
        set(edi_prevpow2,'String',sprintf('%.0f',Prev_Pow2));
        set(edi_deslen,'String',sprintf('%.0f',Next_Pow2));
        set(pop_direct,'Value',1);
        set(pop_mode,'Value',1);
        set(pus_extend,'String',xlate('Extend'));
        set(pus_extend,'Enable','On');
        set(pop_swtXdec,'String',num2str((1:swtXpow)'));
        set(pop_swtXdec,'Value',def_level);
        set(edi_swtXclen,'String',sprintf('%.0f',C_Length));
        set(edi_swtXlen,'String',sprintf('%.0f',Signal_Length));
                
        % Set UIC visibility.
        %--------------------
        set(cat(1,Hdls_UIC2{:}),'visible','on')
        set(cat(1,Hdls_UIC3{:}),'visible','off')
        set(cat(1,Hdls_UIC1{4:end}),'visible','on')

        % Get Axes Handles.
        %------------------
        Axe_Sig =  Hdls_Axes.Axe_Sig;

        % Drawing.
        %---------
        Line_Sig = line(                         ...
                        'parent',Axe_Sig,        ...
                        'Xdata',1:Signal_Length, ...
                        'Ydata',Signal_Anal,     ...
                        'color','Green'          ...
                        );
        Max_Sig           = max(Signal_Anal);
        Min_Sig           = min(Signal_Anal);
        Amp_Sig           = Max_Sig - Min_Sig;
        Ylim_Min_Sig_Anal = Min_Sig-Amp_Sig/100;
        Ylim_Max_Sig_Anal = Max_Sig-Amp_Sig/100;
        set(Axe_Sig,                                      ...
            'Xlim',[1,Signal_Length],                     ...
            'Ylim',[Ylim_Min_Sig_Anal,Ylim_Max_Sig_Anal], ...
            'Visible','on'                                ...
            );
        set(get(Axe_Sig,'title'),'string',xlate('Original Signal'));
		
        % Store values.
        %--------------
        wfigmngrX('storeValue',win_sigxtoolX,'Signal_Anal',Signal_Anal);
        wfigmngrX('storeValue',win_sigxtoolX,'Line_Sig',Line_Sig);

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 0;
        wfigmngrX('storeValue',win_sigxtoolX,'File_Save_Flag',File_Save_Flag);
        
        % Dynvtool Attachment.
        %---------------------
        dynvtoolX('init',win_sigxtoolX,[],Axe_Sig,[],[1 0],'','','');

        % End waiting.
        %-------------
        wwaitingX('off',win_sigxtoolX);


    case 'demo'
        sigxtoolX('load',varargin{:});
        ext_OR_trunc = varargin{3};
        if length(varargin)>3  && ~isempty(varargin{4})
            par_Demo = varargin{4};
        else
            return;
        end
        extMode   = par_Demo{1};
        lenSIG    = par_Demo{2};
        direction = lower(par_Demo{3});
        if ~isequal(extMode,'swtX')
            set(edi_deslen,'String',sprintf('%.0f',lenSIG));
            sigxtoolX('update_deslen',win_sigxtoolX,'noClear');
        else
            set(pop_swtXdec,'Value',lenSIG)
            sigxtoolX('update_swtXdec',win_sigxtoolX)
        end
        switch direction
          case 'both'  , direct = 1;
          case 'left'  , direct = 2;
          case 'right' , direct = 3;
        end
        set(pop_direct,'Value',direct);
        switch ext_OR_trunc
          case 'ext'
            switch extMode
              case 'sym' ,         extVal = 1;
              case 'ppd' ,         extVal = 5;
              case 'zpd' ,         extVal = 6;
              case 'sp0' ,         extVal = 7;
              case {'sp1','spd'} , extVal = 8;
              case 'swtX' ,         extVal = 9;
            end
            set(pop_mode,'Value',extVal);
            sigxtoolX('mode',win_sigxtoolX,'noClear')

          case 'trunc'
        end
        sigxtoolX('extend_truncate',win_sigxtoolX);

    case 'update_swtXdec'
    %----------------------------------------------------------------------%
    % Option: 'UPDATE_SWTDEC' - Update values when using popup in SWT case %
    %----------------------------------------------------------------------%

        % Get stored structure.
        %----------------------
        Signal_Anal = wfigmngrX('getValue',win_sigxtoolX,'Signal_Anal');

        % Update the computed length.
        %----------------------------
        Signal_Length = length(Signal_Anal);
        Level         = get(pop_swtXdec,'Value');
        remLen        = rem(Signal_Length,2^Level);
        if remLen>0
            Computed_Length = Signal_Length + 2^Level-remLen;
        else
            Computed_Length = Signal_Length;
        end
        set(edi_swtXclen,'String',sprintf('%.0f',Computed_Length));

        % Enabling Extend button.
        %------------------------
        set(pus_extend,'String','Extend','Enable','on');

    case 'update_deslen'
    %--------------------------------------------------------------------------%
    % Option: 'UPDATE_DESLEN' - Update values when changing the Desired Length %
    %--------------------------------------------------------------------------%

        % Cleaning.
        %----------
        if nargin<3 , sigxtoolX('clear_GRAPHICS',win_sigxtoolX); end

        % Update UIC values.
        %-------------------
        Signal_Length  = wstr2numX(get(edi_length,'String'));
        Desired_Length = wstr2numX(get(edi_deslen,'String'));
        uic_mode       = [txt_mode;pop_mode];
        if     	isequal(Signal_Length,Desired_Length)
                set(uic_mode,'Enable','off');
                set(pus_extend,'Enable','off');
        elseif  isempty(Desired_Length) || Desired_Length < 2
                set(edi_deslen,'String',get(edi_nextpow2,'String'));
                set(txt_direct,'String','Direction to extend');
                set(uic_mode,'Enable','on');
                set(pus_extend,'String',xlate('Extend'),'Enable','on');
        elseif	Signal_Length < Desired_Length
                set(txt_direct,'String','Direction to extend')
                set(uic_mode,'Visible','On','Enable','on');
                set(pus_extend,'String',xlate('Extend'),'Enable','on');
        elseif	Signal_Length > Desired_Length
                set(txt_direct,'String','Direction to truncate');
                set(uic_mode,'Visible','off','Enable','on');
                set(pus_extend,'String',xlate('Truncate'),'Enable','on');
        end
	
    case 'mode'
    %------------------------------------------------------------------------%
    % Option: 'MODE' -  Update the command part when changing Extension Mode %
    %------------------------------------------------------------------------%      

        % Cleaning.
        %----------
        if nargin<3 , sigxtoolX('clear_GRAPHICS',win_sigxtoolX); end

        % Checking the SWT case for visibility settings.
        %----------------------------------------------
        Mode_str = get(pop_mode,'String');
        Mode_val = get(pop_mode,'Value');
        if  strcmp(deblank(Mode_str(Mode_val,:)),'For SWT')
            set(cat(1,Hdls_UIC2{:}),'visible','off');
            set(cat(1,Hdls_UIC3{:}),'visible','on');
            Signal_Length   = wstr2numX(get(edi_swtXlen,'String'));
            Computed_Length = wstr2numX(get(edi_swtXclen,'String'));
            if isequal(Signal_Length,nextpow2(Signal_Length))
                set(pus_extend,'Enable','off');
                msg = {...
                  sprintf('The length of the signal (%s) is a power of 2.',...
                          int2str(Signal_Length)),...
                  'The SWT extension is not necessary!'};
                wwarndlgX(msg,'SWT Extension Mode','block');

            elseif Signal_Length < Computed_Length
                set(pus_extend,'String',xlate('Extend'),'Enable','on');
            end
        else
            set(pus_extend,'Enable','on');
            set(cat(1,Hdls_UIC2{:}),'visible','on');
            set(cat(1,Hdls_UIC3{:}),'visible','off');
        end
        set(cat(1,Hdls_UIC1{4:end}),'visible','on');

    case 'extend_truncate'
    %--------------------------------------------------------------------------%
    % Option: 'EXTEND_TRUNCATE' - Compute the new Extended or Truncated signal %
    %--------------------------------------------------------------------------%
        
        % Begin waiting.
        %---------------
        wwaitingX('msg',win_sigxtoolX,'Wait ... computing');

        % Get stored structure.
        %----------------------
        Signal_Anal = wfigmngrX('getValue',win_sigxtoolX,'Signal_Anal');
                
        % Get Axes Handles.
        %------------------
%         Axe_Sig     =  Hdls_Axes.Axe_Sig;

        % Compute Ylim of Original Signal.
        %---------------------------------
%         Max_Sig           = max(Signal_Anal);
%         Min_Sig           = min(Signal_Anal);
%         Amp_Sig           = Max_Sig - Min_Sig;
%         Ylim_Min_Sig_Anal = Min_Sig-Amp_Sig/100;
%         Ylim_Max_Sig_Anal = Max_Sig-Amp_Sig/100;
%         Axe_Sig_Ylim      = [Ylim_Min_Sig_Anal,Ylim_Max_Sig_Anal];

        % Get UIC values.
        %----------------
        Signal_Length  = wstr2numX(get(edi_length,'String'));
%         Desired_Length = wstr2numX(get(edi_deslen,'String'));
        Str_pop_mode   = get(pop_mode,'String');
        last_Mode = length(Str_pop_mode);
        Val_pop_mode   = get(pop_mode,'Value');
        if isequal(Val_pop_mode,last_Mode)
            Str_direct     = deblank(get(edi_swtXdir,'String'));
            Desired_Length = wstr2numX(get(edi_swtXclen,'String'));
        else
            Str_pop_direct = get(pop_direct,'String');
            Val_pop_direct = get(pop_direct,'Value');
            Str_direct     = deblank(Str_pop_direct(Val_pop_direct,:));
            Desired_Length = wstr2numX(get(edi_deslen,'String'));
        end

        % Extension mode conversion.
        %---------------------------
        Mode_Values = {'sym';'symw';'asym';'asymw';'ppd';'zpd';'sp0';'spd';'ppd'};
        Mode        = Mode_Values{Val_pop_mode};

        % Get action to do.
        %------------------
        action = deblank(xlate(get(pus_extend,'string')));
        switch action
            case xlate('Truncate')
 	
                switch Str_direct
                  case 'Left'

                        % Computing new signal.
                        %----------------------
                        New_Signal  = wkeep1X(Signal_Anal,Desired_Length,'r');
			
                        % Drawing.
                        %---------
                        Deb_O_S     = 1;
                        Fin_O_S     = Signal_Length;
                        Deb_N_S     = 1 + Signal_Length - Desired_Length;
                        Fin_N_S     = Signal_Length;
                        Signal_Lims = [Deb_O_S Fin_O_S Deb_N_S Fin_N_S];
                        sigxtoolX('draw',win_sigxtoolX,Signal_Anal, ...
                                    Signal_Lims,action);

                  case 'Right'

                        % Computing new signal.
                        %----------------------
                        New_Signal = wkeep1X(Signal_Anal,Desired_Length,'l');
			
                        % Drawing.
                        %---------
                        Deb_O_S     = 1;
                        Fin_O_S     = Signal_Length;
                        Deb_N_S     = 1;
                        Fin_N_S     = Desired_Length;
                        Signal_Lims = [Deb_O_S Fin_O_S Deb_N_S Fin_N_S];
                        sigxtoolX('draw',win_sigxtoolX,Signal_Anal, ...
                                    Signal_Lims,action);

                  case 'Both'

                        % Computing new signal.
                        %----------------------
                        New_Signal = wkeep1X(Signal_Anal,Desired_Length,'c');
			
                        % Drawing.
                        %---------
                        Deb_O_S     = 1;
                        Fin_O_S     = Signal_Length;
                        Deb_N_S     = fix((Signal_Length - Desired_Length)/2)+1;
                        Fin_N_S     = Deb_N_S + Desired_Length - 1;
                        Signal_Lims = [Deb_O_S Fin_O_S Deb_N_S Fin_N_S];
                        sigxtoolX('draw',win_sigxtoolX,Signal_Anal, ...
                                    Signal_Lims,action);

                  otherwise
                      errargtX(mfilename,'Unknown Option','msg');
                      error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
                          'Invalid Input Argument.');

                end
		
            case xlate('Extend')
            
                switch Str_direct
                    case 'Left'

                        % Computing new signal.
                        %----------------------
                        New_Signal = wextendX(1,Mode,Signal_Anal, ...
                                            Desired_Length-Signal_Length,'l');

                        % Drawing.
                        %---------
                        Deb_O_S     = Desired_Length - Signal_Length + 1;
                        Fin_O_S     = Deb_O_S + Signal_Length - 1;
                        Deb_N_S     = 1;
                        Fin_N_S     = Desired_Length;
                        Signal_Lims = [Deb_O_S Fin_O_S Deb_N_S Fin_N_S];
                        sigxtoolX('draw',win_sigxtoolX,New_Signal, ...
                                    Signal_Lims,action);

                    case 'Right'

                        % Computing new signal.
                        %----------------------
                        New_Signal = wextendX(1,Mode,Signal_Anal, ...
                                            Desired_Length-Signal_Length,'r');

                        % Drawing.
                        %---------
                        Deb_O_S     = 1;
                        Fin_O_S     = Signal_Length;
                        Deb_N_S     = 1;
                        Fin_N_S     = Desired_Length;
                        Signal_Lims = [Deb_O_S Fin_O_S Deb_N_S Fin_N_S];
                        sigxtoolX('draw',win_sigxtoolX,New_Signal, ...
                                    Signal_Lims,action);

                    case 'Both'

                        % Computing new signal.
                        %----------------------
                        Diff_Length = Desired_Length-Signal_Length;
                        Ext_Length  = ceil(Diff_Length / 2);
                        New_Signal  = wextendX(1,Mode,Signal_Anal,Ext_Length,'b');
                        if rem(Diff_Length,2)
                            New_Signal = wkeep1X(New_Signal,Desired_Length,'c',1);
                        end

                        % Drawing.
                        %---------
                        Deb_O_S     = fix(Diff_Length / 2) + 1;
                        Fin_O_S     = Deb_O_S + Signal_Length-1;
                        Deb_N_S     = 1;
                        Fin_N_S     = Desired_Length;
                        Signal_Lims = [Deb_O_S Fin_O_S Deb_N_S Fin_N_S];
                        sigxtoolX('draw',win_sigxtoolX,New_Signal, ...
                                    Signal_Lims,action);

                    otherwise
                        errargtX(mfilename,'Unknown Option','msg');
                        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
                            'Invalid Input Argument.');

                end

            otherwise
                errargtX(mfilename,'Unknown Action','msg');
                error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
                    'Invalid Input Argument.');
        end
		
        % Saving the new signal.
        %-----------------------		
        wfigmngrX('storeValue',win_sigxtoolX,'New_Signal',New_Signal);

        % End waiting.
        %-------------
        wwaitingX('off',win_sigxtoolX);
        
    case 'draw'
    %-----------------------------------------------------%
    % Option: 'DRAW' - Plot both new and original signals %
    %-----------------------------------------------------%
						
        % Get arguments.
        %---------------
        Signal      = varargin{2};
        Signal_Lims = varargin{3};
        action      = varargin{4};
        Deb_O_S     = Signal_Lims(1);
        Fin_O_S     = Signal_Lims(2);
        Deb_N_S     = Signal_Lims(3);
        Fin_N_S     = Signal_Lims(4);
        
        % Begin waiting.
        %---------------
        wwaitingX('msg',win_sigxtoolX,'Wait ... drawing');

        % Get stored structure.
        %----------------------
        Line_Sig    = wfigmngrX('getValue',win_sigxtoolX,'Line_Sig');
        Box_Old_Sig = wfigmngrX('getValue',win_sigxtoolX,'Box_Old_Sig');
        Box_New_Sig = wfigmngrX('getValue',win_sigxtoolX,'Box_New_Sig');

        % Get Axes Handles.
        %------------------
        Axe_Sig =  Hdls_Axes.Axe_Sig;
        Axe_Leg =  Hdls_Axes.Axe_Leg;
		
        % Clean signals axes.
        %--------------------
        if ~isempty(Box_Old_Sig), delete(Box_Old_Sig); end
        if ~isempty(Box_New_Sig), delete(Box_New_Sig); end

        % Compute Ylim for the Signal.
        %-----------------------------
        Len_Signal = length(Signal);
        Max_Signal = max(Signal);
        Min_Signal = min(Signal);
        Off_Signal = (Max_Signal - Min_Signal) / 100;
        Ylim_Min   = Min_Signal - 10 * Off_Signal;
        Ylim_Max   = Max_Signal + 10 * Off_Signal;

        % Update axes properties.
        %------------------------
        set(Axe_Sig,                    ...
            'Box','on',                 ...
            'Xlim',[1,Len_Signal],      ...
            'Ylim',[Ylim_Min,Ylim_Max], ...
            'Visible','on'              ...
            );
        set(get(Axe_Sig,'title'),'string','');

        % Draw signal.
        %-------------
        X   = 1:Len_Signal;
        Y   = Signal;
        set(Line_Sig,'Xdata',X,'Ydata',Y,'parent',Axe_Sig);

        switch action

            case xlate('Extend')

                % Constant coefs. for box design.
                %--------------------------------
                C1 = 7;
                C2 = 3;
                S1 = 3;
                S2 = 3;
                                    
                % Draw Box around old signal.
                %----------------------------
                Y_base      = [Ylim_Min Ylim_Max Ylim_Max Ylim_Min Ylim_Min];
                X           = [Deb_O_S Deb_O_S Fin_O_S Fin_O_S Deb_O_S];
                Y           = Y_base + [C1 -C1 -C1 C1 C1]*Off_Signal;
                Box_Old_Sig = line(X,Y,              ...
                                   'parent',Axe_Sig, ...
                                   'color','red',    ...
                                   'LineWidth',S1    ...
                                   );
        
                % Draw Box around new signal.
                %----------------------------
                X   	    = [Deb_N_S Deb_N_S Fin_N_S Fin_N_S Deb_N_S];
                Y           = Y_base + [C2 -C2 -C2 C2 C2]*Off_Signal;
                Box_New_Sig = line(X,Y,              ...
                                   'parent',Axe_Sig, ...
                                   'color','yellow', ...
                                   'LineWidth',S2    ...
                                   );

            case xlate('Truncate')

                % Constant coefs. for box design.
                %--------------------------------
                C1 = 3;
                C2 = 7;
                S1 = 3;
                S2 = 3;

                % Draw Box around old signal.
                %----------------------------
                Y_base      = [Ylim_Min Ylim_Max Ylim_Max Ylim_Min Ylim_Min];
                X   	    = [Deb_O_S Deb_O_S Fin_O_S Fin_O_S Deb_O_S];
                Y           = Y_base + [C1 -C1 -C1 C1 C1] * Off_Signal;
                Box_Old_Sig = line(X,Y,              ...
                                   'parent',Axe_Sig, ...
                                   'color','red',    ...
                                   'LineWidth',S1    ...
                                   );
                         
                % Draw Box around new signal.
                %----------------------------
                X           = [Deb_N_S Deb_N_S Fin_N_S Fin_N_S Deb_N_S];
                Y           = Y_base + [C2 -C2 -C2 C2 C2] * Off_Signal;
                Box_New_Sig = line(X,Y,              ...
                                   'parent',Axe_Sig, ...
                                   'color','yellow', ...
                                   'LineWidth',S2    ...
                                   );
        end
				
        % Display Legend.
        %----------------
        set(Axe_Leg,'Visible','on');
        set(get(Axe_Leg,'Children'),'Visible','on');

        % Dynvtool Attachment.
        %----------------------
        dynvtoolX('init',win_sigxtoolX,[],Axe_Sig,[],[1 0],'','','');

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 0;
        wfigmngrX('storeValue',win_sigxtoolX,'File_Save_Flag',File_Save_Flag);
        
        % Enable save menu On.
        %---------------------
        set([m_save,m_exp_sig],'Enable','on');

        % Store values.
        %--------------        
        wfigmngrX('storeValue',win_sigxtoolX,'Box_Old_Sig',Box_Old_Sig);
        wfigmngrX('storeValue',win_sigxtoolX,'Box_New_Sig',Box_New_Sig);

        % End waiting.
        %-------------
        wwaitingX('off',win_sigxtoolX);
        		
    case 'save'
    %------------------------------------------%
    % Option: 'SAVE' - Save transformed signal %
    %------------------------------------------%

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_sigxtoolX,'Wait ... saving');
				
        % Restore the new signal.
        %------------------------		
        x = wfigmngrX('getValue',win_sigxtoolX,'New_Signal'); %#ok<NASGU>
			
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_sigxtoolX, ...
                                    '*.mat','Save Transformed Signal');
        if ~ok, return; end

        % Saving transformed Signal.
        %---------------------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        try
          eval([name ' = x ;']);
        catch
          name = 'x';
        end
        saveStr = name;        
        try
          save([pathname filename],saveStr);
        catch
          errargtX(mfilename,'Save FAILED !','msg');
        end

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 1;
        wfigmngrX('storeValue',win_sigxtoolX,'File_Save_Flag',File_Save_Flag);
        
        % Enable save menu On.
        %---------------------
        set([m_save,m_exp_sig],'Enable','off');
                
        % End waiting.
        %-------------
        wwaitingX('off',win_sigxtoolX);
        
    case 'exp_wrks'
        wwaitingX('msg',win_sigxtoolX,'Wait ... exporting data');
        x = wfigmngrX('getValue',win_sigxtoolX,'New_Signal');
        wtbxexportX(x,'name','sig_1D','title','Extended Signal');
        wwaitingX('off',win_sigxtoolX);        
		
    case 'clear_GRAPHICS'
    %----------------------------------------------------------------------%
    % Option: 'CLEAR_GRAPHICS' - Clear graphics and redraw original signal %
    %----------------------------------------------------------------------%

        % Get arguments.
        %---------------
        if length(varargin) > 1 , Draw_flag = 0; else Draw_flag = 1; end
		
        % Get stored structure.
        %----------------------
        Signal_Anal = wfigmngrX('getValue',win_sigxtoolX,'Signal_Anal');
        Line_Sig    = wfigmngrX('getValue',win_sigxtoolX,'Line_Sig');

        % Get Axes Handles.
        %------------------
        Axe_Sig = Hdls_Axes.Axe_Sig;
        Axe_Leg = Hdls_Axes.Axe_Leg;
				
        % Set graphics part visible off and redraw original signal if needed.
        %--------------------------------------------------------------------
        set(Axe_Leg,'Visible','off');
        set(get(Axe_Leg,'Children'),'Visible','off');
        if Draw_flag
            set(findobj(Axe_Sig,'Type','line'),'Visible','Off');
            Signal_Length     = length(Signal_Anal);
            Max_Sig           = max(Signal_Anal);
            Min_Sig           = min(Signal_Anal);
            Amp_Sig           = Max_Sig - Min_Sig;
            Ylim_Min_Sig_Anal = Min_Sig-Amp_Sig/100;
            Ylim_Max_Sig_Anal = Max_Sig-Amp_Sig/100;
            set(Axe_Sig,                                      ...
                'Xlim',[1,Signal_Length],                     ...
                'Ylim',[Ylim_Min_Sig_Anal,Ylim_Max_Sig_Anal], ...
                'Visible','on'                                ...
                );
            set(get(Axe_Sig,'title'),'string',xlate('Original Signal'));
            set(Line_Sig, ...
                'parent',Axe_Sig,        ...
                'Xdata',1:Signal_Length, ...
                'Ydata',Signal_Anal,     ...
                'color','Green',         ...
                'Visible','on'           ...
                );
            dynvtoolX('init',win_sigxtoolX,[],Axe_Sig,[],[1 0],'','','');
        else
            set(Axe_Sig,'Visible','off');
            set(get(Axe_Sig,'Children'),'Visible','off');
        end

        % Enable save menu off.
        %----------------------
        set([m_save,m_exp_sig],'Enable','off');
		
        % Reset the new signal.
        %----------------------		
        wfigmngrX('storeValue',win_sigxtoolX,'New_Signal',[]);
        
    case 'close'
    %---------------------------------------%
    % Option: 'CLOSE' - Close current figure%
    %---------------------------------------%

        % Retrieve File_Save_Flag.
        %-------------------------
        File_Save_Flag = wfigmngrX('getValue',win_sigxtoolX,'File_Save_Flag');
        		
        % Retrieve signal values.
        %------------------------		
        New_Signal  = wfigmngrX('getValue',win_sigxtoolX,'New_Signal');
        Signal_Anal = wfigmngrX('getValue',win_sigxtoolX,'Signal_Anal');
        
        % Test for saving the new signal.
        %--------------------------------
        status = 0;
        if ~isempty(New_Signal) && length(New_Signal)~=length(Signal_Anal) ...
                && ~File_Save_Flag
            status = wwaitansX(win_sigxtoolX,...
                     ' Do you want to save the transformed signal ?',2,'cond');
        end
        switch status
          case 1 , sigxtoolX('save',win_sigxtoolX)
          case 0 ,
        end
        varargout{1} = status;

    otherwise
    %-----------------%
    % Option: UNKNOWN %
    %-----------------%    
    errargtX(mfilename,'Unknown Option','msg');
    error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
        'Invalid Input Argument.');

end
