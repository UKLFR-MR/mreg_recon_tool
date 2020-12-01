function varargout = dw1dview_dorcX(varargin)
% DW1DVIEW_DORC M-file for dw1dview_dorcX.fig
%      DW1DVIEW_DORC, by itself, creates a new DW1DVIEW_DORC or raises the existing
%      singleton*.
%
%      H = DW1DVIEW_DORC returns the handle to a new DW1DVIEW_DORC or the handle to
%      the existing singleton*.
%
%      DW1DVIEW_DORC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DW1DVIEW_DORC.M with the given input arguments.
%
%      DW1DVIEW_DORC('Property','Value',...) creates a new DW1DVIEW_DORC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dw1dview_dorcX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dw1dview_dorcX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dw1dview_dorcX

% Last Modified by GUIDE v2.5 09-Aug-2007 16:30:23
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Aug-2007.
%   Last Revision: 24-Jan-2008.
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $ 


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dw1dview_dorcX_OpeningFcn, ...
                   'gui_OutputFcn',  @dw1dview_dorcX_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before dw1dview_dorcX is made visible.
function dw1dview_dorcX_OpeningFcn(hObject,eventdata,handles,varargin) %#ok<INUSL>

% Choose default command line output for dw1dview_dorcX
handles.output = hObject;

% Update handles structure
guidata(hObject,handles);

wfigmngrX('extfig',hObject,'ExtMainFig_WTBX');

% Clean Axe_SIG
Axe_SIG = handles.Axe_SIG;
OBJ = wfindobjX(Axe_SIG,'type','line');
delete(OBJ);

% Check Caller
win = varargin{1};
nameCaller = get(win,'Tag');
switch nameCaller
    case {'DW1D_DEN','WP1D_DEN'} , typeSIG = 'Denoised';
    case {'DW1D_CMP','WP1D_CMP'} , typeSIG = 'Compressed';
end
CallerST = struct('handle',win,'typeSIG',typeSIG);
wtbxappdataX('set',hObject,'Caller',CallerST);
nameSTR = sprintf('View Original and %s Signals',typeSIG);
chkSTR  = sprintf('%s Signal',typeSIG);
set(hObject,'Name',nameSTR);
set(handles.Chk_DorC,'String',chkSTR);

% Install DynVTool.
dynvtoolX('Install_V3',hObject,handles);

% Show Denoised or Compressed Signal
switch nameCaller
    case {'DW1D_DEN','DW1D_CMP'}
        [lin_ORI,lin_DorC] = utthrw1dX('get',win,'handleORI','handleTHR'); 
    case 'WP1D_DEN'
        [lin_ORI,lin_DorC] = utthrwpdX('get',win,'handleORI','handleTHR');        
    case 'WP1D_CMP'
        [lin_ORI,lin_DorC] = utthrgblX('get',win,'handleORI','handleTHR');
end
sigORI = get(lin_ORI,{'xdata','ydata'});
sigDEN = get(lin_DorC,{'xdata','ydata'});
ORI_color = wtbutilsX('colors','sig');
DorC_color = 'k';
LW = 2;
lin_ORI = line(...
    'Parent',handles.Axe_SIG, ...
    'Xdata',sigORI{1},  ...
    'Ydata',sigORI{2},  ...
    'color',ORI_color,  ...
    'Visible','Off'     ...
    );
lin_DorC = line(...
    'Parent',handles.Axe_SIG, ...
    'Xdata',sigDEN{1},  ...
    'Ydata',sigDEN{2},  ...
    'linewidth',LW, ...
    'color',DorC_color,  ...
    'Visible','On'      ...    
    );
axis tight

wtitleX(chkSTR,'Parent',Axe_SIG);
wtbxappdataX('set',hObject,'lin_ORI',lin_ORI);
wtbxappdataX('set',hObject,'lin_DorC',lin_DorC);

% Initialize DYNVTOOL.
%---------------------
dynvtoolX('init',hObject,[],Axe_SIG,[],[1 0],'','','','real');


% UIWAIT makes dw1dview_dorcX wait for user response (see UIRESUME)
% uiwait(handles.Fig_Sig_DorC);

% --- Outputs from this function are returned to the command line.
function varargout = dw1dview_dorcX_OutputFcn(hObject,eventdata,handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Pus_CloseWin.
function Pus_CloseWin_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>
delete(gcbf)

% --- Executes on button press in Pus_CloseWin.
function Chk_Callback(hObject,eventdata,handles,num) %#ok<INUSL,DEFNU>

valChk = get(hObject,'Value');
lin_ORI = wtbxappdataX('get',hObject,'lin_ORI');
lin_DorC = wtbxappdataX('get',hObject,'lin_DorC');
CallerST = wtbxappdataX('get',hObject,'Caller');
switch num
    case 0 , LIN = lin_ORI;
    case 1 , LIN = lin_DorC;    
end

if isequal(valChk,1) , vis = 'On'; else vis = 'Off'; end
set(LIN,'Visible',vis');
vis_ORI = get(lin_ORI,'Visible');
vis_DorC = get(lin_DorC,'Visible');
if strcmpi(vis_ORI,'On')
    if strcmpi(vis_DorC,'On')
        strTIT = ['Original and ' CallerST.typeSIG ' Signals'];
    else
        strTIT = 'Original Signal';
    end
else
    if strcmpi(vis_DorC,'On')
        strTIT = [CallerST.typeSIG ' Signal'];
    else
        strTIT = '';
    end
end
wtitleX(strTIT,'Parent',handles.Axe_SIG);
