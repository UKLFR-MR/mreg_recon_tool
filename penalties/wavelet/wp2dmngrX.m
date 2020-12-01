function out1 = wp2dmngrX(option,win_wptool,varargin)
%WP2DMNGR Wavelet packets 2-D general manager.
%   OUT1 = WP2DMNGR(OPTION,WIN_WPTOOL,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 16-May-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $

% Default values.
%----------------
default_nbcolors = 255;

% Memory Blocks of stored values.
%================================
% MB0.
%-----
n_InfoInit   = 'WP2D_InfoInit';
ind_filename = 1;
ind_pathname = 2;

% MB1.
%-----
n_param_anal   = 'WP2D_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_img_size   = 6;
ind_img_t_name = 7;
ind_act_option = 8;
ind_thr_val    = 9;

% MB2.
%-----
n_wp_utils = 'WP_Utils';
ind_nb_colors = 6;

switch option
    case {'load_img','import_img'}
        switch option
            case 'load_img'
                imgFileType = getimgfiletypeX;
                [imgInfos,Img_Anal,map,ok] = utguidivX('load_img',win_wptool, ...
                    imgFileType,'Load Image',default_nbcolors);
                if ~ok, return; end

            case 'import_img'
                [imgInfos,Img_Anal,ok] = wtbximportX('wp2d');
                if ~ok, return; end
                if isa(Img_Anal,'wptree')
                    wp2dmngrX('load_dec',win_wptool,Img_Anal,imgInfos.name);
                    return
                end
                map = pink(222);
                option = 'load_img';
        end
        flagIDX = length(size(Img_Anal))<3;
        setfigNAME(win_wptool,flagIDX)        
        wtbxappdataX('set',win_wptool,...
            'Anal_Data_Info',{Img_Anal,imgInfos.name});
    
        % Cleaning.
        %----------
        wwaitingX('msg',win_wptool,'Wait ... cleaning');
        wp2dutilX('clean',win_wptool,option,'');

        % Setting Analysis parameters.
        %-----------------------------
        NB_ColorsInPal = size(map,1);
        wmemtoolX('wmb',win_wptool,n_param_anal, ...
            ind_act_option,option,  ...
            ind_img_name,imgInfos.name, ...
            ind_img_t_name,imgInfos.true_name, ...
            ind_img_size,imgInfos.size ...
            );
        wmemtoolX('wmb',win_wptool,n_InfoInit,  ...
            ind_filename,imgInfos.filename, ...
            ind_pathname,imgInfos.pathname  ...
            );
        wmemtoolX('wmb',win_wptool,n_wp_utils,  ...
                       ind_nb_colors,NB_ColorsInPal);

        % Setting GUI values.
        %--------------------
        wp2dutilX('set_gui',win_wptool,option,'');
	    if imgInfos.self_map , arg = map; else arg = []; end
        cbcolmapX('set',win_wptool,'pal',{'pink',NB_ColorsInPal,'self',arg});

        % Drawing.
        %---------
        wp2ddrawX('sig',win_wptool,Img_Anal);

        % Setting enabled values.
        %------------------------
        wp2dutilX('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_wptool);

    case {'load_dec','import_dec'}
        switch option
            case 'load_dec'
                switch nargin
                    case 2
                        % Testing file.
                        %--------------
                        winTitle = 'Load Wavelet Packet Analysis (2D)';
                        fileMask = {...
                            '*.wp2;*.mat' , 'Decomposition  (*.wp2;*.mat)';
                            '*.*','All Files (*.*)'};
                        [filename,pathname,ok] = utguidivX('load_wpdecX', ...
                            win_wptool,fileMask,winTitle,4);
                        if ~ok, return; end

                        % Loading file.
                        %--------------
                        load([pathname filename],'-mat');
                        if ~exist('map','var'), map = pink(default_nbcolors); end
                        if ~exist('data_name','var') , data_name = 'no name'; end
                        if exist('tree_struct','var') , WP_Tree = tree_struct; end %#ok<NODEF>

                    case {3,4}
                        filename = '';
                        pathname = '';
                        WP_Tree  = varargin{1};
                        map = pink(default_nbcolors);
                        if nargin>3
                            data_name = varargin{2};
                        else
                            data_name = 'input var';
                        end
                end

            case 'import_dec'
                [ok,S,NV] = wtbximportX('decwp2d'); %#ok<NASGU>
                if ok
                    WP_Tree = S.tree_struct;
                    if isa(WP_Tree,'wptree')
                        order = treeordX(WP_Tree);
                        ok = isequal(order,4);
                    else
                        ok = false;
                    end
                end
                if ~ok, return; end
                filename = '';
                pathname = '';
                if isfield(S,'map');
                    map = S.map;
                else
                    map = pink(default_nbcolors);
                end
                data_name = S.data_name;
                option = 'load_dec';                
        end

        % Cleaning.
        %----------
        wtbxappdataX('del',win_wptool,'Anal_Data_Info');
        wp2dutilX('clean',win_wptool,option);

        % Getting Analysis parameters.
        %-----------------------------
        [Wav_Name,Ent_Name,Ent_Par,Img_Size] = ...
            read(WP_Tree,'wavname','entname','entpar','sizes',0);
        Img_Size = fliplr(Img_Size);
        Lev_Anal = treedpthX(WP_Tree);
        Img_Name       = data_name;
        NB_ColorsInPal = size(map,1);

        % Setting Analysis parameters
        %-----------------------------
        wmemtoolX('wmb',win_wptool,n_param_anal, ...
                       ind_act_option,option,   ...
                       ind_img_name,Img_Name,   ...
                       ind_wav_name,Wav_Name,   ...
                       ind_lev_anal,Lev_Anal,   ...
                       ind_img_size,Img_Size,   ...
                       ind_ent_anal,Ent_Name,   ...
                       ind_ent_par,Ent_Par      ...
                       );
        wmemtoolX('wmb',win_wptool,n_InfoInit, ...
                       ind_filename,filename, ...
                       ind_pathname,pathname  ...
                       );
        wmemtoolX('wmb',win_wptool,n_wp_utils,ind_nb_colors,NB_ColorsInPal);

        % Writing structures.
        %----------------------
        wtbxappdataX('set',win_wptool,'WP_Tree',WP_Tree);
        wtbxappdataX('set',win_wptool,'WP_Tree_Saved',WP_Tree);

        % Setting GUI values.
        %--------------------
        wp2dutilX('set_gui',win_wptool,option);

        % Setting Initial Colormap.
        %--------------------------
        cbcolmapX('set',win_wptool,'pal',{'pink',NB_ColorsInPal,'self',[]});

        % Computing Original Signal.
        %--------------------------
        Img_Anal = wprec2(WP_Tree);
        flagIDX = length(size(Img_Anal))<3;
        setfigNAME(win_wptool,flagIDX)        


        % Drawing.
        %---------
        wp2ddrawX('sig',win_wptool,Img_Anal);

        % Decomposition drawing
        %----------------------
        wp2ddrawX('anal',win_wptool);

        % Setting enabled values.
        %------------------------
        wp2dutilX('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_wptool);

    case 'demo'
        % varargin{1} = Img_Name
        % varargin{2} = Wav_Name
        % varargin{3} = Lev_Anal
        % varargin{4} = Ent_Name
        % varargin{5} = Ent_Par (optional)
        % varargin{6} = optIMG (optional)
        %---------------------------------
        Img_Name = deblank(varargin{1});
        Wav_Name = deblank(varargin{2});
        Lev_Anal = varargin{3};
        Ent_Name = deblank(varargin{4});
        nbIN = length(varargin);
        if nbIN<5
            Ent_Par = [];
            optIMG = '';
        else
            Ent_Par = varargin{5}; 
            if nbIN<6 , optIMG = ''; else optIMG = varargin{6}; end
        end
        

        % Loading file.
        %--------------
        if any(Img_Name=='.')
            filename = Img_Name;
        else
            filename = [Img_Name '.mat'];
        end
        pathname = utguidivX('WTB_DemoPath',filename);
        [imgInfos,Img_Anal,map,ok] = utguidivX('load_dem2D',win_wptool, ...
            pathname,filename,default_nbcolors,optIMG);
        if ~ok, return; end
        wtbxappdataX('set',win_wptool,...
            'Anal_Data_Info',{Img_Anal,imgInfos.name});
        flagIDX = length(size(Img_Anal))<3;
        setfigNAME(win_wptool,flagIDX)        
        

        % Cleaning.
        %----------
        wp2dutilX('clean',win_wptool,option);

        % Setting Analysis parameters
        %-----------------------------
        NB_ColorsInPal = size(map,1);
        wmemtoolX('wmb',win_wptool,n_param_anal,    ...
            ind_act_option,option,      ...
            ind_img_name,imgInfos.name, ...
            ind_img_t_name,imgInfos.true_name, ...
            ind_wav_name,Wav_Name,      ...
            ind_lev_anal,Lev_Anal,      ...
            ind_img_size,imgInfos.size, ...
            ind_ent_anal,Ent_Name,      ...
            ind_ent_par,Ent_Par         ...
            );
        wmemtoolX('wmb',win_wptool,n_InfoInit, ...
            ind_filename,imgInfos.filename, ...
            ind_pathname,imgInfos.pathname  ...
            );
        wmemtoolX('wmb',win_wptool,n_wp_utils,    ...
            ind_nb_colors,NB_ColorsInPal ...
            );

        % Setting GUI values.
        %--------------------
        wp2dutilX('set_gui',win_wptool,option);
        if imgInfos.self_map , arg = map; else arg = []; end
        cbcolmapX('set',win_wptool,'pal',{'pink',NB_ColorsInPal,'self',arg});

        % Drawing.
        %---------
        wp2ddrawX('sig',win_wptool,Img_Anal);

        % Calling Analysis.
        %-----------------
        wp2dmngrX('step2',win_wptool,option);

        % Setting enabled values.
        %------------------------
        wp2dutilX('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_wptool);
        
    case 'save_synt'
        % Getting Synthesized Image.
        %---------------------------
        hdl_node = wpssnodeX('r_synt',win_wptool);
        if ~isempty(hdl_node)
            X = get(hdl_node,'userdata');
        else
            % Reading structures.
            %--------------------
            WP_Tree = wtbxappdataX('get',win_wptool,'WP_Tree');
            X = wprec2(WP_Tree);
        end
        X = round(X);

        % Saving file.
        %--------------
        [wname,valTHR] = wmemtoolX('rmb',win_wptool,n_param_anal,...
                                  ind_wav_name,ind_thr_val);
        utguidivX('save_img','Save Synthesized Image as', ...
            win_wptool,X,'wname',wname,'valTHR',valTHR);
        
    case 'save_dec'
        % Testing file.
        %--------------
         fileMask = {...
               '*.wp2;*.mat' , 'Decomposition  (*.wp2;*.mat)';
               '*.*','All Files (*.*)'};                        
        [filename,pathname,ok] = utguidivX('test_save',win_wptool, ...
                                   fileMask,'Save Wavelet Packet Analysis (2D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_wptool,'Wait ... saving decomposition');

        name = strtok(filename,'.');
        ext = '.wp2';
        filename = [name ext];

        % Getting Analysis parameters.
        %-----------------------------
        data_name = wmemtoolX('rmb',win_wptool,n_param_anal,ind_img_name); %#ok<NASGU>
        tree_struct = wtbxappdataX('get',win_wptool,'WP_Tree');            %#ok<NASGU>
        valTHR = wmemtoolX('rmb',win_wptool,n_param_anal,ind_thr_val);     %#ok<NASGU>
        map = cbcolmapX('get',win_wptool,'self_pal');
        if isempty(map)
            nb_colors = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_nb_colors);
            map = pink(nb_colors);                                        %#ok<NASGU>
        end

        % Saving file.
        %-------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wp2'; filename = [name ext];
        end
        saveStr = {'tree_struct','map','data_name','valTHR'};
        wwaitingX('off',win_wptool);
        try
            save([pathname filename],saveStr{:});
        catch %#ok<CTCH>
            errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'exp_wrks'
        wwaitingX('msg',win_wptool,'Wait ... saving');
        typeSAVE = varargin{1};
        switch typeSAVE
            case 'sig'
                hdl_node = wpssnodeX('r_synt',win_wptool);
                if ~isempty(hdl_node)
                    x = get(hdl_node,'userdata');
                else
                    WP_Tree = wtbxappdataX('get',win_wptool,'WP_Tree');
                    x = wprec(WP_Tree);
                end
                wtbxexportX(x,'name','sig_2D','title','Synt. Image');

            case 'dec'
                [data_name,valTHR] = wmemtoolX('rmb',win_wptool,...
                        n_param_anal,ind_img_name,ind_thr_val);
                tree_struct = wtbxappdataX('get',win_wptool,'WP_Tree');
                S = struct(...
                    'tree_struct',tree_struct,...
                    'data_name',data_name,'valTHR',valTHR);
                wtbxexportX(S,'name','dec_WP2D','title','Decomposition');
        end
        wwaitingX('off',win_wptool);
        
    case 'anal'
        active_option = wmemtoolX('rmb',win_wptool,n_param_anal,...
                                        ind_act_option);
        if ~strcmp(active_option,'load_img')
            % Test for new Analysis.
            %-----------------------
            % new = wwaitansX(win_wptool,'New Analysis ?');
            % if new==0 , return; end

            % Cleaning. 
            %----------
            wwaitingX('msg',win_wptool,'Wait ... computing');
            wp2dutilX('clean',win_wptool,'load_img','new_anal');
            wp2dutilX('enable',win_wptool,'load_img');
        else
            wwaitingX('msg',win_wptool,'Wait ... computing');
            wmemtoolX('wmb',win_wptool,n_param_anal,ind_act_option,'anal');
        end

        % Setting Analysis parameters
        %-----------------------------
        [Wav_Name,Lev_Anal] = cbanaparX('get',win_wptool,'wav','lev');
        [Ent_Name,Ent_Par,err] = utentparX('get',win_wptool,'ent');
        if err>0
            wwaitingX('off',win_wptool);
            switch err
              case 1 , msg = 'Invalid entropy parameter value! ';
              case 2 , msg = 'Invalid entropy name! ';
            end
            errargtX(mfilename,msg,'msg');
            utentparX('set',win_wptool);
            return
        end
        wmemtoolX('wmb',win_wptool,n_param_anal, ...
                       ind_wav_name,Wav_Name,   ...
                       ind_lev_anal,Lev_Anal,   ...
                       ind_ent_anal,Ent_Name,   ...
                       ind_ent_par,Ent_Par      ...
                       );

        % Calling Analysis.
        %------------------
        wp2dmngrX('step2',win_wptool,option);

        % Setting enabled values.
        %------------------------
        wp2dutilX('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_wptool);

    case 'step2'
        % Begin waiting.
        %---------------
        wwaitingX('msg',win_wptool,'Wait ... computing');

        % Getting  Analysis parameters.
        %------------------------------
        [Wav_Name,Lev_Anal,Img_True_Name,Ent_Name,Ent_Par] = ...
                        wmemtoolX('rmb',win_wptool,n_param_anal, ...
                                        ind_wav_name,ind_lev_anal, ...
                                        ind_img_t_name, ...
                                        ind_ent_anal,ind_ent_par);
        active_option = wmemtoolX('rmb',win_wptool,n_param_anal,ind_act_option);
        [filename,pathname] = wmemtoolX('rmb',win_wptool,n_InfoInit, ...
                                        ind_filename,ind_pathname);

        if strcmp(active_option,'demo') || strcmp(active_option,'anal')
            numopt = 1;
        elseif strcmp(active_option,'load_dec')
            numopt = 2;
        end

        % Computing.
        %-----------
        if numopt==1
            try
                Anal_Data_Info = ...
                    wtbxappdataX('get',win_wptool,'Anal_Data_Info');
                Img_Anal = Anal_Data_Info{1};
            catch %#ok<CTCH>
                try
                    [fileStruct,err] = wfileinfX(pathname,filename); %#ok<ASGLU>
                catch ME  %#ok<NASGU>
                    err = 1;
                end
                msg = sprintf('File %s not found!', filename);
                if ~err
                    try
                        load([pathname filename],'-mat');
                    catch ME  %#ok<NASGU>
                        msg = sprintf('File %s is not a valid file.', filename);
                        err = 1;
                    end
                else
                    [X,map,imgFormat,colorType,err] = ...
                        utguidivX('direct_load_img',win_wptool,pathname,filename); %#ok<ASGLU>
                    if err
                        msg = sprintf('File %s is not a valid file or is empty.', filename);
                    end
                end
                if err
                    wwaitingX('off',win_wptool);
                    errordlg(msg,'Load Image ERROR','modal');
                    return
                end
                Img_Anal = double(eval(Img_True_Name));
            end

        elseif numopt==2    % second time only for load_dec
            Img_Anal = get(wp2ddrawX('r_orig',win_wptool),'Cdata');
            % WP_Tree  = wtbxappdataX('get',win_wptool,'WP_Tree');
        end
        WP_Tree = wpdec2X(Img_Anal,Lev_Anal,Wav_Name,Ent_Name,Ent_Par);

        % Writing structures.
        %--------------------
        wtbxappdataX('set',win_wptool,'WP_Tree',WP_Tree);
        wtbxappdataX('set',win_wptool,'WP_Tree_Saved',WP_Tree);

        % Decomposition drawing
        %----------------------
        wp2ddrawX('anal',win_wptool);

        % End waiting.
        %-------------
        wwaitingX('off',win_wptool);

    case 'comp'
        mousefrmX(0,'watch');
        drawnow;
        wp2dutilX('enable',win_wptool,option);
        out1 = feval('wp2dcompX','create',win_wptool);

    case 'deno'
        mousefrmX(0,'watch');
        drawnow;
        wp2dutilX('enable',win_wptool,option);
        out1 = feval('wp2ddenoX','create',win_wptool);

    case {'return_comp','return_deno'}
        % varargin{1} = 1 : preserve compression
        % varargin{1} = 0 : discard compression
        % varargin{2} = hdl_img (optional)
        %--------------------------------------

        if varargin{1}==1
            % Begin waiting.
            %--------------
            wwaitingX('msg',win_wptool,'Wait ... drawing');

            if strcmp(option,'return_comp')
                namesig = 'cs';
            else
                namesig = 'ds';
            end
            NB_Col = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_nb_colors);
            wpssnodeX('plot',win_wptool,namesig,2,varargin{2},NB_Col)

            % End waiting.
            %-------------
            wwaitingX('off',win_wptool);
        end
        wp2dutilX('enable',win_wptool,option);

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid argument value.');
end

%-------------------------------------------------
function setfigNAME(fig,flagIDX)

if flagIDX
    figNAME = 'Wavelet Packets 2-D : Indexed Image';
else
    figNAME = 'Wavelet Packets 2-D : Truecolor Image';
end
set(fig,'Name',figNAME);
%-------------------------------------------------

