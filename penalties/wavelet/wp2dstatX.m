function varargout = wp2dstatX(option,varargin)
%WP2DSTAT Wavelet packets 2-D statistics.
%   VARARGOUT = WP2DSTAT(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 26-Aug-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_param_anal   = 'WP2D_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
% ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_img_size   = 6;
% ind_img_t_name = 7;
% ind_act_option = 8;
% ind_thr_val    = 9;
% nb1_stored     = 9;

% MB2.
%-----
n_wp_utils = 'WP_Utils';
% ind_tree_lin  = 1;
% ind_tree_txt  = 2;
ind_type_txt  = 3;
% ind_sel_nodes = 4;
% ind_gra_area  = 5;
ind_nb_colors = 6;
% nb2_stored    = 6;

% MB1 (Local Bloc).
%------------------
n_misc_loc = 'WPStat2D_Misc';
ind_curr_img   = 1;
ind_curr_color = 2;
nbLOC_1_stored = 2;

% Tag property of objects.
%-------------------------
tag_sel_cfs    = 'Sel_Cfs';
tag_sel_rec    = 'Sel_Rec';
tag_txt_bin    = 'Bins_Txt';
tag_edi_bin    = 'Bins_Data';
tag_ax_image   = 'Ax_Image';
tag_ax_hist    = 'Ax_Hist';
tag_ax_cumhist = 'Ax_Cumhist';
tag_pus_sta    = 'Show_Stat';

if ~isequal(option,'create') , win_stats = varargin{1}; end
switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Pop_Min_Width, ...
         X_Spacing,Y_Spacing,Def_EdiBkColor,Def_FraBkColor] =  ...
            mextglobX('get',...
                'Def_Txt_Height','Def_Btn_Height','Pop_Min_Width', ...
                'X_Spacing','Y_Spacing', 'Def_EdiBkColor','Def_FraBkColor');

        % Calling figure and node.
        %-------------------------
        win_caller     = varargin{1};
        node           = varargin{2};
        str_win_caller = sprintf('%.0f',win_caller);
        str_node       = sprintf('%.0f',node);

        % Window initialization.
        %----------------------
        win_name = 'Wavelet Packet 2-D  --  Statistics';
        [win_stats,pos_win,win_units,str_numwin,...
                pos_frame0,Pos_Graphic_Area] = ...
                    wfigmngrX('create',win_name,'','ExtFig_HistStat',mfilename,0);
        if nargout>0 , varargout{1} = win_stats; end

        % Begin waiting.
        %---------------
        set(wfindobjX('figure'),'Pointer','watch');

        % Getting variables from wp2dtoolX figure memory block.
        %-----------------------------------------------------
        WP_Tree = wtbxappdataX('get',win_caller,'WP_Tree');
        depth   = treedpthX(WP_Tree);

        [Img_Name,Img_Size,Wave_Name,Ent_Nam,Ent_Par] =           ...
                        wmemtoolX('rmb',win_caller,n_param_anal,   ...
                                       ind_img_name,ind_img_size, ...
                                       ind_wav_name,ind_ent_anal, ...
                                       ind_ent_par);

        % General parameters initialization.
        %-----------------------------------
        dx = X_Spacing;
        dy = Y_Spacing;  dy2 = 2*dy;
        d_txt = Def_Btn_Height-Def_Txt_Height;
        gra_width = Pos_Graphic_Area(3);
        push_width = (pos_frame0(3)-4*dx)/2;
        pop_width  = Pop_Min_Width;
        default_bins = 50;

        % Position property of objects.
        %------------------------------
        xlocINI     = pos_frame0([1 3]);
        ybottomINI  = pos_win(4)-3.5*Def_Btn_Height-dy2;
        ybottomENT  = ybottomINI-(Def_Btn_Height+dy2)-dy;
        y_low       = ybottomENT-4*Def_Btn_Height;
        px          = pos_frame0(1)+(pos_frame0(3)-5*push_width/4)/2;
        pos_sel_cfs = [px, y_low, 5*push_width/4, 3*Def_Btn_Height/2];
        y_low       = y_low-3*Def_Btn_Height;
        pos_sel_rec = [px, y_low, 5*push_width/4, 3*Def_Btn_Height/2];
        px          = pos_frame0(1)+(pos_frame0(3)-3*pop_width)/2;
        y_low       = y_low-3*Def_Btn_Height;
        pos_txt_bin = [px, y_low+d_txt/2, 2*pop_width, Def_Txt_Height];
        px          = pos_txt_bin(1)+pos_txt_bin(3)+dx;
        pos_edi_bin = [px, y_low, pop_width, Def_Btn_Height];
        px          = pos_frame0(1)+(pos_frame0(3)-3*push_width/2)/2;
        y_low       = pos_edi_bin(2)-3*Def_Btn_Height;
        pos_pus_sta = [px, y_low, 3*push_width/2, 2*Def_Btn_Height];

        % String property of objects.
        %----------------------------
        str_sel_cfs = 'Coefficients';
        str_sel_rec = 'Reconstructed';
        str_txt_bin = 'Number of bins';
        str_edi_bin = sprintf('%.0f',default_bins);
        str_pus_sta = 'Show statistics';

        % Command part construction of the window.
        %-----------------------------------------
        utanaparX('create_copy',win_stats, ...
                 {'xloc',xlocINI,'bottom',ybottomINI},...
                 {'n_s',{Img_Name,Img_Size},'wav',Wave_Name,'lev',depth} ...
                 );

        utentparX('create_copy',win_stats, ...
                 {'xloc',xlocINI,'bottom',ybottomENT,...
                  'ent',{Ent_Nam,Ent_Par}} ...
                 );

             rad_cfs = uicontrol('Parent',win_stats,...
                 'Style','Radiobutton',...
                 'Unit',win_units,...
                 'Position',pos_sel_cfs,...
                 'String',str_sel_cfs,...
                 'Tag',tag_sel_cfs,...
                 'Userdata',0,...
                 'Value',0);

             rad_rec = uicontrol('Parent',win_stats,...
                 'Style','Radiobutton',...
                 'Unit',win_units,...
                 'Position',pos_sel_rec,...
                 'String',str_sel_rec,...
                 'Tag',tag_sel_rec,...
                 'Userdata',1,...
                 'Value',1);

             uicontrol('Parent',win_stats,...
                 'Style','text',...
                 'Unit',win_units,...
                 'Position',pos_txt_bin,...
                 'String',str_txt_bin,...
                 'Backgroundcolor',Def_FraBkColor,...
                 'Tag',tag_txt_bin...
                 );

             edi_bin = uicontrol('Parent',win_stats,...
                 'Style','Edit',...
                 'Units',win_units,...
                 'Position',pos_edi_bin,...
                 'String',str_edi_bin,...
                 'Backgroundcolor',Def_EdiBkColor,...
                 'Tag',tag_edi_bin...
                 );

             pus_sta = uicontrol('Parent',win_stats,...
                 'Style','Pushbutton',...
                 'Unit',win_units,...
                 'Position',pos_pus_sta,...
                 'String',xlate(str_pus_sta),...
                 'Userdata',[],...
                 'Tag',tag_pus_sta...
                 );

        % Frame Stats. construction.
        %---------------------------
        [infos_hdls,h_frame1] = utstatsX('create',win_stats,...
                                        'xloc',Pos_Graphic_Area([1,3]), ...
                                        'bottom',dy2);

        % Callbacks update.
        %------------------
        str_infos_hdls  = num2mstrX(infos_hdls);
        str_rad_rec = num2mstrX(rad_rec);
        str_rad_cfs = num2mstrX(rad_cfs);
        str_edi_bin = num2mstrX(edi_bin);
        cba_sel_rec = [mfilename '(''select'',' ...
            str_numwin ',' ...
            str_rad_rec ',' ...
            str_infos_hdls ...
            ');'];
        cba_sel_cfs = [mfilename '(''select'',' ...
            str_numwin ',' ...
            str_rad_cfs ',' ...
            str_infos_hdls ...
            ');'];
        cba_edi_bin = [mfilename '(''update_bins'',' ...
            str_numwin ',' ...
            str_edi_bin ',' ...
            str_infos_hdls ...
            ');'];
        cba_pus_sta = [mfilename '(''draw'',' ...
            str_numwin ',' ...
            str_win_caller ',' ...
            str_infos_hdls ',' ...
            str_node ...
            ');'];

        set(rad_rec,'Callback',cba_sel_rec);
        set(rad_cfs,'Callback',cba_sel_cfs);
        set(edi_bin,'Callback',cba_edi_bin);
        set(pus_sta,'Callback',cba_pus_sta);

        % Axes construction.
        %-------------------
        xspace     = gra_width/10;
        yspace     = pos_frame0(4)/10;
        axe_height = (pos_frame0(4)-Def_Btn_Height-h_frame1-4*dy)/2-yspace;
        axe_width  = gra_width-2*xspace;
        half_width = axe_width/2-xspace/2;
        cx         = gra_width/2;
        cy         = h_frame1+2*dy2+axe_height+4*yspace/3+axe_height/2;
        [w_used,h_used] = wpropimgX(Img_Size,axe_width,axe_height,'pixels');
        pos_ax_image    = [cx-w_used/2,cy-h_used/2,w_used,h_used];
        pos_ax_hist     = [xspace h_frame1+2*dy2+yspace/3 ...
                                 half_width axe_height];
        pos_ax_cumhist  = [2*xspace+half_width h_frame1+2*dy2+yspace/3 ...
                                 half_width axe_height];

        commonProp = {...
           'Parent',win_stats,...
           'Units',win_units,...
           'Visible','Off',...
           'box','on',...
           'NextPlot','Replace',...
           'Drawmode','fast'...
           };
        axes(commonProp{:},'Position',pos_ax_image,'Tag',tag_ax_image);
        axes(commonProp{:},'Position',pos_ax_hist,'Tag',tag_ax_hist);
        axes(commonProp{:},'Position',pos_ax_cumhist,'Tag',tag_ax_cumhist);
        drawnow

        % Displaying the window title.
        %-----------------------------
        str_par = utentparX('get',win_stats,'txt');
        if ~isempty(str_par)
            str_par = [' (' lower(str_par) ' = ',num2str(Ent_Par),')'];
        end
        str_nb_val   = [' (' sprintf('%.0f',Img_Size(1)) ' x ' ...
                sprintf('%.0f',Img_Size(2)) ')'];
        str_wintitle = [Img_Name,str_nb_val,' analyzed at level ',...
                sprintf('%.0f',depth),' with ',Wave_Name,...
                        ' and ''',Ent_Nam,''' entropy',str_par];
        wfigtitlX('string',win_stats,str_wintitle,'off');

        % Setting units to normalized.
        %-----------------------------
        wfigmngrX('normalize',win_stats);

        % Computing statistics for the node.
        %-----------------------------------
		wp2dstatX('draw',win_stats,win_caller,infos_hdls,node);

        % End waiting.
        %-------------
        set(wfindobjX('figure'),'Pointer','arrow');

    case 'select'
        %***********************************************%
        %** OPTION = 'select' - SIGNAL TYPE SELECTION **%
        %***********************************************%
        sel_rad_btn = varargin{2};
        infos_hdls  = varargin{3};

        % Set to the current selection.
        %------------------------------
        children    = get(win_stats,'Children');
        rad_handles = findobj(children,'Style','radiobutton');
        old_rad     = findobj(rad_handles,'Userdata',1);
        set(rad_handles,'Value',0,'Userdata',0);
        set(sel_rad_btn,'Value',1,'Userdata',1)
        if old_rad==sel_rad_btn , return; end

        % Reset all.
        %-----------
        set(infos_hdls,'Visible','off');
        axe_handles = findobj(children,'flat','type','axes');
        axe_image   = findobj(axe_handles,'flat','Tag',tag_ax_image);
        axe_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);
        set(findobj([axe_image,axe_hist,axe_cumhist]),'visible','off');
        drawnow

    case 'draw'
        %*********************************%
        %** OPTION = 'draw' - DRAW AXES **%
        %*********************************%
        win_caller = varargin{2};
        infos_hdls = varargin{3};
        node       = varargin{4};

        % Handles of tagged objects.
        %---------------------------
        children    = get(win_stats,'Children');
        axe_handles = findobj(children,'flat','Type','axes');
        uic_handles = findobj(children,'flat','Type','uicontrol');
        pus_sta     = findobj(uic_handles,'Style','pushbutton','Tag',tag_pus_sta);
        axe_image   = findobj(axe_handles,'flat','Tag',tag_ax_image);
        axe_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);
        rad_handles = findobj(uic_handles,'Style','radiobutton');
        edi_handles = findobj(uic_handles,'Style','edit');
        rad_cfs     = findobj(rad_handles,'Tag',tag_sel_cfs);
        edi_bin     = findobj(edi_handles,'Tag',tag_edi_bin);

        % Main parameters selection before drawing.
        %------------------------------------------
        sel_cfs = (get(rad_cfs,'Value')~=0);

        % Check the bins number.
        %-----------------------
        default_bins = 50;
        old_params   = get(pus_sta,'Userdata');
        if ~isempty(old_params) , default_bins = old_params(1); end
        nb_bins = wstr2numX(get(edi_bin,'String'));
        if isempty(nb_bins) || (nb_bins<2)
            nb_bins = default_bins;   
            set(edi_bin,'String',sprintf('%.0f',default_bins))
        end
        new_params = [nb_bins sel_cfs node];
        if ~isempty(old_params) && (isequal(new_params,old_params))
            vis = get(axe_hist,'Visible');
            if isequal(vis(1:2),'on'), return, end
        end

        % Deseable new selection.
        %-------------------------
        set([edi_bin;rad_handles],'Enable','off');

        % Updating parameters.
        %--------------------- 
        set(pus_sta,'Userdata',new_params);

        % Show the status line.
        %----------------------
        wfigtitlX('vis',win_stats,'on');

        % Cleaning the graphical part.
        %-----------------------------
        set(infos_hdls,'Visible','off');

        % Waiting message.
        %-----------------
        wwaitingX('msg',win_stats,'Wait ... computing');

        % Cleaning the graphical part continuing.
        %----------------------------------------
        set(findobj([axe_image,axe_hist,axe_cumhist]),'visible','off');
        drawnow

        % Parameters initialization.
        %---------------------------
        NB_ColorsInPal = wmemtoolX('rmb',win_caller,n_wp_utils,ind_nb_colors);
        flg_code = 0;
        if node>-1
            WP_Tree = wtbxappdataX('get',win_caller,'WP_Tree');
            order = treeordX(WP_Tree);
            depth = treedpthX(WP_Tree);            

            % Current image construction.
            %----------------------------
            if sel_cfs
                curr_img = wpcoef(WP_Tree,node);
                str_title= 'Coefficients of ';
            else
                curr_img = wprcoef(WP_Tree,node);
                str_title= 'Reconstructed ';
            end
            size_img = size(curr_img);
            if size_img(1)<3 || size_img(2)<3
                wwarndlgX(['          Not enough coefficients ' ...
                        'remaining at level ' ...
                        sprintf('%.0f',depth)],...
                        'Wavelet Packet 2-D -- Statistics','modal');
                wwaitingX('off',win_stats);
                return;
            end
            Tree_Type_TxtV  = wmemtoolX('rmb',win_caller,n_wp_utils,...
                                             ind_type_txt);
            [level,pos]     = ind2depoX(order,node);
            if strcmp(Tree_Type_TxtV,'i')
                ind     = depo2indX(order,node);
                str_pck = ['Packet ('  sprintf('%.0f',ind) ')'];
            else
                str_pck = ['Packet (' sprintf('%.0f',level) ','  ...
                                      sprintf('%.0f',pos), ')'];
            end
            if pos==0
                if level==0
                    curr_color = wtbutilsX('colors','sig');
                    str_title  = [str_title str_pck ' ===> Original image'];
                else
                    col_app    = wtbutilsX('colors','app',depth);
                    curr_color = col_app(level,:);
                    str_title  = [str_title str_pck ...
                                  ' ===> Approximation at level '...
                                       sprintf('%.0f',level)];
                end
                if sel_cfs , flg_code = 1; end
            else
                col_det    = wtbutilsX('colors','det',depth);
                curr_color = col_det(level,:);
                str_title  = [str_title str_pck];
                flg_code   = 1;
            end
        else
            curr_img = get(wpssnodeX('r_synt',win_caller),'Userdata');
            curr_color = wtbutilsX('colors','wp2d','hist');
            if node==-1
                str_title = 'Compressed Image';
            elseif node==-2
                str_title = 'De-noised Image';
            end
        end

        % Displaying the image.
        %=====================
		% Image Coding Value.
		%-------------------
		codemat_v = wimgcodeX('get',win_caller);
        set(win_stats,'Colormap',get(win_caller,'Colormap'));
        axes(axe_image);
        image(wimgcodeX('cod',flg_code,curr_img,NB_ColorsInPal,codemat_v),...
                'Parent',axe_image);
        set(axe_image,'Tag',tag_ax_image);
        wtitleX(str_title,'Parent',axe_image);
        drawnow;

        % Check the bins number.
        %-----------------------
        nb_bins = wstr2numX(get(edi_bin,'String'));
        if isempty(nb_bins) || (nb_bins<2)
            nb_bins = default_bins;
            set(edi_bin,'String',sprintf('%.0f',default_bins))
        end

        % Displaying histogram.
        %----------------------
        his       = wgethistX(curr_img(:),nb_bins);
        [xx,imod] = max(his(2,:)); %#ok<ASGLU>
        mode_val  = (his(1,imod)+his(1,imod+1))/2;
        his(2,:)  = his(2,:)/length(curr_img(:));
        axes(axe_hist);
        wplothisX(axe_hist,his,curr_color);
        wtitleX('Histogram','Parent',axe_hist);

        % Displaying cumulated histogram.
        %--------------------------------
        for i=6:4:length(his(2,:));
            his(2,i)   = his(2,i)+his(2,i-4);
            his(2,i+1) = his(2,i);
        end
        axes(axe_cumhist);
        wplothisX(axe_cumhist,[his(1,:);his(2,:)],curr_color);
        wtitleX('Cumulative histogram','Parent',axe_cumhist);
        drawnow;

        % Displaying statistics.
        %-----------------------
        cur_VAL = curr_img(:);
        mean_val  = mean(cur_VAL);
        max_val   = max(cur_VAL);
        min_val   = min(cur_VAL);
        range_val = max_val-min_val;
        std_val   = std(cur_VAL);
        med_val   = median(cur_VAL);
        abs_med    = median(abs(cur_VAL-med_val));
        abs_mean   = mean(abs(cur_VAL-mean_val));
        L1_val    = norm(cur_VAL,1);
        L2_val    = norm(cur_VAL,2);
        LM_val    = norm(cur_VAL,Inf);        
        utstatsX('display',win_stats, ...
            [mean_val; med_val ; mode_val;  ...
             max_val ; min_val ; range_val; ...
             std_val ; abs_med ; abs_mean;  ...
             L1_val ; L2_val ; LM_val]);

        % Memory blocks update.
        %----------------------
        wmemtoolX('ini',win_stats,n_misc_loc,nbLOC_1_stored);
        wmemtoolX('wmb',win_stats,n_misc_loc, ...
                       ind_curr_img,curr_img(:), ...
                       ind_curr_color,curr_color ...
                       );

        % End waiting.
        %-------------
        wwaitingX('off',win_stats);

        % Setting infos visible.
        %-----------------------
        set(infos_hdls,'Visible','on');

        % Enable new selection.
        %-------------------------
        set([edi_bin;rad_handles],'Enable','on');

    case 'update_bins'
        %**************************************************************%
        %** OPTION = 'update_bins' - UPDATE HISTOGRAMS WITH NEW BINS **%
        %**************************************************************%
        edi_bin = varargin{2};
        infos_hdls    = varargin{3};

        % Handles of tagged objects.
        %---------------------------
        children    = get(win_stats,'Children');
        axe_handles = findobj(children,'flat','type','axes');
        uic_handles = findobj(children,'flat','type','uicontrol')  ;
        pus_sta = findobj(uic_handles,...
                                        'Style','pushbutton',...
                                        'Tag',tag_pus_sta...
                                        );
        axe_hist    = findobj(axe_handles,'flat','Tag',tag_ax_hist);
        axe_cumhist = findobj(axe_handles,'flat','Tag',tag_ax_cumhist);

        % Return if no current display.
        %------------------------------
        vis = get(axe_hist,'Visible');
        if isequal(vis(1:2),'of'), return, end

        % Check the bins number.
        %-----------------------
        default_bins = 50;
        old_params   = get(pus_sta,'Userdata');
        if ~isempty(old_params)
            default_bins = old_params(1);
        end
        nb_bins = wstr2numX(get(edi_bin,'String'));
        if isempty(nb_bins) || (nb_bins<2)
            nb_bins = default_bins;
            set(edi_bin,'String',sprintf('%.0f',default_bins))
        end
        if default_bins==nb_bins , return; end

        % Waiting message.
        %-----------------
        set(infos_hdls,'Visible','off');
        wwaitingX('msg',win_stats,'Wait ... computing');

        % Getting memory blocks.
        %-----------------------
        [curr_img,curr_color] = wmemtoolX('rmb',win_stats,n_misc_loc,...
                                               ind_curr_img,...
                                               ind_curr_color);

        % Updating histograms.
        %---------------------
        if ~isempty(curr_img)
            old_params(1) = nb_bins;
            set(pus_sta,'Userdata',old_params);
            his      = wgethistX(curr_img,nb_bins);
            his(2,:) = his(2,:)/length(curr_img);
            axes(axe_hist);
            wplothisX(axe_hist,his,curr_color);
            wtitleX('Histogram','Parent',axe_hist);

            for i=6:4:length(his(2,:));
                his(2,i)   = his(2,i)+his(2,i-4);
                his(2,i+1) = his(2,i);
            end
            axes(axe_cumhist);
            wplothisX(axe_cumhist,[his(1,:);his(2,:)],curr_color);
            wtitleX('Cumulative histogram','Parent',axe_cumhist);
        end

        % End waiting.
        %-------------
        wwaitingX('off',win_stats);
        set(infos_hdls,'Visible','on');

    case 'demo'
        %****************************************%
        %** OPTION = 'demo' -  DEMOS or TESTS  **%
        %****************************************%
        pus_sta = findobj(win_stats,'Style','pushbutton','Tag',tag_pus_sta);
        eval(get(pus_sta,'Callback'));

    case 'close'

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid argument value.');
end
