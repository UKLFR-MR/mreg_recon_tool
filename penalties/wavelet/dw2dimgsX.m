function out1 = dw2dimgsX(option,in2,in3,in4)
%DW2DIMGS Discrete wavelet 2-D image selection.
%   OUT1 = DW2DIMGS(OPTION,IN2,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 24-Jan-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $

% Tag property of objects.
%-------------------------
tag_imgsel = 'Img_Select';
tag_imgdec = 'Img_Dec';

% Miscellaneous values.
%----------------------
if isequal(option,'get_img')
    win_dw2dtoolX = get(0,'CurrentFigure');
	SelectType = get(win_dw2dtoolX,'SelectionType');
	if ~isequal(SelectType,'normal') , return; end 
else
    win_dw2dtoolX = in2;
end
dw2d_PREFS = wtbutilsX('dw2d_PREFS');
Col_BoxAxeSel   = dw2d_PREFS.Col_BoxAxeSel;
Col_BoxTitleSel = dw2d_PREFS.Col_BoxTitleSel;
Wid_LineSel   = dw2d_PREFS.Wid_LineSel;

img_hdl = findobj(win_dw2dtoolX,'type','image');
switch option
    case 'get_img'
        sel_obj = get(win_dw2dtoolX,'currentobject');
        Img_Dec = findobj(img_hdl,'tag',tag_imgdec);
        obj_sel = findobj(img_hdl,'Tag',tag_imgsel);
        ind     = find(sel_obj==[Img_Dec;obj_sel],1);
        if ~isempty(ind)
            if ~isempty(obj_sel)
                set(obj_sel,'Tag',tag_imgdec);
                axe = get(obj_sel,'parent');
                set(axe,'Xcolor',Col_BoxAxeSel, ...
                        'Ycolor',Col_BoxAxeSel, ...
                        'LineWidth',0.5         ...
                        );
                col_lab = get(win_dw2dtoolX,'DefaultAxesXColor');
                set(get(axe,'xlabel'),'Color',col_lab);
                if obj_sel==sel_obj
                    if nargout>0 , out1 = []; end
                    return; 
                end
            end
            axe = get(sel_obj,'parent');
			axes(axe)
            set(axe,...
                    'Xcolor',Col_BoxTitleSel,   ...
                    'Ycolor',Col_BoxTitleSel,   ...
                    'LineWidth',Wid_LineSel,  ...
                    'Box','On'                  ...
                    );
            set(sel_obj,'Tag',tag_imgsel);
            if nargout>0 , out1 = sel_obj; end
        end

    case 'clean'
        obj_sel = findobj(img_hdl,'Tag',tag_imgsel);
        if ~isempty(obj_sel)
            set(obj_sel,'Tag',tag_imgdec);
            axe = get(obj_sel,'parent');
            set(axe,'Xcolor',Col_BoxAxeSel, ...
                    'Ycolor',Col_BoxAxeSel, ...
                    'LineWidth',0.5         ...
                    );
            col_lab = get(win_dw2dtoolX,'DefaultAxesXColor');
            set(get(axe,'xlabel'),'Color',col_lab);
            if nargout>0 , out1 = []; end
        end

    case 'cleanif'
        % for view_dec
        % in3 = new_lev_dec
        % in4 = old_lev_dec
        %----------------------------
        obj_sel = findobj(img_hdl,'Tag',tag_imgsel);
        if ~isempty(obj_sel)
            us = get(obj_sel,'Userdata');
            %---------------------------%
            %- us = [0;k;m]
            %- k = level ;
            %- m = 1 : v ; m = 2 : d ;             
            %- m = 3 : h ; m = 4 : a ;     
            %----------------------------%
            if (us(2)<=in3)
                if (in4>in3) || (us(3)<4) , return; end
            end
            set(obj_sel,'Tag',tag_imgdec);
            axe = get(obj_sel,'parent');
            set(axe,'Xcolor',Col_BoxAxeSel, ...
                    'Ycolor',Col_BoxAxeSel, ...
                    'LineWidth',0.5         ...
                    );
            col_lab = get(win_dw2dtoolX,'DefaultAxesXColor');
            set(get(axe,'xlabel'),'Color',col_lab);
        end

    case 'get'
        out1 = findobj(img_hdl,'Tag',tag_imgsel);

    otherwise
        errargtX(mfilename,'Unknown Option','msg');
        error('Wavelet:Invalid_ArgVal_Or_ArgType', ...
            'Invalid argument value.');
end
