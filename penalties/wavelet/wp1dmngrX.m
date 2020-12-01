function varargout = wp1dmngrX(option,win_wptool,in3,in4,in5,in6,in7)
%WP1DMNGR Wavelet packets 1-D general manager.
%   OUT1 = WP1DMNGR(OPTION,WIN_WPTOOL,IN3,IN4,IN5,IN6,IN7)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 03-Aug-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $

% Default values.
%----------------
default_nbcolors = 128;

% Memory Blocks of stored values.
%================================
% MB0.
%-----
n_InfoInit   = 'WP1D_InfoInit';
ind_filename = 1;
ind_pathname = 2;

% MB1.
%-----
n_param_anal   = 'WP1D_Par_Anal';
ind_sig_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_sig_size   = 6;
ind_act_option = 7;
ind_thr_val    = 8;

% MB2.
%-----
n_wp_utils = 'WP_Utils';
ind_nb_colors = 6;

switch option
    case {'load_sig','import_sig'}
        switch option
            case 'load_sig'
                [sigInfos,Sig_Anal,ok] = utguidivX('load_sig',win_wptool,...
                        'Signal_Mask','Load Signal');
                if ~ok, return; end

            case 'import_sig'
                [sigInfos,Sig_Anal,ok] = wtbximportX('wp1d');
                if ~ok, return; end
                if isa(Sig_Anal,'wptree')
                    wp1dmngrX('load_dec',win_wptool,Sig_Anal,sigInfos.name);
                    return
                end
                option = 'load_sig';
        end
        wtbxappdataX('set',win_wptool,...
            'Anal_Data_Info',{Sig_Anal,sigInfos.name});

        % Cleaning.
        %----------
        wwaitingX('msg',win_wptool,'Wait ... cleaning');
        wp1dutilX('clean',win_wptool,option,'');

        % Setting Analysis parameters.
        %-----------------------------
        wmemtoolX('wmb',win_wptool,n_param_anal, ...
                       ind_act_option,option,     ...
                       ind_sig_name,sigInfos.name,...
                       ind_sig_size,sigInfos.size ...
                       );
        wmemtoolX('wmb',win_wptool,n_InfoInit, ...
                       ind_filename,sigInfos.filename, ...
                       ind_pathname,sigInfos.pathname  ...
                       );
        wmemtoolX('wmb',win_wptool,n_wp_utils,...
                       ind_nb_colors,default_nbcolors);

        % Setting GUI values.
        %--------------------
        wp1dutilX('set_gui',win_wptool,option);

        % Drawing.
        %---------
        wp1ddrawX('sig',win_wptool,Sig_Anal);

        % Setting enabled values.
        %------------------------
        wp1dutilX('enable',win_wptool,option);

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
                        winTitle = 'Load Wavelet Packet Analysis (1D)';
                        fileMask = {...
                            '*.wp1;*.mat' , 'Decomposition  (*.wp1;*.mat)';
                            '*.*','All Files (*.*)'};
                        [filename,pathname,ok] = ...
                            utguidivX('load_wpdecX',win_wptool, ...
                                        fileMask,winTitle,2);
                        if ~ok, return; end

                        % Loading file.
                        %--------------
                        load([pathname filename],'-mat');
                        if ~exist('data_name','var')
                            data_name = 'no name';
                        end
                        if exist('tree_struct','var')
                            WP_Tree = tree_struct; %#ok<NODEF>
                        end

                    case {3,4}
                        WP_Tree = in3;
                        if nargin>3
                            data_name = in4; 
                        else
                            data_name = 'input var';
                        end
                end

            case 'import_dec'
                [ok,S,varName] = wtbximportX('decwp1d'); %#ok<NASGU>
                if ok
                    WP_Tree = S.tree_struct;
                    if isa(WP_Tree,'wptree')
                        order = treeordX(WP_Tree);
                        ok = isequal(order,2);
                    else
                        ok = false;
                    end
                end
                if ~ok, return; end
                data_name = S.data_name;
                option = 'load_dec';
        end

        % Cleaning.
        %----------
        wwaitingX('msg',win_wptool,'Wait ... cleaning');
        wp1dutilX('clean',win_wptool,option);

        % Getting Analysis parameters.
        %-----------------------------
        [Wave_Name,Ent_Name,Ent_Par,Signal_Size] = ...
                read(WP_Tree,'wavname','entname','entpar','sizes',0);
        Level_Anal  = treedpthX(WP_Tree);
        Sig_Name = data_name;

        % Setting Analysis parameters
        %-----------------------------
        wmemtoolX('wmb',win_wptool,n_param_anal,  ...
                       ind_act_option,option,    ...
                       ind_sig_name,Sig_Name, ...
                       ind_wav_name,Wave_Name,   ...
                       ind_lev_anal,Level_Anal,  ...
                       ind_sig_size,Signal_Size, ...
                       ind_ent_anal,Ent_Name,    ...
                       ind_ent_par,Ent_Par       ...
                       );
        wmemtoolX('wmb',win_wptool,n_wp_utils,      ...
                       ind_nb_colors,default_nbcolors ...
                       );
        % Writing structures.
        %----------------------
        wtbxappdataX('set',win_wptool,'WP_Tree',WP_Tree);
        wtbxappdataX('set',win_wptool,'WP_Tree_Saved',WP_Tree);

        % Setting GUI values.
        %--------------------
        wp1dutilX('set_gui',win_wptool,option);

        % Computing and Drawing Original Signal.
        %---------------------------------------
        wwaitingX('msg',win_wptool,'Wait ... computing');
        Sig_Anal = wprec(WP_Tree);
        wp1ddrawX('sig',win_wptool,Sig_Anal);

        % Decomposition drawing
        %----------------------
        wp1ddrawX('anal',win_wptool);

        % Setting enabled values.
        %------------------------
        wp1dutilX('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_wptool);

    case 'demo'
        % in3 = Sig_Name
        % in4 = Wave_Name
        % in5 = Level_Anal
        % in6 = Ent_Name
        % in7 = Ent_Par (optional)
        %--------------------------
        Sig_Name = deblank(in3);
        Wave_Name   = deblank(in4);
        Level_Anal  = in5;
        Ent_Name    = deblank(in6);
        if nargin==6 ,  Ent_Par = 0 ; else Ent_Par = in7; end

        % Loading file.
        %-------------
        filename = [Sig_Name '.mat'];       
        pathname = utguidivX('WTB_DemoPath',filename);
        [sigInfos,Sig_Anal,ok] = ...
            utguidivX('load_dem1D',win_wptool,pathname,filename);
        if ~ok, return; end

        % Cleaning.
        %----------
        wwaitingX('msg',win_wptool,'Wait ... cleaning');
        wp1dutilX('clean',win_wptool,option);

        % Setting Analysis parameters
        %-----------------------------
        wmemtoolX('wmb',win_wptool,n_param_anal,    ...
                       ind_act_option,option,      ...
                       ind_sig_name,sigInfos.name, ...
                       ind_wav_name,Wave_Name,     ...
                       ind_lev_anal,Level_Anal,    ...
                       ind_sig_size,sigInfos.size, ...
                       ind_ent_anal,Ent_Name,      ...
                       ind_ent_par,Ent_Par         ...
                        );
        wmemtoolX('wmb',win_wptool,n_InfoInit, ...
                       ind_filename,sigInfos.filename, ...
                       ind_pathname,sigInfos.pathname  ...
                       );
        wmemtoolX('wmb',win_wptool,n_wp_utils,      ...
                       ind_nb_colors,default_nbcolors ...
                       );

        % Setting GUI values.
        %--------------------
        wp1dutilX('set_gui',win_wptool,option);

        % Drawing.
        %---------
        wp1ddrawX('sig',win_wptool,Sig_Anal);

        % Calling Analysis.
        %-----------------
        wp1dmngrX('step2',win_wptool,option);

        % Setting enabled values.
        %------------------------
        wp1dutilX('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_wptool);

    case 'save_synt'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_wptool, ...
                                     '*.mat','Save Synthesized Signal');
        if ~ok, return; end
        name  = strtok(filename,'.');

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_wptool,'Wait ... saving');

        % Saving Synthesized Signal.
        %---------------------------
        [wname,valTHR] = wmemtoolX('rmb',win_wptool,n_param_anal,...
            ind_wav_name,ind_thr_val); %#ok<NASGU,NASGU>
        hdl_node = wpssnodeX('r_synt',win_wptool);
        if ~isempty(hdl_node)
            x = get(hdl_node,'userdata');        %#ok<NASGU>
        else
            WP_Tree = wtbxappdataX('get',win_wptool,'WP_Tree');
            x = wprec(WP_Tree); %#ok<NASGU>
        end
        
        try
            saveStr = name;
            eval([saveStr '= x ;']);
        catch
            saveStr = 'x';
        end
        
        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        wwaitingX('off',win_wptool);
        try
          save([pathname filename],saveStr,'valTHR','wname');
        catch
          errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'save_dec'
         % Testing file.
        %--------------
         fileMask = {...
               '*.wp1;*.mat' , 'Decomposition  (*.wp1;*.mat)';
               '*.*','All Files (*.*)'};                
        [filename,pathname,ok] = utguidivX('test_save',win_wptool, ...
                                   fileMask,'Save Wavelet Packet Analysis (1D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_wptool,'Wait ... saving decomposition');

        % Getting Analysis parameters.
        %-----------------------------
        data_name = wmemtoolX('rmb',win_wptool,n_param_anal,ind_sig_name); %#ok<NASGU>

        % Reading structures.
        %--------------------
        tree_struct = wtbxappdataX('get',win_wptool,'WP_Tree'); %#ok<NASGU>

        % Saving file.
        %--------------
        valTHR = wmemtoolX('rmb',win_wptool,n_param_anal,ind_thr_val); %#ok<NASGU>
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wp1'; filename = [name ext];
        end
        saveStr = {'tree_struct','data_name','valTHR'};
        wwaitingX('off',win_wptool);
        try
            save([pathname filename],saveStr{:});
        catch
            errargtX(mfilename,'Save FAILED !','msg');
        end
        
    case 'exp_wrks'
        wwaitingX('msg',win_wptool,'Wait ... exporting data');
        typeEXP = in3;
        switch typeEXP
            case 'sig'
                hdl_node = wpssnodeX('r_synt',win_wptool);
                if ~isempty(hdl_node)
                    x = get(hdl_node,'userdata');
                else
                    WP_Tree = wtbxappdataX('get',win_wptool,'WP_Tree');
                    x = wprec(WP_Tree);
                end
                wtbxexportX(x,'name','sig_1D','title','Synt. Signal');

            case 'dec'
                [data_name,valTHR] = wmemtoolX('rmb',win_wptool,...
                        n_param_anal,ind_sig_name,ind_thr_val);
                tree_struct = wtbxappdataX('get',win_wptool,'WP_Tree');
                S = struct(...
                    'tree_struct',tree_struct,...
                    'data_name',data_name,'valTHR',valTHR);
                wtbxexportX(S,'name','dec_WP1D','title','Decomposition');
        end
        wwaitingX('off',win_wptool);
        
    case 'anal'
        active_option = wmemtoolX('rmb',win_wptool,n_param_anal,ind_act_option);
        if ~strcmp(active_option,'load_sig')
            % Cleaning. 
            %----------
            wwaitingX('msg',win_wptool,'Wait ... cleaning');
            wp1dutilX('clean',win_wptool,'load_sig','new_anal');
            wp1dutilX('enable',win_wptool,'load_sig');
        else
            wmemtoolX('wmb',win_wptool,n_param_anal,ind_act_option,'anal');
        end

        % Waiting message.
        %-----------------
        wwaitingX('msg',win_wptool,'Wait ... computing');

        % Setting Analysis parameters
        %-----------------------------
        [Wave_Name,Level_Anal] = cbanaparX('get',win_wptool,'wav','lev');
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
            ind_wav_name,Wave_Name, ...
            ind_lev_anal,Level_Anal,...
            ind_ent_anal,Ent_Name,  ...
            ind_ent_par,Ent_Par     ...
            );

        % Calling Analysis.
        %------------------
        wp1dmngrX('step2',win_wptool,option);

        % Setting enabled values.
        %------------------------
        wp1dutilX('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_wptool);

    case 'step2'
        % Begin waiting.
        %---------------
        wwaitingX('msg',win_wptool,'Wait ... computing');

        % Getting  Analysis parameters.
        %------------------------------
        [Sig_Name,Wave_Name,Level_Anal,Ent_Name,Ent_Par] = ...
                wmemtoolX('rmb',win_wptool,n_param_anal, ...
                               ind_sig_name, ...
                               ind_wav_name,ind_lev_anal, ...
                               ind_ent_anal,ind_ent_par);
        active_option = wmemtoolX('rmb',win_wptool,n_param_anal,ind_act_option);
        [filename,pathname] = wmemtoolX('rmb',win_wptool,n_InfoInit, ...
                                             ind_filename,ind_pathname);

        % Computing.
        %-----------   
        switch active_option
            case {'demo','anal'}
                try
                    load([pathname filename],'-mat');
                    Sig_Anal = eval(Sig_Name);
                catch
                    try
                        Anal_Data_Info = ...
                            wtbxappdataX('get',win_wptool,'Anal_Data_Info');
                        Sig_Anal = Anal_Data_Info{1};
                    catch
                        [Sig_Anal,ok] = utguidivX('direct_load_sig', ...
                            win_wptool,pathname,filename);
                        if ~ok
                            wwaitingX('off',win_wptool);
                            msg = sprintf('File %s not found!', filename);
                            errordlg(msg,'Load ERROR','modal');
                            return
                        end

                    end
                end

            case 'load_dec'       % second time only for load_dec
                Sig_Anal = get(wp1ddrawX('r_orig',win_wptool),'Ydata');
                WP_Tree  = wtbxappdataX('get',win_wptool,'WP_Tree'); %#ok<NASGU>
        end
        WP_Tree = wpdecX(Sig_Anal,Level_Anal,Wave_Name,Ent_Name,Ent_Par);

        % Writing structures.
        %----------------------
        wtbxappdataX('set',win_wptool,'WP_Tree',WP_Tree);
        wtbxappdataX('set',win_wptool,'WP_Tree_Saved',WP_Tree);

        % Decomposition drawing
        %----------------------
        wp1ddrawX('anal',win_wptool);

        % End waiting.
        %-------------
        wwaitingX('off',win_wptool);

    case 'comp'
        mousefrmX(0,'watch');
        drawnow;
        wp1dutilX('enable',win_wptool,option);
        fig = feval('wp1dcompX','create',win_wptool);
        if nargout>0 , varargout{1} = fig; end

    case 'deno'
        mousefrmX(0,'watch');
        drawnow;
        wp1dutilX('enable',win_wptool,option);
        fig = feval('wp1ddenoX','create',win_wptool);
        if nargout>0 , varargout{1} = fig; end        

    case {'return_comp','return_deno'}
        % in3 = 1 : preserve compression
        % in3 = 0 : discard compression
        % in4 = hdl_line (optional)
        %--------------------------------------
        if in3==1
            % Begin waiting.
            %--------------
            wwaitingX('msg',win_wptool,'Wait ... drawing');

            if strcmp(option,'return_comp')
                namesig = 'cs';
            else
                namesig = 'ds';
            end
            wpssnodeX('plot',win_wptool,namesig,1,in4,[]);

            % End waiting.
            %-------------
            wwaitingX('off',win_wptool);
        end
        wp1dutilX('enable',win_wptool,option);

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid argument value.');
end
