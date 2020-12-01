function [out1,out2,out3,out4,out5,out6,out7] = ...
          dw1dsepmX(option,win_dw1dtoolX,in3,in4)
%DW1DSEPM Discrete wavelet 1-D separate mode.
%   [OUT1,OUT2,OUT3,OUT4,OUT5,OUT6,OUT7] = ...
%   DW1DSEPM(OPTION,WIN_DW1DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 11-Sep-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2012/02/08 09:52:45 $ 

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
ind_act_option = 6;
ind_ssig_type  = 7;
% ind_thr_val    = 8;
% nb1_stored     = 8;

% MemBloc4 of stored values.
%---------------------------
n_miscella     = 'DWAn1d_Miscella';
ind_graph_area =  1;
% ind_view_mode  =  2;
% ind_savepath   =  3;
% nb4_stored     =  3;

% Tag property of objects.
%-------------------------
tag_a_l_sep = 'AL_Sep';
tag_t_l_sep = 'TL_Sep';
tag_a_r_sep = 'AR_Sep';
tag_t_r_sep = 'TR_Sep';
tag_fra_sep = 'Fra_Sep';
tag_sa_sep  = 'Sa_Sep';
tag_ssa_sep = 'SSa_Sep';
tag_app_sep = 'App_Sep';
tag_sd_sep  = 'Sd_Sep';
tag_ssd_sep = 'SSd_Sep';
tag_det_sep = 'Det_Sep';
tag_img_sep = 'Img_Sep';

children    = get(win_dw1dtoolX,'Children');
axe_handles = findobj(children,'flat','type','axes');
uic_handles = findobj(children,'flat','type','uicontrol');
fra_handles = findobj(uic_handles,'Style','frame');
txt_a_handles = findobj(axe_handles,'type','text');

switch option
    case 'view'
        % in3 = old_mode or ...
        % in3 = -1 : same mode
        % in3 =  0 : clean 
        %------------------------------------------------------
        [Wave_Name,Level_Anal,Signal_size] = ...
                wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,...
                               ind_wav_name,ind_lev_anal,ind_sig_size);
        old_mode = in3;

        [flg_axe,sa_flg,app_flg,sd_flg,det_flg] = ...
                                dw1dvmodX('get_vm',win_dw1dtoolX,3);
        cfs_flg = flg_axe(3);
        if flg_axe(1)==0 , sa_flg = [0 0]; end
        if flg_axe(2)==0 , sd_flg = [0 0]; end
        lev2    = Level_Anal+2;
        a_flg   = [app_flg , sa_flg];
        d_flg   = [det_flg , sd_flg , cfs_flg];
        vis_str = getonoffX([a_flg d_flg]);
        v_app   = vis_str(1:Level_Anal,:);
        v_s_a   = vis_str(Level_Anal+1,:);
        v_ss_a  = vis_str(lev2,:);
        v_det   = vis_str(lev2+1:lev2+Level_Anal,:);
        v_s_d   = vis_str(2*lev2-1,:);
        v_ss_d  = vis_str(2*lev2,:);
        v_cfs   = vis_str(2*lev2+1,:);

        [axe_left,axe_right,txt_left,txt_right,fra_sep,ind_left,ind_right] = ...
                                dw1dsepmX('axes',win_dw1dtoolX,a_flg,d_flg);

        axe_hdl = [axe_left(:)' axe_right(:)'];
        lin_handles = findobj(axe_hdl,'Type','line');
        img_handles = findobj(axe_hdl,'Type','image');
        s_app   = findobj(lin_handles,'Tag',tag_sa_sep);
        ss_app  = findobj(lin_handles,'Tag',tag_ssa_sep);
        app     = findobj(lin_handles,'Tag',tag_app_sep);
        s_det   = findobj(lin_handles,'Tag',tag_sd_sep);
        ss_det  = findobj(lin_handles,'Tag',tag_ssd_sep);
        det     = findobj(lin_handles,'Tag',tag_det_sep);
        img_cfs = findobj(img_handles,'Tag',tag_img_sep);

        xmax = Signal_size;

        ss_type = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_ssig_type);

        if sa_flg(1)==1
            if sa_flg(2)==1 , txt = ['s/' ss_type]; else txt = 's'; end
        else
            if sa_flg(2)==1 , txt = ss_type;        else txt = '';  end
        end
        set(txt_left(Level_Anal+1),'String',txt);
        if sd_flg(1)==1
            if sd_flg(2)==1 , txt = ['s/' ss_type]; else txt = 's'; end
        else
            if sd_flg(2)==1 , txt = ss_type;        else txt = '';  end
        end
        set(txt_right(Level_Anal+1),'String',txt);

        if isempty(s_app)
            [x,ymin,ymax] = dw1dfileX('sig',win_dw1dtoolX,1);
            col_s   = wtbutilsX('colors','sig');
            axe_act = axe_left(Level_Anal+1);
            line('Parent',axe_act,'Xdata',1:length(x),'Ydata',x,...
                 'Color',col_s,'Visible',v_s_a,'Tag',tag_sa_sep);
            set(axe_act,             ...
                    'XTicklabelMode','manual', ...
                    'XTickLabel',[],           ...
                    'Userdata',Level_Anal+1,   ...
                    'Ylim',[ymin ymax]         ...
                    );

            axe_act = axe_right(Level_Anal+1);
            line('Parent',axe_act,'Xdata',1:length(x),'Ydata',x,...
                 'Color',col_s,'Visible',v_s_d,'Tag',tag_sd_sep);
            set(axe_act,'Ylim',[ymin ymax])
        else
            set(s_app,'Visible',v_s_a);
            set(s_det,'Visible',v_s_d);
        end
        if isempty(ss_app)
            [x,ymin,ymax] = dw1dfileX('ssig',win_dw1dtoolX,1);
            col_ss  = wtbutilsX('colors','ssig');
            axe_act = axe_left(Level_Anal+1);
            ylim = get(axe_act,'Ylim');
            if ylim(1)<ymin , ymin = ylim(1); end
            if ylim(2)>ymax , ymax = ylim(2); end
            line('Parent',axe_act,'Xdata',1:length(x),'Ydata',x,...
                 'Color',col_ss,'Visible',v_ss_a,'Tag',tag_ssa_sep);
            set(axe_act, ...
                    'XTicklabelMode','manual', ...
                    'XTickLabel',[],           ...
                    'Userdata',Level_Anal+1,   ...
                    'Ylim',[ymin ymax]         ...
                    );

            axe_act = axe_right(Level_Anal+1);
            ylim = get(axe_act,'Ylim');
            if ylim(1)<ymin , ymin = ylim(1); end
            if ylim(2)>ymax , ymax = ylim(2); end
            line('Parent',axe_act,'Xdata',1:length(x),'Ydata',x,...
                 'Color',col_ss,'Visible',v_ss_d,'Tag',tag_ssd_sep);
            set(axe_act,'Ylim',[ymin ymax]);
        else
            set(ss_app,'Visible',v_ss_a);
            set(ss_det,'Visible',v_ss_d);
        end
        if isempty(app)
            [x,ymin,ymax] = dw1dfileX('app',win_dw1dtoolX,1:Level_Anal,3);
            app     = zeros(1,Level_Anal);
            col_app = wtbutilsX('colors','app',Level_Anal);
            for k = Level_Anal:-1:1
                axe_act = axe_left(k);
                app(k) = line('Parent',axe_act,      ...
                              'Xdata',1:size(x,2), ...
                              'Ydata',x(k,:),        ...
                              'Color',col_app(k,:),  ...
                              'Visible',v_app(k,:),  ...
                              'Tag',tag_app_sep,     ...
                              'Userdata',k           ...
                              );
                set(axe_act,'Ylim',[ymin(k) ymax(k)]);
            end
        else
            for k =1:Level_Anal , set(app(k),'Visible',v_app(k,:)); end
        end
        if isempty(det)
            [x,set_ylim,ymin,ymax] = ...
                    dw1dfileX('det',win_dw1dtoolX,1:Level_Anal,1);
            det     = zeros(1,Level_Anal);
            col_det = wtbutilsX('colors','det',Level_Anal);
            for k = Level_Anal:-1:1
                axes(axe_right(k));
                axe_act = axe_right(k);
                axes(axe_act);
                det(k)  = line( 'Parent',axe_act,       ...
                                'Xdata',1:size(x,2),  ...
                                'Ydata',x(k,:),         ...
                                'Color',col_det(k,:),   ...
                                'Visible',v_det(k,:),   ...
                                'Tag',tag_det_sep,      ...
                                'Userdata',k            ...
                                );
                if set_ylim(k)
                    set(axe_act,'Ylim',[ymin(k) ymax(k)]);
                end
            end
        else
            for k =1:Level_Anal , set(det(k),'Visible',v_det(k,:)); end
        end
        if ismember((Level_Anal+2),ind_right)
            yes_right = 1;
        else
            yes_right = 0;
        end

        ax_hdl = axe_right(Level_Anal+2);
        if yes_right
            [rep,ccfs_vm,levs,xlim,nb_cla] = ...                    
                    dw1dmiscX('tst_vm',win_dw1dtoolX,3,ax_hdl,det_flg);
            if rep==1 , delete(img_cfs); img_cfs = []; end
            if isempty(img_cfs)
                [x,xlim1,xlim2,ymax,ymin,nb_cla,levs,ccfs_vm] = ...
                                dw1dmiscX('col_cfs',win_dw1dtoolX,...
                                        ccfs_vm,1:Level_Anal,xlim,nb_cla);
                tag = get(ax_hdl,'Tag');
                image( ...
                    flipud(x),         ...
                    'Parent',ax_hdl,   ...
                    'Visible',v_cfs,   ...
                    'Tag',tag_img_sep, ...
                    'Userdata',        ...
                    [ccfs_vm,levs,xlim1,xlim2,nb_cla]...
                    );
                ylim = [0.5 Level_Anal+0.5];
                xlim = get(axe_left(Level_Anal+1),'Xlim');
                levlab  = flipud(int2str(levs(:)));
                set(ax_hdl,...
                    'YTicklabelMode','manual', ...
                    'YTick',1:length(levs),  ...
                    'YTickLabel',levlab,       ...
                    'Box','on',                ...
                    'Userdata',Level_Anal+2,   ...
                    'Xlim',xlim,               ...
                    'Ylim',ylim,               ...
                    'Layer','top',             ...
                    'Tag',tag                  ...
                    );
            else
                set(img_cfs,'Visible',v_cfs);           
            end
        else
            set(img_cfs,'Visible','off');   
        end

        opt_act = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_act_option);
        if strcmp(opt_act,'synt')
            ini_str = 'Orig. Synt. Sig.';
        else
            ini_str = 'Signal';
        end

        if     strcmp(ss_type,'ss') , str_ss = 'Synt.';
        elseif strcmp(ss_type,'ds') , str_ss = 'Deno.';
        elseif strcmp(ss_type,'cs') , str_ss = 'Comp.';
        end

        ind = (1:Level_Anal+1);
        if ~isempty(ind_left)
            m_l = ind_left(1);
            i_l = find(ind~=m_l);
            set(axe_left(m_l),'Userdata',m_l);
            for k = i_l
                ax = axe_left(k);
                set(ax,...
                       'XTicklabelMode','manual',...
                       'XTickLabel',[],          ...
                       'Userdata',k              ...
                       );
                delete(get(ax,'title'));
            end
            m_l = max(ind_left);
            if ~isempty(m_l)
                txt = '';                
                if sa_flg(1)==1 , txt = [txt ini_str]; end
                if sa_flg(2)==1
                    if ~isempty(txt) , s = ', '; else s = ''; end
                    txt  = [txt s str_ss ' Signal']; 
                end             
                if find(app_flg)
                    if ~isempty(txt) , s = ' and '; else s = ''; end
                    txt  = [txt s 'Approximation(s)']; 
                end 
                wtitleX(txt,'Parent',axe_left(m_l));
            end
            set(axe_left(ind_left(1)),'XTicklabelMode','auto');  
        end

        if ~isempty(ind_right)
            m_r = ind_right(1);
            i_r = find([ind Level_Anal+2]~=m_r);
            set(axe_right(m_r),'Userdata',m_r);
            for k = i_r
                ax = axe_right(k);
                set(ax, ...
                        'XTicklabelMode','manual',...
                        'XTickLabel',[],          ...
                        'Userdata',k              ...
                        );
                delete(get(ax,'title'));
            end
            m_r = max(ind_right);
            if ~isempty(m_r)
                txt = '';
                if find(cfs_flg) , txt  = [txt 'Coefs']; end
                if sd_flg(1)==1
                    if ~isempty(txt) , s = ', '; else s = ''; end
                    txt = [txt s ini_str];
                end
                if sd_flg(2)==1
                    if ~isempty(txt) , s = ', '; else s = ''; end
                    txt  = [txt s str_ss ' Signal'];
                end
                if find(det_flg)
                    if ~isempty(txt) , s = ' and '; else s = ''; end
                    txt  = [txt s 'Detail(s)'];
                end
                wtitleX(txt,'Parent',axe_right(m_r));
            end
            set(axe_right(ind_right(1)),'XTicklabelMode','auto');
        end

        % Axes attachment.
        %-----------------
        okNew = dw1dvdrvX('test_mode',win_dw1dtoolX,'sep',old_mode);
        if okNew
            set([axe_left(:)' axe_right(:)'],'Xlim',[1 xmax]);
            axe_cmd = [axe_left axe_right(1:end-1)];
            others  = axe_right(end);
            dynvtoolX('init',win_dw1dtoolX,[],[axe_cmd,others],[],[1 0], ...
                    '','','dw1dcoorX',[win_dw1dtoolX,others,Level_Anal]);
        end

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtoolX('wmb',win_dw1dtoolX,n_param_anal,ind_axe_ref,axe_left(1));

    case 'axes'
        % in3 = app flags (left)
        %   in3(1:Level_Anal)       = app flags
        %   in3(Level_Anal+1)       = s_app flag
        %   in3(Level_Anal+2)       = ss_app flag
        % in4 = det flags (right)
        %   in4(1:Level_Anal)       = det flags
        %   in4(Level_Anal+1)       = s_app flag
        %   in3(Level_Anal+2)       = ss_det flag
        %   in3(Level_Anal+3)       = cfs flag
        %------------------------------------------------------

        % Get Globals.
        %-------------
        Def_FraBkColor = mextglobX('get','Def_FraBkColor');

        % Getting  Analysis parameters.
        %------------------------------
        [Signal_Name,Signal_Size,Wave_Name,Level_Anal] =   ...
                wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,  ...
                               ind_sig_name,ind_sig_size,  ...
                               ind_wav_name,ind_lev_anal);
        
        % Getting miscellaneous parameters.
        %----------------------------------
        pos_graph = wmemtoolX('rmb',win_dw1dtoolX,n_miscella,ind_graph_area);

        a_flg = in3;
        d_flg = in4;
        nb_a_left  = sum(a_flg(1:Level_Anal))+ ...
                                max(a_flg(Level_Anal+1:Level_Anal+2));
        nb_a_right = sum(d_flg(1:Level_Anal))+ ...
                max(d_flg(Level_Anal+1:Level_Anal+2))+d_flg(Level_Anal+3);
        nb_a_l_tot = Level_Anal+1;
        nb_a_r_tot = Level_Anal+2;

        ind_left = find(a_flg(1:Level_Anal)==1);
        if a_flg(Level_Anal+1)==1 || a_flg(Level_Anal+2)==1
            ind_left = [ind_left Level_Anal+1];     
        end

        ind_right = find(d_flg(1:Level_Anal)==1);
        if d_flg(Level_Anal+1)==1 || d_flg(Level_Anal+2)==1
            ind_right = [ind_right Level_Anal+1];   
        end
        if d_flg(Level_Anal+3)==1
            ind_right = [ind_right Level_Anal+2];   
        end
        out6 = ind_left;
        out7 = ind_right;

        pos_win   = get(win_dw1dtoolX,'Position');
        win_units = get(win_dw1dtoolX,'Units');
        bdx = 0.1*pos_win(3);
        bdy = 0.05*pos_win(4);
        ecy = 0.02*pos_win(4);
        if nb_a_left*nb_a_right~=0
            w_left  = (pos_graph(3)-3*bdx)/2;
            x_left  = pos_graph(1)+1.1*bdx;
            w_right = w_left;
            x_right = x_left+w_left+bdx+bdx/5;
        elseif nb_a_left~=0
            w_left  = pos_graph(3)-2*bdx;
            x_left  = pos_graph(1)+1.2*bdx;
        elseif nb_a_right~=0
            w_right = pos_graph(3)-2*bdx;
            x_right = pos_graph(1)+bdx;
        end
        if nb_a_left~=0
            h_axe = (pos_graph(4)-2*bdy-(nb_a_left-1)*ecy)/nb_a_left;
            y_axe = pos_graph(2)+bdy;
            pos_a_left = [x_left y_axe w_left h_axe];
            pos_a_left = pos_a_left(ones(1,nb_a_left),:);
            for k=2:nb_a_left
                y_axe = y_axe+h_axe+ecy;
                pos_a_left(k,2) = y_axe;
            end
        end
        if nb_a_right~=0
            h_axe = (pos_graph(4)-2*bdy-(nb_a_right-1)*ecy)/nb_a_right;
            y_axe = pos_graph(2)+bdy;
            pos_a_right = [x_right y_axe w_right h_axe];
            pos_a_right = pos_a_right(ones(1,nb_a_right),:);
            for k=2:nb_a_right
                y_axe = y_axe+h_axe+ecy;
                pos_a_right(k,2) = y_axe;
            end
        end
        out1 = zeros(1,nb_a_l_tot);
        out3 = zeros(1,nb_a_l_tot);
        out2 = zeros(1,nb_a_r_tot);
        out4 = zeros(1,nb_a_r_tot);
        out1tmp = findobj(axe_handles,'flat','Tag',tag_a_l_sep);
        if ~isempty(out1tmp)
            out2tmp = findobj(axe_handles,'flat','Tag',tag_a_r_sep);
            out3tmp = findobj(txt_a_handles,'Tag',tag_t_l_sep);
            out4tmp = findobj(txt_a_handles,'Tag',tag_t_r_sep);
            for k = 1:nb_a_l_tot
                out1(k) = findobj(out1tmp,'flat','Userdata',k);
                out3(k) = findobj(out3tmp,'Userdata',k);
            end
            for k = 1:nb_a_r_tot
                out2(k) = findobj(out2tmp,'flat','Userdata',k);
                out4(k) = findobj(out4tmp,'Userdata',k);
            end
            out5 = findobj(fra_handles,'Tag',tag_fra_sep);
        else
            axeProp = {...
               'Parent',win_dw1dtoolX,...
               'Units',win_units,    ...
               'Visible','Off',      ...
               'Nextplot','add',     ...
               'DrawMode','Fast',    ...
               'Box','On'            ...
               };
            for k = 1:nb_a_l_tot
                if k~=1
                    axeProp = {axeProp{:}, ...
                               'XTicklabelMode','manual','XTickLabel',[]};
                end
                out1(k) = axes(axeProp{:},'Userdata',k,'Tag',tag_a_l_sep);
                if k==Level_Anal+1
                    txt_str = 's/ss';
                else
                    txt_str = ['a' wnsubstrX(k)];
                end
                out3(k) = txtinaxeX('create',txt_str,out1(k),'l','off','bold',20);
                set(out3(k),'Userdata',k,'Tag',tag_t_l_sep);
            end
            for k = 1:nb_a_r_tot
                if k~=1
                    axeProp = {axeProp{:}, ...
                               'XTicklabelMode','manual','XTickLabel',[]};
                end
                out2(k) = axes(axeProp{:},'Userdata',k,'Tag',tag_a_r_sep);
                if k==Level_Anal+2
                    txt_str  = 'cfs';
                    set(out2(k),'Ydir','reverse');
                elseif k==Level_Anal+1
                    txt_str = 's/ss';
                else
                    txt_str = ['d' wnsubstrX(k)];
                end
                out4(k) = txtinaxeX('create',txt_str,out2(k),'r','off','bold',20);
                set(out4(k),'Userdata',k,'Tag',tag_t_r_sep);
            end
            w_fra = 0.01*pos_win(3);
            x_fra = pos_graph(1)+(pos_graph(3)-w_fra)/2;
            y_fra = pos_graph(2);
            h_fra = pos_graph(4);
            out5  = uicontrol(...
                            'Parent',win_dw1dtoolX,                ...
                            'Style','frame',                      ...
                            'Unit',win_units,                     ...
                            'Position',[x_fra,y_fra,w_fra,h_fra], ...
                            'Visible','Off',                      ...
                            'Backgroundcolor',Def_FraBkColor,     ...
                            'Tag',tag_fra_sep                     ...
                            );
        end
        set(findobj([out1 out2]),'Visible','off');
        if nb_a_left*nb_a_right~=0
            set(out5,'Visible','On');
        else
            set(out5,'Visible','Off');
        end
        fontsize = wmachdepX('fontsize','normal',9,max(nb_a_right,nb_a_left));
        for k = 1:nb_a_left
            ind = ind_left(k);
            set(out1(ind),'Position',pos_a_left(k,:),'Visible','On');
            txtinaxeX('pos',out3(ind));
            set(out3(ind),'FontSize',fontsize,'Visible','on');
        end
        for k = 1:nb_a_right
            ind = ind_right(k);
            set(out2(ind),'Position',pos_a_right(k,:),'Visible','On');
            txtinaxeX('pos',out4(ind));
            set(out4(ind),'FontSize',fontsize,'Visible','on');
        end

    case 'del_ss'
        lin_handles = findobj(axe_handles,'Type','line');
        ss_app = findobj(lin_handles,'Tag',tag_ssa_sep);
        ss_det = findobj(lin_handles,'Tag',tag_ssd_sep);
        delete([ss_app ss_det]);

    case 'clear'
        dynvtoolX('stop',win_dw1dtoolX);
        out1 = findobj(axe_handles,'flat','Tag',tag_a_l_sep);
        out2 = findobj(axe_handles,'flat','Tag',tag_a_r_sep);
        out5 = findobj(fra_handles,'Tag',tag_fra_sep);
        delete([out1(:)' out2(:)' out5]);

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid Input Argument.');
end
        

