function out1 = dw1dmngrX(option,win_dw1dtoolX,in3,in4,in5)
%DW1DMNGR Discrete wavelet 1-D general manager.
%   OUT1 = DW1DMNGR(OPTION,WIN_DW1DTOOL,IN3,IN4,IN5)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 17-Jun-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $

% Default values.
%----------------
max_lev_anal = 12;

% MemBloc0 of stored values.
%---------------------------
n_InfoInit   = 'DW1D_InfoInit';
ind_filename =  1;
ind_pathname =  2;

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
% ind_axe_ref    = 5;
ind_act_option = 6;
% ind_ssig_type  = 7;
ind_thr_val    = 8;

% MemBloc2 of stored values.
%---------------------------
n_coefs_longs = 'Coefs_and_Longs';
ind_coefs     = 1;
ind_longs     = 2;

%***********************************************%
%** OPTION = 'ini' - Only for precompilation. **%
%***********************************************%
if strcmp(option,'ini') , return; end
%***********************************************%

switch option
    case 'anal'
        active_option = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_act_option);
        if ~strcmp(active_option,'load_sig')

            % Cleaning.
            %----------
            Sig_Anal = dw1dfileX('sig',win_dw1dtoolX);
            wwaitingX('msg',win_dw1dtoolX,'Wait ... cleaning');
            dw1dutilX('clean',win_dw1dtoolX,'load_sig','new_anal');

            % Setting GUI values.
            %--------------------
            dw1dutilX('set_gui',win_dw1dtoolX,'load_sig','new_anal');

            % Drawing.
            %---------
            dw1dvdrvX('plot_sig',win_dw1dtoolX,Sig_Anal);

            % Setting enabled values.
            %------------------------
            dw1dutilX('enable',win_dw1dtoolX,'load_sig');
        else
            wmemtoolX('wmb',win_dw1dtoolX,n_param_anal,ind_act_option,'anal');
        end

        % Waiting message.
        %-----------------
        wwaitingX('msg',win_dw1dtoolX,'Wait ... computing');

        % Setting Analysis parameters
        %-----------------------------
        dw1dutilX('set_par',win_dw1dtoolX,option);

        % Setting GUI values.
        %--------------------
        dw1dutilX('set_gui',win_dw1dtoolX,option);
        mousefrmX(0,'watch');

        % Computing
        %-----------
        if strcmp(active_option,'load_dec')
            dw1dfileX('anal',win_dw1dtoolX,'new_anal');
        else
            dw1dfileX('anal',win_dw1dtoolX);
        end

        % Drawing.
        %---------
        dw1dvdrvX('plot_anal',win_dw1dtoolX);

        % Setting enabled values.
        %------------------------
        dw1dutilX('enable',win_dw1dtoolX,option);
        
        % Add or Delete Save APP-Menu
        %------------------------------
        Level_Anal = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_lev_anal);
        Add_OR_Del_SaveAPPMenu(win_dw1dtoolX,Level_Anal);
        
        % End waiting.
        %-------------
        wwaitingX('off',win_dw1dtoolX);

    case 'synt'
        active_option = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,...
                                        ind_act_option);
        if ~strcmp(active_option,'load_cfs')

            % Cleaning.
            %----------
            wwaitingX('msg',win_dw1dtoolX,'Wait ... cleaning');
            dw1dutilX('clean',win_dw1dtoolX,'load_cfs','new_synt');

            % Setting GUI values.
            %--------------------
            dw1dutilX('set_gui',win_dw1dtoolX,'load_cfs');

            % Drawing.
            %---------
            dw1dvdrvX('plot_cfs',win_dw1dtoolX);

            % Setting enabled values.
            %------------------------
            dw1dutilX('enable',win_dw1dtoolX,'load_cfs');
        else
            wmemtoolX('wmb',win_dw1dtoolX,n_param_anal,ind_act_option,'synt');
        end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw1dtoolX,'Wait ... computing');

        % Setting Analysis parameters
        %-----------------------------
        dw1dutilX('set_par',win_dw1dtoolX,option);

        % Setting GUI values.
        %--------------------
        dw1dutilX('set_gui',win_dw1dtoolX,option);

        % Computing
        %-----------
        dw1dfileX('anal',win_dw1dtoolX,'synt');

        % Computing & Drawing.
        %----------------------
        dw1dvdrvX('plot_synt',win_dw1dtoolX);

        % Setting enabled values.
        %------------------------
        dw1dutilX('enable',win_dw1dtoolX,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_dw1dtoolX);

    case 'stat'
        mousefrmX(0,'watch'); drawnow;
        fig = dw1dstatX('create',win_dw1dtoolX);
        if nargout>0 , out1 = fig; end

    case 'hist'
        mousefrmX(0,'watch'); drawnow;
        fig = dw1dhistX('create',win_dw1dtoolX);
        if nargout>0 , out1 = fig; end

    case 'comp'
        mousefrmX(0,'watch'); drawnow;
        dw1dutilX('enable',win_dw1dtoolX,option);
        fig = dw1dcompX('create',win_dw1dtoolX);
        if nargout>0 , out1 = fig; end

    case 'deno'
        mousefrmX(0,'watch'); drawnow;
        dw1dutilX('enable',win_dw1dtoolX,option);
        fig = dw1ddenoX('create',win_dw1dtoolX);
        if nargout>0 , out1 = fig; end

    case {'return_comp','return_deno'}
        % in3 = 1 : preserve compression
        % in3 = 0 : discard compression
        % in4 = hld_lin (optional)
        %--------------------------------------
        if in3==1
            % Begin waiting.
            %--------------
            wwaitingX('msg',win_dw1dtoolX,'Wait ... drawing');

            % Computing
            %-----------
            dw1dfileX('comp_ss',win_dw1dtoolX,in4);

            % Cleaning axes & drawing.
            %------------------------
            dw1dvmodX('ss_vm',win_dw1dtoolX,[1 4 6],1,0);
            dw1dvmodX('ss_vm',win_dw1dtoolX,[2 3 5],1);
            dw1dvmodX('ch_vm',win_dw1dtoolX,2);

            % End waiting.
            %-------------
            wwaitingX('off',win_dw1dtoolX);
        end
        dw1dutilX('enable',win_dw1dtoolX,option);

    case {'load_sig','import_sig'}
        switch option
            case 'load_sig'
                [sigInfos,Sig_Anal,ok] = ...
                    utguidivX('load_sig',win_dw1dtoolX,'Signal_Mask','Load Signal');
                
            case 'import_sig'
                [sigInfos,Sig_Anal,ok] = wtbximportX('dw1d');
                if size(Sig_Anal,1)>1 , Sig_Anal = Sig_Anal'; end
                option = 'load_sig';
        end
        if ~ok, return; end
        wtbxappdataX('set',win_dw1dtoolX,...
            'Anal_Data_Info',{Sig_Anal,sigInfos.name});

        % Cleaning.
        %----------
        wwaitingX('msg',win_dw1dtoolX,'Wait ... cleaning');
        dw1dutilX('clean',win_dw1dtoolX,option,'');

        % Setting Analysis parameters.
        %-----------------------------
        wmemtoolX('wmb',win_dw1dtoolX,n_param_anal, ...
                       ind_act_option,option,     ...
                       ind_sig_name,sigInfos.name,...
                       ind_sig_size,sigInfos.size ...
                       );
        wmemtoolX('wmb',win_dw1dtoolX,n_InfoInit, ...
                       ind_filename,sigInfos.filename, ...
                       ind_pathname,sigInfos.pathname  ...
                       );

        % Setting GUI values.
        %--------------------
        dw1dutilX('set_gui',win_dw1dtoolX,option,'');

        % Drawing.
        %---------
        dw1dvdrvX('plot_sig',win_dw1dtoolX,Sig_Anal);

        % Setting enabled values.
        %------------------------
        dw1dutilX('enable',win_dw1dtoolX,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_dw1dtoolX);

    case {'load_cfs','import_cfs'}
        if nargin==2 || isequal(option,'import_cfs')
            switch option
                case 'load_cfs'
                    % Testing file.
                    %--------------
                    [filename,pathname,ok] = utguidivX('load_var',win_dw1dtoolX,  ...
                        '*.mat','Load Coefficients (1D)',...
                        {'coefs','longs'});
                    if ~ok, return; end

                    % Loading file.
                    %--------------
                    load([pathname filename],'-mat');
                    Signal_Name = strtok(filename,'.');
                    
                case 'import_cfs'
                    [ok,S,varName] = wtbximportX('cfs1d');
                    if ~ok, return; end
                    filename = ''; pathname = '';
                    coefs = S.coefs;
                    longs = S.longs;
                    Signal_Name = varName;
                    option = 'load_cfs';
            end
            lev = length(longs)-2;
            if lev>max_lev_anal
                wwaitingX('off',win_dw1dtoolX);
                msg = sprintf(...
                    ['The level of the decomposition \n' ...
                    'is too large (max = %d).'],max_lev_anal);
                wwarndlgX(msg,'Load Coefficients (1D)','block');
                return  
            end
            in3 = '';
        end
        wtbxappdataX('del',win_dw1dtoolX,'Anal_Data_Info');

        % Cleaning.
        %----------
        wwaitingX('msg',win_dw1dtoolX,'Wait ... cleaning');
        dw1dutilX('clean',win_dw1dtoolX,option,in3);

        if nargin==2 || isequal(option,'import_cfs')
            % Getting Analysis parameters.
            %-----------------------------
            len         = length(longs);
            Signal_Size = longs(len);
            Level_Anal  = len-2;

            % Setting Analysis parameters
            %-----------------------------
            wmemtoolX('wmb',win_dw1dtoolX,n_param_anal,...
                           ind_act_option,option,    ...
                           ind_sig_name,Signal_Name, ...
                           ind_lev_anal,Level_Anal,  ...
                           ind_sig_size,Signal_Size  ...
                           );
            wmemtoolX('wmb',win_dw1dtoolX,n_InfoInit,...
                           ind_filename,filename,  ...
                           ind_pathname,pathname   ...
                           );

            % Setting coefs and longs.
            %-------------------------
            wmemtoolX('wmb',win_dw1dtoolX,n_coefs_longs, ...
                           ind_coefs,coefs,ind_longs,longs);
        end

        % Setting GUI values.
        %--------------------
        dw1dutilX('set_gui',win_dw1dtoolX,option);

        % Drawing.
        %---------
        dw1dvdrvX('plot_cfs',win_dw1dtoolX);

        % Setting enabled values.
        %------------------------
        dw1dutilX('enable',win_dw1dtoolX,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_dw1dtoolX);

    case {'load_dec','import_dec'}
        switch option
            case 'load_dec'
                fileMask = {...
                    '*.wa1;*.mat' , 'Decomposition  (*.wa1;*.mat)';
                    '*.*','All Files (*.*)'};
                [filename,pathname,ok] = utguidivX('load_var',win_dw1dtoolX, ...
                    fileMask,'Load Wavelet Analysis (1D)',...
                    {'coefs','longs','wave_name','data_name'});
                if ~ok, return; end
                
                % Loading file.
                %--------------
                load([pathname filename],'-mat');
                
            case 'import_dec'
                [ok,S,varName] = wtbximportX('dec1d'); 
                if ~ok, return; end
                filename = [];
                pathname = [];
                coefs = S.coefs;
                longs = S.longs;
                data_name = S.data_name;
                wave_name = S.wave_name;
                option = 'load_dec';
        end        
        lev = length(longs)-2;
        if lev>max_lev_anal
            wwaitingX('off',win_dw1dtoolX);
            msg = 'The level of the decomposition \nis too large (max = %d).';
            msg = sprintf(msg,max_lev_anal);
            wwarndlgX(msg,'Load Wavelet Analysis (1D)','block');
            return
        end
        wtbxappdataX('del',win_dw1dtoolX,'Anal_Data_Info');

        % Cleaning.
        %----------
        wwaitingX('msg',win_dw1dtoolX,'Wait ... cleaning');
        dw1dutilX('clean',win_dw1dtoolX,option);

        % Getting Analysis parameters.
        %-----------------------------
        len         = length(longs);
        Signal_Size = longs(len);
        Level_Anal  = len-2;
        Signal_Name = data_name;
        Wave_Name   = wave_name;

        % Setting Analysis parameters
        %-----------------------------
        wmemtoolX('wmb',win_dw1dtoolX,n_param_anal, ...
                       ind_act_option,option,    ...
                       ind_sig_name,Signal_Name, ...
                       ind_wav_name,Wave_Name,   ...
                       ind_lev_anal,Level_Anal,  ...
                       ind_sig_size,Signal_Size  ...
                       );
        wmemtoolX('wmb',win_dw1dtoolX,n_InfoInit, ...
                       ind_filename,filename, ...
                       ind_pathname,pathname  ...
                       );

        % Setting coefs and longs.
        %-------------------------
        wmemtoolX('wmb',win_dw1dtoolX,n_coefs_longs, ...
                       ind_coefs,coefs,ind_longs,longs);

        % Setting GUI values.
        %--------------------
        dw1dutilX('set_gui',win_dw1dtoolX,option);

        % Computing
        %-----------
        sig_rec = dw1dfileX('anal',win_dw1dtoolX,'load_dec');

        % Drawing.
        %---------
        dw1dvdrvX('plot_sig',win_dw1dtoolX,sig_rec,1);
        dw1dvdrvX('plot_anal',win_dw1dtoolX);

        % Setting enabled values.
        %------------------------
        dw1dutilX('enable',win_dw1dtoolX,option);

        % End waiting.
        %-------------
        wwaitingX('off',win_dw1dtoolX);
        
    case 'demo'
        % in3 = Signal_Name
        % in4 = Wave_Name
        % in5 = Level_Anal
        %------------------
        Signal_Name = deblank(in3);
        Wave_Name   = deblank(in4);
        Level_Anal  = in5;

        % Loading file.
        %-------------
        filename = [Signal_Name '.mat'];       
        pathname = utguidivX('WTB_DemoPath',filename);
        [sigInfos,Sig_Anal,ok] = ...
            utguidivX('load_dem1D',win_dw1dtoolX,pathname,filename);
        if ~ok, return; end
        wtbxappdataX('del',win_dw1dtoolX,'Anal_Data_Info');

        % Cleaning.
        %----------
        wwaitingX('msg',win_dw1dtoolX,'Wait ... cleaning');
        dw1dutilX('clean',win_dw1dtoolX,option);

        % Setting Analysis parameters
        %-----------------------------
        wmemtoolX('wmb',win_dw1dtoolX,n_param_anal,  ...
            ind_act_option,option,      ...
            ind_sig_name,sigInfos.name, ...
            ind_wav_name,Wave_Name,     ...
            ind_lev_anal,Level_Anal,    ...
            ind_sig_size,sigInfos.size  ...
            );
        wmemtoolX('wmb',win_dw1dtoolX,n_InfoInit, ...
            ind_filename,sigInfos.filename,  ...
            ind_pathname,sigInfos.pathname   ...
            );

        % Setting GUI values.
        %--------------------
        dw1dutilX('set_gui',win_dw1dtoolX,option);

        % Drawing.
        %---------
        dw1dvdrvX('plot_sig',win_dw1dtoolX,Sig_Anal,1);

        % Computing
        %-----------
        dw1dfileX('anal',win_dw1dtoolX);
        
        % Drawing.
        %---------
        dw1dvdrvX('plot_anal',win_dw1dtoolX);

        % Setting enabled values.
        %------------------------
        dw1dutilX('enable',win_dw1dtoolX,option);

        % Add or Delete Save APP-Menu
        %------------------------------
        Level_Anal = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_lev_anal);
        Add_OR_Del_SaveAPPMenu(win_dw1dtoolX,Level_Anal);
        
        % End waiting.
        %-------------
        wwaitingX('off',win_dw1dtoolX);

    case 'save_synt'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_dw1dtoolX, ...
                                     '*.mat','Save Synthesized Signal');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw1dtoolX,'Wait ... saving');

        % Getting Analysis values.
        %-------------------------
        [wname,thrParams] = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,...
                                     ind_wav_name,ind_thr_val); %#ok<ASGLU>
        if length(thrParams)==1
            thrName = 'valTHR';  
            valTHR = thrParams; 
        else
            thrName = 'thrParams';
        end
        x = dw1dfileX('ssig',win_dw1dtoolX); 
        
        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        
        try
          saveStr = name;  
          eval([saveStr '= x ;']);  
        catch %#ok<*CTCH>
          saveStr = 'x';
        end
        wwaitingX('off',win_dw1dtoolX);       
        try
          save([pathname filename],saveStr,thrName,'wname');
        catch          
          errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'save_app'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_dw1dtoolX, ...
                                     '*.mat','Save Approximation Signal');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw1dtoolX,'Wait ... saving');

        % Getting Analysis values.
        %-------------------------
        Level_Anal = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_lev_anal);
        levAPP = get(gcbo,'Position');
        if levAPP<=Level_Anal
            x = dw1dfileX('app',win_dw1dtoolX,levAPP); %#ok<*NASGU>
        else
            x = dw1dfileX('app',win_dw1dtoolX,(1:Level_Anal)); 
        end
        
        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        try
            saveStr = name;
            eval([saveStr '= x ;']);
        catch
            saveStr = 'x';
        end
        wwaitingX('off',win_dw1dtoolX);       
        try
            save([pathname filename],saveStr);
        catch
            errargtX(mfilename,'Save FAILED !','msg');
        end
        
    case 'save_app_cfs'
        % Testing file.
        %--------------
        levAPP = get(gcbo,'Position');
        strTITLE = ...
            sprintf('Save Coefficients of approximation at level %s',int2str(levAPP));
        [filename,pathname,ok] = utguidivX('test_save',win_dw1dtoolX, ...
            '*.mat',strTITLE);
        if ~ok, return; end
        
        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw1dtoolX,'Wait ... saving coefficients');
        
        % Getting Analysis values.
        %-------------------------
        wname = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal, ...
            ind_wav_name); %#ok<ASGLU>
        [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
            ind_coefs,ind_longs); %#ok<NASGU>
        x = appcoefX(coefs,longs,wname,levAPP);
        
        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'x'};
        
        wwaitingX('off',win_dw1dtoolX);
        try
            save([pathname filename],saveStr{:});
        catch
            errargtX(mfilename,'Save FAILED !','msg');
        end
        
    case 'save_cfs'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidivX('test_save',win_dw1dtoolX, ...
                                     '*.mat','Save Coefficients (1D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw1dtoolX,'Wait ... saving coefficients');

        % Getting Analysis values.
        %-------------------------
        [wname,thrParams] = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,...
                                     ind_wav_name,ind_thr_val); %#ok<ASGLU>
        if length(thrParams)==1
            thrName = 'valTHR';
            valTHR = thrParams; %#ok<NASGU>
        else
            thrName = 'thrParams';
        end
        [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
                                       ind_coefs,ind_longs); %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','longs',thrName,'wname'};

        wwaitingX('off',win_dw1dtoolX);
        try
          save([pathname filename],saveStr{:});
        catch
          errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'save_dec'
        % Testing file.
        %--------------
         fileMask = {...
               '*.wa1;*.mat' , 'Decomposition  (*.wa1;*.mat)';
               '*.*','All Files (*.*)'};
        [filename,pathname,ok] = utguidivX('test_save',win_dw1dtoolX, ...
                                     fileMask,'Save Wavelet Analysis (1D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_dw1dtoolX,'Wait ... saving decomposition');

        % Getting Analysis parameters.
        %-----------------------------
        [wave_name,data_name,thrParams] = ...
            wmemtoolX('rmb',win_dw1dtoolX,n_param_anal, ...
            	ind_wav_name,ind_sig_name,ind_thr_val); %#ok<ASGLU>
        if length(thrParams)==1
            thrName = 'valTHR';
            valTHR = thrParams; %#ok<NASGU>
        else
            thrName = 'thrParams';
        end
        [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
                                       ind_coefs,ind_longs); %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wa1'; filename = [name ext];
        end
        saveStr = {'coefs','longs',thrName,'wave_name','data_name'};

        wwaitingX('off',win_dw1dtoolX);
        try
          save([pathname filename],saveStr{:});
        catch
          errargtX(mfilename,'Save FAILED !','msg');
        end

    case 'exp_wrks'
        wwaitingX('msg',win_dw1dtoolX,'Wait ... exporting data');
        typeEXP = in3;
        switch typeEXP
            case 'sig'
                x = dw1dfileX('ssig',win_dw1dtoolX);
                wtbxexportX(x,'name','sig_1D','title','Synt. Signal');
                
            case 'cfs'
                [wname,thrParams] = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,...
                    ind_wav_name,ind_thr_val);
                if length(thrParams)==1
                    thrName = 'valTHR';
                else
                    thrName = 'thrParams';
                end
                [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
                    ind_coefs,ind_longs);
                S = struct('coefs',coefs,'longs',longs,thrName,thrParams, ...
                           'wname',wname);
                wtbxexportX(S,'name','cfs_1D','title','Coefficients');
                
            case 'dec'
                [wname,data_name,thrParams] = ...
                    wmemtoolX('rmb',win_dw1dtoolX,n_param_anal, ...
                                   ind_wav_name,ind_sig_name,ind_thr_val);
                if length(thrParams)==1
                    thrName = 'valTHR';
                else
                    thrName = 'thrParams';
                end
                [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
                    ind_coefs,ind_longs);
                S = struct('coefs',coefs,'longs',longs,thrName,thrParams, ...
                        'wave_name',wname,'data_name',data_name);
                wtbxexportX(S,'name','dec_1D','title','Decomposition');
        end
        wwaitingX('off',win_dw1dtoolX);       

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid Input Argument.');
end


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
        'Callback',['dw1dmngrX(''save_app'',' str_numwin ');']  ...
        );
end
labSTR = sprintf('All the Approximations');
uimenu(Men_Save_APP,'Label',labSTR,'Position',Level_Anal+1,...
    'Separator','On', ...
    'Callback',['dw1dmngrX(''save_app'',' str_numwin ');']  ...
    );
Men_Save_APP_CFS = ...
    findobj(win_tool,'type','uimenu','tag','Men_Save_APP_CFS');
child = get(Men_Save_APP_CFS,'Children');
delete(child);
for k = 1:Level_Anal
    labSTR = sprintf('Coefficients of A%s',int2str(k));
    uimenu(Men_Save_APP_CFS,'Label',labSTR,'Position',k, ...
        'Callback',['dw1dmngrX(''save_app_cfs'',' str_numwin ');']  ...
        );
end
%--------------------------------------------------------------------------
