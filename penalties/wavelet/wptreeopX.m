function out1 = wptreeopX(option,win_wptool,in3,in4)
%WPTREEOP Operations on wavelet packets tree.
%   OUT1 = WPTREEOP(OPTION,WIN_WPTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 03-Aug-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $

%==========================================================%
switch option
    case {'vis','split_merge','rec','select_on','stat'}
		mouseSelect = get(win_wptool,'SelectionType');
		if ~isequal(mouseSelect,'normal') , return; end
end
%==========================================================%

% MB2 (main window).
%-------------------
n_wp_utils = 'WP_Utils';
ind_tree_lin  = 1;
ind_tree_txt  = 2;
ind_type_txt  = 3;
ind_sel_nodes = 4;
% ind_gra_area  = 5;
ind_nb_colors = 6;
% nb2_stored    = 6;

% Tag property of objects.
%-------------------------
tag_pop_colm  = 'Txt_PopM';  % WP-1D only
tag_axe_t_lin = 'Axe_TreeLines';
tag_txt_in_t  = 'Txt_In_tree';
% tag_lin_in_t  = 'Lin_In_tree';
% tag_axe_sig   = 'Axe_Sig';
tag_axe_pack  = 'Axe_Pack';
tag_axe_cfs   = 'Axe_Cfs';
tag_curtree   = 'Pop_CurTree';
tag_nodlab    = 'Pop_NodLab';
tag_nodact    = 'Pop_NodAct';
tag_img_cfs   = 'Img_WPCfs';
tag_img_nod   = 'Img_NodCfs';

% Handles.
%---------
children    = get(win_wptool,'Children');
pop_handles = findobj(children,'flat','style','popupmenu');
axe_handles = findobj(children,'flat','type','axes');
WP_Axe_Tree = findobj(axe_handles,'flat','Tag',tag_axe_t_lin);
% WP_Axe_Sig  = findobj(axe_handles,'flat','Tag',tag_axe_sig);
WP_Axe_Pack = findobj(axe_handles,'flat','Tag',tag_axe_pack);
WP_Axe_Cfs  = findobj(axe_handles,'flat','Tag',tag_axe_cfs);

% Miscellaneous Values.
%-------------------------
[txt_color,sel_color,ftn_size] = ...
                wtbutilsX('wputils','tree_op',get(WP_Axe_Tree,'Xcolor'));
            
            
% To correct a warning on slider !! 
%----------------------------------
tag_sli_pos   = 'Sli_Pos';
WP_Sli_Pos =  findobj(children,'tag',tag_sli_pos);
mini = get(WP_Sli_Pos,'Min');
maxi = get(WP_Sli_Pos,'Max');
if mini<= maxi
    set(WP_Sli_Pos,'Min',mini-sqrt(eps),'Max',maxi);
end
%---------------------------------------------------------------
            
            
switch option
    case 'nodact'
        pop_nodact = findobj(pop_handles,'Tag',tag_nodact);
        v     = get(pop_nodact,'Value');
        old_v = get(pop_nodact,'Userdata');
        if isempty(old_v) , old_v = 0; end
        set(pop_nodact,'Userdata',v);
        if     any(v==(1:6)) && old_v==7  , ok = 1;
        elseif any(old_v==(1:6)) && v==7  , ok = 1;
        elseif old_v==7 && v==7
            if nargin==3
               if strcmp(in3,'reset')
                    set(pop_nodact,'Value',1);
                    set(pop_nodact,'Userdata',1);
                    v  = 1; ok = 1;
               else
                   return;
               end
            else
               return;
            end
        else
            ok = 0;
        end
        if ok
            WP_Tree = wtbxappdataX('get',win_wptool,'WP_Tree');
            order = treeordX(WP_Tree);
            img_handles = findobj(WP_Axe_Cfs,'tag',tag_img_cfs);
        end

        Tree_Texts = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_tree_txt);
        str_win    = sprintf('%.0f',win_wptool);
        switch v
            case 1
                btndown_fcn = [mfilename '(''vis'',' str_win ');'];

            case 2
                wptreeopX('select_off',win_wptool);
                btndown_fcn = [mfilename '(''split_merge'',' str_win ');'];

            case 3
                wptreeopX('select_off',win_wptool);
                btndown_fcn = [mfilename '(''rec'',' str_win ');'];

            case 4
                btndown_fcn = [mfilename '(''select_on'',' str_win ');'];

            case 5
                wptreeopX('select_off',win_wptool);
                set(pop_nodact,'Value',1);
                btndown_fcn = [mfilename '(''vis'',' str_win ');'];

            case 6
                btndown_fcn = [mfilename '(''stat'',' str_win ');'];

            case 7
                tn = tnodesX(WP_Tree);
                nbTT = length(Tree_Texts);
                nodes = false(1,nbTT);
                for k = 1:nbTT
                    us = get(Tree_Texts(k),'Userdata');
                    if ~isempty(us) && isempty(find(tn==us,1))
                        nodes(k) = true;
                    end
                end
                set(Tree_Texts(nodes),'Visible','off');
                btndown_fcn = ['wptreeopX(''colcfs'',' str_win ');'];
                set(img_handles,'Visible','off');
        end
        if any(v==(1:6)) && old_v==7
            if order==2
                delete(findobj(WP_Axe_Cfs,'tag',tag_img_nod));
                set(WP_Axe_Cfs,'Nextplot','replace');
            end
            set(Tree_Texts,'Visible','on');
            set(img_handles,'Visible','on');
            drawnow
            if order==2
                pop_colm = findobj(win_wptool,'style','popupmenu',...
                                'tag',tag_pop_colm);
                col_mode = get(pop_colm,'Value');
                if find(col_mode==[1 2 3 4])
                    strlab = 'frequency ordered coefficients';
                else
                    strlab = ...
                    '(down -> up) for Cfs <==> (left -> right) in Tree';
                end
                wsetxlabX(WP_Axe_Cfs,strlab);
            else
                wsetxlabX(WP_Axe_Cfs,'');
            end
        elseif any(old_v==(1:6)) && v==7
            wsetxlabX(WP_Axe_Cfs,'');
        end
        set(Tree_Texts,'ButtonDownFcn',btndown_fcn);
        return

    case 'nodlab'
        pop_nodlab = findobj(pop_handles,'Tag',tag_nodlab);
        pop_nodact = findobj(pop_handles,'Tag',tag_nodact);
        v_lab = get(pop_nodlab,'Value');
        v_act = get(pop_nodact,'Value');
        if v_act==7
            txt_in_tree = findobj(WP_Axe_Tree,'tag',tag_txt_in_t);
            txt_off     = findobj(txt_in_tree,'Visible','off');
        end
        Tree_Texts  = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_tree_txt);
        if v_lab==6
            set(Tree_Texts,'Visible','off'); return
        end
        switch v_lab
           case 1 , labtype = 'p';
           case 2 , labtype = 'i';
           case 3 , labtype = 'e';
           case 4 , labtype = 'eo';
           case 5 , labtype = 's';
           case 7 , labtype = 't';
           case 8 , labtype = 'en';               
        end
        wmemtoolX('wmb',win_wptool,n_wp_utils,ind_type_txt,labtype);
        WP_Tree = wtbxappdataX('get',win_wptool,'WP_Tree');
        nodes   = allnodesX(WP_Tree);
        labels  = tlabels(WP_Tree,labtype,nodes);
        for k=1:length(nodes)
            set(Tree_Texts(1+nodes(k)),'String',deblank(labels(k,:)));
        end
        set(Tree_Texts,'Visible','on');
        if v_act==7 , set(txt_off,'Visible','off'); end
        return

    case 'select_off'
        Selected_Nodes = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_sel_nodes);
        if ~isempty(Selected_Nodes)
            set(Selected_Nodes(2,:),'Color',txt_color);
            wmemtoolX('wmb',win_wptool,n_wp_utils,ind_sel_nodes,[]);
        end
        return

    case 'select_on'
        [obj,node] = findnode(win_wptool,WP_Axe_Tree);
        if isempty(obj) , return; end

        Selected_Nodes = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_sel_nodes);
        col = get(obj,'Color');
        if col==txt_color
            Selected_Nodes = [Selected_Nodes [node;obj]];
            set(obj,'Color',sel_color);
        else
            Selected_Nodes(:,Selected_Nodes(2,:)==obj) = [];
            set(obj,'Color',txt_color);
        end
        wmemtoolX('wmb',win_wptool,n_wp_utils,ind_sel_nodes,Selected_Nodes);
        return;

    case 'stat'
        [obj,node] = findnode(win_wptool,WP_Axe_Tree);
        if isempty(obj) , return; end

        set(wfindobjX('figure'),'Pointer','watch');
        WP_Tree = wtbxappdataX('get',win_wptool,'WP_Tree');
        order = treeordX(WP_Tree);
        if  order==2
            out1 = wp1dstatX('create',win_wptool,node);
        elseif  order==4
            out1 = wp2dstatX('create',win_wptool,node);
        end
        set(wfindobjX('figure'),'Pointer','arrow');
        return

    case 'colcfs'
        [obj,node] = findnode(win_wptool,WP_Axe_Tree);
        if isempty(obj) , return; end

        set(wfindobjX('figure'),'Pointer','watch');
        WP_Tree = wtbxappdataX('get',win_wptool,'WP_Tree');
        order = treeordX(WP_Tree);
        img_handles = findobj(WP_Axe_Cfs,'tag',tag_img_cfs);
        if order==2
            us = get(img_handles,'Userdata');
            tn = depo2indX(order,us(:,1:2));
            num_img = find(node==tn);
            set(img_handles,'Visible','off');
            if num_img~=0
                xd = get(img_handles,'xdata');
                nd = get(img_handles,'Cdata');
                NBrows = size(nd,1);
                y1 = us(num_img,3);
                y2 = us(num_img,4); 
                r1 = ceil(y1*NBrows)+1;
                r2 = floor(y2*NBrows);
                nd = nd(r1:r2,:);
                if r1==r2
                    ydata(1) = (y2+y1)/2;
                    ydata(2) = y2;
                else
                    alfa = 1/(2*(r2-r1+1));
                    ydata = [(1-alfa)*y1+alfa*y2 (1-alfa)*y2+alfa*y1];
                end
                set(WP_Axe_Cfs,'Nextplot','add');
                axes(WP_Axe_Cfs);
                delete(findobj(WP_Axe_Cfs,'tag',tag_img_nod));
                image('Parent',WP_Axe_Cfs, ...
                      'Xdata',xd,'Ydata',ydata, ...
                      'Cdata',nd,'tag',tag_img_nod ...
                      );
                strlab = ['Packet : (' sprintf('%.0f',us(num_img,1)) ',' ...
                           sprintf('%.0f',us(num_img,2)) ') or (' sprintf('%.0f',node) ')'];
                wsetxlabX(WP_Axe_Cfs,strlab);
                set(WP_Axe_Cfs,'Tag',tag_axe_cfs)
            end

        elseif order==4
            num_img = 0;
            for k=1:length(img_handles)
                us = get(img_handles(k),'Userdata');
                us = us(1:2);
                if node==depo2indX(order,us) , num_img = k; break; end
            end
            img_on = findobj(img_handles,'Visible','on');
            set(img_on,'Visible','off');
            if num_img~=0
                set(img_handles(num_img),'Visible','on');
                strlab = ['Packet : (' sprintf('%.0f',us(1)) ',' ...
                       sprintf('%.0f',us(2)) ') or (' sprintf('%.0f',node) ')'];
                wsetxlabX(WP_Axe_Cfs,strlab);
            end
        end
        set(wfindobjX('figure'),'Pointer','arrow');
        return

    case 'slide_size'
        % in3 = slider_size.
        % in4 = slider_pos.
        %--------------------
        v = get(in3,'Value');
        set(in3,'UserData',v);
        half = 1/((2*v)^(v/4));

        % Setting slider-pos properties.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if v>1
            old_bound = get(in4,'Max');
            old_val   = get(in4,'Value');
            new_bound = abs(0.5-half);
            if old_bound ~= 0
                new_val = -new_bound+(old_val+old_bound)*(new_bound/old_bound);
            else
                new_val = 0;
            end
            delta = 0;
            if new_val>new_bound-delta , new_val = new_bound-delta;
            elseif new_val<-new_bound+delta , new_val = -new_bound+delta;
            end
            set(in4,'Min',-new_bound,'Max',new_bound,...
                'Value',new_val,'Visible','on');
        else
            new_val = 0;
            set(in4,'Min',0,'Max',0,'Value',0,'Visible','off');
        end
        set(WP_Axe_Tree,'XLim',[new_val-half new_val+half]);
        return

    case 'slide_pos'
        % in3 = slider_pos.
        %------------------
        mVM = get(in3,{'min','val','max'});
        delta = 0; 
        OK = (mVM{2}>mVM{1}+delta) &&  (mVM{2}<mVM{3}-delta);
        if ~OK
            if mVM{2}<=mVM{1} , val = mVM{1}; else val = mVM{3}; end            
            set(in3,'Value',val,'Visible','On')
        end
        x0 = mVM{2};
        u  = get(WP_Axe_Tree,'XLim');
        demi_ecart = (u(2)-u(1))/2;
        set(WP_Axe_Tree,'XLim',[x0-demi_ecart x0+demi_ecart]);
        return

    case {'best','blvl','wp2wtree','restore','input_tree','cuttree'}
        % Begin waiting.
        %--------------
        wwaitingX('msg',win_wptool,'Wait ... computing');
        wptreeopX('select_off',win_wptool);
        if ~strcmp(option,'input_tree')
            WP_Tree = wtbxappdataX('get',win_wptool,'WP_Tree');
        else
            WP_Tree = in3;
        end
        switch option
            case 'best'
                WP_Tree = besttree(WP_Tree);
                Axe_TreeTitle = 'Best Tree';

            case 'blvl'
                WP_Tree = bestlevt(WP_Tree);
                Axe_TreeTitle = 'Best Level Tree';

            case 'wp2wtree'
                WP_Tree = wp2wtree(WP_Tree);
                Axe_TreeTitle = 'Wavelet Tree';

            case 'restore'
                WP_Tree = wtbxappdataX('get',win_wptool,'WP_Tree_Saved');
                Axe_TreeTitle = 'Decomposition Tree';

            case 'input_tree'
                Axe_TreeTitle = 'Decomposition Tree';

            case 'cuttree'
                % in3 = pop_hdl
                %--------------
                val = get(in3,'Value');
                lev = val-1;
                depth = treedpthX(WP_Tree);
                if lev==depth , wwaitingX('off',win_wptool); return; end

                [WP_Tree,n2m] = wpcutree(WP_Tree,lev);
                if isempty(n2m) , wwaitingX('off',win_wptool); return; end
                Axe_TreeTitle = 'Cut Tree';
        end


        depth = treedpthX(WP_Tree);
        str_depth = [];
        for k=0:depth , str_depth = [ str_depth ; sprintf('%2.0f',k) ]; end
        pop_cur = findobj(pop_handles,'Tag',tag_curtree);
        set(pop_cur,'String',str_depth,'Value',depth+1);

        xlab    = get(WP_Axe_Cfs,'xlabel');
        strxlab = get(xlab,'String');
        titl    = get(WP_Axe_Cfs,'title');
        strtitl = get(titl,'String');

        hdl_in_axes = [...
                        get(WP_Axe_Tree,'Children'); ...
                        get(WP_Axe_Cfs,'Children');  ...
                        get(WP_Axe_Pack,'Children')  ...
                        ];

        delete(hdl_in_axes); drawnow

        wmemtoolX('wmb',win_wptool,n_wp_utils,...
                       ind_tree_lin,[],ind_tree_txt,[]);
        wtbxappdataX('set',win_wptool,'WP_Tree',WP_Tree);           
        nb_col = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_nb_colors);
		axes(WP_Axe_Tree);
		wtitleX(Axe_TreeTitle,'Parent',WP_Axe_Tree);
		axes(WP_Axe_Pack);
		wtitleX('Node Action Result','Parent',WP_Axe_Pack);
		wpplottrX('first',win_wptool,WP_Tree);
		wptreeopX('nodlab',win_wptool);
		pop_nodact = findobj(pop_handles,'tag',tag_nodact);
		act = get(pop_nodact,'Value');
		wptreeopX('nodact',win_wptool,'reset');
		pop_colm = findobj(pop_handles,'tag',tag_pop_colm);
        col_mode = get(pop_colm,'Value');
        wpplotcf(WP_Tree,col_mode,WP_Axe_Cfs,nb_col);
        axes(WP_Axe_Cfs)
        wtitleX(strtitl,'Parent',WP_Axe_Cfs);
        order = treeordX(WP_Tree);
        if order==2
            if act==7
                xlab = get(WP_Axe_Cfs,'xlabel');
                strxlab = get(xlab,'String');
            end
            wsetxlabX(WP_Axe_Cfs,strxlab);
        end
        if ~strcmp(option,'input_tree') , dynvtoolX('get',win_wptool,0); end

        % End waiting.
        %-------------
        wwaitingX('off',win_wptool);
        return

    case {'vis','rec','split_merge'}
        [obj,node] = findnode(win_wptool,WP_Axe_Tree);
        if isempty(obj) , return; end

end

% Begin waiting.
%--------------
wwaitingX('msg',win_wptool,'Wait ... computing');

WP_Tree = wtbxappdataX('get',win_wptool,'WP_Tree');
if ~isempty(WP_Tree) , order = treeordX(WP_Tree); end
switch option
    case {'vis','rec'}
		[d,p] = ind2depoX(order,node);
        size0   = read(WP_Tree,'sizes',0);
        switch option
            case 'vis' , pack = wpcoef(WP_Tree,node);
            case 'rec' , pack = wprcoef(WP_Tree,node);
        end
        switch option
          case 'vis'
            flg_code = 1;
            trunc_p  = [d size0];
            str_pck  = [];

          case 'rec'
            if p==0 , flg_code = 0; else flg_code = 1; end
            trunc_p = [0 size0];
            str_pck = 'Reconstructed ';
        end
		str_pck	= [str_pck 'Packet : ('	sprintf('%.0f',d) ',' sprintf('%.0f',p)	...
				      ') or (' sprintf('%.0f',node) ')'];
		delete(get(WP_Axe_Pack,'Children'));
		dynvtoolX('ini_his',win_wptool,1)
		axes(WP_Axe_Pack)
		if order == 2
            xmax = length(pack);
		    if xmax==1, xmax = 1+0.01; end
		    ymin = min(pack);       ymax = max(pack);
			if abs(ymax-ymin)<sqrt(eps) , ymin = ymin-0.0001; ymax = ymax+0.0001; end
			if p==0
				if d==0 , colNAME = 'sig'; else colNAME = 'app'; end
			else
				colNAME = 'det';
			end
			color = wtbutilsX('colors',colNAME,1);
			plot(pack,'Color',color,'Parent',WP_Axe_Pack);
			set(WP_Axe_Pack,'XLim',[1 xmax],'Ylim',[ymin ymax],'Tag',tag_axe_pack);
			wtitleX(str_pck,...
				'FontSize',ftn_size,...
				'Color',get(WP_Axe_Tree,'Xcolor'),...
				'Parent',WP_Axe_Pack);
		else
			% Image Coding Value.
			%-------------------
			codemat_v = wimgcodeX('get'); 			
		    NB_Colors2D = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_nb_colors);
		    pack = wimgcodeX('cod',flg_code,pack,NB_Colors2D,codemat_v,trunc_p);
		    image('CData',pack,'Parent',WP_Axe_Pack);
		    wtitleX(str_pck,...
		           'FontSize',ftn_size,...
		           'Color',get(WP_Axe_Tree,'Xcolor'),...
		           'Parent',WP_Axe_Pack);
		    set(WP_Axe_Pack, ...
		           'Tag',tag_axe_pack,     ...
		           'Layer','top',            ...
		           'Ydir','Reverse',        ...
		           'XLim',[1 size(pack,2)] + 0.5*[-1 1],  ...
		           'Ylim',[1 size(pack,1)] + 0.5*[-1 1]   ...
		           );
		end
		dynvtoolX('put',win_wptool)
		axes(WP_Axe_Tree);

    case 'split_merge'
        pack_exist = istnodeX(WP_Tree,node);     
        if pack_exist == 0
            WP_Tree = nodejoin(WP_Tree,node);
            labels  = [];
        else
            WP_Tree = wpsplt(WP_Tree,node);
            child   = node*order+(1:order)';
            labtype = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_type_txt);
            labels  = tlabels(WP_Tree,labtype,child);
        end
        wtbxappdataX('set',win_wptool,'WP_Tree',WP_Tree);
        depth = treedpthX(WP_Tree);
        str_depth = [];
        for k=0:depth , str_depth = [ str_depth ; sprintf('%2.0f',k) ]; end
        pop_cur = findobj(pop_handles,'Tag',tag_curtree);
        set(pop_cur,'String',str_depth,'Value',depth+1);

        % Drawing New Tree.
        %------------------
        axes(WP_Axe_Tree);
        wtitleX('Decomposition Tree','Parent',WP_Axe_Tree);
        wpplottrX('split_merge',win_wptool,WP_Tree,node,labels);
        wptreeopX('cfs',win_wptool);

    case 'cfs'
        xlab    = get(WP_Axe_Cfs,'xlabel');
        strxlab = get(xlab,'String');
        titl    = get(WP_Axe_Cfs,'title');
        strtitl = get(titl,'String');
        delete(get(WP_Axe_Cfs,'Children'));
        nb_col   = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_nb_colors);
        pop_colm = findobj(pop_handles,'tag',tag_pop_colm);
        col_mode = get(pop_colm,'Value');
        wpplotcf(WP_Tree,col_mode,WP_Axe_Cfs,nb_col);
        wtitleX(strtitl,'Parent',WP_Axe_Cfs)
        if order==2 , wsetxlabX(WP_Axe_Cfs,strxlab); end

    case 'col_mode'	% option = 'col_mode' -- only for WP-1D
	% b_pop	= in3.
	%-------------
	colorMode = get(in3,'Value');
	user	= get(in3,'Userdata');
	if colorMode~=user
	    set(in3,'Userdata',colorMode);
	    titl    = get(WP_Axe_Cfs,'title');
	    strtitl = get(titl,'String');
	    delete(get(WP_Axe_Cfs,'Children'));
	    nb_col = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_nb_colors);
        wpplotcf(WP_Tree,colorMode,WP_Axe_Cfs,nb_col);
	    wtitleX(strtitl,'Parent',WP_Axe_Cfs)
	    if order==2
	        if find(colorMode==[1 2 3 4])
	            strxlab = 'frequency ordered coefficients';
	        else
	            strxlab = ...
	               '(down -> up) for Cfs <==> (left -> right) in Tree';
	        end
	        wsetxlabX(WP_Axe_Cfs,strxlab);
	    end
	end

    case 'recons'
        Selected_Nodes = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_sel_nodes);
        if isempty(Selected_Nodes) , wwaitingX('off',win_wptool); return; end

        nodes   = sort(Selected_Nodes(1,:));
        n2m     = [];
        un_sel  = [];
        ter_nod = [];
        k = 1;
        while k<=length(nodes)
            nod_sel = nodes(k);
            desc    = nodedescX(WP_Tree,nod_sel);
            desc    = desc(2:length(desc));
            if isempty(desc)
                ter_nod = [ter_nod nod_sel];
            else
                xind = wcommonX(nodes,desc);
                indx = find(xind);
                un_sel = [un_sel nodes(indx)];
                nodes(indx) = [];
                n2m = [n2m nod_sel];
            end
            k = k+1;
        end
        if ~isempty(un_sel)
            xind = wcommonX(Selected_Nodes(1,:),un_sel);
            indx = find(xind);
            set(Selected_Nodes(2,indx),'Color',txt_color);
            Selected_Nodes(:,indx) = [];
            wmemtoolX('wmb',win_wptool,n_wp_utils,...
                           ind_sel_nodes,Selected_Nodes);
        end

        Tree_Texts = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_tree_txt);
        set(Tree_Texts,'Visible','off');
        set(Selected_Nodes(2,:),'Visible','on');
        drawnow
        WP_Tree = nodejoin(WP_Tree,n2m);
        [order,tnods] = get(WP_Tree,'order','tn');
        sizes = read(WP_Tree,'tnsizes');
        xind = wcommonX(tnods,[ter_nod n2m]);
        indic = find(xind==0);
        for j = 1:length(indic)
            k = indic(j);
            WP_Tree = write(WP_Tree,'data',tnods(k),zeros(sizes(k,:)));
        end
        [WP_Tree,pack] = nodejoin(WP_Tree,0); %#ok<ASGLU>


        % Drawing Packet.
        %----------------
        nodes = (sort(Selected_Nodes(1,:)))';
        Tree_Type_TxtV = wmemtoolX('rmb',win_wptool,n_wp_utils,ind_type_txt);
        str_pck = 'Rec. Pack. : ';
        len     =  length(nodes);
        if strcmp(Tree_Type_TxtV,'i')
            ind = depo2indX(order,nodes);
            for k=1:len
                str_pck = [str_pck '(' sprintf('%.0f',ind(k)) ')'];
                if k<len , str_pck = [str_pck '+']; end
            end
        else
            [d,p] = ind2depoX(order,nodes);
            for k=1:len
                str_pck = [str_pck '(' sprintf('%.0f',d(k)) ',' ...
                                        sprintf('%.0f',p(k)), ')'];
                if k<len , str_pck = [str_pck '+']; end
            end
        end
        delete(get(WP_Axe_Pack,'Children'));
        dynvtoolX('ini_his',win_wptool,1)
        axes(WP_Axe_Pack)
        if order == 2
            xmax = length(pack);
            if xmax==1, xmax = 1+0.01; end
            ymin = min(pack); ymax = max(pack);
            if ymin==ymax , ymin = ymin-0.0001; ymax = ymax+0.0001; end
            color = wtbutilsX('colors','wp1d','recons');
            line(...
                'Xdata',1:length(pack),...
                'Ydata',pack,...
                'Color',color,...
                'Parent',WP_Axe_Pack);
            set(WP_Axe_Pack,'XLim',[1 xmax],'Ylim',[ymin ymax]);
            wtitleX(str_pck,...
                'FontSize',ftn_size,...
                'Parent',WP_Axe_Pack);
            
        else
			% Image Coding Value.
			%-------------------
			codemat_v = wimgcodeX('get');
			
            NB_Colors2D = ...
                    wmemtoolX('rmb',win_wptool,n_wp_utils,ind_nb_colors);
            image(...
                  'CData',wimgcodeX('cod',0,pack,NB_Colors2D,codemat_v),...
                  'Parent',WP_Axe_Pack);
            wtitleX(str_pck,...
                   'FontSize',ftn_size,...
                   'Color',get(WP_Axe_Tree,'Xcolor'),...
                   'Parent',WP_Axe_Pack);
		    set(WP_Axe_Pack, ...
		           'Tag',tag_axe_pack,     ...
		           'Layer','top',            ...
		           'Ydir','Reverse',        ...
		           'XLim',[1 size(pack,2)] + 0.5*[-1 1],  ...
		           'Ylim',[1 size(pack,1)] + 0.5*[-1 1]   ...
		           );
        end
        dynvtoolX('put',win_wptool)
        axes(WP_Axe_Tree);
        set(Tree_Texts,'Visible','on');
end

% End waiting.
%-------------
wwaitingX('off',win_wptool);


%------------------------------------------------
function [obj,node] = findnode(win,axe)

obj = get(win,'CurrentObject');
if ~isempty(obj)
   if ~isequal(get(obj,'Parent'),axe)
      obj = [];
   else
      node = get(obj,'UserData');
   end
end
%------------------------------------------------
