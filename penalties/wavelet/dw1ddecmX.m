function [out1,out2] = dw1ddecmX(option,win_dw1dtoolX,in3,in4)
%DW1DDECM Discrete wavelet 1-D full decomposition mode manager.
%   [OUT1,OUT2] = DW1DDECM(OPTION,WIN_DW1DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 26-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
% ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
% ind_act_option = 6;
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
tag_declev    = 'Pop_DecLev';
% tag_txtdeclev = 'Txt_DecLev';
tag_axe_dec   = 'Axe_Dec';
tag_txt_dec   = 'Txt_Dec';
tag_s_dec     = 'S_dec';
tag_ss_dec    = 'SS_dec';
tag_a_dec     = 'A_dec';
tag_d_dec     = 'D_dec';

axe_handles   = findobj(get(win_dw1dtoolX,'Children'),'flat','Type','axes');
txt_a_handles = findobj(axe_handles,'Type','text');

switch option
    case 'ssig'
        % in3 = chk_handle
        %-----------------
        [flg_s_ss,ccfs] = dw1dvmodX('get_vm',win_dw1dtoolX,2);
        val = get(in3,'Value');
        flg_s_ss(2) = val; 
        dw1dvmodX('set_vm',win_dw1dtoolX,2,flg_s_ss,ccfs);
        ss_dec  = findobj(axe_handles,'Tag',tag_ss_dec);
        Level_Anal = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_lev_anal);
        num = Level_Anal+2;
        txt_dec = findobj(txt_a_handles,'Userdata',num,'Tag',tag_txt_dec);
        if val==0
            set(ss_dec,'Visible','off');
            set(txt_dec,'String','s');      
        else
            set(ss_dec,'Visible','on');
            ss_type = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_ssig_type);
            set(txt_dec,'String',['s/' ss_type]);   
        end

    case 'dec'
        wwaitingX('msg',win_dw1dtoolX,'Wait ... computing');
        pop_handles = findobj(win_dw1dtoolX,'Style','popupmenu');
        pop = findobj(pop_handles,'Tag',tag_declev);
        lev = get(pop,'Value');
        a_dec = findobj(axe_handles,'Type','line','tag',tag_a_dec);
        if ~isempty(a_dec) && lev~=get(a_dec,'Userdata')
            delete(a_dec); 
            a_dec = []; 
        end
        if isempty(a_dec) , dw1ddecmX('view',win_dw1dtoolX,-1,lev); end
        wwaitingX('off',win_dw1dtoolX);

    case 'view'
        % in3 = old_mode or ...
        % in3 = -1 : same mode
        % in3 =  0 : clean
        %---------------------------
        % in4 = level (optional)
        %---------------------------
        old_mode = in3;
        [Wave_Name,Level_Anal,Signal_Size] = ... 
                        wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,...
                                ind_wav_name,ind_lev_anal,ind_sig_size);
        if nargin==3 , level = Level_Anal; else level = in4; end
        v_flg   = dw1dvmodX('get_vm',win_dw1dtoolX,2);
        vis_str = getonoffX(v_flg);
        v_s     = vis_str(1,:);
        v_ss    = vis_str(2,:);

        [axe_hdl,txt_hdl] = dw1ddecmX('axes',win_dw1dtoolX,level);
        lin_handles = findobj(axe_hdl,'Type','line');
        s_dec  = findobj(lin_handles,'Tag',tag_s_dec);
        ss_dec = findobj(lin_handles,'Tag',tag_ss_dec);
        a_dec  = findobj(lin_handles,'Tag',tag_a_dec);
        d_dec  = findobj(lin_handles,'Tag',tag_d_dec);
        if ~isempty(a_dec)
            if level~=get(a_dec,'Userdata') , delete(a_dec); a_dec = []; end
        end
        for k = 1:length(d_dec)
            if get(d_dec(k),'Userdata')>level , d_dec(k) = -d_dec(k); end
        end
        if ~isempty(d_dec)
            inv_d = -d_dec(d_dec<0);
            if ~isempty(inv_d) , set(inv_d,'Visible','off'); end
        end

        % nb_axe = level+2;
        ind = [1:level,Level_Anal+1:Level_Anal+2];
        set([axe_hdl(ind) txt_hdl(ind)],'Visible','On');
        ind   = Level_Anal+2;
        axAct = axe_hdl(ind);
        ss_type = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_ssig_type);
        if v_flg(1)==1
            if v_flg(2)==1 , txt = ['s/' ss_type]; else txt = 's'; end
        else
            if v_flg(2)==1 , txt = ss_type;        else txt = '';  end
        end
        set(txt_hdl(ind),'String',txt);
        if isempty(s_dec)
            [x,ymin,ymax] = dw1dfileX('sig',win_dw1dtoolX,1);
            xmin = 1;  xmax = length(x);
            set(axe_hdl,'Xlim',[xmin xmax]);
            axes(axAct);
            col = wtbutilsX('colors','sig');
            line('Parent',axAct,'Xdata',1:length(x),'Ydata',x,...
                 'Color',col,'Visible',v_s,'Tag',tag_s_dec);
            set(axAct,'Ylim',[ymin ymax],'Userdata',ind,'Tag',tag_axe_dec);
        else
            set(s_dec,'Visible',v_s);
        end
        if isempty(ss_dec)
            [x,ymin,ymax] = dw1dfileX('ssig',win_dw1dtoolX,1);
            ylim = get(axAct,'Ylim');
            if ylim(1)<ymin , ymin = ylim(1); end
            if ylim(2)>ymax , ymax = ylim(2); end
            axes(axAct);
            col = wtbutilsX('colors','ssig');
            line('Parent',axAct,'Xdata',1:length(x),'Ydata',x,...
                    'Color',col,'Visible',v_ss,'Tag',tag_ss_dec);
            set(axAct,'Ylim',[ymin,ymax],'Userdata',ind,'Tag',tag_axe_dec);
        else
            set(ss_dec,'Visible',v_ss);
        end
        ind   = Level_Anal+1;
        axAct = axe_hdl(ind);
        if isempty(a_dec)
            [x,ymin,ymax] = dw1dfileX('app',win_dw1dtoolX,level,3);
            col_app = wtbutilsX('colors','app',Level_Anal);
            line(...
                 'Parent',axAct,       ...
                 'Xdata',1:length(x),  ...
                 'Ydata',x,            ...
                 'Color',col_app(level,:),...
                 'Userdata',level,'Tag',tag_a_dec);
            set(axAct,'Ylim',[ymin ymax],'Tag',tag_axe_dec);
        else
            set(a_dec,'Visible','on');
        end
        set(txt_hdl(ind),'String',['a' wnsubstrX(level)]);
        if isempty(d_dec)
            [x,set_ylim,ymin,ymax] = dw1dfileX('det',win_dw1dtoolX,1:Level_Anal,1);
            col_det = wtbutilsX('colors','det',Level_Anal);
            for k = Level_Anal:-1:1
                axe = axe_hdl(k);
                if k>level , vis = 'off'; else vis = 'on'; end
                line(...
                     'Parent',axe,         ...
                     'Xdata',1:size(x,2),  ...
                     'Ydata',x(k,:),       ...
                     'Color',col_det(k,:), ...
                     'Userdata',k,         ...
                     'Visible',vis,        ...
                     'Tag',tag_d_dec       ...
                     );
                prop = {'Userdata',k,'Tag',tag_axe_dec};
                if set_ylim ,  prop = {'Ylim',[ymin(k) ymax(k)],prop{:}}; end
                set(axe,prop{:});
            end
        else
            set(d_dec(1:level),'Visible','on');
        end
        set(axe_hdl(2:end),...
                'XTicklabelMode','manual', ...
                'XTickLabel',[]            ...
                );
        axeAct = axe_hdl(end);
        axes(axeAct);
        i_lev   = int2str(level);
        str_tit = sprintf('Decomposition at level %s : s = a%s', i_lev ,i_lev);
        for k =level:-1:1
            str_tit = [str_tit ' + d' int2str(k)]; %#ok<AGROW>
        end
        str_tit = [str_tit ' .'];
        wtitleX(str_tit,'Parent',axeAct);

        % Axes attachment.
        %-----------------
        okNew = dw1dvdrvX('test_mode',win_dw1dtoolX,'dec',old_mode);
        if okNew
            set(axe_hdl,'Xlim',[1 Signal_Size]);
            dynvtoolX('init',win_dw1dtoolX,[],axe_hdl,[],[1 0]);
        end

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtoolX('wmb',win_dw1dtoolX,n_param_anal,ind_axe_ref,axe_hdl(1));

    case 'axes'
        % in3 = level_view
        %-----------------
        Level_Anal = wmemtoolX('rmb',win_dw1dtoolX,n_param_anal,ind_lev_anal);
        if nargin==2 , in3 = Level_Anal; end

        % Axes Positions.
        %----------------
        pos_graph = wmemtoolX('rmb',win_dw1dtoolX,n_miscella,ind_graph_area);
        pos_win   = get(win_dw1dtoolX,'Position');
        win_units = get(win_dw1dtoolX,'Units');
        nb_axes_tot = Level_Anal+2;
        nb_axes = in3+2;
        [bdXLSPACE,bdXRSPACE] = mextglobX('get','bdXLSpacing','bdXRSpacing');
        bdxl = 1.5*bdXLSPACE*pos_win(3);
        bdxr = bdXRSPACE*pos_win(3);
        w_used  = pos_graph(3)-bdxl-bdxr;
        bdy = 0.05*pos_win(4);
        ecy = 0.02*pos_win(4);
        h_used = (pos_graph(4)-2*bdy-(nb_axes-1)*ecy)/nb_axes;
        pos_axe = [bdxl pos_graph(2)+bdy w_used h_used];
        pos_axe = pos_axe(ones(1,nb_axes),:);
        y_axe   = pos_axe(1,2);
        for k=2:nb_axes
            y_axe = y_axe+h_used+ecy;
            pos_axe(k,2) = y_axe;
        end
        out1 = zeros(1,nb_axes_tot);
        out2 = zeros(1,nb_axes_tot);
        out1tmp = findobj(axe_handles,'flat','Tag',tag_axe_dec);
        fontsize = wtbutilsX('dw1d_DEC_PREFS');
        if ~isempty(out1tmp)
            out2tmp = findobj(txt_a_handles,'Tag',tag_txt_dec);
            for k = 1:nb_axes_tot
                out1(k) = findobj(out1tmp,'flat','Userdata',k);
                out2(k) = findobj(out2tmp,'Userdata',k);
            end
            set([out1 out2],'Visible','off');
        else
            axeProp = {...
               'Parent',win_dw1dtoolX,...
               'Units',win_units,    ...
               'Visible','off',      ...
               'Nextplot','add',     ...
               'DrawMode','Fast',    ...
               'Box','On',           ...
               'Tag',tag_axe_dec     ...
               };
            for k = 1:nb_axes_tot
                if k~=1
                    axeProp = {axeProp{:}, ...
                               'XTicklabelMode','manual','XTickLabel',[]};
                end
                out1(k) = axes(axeProp{:},'Userdata',k);
                switch k
                  case nb_axes_tot ,   txt_str = 's/ss';                    
                  case nb_axes_tot-1 , txt_str = 'a';                    
                  otherwise ,          txt_str = ['d' wnsubstrX(k)];                   
                end
                out2(k) = txtinaxeX('create',...
                    txt_str,out1(k),'l','off','bold',fontsize);
                set(out2(k),'Userdata',k,'Tag',tag_txt_dec);
            end
        end
        for k = 1:nb_axes-2
            set(out1(k),'Position',pos_axe(k,:));
            txtinaxeX('pos',out2(k));
        end
        ind = nb_axes-2;
        for k = nb_axes_tot-1:nb_axes_tot
            ind = ind+1;
            set(out1(k),'Position',pos_axe(ind,:));
            txtinaxeX('pos',out2(k));
        end

    case 'del_ss'
        lin_handles = findobj(axe_handles,'Type','line');
        ss_sig      = findobj(lin_handles,'Tag',tag_ss_dec);
        delete(ss_sig);

    case 'clear'
        dynvtoolX('stop',win_dw1dtoolX);
        out1 = findobj(axe_handles,'flat','Tag',tag_axe_dec);
        delete(out1);
        
    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid Input Argument.');
end
        
