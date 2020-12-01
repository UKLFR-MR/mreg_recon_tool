function varargout = wguiutilsX(option,varargin)
%WGUIUTILS Utilities for various wavelet GUIs.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Apr-2005.
%   Last Revision: 28-Aug-2007.
%   Copyright 1995-2007 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

switch option
    %=====================================================================%
    % --- Executes during object creation, after setting all properties.  %
    %=====================================================================%
    case 'EdiPop_CreateFcn'
        hObject = varargin{1};
        def_UIBkCOL = get(0,'defaultUicontrolBackgroundColor');
        if ispc
            BKCOL = get(hObject,'BackgroundColor');
            if isequal(BKCOL,def_UIBkCOL)
                set(hObject,'BackgroundColor','white');
            end
        elseif strcmpi(get(hObject,'style'),'listbox')
            set(hObject,'BackgroundColor','white')
        else
            set(hObject,'BackgroundColor',def_UIBkCOL);
        end

    case 'Edi_Inact_CreateFcn'
        hObject = varargin{1};
        ediInActBkColor = mextglobX('get','Def_Edi_InActBkColor');
        set(hObject,'BackgroundColor',ediInActBkColor);

    case 'Sli_CreateFcn'
        hObject = varargin{1};
        def_UIBkCOL = get(0,'defaultUicontrolBackgroundColor');
        if isequal(get(hObject,'BackgroundColor'),def_UIBkCOL)
            sliBkCol = [.9 .9 .9];
        else
            sliBkCol = [.9 .9 .9];
        end
        set(hObject,'BackgroundColor',sliBkCol);
    %=====================================================================%
    %                END Create Functions                                 %
    %=====================================================================%
    
    case 'setAxesTitle'
        axe   = varargin{1};
        label = varargin{2};
        fontSize = mextglobX('get','Def_AxeFontSize');
        axes(axe);
        if iscell(label),
            for i=1:length(label), label{i} = xlate(label{i}); end
        else
            label = xlate(label);
        end
        varargout{1} = title(label,'Parent',axe,...
            'Color','k','FontWeight','normal','Fontsize',fontSize);
        if length(varargin)>2 , set(varargin{3},'Visible','Off'); end
        
    case 'setAxesXlabel'
        axe   = varargin{1};
        label = varargin{2};
        fontSize = mextglobX('get','Def_AxeFontSize');
        axes(axe);
        varargout{1} = xlabel(xlate(label),'Parent',axe, ...
            'Color','k','FontWeight','normal','Fontsize',fontSize);
        if length(varargin)>2 , set(varargin{3},'Visible','Off'); end
end
