function out1 = wpssnodeX(option,win_wptool,in3,in4,in5,in6)
%WPSSNODE Plot wavelet packets synthesized node.
%   OUT1 = WPSSNODE(OPTION,WIN_WPTOOL,IN3,IN4,IN5,IN6)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 04-Aug-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
% $Revision: 1.1 $

% Image Coding Value.
%-------------------
codemat_v = wimgcodeX('get');

% Tag property of objects.
%-------------------------
tag_nodact    = 'Pop_NodAct';
tag_ss_node   = 'SS_Node';
tag_ss_obj    = 'SS_Obj';
tag_axe_t_lin = 'Axe_TreeLines';
tag_axe_pack  = 'Axe_Pack';

axe_handles   = findobj(get(win_wptool,'Children'),'flat','type','axes');
WP_Axe_Tree   = findobj(axe_handles,'flat','Tag',tag_axe_t_lin);
WP_Axe_Pack   = findobj(axe_handles,'flat','Tag',tag_axe_pack);
SS_text       = findobj(WP_Axe_Tree,'Tag',tag_ss_node);
SS_Obj        = findobj(WP_Axe_Pack,'Tag',tag_ss_obj);

% Miscellaneous Values.
%-------------------------
[txt_color,pack_color,ftn_size] = ...
        wtbutilsX('wputils','ss_node',get(WP_Axe_Tree,'Xcolor'));

switch option 
    case 'plot'
        % in3 = type ('cs' or 'ds')
        % in4 = dim
        % in5 = handle (line or image)
        % in6 = NB_Col (useful only  for dim = 2)
        %-----------------------------------------
        if (nargin<6) | isempty(in6) , in6 = 128; end
        axes(WP_Axe_Tree)
        if ~isempty(SS_Obj)
            delete(SS_Obj);
            hdl = get(WP_Axe_Pack,'title');
            col = get(WP_Axe_Pack,'Xcolor');
            set(hdl,'String','Node Action Result ','Color',col);
        end
        str_txt = ['(' in3 ')'];
        if isempty(SS_text)
            btndown_fcn  = [mfilename '(''cba'',' int2str(win_wptool) ...
                            ',' int2str(in4) ',' int2str(in6) ');'];
            SS_text = text(...
                           'Clipping','on',                ...
                           'String', str_txt,              ...
                           'Position',[0.25 0.1 0],        ...
                           'Color',txt_color,              ...
                           'HorizontalAlignment','center', ...
                           'VerticalAlignment','middle',   ...
                           'FontSize',ftn_size,            ...
                           'FontWeight','bold',            ...
                           'ButtonDownFcn',btndown_fcn,    ...
                           'Tag',tag_ss_node               ...
                           );
        else
            set(SS_text,'String', str_txt);
        end
        if in4==1
            set(SS_text,'UserData',get(in5,'Ydata'));
        elseif in4==2
            set(SS_text,'UserData',get(in5,'Cdata'));
        end

    case 'cba'
        pop_act = findobj(win_wptool,'Tag',tag_nodact);
        v       = get(pop_act,'Value');
        switch v
            case 1 , wpssnodeX('vis',win_wptool,in3,in4);
            case 6 , wpssnodeX('stat',win_wptool,in3);
        end

    case 'vis'
        % in3 = dim
        % in4 = NB_Col (useful only  for dim = 2)
        %---------------------------------------

        % Begin waiting.
        %--------------
        wwaitingX('msg',win_wptool,'Wait ... computing');

        dim     = in3;
        NB_Col  = in4;
        if isempty(NB_Col) , NB_Col = 128; end
        ssig_rec = get(SS_text,'UserData');
        siz      = size(ssig_rec);
        type_ss  = get(SS_text,'String');
        if findstr('cs',type_ss)
            str_txt = ['Compressed ']; 
        else
            str_txt = ['De-noised ']; 
        end
        delete(get(WP_Axe_Pack,'Children'));
        dynvtoolX('ini_his',win_wptool,1)
        % title_Color = pack_color;
        title_Color = mextglobX('get','Def_TxtColor');
        if dim==1
            str_txt = [str_txt 'Signal']; 
            xmax = max(siz);
            if xmax==1 , xmax = 1+0.01; end
            ymin = min(ssig_rec);   ymax = max(ssig_rec);
            if ymin==ymax , ymin = ymin-0.01; ymax = ymax+0.01; end
            plot(ssig_rec,'Parent',WP_Axe_Pack,...
                 'Color',pack_color,'tag',tag_ss_obj);
            set(WP_Axe_Pack,'XLim',[1 xmax],'Ylim',...
                    [ymin ymax],'Tag',tag_axe_pack);
            wtitleX(str_txt,'Parent',WP_Axe_Pack,...
                   'FontSize',ftn_size,'Color',title_Color);
        else
            str_txt = [str_txt 'Image']; 
            im = wimgcodeX('cod',0,ssig_rec,NB_Col,codemat_v);
            image('CData',im,'tag',tag_ss_obj,'Parent',WP_Axe_Pack);
            wtitleX(str_txt,'Parent',WP_Axe_Pack,...
                   'FontSize',ftn_size,'Color',title_Color);

            set(WP_Axe_Pack,'Tag',tag_axe_pack,    ...
                            'Layer','top',         ...
                            'XLim',[1 size(im,2)], ...
                            'Ylim',[1 size(im,1)], ...
                            'Ydir','Reverse'       ...
                            );
        end
        dynvtoolX('put',win_wptool)
        axes(WP_Axe_Tree);

        % End waiting.
        %-------------
        wwaitingX('off',win_wptool);

    case 'stat'
        dim = in3;
        type_ss = get(SS_text,'String');
        if findstr('cs',type_ss) , node = -1; else , node = -2; end
        switch dim
          case 1 , feval('wp1dstatX','create',win_wptool,node);
          case 2 , feval('wp2dstatX','create',win_wptool,node);
        end

    case 'r_synt'
        out1 = SS_text;

    case 'del'
        delete(SS_text);
        if ~isempty(SS_Obj)
            delete(SS_Obj);
            hdl = get(WP_Axe_Pack,'title');
            col = get(WP_Axe_Pack,'Xcolor');
            set(hdl,'String','Node Action Result ','Color',col);
        end
end
