function varargout = wavemenuX(varargin)
% WAVEMENU Start the Wavelet Toolbox graphical user interface tools.
%    WAVEMENU launches a menu for accessing the various 
%    graphical tools provided in the Wavelet Toolbox.
%
%    In addition, WAVEMENU(COLOR) let you choose the color
%    preferences. Available values for COLOR are:
%        'k', 'w' , 'y' , 'r' , 'g', 'b' , 'std' (or 's')
%        and 'default' (or 'd').
%
%    WAVEMENU is equivalent to WAVEMENU('default')

% Last Modified by GUIDE v2.5 20-Jan-2006 14:17:25
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 29-Aug-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $


%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wavemenuX_OpeningFcn, ...
                   'gui_OutputFcn',  @wavemenuX_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
%----------------- Begin solution for G575274 --------------------%
A = wtbxmngrX('is_on');
F = wfindobjX('type','figure');
if A
    OK = isempty(F);
    if ~OK
        OK = true;
        for k = 1:length(F)
            if isequal('wavemenuX_Win',get(F(k),'tag'));
                OK = false;
                break
            end
        end
    end
    if OK
        if isappdata(0,'Def_WGlob_Struct'),rmappdata(0,'Def_WGlob_Struct'); end
        if isappdata(0,'Wavelets_Info'),rmappdata(0,'Wavelets_Info'); end 
        if isappdata(0,'WTBX_Glob_Info'),rmappdata(0,'WTBX_Glob_Info'); end 
        if isappdata(0,'DWT_Attribute'),rmappdata(0,'DWT_Attribute'); end 
    end
end
%----------------- End of solution for G575274 -------------------%
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%*************************************************************************%
%                END initialization code - DO NOT EDIT                    %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Opening Function                                   %
%                ----------------------                                   %
% --- Executes just before wavemenuX is made visible.                      %
%*************************************************************************%
function wavemenuX_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wavemenuX (see VARARGIN)

% Choose default command line output for wavemenuX
handles.output = hObject;
set(hObject,'WindowStyle','normal');

% Update handles structure
guidata(hObject, handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manually in the automatic generated code %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles,varargin{:});

% Force translations because of g290327,318823.
hall = findobj(hObject, 'type','uicontrol');
for indx = 1:length(hall)
    set(hall(indx), 'String', xlate(get(hall(indx), 'String')));
    set(hall(indx), 'TooltipString', xlate(get(hall(indx), 'TooltipString')));
end

%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = wavemenuX_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;
%*************************************************************************%
%                END Output Function                                      %
%*************************************************************************%


%=========================================================================%
%                BEGIN Callback Functions                                 %
%                ------------------------                                 %
%=========================================================================%
%-------------------------------------------------------------------
function Pus_Btn_CreateFcn(hObject,eventdata,handles) %#ok<INUSD,DEFNU>
% if isunix
%     bkColor = mextglobX('get','Def_UICBkColor');
%     set(hObject,bkColor);
% end
%-------------------------------------------------------------------
function Pus_TOOL_Callback(hObject,eventdata,handles,ToolName) %#ok<INUSL,DEFNU>

mousefrmX(0,'watch');
switch ToolName
    case 'dw1dtoolX'    , dw1dtoolX;
    case 'wp1dtoolX'    , wp1dtoolX;
    case 'cw1dtoolX'    , cw1dtoolX;
    case 'cwimtoolX'    , cwimtoolX;
    case 'dw2dtoolX'    , dw2dtoolX;
    case 'wp2dtoolX'    , wp2dtoolX;
    case 'wvdtoolX'     , wvdtoolX;
    case 'wpdtoolX'     , wpdtoolX;
    case 'sw1dtoolX'    , sw1dtoolX;
    case 'de1dtoolX'    , de1dtoolX;
    case 're1dtoolX'    , re1dtoolX;
    case 'cf1dtoolX'    , cf1dtoolX;
    case 'sw2dtoolX'    , sw2dtoolX;
    case 'cf2dtoolX'    , cf2dtoolX;
    case 'sigxtoolX'    , sigxtoolX;
    case 'imgxtoolX'    , imgxtoolX;
    case 'wfbmtoolX'    , wfbmtoolX;
    case 'wfustoolX'    , wfustoolX;
    case 'nwavtoolX'    , nwavtoolX;
    case 'wlifttool'   , wlifttool;
    case 'wmspcatool'  , wmspcatool;
    case 'wmuldentool' , wmuldentool;        
    case 'mdw1dtoolX'   , mdw1dtoolX;
    case 'comptool'    , wc2dtool;
    case 'dw3dtoolX'    , dw3dtoolX;
end
mousefrmX(0,'arrow');
%-------------------------------------------------------------------
function Pus_Close_Win_Callback(hObject,eventdata,handles) %#ok<INUSD>

% Closing all opened main analysis windows.
%------------------------------------------
fig = gcbf;
wfigmngrX('close',fig);

% Closing the wavemenuX window.
%-----------------------------
try
    delete_Callback;
    delete(fig);
catch ME    %#ok<NASGU>
end
%-------------------------------------------------------------------
function delete_Callback(hObject,eventdata,handles) %#ok<INUSD>

mextglobX('clear');
wtbxmngrX('clear');
mousefrmX(0,'arrow');
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles,varargin) %#ok<INUSL>

% Check for first call.
%----------------------
LstMenusInFig  = findall(get(hObject,'Children'),'flat','type','uimenu');
lstLabelsInFig = get(LstMenusInFig,'label');
idxMenuFile = strmatch('&File',lstLabelsInFig);
extendFLAG = isempty(idxMenuFile);

nbIN = length(varargin);
switch nbIN
    case 0     , varargin{1} = [];
    case {1,2,3} 
    otherwise
        error('Wavelet:FunctionOutput:TooMany_ArgNum', ...
            'Too many input arguments.')
end

if ~wtbxmngrX('is_on') , wtbxmngrX('ini'); end
first = ~mextglobX('is_on');
if first 
    mextglobX('ini',varargin{:});
elseif ~isempty(varargin{1})
    mextglobX('pref',varargin{:});    
else
    return
end

if extendFLAG
    wfigmngrX('extfig',hObject,'ExtMainFig_WTBX');
end

% Set CLOSE functions.
%---------------------
set(hObject,'CloseRequestFcn',@Pus_Close_Win_Callback)
MenusInFig  = findall(hObject,'type','uimenu');
LabelsInFig = get(MenusInFig,'label');
idxMenuClose = strmatch('&Close',LabelsInFig);
hMenu_Close = MenusInFig(idxMenuClose); 
set(hMenu_Close,'Callback',@Pus_Close_Win_Callback)

% Set colors and fontes for the figure.
%---------------------------------------
wfigmngrX('set_FigATTRB',hObject,'wavemenuX');

if extendFLAG
    redimfigXATTRB = wtbxappdataX('get',hObject,'redimfigXATTRB');
    if isempty(redimfigXATTRB)
        redimfigX('On',hObject,[0.85 1.2],'left');
        wtbxappdataX('set',hObject,'redimfigXATTRB',true);
    end
end

set(hObject,'DeleteFcn',@delete_Callback);
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%
