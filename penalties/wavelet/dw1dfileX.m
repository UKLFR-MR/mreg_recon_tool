function [out1,out2,out3,out4] = dw1dfileX(option,win_dw1dtoolX,in3,in4)
%DW1DFILE Discrete wavelet 1-D file manager.
%   [OUT1,OUT2,OUT3,OUT4] = DW1DFILE(OPTION,WIN_DW1DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 29-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $

% MemBloc0 of stored values.
%---------------------------
n_InfoInit   = 'DW1D_InfoInit';
ind_filename =  1;
ind_pathname =  2;
% nb0_stored   =  2;

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
% ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
% ind_axe_ref    = 5;
% ind_act_option = 6;
% ind_ssig_type  = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% MemBloc2 of stored values.
%---------------------------
n_coefs_longs = 'Coefs_and_Longs';
ind_coefs     = 1;
ind_longs     = 2;
% nb2_stored    = 2;

% MemBloc3 of stored values.
%---------------------------
n_synt_sig = 'Synt_Sig';
ind_ssig   =  1;
% nb3_stored =  1;

% MemBloc4 of stored values.
%---------------------------
n_miscella     = 'DWAn1d_Miscella';
% ind_graph_area =  1;
% ind_view_mode  =  2;
ind_savepath   =  3;
% nb4_stored     =  3;

% Figure handle.
%---------------
numfig = int2str(win_dw1dtoolX);

% Default values.
%---------------- 
percentYLIM = 0.01;
epsilon = 0.01;
nbMinPt = 20;
Wave_Name = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_wav_name);

switch option
    case 'anal'
        %******************************************************%
        %** OPTION = 'anal' -  Computing and saving Analysis.**%
        %******************************************************%
        % in3 optional (for 'load_dec' or 'synt' or 'new_anal')
        %------------------------------------------------------
        if nargin==2
            numopt = 1;
        elseif strcmp(in3,'new_anal')
            numopt = 2;
        else
            numopt = 3;
        end     

        % Getting  Analysis parameters.
        %------------------------------
        [Signal_Name,Level_Anal] =   ...
                wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,  ...
                               ind_sig_name,ind_lev_anal  ...
                               );
        pathname = wmemtoolX('rmb',win_dw1dtoolX,n_InfoInit,ind_pathname);
        filename = wmemtoolX('rmb',win_dw1dtoolX,n_InfoInit,ind_filename);
        if numopt<3
            if numopt==1
                try
                    Anal_Data_Info = wtbxappdataX('get',win_dw1dtoolX,...
                        'Anal_Data_Info');
                    Signal_Anal = Anal_Data_Info{1};
                catch
                    try
                        load([pathname filename],'-mat');
                        Signal_Anal = eval(Signal_Name);
                        if size(Signal_Anal,1)>1 , Signal_Anal = Signal_Anal'; end
                    catch
                        [Signal_Anal,ok] = ...
                            utguidivX('direct_load_sig',win_dw1dtoolX,pathname,filename);
                        if ~ok
                            msg = sprintf('File %s is not a valid file.',filename);
                            wwaitingX('off',win_dw1dtoolX);
                            errordlg(msg,'Load Signal ERROR','modal');
                            return
                        end
                    end
                end
            else
                Signal_Anal = dw1dfileX('sig',win_dw1dtoolX);
            end
            [coefs,longs] = wavedecX(Signal_Anal,Level_Anal,Wave_Name);

            % Writing coefficients.
            %----------------------
            wmemtoolX('wmb',win_dw1dtoolX,n_coefs_longs,...
                           ind_coefs,coefs,ind_longs,longs);
        else
            [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
                                           ind_coefs,ind_longs);
        end

        % Cleaning files.
        %----------------
        dw1dfileX('del',win_dw1dtoolX);

        % Test for saving.
        %-----------------
        try
          err = 0;
          sig_rec = 1; %#ok<NASGU>
          save(['sig_rec.' numfig],'sig_rec','-mat');
        catch
          err = 1;
        end

        if err==0
            % Computing and Saving Approximations
            %------------------------------------
            pathname = cd;
            if ~isequal(pathname(length(pathname)),filesep)
                pathname = [pathname filesep];
            end
            wmemtoolX('wmb',win_dw1dtoolX,n_miscella,...
                           ind_savepath,pathname);
            app_rec = wrmcoefX('a',coefs,longs,Wave_Name);
            if nargin==2
                sig_rec = Signal_Anal;  %#ok<NASGU>
            else
                sig_rec = app_rec(1,:); %#ok<NASGU>
            end
            save(['sig_rec.' numfig],'sig_rec','-mat');
            clear sig_rec
            ssig_rec = app_rec(1,:);
            save(['ssig_rec.' numfig],'ssig_rec','-mat');
            if nargin==3 , out1 = ssig_rec; end
            wmemtoolX('wmb',win_dw1dtoolX,n_synt_sig,ind_ssig,ssig_rec);
            clear ssig_rec
            app_rec = app_rec(2:Level_Anal+1,:); %#ok<NASGU>
            save(['app_rec.' numfig],'app_rec','-mat');
            clear app_rec

            % Computing and Saving Details
            %-------------------------------
            det_rec = wrmcoefX('d',coefs,longs,Wave_Name); %#ok<NASGU>
            save(['det_rec.' numfig],'det_rec','-mat');
            clear det_rec

            % Computing and Saving Coefficients
            %----------------------------------
            cfs_beg = wrepcoefX(coefs,longs); %#ok<NASGU>
            save(['cfs_beg.' numfig],'cfs_beg','-mat');
        else
            out1 = wrcoefX('a',coefs,longs,Wave_Name);
            wmemtoolX('wmb',win_dw1dtoolX,n_synt_sig,ind_ssig,out1);
        end

    case 'comp_ss'
        %***********************************************************%
        %** OPTION = 'comp_ss' -  Computing and saving Synt. Sig. **%
        %***********************************************************%
        % Used by return_comp & return_deno
        % in3 = hdl_lin
        %------------------------------------
        ssig_rec = get(in3,'Ydata');
        pathname = wmemtoolX('rmb',win_dw1dtoolX,n_miscella,ind_savepath);
        filename = ['ssig_rec.' numfig];
        saveStr  = 'ssig_rec';
        try
          save([pathname filename],saveStr)
        catch
          wmemtoolX('wmb',win_dw1dtoolX,n_synt_sig,ind_ssig,ssig_rec);
        end

    case 'app'
        pathname = wmemtoolX('rmb',win_dw1dtoolX,n_miscella,ind_savepath);
        filename = ['app_rec.' numfig];
        try
          load([pathname filename],'-mat')
          out1 = app_rec(in3,:); %#ok<NODEF>
        catch
          [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
                                         ind_coefs,ind_longs);
          out1 = wrmcoefX('a',coefs,longs,Wave_Name,in3);
        end
        if nargin<4 , return; end;
        switch in4
            case 1
                lx = size(out1,2);
                l3 = length(in3);
                bord = getEdgeSize(in3,Wave_Name);
                lrem = lx+1-2*bord;
                out2 = zeros(1,l3);
                out4 = zeros(1,l3);
                out3 = zeros(1,l3);
                for k = 1:l3
                    if lrem(k)>nbMinPt
                        out2(k) = 1;
                        Xidx = bord(k):lrem(k)+bord(k);
                    else
                        Xidx = 1:lx;
                    end
                    [out3(k),out4(k)] = getMinMax(out1(k,Xidx),percentYLIM);
                end

            case 2
                [out2,out3] = getMinMax(out1,percentYLIM);

            case 3
                lx  = size(out1,2);
                l3  = length(in3);
                bord = getEdgeSize(in3,Wave_Name);
                lrem = lx+1-2*bord;
                out2 = zeros(1,l3);
                out3 = zeros(1,l3);
                for k = 1:l3
                    if lrem(k)>nbMinPt
                        Xidx = bord(k):lrem(k)+bord(k);
                    else
                        Xidx = 1:lx;
                    end
                    [out2(k),out3(k)] = getMinMax(out1(k,Xidx),percentYLIM);
                end
        end

    case 'det'
        pathname = wmemtoolX('rmb',win_dw1dtoolX,n_miscella,ind_savepath);
        filename = ['det_rec.' numfig];
        try
          load([pathname filename],'-mat')
          out1 = det_rec(in3,:); %#ok<NODEF>
        catch
          [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
                                         ind_coefs,ind_longs);
          out1 = wrmcoefX('d',coefs,longs,Wave_Name,in3);
        end
        if nargin<4 , return; end;
        if in4==1
            lx = size(out1,2);
            l3 = length(in3);
            bord = getEdgeSize(in3,Wave_Name);
            lrem = lx+1-2*bord;
            out2 = zeros(1,l3);
            out4 = zeros(1,l3);
            out3 = zeros(1,l3);
            for k = 1:l3
                if lrem(k)>nbMinPt
                    out2(k) = 1;
                    Xidx = bord(k):lrem(k)+bord(k);
                else
                    Xidx = 1:lx;
                end
                [out3(k),out4(k)] = ...
                    getMinMax(out1(k,Xidx),percentYLIM);
            end
        elseif in4==2
            [out2,out3] = getMinMax(out1,percentYLIM);
        end

    case 'sig'
        pathname = wmemtoolX('rmb',win_dw1dtoolX,n_miscella,ind_savepath);
        filename = ['sig_rec.' numfig];
        try
          load([pathname filename],'-mat')
          out1 = sig_rec; %#ok<NODEF>
        catch
          [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
                                         ind_coefs,ind_longs);
          out1 = wrcoefX('a',coefs,longs,Wave_Name,0);
        end
        if nargin==3
            [out2,out3] = getMinMax(out1,percentYLIM);
        end

    case 'ssig'
        pathname = wmemtoolX('rmb',win_dw1dtoolX,n_miscella,ind_savepath);
        filename = ['ssig_rec.' numfig];
        try
          load([pathname filename],'-mat')
          out1 = ssig_rec; %#ok<NODEF>
        catch
          out1 = wmemtoolX('rmb',win_dw1dtoolX,n_synt_sig,ind_ssig);
        end
        if nargin==3
            [out2,out3] = getMinMax(out1,percentYLIM);
        end

    case 'cfs_beg'
        pathname = wmemtoolX('rmb',win_dw1dtoolX,n_miscella,ind_savepath);
        filename = ['cfs_beg.' numfig];
        try
          load([pathname filename],'-mat')
        catch
          [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
                                         ind_coefs,ind_longs);
          cfs_beg = wrepcoefX(coefs,longs);
        end
        out1 = cfs_beg(in3,:);
        if nargin<4 , return; end;
        if in4==1
            lx = size(out1,2);
            l3 = length(in3);
            bord = getEdgeSize(in3,Wave_Name);
            lrem = lx+1-2*bord;
            out2 = zeros(1,l3);
            out4 = zeros(1,l3);
            out3 = zeros(1,l3);
            for k = 1:l3
                if lrem(k)>nbMinPt
                    out2(k) = 1;
                    Xidx = bord(k):lrem(k)+bord(k);
                else
                    Xidx = 1:lx;
                end
                [out3(k),out4(k)] = ...
                    getMinMax(out1(k,Xidx),percentYLIM);
            end
        elseif in4==2
            [out2,out3] = getMinMax(out1,percentYLIM);
        end
        
    case 'app_cfs'
        [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        out1 = appcoefX(coefs,longs,Wave_Name,in3);
        if nargin<4 , return; end;
        if in4==1
            bord = getEdgeSize(in3,Wave_Name);
            lx = size(out1,2);
            lrem = lx+1-2*bord;
            if lrem>nbMinPt
                out2 = 1;
                Xidx = (bord:lrem+bord);
                [out3,out4] = getMinMax(out1(Xidx),percentYLIM);
            else
                out2 = 0;
                out3 = -epsilon;
                out4 = epsilon;
            end
        elseif in4==2
            [out2,out3] = getMinMax(out1,percentYLIM);
        end

    case 'det_cfs'
        [coefs,longs] = wmemtoolX('rmb',win_dw1dtoolX,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        out1 = detcoefX(coefs,longs,in3);
        if nargin<4 , return; end;
        if in4==1
            bord = getEdgeSize(in3,Wave_Name);
            lx = size(out1,2);
            lrem = lx+1-2*bord;
            if lrem>nbMinPt
                out2 = 1;
                Xidx = bord:lrem+bord;
                [out3,out4] = getMinMax(out1(Xidx),percentYLIM);
            else
                out2 = 0;
                out3 = -epsilon;
                out4 = epsilon;
            end
        elseif in4==2
            [out2,out3] = getMinMax(out1,percentYLIM);
        end

    case 'del'
        %************************************%
        %** OPTION = 'del' -  Delete files.**%
        %************************************%
        pathname = wmemtoolX('rmb',win_dw1dtoolX,n_miscella,ind_savepath);
        if ~isempty(pathname)
           olddir = cd;
           try    cd(pathname);
           catch  return;
           end
           sig_file = ['sig_rec.' numfig];
           deleteFile(sig_file)
           ssig_file = ['ssig_rec.' numfig];
           deleteFile(ssig_file);
           app_file = ['app_rec.' numfig];
           deleteFile(app_file);
           det_file = ['det_rec.' numfig];
           deleteFile(det_file);
           cfs_file = ['cfs_beg.' numfig];
           deleteFile(cfs_file);
           cd(olddir);
        end
        wmemtoolX('wmb',win_dw1dtoolX,n_miscella,ind_savepath,'');

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid Input Argument.');
end


%---------------------------------------------------------------
function deleteFile(f)

if exist(f,'file')==2 ,
    try  delete(f); catch end
end
%---------------------------------------------------------------
function [mini,maxi] = getMinMax(val,percent)

[dummy,dim] = max(size(val));
mini  = min(val,[],dim);
maxi  = max(val,[],dim);
delta = max([maxi-mini,sqrt(eps)]);
mini  = mini-percent*delta;
maxi  = maxi+percent*delta;
%---------------------------------------------------------------
function edgeS = getEdgeSize(lev,wname)

f = wfiltersX(wname);
edgeS = (2.^(lev+1))+ length(f);
%---------------------------------------------------------------
