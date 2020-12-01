function out1 = dw2dmngrX(option,win_dw2dtoolX,varargin)
%DW2DMNGR Discrete wavelet 2-D general manager.
%   OUT1 = DW2DMNGR(OPTION,WIN_DW2DTOOL,VARARGIN)
%
%   option = 'load_img'
%   option = 'load_dec'
%   option = 'load_cfs'
%   option = 'demo'
%   option = 'save_synt'
%   option = 'save_cfs'
%   option = 'save_dec'
%   option = 'analyze'
%   option = 'synthesize'
%   option = 'step2'
%   option = 'view_dec'
%   option = 'select'
%   option = 'view_mode'
%   option = 'fullsize'
%   option = 'return_comp'
%   option = 'return_deno'
%   option = 'set_graphic'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 07-Oct-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Get Globals.
%-------------
[Def_AxeFontSize,Terminal_Prop] = ...
    mextglobX('get','Def_AxeFontSize','Terminal_Prop');

% Default values.
%----------------
max_lev_anal = 8;
def_nbCodeOfColors = 255;

% Image Coding Value.
%-------------------
if ~ishandle(win_dw2dtoolX) , win_dw2dtoolX = gcbf; end
codemat_v = wimgcodeX('get',win_dw2dtoolX);

% Tag property of objects.
%-------------------------
% tag_m_savesyn  = 'Save_Syn';
% tag_m_savecfs  = 'Save_Cfs';
% tag_m_savedec  = 'Save_Dec';
% tag_cmd_frame  = 'Cmd_Frame';
tag_pus_anal   = 'Pus_Anal';
% tag_pus_deno   = 'Pus_Deno';
% tag_pus_comp   = 'Pus_Comp';
% tag_pus_hist   = 'Pus_Hist';
% tag_pus_stat   = 'Pus_Stat';
tag_pop_declev = 'Pop_DecLev';
tag_pus_visu   = 'Pus_Visu';
tag_pus_big    = 'Pus_Big';
tag_pus_rec    = 'Pus_Rec';
tag_pop_viewm  = 'Pop_ViewM';
tag_txt_full   = 'Txt_Full';
tag_pus_full   = ['Pus_Full.1';'Pus_Full.2';'Pus_Full.3';'Pus_Full.4'];
% tag_btnaxeset  = 'Btn_Axe_Set';
tag_axefigutil = 'Axe_FigUtil';
tag_linetree   = 'Tree_lines';
tag_txttree    = 'Tree_txt';
tag_axeimgbig  = 'Axe_ImgBig';
tag_axeimgini  = 'Axe_ImgIni';
tag_axeimgvis  = 'Axe_ImgVis';
tag_axeimgsel  = 'Axe_ImgSel';
tag_axeimgdec  = 'Axe_ImgDec';
tag_axeimgsyn  = 'Axe_ImgSyn';
tag_axeimghdls = 'Img_Handles';
tag_imgdec     = 'Img_Dec';

% Memory Blocks of stored values.
%================================
% MB0.
%-----
n_InfoInit   = 'DW2D_InfoInit';
ind_filename = 1;
ind_pathname = 2;
% nb0_stored   = 2;

% MB1.
%-----
n_param_anal   = 'DWAn2d_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
ind_img_t_name = 4;
ind_img_size   = 5;
ind_nbcolors   = 6;
ind_act_option = 7;
ind_simg_type  = 8;
ind_thr_val    = 9;
% nb1_stored     = 9;

% MB2.1 and 2.2.
%---------------
n_coefs = 'MemCoefs';
n_sizes = 'MemSizes';

% MB3.
%-----
n_miscella      = 'DWAn2d_Miscella';
ind_graph_area  =  1;
ind_pos_axebig  =  2;
ind_pos_axeini  =  3;
ind_pos_axevis  =  4;
ind_pos_axedec  =  5;
ind_pos_axesyn  =  6;
ind_pos_axesel  =  7;
ind_view_status =  8;
ind_save_status =  9;
ind_sel_funct   = 10;
% nb3_stored      = 10;

% Miscellaneous values.
%----------------------
square_viewm  = 1;
tree_viewm    = 2;

dw2d_PREFS = wtbutilsX('dw2d_PREFS');
Col_BoxAxeSel   = dw2d_PREFS.Col_BoxAxeSel;
Col_BoxTitleSel = dw2d_PREFS.Col_BoxTitleSel;
Wid_LineSel     = dw2d_PREFS.Wid_LineSel;

% View Status
%--------------------------------------------------------%
% 'none' : init
% 's_l*' : square        * = lev_dec (1 --> Level_Anal)
% 'f1l*' : full ini      * = lev_dec (1 --> Level_Anal)
% 'f2l*' : full syn      * = lev_dec (1 --> Level_Anal)
% 'f3l*' : full vis      * = lev_dec (1 --> Level_Anal)
% 'f4l*' : full dec      * = lev_dec (1 --> Level_Anal)
% 'b*l*' : big
%            first   * = index   (1 --> 4*Level_Anal)
%            second  * = lev_dec (1 --> Level_Anal)
% 't_l*' : tree          * = lev_dec (1 --> Level_Anal)
%--------------------------------------------------------%

% Handles of tagged objects.
%---------------------------
str_numwin  = sprintf('%.0f',win_dw2dtoolX);
children    = get(win_dw2dtoolX,'Children');
uic_handles = findobj(children,'flat','type','uicontrol');
axe_handles = findobj(children,'flat','type','axes');
txt_handles = findobj(uic_handles,'Style','text');
pop_handles = findobj(uic_handles,'Style','popupmenu');
pus_handles = findobj(uic_handles,'Style','pushbutton');

% m_files   = wfigmngrX('getmenus',win_dw2dtoolX,'file');
% m_savesyn = findobj(m_files,'Tag',tag_m_savesyn);
% m_savecfs = findobj(m_files,'Tag',tag_m_savecfs);
% m_savedec = findobj(m_files,'Tag',tag_m_savedec);

pus_anal   = findobj(pus_handles,'Tag',tag_pus_anal);
% pus_deno   = findobj(pus_handles,'Tag',tag_pus_deno);
% pus_comp   = findobj(pus_handles,'Tag',tag_pus_comp);
% pus_hist   = findobj(pus_handles,'Tag',tag_pus_hist);
% pus_stat   = findobj(pus_handles,'Tag',tag_pus_stat);
pop_declev = findobj(pop_handles,'Tag',tag_pop_declev);
pus_visu   = findobj(pus_handles,'Tag',tag_pus_visu);
pus_big    = findobj(pus_handles,'Tag',tag_pus_big);
pus_rec    = findobj(pus_handles,'Tag',tag_pus_rec);
pop_viewm  = findobj(pop_handles,'Tag',tag_pop_viewm);
txt_full   = findobj(txt_handles,'Tag',tag_txt_full);
pus_full   = zeros(1,4);
for k =1:4
    pus_full(k) = (findobj(pus_handles,'Tag',tag_pus_full(k,:)))';
end

Axe_ImgBig = findobj(axe_handles,'flat','Tag',tag_axeimgbig);
Axe_ImgIni = findobj(axe_handles,'flat','Tag',tag_axeimgini);
Axe_ImgVis = findobj(axe_handles,'flat','Tag',tag_axeimgvis);
Axe_ImgSel = findobj(axe_handles,'flat','Tag',tag_axeimgsel);
Axe_ImgSyn = findobj(axe_handles,'flat','Tag',tag_axeimgsyn);

switch option
    case {'load_img','import_img'}
        switch option
            case 'load_img'
                imgFileType = getimgfiletypeX;
                [imgInfos,img_anal,map,ok] = ...
                    utguidivX('load_img',win_dw2dtoolX, ...
                    imgFileType,'Load Image',def_nbCodeOfColors);
                waitMSG = 'Wait ... loading data';
                
            case 'import_img'
                [imgInfos,img_anal,ok] = wtbximportX('2d');
                map = pink(def_nbCodeOfColors);
                waitMSG = 'Wait ... importing data';
                option = 'load_img';
        end
        if ~ok, return; end
        flagIDX = length(size(img_anal))<3;
        setfigNAME(win_dw2dtoolX,flagIDX)
        
        % Cleaning.
        %----------
        wwaitingX('msg',win_dw2dtoolX,waitMSG);
        dw2dutilX('clean',win_dw2dtoolX,option);

        % Setting Analysis parameters.
        %-----------------------------
        NB_ColorsInPal = size(map,1);
        wmemtoolX('wmb',win_dw2dtoolX,n_param_anal,   ...
            ind_act_option,option,       ...
            ind_img_name,imgInfos.name,  ...
            ind_img_t_name,imgInfos.true_name, ...
            ind_img_size,imgInfos.size,  ...
            ind_nbcolors,NB_ColorsInPal, ...
            ind_simg_type,'ss'           ...
            );
        wmemtoolX('wmb',win_dw2dtoolX,n_InfoInit, ...
            ind_filename,imgInfos.filename, ...
            ind_pathname,imgInfos.pathname  ...
            );

        % Setting GUI values.
        %--------------------
        levm   = wmaxlevX(imgInfos.size([1 2]),'haar');
        levmax = min(levm,max_lev_anal);
        if isequal(imgInfos.true_name,'X')
            img_Name = imgInfos.name;
        else
	        img_Name = imgInfos.true_name;
        end
        img_Size = imgInfos.size;
        cbanaparX('set',win_dw2dtoolX, ...
            'n_s',{img_Name,img_Size}, ...
            'lev',{'String',int2str((1:levmax)'),'Value',min(levmax,2)} ...
            );
        if imgInfos.self_map , arg = map; else arg = []; end       
        cbcolmapX('set',win_dw2dtoolX,'pal',{'pink',NB_ColorsInPal,'self',arg});

        % Drawing axes.
        %--------------
        dw2dutilX('pos_axe_init',win_dw2dtoolX,option);

        % Drawing Original Image
        %-----------------------
        img_anal = wimgcodeX('cod',0,img_anal,NB_ColorsInPal,codemat_v);
        image([1 img_Size(1)],[1 img_Size(2)],img_anal,'Parent',Axe_ImgIni);
        wtitleX('Original Image','Parent',Axe_ImgIni);
        set(Axe_ImgIni,'Tag',tag_axeimgini)

        % Setting enabled values.
        %------------------------
        dw2dutilX('enable',win_dw2dtoolX,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_dw2dtoolX);

    case {'load_dec','import_dec'}
        switch option
            case 'load_dec'
                % Testing file.
                %--------------
                fileMask = {...
                    '*.wa2;*.mat' , 'Decomposition  (*.wa2;*.mat)';
                    '*.*','All Files (*.*)'};
                [filename,pathname,ok] = utguidivX('load_var',win_dw2dtoolX, ...
                    fileMask,'Load Wavelet Analysis (2D)',...
                    {'coefs','sizes','wave_name'});
                if ~ok, return; end

                % Loading file.
                %--------------
                load([pathname filename],'-mat');
                
            case 'import_dec'
                [ok,S] = wtbximportX('dec2d'); 
                if ~ok, return; end
                filename = ''; pathname = '';
                coefs = S.coefs;
                sizes = S.sizes;
                wave_name = S.wave_name;
                if isfield(S,'map') , map = S.map; end
                if isfield(S,'data_name') , data_name = S.data_name; end  
                option = 'load_dec';
        end
        if ~exist('map','var') , map = pink(def_nbCodeOfColors); end
        if ~exist('data_name','var') , data_name = 'no name';    end
        lev = size(sizes,1)-2;
        if lev>max_lev_anal
            msg = 'The level of the decomposition \nis too large (max = %.0f).';
            msg = sprintf(msg, max_lev_anal);
            wwarndlgX(msg,'Load Wavelet Analysis (2D)','block');
            return
        end
        flagIDX = length(sizes(1,:))<3;
        setfigNAME(win_dw2dtoolX,flagIDX)       

        % Cleaning.
        %----------
        wwaitingX('msg',win_dw2dtoolX,'Wait ... cleaning');
        dw2dutilX('clean',win_dw2dtoolX,option);

        % Getting Analysis parameters.
        %-----------------------------       
        s_img      = [size(sizes,1) , 2];
        Img_Size   = sizes(s_img(1),[2 1]);
        Level_Anal = s_img(1)-2;
        NB_ColorsInPal = size(map,1);

        % Setting coefs and sizes.
        %-------------------------
        wmemtoolX('wmb',win_dw2dtoolX,n_coefs,1,coefs); 
        wmemtoolX('wmb',win_dw2dtoolX,n_sizes,1,sizes);

        % Setting GUI values.
        %--------------------
        levm   = wmaxlevX(Img_Size,'haar');
        levmax = min(levm,max_lev_anal);
        cbanaparX('set',win_dw2dtoolX, ...
                 'n_s',{data_name,Img_Size},'wav',wave_name, ...
                 'lev',{'String',int2str((1:levmax)'),'Value',Level_Anal});
        levels = int2str((1:Level_Anal)');
        set(pop_declev,'String',levels,'Value',Level_Anal);
        pink_map = pink(NB_ColorsInPal);
        self_map = max(max(abs(map-pink_map)));
        if self_map , arg = map; else arg = []; end
        cbcolmapX('set',win_dw2dtoolX,'pal',{'pink',NB_ColorsInPal,'self',arg});

        % Setting Analysis parameters.
        %-----------------------------
        wmemtoolX('wmb',win_dw2dtoolX,n_param_anal,   ...
                       ind_act_option,option,       ...
                       ind_wav_name,wave_name,      ...
                       ind_lev_anal,Level_Anal,     ...
                       ind_img_name,data_name,      ...
                       ind_img_t_name,'',           ...
                       ind_img_size,Img_Size,       ...
                       ind_nbcolors,NB_ColorsInPal, ...
                       ind_simg_type,'ss'           ...
                       );
        wmemtoolX('wmb',win_dw2dtoolX,n_InfoInit, ...
                       ind_filename,filename,   ...
                       ind_pathname,pathname    ...
                       );

        % Drawing axes.
        %--------------
        dw2dutilX('pos_axe_init',win_dw2dtoolX,option);

        % Calling Analysis
        %-----------------
        dw2dmngrX('step2',win_dw2dtoolX,option);

        % Computing Original Image.
        %--------------------------
        X = appcoef2X(coefs,sizes,wave_name,0);

        % Drawing Original Image
        %-----------------------
        X = wimgcodeX('cod',0,X,NB_ColorsInPal,codemat_v);
        image([1 Img_Size(1)],[1,Img_Size(2)],X,'Parent',Axe_ImgIni);
        wtitleX('Reconstructed Image','Parent',Axe_ImgIni);
        set(Axe_ImgIni,'Tag',tag_axeimgini)
        image([1 Img_Size(1)],[1 Img_Size(2)],X,'Parent',Axe_ImgSyn);
        set(Axe_ImgSyn,...
            'XTicklabelMode','manual', ...
            'YTicklabelMode','manual', ...
            'XTicklabel',[],           ...
            'YTicklabel',[],           ...
            'Box','On',                ...
            'Tag',tag_axeimgsyn        ...
            );
        wtitleX('Synthesized Image','Parent',Axe_ImgSyn);

        % Setting enabled values.
        %------------------------
        dw2dutilX('enable',win_dw2dtoolX,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_dw2dtoolX);

    case {'load_cfs','import_cfs'}
        % varargin{1} = 'new_synt' (optional).
        %----------------------------
        if nargin==2 || isequal(option,'import_cfs')
            switch option
                case 'load_cfs'
                    % Testing file.
                    %--------------
                    [filename,pathname,ok] = utguidivX('load_var',win_dw2dtoolX,  ...
                        '*.mat','Load Coefficients (2D)',...
                        {'coefs','sizes'});
                    if ~ok, return; end

                    % Loading file.
                    %--------------
                    load([pathname filename],'-mat');
                    Img_Name = strtok(filename,'.');
                    
                case 'import_cfs'
                    [ok,S,varName] = wtbximportX('cfs2d');
                    if ~ok, return; end
                    filename = ''; pathname = '';
                    coefs = S.coefs;
                    sizes = S.sizes;
                    Img_Name = varName;
                    option = 'load_cfs';
            end
            lev = size(sizes,1)-2;
            if lev>max_lev_anal
                msg = 'The level of the decomposition \nis too large (max = %d).';
                msg = sprintf(msg,max_lev_anal);
                wwarndlgX(msg,'Load Coefficients (2D)','block');
                return  
            end
            flagIDX = length(sizes(1,:))<3;
            setfigNAME(win_dw2dtoolX,flagIDX)

            % Cleaning.
            %----------
            wwaitingX('msg',win_dw2dtoolX,'Wait ... cleaning');
            dw2dutilX('clean',win_dw2dtoolX,option);

            % Getting Analysis parameters.
            %-----------------------------
            s_img      = [size(sizes,1) , 2];
            Img_Size   = sizes(s_img(1),[2 1]);
            Level_Anal = s_img(1)-2;

            % Setting coefs and sizes.
            %-------------------------
            wmemtoolX('wmb',win_dw2dtoolX,n_coefs,1,coefs);
            wmemtoolX('wmb',win_dw2dtoolX,n_sizes,1,sizes);

            % Setting GUI values.
            %--------------------
            cbanaparX('set',win_dw2dtoolX, ...
               'n_s',{Img_Name,Img_Size}, ...
               'lev',{'String',int2str(Level_Anal),'Value',1} ...
               );
            levels = int2str((1:Level_Anal)');
            set(pop_declev,'String',levels,'Value',Level_Anal);

            % Computing (approximate) colormap.
            %----------------------------------
            tmp = appcoef2X(coefs,sizes,'haar',Level_Anal);
            NB_ColorsInPal = ceil(max(tmp(:))/(2^Level_Anal));
            NB_ColorsInPal = min([max([2,NB_ColorsInPal]),def_nbCodeOfColors]);
            cbcolmapX('set',win_dw2dtoolX,'pal',{'pink',NB_ColorsInPal});

            % Setting Analysis parameters.
            %-----------------------------
            wmemtoolX('wmb',win_dw2dtoolX,n_param_anal,   ...
                           ind_act_option,option,       ...
                           ind_lev_anal,Level_Anal,     ...
                           ind_img_size,Img_Size,       ...
                           ind_img_name,Img_Name,       ...
                           ind_nbcolors,NB_ColorsInPal, ...
                           ind_simg_type,'ss'           ...
                           );
            wmemtoolX('wmb',win_dw2dtoolX,n_InfoInit, ...
                           ind_filename,filename,   ...
                           ind_pathname,pathname    ...
                           );
        else
            % Cleaning.
            %----------
            wwaitingX('msg',win_dw2dtoolX,'Wait ... cleaning');
            dw2dutilX('clean',win_dw2dtoolX,option,varargin{1});
        end

        % Drawing axes.
        %--------------
        dw2dutilX('pos_axe_init',win_dw2dtoolX,option);

        % Calling Analysis
        %-----------------
        dw2dmngrX('step2',win_dw2dtoolX,option);

        % Setting enabled values.
        %------------------------
        dw2dutilX('enable',win_dw2dtoolX,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_dw2dtoolX);
        
    case 'demo'
        Img_Name   = deblank(varargin{1});
        Wave_Name  = deblank(varargin{2});
        Level_Anal = varargin{3};
        if nargin<6 , optIMG = ''; else optIMG = varargin{4}; end

        % Loading file.
        %--------------
        if any(Img_Name=='.')
            filename = Img_Name;
        else
            filename = [Img_Name '.mat'];
        end
        pathname = utguidivX('WTB_DemoPath',filename);
        [imgInfos,img_anal,map,ok] = utguidivX('load_dem2D',win_dw2dtoolX, ...
                pathname,filename,def_nbCodeOfColors,optIMG);
        if ~ok, return; end
        flagIDX = length(size(img_anal))<3;
        setfigNAME(win_dw2dtoolX,flagIDX)

        % Cleaning.
        %----------
        wwaitingX('msg',win_dw2dtoolX,'Wait ... cleaning');
        dw2dutilX('clean',win_dw2dtoolX,option);
                
        % Setting GUI values.
        %--------------------
        NB_ColorsInPal = size(map,1);
        if isequal(imgInfos.true_name,'X')
            img_Name = imgInfos.name;
        else
            img_Name = imgInfos.true_name;
        end
        levm   = wmaxlevX(imgInfos.size([1 2]),'haar');
        levmax = min(levm,max_lev_anal);
        cbanaparX('set',win_dw2dtoolX, ...
            'n_s',{img_Name,imgInfos.size}, ...
            'wav',Wave_Name, ...
            'lev',{'String',int2str((1:levmax)'),'Value',Level_Anal} ...            
            );
        
        levels = int2str((1:Level_Anal)');
        set(pop_declev,'String',levels,'Value',Level_Anal);
        if imgInfos.self_map , arg = map; else arg = []; end
        cbcolmapX('set',win_dw2dtoolX,'pal',{'pink',NB_ColorsInPal,'self',arg});

        % Setting Analysis parameters
        %-----------------------------
        NB_ColorsInPal = size(map,1);
        wmemtoolX('wmb',win_dw2dtoolX,n_param_anal,  ...
                       ind_act_option,option,      ...
                       ind_img_name,imgInfos.name, ...
                       ind_wav_name,Wave_Name,     ...
                       ind_lev_anal,Level_Anal,    ...
                       ind_img_t_name,imgInfos.true_name, ...
                       ind_img_size,imgInfos.size, ...
                       ind_nbcolors,NB_ColorsInPal,...
                       ind_simg_type,'ss'          ...
                       );
        wmemtoolX('wmb',win_dw2dtoolX,n_InfoInit, ...
                       ind_filename,imgInfos.filename, ...
                       ind_pathname,imgInfos.pathname  ...
                       );

        % Drawing axes.
        %--------------
        dw2dutilX('pos_axe_init',win_dw2dtoolX,option);

        % Drawing Original Image
        %-----------------------
        X = wimgcodeX('cod',0,img_anal,NB_ColorsInPal,codemat_v);
        image([1 imgInfos.size(1)],[1,imgInfos.size(2)],X,...
                'Parent',Axe_ImgIni);
        wtitleX('Original Image','Parent',Axe_ImgIni);
        set(Axe_ImgIni,'Tag',tag_axeimgini)

        % Calling Analysis.
        %-----------------
        dw2dmngrX('step2',win_dw2dtoolX,option);

        % Setting enabled values.
        %------------------------
        dw2dutilX('enable',win_dw2dtoolX,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_dw2dtoolX);

	case 'save_synt'
        % Getting Analysis values.
        %-------------------------
        [wname,valTHR] = wmemtoolX('rmb',win_dw2dtoolX,n_param_anal, ...
                                  ind_wav_name,ind_thr_val); 

        % Getting Synthesized Image.
        %---------------------------
        img = dw2drwcdX('r_synt',win_dw2dtoolX);
        X = round(get(img,'Cdata'));
        utguidivX('save_img','Save Synthesized Image as', ...
            win_dw2dtoolX,X,'wname',wname,'valTHR',valTHR);

    case 'save_app'
        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw2dtoolX,'Wait ... saving');

        % Getting Analysis values.
        %-------------------------
        SaveSTR = 'Save Approximation Image as';
        wname = wmemtoolX('rmb',win_dw2dtoolX,n_param_anal,ind_wav_name); 
        coefs = wmemtoolX('rmb',win_dw2dtoolX,n_coefs,1);
        sizes = wmemtoolX('rmb',win_dw2dtoolX,n_sizes,1);
        Level_Anal = wmemtoolX('rmb',win_dw2dtoolX,n_param_anal,ind_lev_anal);
        levAPP = get(gcbo,'Position');
        if levAPP<=Level_Anal
            X = wrcoef2X('a',coefs,sizes,wname,levAPP);
            X = round(X);
            utguidivX('save_img',SaveSTR,win_dw2dtoolX,X);

        else
            X = wrcoef2X('a',coefs,sizes,wname,1);
            [OKsave,pathname,filename] = ...
                utguidivX('save_img',SaveSTR,win_dw2dtoolX,X);
            if ~OKsave , wwaitingX('off',win_dw2dtoolX); return; end
            [~,name,ext] = fileparts(filename);
            try
                extension = ext(2:end);
                for k=2:Level_Anal
                    fname = [pathname,name '_A' int2str(k),'.',extension];
                    X = wrcoef2X('a',coefs,sizes,wname,k);
                    if ~isequal(extension,'mat')
                        imwrite(X,fname,extension);
                    else
                        save(fname,'X');
                    end
                end
            catch ME 
            end
        end
        wwaitingX('off',win_dw2dtoolX);
 
    case 'save_app_cfs'
        % Testing file.
        %--------------
        levAPP = get(gcbo,'Position');
        strTITLE = ...
            sprintf('Save Coefficients of approximation at level %s',int2str(levAPP));
        [filename,pathname,ok] = utguidivX('test_save',win_dw2dtoolX, ...
            '*.mat',strTITLE);
        if ~ok, return; end
        
        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw2dtoolX,'Wait ... saving coefficients');
        
        % Getting Analysis values.
        %-------------------------
        wname = wmemtoolX('rmb',win_dw2dtoolX,n_param_anal,ind_wav_name); 
        coefs = wmemtoolX('rmb',win_dw2dtoolX,n_coefs,1);
        sizes = wmemtoolX('rmb',win_dw2dtoolX,n_sizes,1);
        X = appcoef2X(coefs,sizes,wname,levAPP); %#ok<*NASGU>
        
        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'X'};
        
        wwaitingX('off',win_dw2dtoolX);
        try
            save([pathname filename],saveStr{:});
        catch
            errargtX(mfilename,'Save FAILED !','msg');
        end
                
    case 'save_cfs'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_dw2dtoolX, ...
                                     '*.mat','Save Coefficients (2D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw2dtoolX,'Wait ... saving coefficients');

        % Getting Analysis values.
        %-------------------------
        [wname,valTHR] = wmemtoolX('rmb',win_dw2dtoolX,n_param_anal, ...
                                  ind_wav_name,ind_thr_val); %#ok<NASGU>
        map = cbcolmapX('get',win_dw2dtoolX,'self_pal');
        if isempty(map)
            nb_colors = wmemtoolX('rmb',win_dw2dtoolX,n_param_anal,ind_nbcolors);
            map = pink(nb_colors); %#ok<NASGU>
        end
        coefs = wmemtoolX('rmb',win_dw2dtoolX,n_coefs,1); %#ok<NASGU>
        sizes = wmemtoolX('rmb',win_dw2dtoolX,n_sizes,1); %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','map','valTHR','wname'};
        wwaitingX('off',win_dw2dtoolX);
        try
          save([pathname filename],saveStr{:});
        catch %#ok<*CTCH>
          errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'save_dec'
        % Testing file.
        %--------------
         fileMask = {...
               '*.wa2;*.mat' , 'Decomposition  (*.wa2;*.mat)';
               '*.*','All Files (*.*)'};                
        [filename,pathname,ok] = utguidivX('test_save',win_dw2dtoolX, ...
                                     fileMask,'Save Wavelet Analysis (2D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw2dtoolX,'Wait ... saving decomposition');

        % Getting Analysis parameters.
        %-----------------------------
        [wave_name,data_name,level_anal,nb_colors,valTHR] = ...
                wmemtoolX('rmb',win_dw2dtoolX,n_param_anal, ...
                               ind_wav_name, ...
                               ind_img_name, ...
                               ind_lev_anal, ...
                               ind_nbcolors, ...
                               ind_thr_val   ...
                               ); %#ok<ASGLU,NASGU>

        map = cbcolmapX('get',win_dw2dtoolX,'self_pal');
        if isempty(map) , map = pink(nb_colors); end    %#ok<NASGU>
        coefs = wmemtoolX('rmb',win_dw2dtoolX,n_coefs,1); %#ok<NASGU>
        sizes = wmemtoolX('rmb',win_dw2dtoolX,n_sizes,1); %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wa2'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','wave_name','map','valTHR','data_name'};
        wwaitingX('off',win_dw2dtoolX);
        try
          save([pathname filename],saveStr{:});
        catch
          errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'exp_wrks'
        wwaitingX('msg',win_dw2dtoolX,'Wait ... saving');
        typeSAVE = varargin{1};
        switch typeSAVE
            case 'sig'
                map = cbcolmapX('get',win_dw2dtoolX,'self_pal');
                if isempty(map)
                    nb_colors = wmemtoolX('rmb',win_dw2dtoolX, ...
                        n_param_anal,ind_nbcolors);
                    map = pink(nb_colors); %#ok<NASGU>
                end
                img = dw2drwcdX('r_synt',win_dw2dtoolX);
                X = round(get(img,'Cdata'));
                wtbxexportX(X,'name','sig_2D','title','Synt. Image');

            case 'cfs'
                [wname,valTHR] = wmemtoolX('rmb',win_dw2dtoolX,n_param_anal, ...
                    ind_wav_name,ind_thr_val);
                map = cbcolmapX('get',win_dw2dtoolX,'self_pal');
                if isempty(map)
                    nb_colors = wmemtoolX('rmb',win_dw2dtoolX, ...
                        n_param_anal,ind_nbcolors);
                    map = pink(nb_colors);
                end
                coefs = wmemtoolX('rmb',win_dw2dtoolX,n_coefs,1);
                sizes = wmemtoolX('rmb',win_dw2dtoolX,n_sizes,1);
                S = struct('coefs',coefs,'sizes',sizes,'map',map,...
                    'valTHR',valTHR,'wname',wname);
                wtbxexportX(S,'name','cfs_2D','title','Coefficients');

            case 'dec'
                [wave_name,data_name,nb_colors,valTHR] = ...
                    wmemtoolX('rmb',win_dw2dtoolX,n_param_anal, ...
                    ind_wav_name,ind_img_name,ind_nbcolors,ind_thr_val ...
                    );
                map = cbcolmapX('get',win_dw2dtoolX,'self_pal');
                if isempty(map) , map = pink(nb_colors); end
                coefs = wmemtoolX('rmb',win_dw2dtoolX,n_coefs,1);
                sizes = wmemtoolX('rmb',win_dw2dtoolX,n_sizes,1);                
                S = struct('coefs',coefs,'sizes',sizes,'wave_name',wave_name, ...
                    'map',map,'valTHR',valTHR,'data_name',data_name);
                wtbxexportX(S,'name','dec_2D','title','Decomposition');
        end
        wwaitingX('off',win_dw2dtoolX);

    case 'analyze'
        active_option = wmemtoolX('rmb',win_dw2dtoolX,n_param_anal,ind_act_option);        

        if ~strcmp(active_option,'load_img')
            wwaitingX('msg',win_dw2dtoolX,'Wait ... computing');
            dw2dutilX('clean2',win_dw2dtoolX,option);
            wmemtoolX('wmb',win_dw2dtoolX,n_param_anal,ind_simg_type,'ss');
        end

        % Reading Analysis Parameters.
        %----------------------------
        [Wave_Name,Level_Anal] = cbanaparX('get',win_dw2dtoolX,'wav','lev');

        % Setting GUI values.
        %--------------------
        levels = int2str((1:Level_Anal)');
        set(pop_declev,'String',levels,'Value',Level_Anal);

        % Setting Analysis parameters.
        %-----------------------------
        wmemtoolX('wmb',win_dw2dtoolX,n_param_anal, ...
                       ind_act_option,option,  ...
                       ind_wav_name,Wave_Name, ...
                       ind_lev_anal,Level_Anal ...
                       );

        % Calling Analysis.
        %------------------
        dw2dmngrX('step2',win_dw2dtoolX,option);

        % Setting enabled values.
        %------------------------
        dw2dutilX('enable',win_dw2dtoolX,option);

    case 'synthesize'
        active_option = wmemtoolX('rmb',win_dw2dtoolX,n_param_anal,ind_act_option);
        if ~strcmp(active_option,'load_cfs')
            wwaitingX('msg',win_dw2dtoolX,'Wait ... computing');
            dw2dmngrX('load_cfs',win_dw2dtoolX,'new_synt');
        end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw2dtoolX,'Wait ... computing');

        % Reading Analysis Parameters.
        %----------------------------
        Wave_Name  = cbanaparX('get',win_dw2dtoolX,'wav');

        % Getting & Setting Analysis parameters.
        %---------------------------------------
        [Img_Size,NB_ColorsInPal,Level_Anal] = ...
                wmemtoolX('rmb',win_dw2dtoolX,n_param_anal, ...
                               ind_img_size, ...
                               ind_nbcolors, ...
                               ind_lev_anal  ...
                               );
        wmemtoolX('wmb',win_dw2dtoolX,n_param_anal, ...
                       ind_act_option,option, ...
                       ind_wav_name,Wave_Name ...
                       );

        % Setting GUI values.
        %--------------------
        cbanaparX('set',win_dw2dtoolX, ...
            'lev',{'String',sprintf('%.0f',Level_Anal)});
        levels  = int2str((1:Level_Anal)');
        set(pop_declev,'String',levels,'Value',Level_Anal);

        % Getting Analysis values.
        %-------------------------
        coefs = wmemtoolX('rmb',win_dw2dtoolX,n_coefs,1);
        sizes = wmemtoolX('rmb',win_dw2dtoolX,n_sizes,1);

        % Getting Select Function.
        %------------------------
        [view_status,select_funct] = wmemtoolX('rmb',win_dw2dtoolX,n_miscella,...
                                        ind_view_status,ind_sel_funct);

        % Setting axes properties.
        %-------------------------
        Axe_ImgDec  = wmemtoolX('rmb',win_dw2dtoolX,tag_axeimgdec,1);
        Axe_ImgDec  = Axe_ImgDec(1:4*Level_Anal);
        Img_Handles = wmemtoolX('rmb',win_dw2dtoolX,tag_axeimghdls,1);

        % Computing Synthesized Image.
        %-----------------------------
        view_mode = view_status(1);
        for k=Level_Anal-1:-1:1
            X = appcoef2X(coefs,sizes,Wave_Name,k);
            if (k~=Level_Anal) && ( view_mode=='s' || view_mode=='f')
                vis = 'Off';
            else
                vis = 'On';
            end
            num_img = 4*k;
            axeAct  = Axe_ImgDec(num_img);
            % axes(axeAct)
            %--------------------------------%
            %-   k = level ;
            %-   m = 1 : v ;    m = 2 : d ;         
            %-   m = 3 : h ;    m = 4 : a ; 
            %--------------------------------%
            trunc_p = [k Img_Size(2) Img_Size(1)];
            X = wimgcodeX('cod',1,X,NB_ColorsInPal,codemat_v,trunc_p);
            Img_Handles(num_img) = ...
                image([1 Img_Size(1)],[1,Img_Size(2)],X,...
                    'Parent',axeAct,...
                    'Visible',vis,...
                    'UserData',[0;k;4],...
                    'Tag',tag_imgdec,...
                    'ButtonDownFcn',select_funct...
                );
            set(axeAct, ...
                  'Visible',vis,                   ...
                  'Xcolor',Col_BoxAxeSel,          ...
                  'Ycolor',Col_BoxAxeSel,          ...
                  'XTicklabelMode','manual',       ...
                  'YTicklabelMode','manual',       ...
                  'XTicklabel',[],'YTicklabel',[], ...
                  'XTick',[],'YTick',[],           ...
                  'Box','On',                      ...
                  'Tag',tag_axeimgdec              ...
                  );
        end
        wmemtoolX('wmb',win_dw2dtoolX,tag_axeimghdls,1,Img_Handles);

        % Drawing Synthesized Image.
        %--------------------------
        X = appcoef2X(coefs,sizes,Wave_Name,0);
        X = wimgcodeX('cod',0,X,NB_ColorsInPal,codemat_v);
        if (view_mode=='f') , vis = 'Off'; else vis = 'On'; end
        % axes(Axe_ImgIni);
        image([1 Img_Size(1)],[1 Img_Size(2)],X, ...
                'Visible',vis,'Parent',Axe_ImgIni);
        set(Axe_ImgIni,'Visible',vis,'Tag',tag_axeimgini);
        wtitleX('Original Synthesized Image','Parent',Axe_ImgIni);
        % axes(Axe_ImgSyn);
        image([1 Img_Size(1)],[1 Img_Size(2)],X, ...
                'Visible',vis,'Parent',Axe_ImgSyn);
        set(Axe_ImgSyn,'Visible',vis,'Tag',tag_axeimgsyn);
        wtitleX('Synthesized Image','Parent',Axe_ImgSyn);
        delete(findobj(Axe_ImgVis,'Type','image'));

        % Setting enabled values.
        %------------------------
        dw2dutilX('enable',win_dw2dtoolX,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_dw2dtoolX);

    case 'step2'
        %*****************************************************%
        %** OPTION = 'step2' - (load_dec & demo & analyze)  **%
        %*****************************************************%
        % varargin{1} = calling option
        %---------------------

        % Getting  Analysis parameters.
        %------------------------------
        [Img_Name,Img_Size,NB_ColorsInPal,Wave_Name,Level_Anal] = ...
                 wmemtoolX('rmb',win_dw2dtoolX,n_param_anal, ...
                                ind_img_name, ...
                                ind_img_size, ...
                                ind_nbcolors, ...
                                ind_wav_name, ...
                                ind_lev_anal  ...
                                ); %#ok<ASGLU>

        % Setting axes properties.
        %-------------------------
        Axe_ImgDec = wmemtoolX('rmb',win_dw2dtoolX,tag_axeimgdec,1);
        set(Axe_ImgDec,'Visible','Off');
        Axe_ImgDec = Axe_ImgDec(1:4*Level_Anal);
        indVis = 1:4*Level_Anal;
        indVis = [indVis(mod(indVis,4)~=0),indVis(end)];
        set(Axe_ImgDec(indVis),'Visible','On');

        % Getting Select Function.
        %------------------------
        select_funct = wmemtoolX('rmb',win_dw2dtoolX,n_miscella,ind_sel_funct);

        % Begin waiting.
        %---------------
        wwaitingX('msg',win_dw2dtoolX,'Wait ... computing');

        % Computing.
        %-----------
        if strcmp(varargin{1},'demo') || strcmp(varargin{1},'analyze')
            img_anal      = get(dw2drwcdX('r_orig',win_dw2dtoolX),'Cdata');
            [coefs,sizes] = wavedec2X(img_anal,Level_Anal,Wave_Name);
            clear img_anal

            % Setting coefs and sizes.
            %-------------------------
            wmemtoolX('wmb',win_dw2dtoolX,n_coefs,1,coefs);
            wmemtoolX('wmb',win_dw2dtoolX,n_sizes,1,sizes);
        else
            % Getting Analysis values.
            %-------------------------
            coefs = wmemtoolX('rmb',win_dw2dtoolX,n_coefs,1);
            sizes = wmemtoolX('rmb',win_dw2dtoolX,n_sizes,1);
        end
        
        % App flag.
        %----------
        if strcmp(varargin{1},'load_cfs') || strcmp(varargin{1},'new_synt')
            app_flg = 0;
        else
            app_flg = 1;
        end

        % Decomposition drawing
        %----------------------
        Img_Handles = zeros(1,4*Level_Anal);
        for k=1:Level_Anal
            for m=1:4
                switch m
                    case 1 , Y = detcoef2X('v',coefs,sizes,k);
                    case 2 , Y = detcoef2X('d',coefs,sizes,k);
                    case 3 , Y = detcoef2X('h',coefs,sizes,k);
                    case 4
                        if app_flg || k==Level_Anal
                            Y = appcoef2X(coefs,sizes,Wave_Name,k);
                        else
                            Y = zeros(size(Y));
                        end
                    otherwise
                        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
                            'Invalid Input Argument.');
                end
                if (m==4) && (k~=Level_Anal)
                    vis = 'Off'; 
                else
                    vis = 'On'; 
                end
                num_img = 4*(k-1)+m;
                axeAct  = Axe_ImgDec(num_img);
                % axes(axeAct)
                %-------------------------------%
                %-   k = level ;
                %-   m = 1 : v ;   m = 2 : d ;         
                %-   m = 3 : h ;   m = 4 : a ; 
                %-------------------------------%
                trunc_p = [k Img_Size(2) Img_Size(1)];
                Y = wimgcodeX('cod',1,Y,NB_ColorsInPal,codemat_v,trunc_p);
                Img_Handles(num_img) = ...
                        image([1 Img_Size(1)],[1 Img_Size(2)],Y,...
                              'Parent',axeAct,             ...
                              'Visible',vis,               ...
                              'UserData',[0;k;m],          ...
                              'Tag',tag_imgdec,            ...
                              'ButtonDownFcn',select_funct ...
                              );
                set(axeAct,...
                    'Visible',vis,                    ...
                    'Xcolor',Col_BoxAxeSel,           ...
                    'Ycolor',Col_BoxAxeSel,           ...
                    'XTicklabelMode','manual',        ...
                    'YTicklabelMode','manual',        ...
                    'XTicklabel',[],'YTicklabel',[],  ...
                    'XTick',[],'YTick',[],'Box','On', ...
                    'Tag',tag_axeimgdec               ...
                    );
            end
        end
        wmemtoolX('wmb',win_dw2dtoolX,tag_axeimghdls,1,Img_Handles);

        % Decomposition Title.
        %---------------------
        wsetxlabX(Axe_ImgSel,sprintf('Decomposition at level %.0f',Level_Anal));

        % Synthesized Image (same that original).
        %----------------------------------------
        if strcmp(varargin{1},'demo') || strcmp(varargin{1},'analyze')
            X      = appcoef2X(coefs,sizes,Wave_Name,0);
            X      = wimgcodeX('cod',0,X,NB_ColorsInPal,codemat_v);
            gx     = get(Axe_ImgSyn,'Xgrid');
            gy     = get(Axe_ImgSyn,'Ygrid');
            strtit = get(get(Axe_ImgSyn,'title'),'String');
            image([1 Img_Size(1)],[1 Img_Size(2)],X,'Parent',Axe_ImgSyn);
            set(Axe_ImgSyn,...
                'Visible','On',           ...
                'Xgrid',gx,'Ygrid',gy,    ...
                'XTicklabelMode','manual',...
                'YTicklabelMode','manual',...
                'XTicklabel',[],          ...
                'YTicklabel',[],          ...
                'Box','On',               ...
                'Tag',tag_axeimgsyn       ...
                );
            wtitleX(strtit,'Parent',Axe_ImgSyn);
        end

        % Setting Dynamic Visualization tool.
        %------------------------------------
        dynvtoolX('init',win_dw2dtoolX,...
                        [],...
                        [Axe_ImgIni Axe_ImgBig Axe_ImgSyn Axe_ImgVis],...
                        Axe_ImgDec,[1 1],'','','','int');

        % Setting view_status.
        %---------------------
        view_status = ['s_l' sprintf('%.0f',Level_Anal)];
        wmemtoolX('wmb',win_dw2dtoolX,n_miscella, ...
                       ind_view_status,view_status,...
                       ind_save_status,view_status ...
                       );
        % Add or Delete Save APP-Menu
        %------------------------------
        Add_OR_Del_SaveAPPMenu(win_dw2dtoolX,Level_Anal);

        % End waiting.
        %-------------
        wwaitingX('off',win_dw2dtoolX);

    case 'view_dec'
        %**********************************************%
        %** OPTION = 'view_dec' - view decomposition **%
        %**********************************************%
        % Getting position parameters.
        %-----------------------------
        view_status = wmemtoolX('rmb',win_dw2dtoolX,n_miscella, ...
                               ind_view_status);
        new_lev_view = get(pop_declev,'Value');
        k = findstr(view_status,'l');
        lev_old = wstr2numX(view_status(k+1:length(view_status)));
        if new_lev_view==lev_old , return; end
        dw2dimgsX('cleanif',win_dw2dtoolX,new_lev_view,lev_old);
        view_status = [view_status(1:k) sprintf('%.0f',new_lev_view)];
        wmemtoolX('wmb',win_dw2dtoolX,n_miscella,ind_view_status,view_status);

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw2dtoolX,'Wait ... drawing');

        % Drawing.
        %---------
        dw2dmngrX('set_graphic',win_dw2dtoolX,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_dw2dtoolX);

    case 'select'
        Drag_Tools = [pus_visu,pus_big,pus_rec];
        if strcmp(varargin{1},'end_big')
            % End Big Image.
            %---------------
            dw2dmngrX('set_graphic',win_dw2dtoolX,option,'end');
            handles = [pus_anal, pop_declev, pus_visu, ...
                       pus_rec,  pop_viewm,  pus_full  ...
                       ];
            set(handles,'Enable','On');
            cba_pus_big  = ['dw2dmngrX(''select'','  ...
                            str_numwin ','  ...
                            num2mstrX(pus_big) ');'];
            bk_col = get(pus_visu,'BackGroundColor');
            set(pus_big,...
                    'String',xlate('Full Size'),     ...
                    'BackGroundColor',bk_col, ...
                    'Callback',cba_pus_big    ...
                    );
            val = get(pop_viewm,'Value');
            if (val==square_viewm)
                dw2darroX('vis_arrow',win_dw2dtoolX,'on');
            end
            ind = 0;
		    dynvtoolX('dynvzaxeX_BtnOnOff',win_dw2dtoolX,'On')

        else
            obj_sel = dw2dimgsX('get',win_dw2dtoolX);
            if ~isempty(obj_sel)
                ind = find(gcbo==Drag_Tools);
            else
                ind = 0;
            end
        end

        if ind~=0
            % Getting  Analysis parameters.
            %------------------------------
            if strcmp(get(Drag_Tools(ind),'Enable'),'off') , return; end

            Img_Handles = wmemtoolX('rmb',win_dw2dtoolX,tag_axeimghdls,1);
            indimg      = find(Img_Handles==obj_sel);
            if isempty(indimg) , return; end

            % Begin waiting.
            %--------------
            wwaitingX('msg',win_dw2dtoolX,'Wait ... computing');

            [Img_Size,Wave_Name,Level_Anal] = ...
                    wmemtoolX('rmb',win_dw2dtoolX,n_param_anal, ...
                                   ind_img_size, ...
                                   ind_wav_name, ...
                                   ind_lev_anal  ...
                                   );

            Axe_ImgDec = wmemtoolX('rmb',win_dw2dtoolX,tag_axeimgdec,1);
            Axe_ImgDec = Axe_ImgDec(1:4*Level_Anal);

            % Computing.
            %----------------------------%
            %-   m = 1 : v ;   m = 2 : d ;             
            %-   m = 3 : h ;   m = 4 : a ;     
            %----------------------------%
            us = get(obj_sel,'UserData');
            level = us(2,:);
            m     = us(3,:);
            str_lev = sprintf('%.0f',level);
            switch m
              case 1 , opt = 'v'; typestr = 'Vertical detail';
              case 2 , opt = 'd'; typestr = 'Diagonal detail';
              case 3 , opt = 'h'; typestr = 'Horizontal detail';
              case 4 , opt = 'a'; typestr = 'Approximation';
            end
            switch ind
                case {1,2}    %-- Visualize or big image
                    X = get(obj_sel,'CData');
                    strxlab = [typestr ' coef. at level ' str_lev];
                    axe = get(obj_sel,'Parent');
                    xl = get(axe,'Xlim');
                    yl = get(axe,'Ylim');

                case 3   %-- Reconstruction
                    NB_ColorsInPal = wmemtoolX('rmb',win_dw2dtoolX, ...
                                                    n_param_anal,  ...
                                                    ind_nbcolors   ...
                                                    );
                    coefs = wmemtoolX('rmb',win_dw2dtoolX,n_coefs,1);
                    sizes = wmemtoolX('rmb',win_dw2dtoolX,n_sizes,1);

                    X = wrcoef2X(opt,coefs,sizes,Wave_Name,level);
                    if opt=='a' , flg_code = 0; else flg_code = 1; end
                    X = wimgcodeX('cod',flg_code,X,NB_ColorsInPal,codemat_v);
                    strxlab = ['Recons. ' typestr ' coef. of level ' str_lev];
                    xl = get(Axe_ImgIni,'Xlim');
                    yl = get(Axe_ImgIni,'Ylim');
            end
            if ind~=2       % Drawing (little image)
                gx = get(Axe_ImgVis,'Xgrid');
                gy = get(Axe_ImgVis,'Ygrid');
                image([1 Img_Size(1)],[1 Img_Size(2)],X,'Parent',Axe_ImgVis);
                set(Axe_ImgVis,...
                    'Visible','On',            ...
                    'Xgrid',gx,'Ygrid',gy,     ...
                    'Xlim',xl,'Ylim',yl,       ...
                    'XTicklabel',[],           ...
                    'YTicklabel',[],           ...
                    'Xcolor',Col_BoxTitleSel,  ...
                    'Ycolor',Col_BoxTitleSel,  ...
                    'LineWidth',Wid_LineSel, ...
                    'Box','On',                ...
                    'Tag',tag_axeimgvis        ...
                    );
                wtitleX(strxlab,'Parent',Axe_ImgVis);

            else            % Drawing (big image)
                [row,col] = size(X);
                strxlab   = [strxlab '  -- image size : ('        ...
                             sprintf('%.0f',row) ',' sprintf('%.0f',col) ')'];

                % Setting enabled values.
                %------------------------
				dynvtoolX('dynvzaxeX_BtnOnOff',win_dw2dtoolX,'Off')
                handles = [ pus_anal, pop_declev, pus_visu, ...
                            pus_rec,  pop_viewm,  pus_full  ...
                            ];
                set(handles,'Enable','Off');
                set(pus_big,                               ...
                        'String',xlate('End Full Size'),   ...
                        'Callback',                        ...
                        ['dw2dmngrX(''select'',' str_numwin ...
                                 ',''end_big'');']         ...
                        );
                axe_figutil = findobj(get(win_dw2dtoolX,'Children'),...
                                    'flat','type','axes',      ...
                                    'Tag',tag_axefigutil...
                                    );
                t_lines = findobj(axe_figutil,'type','line','Tag',tag_linetree);
                t_txt   = findobj(axe_figutil,'type','text','Tag',tag_txttree);

                for k=1:4*Level_Anal
                    ax = Axe_ImgDec(k);
                    set(get(ax,'Children'),'Visible','Off');
                    set(ax,'Visible','Off');
                end
                set(findobj([Axe_ImgIni,Axe_ImgVis,...
                             Axe_ImgSyn,Axe_ImgSel]),'visible','off');
                wboxtitlX('vis',Axe_ImgSel,'off');
                set([t_lines' t_txt'],'Visible','off');
                dw2darroX('vis_arrow',win_dw2dtoolX,'off');

                gx = get(Axe_ImgBig,'Xgrid');
                gy = get(Axe_ImgBig,'Ygrid');
                image([1 Img_Size(1)],[1 Img_Size(2)],X,...
                      'Parent',Axe_ImgBig);
                set(Axe_ImgBig, ...
                    'Visible','On',        ...
                    'Xgrid',gx,'Ygrid',gy, ...
                    'XTicklabel',[],       ...
                    'YTicklabel',[],       ...
                    'Xlim',xl,'Ylim',yl,   ...
                    'Tag',tag_axeimgbig    ...
                    );
                wsetxlabX(Axe_ImgBig,strxlab);

                % Changing View Status.
                %----------------------
                view_status = wmemtoolX('rmb',win_dw2dtoolX, ...
                                        n_miscella,ind_view_status);
                wmemtoolX('wmb',win_dw2dtoolX,n_miscella,...
                               ind_save_status,view_status);
                view_status = ['b' sprintf('%.0f',indimg) ...
                                'l' sprintf('%.0f',get(pop_declev,'Value'))];
                wmemtoolX('wmb',win_dw2dtoolX,n_miscella,...
                               ind_view_status,view_status);
            end

            % End waiting.
            %--------------
            wwaitingX('off',win_dw2dtoolX);
        end

    case 'view_mode'
        % Getting & Setting View_status.
        %-------------------------------
        view_status = wmemtoolX('rmb',win_dw2dtoolX,n_miscella,ind_view_status);
        val = get(pop_viewm,'Value');
        if view_status(1)=='s'
            if val==square_viewm , return; end
            view_status(1) = 't';
        elseif view_status(1)=='t'
            if val==tree_viewm , return; end
            view_status(1) = 's';
        end
        wmemtoolX('wmb',win_dw2dtoolX,n_miscella, ...
                       ind_view_status,view_status, ...
                       ind_save_status,view_status  ...
                       );
        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw2dtoolX,'Wait ... drawing');
        
        pos = zeros(4,4);
        pos(1,:) = get(pus_full(1),'Position');
        if val==square_viewm
            pos(1,3) = (3*pos(1,3))/2;
            pos(2,:) = pos(1,:); pos(2,2) = pos(2,2)-pos(2,4);
            pos(3,:) = pos(1,:); pos(3,1) = pos(3,1)+pos(3,3);
            pos(4,:) = pos(3,:);
            pos(4,2) = pos(4,2)-pos(4,4);
        else
            pos(1,3) = (2*pos(1,3))/3;
            pos(2,:) = pos(1,:); pos(2,1) = pos(2,1)+pos(2,3);
            pos(3,:) = pos(2,:); pos(3,1) = pos(3,1)+pos(3,3);
            pos(4,:) = pos(1,:);
            pos(4,3) = 3*pos(4,3);
            pos(4,2) = pos(4,2)-pos(4,4);
        end

        dw2darroX('vis_arrow',win_dw2dtoolX,'off');

        % Cleaning Selection.
        %--------------------
        dw2dimgsX('clean',win_dw2dtoolX);

        % Drawing.
        %---------
        dw2dmngrX('set_graphic',win_dw2dtoolX,option);

        set([txt_full,pus_full],'Visible','off');
        for k=1:4 , set(pus_full(k),'Position',pos(k,:)); end
        pos_txt = get(txt_full,'Position');
        d_txt   = pos(1,4)-pos_txt(4);
        if val==square_viewm
            hdl_on = [txt_full,pus_full];
            pos_txt(2) = pos(1,2)-pos_txt(1,4)/2;
        else
            hdl_on = [txt_full,pus_full(1:3)];
            pos_txt(2) = pos(1,2)+d_txt/2;
        end
        set(txt_full,'Position',pos_txt);
        set(hdl_on,'Visible','on');

        if val==square_viewm
            dw2darroX('vis_arrow',win_dw2dtoolX,'on');
        end

        % End waiting.
        %-------------
        wwaitingX('off',win_dw2dtoolX);

    case 'fullsize'
        % varargin{1} = btn number.
        %------------------

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw2dtoolX,'Wait ... drawing');

        % Test begin or end.
        %-------------------
        num = varargin{1};
        btn = pus_full(num);
        act = get(btn,'Userdata');
        if act==0
            % begin full size
            %----------------
            dw2darroX('vis_arrow',win_dw2dtoolX,'off');
            param = 'beg';
            for k=1:length(pus_full)
                act_old = get(pus_full(k),'Userdata');
                if act_old==1
                    other_btn = pus_full(length(pus_full)+1-k);
                    old_col = get(other_btn,'Backgroundcolor');
                    set(pus_full(k),...
                        'Backgroundcolor',old_col,  ...
                        'String',sprintf('%.0f',k), ...
                        'Userdata',0);
                    break;
                end
            end
            set(btn,'String',['end ' sprintf('%.0f',num)], ...
                    'Userdata',1);
				
			if num==4 , ena_DynV = 'On'; else ena_DynV = 'Off'; end
			
            % Changing View Status.
            %----------------------
            view_status = wmemtoolX('rmb',win_dw2dtoolX,n_miscella,...
                                         ind_view_status);
            if view_status(1)~='f'
                wmemtoolX('wmb',win_dw2dtoolX,n_miscella,...
                                    ind_save_status,view_status);
            end
            view_status = ['f' sprintf('%.0f',num) 'l' ...
                               sprintf('%.0f',get(pop_declev,'value'))];
            wmemtoolX('wmb',win_dw2dtoolX,n_miscella,ind_view_status,view_status);
        else
            % end full size.
            %---------------
            other_btn = pus_full(length(pus_full)+1-num);
            old_col = get(other_btn,'Backgroundcolor');
            param = 'end';
            set(btn,'Backgroundcolor',old_col,    ...
                    'String',sprintf('%.0f',num), ...
                    'Userdata',0);
			ena_DynV = 'On'; 				
        end
		dynvtoolX('dynvzaxeX_BtnOnOff',win_dw2dtoolX,ena_DynV)

        % Setting enabled values.
        %------------------------
        handles = [pus_anal, pus_visu, pus_big, pus_rec, pop_viewm];
        if strcmp(param,'end')
            ena = 'on';
            handles = [handles , pop_declev];
        elseif find(num==[1 2 3])
            ena = 'off';
            handles = [handles , pop_declev];
        elseif num==4
            ena = 'off';
        end

        % Drawing.
        %---------
        if strcmp(ena,'off') , set(handles,'Enable',ena); end
        dw2dmngrX('set_graphic',win_dw2dtoolX,option,param);
        if strcmp(ena,'on')
            set(handles,'Enable',ena);
        elseif num==4
            set(pop_declev,'Enable','On');
        end
        val = get(pop_viewm,'Value');
        if (val==square_viewm) && strcmp(param,'end')
            dw2darroX('vis_arrow',win_dw2dtoolX,'on');
        end

        % End waiting.
        %-------------
        wwaitingX('off',win_dw2dtoolX);

    case 'stat'
        set(wfindobjX('figure'),'Pointer','watch');
        out1 = feval('dw2dstatX','create',win_dw2dtoolX);

    case 'hist'
        set(wfindobjX('figure'),'Pointer','watch');
        out1 = feval('dw2dhistX','create',win_dw2dtoolX);

    case 'comp'
        set(wfindobjX('figure'),'Pointer','watch');
        dw2dutilX('enable',win_dw2dtoolX,option);
        out1 = feval('dw2dcompX','create',win_dw2dtoolX);

    case 'deno'
        set(wfindobjX('figure'),'Pointer','watch');
        dw2dutilX('enable',win_dw2dtoolX,option);
        out1 = feval('dw2ddenoX','create',win_dw2dtoolX);

    case {'return_comp','return_deno'}
        % varargin{1} = 1 : preserve compression
        % varargin{1} = 0 : discard compression
        % varargin{2} = hdl_img (optional)
        %--------------------------------------

        if varargin{1}==1
            % Begin waiting.
            %--------------
            wwaitingX('msg',win_dw2dtoolX,'Wait ... computing');

            if strcmp(option,'return_comp')
                arro_txt = 'comp';      t_simg = 'cs';
                xlab_str = 'Compressed Image';
            else
                arro_txt = 'deno';      t_simg = 'ds';
                xlab_str = 'De-noised Image';
            end
            wmemtoolX('wmb',win_dw2dtoolX,n_param_anal, ...
                           ind_simg_type,t_simg       ...
                           );

            [Img_Size,NB_ColorsInPal] = ...
                    wmemtoolX('rmb',win_dw2dtoolX,n_param_anal,...
                                   ind_img_size,ind_nbcolors);

            % Drawing Synthesized Image.
            %--------------------------
            view_status = wmemtoolX('rmb',win_dw2dtoolX,n_miscella,ind_view_status);
            view_mode   = view_status(1);

            if (view_mode=='f') && (view_status(2)~='2')
                vis = 'Off';
            else
                vis = 'on';
            end
            if (view_mode=='s') , vis_ar = 'On'; else vis_ar = 'Off'; end
            xlim = get(Axe_ImgIni,'Xlim');
            ylim = get(Axe_ImgIni,'Ylim');
            % axes(Axe_ImgSyn);
            image(...
                    [1 Img_Size(1)],[1 Img_Size(2)],        ...
                    wimgcodeX('cod',0,get(varargin{2},'Cdata'), ...
                            NB_ColorsInPal,codemat_v), ...
                    'Visible',vis,                           ...
                    'Parent',Axe_ImgSyn                      ...
                    );
            col = get(get(Axe_ImgSyn,'xlabel'),'Color');
            set(Axe_ImgSyn,...
                'Visible',vis,                  ...
                'XTicklabelMode','manual',      ...
                'YTicklabelMode','manual',      ...
                'XTicklabel',[],'YTicklabel',[],...
                'Xlim',xlim,'Ylim',ylim,        ...
                'Box','On',                     ...
                'Tag',tag_axeimgsyn             ...
                );
            wtitleX(xlab_str,'Color',col,...
                            'Visible',vis,...
                            'Parent',Axe_ImgSyn);

            dw2darroX('vis_arrow',win_dw2dtoolX,vis_ar,arro_txt);

            % End waiting.
            %-------------
            wwaitingX('off',win_dw2dtoolX);
        end
        dw2dutilX('enable',win_dw2dtoolX,option);

    case 'set_graphic'
        % varargin{1} = calling option.
        %  if varargin{1} = 'fullsize' :
        %     varargin{2} = 'beg' or 'end'.
        %  if varargin{1} = 'select' :
        %     varargin{2} = 'beg' or 'end'.
        %-----------------------------

        % Getting Analysis parameters.
        %-----------------------------
        [Img_Size,Level_Anal] = wmemtoolX('rmb',win_dw2dtoolX,n_param_anal,...
                                               ind_img_size,ind_lev_anal);
        level_view = get(pop_declev,'Value');

        % Getting Axes handles.
        %----------------------
        Axe_ImgDec  = wmemtoolX('rmb',win_dw2dtoolX,tag_axeimgdec,1);
        Img_Handles = wmemtoolX('rmb',win_dw2dtoolX,tag_axeimghdls,1);

        % Getting position parameters.
        %-----------------------------
        [ pos,pos_axeini,pos_axevis,pos_axesel,   ...
          pos_axesyn,pos_axebig,pos_axedec,view_status,save_status] = ...
                  wmemtoolX('rmb',win_dw2dtoolX,n_miscella, ...
                                 ind_graph_area,  ...
                                 ind_pos_axeini,  ...
                                 ind_pos_axevis,  ...
                                 ind_pos_axesel,  ...
                                 ind_pos_axesyn,  ...
                                 ind_pos_axebig,  ...
                                 ind_pos_axedec,  ...
                                 ind_view_status, ...
                                 ind_save_status  ...
                                 );
        k = findstr(save_status,'l');
        lev_view_old = wstr2numX(save_status(k+1:length(save_status)));

        % Setting options.
        %-----------------
        obj_sel = [];
        switch varargin{1}
            case 'fullsize'
                if strcmp(varargin{2},'beg')
                    view_attrb = 10+wstr2numX(view_status(2));
                else
                    view_status = save_status;
                    wmemtoolX('wmb',win_dw2dtoolX,n_miscella,...
                                            ind_view_status,view_status);
                    switch view_status(1)
                        case 's' , view_attrb = 5;
                        case 't' , view_attrb = 6;
                    end
                    obj_sel = dw2dimgsX('get',win_dw2dtoolX);
                end

            case 'select'       % end big_image
                view_status = save_status;
                wmemtoolX('wmb',win_dw2dtoolX,n_miscella,...
                                        ind_view_status,view_status);
                switch view_status(1)
                    case 's' , view_attrb = 5;
                    case 't' , view_attrb = 6;
                end
                obj_sel = dw2dimgsX('get',win_dw2dtoolX);

            case 'view_dec'
                save_status = [save_status(1:k) sprintf('%.0f',level_view)];
                wmemtoolX('wmb',win_dw2dtoolX,n_miscella,...
                                        ind_save_status,save_status);
                switch view_status(1) 
                    case {'s','f'} , view_attrb = 3;
                    case 't' ,       view_attrb = 4;
                end

            case 'view_mode'
                switch view_status(1)
                    case 's' , view_attrb = 5;
                    case 't' , view_attrb = 6;
                end
        end

        % Computing axes positions.
        %--------------------------
        if view_status(1)=='t'
            % Getting position parameters.
            %-----------------------------
            term_dim      = Terminal_Prop;
            [xpixl,ypixl] = wfigutilX('prop_size',win_dw2dtoolX,1,1);

            % View boundary parameters.
            %--------------------------
            mx = 0.73;  my = 0.70;

            x_marge = 0.05;
            x_left  = pos(1)+x_marge;
            width   = pos(3)-x_marge;
            NBL     = level_view+1; NBC     = 4;
            w_theo  = width/NBC;    h_theo  = pos(4)/NBL;
            w_pos   = w_theo*mx;    h_pos = h_theo*my;
            X_cent  = x_left+(w_theo/2)*(1:2:2*NBC-1);
            Y_cent  = pos(2)+(h_theo/2)*(1:2:2*NBL-1);
            alpha   = (term_dim(2)*h_pos*Img_Size(1))/...
                      (term_dim(1)*w_pos*Img_Size(2));
            w_used  = w_pos*min(1,alpha);
            h_used  = h_pos*min(1,1/alpha);

            dy  = (h_theo-h_used)/2;
            ind = 2:(NBL-1);
            Y_cent(ind) = Y_cent(ind)-dy*(ind-1); 
            if NBL>Level_Anal-2
                Y_cent(NBL) = Y_cent(NBL)-(level_view*dy)/(NBL-1);
            end

            % Correction : Y-Shift
            %---------------------
            if level_view>max_lev_anal-2
                Y_cent(1:NBL-1) = Y_cent(1:NBL-1)+25*ypixl;
            end

            w_u2 = w_used/2;  h_u2 = h_used/2;
            pos_axeini = [ X_cent(1)-w_u2 , Y_cent(NBL)-h_u2 ,...
                           w_used         , h_used           ];
            pos_axesyn = [ X_cent(2)-w_u2 , Y_cent(NBL)-h_u2 ,...
                           w_used         , h_used           ];
            pos_axevis = [ X_cent(3)      , Y_cent(NBL)-h_u2 ,...
                           w_used         , h_used           ];

            bdy = 0*ypixl;
            xl  = pos(1)+20*xpixl;
            wa  = pos(3)-40*xpixl;
            yd  = Y_cent(1)-h_u2-bdy;
            ha  = Y_cent(NBL-1)-Y_cent(1)+h_used+bdy;
            [ha,yd] = depOfMachine(ypixl,ha,yd);
            pos_axesel = [xl yd wa ha];

            max_l   = max_lev_anal+1;
            l_Xdata = zeros(max_l,2);
            l_Ydata = zeros(max_l,2);
            for k = 1:level_view
                for l = 1:4
                    ind = 4*(level_view-k+1)+1-l;
                    pos_axedec(ind,:) = [X_cent(l)-w_u2  ,...
                                         Y_cent(k)-h_u2  ,...
                                         w_used          ,...
                                         h_used  ];
                end
                l_Xdata(k,:) = [X_cent(1) X_cent(NBC)];
                l_Ydata(k,:) = [Y_cent(k) Y_cent(k)];
            end
            l_Xdata(max_l,:) = [X_cent(1),  X_cent(1)];
            l_Ydata(max_l,:) = [Y_cent(NBL),Y_cent(1)];
            x_left_txt = pos_axeini(1)-0.035;
        end

        max_a   = 4*Level_Anal;
        max_v   = 4*level_view;
        all_ind = 1:max_a;
        rem_4   = rem(all_ind,4);
        switch view_status(1)
            case 's'
                vis_ini = 'on';  vis_vis = 'on';
                vis_sel = 'on';  vis_syn = 'on';
                vis_big = 'off';
                ind_On  = [find(all_ind<max_v & rem_4~=0) , max_v];
                ind_Off = [find(all_ind<max_v & rem_4==0) , ...
                                        find(all_ind>max_v)];

            case 't'
                vis_ini = 'on';  vis_vis = 'on';
                vis_sel = 'on';  vis_syn = 'on';
                vis_big = 'off';
                ind_On  = 1:max_v;  ind_Off = max_v+1:max_a;

            case 'f'
                switch view_status(2)
                    case '1'
                        pos_axeini = pos_axebig;
                        vis_ini = 'on';  vis_vis = 'off';
                        vis_sel = 'off'; vis_syn = 'off';
                        vis_big = 'off';
                        ind_On  = [];    ind_Off = all_ind;

                    case '2'
                        pos_axesyn = pos_axebig;
                        vis_ini = 'off'; vis_vis = 'off';
                        vis_sel = 'off'; vis_syn = 'on';
                        vis_big = 'off';
                        ind_On  = [];    ind_Off = all_ind;

                    case '3'
                        pos_axevis = pos_axebig;
                        vis_ini = 'off'; vis_vis = 'on';
                        vis_sel = 'off'; vis_syn = 'off';
                        vis_big = 'off';
                        ind_On  = [];    ind_Off = all_ind;

                    case '4'
                        pos_axesel = pos_axebig;
                        xl = pos_axesel(1);
                        yb = pos_axesel(2);
                        la = pos_axesel(3)/2;
                        ha = pos_axesel(4)/2;
                        ind = 1;
                        for k = 1:max_lev_anal
                            pos_axedec(ind:ind+3,1:4) = ...
                                    [xl   , yb   , la, ha;
                                     xl+la, yb   , la, ha;
                                     xl+la, yb+ha, la, ha;
                                     xl   , yb+ha, la, ha ...
                                    ];
                            ind = ind+4;
                            yb = yb+ha; la = la/2; ha = ha/2;
                        end

                        vis_ini = 'off'; vis_vis = 'off';
                        vis_sel = 'on';  vis_syn = 'off';
                        vis_big = 'off';
                        ind_On  = [find(all_ind<max_v & rem_4~=0) , max_v];
                        ind_Off = [find(all_ind<max_v & rem_4==0) , ...
                                        find(all_ind>max_v)];
                end
        end     

        % Setting graphic area.
        %----------------------
        axe_figutil = findobj(axe_handles,'Tag',tag_axefigutil);
        t_lines     = findobj(axe_figutil,'type','line','Tag',tag_linetree);
        t_txt       = findobj(axe_figutil,'type','text','Tag',tag_txttree);
        set([t_lines' t_txt'],'Visible','off'); 
        set(Img_Handles,'Visible','Off');
        ind = 4*lev_view_old;
        delete([...
                get(Axe_ImgDec(ind),'Xlabel'),...
                get(Axe_ImgDec(ind-1),'Xlabel'),...
                get(Axe_ImgDec(ind-2),'Xlabel'),...
                get(Axe_ImgDec(ind-3),'Xlabel'),...
                ]);
        switch view_status(1)
            case 'f'
                switch view_status(2)
                    case '1' , set(Axe_ImgIni,'Position',pos_axeini);
                    case '2' , set(Axe_ImgSyn,'Position',pos_axesyn);
                    case '3' , set(Axe_ImgVis,'Position',pos_axevis);
                    case '4'
                        set(Axe_ImgSel,'Position',pos_axesel);
                        for k = 1:4*max_lev_anal
                            set(Axe_ImgDec(k),'Position',pos_axedec(k,:));
                        end
                end

            case {'s','t'}
                set(Axe_ImgIni,'Position',pos_axeini);
                set(Axe_ImgVis,'Position',pos_axevis);
                set(Axe_ImgSyn,'Position',pos_axesyn);
                set(Axe_ImgSel,'Position',pos_axesel);
                for k = 1:4*max_lev_anal
                    set(Axe_ImgDec(k),'Position',pos_axedec(k,:));
                end
        end
        set(findobj(Axe_ImgIni),'visible',vis_ini);
        set(findobj(Axe_ImgVis),'visible',vis_vis);
        set(findobj(Axe_ImgSyn),'visible',vis_syn);
        set(findobj(Axe_ImgSel),'visible',vis_sel);
        set(findobj(Axe_ImgBig),'visible',vis_big);
        s_font = Def_AxeFontSize;
        if view_status(1)=='t'
            bdy = 18;
            strxlab = sprintf('Decomposition at level %.0f',level_view); 
            box_str = ['Image Selection : ' strxlab];
            wboxtitlX('set',Axe_ImgSel,box_str,s_font,9,10,bdy,vis_sel);
        else
            bdy = 18;
            box_str = 'Image Selection';
            wboxtitlX('set',Axe_ImgSel,box_str,s_font,9,18,bdy,vis_sel);
        end

        switch view_attrb
            case 4
                for k = [1:level_view,max_lev_anal+1]
                    l = findobj(t_lines,'Type','line','Userdata',k);
                    set(l,...
                         'Xdata',l_Xdata(k,:),...
                         'Ydata',l_Ydata(k,:),...
                         'Visible','On'       ...
                         );
                end
                for k = 1:level_view
                    txt = findobj(t_txt,'Type','text','Userdata',k);
                    j = level_view+1-k;
                    set(txt,...
                           'Position',[x_left_txt ,l_Ydata(j,1)], ...
                           'Visible','On'                         ...
                           );
                end
                set(Axe_ImgSel,'Visible','Off');

            case 5
                set([Axe_ImgDec,Axe_ImgIni,Axe_ImgVis,Axe_ImgSel,Axe_ImgSyn],...
                                'Visible','off');
                ind = 4*level_view;
                delete([...
                        get(Axe_ImgDec(ind),'Xlabel'),  ...
                        get(Axe_ImgDec(ind-1),'Xlabel'),...
                        get(Axe_ImgDec(ind-2),'Xlabel'),...
                        get(Axe_ImgDec(ind-3),'Xlabel') ...
                        ]);

            case 6
                set([Axe_ImgDec,Axe_ImgIni,Axe_ImgVis,Axe_ImgSel,Axe_ImgSyn],...
                                'Visible','off');
                for k = [1:level_view,max_lev_anal+1]
                    l = findobj(t_lines,'Type','line','Userdata',k);
                    set(l,...
                        'Xdata',l_Xdata(k,:),...
                        'Ydata',l_Ydata(k,:),...
                        'Visible','On'       ...
                        );
                end
                for k = 1:level_view
                    txt = findobj(t_txt,'Type','text','Userdata',k);
                    j = level_view+1-k;
                    set(txt,...
                        'Position',[x_left_txt ,l_Ydata(j,1)], ...
                        'Visible','On'                         ...
                        );
                end
        end

        if find(view_attrb==[5 6])
                if view_attrb==5
                    set([Axe_ImgIni,Axe_ImgSel],'Visible','on','Box','On');
                else
                    set(Axe_ImgIni,...
                        'Visible','on',                 ...
                        'XTicklabelMode','manual',      ...
                        'YTicklabelMode','manual',      ...
                        'XTicklabel',[],'YTicklabel',[],...
                        'XTick',[],'YTick',[],          ...
                        'Box','On');
                end
                % for k = 1:length(ind_On) , axes(Axe_ImgDec(k)); end
                set(Axe_ImgDec(ind_On),...
                    'Visible','on',...
                    'Xcolor',Col_BoxAxeSel,         ...
                    'Ycolor',Col_BoxAxeSel,         ...
                    'XTicklabelMode','manual',      ...
                    'YTicklabelMode','manual',      ...
                    'XTicklabel',[],'YTicklabel',[],...
                    'XTick',[],'YTick',[],'Box','On'...
                    );

                if ~isempty(obj_sel)
                    axe = get(obj_sel,'parent');
                    set(axe,...
                        'Xcolor',Col_BoxTitleSel, ...
                        'Ycolor',Col_BoxTitleSel, ...
                        'LineWidth',Wid_LineSel,...
                        'Box','On'                ...
                        );
                end
                                       
                set(Axe_ImgVis,...
                    'Visible','on',                 ...
                    'XTicklabelMode','manual',      ...
                    'YTicklabelMode','manual',      ...
                    'XTicklabel',[],'YTicklabel',[],...
                    'Xcolor',Col_BoxTitleSel,       ...
                    'Ycolor',Col_BoxTitleSel,       ...
                    'LineWidth',Wid_LineSel,        ...
                    'Box','On'                      ...
                    );
                set(Axe_ImgSyn,...
                    'Visible','on',                 ...
                    'XTicklabelMode','manual',      ...
                    'YTicklabelMode','manual',      ...
                    'XTicklabel',[],'YTicklabel',[],...
                    'Box','On'                      ...
                    );
  
        end

        if find(view_attrb==[3 4 5 6 11 12 13 14])
            set(Img_Handles(ind_On),'Visible','On');
            set(Axe_ImgDec(ind_On),'Visible','On');
            if ~isempty(ind_Off)
                set(Img_Handles(ind_Off),'Visible','Off');
                set(Axe_ImgDec(ind_Off),'Visible','Off');
            end
        end

        if view_attrb==5
            strxlab = sprintf('Decomposition at level %.0f',level_view); 
            wsetxlabX(Axe_ImgSel,strxlab);

        elseif find(view_attrb==[4 6])
            strxlab = '';
            wsetxlabX(Axe_ImgSel,strxlab);
            ind = 4*level_view;
            col_lab = get(win_dw2dtoolX,'DefaultAxesXColor');
            wsetxlabX(Axe_ImgDec(ind),xlate('Approximations'),col_lab);
            wsetxlabX(Axe_ImgDec(ind-1),'Horizontal Details',col_lab);
            wsetxlabX(Axe_ImgDec(ind-2),'Diagonal Details',col_lab);
            wsetxlabX(Axe_ImgDec(ind-3),'Vertical Details',col_lab);

        elseif find(view_attrb==[3 14])
            strxlab = sprintf('Decomposition at level %.0f',level_view); 
            wsetxlabX(Axe_ImgSel,strxlab);
        end
		
    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid Input Argument.');
end


%-------------------------------------------------
function varargout = depOfMachine(varargin)

ypixl = varargin{1};
ha    = varargin{2};
yd    = varargin{3};
scrSize = get(0,'ScreenSize');
if (scrSize(4)<700) 
    dyd = 10*ypixl;
    ha = ha+dyd; 
    yd = yd-dyd;
end
varargout = {ha,yd};
%-------------------------------------------------
function setfigNAME(fig,flagIDX)

if flagIDX
    figNAME = 'Wavelet 2-D : Indexed Image';
else
    figNAME = 'Wavelet 2-D : Truecolor Image';
end
set(fig,'Name',figNAME);
%-------------------------------------------------


%--------------------------------------------------------------------------
function Add_OR_Del_SaveAPPMenu(win_tool,Level_Anal)

% Add or Delete Save APP-Menu
%------------------------------
Men_Save_APP = ...
    findobj(win_tool,'type','uimenu','tag','Men_Save_APP');
child = get(Men_Save_APP,'Children');
delete(child);
str_numwin = sprintf('%20.15f',win_tool);
for k = 1:Level_Anal
    labSTR = sprintf('Approximation at level %s',int2str(k));
    uimenu(Men_Save_APP,'Label',labSTR,'Position',k, ...
        'Callback',['dw2dmngrX(''save_app'',' str_numwin ');']  ...
        );
end
labSTR = sprintf('All the Approximations');
uimenu(Men_Save_APP,'Label',labSTR,'Position',Level_Anal+1,...
    'Separator','On', ...
    'Callback',['dw2dmngrX(''save_app'',' str_numwin ');']  ...
    );
Men_Save_APP_CFS = ...
    findobj(win_tool,'type','uimenu','tag','Men_Save_APP_CFS');
child = get(Men_Save_APP_CFS,'Children');
delete(child);
for k = 1:Level_Anal
    labSTR = sprintf('Coefficients of A%s',int2str(k));
    uimenu(Men_Save_APP_CFS,'Label',labSTR,'Position',k, ...
        'Callback',['dw2dmngrX(''save_app_cfs'',' str_numwin ');']  ...
        );
end
%--------------------------------------------------------------------------
