function varargout = wtbxexportX(varargin)
% WTBXEXPORT M-file for wtbxexportX.fig

% Last Modified by GUIDE v2.5 22-Jun-2009 17:14:45
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Mar-2007.
%   Last Revision: 21-May-2008.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wtbxexportX_OpeningFcn, ...
                   'gui_OutputFcn',  @wtbxexportX_OutputFcn, ...
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
%--------------------------------------------------------------------------
% --- Executes just before wtbxexportX is made visible.
function wtbxexportX_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for wtbxexportX
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialisation
Init_Tool(hObject,eventdata,handles,varargin{:});

% UIWAIT makes wtbxexportX wait for user response (see UIRESUME)
uiwait(handles.figure1);
%--------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = wtbxexportX_OutputFcn(hObject,eventdata,handles)  %#ok<INUSD>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];
%--------------------------------------------------------------------------
function lst_VAR_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

lst = get(hObject,'String');
val = get(hObject,'Value');
if isequal(val,2) , val = 1; end
varName = lst{val};
set(handles.edi_VAR,'String',varName);
%--------------------------------------------------------------------------
function Pus_OK_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>


Verify_and_Export_Var(hObject,gcbf,handles)
%--------------------------------------------------------------------------
function Verify_and_Export_Var(hObject,fig,handles) %#ok<INUSL>

%------------------------------ BUG G414791 -----------------------------
% st = dbstack;
% disp('---------------------------------------------------------------')
% for k = 1:length(st)
%     disp(['name: ' st(k).name char(9) 'line: ' int2str(st(k).line)])
% end
% disp('---------------------------------------------------------------')
% disp(' ');
% flag_QUESTDLG = any(strcmp({st(:).name},'questdlg'));
% if flag_QUESTDLG , return; end
%------------------------------ BUG G414791 -----------------------------

name_VAR = get(handles.edi_VAR,'String');
if isempty(name_VAR) , return; end
if iscell(name_VAR)
    name_VAR = name_VAR{1};
    if isempty(name_VAR) , return; end
end

% Verify the name of the variable
OK_Var = true;

lst_STR = get(handles.lst_VAR,'String');
call_DLG = ~isempty(find(strcmp(name_VAR,lst_STR),1));
if call_DLG
    ButtonName = questdlg(...
        sprintf('Replace the variable %s on the Workspace?', name_VAR), ...
        'Replace VAR','Yes','No','No');
    switch ButtonName,
        case 'No'
            OK_Var = false;
            % To reset the dialog and prompt again,
            % uncomment the 3 next lines and comment the 4th.
            
            name_VAR = get(handles.edi_VAR,'Userdata');
            if iscell(name_VAR) , name_VAR = name_VAR{1}; end
            set(handles.edi_VAR,'String',name_VAR);
            % close(fig) % The dialog is closed.
            
        case 'Yes'
    end
end

% Export to the workspace.
if OK_Var
    Var_VALUE = wtbxappdataX('get',fig,'Var_VALUE');
    if isequal(name_VAR,'Curr. Part') , name_VAR = 'Curr_Part'; end
    assignin('base',name_VAR,Var_VALUE)
    close(fig)
end
%--------------------------------------------------------------------------
function Pus_CAN_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

close(gcbf)
%--------------------------------------------------------------------------
function edi_VAR_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

% Verify_and_Export_Var(hObject,gcbf,handles)
%--------------------------------------------------------------------------
function  Init_Tool(hObject,eventdata,handles,varargin) %#ok<INUSL>

% Set WindowStyle modal.
set(hObject,'WindowStyle','modal')

% Check variables on Workspace.
workspace_vars = evalin('base','whos');
num_of_vars = length(workspace_vars);
var_Names = cell(1,num_of_vars);
for k=1:num_of_vars , var_Names{k} = workspace_vars(k).name; end

% Set new variable name.
name_DEF = {'my_VAR'};
name_VAR = '';
titleSTR = xlate('Export to Workspace');
nbIN = length(varargin)-1;
for k = 2:2:nbIN
    argNAM = varargin{k};
    argVAL = xlate(varargin{k+1});
    switch argNAM
        case 'name'  , name_VAR = {argVAL};
        case 'title' , titleSTR = [titleSTR ' - ' argVAL]; %#ok<AGROW>
    end
end
if isempty(name_VAR) , name_VAR = name_DEF; end
var_Names = {name_VAR{:} , '-----------------' , var_Names{:}};

% Verify new name.
idx = 0;
nameUSED = any(strcmp(var_Names,name_VAR));
while nameUSED
    idx = idx + 1;
    name_VAR = {['my_VAR_' int2str(idx)]};
    nameUSED = any(strcmp(var_Names,name_VAR));    
end
set(handles.edi_VAR,'String',name_VAR,'Userdata',name_VAR);
set(handles.lst_VAR,'String',var_Names);
set(hObject,'Name',titleSTR);

% Store new variable value.
wtbxappdataX('set',hObject,'Var_VALUE',varargin{1});
%--------------------------------------------------------------------------
