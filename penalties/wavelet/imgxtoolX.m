function varargout = imgxtoolX(option,varargin)
%IMGXTOOL Image extension tool.
%   VARARGOUT = IMGXTOOL(OPTION,VARARGIN)
%
%   GUI oriented tool which allows the construction of a new
%   image from an original one by truncation or extension.
%   Extension is done by selecting different possible modes:
%   Symmetric, Periodic, Zero Padding, Continuous or Smooth.
%   A special mode is provided to extend an image in order 
%   to be accepted by the SWT decomposition.
%------------------------------------------------------------
%   Internal options:
%
%   OPTION = 'create'          'load'             'demo'
%            'update_deslen'   'extend_truncate'
%            'draw'            'save'
%            'clear_graphics'  'mode'
%            'close'
%
%   See also WEXTEND.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 30-Nov-98.
%   Last Revision: 22-Jun-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidivX('ini',option,varargin{:});

% Default values.
%----------------
default_nbcolors = 255;

% Image Coding Value.
%-------------------
codemat_v = wimgcodeX('get');

% Initialisations for all options excepted 'create'.
%---------------------------------------------------
switch option

  case 'create'
  
  otherwise
    % Get figure handle.
    %-------------------
    win_imgxtoolX = varargin{1};

    % Get stored structure.
    %----------------------
    Hdls_UIC_C      = wfigmngrX('getValue',win_imgxtoolX,'Hdls_UIC_C');
    Hdls_UIC_H      = wfigmngrX('getValue',win_imgxtoolX,'Hdls_UIC_H');
    Hdls_UIC_V      = wfigmngrX('getValue',win_imgxtoolX,'Hdls_UIC_V');
    Hdls_UIC_Swt    = wfigmngrX('getValue',win_imgxtoolX,'Hdls_UIC_Swt');
    Hdls_Axes       = wfigmngrX('getValue',win_imgxtoolX,'Hdls_Axes');
    Hdls_Colmap     = wfigmngrX('getValue',win_imgxtoolX,'Hdls_Colmap');
    Pos_Axe_Img_Ori = wfigmngrX('getValue',win_imgxtoolX,'Pos_Axe_Img_Ori');
 
    % Get UIC Handles.
    %-----------------
    [m_load,m_save,m_demo,txt_image,edi_image,...
     txt_mode,pop_mode,pus_extend] = deal(Hdls_UIC_C{:}); %#ok<ASGLU>
    m_exp_sig = wtbxappdataX('get',win_imgxtoolX,'m_exp_sig'); 
 
    [frm_fra_H,txt_fra_H,txt_length_H,edi_length_H,txt_nextpow2_H,  ...
     edi_nextpow2_H,txt_prevpow2_H,edi_prevpow2_H,txt_deslen_H,     ...
     edi_deslen_H,txt_direct_H,pop_direct_H] = deal(Hdls_UIC_H{:}); %#ok<ASGLU>
 
    [frm_fra_V,txt_fra_V,txt_length_V,edi_length_V,txt_nextpow2_V,  ...
     edi_nextpow2_V,txt_prevpow2_V,edi_prevpow2_V,txt_deslen_V,     ...
     edi_deslen_V,txt_direct_V,pop_direct_V] = deal(Hdls_UIC_V{:}); %#ok<ASGLU>
 
    [txt_swtXdec,pop_swtXdec,frm_fra_H_2,txt_fra_H_2,txt_swtXlen_H,    ...
     edi_swtXlen_H,txt_swtXclen_H,edi_swtXclen_H,txt_swtXdir_H,         ...
     edi_swtXdir_H,txt_swtXdec,pop_swtXdec,frm_fra_V_2,txt_fra_V_2,    ...
     txt_swtXlen_V,edi_swtXlen_V,txt_swtXclen_V,edi_swtXclen_V          ...
     ] = deal(Hdls_UIC_Swt{1:end-2}); %#ok<ASGLU>
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
        [win_imgxtoolX,pos_win,win_units,str_numwin,pos_frame0] = ...
                wfigmngrX('create','Image Extension / Truncation',  ...
                         winAttrb,'ExtFig_Tool_3',                 ...
                        {mfilename,'cond'},1,1,0);
        if nargout>0 , varargout{1} = win_imgxtoolX; end
		
		% Add Help for Tool.
		%------------------
		wfighelpX('addHelpTool',win_imgxtoolX, ...
			'Two-Dimensional &Extension','IMGX_GUI');

		% Add Help Item.
		%----------------
		wfighelpX('addHelpItem',win_imgxtoolX,...
			'Dealing with Border Distortion','BORDER_DIST');

        % Menu construction for current figure.
        %--------------------------------------
        m_files = wfigmngrX('getmenus',win_imgxtoolX,'file');
        m_load  = uimenu(m_files,'Label','&Load Image','Position',1, ...
            'Callback',[mfilename '(''load'',' str_numwin ');']  ...            
            );
        m_save  = uimenu(m_files,...
            'Label','&Save Transformed Image',       ...
            'Position',2,                            ...
            'Enable','Off',                          ...
            'Callback',                              ...
            [mfilename '(''save'',' str_numwin ');'] ...
            );
        m_demo  = uimenu(m_files, ...
                         'Label','&Example Extension','Position',3);
        uimenu(m_files,...
            'Label','Import Image from Workspace', ...
            'Position',4,'Separator','On', ...
            'Callback', ...
            [mfilename '(''load'',' str_numwin ',''wrks'');'] ...
            );
        m_exp_sig = uimenu(m_files,...
            'Label','Export Image to Workspace',  ...
            'Position',5,'Enable','Off','Separator','Off', ...
            'Callback',[mfilename '(''exp_wrks'',' str_numwin ');']  ...
            ); 
        
        m_demoIDX = uimenu(m_demo,'Label','Indexed Images ','Position',1);
        m_demoCOL = uimenu(m_demo,'Label','Truecolor Images ','Position',2);
        demoSET = {...
         'woman2'  , 'ext'   , '{''zpd'' , [220,200] , ''both'' , ''both''}' , 'BW' ; ...
         'woman2'  , 'trunc' , '{''nul'' , [ 96, 96] , ''both'' , ''both''}' , 'BW' ; ...
         'wbarb'   , 'ext'   , '{''sym'' , [512,200] , ''right'', ''both''}' , 'BW' ; ...
         'noiswom' , 'ext'   , '{''sym'' , [512,512] , ''right'', ''down''}' , 'BW' ; ...
         'noiswom' , 'ext'   , '{''ppd'' , [512,512] , ''right'', ''down''}' , 'BW' ; ...
         'wbarb'   , 'ext'   , '{''sym'' , [512,512] , ''both'' , ''both''}' , 'BW' ; ...
         'facets'  , 'ext'   , '{''ppd'' , [512,512] , ''both'' , ''both''}' , 'COL' ; ...
         'mandel'  , 'ext'   , '{''sym'' , [512,512] , ''left'' , ''both''}' , 'COL'  ...
         };
        nbDEM = size(demoSET,1);
        beg_call_str = [mfilename '(''demo'',' str_numwin ','''];
		
		names = demoSET(:,1);
		tab   = char(9);
        for k = 1:nbDEM
            typ = demoSET{k,2};
            fil = demoSET{k,1};
            par = demoSET{k,3};
            optIMG = demoSET{k,4};
            parVal = eval(par);
            switch parVal{1}
              case 'swtX'
                lenSTR = [' - level: ',int2str(parVal{2})];
              otherwise
                lenSTR = [' - size: [' , int2str(parVal{2}) , ']'];
            end
            strPAR = ['mode: ' ,  parVal{1} , lenSTR, ...
                      ' - direction: [', parVal{3} , ',' parVal{4} ,']'];
            switch  typ
              case 'ext'   , strTYPE = 'Extension  - ';
              case 'trunc' , strTYPE = 'Truncation - ';
            end
            libel = [names{k} tab '  -  ' strTYPE strPAR];
            action = [beg_call_str fil  ''',''' typ ''',' par ...
                ''',''' optIMG ''');'];
            if k<7 , md = m_demoIDX; else md = m_demoCOL; end
            uimenu(md,'Label',libel,'Callback',action);
        end

        % Borders and double borders.
        %----------------------------
        dx = X_Spacing; dx2 = 2*dx;
        dy = Y_Spacing; dy2 = 2*dy;

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
        delta_Xleft        = wtbutilsX('extension_PREFS');          
        xlocINI            = [x_frame0 cmd_width];
        ybottomINI         = pos_win(4)-dy2;
        x_left_0           = x_frame0 + dx2 + dx;
        x_left_1           = x_left_0 + txt_width/2 + delta_Xleft;
        x_left_2           = x_left_1 + edi_width;
        
        y_low              = ybottomINI-(btn_Height+1*dy2);
        pos_txt_image      = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_image      = [x_left_1, y_low+dy/2, 2*edi_width, btn_Height];

        y_low              = y_low-1.5*(btn_Height+2*dy2);
        pos_txt_length_H   = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_length_H   = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+1*dy2);
        pos_txt_nextpow2_H = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_nextpow2_H = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+1*dy2);
        pos_txt_prevpow2_H = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_prevpow2_H = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+1*dy2);
        pos_txt_deslen_H   = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_deslen_H   = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+1*dy2);
        pos_txt_direct_H   = [x_left_0, y_low, txt_width, btn_Height];
        pos_pop_direct_H   = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        fra_left           = x_left_0-dx2;
        fra_low            = y_low-dy;
        fra_width          = cmd_width-dx2;
        fra_height         = 5*(btn_Height+1*dy2)+dy2;
        pos_fra_H          = [fra_left, fra_low, fra_width, fra_height];
        txt_fra_H_height   = 3*btn_Height/4;
        txt_fra_H_width    = Def_Btn_Width;
        txt_fra_H_low      = (fra_low + fra_height) - (txt_fra_H_height / 2);
        txt_fra_H_left     = fra_left + (fra_width - txt_fra_H_width) / 2;
        pos_txt_fra_H      = [txt_fra_H_left, txt_fra_H_low, ...
                               txt_fra_H_width, txt_fra_H_height];
 
        y_low              = fra_low-1.5*(btn_Height+2*dy2);
        pos_txt_length_V   = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_length_V   = [x_left_2, y_low+dy, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+1*dy2);
        pos_txt_nextpow2_V = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_nextpow2_V = [x_left_2, y_low+dy/2, edi_width, btn_Height];

        y_low              = y_low-(btn_Height+dy2);
        pos_txt_prevpow2_V = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_prevpow2_V = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+dy2);
        pos_txt_deslen_V   = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_deslen_V   = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+1*dy2);
        pos_txt_direct_V   = [x_left_0, y_low, txt_width, btn_Height];
        pos_pop_direct_V   = [x_left_2, y_low+dy/2, edi_width , btn_Height];
 
        fra_left           = x_left_0-dx2;
        fra_low            = y_low-dy;
        fra_width          = cmd_width-dx2;
        fra_height         = 5*(btn_Height+dy2)+dy2;
        pos_fra_V          = [fra_left, fra_low, fra_width, fra_height];
        txt_fra_V_height   = 3* btn_Height/4;
        txt_fra_V_width    = Def_Btn_Width;
        txt_fra_V_low      = (fra_low + fra_height) - (txt_fra_V_height / 2);
        txt_fra_V_left     = fra_left + (fra_width - txt_fra_V_width) / 2;
        pos_txt_fra_V      = [txt_fra_V_left, txt_fra_V_low, ...
                               txt_fra_V_width, txt_fra_V_height];

        x_left             = x_left_0-dx2+(cmd_width-3*txt_width/4)/2;
        y_low              = fra_low-(btn_Height+1*dy2);
        pos_txt_mode       = [x_left, y_low, txt_width btn_Height];
 
        y_low              = y_low-(btn_Height+dy);
        pos_pop_mode       = [x_left_0, y_low, pus_width+2*dx2 , btn_Height];

        y_low              = y_low-2*btn_Height-dy;
        pos_pus_extend     = [x_left_0+dx2, y_low, pus_width , 1.5*btn_Height];

        pos_fra_H_2        = pos_fra_H;
        pos_fra_H_2(2)     = pos_fra_H(2)-btn_Height;
        pos_fra_H_2(4)     = 3*(btn_Height+2*dy2)+dy;

        txt_fra_H_height   = 3*btn_Height/4;
        txt_fra_H_width    = Def_Btn_Width;
        txt_fra_H_low      = (pos_fra_H_2(2)+pos_fra_H_2(4))-(txt_fra_H_height/2);
        txt_fra_H_left     = pos_fra_H_2(1)+(pos_fra_H_2(3)-txt_fra_H_width)/ 2;
        pos_txt_fra_H_2    = [txt_fra_H_left, txt_fra_H_low,...
                              txt_fra_H_width, txt_fra_H_height];
 
        x_left             = x_left_0-dx2;
        y_low              = pos_fra_H_2(2)+pos_fra_H_2(4)+3*dy2;
        pos_txt_swtXdec     = [x_left, y_low, 9*txt_width/8, btn_Height];
        x_left             = x_left + pos_txt_swtXdec(3);
        pos_pop_swtXdec     = [x_left, y_low+dy, edi_width, btn_Height];
 
        y_low              = pos_fra_H_2(2)+pos_fra_H_2(4)-(btn_Height+2*dy2);
        pos_txt_swtXlen_H   = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtXlen_H   = [x_left_2, y_low+dy, edi_width, btn_Height];
 
        y_low              = y_low-(btn_Height+2*dy2);
        pos_txt_swtXclen_H  = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtXclen_H  = [x_left_2, y_low+dy, edi_width, btn_Height];
 
        y_low              = y_low-(btn_Height+2*dy2);
        pos_txt_swtXdir_H   = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtXdir_H   = [x_left_2, y_low+dy, edi_width, btn_Height];
 
        pos_fra_V_2        = pos_fra_V;
        pos_fra_V_2(4)     = 3*(btn_Height+2*dy2)+dy;

        txt_fra_V_height   = 3*btn_Height/4;
        txt_fra_V_width    = Def_Btn_Width;
        txt_fra_V_low      = pos_fra_V_2(2)+pos_fra_V_2(4)- txt_fra_V_height/2;
        txt_fra_V_left     = pos_fra_V_2(1)+(pos_fra_V_2(3)-txt_fra_V_width)/2;
        pos_txt_fra_V_2    = [txt_fra_V_left, txt_fra_V_low,...
                              txt_fra_V_width, txt_fra_V_height];
 
        y_low              = pos_fra_V_2(2)+pos_fra_V_2(4)-(btn_Height+2*dy2);
        pos_txt_swtXlen_V   = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtXlen_V   = [x_left_2, y_low+dy, edi_width, btn_Height];
 
        y_low              = y_low-(btn_Height+2*dy2);
        pos_txt_swtXclen_V  = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtXclen_V  = [x_left_2, y_low+dy, edi_width, btn_Height];
 
        y_low              = y_low-(btn_Height+2*dy2);
        pos_txt_swtXdir_V   = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtXdir_V   = [x_left_2, y_low+dy, edi_width, btn_Height];

        % String property of objects.
        %----------------------------
        str_txt_image    = 'Image';
        str_edi_image    = '';
        str_txt_length   = 'Length';
        str_edi_length   = '';
        str_txt_nextpow2 = 'Next Power of 2';
        str_edi_nextpow2 = '';
        str_txt_prevpow2 = 'Previous Power of 2';
        str_edi_prevpow2 = '';
        str_txt_deslen   = 'Desired Length';
        str_edi_deslen   = '';
        str_txt_direct   = 'Direction to extend';
        str_pop_direct_H = [ 'Both ' ; 'Left ' ; 'Right'];
        str_pop_direct_V = [ 'Both ' ; 'Up   ' ; 'Down '];
        str_txt_fra_H    = 'Horizontal';
        str_txt_fra_H_2  = 'Horizontal';
        str_txt_fra_V    = 'Vertical';
        str_txt_fra_V_2  = 'Vertical';
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
        str_pus_extend    = 'Extend';
        str_txt_swtXdec    = 'SWT Decomposition Level';
        str_pop_swtXdec    = num2str((1:10)');
        str_txt_swtXlen_H  = 'Length';
        str_edi_swtXlen_H  = '';
        str_txt_swtXclen_H = 'Computed Length';
        str_edi_swtXclen_H = '';
        str_txt_swtXdir_H  = 'Direction to extend';
        str_edi_swtXdir_H  = 'Right';
        str_tip_swtXclen_H = ['Minimal length of the ',     ...
                            'periodic extended signal ',   ...
                            'for SWT decomposition'];
        str_tip_swtXclen_V = str_tip_swtXclen_H;
        str_txt_swtXlen_V  = 'Length';
        str_edi_swtXlen_V  = '';
        str_txt_swtXclen_V = 'Computed Length';
        str_edi_swtXclen_V = '';
        str_txt_swtXdir_V  = 'Direction to extend';
        str_edi_swtXdir_V  = 'Down';
 
        % Construction of uicontrols.
        %----------------------------
        commonProp = {...
            'Parent',win_imgxtoolX, ...
            'Unit',win_units,      ...
            'Visible','off'        ...
            };
        comFraProp = [commonProp, ...
            'BackGroundColor',Def_FraBkColor, ...
            'Style','frame'                   ...
            ];
        comPusProp = [commonProp,'Style','Pushbutton'];
        comPopProp = [commonProp,'Style','Popupmenu'];
        comTxtProp = [commonProp, ...
            'ForeGroundColor','k',            ...
            'BackGroundColor',Def_FraBkColor, ...
            'HorizontalAlignment','left',     ...
            'Style','Text'                    ...
            ];
        comEdiProp = [commonProp, ...
            'ForeGroundColor','k',          ...
            'HorizontalAlignment','center', ...
            'Style','Edit'                  ...
            ];

        txt_image = uicontrol( ...
            comTxtProp{:},                     ...
            'Position',pos_txt_image,          ...
            'String',str_txt_image             ...
            );
        edi_image = uicontrol( ...
            comEdiProp{:},                     ...
            'Position',pos_edi_image,          ...
            'String',str_edi_image,            ...
            'BackGroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );

        frm_fra_H = uicontrol(  ...
            comFraProp{:},                     ...
            'Position',pos_fra_H               ...
            );
        txt_fra_H = uicontrol(  ...
            comTxtProp{:},                     ...
            'HorizontalAlignment','center',    ...
            'Position',pos_txt_fra_H,          ...
            'String',str_txt_fra_H             ...
            );
        txt_length_H   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_length_H,       ...
            'String',str_txt_length            ...
            );
        edi_length_H   = uicontrol( ...
            comEdiProp{:},                     ...
            'Position',pos_edi_length_H,       ...
            'String',str_edi_length,           ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_nextpow2_H = uicontrol( ...
            comTxtProp{:},                     ...
            'Position',pos_txt_nextpow2_H,     ...
            'String',str_txt_nextpow2          ...
            );
        edi_nextpow2_H = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_nextpow2_H,     ...
            'String',str_edi_nextpow2,         ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_prevpow2_H = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_prevpow2_H,     ...
            'String',str_txt_prevpow2          ...
            );
        edi_prevpow2_H = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_prevpow2_H,     ...
            'String',str_edi_prevpow2,         ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_deslen_H   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_deslen_H,       ...
            'String',str_txt_deslen            ...
            );
        edi_deslen_H   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_deslen_H,       ...
            'String',str_edi_deslen,           ...
            'Backgroundcolor',ediActBkColor   ...
            );
        txt_direct_H   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_direct_H,       ...
            'String',str_txt_direct            ...
            );
        pop_direct_H   = uicontrol(  ...
            comPopProp{:},                     ...
            'Position',pos_pop_direct_H,       ...
            'String',str_pop_direct_H          ...
            );

        frm_fra_V      = uicontrol(  ...
            comFraProp{:},                     ...
            'Position',pos_fra_V               ...
            );
        txt_fra_V      = uicontrol(  ...
            comTxtProp{:},                     ...
            'HorizontalAlignment','center',    ...
            'Position',pos_txt_fra_V,          ...
            'String',str_txt_fra_V             ...
            );
        txt_length_V   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_length_V,       ...
            'String',str_txt_length            ...
            );
        edi_length_V   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_length_V,       ...
            'String',str_edi_length,           ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );

        txt_nextpow2_V = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_nextpow2_V,     ...
            'String',str_txt_nextpow2          ...
            );
        edi_nextpow2_V = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_nextpow2_V,     ...
            'String',str_edi_nextpow2,         ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_prevpow2_V = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_prevpow2_V,     ...
            'String',str_txt_prevpow2          ...
            );
        edi_prevpow2_V = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_prevpow2_V,     ...
            'String',str_edi_prevpow2,         ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_deslen_V   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_deslen_V,       ...
            'String',str_txt_deslen            ...
            );
        edi_deslen_V   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_deslen_V,       ...
            'String',str_edi_deslen,           ...
            'Backgroundcolor',ediActBkColor   ...
            );
        txt_direct_V   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_direct_V,       ...
            'String',str_txt_direct            ...
            );
        pop_direct_V   = uicontrol(  ...
            comPopProp{:},                     ...
            'Position',pos_pop_direct_V,       ...
            'String',str_pop_direct_V          ...
            );

        txt_mode       = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_mode,           ...
            'String',str_txt_mode              ...
            );
        pop_mode       = uicontrol(  ...
            comPopProp{:},                     ...
            'Position',pos_pop_mode,           ...
            'String',str_pop_mode              ...
            );
        pus_extend     = uicontrol(  ...
            comPusProp{:},                     ...
            'Position',pos_pus_extend,         ...
            'String',xlate(str_pus_extend),    ...
            'Interruptible','On'               ...
            );

        txt_swtXdec     = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtXdec,         ...
            'String',str_txt_swtXdec            ...
            );
        pop_swtXdec     = uicontrol(  ...
            comPopProp{:},                     ...
            'Position',pos_pop_swtXdec,         ...
            'String',str_pop_swtXdec            ...
            );
        frm_fra_H_2    = uicontrol(  ...
            comFraProp{:},                     ...
            'Position',pos_fra_H_2             ...
            );
        txt_fra_H_2    = uicontrol(  ...
            comTxtProp{:},                     ...
            'HorizontalAlignment','center',    ...
            'Position',pos_txt_fra_H_2,        ...
            'String',str_txt_fra_H_2           ...
            );
        txt_swtXlen_H   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtXlen_H,       ...
            'String',str_txt_swtXlen_H          ...
            );
        edi_swtXlen_H   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtXlen_H,       ...
            'String',str_edi_swtXlen_H,         ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_swtXclen_H  = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtXclen_H,      ...
            'ToolTipString',str_tip_swtXclen_H, ...
            'String',str_txt_swtXclen_H         ...
            );
        edi_swtXclen_H  = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtXclen_H,      ...
            'String',str_edi_swtXclen_H,        ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_swtXdir_H   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtXdir_H,       ...
            'String',str_txt_swtXdir_H          ...
            );
        edi_swtXdir_H   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtXdir_H,       ...
            'String',str_edi_swtXdir_H,         ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        frm_fra_V_2    = uicontrol(  ...
            comFraProp{:},                     ...
            'Position',pos_fra_V_2             ...
            );
        txt_fra_V_2    = uicontrol(  ...
            comTxtProp{:},                     ...
            'HorizontalAlignment','center',    ...
            'Position',pos_txt_fra_V_2,        ...
            'String',str_txt_fra_V_2           ...
            );
        txt_swtXlen_V   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtXlen_V,       ...
            'String',str_txt_swtXlen_V          ...
            );
        edi_swtXlen_V   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtXlen_V,       ...
            'String',str_edi_swtXlen_V,         ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_swtXclen_V  = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtXclen_V,      ...
            'ToolTipString',str_tip_swtXclen_V, ...
            'String',str_txt_swtXclen_V         ...
            );
        edi_swtXclen_V  = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtXclen_V,      ...
            'String',str_edi_swtXclen_V,        ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_swtXdir_V   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtXdir_V,       ...
            'String',str_txt_swtXdir_V          ...
            );
        edi_swtXdir_V   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtXdir_V,       ...
            'String',str_edi_swtXdir_V,         ...
            'Backgroundcolor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
                             
        % Callback property of objects.
        %------------------------------
        str_win_imgxtoolX = num2mstrX(win_imgxtoolX);
        cba_edi_deslen_H = [mfilename '(''update_deslen'','   ...
                                 str_win_imgxtoolX             ...
                                 ',''H'');'];
        cba_edi_deslen_V = [mfilename '(''update_deslen'','   ...
                                 str_win_imgxtoolX             ...
                                 ',''V'');'];
        cba_pop_direct_H = [mfilename '(''clear_GRAPHICS'','  ...
                                 str_win_imgxtoolX             ...
                                 ');'];
        cba_pop_direct_V = [mfilename '(''clear_GRAPHICS'','  ...
                                 str_win_imgxtoolX             ...
                                 ');'];
        cba_pop_mode 	 = [mfilename '(''mode'','            ...
                                 str_win_imgxtoolX             ...
                                 ');'];
        cba_pus_extend 	 = [mfilename '(''extend_truncate'',' ...
                                 str_win_imgxtoolX             ...
                                 ');'];
        cba_pop_swtXdec 	 = [mfilename '(''update_swtXdec'','   ...
                                 str_win_imgxtoolX             ...
                                 ');'];
        set(edi_deslen_H,'Callback',cba_edi_deslen_H);
        set(pop_direct_H,'Callback',cba_pop_direct_H);
        set(edi_deslen_V,'Callback',cba_edi_deslen_V);
        set(pop_direct_V,'Callback',cba_pop_direct_V);
        set(pop_mode,'Callback',cba_pop_mode);
        set(pus_extend,'Callback',cba_pus_extend);
        set(pop_swtXdec,'Callback',cba_pop_swtXdec);
        
        % Graphic part of the window.
        %============================

        % Axes Construction.
        %-------------------
        commonProp  = {...
            'Parent',win_imgxtoolX,           ...
            'Visible','off',                 ...
            'Units','pixels',                ...
            'XTicklabelMode','manual',       ...
            'YTicklabelMode','manual',       ...
            'XTicklabel',[],'YTicklabel',[], ...
            'XTick',[],'YTick',[],           ...
            'Box','On'                       ...
            };

        % Image Axes construction.
        %--------------------------
        x_left      = x_graph;
        x_wide      = w_graph-2*x_left;
        y_low       = y_graph+2*bdy;
        y_height    = h_graph-y_low-2*bdy;
        Pos_Axe_Img = [x_left, y_low, x_wide, y_height];
        Axe_Img     = axes( commonProp{:},         ...
                            'Ydir','Reverse',      ...
                            'Position',Pos_Axe_Img ...
                            );

        % Legend Axes construction.
        %--------------------------
        X_Leg = Pos_Axe_Img(1);
        Y_Leg = Pos_Axe_Img(2) + 43*Pos_Axe_Img(4)/40;
        W_Leg = (Pos_Axe_Img(3) - Pos_Axe_Img(1)) / 2.5;
        H_Leg = (Pos_Axe_Img(4) - Pos_Axe_Img(2)) / 5;
        
        Pos_Axe_Leg = [X_Leg Y_Leg W_Leg H_Leg];
        ud.dynvzaxeX.enable = 'Off';
        Axe_Leg = axes(commonProp{:},          ...
            'Position',Pos_Axe_Leg, ...
            'Xlim',[0 180],         ...
            'Ylim',[0 20],          ...
            'Drawmode','fast',      ...
            'userdata',ud           ...
            );
        line(                           ...
            'Parent',Axe_Leg,          ...
            'Xdata',11:30,             ...
            'Ydata',ones(1,20)*14,     ...
            'LineWidth',3,             ...
            'Visible','off',           ...
            'Color','yellow'           ...
            );
        line(                           ...
            'Parent',Axe_Leg,          ...
            'Xdata',11:30,             ...
            'Ydata',ones(1,20)*7,      ...
            'LineWidth',3,             ...
            'Visible','off',           ...
            'Color','red'              ...
            );
        text(40,14,xlate('Transformed image'), ...
            'Parent',Axe_Leg,          ...
            'FontWeight','normal',     ...
            'Visible','off'            ...
            );
        text(40,7,xlate('Original image'),  ...
            'Parent',Axe_Leg,          ...
            'FontWeight','normal',     ...
            'Visible','off'            ...
            );

        % Adding colormap GUI.
        %---------------------
        [Hdls_Colmap1,Hdls_Colmap2] = utcolmapX('create',win_imgxtoolX, ...
                 'xloc',xlocINI,'bkcolor',Def_FraBkColor);
        Hdls_Colmap = [Hdls_Colmap1 Hdls_Colmap2];
        set(Hdls_Colmap,'visible','off');

        % Setting units to normalized.
        %-----------------------------
        wfigmngrX('normalize',win_imgxtoolX);

        % Store values.
        %--------------
        Hdls_UIC_C  = {...
            m_load,m_save,m_demo,...
            txt_image,edi_image,  ...
            txt_mode,pop_mode,pus_extend ...
            };
        Hdls_UIC_H  = {...
            frm_fra_H,txt_fra_H,           ...
            txt_length_H,edi_length_H,     ...
            txt_nextpow2_H,edi_nextpow2_H, ...
            txt_prevpow2_H,edi_prevpow2_H, ...
            txt_deslen_H,edi_deslen_H,     ...
            txt_direct_H,pop_direct_H      ...
            };
        Hdls_UIC_V  = {...
            frm_fra_V,txt_fra_V,           ...
            txt_length_V,edi_length_V,     ...
            txt_nextpow2_V,edi_nextpow2_V, ...
            txt_prevpow2_V,edi_prevpow2_V, ...
            txt_deslen_V,edi_deslen_V,     ...
            txt_direct_V,pop_direct_V      ...
            };

        Hdls_UIC_Swt = {...
            txt_swtXdec,pop_swtXdec,       ...
            frm_fra_H_2,txt_fra_H_2,     ...
            txt_swtXlen_H,edi_swtXlen_H,   ...
            txt_swtXclen_H,edi_swtXclen_H, ...
            txt_swtXdir_H,edi_swtXdir_H,   ...
            txt_swtXdec,pop_swtXdec,       ...
            frm_fra_V_2,txt_fra_V_2,     ...
            txt_swtXlen_V,edi_swtXlen_V,   ...
            txt_swtXclen_V,edi_swtXclen_V, ...
            txt_swtXdir_V,edi_swtXdir_V    ...
            };
 
        Hdls_Axes    = struct('Axe_Img',Axe_Img,'Axe_Leg',Axe_Leg);

        Pos_Axe_Img_Ori = get(Axe_Img,'Position');

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_BORDER_DIST = [txt_mode,pop_mode];
		wfighelpX('add_ContextMenu',win_imgxtoolX,...
			hdl_BORDER_DIST,'BORDER_DIST');
		%-------------------------------------
        
		% Store handles and values.
        %--------------------------		
        wfigmngrX('storeValue',win_imgxtoolX,'Hdls_UIC_C',Hdls_UIC_C);
        wfigmngrX('storeValue',win_imgxtoolX,'Hdls_UIC_H',Hdls_UIC_H);
        wfigmngrX('storeValue',win_imgxtoolX,'Hdls_UIC_V',Hdls_UIC_V);
        wfigmngrX('storeValue',win_imgxtoolX,'Hdls_UIC_Swt',Hdls_UIC_Swt);
        wfigmngrX('storeValue',win_imgxtoolX,'Hdls_Axes',Hdls_Axes);
        wfigmngrX('storeValue',win_imgxtoolX,'Hdls_Colmap',Hdls_Colmap);
        wfigmngrX('storeValue',win_imgxtoolX,'Pos_Axe_Img_Ori',Pos_Axe_Img_Ori);
        wtbxappdataX('set',win_imgxtoolX,'m_exp_sig',m_exp_sig);

        % Set Figure Visible 'On'
        %------------------------
        set(win_imgxtoolX,'Visible','On');

    case 'load'
    %------------------------------------------%
    % Option: 'LOAD' - Load the original image %
    %------------------------------------------%
        if length(varargin)<2  % LOAD IMAGE
            imgFileType = getimgfiletypeX;
            [imgInfos,Anal_Image,map,ok] = ...
                utguidivX('load_img',win_imgxtoolX,imgFileType, ...
                'Load Image',default_nbcolors); %#ok<ASGLU>
        
        elseif isequal(varargin{2},'wrks')  % LOAD from WORKSPACE
            [imgInfos,Anal_Image,ok] = wtbximportX('2d');
            % map = pink(default_nbcolors);
            
        else
            img_Name = deblank(varargin{2});
            filename = [img_Name '.mat'];
            pathname = utguidivX('WTB_DemoPath',filename);
            if length(varargin)<5 , optIMG = ''; else  optIMG = varargin{5}; end
            [imgInfos,Anal_Image,map,ok] = utguidivX('load_dem2D',...
                win_imgxtoolX,pathname,filename,default_nbcolors,optIMG); %#ok<ASGLU>
        end
        if ~ok, return; end
        flagIDX = length(size(Anal_Image))<3;
        setfigNAME(win_imgxtoolX,flagIDX)
        

        % Begin waiting.
        %---------------
        wwaitingX('msg',win_imgxtoolX,'Wait ... loading');

        % Cleaning.
        %----------
        imgxtoolX('clear_GRAPHICS',win_imgxtoolX,'load');

        % Disable save menu.
        %-------------------
        set([m_save,m_exp_sig],'Enable','off');

        % Compute UIC values.
        %--------------------
        H           = imgInfos.size(1);
        V           = imgInfos.size(2);
        pow_H       = fix(log(H)/log(2));
        Next_Pow2_H = 2^(pow_H+1);
        if isequal(2^pow_H,H)
            Prev_Pow2_H = 2^(pow_H-1);
            swtXpow_H    = pow_H;
        else
            Prev_Pow2_H = 2^pow_H;
            swtXpow_H    = pow_H+1;
        end
        pow_V       = fix(log(V)/log(2));
        Next_Pow2_V = 2^(pow_V+1);
        if isequal(2^pow_V,V)
            Prev_Pow2_V   = 2^(pow_V-1);
            swtXpow_V    = pow_V;
        else
            Prev_Pow2_V   = 2^pow_V;
            swtXpow_V    = pow_V+1;
        end
        
        % Compute the max level value for SWT.
        %-------------------------------------
        Max_Lev = min(swtXpow_H,swtXpow_V);
                
        % Compute the default level for SWT .
        %-----------------------------------
        def_pow = 1;
        if ~rem(H,2)
            while ~rem(H,2^def_pow), def_pow = def_pow + 1; end
            def_level_H = def_pow-1;
        else
            def_level_H = def_pow;
        end
        
        def_pow = 1;
        if ~rem(V,2)
            while ~rem(V,2^def_pow), def_pow = def_pow + 1; end
            def_level_V = def_pow-1;
        else
            def_level_V = def_pow;
        end
        Def_Lev = min(max(def_level_H,def_level_V),Max_Lev);
        
        % Compute the extended lengths for SWT.
        %--------------------------------------
        C_Length_H = H;
        while rem(C_Length_H,2^def_level_H), C_Length_H = C_Length_H + 1; end
        C_Length_V = V;
        while rem(C_Length_V,2^def_level_V), C_Length_V = C_Length_V + 1; end
        
        % Set UIC values.
        %----------------
        set(edi_image,'String',imgInfos.name);
        set(edi_length_H,'String',sprintf('%.0f',H));
        set(edi_nextpow2_H,'String',sprintf('%.0f',Next_Pow2_H));
        set(edi_prevpow2_H,'String',sprintf('%.0f',Prev_Pow2_H));
        set(edi_deslen_H,'String',sprintf('%.0f',Next_Pow2_H));
        set(pop_direct_H,'Value',1);
        set(edi_length_V,'String',sprintf('%.0f',V));
        set(edi_nextpow2_V,'String',sprintf('%.0f',Next_Pow2_V));
        set(edi_prevpow2_V,'String',sprintf('%.0f',Prev_Pow2_V));
        set(edi_deslen_V,'String',sprintf('%.0f',Next_Pow2_V));
        set(pop_direct_V,'Value',1);
        set(pop_mode,'Value',1);
        set(pus_extend,'String',xlate('Extend'));
        set(pus_extend,'Enable','On');
        set(pop_swtXdec,'String',num2str((1:Max_Lev)'));
        set(pop_swtXdec,'Value',Def_Lev);
        set(edi_swtXlen_H,'String',sprintf('%.0f',H));
        set(edi_swtXlen_V,'String',sprintf('%.0f',V));        
        set(edi_swtXclen_H,'String',sprintf('%.0f',C_Length_H));
        set(edi_swtXclen_V,'String',sprintf('%.0f',C_Length_V));        
                
        % Set UIC visible on.
        %--------------------
        set(cat(1,Hdls_UIC_H{:}),'visible','on')
        set(cat(1,Hdls_UIC_V{:}),'visible','on')
        set(cat(1,Hdls_UIC_Swt{:}),'visible','off')
        set(cat(1,Hdls_UIC_C{4:end}),'visible','on')

        % Setting Colormap.
        %------------------
        maxVal   = double(max(Anal_Image(:)));
        nbcolors = round(max([2,min([maxVal,default_nbcolors])]));
        cbcolmapX('set',win_imgxtoolX,'pal',{'pink',nbcolors});
        set(Hdls_Colmap,'Visible','on');
        set(Hdls_Colmap,'Enable','on');

        % Get Axes Handles.
        %------------------
        Axe_Img =  Hdls_Axes.Axe_Img ;

        % Drawing.
        %---------
        NB_ColorsInPal = default_nbcolors;
        Anal_Image     = wimgcodeX('cod',0,Anal_Image,NB_ColorsInPal,codemat_v);
        image(                ...
            'parent',Axe_Img,   ...
            'Xdata',[1,H],      ...
            'Ydata',[1,V],      ...
            'Cdata',wd2uiorui2dX('d2uint',Anal_Image), ...
            'Visible','on'      ...
            );
        [w,h]          = wpropimgX([H V],Pos_Axe_Img_Ori(3),Pos_Axe_Img_Ori(4));
        Pos_Axe_Img    = Pos_Axe_Img_Ori;
        Pos_Axe_Img(1) = Pos_Axe_Img(1)+abs(Pos_Axe_Img(3)-w)/2;
        Pos_Axe_Img(2) = Pos_Axe_Img(2)+abs(Pos_Axe_Img(4)-h)/2;
        Pos_Axe_Img(3) = w;
        Pos_Axe_Img(4) = h;
        set(Axe_Img,                ...
            'Xlim',[1,H],           ...
            'Ylim',[1,V],           ...
            'Position',Pos_Axe_Img, ...
            'Visible','on');
        set(get(Axe_Img,'title'),'string',xlate('Original Image'));

        % Store values.
        %--------------
        wfigmngrX('storeValue',win_imgxtoolX,'Anal_Image',Anal_Image);
        wfigmngrX('storeValue',win_imgxtoolX,'Pos_Axe_Img_Bas',Pos_Axe_Img);

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 0;
        wfigmngrX('storeValue',win_imgxtoolX,'File_Save_Flag',File_Save_Flag);
        
        % Dynvtool Attachment.
        %----------------------
        dynvtoolX('init',win_imgxtoolX,[],Axe_Img,[],[1 1],'','','');

        % End waiting.
        %-------------
        wwaitingX('off',win_imgxtoolX);
        
    case 'demo'
        imgxtoolX('load',varargin{:});
        ext_OR_trunc = varargin{3};
        if ~isempty(varargin{4})
            par_Demo = varargin{4};
        else
            return;
        end
        extMode  = par_Demo{1};
        lenSIG   = par_Demo{2};
        direct_H = lower(par_Demo{3});
        direct_V = lower(par_Demo{4});
        if ~isequal(extMode,'swtX')
            set(edi_deslen_H,'String',sprintf('%.0f',lenSIG(1)));
            imgxtoolX('update_deslen',win_imgxtoolX,'H','noClear');
            set(edi_deslen_V,'String',sprintf('%.0f',lenSIG(2)));
            imgxtoolX('update_deslen',win_imgxtoolX,'V','noClear');
        else
            set(pop_swtXdec,'Value',lenSIG)
            imgxtoolX('update_swtXdec',win_imgxtoolX)
        end
        switch direct_H
          case 'both'  , direct = 1;
          case 'left'  , direct = 2;
          case 'right' , direct = 3;
        end
        set(pop_direct_H,'Value',direct);
        switch direct_V
          case 'both' , direct = 1;
          case 'up'   , direct = 2;
          case 'down' , direct = 3;
        end
        set(pop_direct_V,'Value',direct);
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
            imgxtoolX('mode',win_imgxtoolX,'noClear')

          case 'trunc'
        end
        imgxtoolX('extend_truncate',win_imgxtoolX);

    case 'update_swtXdec'
    %----------------------------------------------------------------------%
    % Option: 'UPDATE_SWTDEC' - Update values when using popup in SWT case %
    %----------------------------------------------------------------------%        
        % Update the computed length.
        %----------------------------
        Image_Length_H = wstr2numX(get(edi_swtXlen_H,'String'));
        Image_Length_V = wstr2numX(get(edi_swtXlen_V,'String'));
        Level          = get(pop_swtXdec,'Value');
        remLen_H       = rem(Image_Length_H,2^Level);
        remLen_V       = rem(Image_Length_V,2^Level);
        if remLen_H>0
            C_Length_H = Image_Length_H + 2^Level-remLen_H;
        else
            C_Length_H = Image_Length_H;
        end
        if remLen_V>0
            C_Length_V = Image_Length_V + 2^Level-remLen_V;
        else
            C_Length_V = Image_Length_V;
        end
        set(edi_swtXclen_H,'String',sprintf('%.0f',C_Length_H));
        set(edi_swtXclen_V,'String',sprintf('%.0f',C_Length_V));
        
        % Enabling Extend button.
        %------------------------        
        set(pus_extend,'String',xlate('Extend'),'Enable','on');

    case 'update_deslen'
    %--------------------------------------------------------------------------%
    % Option: 'UPDATE_DESLEN' - Update values when changing the Desired Length %
    %--------------------------------------------------------------------------%
		
        % Get arguments.
        %---------------
        Direction = varargin{2};

        % Cleaning.
        %----------
        if nargin<4 , imgxtoolX('clear_GRAPHICS',win_imgxtoolX); end

        % Get Common UIC Handles.
        %------------------------	
        Image_length_H   = wstr2numX(get(edi_length_H,'String'));
        Desired_length_H = wstr2numX(get(edi_deslen_H,'String'));
        Image_length_V   = wstr2numX(get(edi_length_V,'String'));
        Desired_length_V = wstr2numX(get(edi_deslen_V,'String'));
        uic_mode         = [txt_mode;pop_mode];
        switch Direction
          case 'H'
            % Update UIC values.
            %-------------------
            if      isempty(Desired_length_H) || Desired_length_H < 2
                    set(edi_deslen_H,'String',get(edi_nextpow2_H,'String'));
                    set(txt_direct_H,'String','Direction to extend');
                    set(pus_extend,'String',xlate('Extend'),'Enable','on');
            elseif  Image_length_H <= Desired_length_H
                    set(txt_direct_H,'String','Direction to extend');
                    set(pus_extend,'String',xlate('Extend'));
            elseif  Image_length_H > Desired_length_H
                    set(txt_direct_H,'String','Direction to truncate');
                    set(pus_extend,'String',xlate('Truncate'));
            end

          case 'V'
            % Update UIC values.
            %-------------------
            if      isempty(Desired_length_V) || Desired_length_V < 2
                    set(edi_deslen_V,'String',get(edi_nextpow2_V,'String'));
                    set(txt_direct_V,'String','Direction to extend');
                    set(pus_extend,'String',xlate('Extend'));
            elseif  Image_length_V <= Desired_length_V
                    set(txt_direct_V,'String','Direction to extend');
                    set(pus_extend,'String',xlate('Extend'));
            elseif  Image_length_V > Desired_length_V
                    set(txt_direct_V,'String','Direction to truncate');
                    set(pus_extend,'String',xlate('Truncate'));
            end

          otherwise
              errargtX(mfilename,'Unknown Action','msg');
              error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
                  'Invalid Input Argument.');
        end
        set(uic_mode,'Enable','on');
        set(pus_extend,'Enable','on');                                
        if     	isequal(Image_length_H,Desired_length_H) && ...
                isequal(Image_length_V,Desired_length_V)
                set(txt_direct_V,'String','Direction to extend');
                set(txt_direct_H,'String','Direction to extend');
                set(uic_mode,'Enable','off');
                set(pus_extend,'Enable','off');                        
        elseif  ((Image_length_H <= Desired_length_H)  && ...
                 (Image_length_V <  Desired_length_V)) || ...
                ((Image_length_H <  Desired_length_H)  && ...
                 (Image_length_V <= Desired_length_V))                
                set(uic_mode,'Visible','on');
                set(pus_extend,'String',xlate('Extend'));
        elseif  (Image_length_H <= Desired_length_H) && ...
                (Image_length_V > Desired_length_V)
                set(uic_mode,'Visible','on');
                set(pus_extend,'String',xlate('Extend / Truncate'));
        elseif  (Image_length_H > Desired_length_H) && ...
                (Image_length_V <= Desired_length_V)
                set(uic_mode,'Visible','on');
                set(pus_extend,'String',xlate('Truncate / Extend'));
        elseif  (Image_length_H > Desired_length_H) && ...
                (Image_length_V > Desired_length_V)
                set(uic_mode,'Visible','off');
                set(pus_extend,'String',xlate('Truncate'));
        end
        set(pus_extend,'Visible','on');
	
    case 'mode'
    %------------------------------------------------------------------------%
    % Option: 'MODE' -  Update the command part when changing Extension Mode %
    %------------------------------------------------------------------------%

        % Cleaning.
        %----------
        if nargin<3 , imgxtoolX('clear_GRAPHICS',win_imgxtoolX); end

        % Checking the SWT case for visibility settings.
        %-----------------------------------------------
        Mode_str = get(pop_mode,'String');
        Mode_val = get(pop_mode,'Value');
        if  strcmp(deblank(Mode_str(Mode_val,:)),'For SWT')
            set(cat(1,Hdls_UIC_H{:}),'visible','off')
            set(cat(1,Hdls_UIC_V{:}),'visible','off')
            set(cat(1,Hdls_UIC_Swt{:}),'visible','on')

            Image_Length_H    = wstr2numX(get(edi_swtXlen_H,'String'));
            Computed_Length_H = wstr2numX(get(edi_swtXclen_H,'String'));
            Image_Length_V    = wstr2numX(get(edi_swtXlen_V,'String'));
            Computed_Length_V = wstr2numX(get(edi_swtXclen_V,'String'));
            set(pus_extend,'String',xlate('Extend'));
            if isequal(Image_Length_H,nextpow2(Image_Length_H)) && ...
                isequal(Image_Length_V,nextpow2(Image_Length_V))
                set(pus_extend,'Enable','off');
                strSize = ['(' int2str(Image_Length_V), 'x', ...
                               int2str(Image_Length_H) ')'];
                msg = {...
                  sprintf('The size of the image %s is a power of 2.', strSize),  ...
                  'The SWT extension is not necessary!'};
                wwarndlgX(msg,'SWT Extension Mode','block');

            elseif Image_Length_H < Computed_Length_H || ...
                Image_Length_V < Computed_Length_V
                set(pus_extend,'Enable','on');
            end
        else
            set(pus_extend,'Enable','on');
            set(cat(1,Hdls_UIC_H{:}),'visible','on')
            set(cat(1,Hdls_UIC_V{:}),'visible','on')
            set(cat(1,Hdls_UIC_Swt{:}),'visible','off')
        end
        set(cat(1,Hdls_UIC_C{4:end}),'visible','on');
            
    case 'extend_truncate'
    %-------------------------------------------------------------------------%
    % Option: 'EXTEND_TRUNCATE' - Compute the new Extended or Truncated image %
    %-------------------------------------------------------------------------%
        
        % Begin waiting.
        %---------------
        wwaitingX('msg',win_imgxtoolX,'Wait ... computing');

        % Get stored structure.
        %----------------------        
        Anal_Image = wfigmngrX('getValue',win_imgxtoolX,'Anal_Image');

        % Get UIC values.
        %----------------
        Image_length_H   = wstr2numX(get(edi_length_H,'String'));
        Str_pop_direct_H = get(pop_direct_H,'String');
        Val_pop_direct_H = get(pop_direct_H,'Value');
        Str_pop_direct_H = deblank(Str_pop_direct_H(Val_pop_direct_H,:));
        Image_length_V   = wstr2numX(get(edi_length_V,'String'));
        Str_pop_direct_V = get(pop_direct_V,'String');
        Val_pop_direct_V = get(pop_direct_V,'Value');
        Str_pop_direct_V = deblank(Str_pop_direct_V(Val_pop_direct_V,:));
        Str_pop_mode     = get(pop_mode,'String');
        last_Mode        = length(Str_pop_mode);
        Val_pop_mode     = get(pop_mode,'Value');

        % Directions mode conversion and desired lengths.
        %------------------------------------------------
        if isequal(Val_pop_mode,last_Mode)
            Dir_H = 'r';
            Dir_V = 'b';
            Desired_length_H = wstr2numX(get(edi_swtXclen_H,'String'));
            Desired_length_V = wstr2numX(get(edi_swtXclen_V,'String'));
        else
            Dir_H_Values     = ['b';'l';'r'];
            Dir_V_Values     = ['b';'u';'d'];
            Dir_H            = Dir_H_Values(Val_pop_direct_H);
            Dir_V            = Dir_V_Values(Val_pop_direct_V);
            Desired_length_H = wstr2numX(get(edi_deslen_H,'String'));
            Desired_length_V = wstr2numX(get(edi_deslen_V,'String'));
        end
        Desired_Size = [Desired_length_V Desired_length_H];

        % Extension mode conversion.
        %---------------------------
        Mode_Values = {'sym';'symw';'asym';'asymw';'ppd';'zpd';'sp0';'spd';'ppd'};
        Mode        = Mode_Values{Val_pop_mode};

        % Get action to do.
        %------------------
        action = deblank(get(pus_extend,'string'));
        switch action
          case xlate('Truncate')
              Deb_O_H = 1;
              Deb_O_V = 1;
              delta_H = Image_length_H - Desired_length_H;
              delta_V = Image_length_V - Desired_length_V;
              switch Str_pop_direct_H
                case 'Left'  , Deb_N_H = 1 + delta_H;
                case 'Right' , Deb_N_H = 1;
                case 'Both'  , Deb_N_H = 1 + fix(delta_H/2);
              end
              switch Str_pop_direct_V
                case 'Up'   , Deb_N_V = 1 + delta_V;
                case 'Down' , Deb_N_V = 1;
                case 'Both' , Deb_N_V = 1 + fix(delta_V/2);
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              First_Point  = [Deb_N_V Deb_N_H ];
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              New_Image    = wkeep2X(Anal_Image,Desired_Size,First_Point);
              imgxtoolX('draw',win_imgxtoolX,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

          case xlate('Extend / Truncate')
              Deb_O_V = 1;
              Deb_N_H = 1;
              delta_H = Desired_length_H - Image_length_H;
              delta_V = Image_length_V - Desired_length_V;
              switch Str_pop_direct_H
                case 'Left'  , Deb_O_H = 1 + delta_H;
                case 'Right' , Deb_O_H = 1;
                case 'Both'  , Deb_O_H = 1 + fix(delta_H/2);
              end
              switch Str_pop_direct_V
                case 'Up'   , Deb_N_V = 1 + delta_V;
                case 'Down' , Deb_N_V = 1;
                case 'Both' , Deb_N_V = 1 + fix(delta_V/2);
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              First_Point  = [Deb_N_V Deb_N_H ];
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              New_Image    = wkeep2X(Anal_Image,Desired_Size,First_Point);
              switch Dir_H
                case {'l','r'}
                  New_Image = wextendX('ac',Mode,New_Image,delta_H,Dir_H);

                case 'b'
                  Ext_Size  = ceil(delta_H/2);
                  New_Image = wextendX('ac',Mode,New_Image,Ext_Size,Dir_H);
                  if rem(delta_H,2)
                      New_Image = wkeep2X(New_Image,Desired_Size,'c','dr');
                  end
              end

              imgxtoolX('draw',win_imgxtoolX,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

          case xlate('Truncate / Extend')
              Deb_O_H = 1;
              Deb_N_V = 1;
              delta_H = Image_length_H - Desired_length_H;
              delta_V = Desired_length_V - Image_length_V ;
              switch Str_pop_direct_H
                case 'Left'  , Deb_N_H = 1 + delta_H;
                case 'Right' , Deb_N_H = 1;
                case 'Both'  , Deb_N_H = 1 + fix(delta_H/2);
              end
              switch Str_pop_direct_V
                case 'Up'   , Deb_O_V = 1 + delta_V;
                case 'Down' , Deb_O_V = 1;
                case 'Both' , Deb_O_V = 1 + fix(delta_V/2);
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              First_Point  = [Deb_N_V Deb_N_H ];
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              New_Image    = wkeep2X(Anal_Image,Desired_Size,First_Point);
              switch Dir_V
                case {'u','d'}
                  New_Image = wextendX('ar',Mode,New_Image,delta_V,Dir_V);

                case 'b'
                  Ext_Size  = ceil(delta_V/2);
                  New_Image = wextendX('ar',Mode,Anal_Image,Ext_Size,Dir_V);
                  if rem(delta_V,2)
                      New_Image = wkeep2X(New_Image,Desired_Size,'c','dr');
                  end
              end

              imgxtoolX('draw',win_imgxtoolX,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

          case xlate('Extend')
              Deb_N_H = 1;
              Deb_N_V = 1;
              delta_H = Desired_length_H - Image_length_H;
              delta_V = Desired_length_V - Image_length_V ;
              switch Str_pop_direct_H
                case 'Left'  , Deb_O_H = 1 + delta_H;
                case 'Right' , Deb_O_H = 1;
                case 'Both'  , Deb_O_H = 1 + fix(delta_H/2);
              end
              switch Str_pop_direct_V
                case 'Up'   , Deb_O_V = 1 + delta_V;
                case 'Down' , Deb_O_V = 1;
                case 'Both' , Deb_O_V = 1 + fix(delta_V/2);
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              switch Dir_H
                case {'l','r'}
                  New_Image = wextendX('ac',Mode,Anal_Image,delta_H,Dir_H);

                case 'b'
                  Ext_Size  = ceil(delta_H/2);
                  New_Image = wextendX('ac',Mode,Anal_Image,Ext_Size,Dir_H);
              end

              switch Dir_V
                case {'u','d'}
                  New_Image  = wextendX('ar',Mode,New_Image,delta_V,Dir_V);

                case 'b'
                  Ext_Size  = ceil(delta_V/2);
                  New_Image = wextendX('ar',Mode,New_Image,Ext_Size,Dir_V);
              end
              if rem(delta_H,2) || rem(delta_V,2)
                  New_Image = wkeep2X(New_Image,Desired_Size,'c','dr');
              end

              imgxtoolX('draw',win_imgxtoolX,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

        end
		
        % Saving the new image.
        %-----------------------		
        wfigmngrX('storeValue',win_imgxtoolX,'New_Image',New_Image);

        % End waiting.
        %-------------
        wwaitingX('off',win_imgxtoolX);
        
    case 'draw'
    %-----------------------------------------------------%
    % Option: 'DRAW' - Plot both new and original signals %
    %-----------------------------------------------------%
						
        % Get arguments.
        %---------------
        Anal_Image = varargin{2};
        New_Image  = varargin{3};
        Image_Lims = varargin{4};
        Deb_O_H    = Image_Lims(1,1);
        Fin_O_H    = Image_Lims(1,2);
        Deb_O_V    = Image_Lims(1,3);
        Fin_O_V    = Image_Lims(1,4);
        Deb_N_H    = Image_Lims(2,1);
        Fin_N_H    = Image_Lims(2,2);
        Deb_N_V    = Image_Lims(2,3);
        Fin_N_V    = Image_Lims(2,4);
        
        % Begin waiting.
        %---------------
        wwaitingX('msg',win_imgxtoolX,'Wait ... drawing');
        
        % Get Axes Handles.
        %------------------
        Axe_Img = Hdls_Axes.Axe_Img;
        Axe_Leg = Hdls_Axes.Axe_Leg;
		
        % Clean images axes.
        %--------------------
        delete(findobj(Axe_Img,'Type','image'));
        delete(findobj(Axe_Img,'Type','line'));

        % Compute axes limits.
        %---------------------
        Xmin = min(Deb_O_H,Deb_N_H)-1;
        Xmax = max(Fin_O_H,Fin_N_H)+1;
        Ymin = min(Deb_O_V,Deb_N_V)-1;
        Ymax = max(Fin_O_V,Fin_N_V)+1;

        % Compute image ratio.
        %---------------------
        Len_X = Xmax - Xmin;
        Len_Y = Ymax - Ymin;
        
        % Compute new Axes position to respect a good ratio.
        %---------------------------------------------------
        [w,h]          = wpropimgX([Len_X Len_Y],Pos_Axe_Img_Ori(3), ...
                                   Pos_Axe_Img_Ori(4));
        Pos_Axe_Img    = Pos_Axe_Img_Ori;
        Pos_Axe_Img(1) = Pos_Axe_Img(1)+abs(Pos_Axe_Img(3)-w)/2;
        Pos_Axe_Img(2) = Pos_Axe_Img(2)+abs(Pos_Axe_Img(4)-h)/2;
        Pos_Axe_Img(3) = w;
        Pos_Axe_Img(4) = h;
            
        % Update axes properties.
        %------------------------
        set(Axe_Img,                         ...
            'XTicklabelMode','manual',       ...
            'YTicklabelMode','manual',       ...
            'XTicklabel',[],'YTicklabel',[], ...
            'XTick',[],'YTick',[],           ...
            'Ydir','reverse',                ...
            'Box','Off',                     ...
            'NextPlot','add',                ...
            'Position',Pos_Axe_Img,          ...
            'Xlim',[Xmin,Xmax],              ...
            'Ylim',[Ymin,Ymax],              ...
            'Xcolor','k',                    ...
            'Ycolor','k',                    ...
            'Visible','on'                   ...
            );
        set(get(Axe_Img,'title'),'string','');
            
        % Draw old image.
        %----------------
        image(wd2uiorui2dX('d2uint',Anal_Image), ... 
            'parent',Axe_Img,          ...
            'Xdata',[Deb_O_H Fin_O_H], ...
            'Ydata',[Deb_O_V Fin_O_V]  ...
            );

        % Draw new image.
        %----------------
        image(wd2uiorui2dX('d2uint',New_Image), ...
            'parent',Axe_Img,          ...
            'Xdata',[Deb_N_H Fin_N_H], ...
            'Ydata',[Deb_N_V Fin_N_V]  ...
            );

        % Constant coefs. for box design.
        %--------------------------------
        S1 = 4;
        S2 = 4;

        % Draw Box around old image.
        %---------------------------
        X = [Deb_O_H Fin_O_H Fin_O_H Deb_O_H Deb_O_H];
        Y = [Deb_O_V Deb_O_V Fin_O_V Fin_O_V Deb_O_V];
        line(X,Y,'parent',Axe_Img,'color','red','LineWidth',S1);

        % Draw Box around new image.
        %----------------------------
        X = [Deb_N_H Fin_N_H Fin_N_H Deb_N_H Deb_N_H];
        Y = [Deb_N_V Deb_N_V Fin_N_V Fin_N_V Deb_N_V];
        line(X,Y,'parent',Axe_Img,'color','yellow','LineWidth',S2);

        % Display Legend.
        %----------------
        set(Axe_Leg,'Visible','on');
        set(get(Axe_Leg,'Children'),'Visible','on');
				
        % Dynvtool Attachment.
        %----------------------
        dynvtoolX('init',win_imgxtoolX,[],Axe_Img,[],[1 1],'','','');

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 0;
        wfigmngrX('storeValue',win_imgxtoolX,'File_Save_Flag',File_Save_Flag);
        				
        % Enable save menu.
        %------------------
        set([m_save,m_exp_sig],'Enable','on');

        % End waiting.
        %-------------
        wwaitingX('off',win_imgxtoolX);
                		
    case 'save'
    %-----------------------------------------%
    % Option: 'SAVE' - Save transformed image %
    %-----------------------------------------%				

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_imgxtoolX, ...
                                    '*.mat','Save Transformed Image');
        if ~ok, return; end

        % Begin waiting.
        %---------------
        wwaitingX('msg',win_imgxtoolX,'Wait ... saving');
				
        % Restore the new image.
        %-----------------------		
        X = wfigmngrX('getValue',win_imgxtoolX,'New_Image');

        % Setting Colormap.
        %------------------
        map = cbcolmapX('get',win_imgxtoolX,'self_pal');
        if isempty(map)
            maxVal   = double(max(X(:)));
            nbcolors = round(max([2,min([maxVal,default_nbcolors])]));
            map = pink(nbcolors); %#ok<NASGU>
        end
	
        % Saving transformed Image.
        %--------------------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        try
          save([pathname filename],'X','map');
        catch %#ok<CTCH>
          errargtX(mfilename,'Save FAILED !','msg');
        end

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 1;
        wfigmngrX('storeValue',win_imgxtoolX,'File_Save_Flag',File_Save_Flag);
        				
        % Enable save menu.
        %------------------
        set([m_save,m_exp_sig],'Enable','off');
        
        % End waiting.
        %-------------
        wwaitingX('off',win_imgxtoolX);

    case 'exp_wrks'
        wwaitingX('msg',win_imgxtoolX,'Wait ... exporting data');
        X = wfigmngrX('getValue',win_imgxtoolX,'New_Image');
        wtbxexportX(X,'name','sig_2D','title','Extended Image');
        wwaitingX('off',win_imgxtoolX);                
        
    case 'clear_GRAPHICS'
    %---------------------------------------------------------------------%
    % Option: 'CLEAR_GRAPHICS' - Clear graphics and redraw original image %
    %---------------------------------------------------------------------%
					
        % Get arguments.
        %---------------
        if length(varargin) > 1, Draw_flag = 0; else Draw_flag = 1; end

        % Get Axes Handles.
        %------------------
        Axe_Img = Hdls_Axes.Axe_Img;
        Axe_Leg = Hdls_Axes.Axe_Leg;

        % Set graphics part visible off and redraw original image if needed.
        %-------------------------------------------------------------------
        set(Axe_Leg,'Visible','off');
        set(get(Axe_Leg,'Children'),'Visible','off');
        
        if Draw_flag
            Anal_Image      = wfigmngrX('getValue',win_imgxtoolX,'Anal_Image');
            Pos_Axe_Img_Bas = wfigmngrX('getValue',win_imgxtoolX, ...
                                       'Pos_Axe_Img_Bas');
            set(findobj(Axe_Img,'Type','line'),'Visible','Off');
            [H,V] = size(Anal_Image);
            set(get(Axe_Img,'title'),'string',xlate('Original Image'));
            set(Axe_Img,                         ...
                'Xlim',[1,H],                    ...
                'Ylim',[1,V],                    ...
                'Position',Pos_Axe_Img_Bas,      ...
                'Visible','on');
            set(findobj(Axe_Img,'Type','image'), ...
                'parent',Axe_Img,                ...
                'Xdata',[1,H],                   ...
                'Ydata',[1,V],                   ...
                'Cdata',wd2uiorui2dX('d2uint',Anal_Image), ... 
                'Visible','on'                   ...
                );
            dynvtoolX('init',win_imgxtoolX,[],Axe_Img,[],[1 1],'','','');
        else
            set(Axe_Img,'Visible','off');
            set(get(Axe_Img,'Children'),'Visible','off');
        end
				
        % Disable save menu.
        %-------------------
        set([m_save,m_exp_sig],'Enable','off');
		
        % Reset the new image.
        %---------------------		
        wfigmngrX('storeValue',win_imgxtoolX,'New_Image',[]);
        
    case 'close'
    %---------------------------------------%
    % Option: 'CLOSE' - Close current figure%
    %---------------------------------------%

        % Retrieve File_Save_Flag.
        %-------------------------
        File_Save_Flag = wfigmngrX('getValue',win_imgxtoolX,'File_Save_Flag');
        		
        % Retrieve images values.
        %------------------------		
        New_Image  = wfigmngrX('getValue',win_imgxtoolX,'New_Image');
        Anal_Image = wfigmngrX('getValue',win_imgxtoolX,'Anal_Image');
        
        % Test for saving the new image.
        %-------------------------------
        status = 0;
        if ~isempty(New_Image) && any(size(New_Image)~=size(Anal_Image)) &&...
            ~File_Save_Flag
            status = wwaitansX(win_imgxtoolX,...
                     ' Do you want to save the transformed image ?',2,'cond');
        end
        switch status
          case 1 , imgxtoolX('save',win_imgxtoolX)
          case 0 ,
        end
        varargout{1} = status;
        				
    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid Input Argument.');
end

%--------------------------------------------------------------------------
function setfigNAME(fig,flagIDX)

if flagIDX
    figNAME = 'Image Extension / Truncation : Indexed Image';
else
    figNAME = 'Image Extension / Truncation : Truecolor Image';
end
set(fig,'Name',figNAME);
%---------------------------------------------------------------------------

