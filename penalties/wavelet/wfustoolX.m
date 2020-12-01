function varargout = wfustoolX(varargin)
%WFUSTOOL Discrete wavelet 2D tool for image fusion.
%   VARARGOUT = WFUSTOOL(VARARGIN)

% WFUSTOOL M-file for wfustoolX.fig
%      WFUSTOOL, by itself, creates a new WFUSTOOL or raises the existing
%      singleton*.
%
%      H = WFUSTOOL returns the handle to a new WFUSTOOL or the handle to
%      the existing singleton*.
%
%      WFUSTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WFUSTOOL.M with the given input arguments.
%
%      WFUSTOOL('Property','Value',...) creates a new WFUSTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wfustoolX_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wfustoolX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wfustoolX

% Last Modified by GUIDE v2.5 24-Apr-2009 14:58:23
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Last Revision: 17-May-2009.
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2012/02/08 09:52:45 $ 

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wfustoolX_OpeningFcn, ...
                   'gui_OutputFcn',  @wfustoolX_OutputFcn, ...
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
%*************************************************************************%
%                END initialization code - DO NOT EDIT                    %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Opening Function                                   %
%                ----------------------                                   %
% --- Executes just before wfustoolX is made visible.                      %
%*************************************************************************%
function wfustoolX_OpeningFcn(hObject,eventdata,handles,varargin) %#ok<VANUS>
% This function has no output args, see OutputFcn.

% Choose default command line output for wfustoolX
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manualy in the automatic generated code   %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles);
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%

%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = wfustoolX_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
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
function Pus_CloseWin_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

hFig = handles.output;
hdl_Menus = wtbxappdataX('get',hFig,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
if isequal(lower(ena_Save),'on')
    status = wwaitansX({hFig,'Image Fusion'},...
        'Save the synthesized image ?',2,'Cancel');
    switch status
        case -1 , return;
        case  1
            wwaitingX('msg',hFig,'Wait ... computing');
            save_FUN(m_save,eventdata,handles)
            wwaitingX('off',hFig);
        otherwise
    end
end
close(gcbf)
%--------------------------------------------------------------------------
function Load_Img1_Callback(hObject,eventdata,handles,varargin) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

def_nbCodeOfColors = 255;
if isempty(varargin)
    imgFileType = getimgfiletypeX;
    [imgInfos,img_anal,map,ok] = ...
        utguidivX('load_img',hFig,imgFileType,'Load Image',def_nbCodeOfColors);
else
    [imgInfos,img_anal,ok] = wtbximportX('2d');
    map = pink(def_nbCodeOfColors);
end
if ~ok, return; end
tst_ImageSize(hFig,1,imgInfos);

% Cleaning.
%----------
wwaitingX('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'Load_Img1_Callback','beg');

% Setting GUI values and Analysis parameters.
%--------------------------------------------
max_lev_anal = 8;
levm   = wmaxlevX(imgInfos.size,'haar');
levmax = min(levm,max_lev_anal);
[curlev,curlevMAX] = cbanaparX('get',hFig,'lev','levmax');
if levmax<curlevMAX
    cbanaparX('set',hFig, ...
        'lev',{'String',int2str((1:levmax)'),'Value',min(levmax,curlev)} ...
        );
end
%---------------------------------
if isequal(imgInfos.true_name,'X')
    img_Name = imgInfos.name;
else
    img_Name = imgInfos.true_name;
end
img_Size = imgInfos.size;
wtbxappdataX('set',hFig,'Size_IMG_1',img_Size);
img_Size_2 = wtbxappdataX('get',hFig,'Size_IMG_2');
L1 = length(img_Size);
L2 = length(img_Size_2);
%---------------------------------
NB_ColorsInPal = size(map,1);
if imgInfos.self_map , arg = map; else arg = []; end
curMap = get(hFig,'Colormap');
NB_ColorsInPal = max([NB_ColorsInPal,size(curMap,1)]);
cbcolmapX('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
%---------------------------------
n_s = [img_Name '  (' , int2str(img_Size(2)) 'x' int2str(img_Size(1)) ')'];
set(handles.Edi_Data_NS,'String',n_s);                
image(wd2uiorui2dX('d2uint',img_anal),'Parent',handles.Axe_Image_1); 
wguiutilsX('setAxesTitle',handles.Axe_Image_1,'Image 1');

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Load_Img1_Callback','end');
if L1==L2
    if L1==3 , vis_UTCOLMAP = 'Off'; else vis_UTCOLMAP = 'On'; end
    cbcolmapX('visible',hFig,vis_UTCOLMAP); 
end
wwaitingX('off',hFig);
%--------------------------------------------------------------------------
function Load_Img2_Callback(hObject,eventdata,handles,varargin) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

def_nbCodeOfColors = 255;
if isempty(varargin)
    imgFileType = getimgfiletypeX;    
    [imgInfos,img_anal,map,ok] = ...
        utguidivX('load_img',hFig,imgFileType,'Load Image',def_nbCodeOfColors);
else
    [imgInfos,img_anal,ok] = wtbximportX('2d');
    map = pink(def_nbCodeOfColors);
end
if ~ok, return; end
tst_ImageSize(hFig,2,imgInfos);
% okSize = tst_ImageSize(hFig,2,imgInfos);
% if ~okSize, return; end

% Cleaning.
%----------
wwaitingX('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'Load_Img2_Callback','beg');

% Setting GUI values and Analysis parameters.
%--------------------------------------------
max_lev_anal = 8;
levm   = wmaxlevX(imgInfos.size,'haar');
levmax = min(levm,max_lev_anal);
[curlev,curlevMAX] = cbanaparX('get',hFig,'lev','levmax');
if levmax<curlevMAX
    cbanaparX('set',hFig, ...
        'lev',{'String',int2str((1:levmax)'),'Value',min(levmax,curlev)} ...
        );
end
%---------------------------------
if isequal(imgInfos.true_name,'X')
    img_Name = imgInfos.name;
else
    img_Name = imgInfos.true_name;
end
img_Size = imgInfos.size;
wtbxappdataX('set',hFig,'Size_IMG_2',img_Size);
%---------------------------------
img_Size_1 = wtbxappdataX('get',hFig,'Size_IMG_1');
L1 = length(img_Size_1);
L2 = length(img_Size);
NB_ColorsInPal = size(map,1);
if imgInfos.self_map , arg = map; else arg = []; end
curMap = get(hFig,'Colormap');
NB_ColorsInPal = max([NB_ColorsInPal,size(curMap,1)]);
cbcolmapX('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
%---------------------------------
n_s = [img_Name '  (' , int2str(img_Size(2)) 'x' int2str(img_Size(1)) ')'];
set(handles.Edi_Image_2,'String',n_s);                
image(wd2uiorui2dX('d2uint',img_anal),'Parent',handles.Axe_Image_2); 
wguiutilsX('setAxesTitle',handles.Axe_Image_2,'Image 2');
wguiutilsX('setAxesXlabel',handles.Axe_Image_Fus,'Synthesized Image');

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Load_Img2_Callback','end');
if L1==L2
    if L1==3 , vis_UTCOLMAP = 'Off'; else vis_UTCOLMAP = 'On'; end
    cbcolmapX('visible',hFig,vis_UTCOLMAP); 
end
wwaitingX('off',hFig);
%--------------------------------------------------------------------------
function Pus_Decompose_Callback(hObject,eventdata,handles,varargin) %#ok<INUSL>

hFig = handles.output;
nbIN = length(varargin);
if nbIN<1
    img_Size_1 = wtbxappdataX('get',hFig,'Size_IMG_1');
    img_Size_2 = wtbxappdataX('get',hFig,'Size_IMG_2');
    D = length(img_Size_1)-length(img_Size_2);
    if D~=0
        dispWarnMessage(hFig);
        return;
    end
    flagIDX = length(img_Size_1)<3;
    setfigNAME(hFig,flagIDX)
end
axe_IND = [...
        handles.Axe_ImgDec_1 , ...
        handles.Axe_ImgDec_2 , ...
        handles.Axe_ImgDec_Fus ...
    ];
axe_CMD = [...
        handles.Axe_Image_1 , ...
        handles.Axe_Image_2 , ...
        handles.Axe_Image_Fus ...
    ];
axe_ACT = [];

% Cleaning.
%----------
wwaitingX('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'Pus_Decompose_Callback','beg');

% Decomposition.
%---------------
[wname,level] = cbanaparX('get',hFig,'wav','lev');
Image_1 = findobj(handles.Axe_Image_1,'type','image');
X = get(Image_1,'Cdata');
tree_1 = wfustreeX(X,level,wname);
Image_2 = findobj(handles.Axe_Image_2,'type','image');
X = get(Image_2,'Cdata');
tree_2 = wfustreeX(X,level,wname);

% Store Decompositions Parameters.
%--------------------------------
tool_PARAMS = wtbxappdataX('get',hFig,'tool_PARAMS');
tool_PARAMS.DecIMG_1 = tree_1;
tool_PARAMS.DecIMG_2 = tree_2;
dwtX_ATTRB = struct('type','dwtX','wname',wname,'level',level);
tool_PARAMS.dwtX_ATTRB = dwtX_ATTRB;
wtbxappdataX('set',hFig,'tool_PARAMS',tool_PARAMS);

% Show Decompositions.
%---------------------
DecIMG_1 = getdec(tree_1);
image(wd2uiorui2dX('d2uint',DecIMG_1),'Parent',handles.Axe_ImgDec_1);
wguiutilsX('setAxesTitle',handles.Axe_ImgDec_1,'Decomposition 1');
DecIMG_2 = getdec(tree_2);
image(wd2uiorui2dX('d2uint',DecIMG_2),'Parent',handles.Axe_ImgDec_2);
wguiutilsX('setAxesTitle',handles.Axe_ImgDec_2,'Decomposition 2');
dynvtoolX('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','int');

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Pus_Decompose_Callback','end');
wwaitingX('off',hFig);
%--------------------------------------------------------------------------
function Pop_Fus_App_Callback(hObject,eventdata,handles)

Edi = handles.Edi_Fus_App;
Txt = handles.Txt_Edi_App;
set_Fus_Param(hObject,Edi,Txt,eventdata,handles)
set(handles.Tog_Inspect,'Enable','Off');
%--------------------------------------------------------------------------
function Pop_Fus_Det_Callback(hObject,eventdata,handles)

Edi = handles.Edi_Fus_Det;
Txt = handles.Txt_Edi_Det;
set_Fus_Param(hObject,Edi,Txt,eventdata,handles)
set(handles.Tog_Inspect,'Enable','Off');
%--------------------------------------------------------------------------
function Edi_Fus_App_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

Pop = handles.Pop_Fus_App;
Edi = handles.Edi_Fus_App;
tst_Fus_Param(Pop,Edi,eventdata,handles);
%--------------------------------------------------------------------------
function Edi_Fus_Det_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

Pop = handles.Pop_Fus_Det;
Edi = handles.Edi_Fus_Det;
tst_Fus_Param(Pop,Edi,eventdata,handles);
%--------------------------------------------------------------------------
function Pus_Fusion_Callback(hObject,eventdata,handles) %#ok<INUSL>

hFig = handles.output;

% Cleaning.
%----------
wwaitingX('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'Pus_Fusion_Callback','beg');

% Get Decompositions Parameters.
%-------------------------------
tool_PARAMS = wtbxappdataX('get',hFig,'tool_PARAMS');
tree_1 = tool_PARAMS.DecIMG_1;
tree_2 = tool_PARAMS.DecIMG_2;
% dwtX_ATTRB = tool_PARAMS.dwtX_ATTRB;
% type  = dwtX_ATTRB.type;
% wname = dwtX_ATTRB.wname;
% level = dwtX_ATTRB.level;

% Get Fusion Parameters.
%-----------------------
AfusMeth = get_Fus_Param('app',handles);
DfusMeth = get_Fus_Param('det',handles);

% Make Fusion.
%-------------
[XFus,tree_F] = wfusdecX(tree_1,tree_2,AfusMeth,DfusMeth);
DecImgFus = getdec(tree_F);
tool_PARAMS.DecIMG_F = tree_F;
wtbxappdataX('set',hFig,'tool_PARAMS',tool_PARAMS);

% Plot Decomposition and Image.
%------------------------------
axeCur = handles.Axe_ImgDec_Fus;
image(wd2uiorui2dX('d2uint',DecImgFus),'Parent',axeCur);
wguiutilsX('setAxesXlabel',axeCur,'Fusion of Decompositions');
axeCur = handles.Axe_Image_Fus;
image(wd2uiorui2dX('d2uint',XFus),'Parent',axeCur);
wguiutilsX('setAxesXlabel',axeCur,'Synthesized Image');
%---------------------------------------------
axe_IND = [...
        handles.Axe_ImgDec_1 , ...
        handles.Axe_ImgDec_2 , ...
        handles.Axe_ImgDec_Fus ...
    ];
axe_CMD = [...
        handles.Axe_Image_1 , ...
        handles.Axe_Image_2 , ...
        handles.Axe_Image_Fus ...
    ];
axe_ACT = [];
dynvtoolX('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','int');

% End waiting.
%-------------
set(handles.Tog_Inspect,'Enable','On');
CleanTOOL(hFig,eventdata,handles,'Pus_Fusion_Callback','end');
wwaitingX('off',hFig);
%--------------------------------------------------------------------------
function Tog_Inspect_Callback(hObject,eventdata,handles)

hFig = handles.output;
Val_Inspect = get(hObject,'Value');

% Cleaning.
%----------
wwaitingX('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'Tog_Inspect_Callback','beg',Val_Inspect);

axe_INI = [...
        handles.Axe_ImgDec_1 , handles.Axe_ImgDec_2 , handles.Axe_ImgDec_Fus ,...
        handles.Axe_Image_1  , handles.Axe_Image_2 ,  handles.Axe_Image_Fus...
    ];
child = allchild(axe_INI);
child = cat(1,child{:})';
child_INI = findobj(child)';
axe_TREE = [...
        handles.Axe_Tree_Dec , ...
        handles.Axe_Tree_Img1  , handles.Axe_Tree_Img2 ,  handles.Axe_Tree_ImgF...
    ];
child = allchild(axe_TREE);
child_DEC = cat(1,child{:})';
child_DEC = findobj(child_DEC)';

hdl_Arrows = wtbxappdataX('get',hFig,'hdl_Arrows');
switch Val_Inspect
    case 0 ,
        set([axe_TREE , child_DEC],'Visible','Off');
        delete(child_DEC);
        set([axe_INI  , child_INI , hdl_Arrows(:)'],'Visible','On');
        dynvtoolX('init',hFig,axe_INI(1:3),axe_INI,[],[1 1],'','','','int');
        set(hObject,'String','Inspect Fusion Tree');
        set(handles.Pus_CloseWin,'Enable','On');
    case 1 ,
        dynvtoolX('ini_his',hFig,-1);
        set([axe_INI  , child_INI , hdl_Arrows(:)'],'Visible','Off');        
        set([axe_TREE , child_DEC],'Visible','On');
        Tree_MANAGER('create',hFig,eventdata,handles);
        set(hObject,'String','Return to Decompositions');
        set(handles.Pus_CloseWin,'Enable','Off');
end

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Tog_Inspect_Callback','end',Val_Inspect);
wwaitingX('off',hFig);
%--------------------------------------------------------------------------
function Pop_Nod_Lab_Callback(hObject,eventdata,handles) %#ok<DEFNU>

hFig = handles.output;
lab_Value  = get(hObject,'Value');
lab_String = get(hObject,'String');
NodeLabType = deblank(lab_String{lab_Value,:});
node_PARAMS = wtbxappdataX('get',hFig,'node_PARAMS');
if isequal(NodeLabType,node_PARAMS.nodeLab) , return; end
node_PARAMS.nodeLab = NodeLabType;
wtbxappdataX('set',hFig,'node_PARAMS',node_PARAMS);
Tree_MANAGER('setNodeLab',hFig,eventdata,handles,lab_Value)
%--------------------------------------------------------------------------
function Pop_Nod_Act_Callback(hObject,eventdata, handles) %#ok<DEFNU>

hFig = handles.output;
act_Value = get(hObject,'Value');
act_String = get(hObject,'String');
NodeActType = deblank(act_String{act_Value,:});
node_PARAMS = wtbxappdataX('get',hFig,'node_PARAMS');
if isequal(NodeActType,node_PARAMS.nodeAct) , return; end
node_PARAMS.nodeAct = NodeActType;
wtbxappdataX('set',hFig,'node_PARAMS',node_PARAMS);
Tree_MANAGER('setNodeAct',hFig,eventdata,handles,act_Value)
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%



%=========================================================================%
%                    TREE MANAGEMENT and CALLBACK FUNCTIONS               %
%-------------------------------------------------------------------------%
function Tree_MANAGER(option,hFig,eventdata,handles,varargin) %#ok<INUSL>

% Miscellaneous Values.
%----------------------
line_color = [0 0 0];
actColor   = 'b';
inactColor = 'r';

% MemBloc of stored values.
%--------------------------
n_stored_val = 'NTREE_Plot';
ind_tree     = 1;
% ind_Class    = 2;
ind_hdls_txt = 3;
ind_hdls_lin = 4;
ind_menu_NodeLab =  5;
ind_type_NodeLab =  6;
% ind_menu_NodeAct =  7;
ind_type_NodeAct =  8;
% ind_menu_TreeAct =  9;
% ind_type_TreeAct = 10;
% nb1_stored = 10;

% Handles.
%---------
tool_hdl_AXES = wtbxappdataX('get',hFig,'tool_hdl_AXES');
axe_TREE = tool_hdl_AXES.axe_TREE;
Axe_Tree_Dec  = axe_TREE(1);

% tool_PARAMS.
%-------------
tool_PARAMS = wtbxappdataX('get',hFig,'tool_PARAMS');
tree_F = tool_PARAMS.DecIMG_F;

switch option
    case 'create'
        % node_PARAMS.
        %-------------
        node_PARAMS = wtbxappdataX('get',hFig,'node_PARAMS');
        type_NodeLab = node_PARAMS.nodeLab;
        
        Tree_Colors = struct(...
            'line_color',line_color, ...
            'actColor',actColor,     ...
            'inactColor',inactColor);  
        wtbxappdataX('set',hFig,'Tree_Colors',Tree_Colors);
        set(Axe_Tree_Dec,'DefaultTextFontSize',8)
        order = treeordX(tree_F);
        depth = treedpthX(tree_F);
        allN  = allnodesX(tree_F);
        NBnod = (order^(depth+1)-1)/(order-1);
        table_node = -ones(1,NBnod);
        table_node(allN+1) = allN;
        [xnpos,ynpos] = xynodposX(table_node,order,depth);
        
        hdls_lin = zeros(1,NBnod);
        hdls_txt = zeros(1,NBnod);
        i_fath  = 1;
        i_child = i_fath+(1:order);
        for d=1:depth
            ynT = ynpos(d,:);
            ynL = ynT+[0.01 -0.01];
            for p=0:order^(d-1)-1
                if table_node(i_child(1)) ~= -1
                    for k=1:order
                        ic = i_child(k);
                        hdls_lin(ic) = line(...
                            'Parent',Axe_Tree_Dec, ...
                            'XData',[xnpos(i_fath) xnpos(ic)],...
                            'YData',ynL,...
                            'Color',line_color);
                    end
                end
                i_child = i_child+order;
                i_fath  = i_fath+1;
            end
        end
        labels = tlabels(tree_F,'i'); % Indices
        textProp = {...
                'Parent',Axe_Tree_Dec,          ...
                'FontWeight','bold',            ...
                'Color',actColor,               ...
                'HorizontalAlignment','center', ...
                'VerticalAlignment','middle',   ...
                'Clipping','on'                 ...
            };    
        
        i_node = 1;   
        hdls_txt(i_node) = ...
            text(textProp{:},...
            'String', labels(i_node,:),   ...
            'Position',[0 0.1 0],         ...
            'UserData',table_node(i_node) ...
            );
        i_node = i_node+1;
        
        i_fath  = 1;
        i_child = i_fath+(1:order);
        for d=1:depth
            for p=0:order:order^d-1
                if table_node(i_child(1)) ~= -1
                    for k=1:order
                        ic = i_child(k);
                        hdls_txt(ic) = text(...
                            textProp{:},...
                            'String',labels(i_node,:), ...
                            'Position',[xnpos(ic) ynpos(d,2) 0],...
                            'Userdata',table_node(ic)...
                            );
                        i_node = i_node+1;
                    end
                end
                i_child = i_child+order;
            end
        end
        nodeAction = ...
            [mfilename '(''nodeAction_CallBack'',gco,[],' num2mstrX(hFig) ');'];
        set(hdls_txt(hdls_txt~=0),'ButtonDownFcn',nodeAction);
        [nul,notAct] = findactn(tree_F,allN,'na'); %#ok<ASGLU>
        set(hdls_txt(notAct+1),'Color',inactColor);
        %----------------------------------------------
        m_lab = [];
        wmemtoolX('wmb',hFig,n_stored_val, ...
            ind_tree,tree_F,      ...
            ind_hdls_txt,hdls_txt, ...
            ind_hdls_lin,hdls_lin, ...
            ind_menu_NodeLab,m_lab, ...
            ind_type_NodeLab,'Index', ...
            ind_type_NodeAct,'' ...
            );        
        %----------------------------------------------
        switch lower(type_NodeLab)
            case 'index' ,
            otherwise    , plot(tree_F,'setNodeLabel',hFig,lower(type_NodeLab));
        end        
        %----------------------------------------------
        wguiutilsX('setAxesTitle',Axe_Tree_Dec,'Wavelet Decomposition Tree');
        show_Node_IMAGES(hFig,'Visualize',0)
        
    case 'setNodeLab'
        if length(varargin)>1
            labValue = varargin{1};
        else
            handles = guihandles(hFig);
            labValue = get(handles.Pop_Nod_Lab,'Value');
        end
        switch labValue
            case 1 , labtype = 'i'; 
            case 2 , labtype = 'dp';
            case 3 , labtype = 's';
            case 4 , labtype = 't';
        end
        labels = tlabels(tree_F,labtype);
        hdls_txt = wmemtoolX('rmb',hFig,n_stored_val,ind_hdls_txt);
        hdls_txt = hdls_txt(hdls_txt~=0);
        for k=1:length(hdls_txt), set(hdls_txt(k),'String',labels(k,:)); end

    case 'setNodeAct'
        nodeAction = ...
            [mfilename '(''nodeAction_CallBack'',gco,[],' num2mstrX(hFig) ');'];
        hdls_txt = wmemtoolX('rmb',hFig,n_stored_val,ind_hdls_txt);
        set(hdls_txt(hdls_txt~=0),'ButtonDownFcn',nodeAction);        
end
%-------------------------------------------------------------------------
function nodeAction_CallBack(hObject,eventdata,hFig) %#ok<INUSL,DEFNU>

node = plot(ntree,'getNode',hFig);
if isempty(node) , return; end
node_PARAMS = wtbxappdataX('get',hFig,'node_PARAMS');
nodeAct = node_PARAMS.nodeAct;
if isequal(nodeAct,'Split_Merge') || isequal(nodeAct,'Split / Merge')
    tool_PARAMS = wtbxappdataX('get',hFig,'tool_PARAMS');
    tree_F = tool_PARAMS.DecIMG_F;
    tnrank = findactn(tree_F,node);
    if isnan(tnrank) , return;  end
    plot(tree_F,'Split-Merge',hFig);
    tree_1 = tool_PARAMS.DecIMG_1;
    tree_2 = tool_PARAMS.DecIMG_2;
    if tnrank>0
        tree_1 = nodesplt(tree_1,node);
        tree_2 = nodesplt(tree_2,node);
        tree_F = nodesplt(tree_F,node);
    else
        tree_1 = nodejoin(tree_1,node);
        tree_2 = nodejoin(tree_2,node);
        tree_F = nodejoin(tree_F,node);
    end
    tool_PARAMS.DecIMG_1 = tree_1;
    tool_PARAMS.DecIMG_2 = tree_2;
    tool_PARAMS.DecIMG_F = tree_F;
    wtbxappdataX('set',hFig,'tool_PARAMS',tool_PARAMS);
    Tree_MANAGER('setNodeLab',hFig,eventdata,guihandles(hFig))
else
    show_Node_IMAGES(hFig,nodeAct,node);
end
%-------------------------------------------------------------------------
function show_Node_IMAGES(hFig,nodeAct,node)

tool_hdl_AXES = wtbxappdataX('get',hFig,'tool_hdl_AXES');
axe_TREE = tool_hdl_AXES.axe_TREE;
Axe_Tree_Img1 = axe_TREE(2);
Axe_Tree_Img2 = axe_TREE(3);
Axe_Tree_ImgF = axe_TREE(4);
tool_PARAMS = wtbxappdataX('get',hFig,'tool_PARAMS');
tree_1 = tool_PARAMS.DecIMG_1;
tree_2 = tool_PARAMS.DecIMG_2;
tree_F = tool_PARAMS.DecIMG_F;

mousefrmX(hFig,'watch')
NBC = cbcolmapX('get',hFig,'nbColors');
flag_INVERSE = false;
show_One_IMAGE(nodeAct,tree_1,node,NBC,flag_INVERSE,Axe_Tree_Img1,'Image 1')
show_One_IMAGE(nodeAct,tree_2,node,NBC,flag_INVERSE,Axe_Tree_Img2,'Image 2')
show_One_IMAGE(nodeAct,tree_F,node,NBC,flag_INVERSE,...
    Axe_Tree_ImgF,'Synthesized Image')
lind = tlabels(tree_F,'i',node);
ldep = tlabels(tree_F,'p',node);

axeTitle = [xlate('Coefficients: node') ' ' lind ...
    ' '  xlate('or') ' ' ldep];
if isequal(nodeAct,'Reconstruct')
    axeTitle = [xlate('Reconstructed') ' ' axeTitle];
end
title(axeTitle,'Parent',Axe_Tree_ImgF);
mousefrmX(hFig,'arrow')
dynvtoolX('init',hFig,axe_TREE(1),axe_TREE(2:4),[],[1 1],'','','','int');
%-------------------------------------------------------------------------
function show_One_IMAGE(nodeAct,treeOBJ,node,NBC,flag_INVERSE,axe,xlab)

X = getCoded_IMAGE(nodeAct,treeOBJ,node,NBC,flag_INVERSE);
image(wd2uiorui2dX('d2uint',X),'Parent',axe);
wguiutilsX('setAxesXlabel',axe,xlab);
%-------------------------------------------------------------------------
function X = getCoded_IMAGE(nodeAct,treeOBJ,node,NBC,flag_INVERSE)

switch nodeAct
    case 'Visualize' , [nul,X] = nodejoin(treeOBJ,node); %#ok<ASGLU>
    case 'Reconstruct' , X = rnodcoef(treeOBJ,node);
end
if node>0 , 
    X = wcodematX(X,NBC,'mat',1);
    if flag_INVERSE && rem(node,4)~=1 , X = max(X(:))-X; end
end
%==========================================================================


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%
function demo_FUN(hObject,eventdata,handles,numDEM) %#ok<INUSL>

optIMG   = 'BW';
switch numDEM
    case 1 
        I_1 = 'detail_1'; I_2 = 'detail_2';
        wname = 'db1' ; level = 2;
        AfusMeth = 'max';
        DfusMeth = 'max';       
    case 2
        I_1 = 'cathe_1'; I_2 = 'cathe_2';
        wname = 'db1' ; level = 2;
        AfusMeth = 'max'; 
        DfusMeth = 'max'; 
    case 3
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 2;
        AfusMeth = 'max';
        DfusMeth = 'max';
    case 4
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'bior6.8' ; level = 3;
        AfusMeth = 'rand';
        DfusMeth = 'max';
    case 5
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',4);
        DfusMeth = struct('name','UD_fusion','param',1);
    case 6
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = 'DU_fusion'; DfusMeth = 'DU_fusion';
    case 7
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = 'LR_fusion'; 
        DfusMeth = 'LR_fusion';
    case 8
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = 'RL_fusion';
        DfusMeth = 'RL_fusion';
    case 9
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'sym6' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',2);
        DfusMeth = struct('name','UD_fusion','param',4);
    case 10
        I_1 = 'face_mos'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'mean';
        DfusMeth = 'max';
    case 11
        I_1 = 'face_pai'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'mean';
        DfusMeth = 'max';
    case 12
        I_1 = 'fond_bou'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',1);
        DfusMeth = 'max';
    case 13
        I_1 = 'fond_mos'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',1);
        DfusMeth = 'max';
    case 14
        I_1 = 'fond_pav'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',0.5);
        DfusMeth = 'max';
    case 15
        I_1 = 'fond_tex'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth  = struct('name','UD_fusion','param',0.5);
        DfusMeth = 'img1';
    case 16
        I_1 = 'pile_mos'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth  = struct('name','UD_fusion','param',0.5);
        DfusMeth = 'img1';
    case 17
        I_1 = 'arms.jpg'; I_2 = 'fond_tex';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'img1'; 
        DfusMeth = 'max';
    case 18
        I_1 = 'arms.jpg'; I_2 = 'fond_tex';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'img1'; 
        DfusMeth = 'max';
        optIMG   = 'COL';
    case 19
        I_1 = 'facets'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'img1'; 
        DfusMeth = 'max';
        optIMG   = 'COL'; 
    case 20
        I_1 = 'mask'; I_2 = 'fond_tex';
        wname = 'sym4' ; level = 3;
        AfusMeth = struct('name','RL_fusion','param',1);
        DfusMeth = struct('name','LR_fusion','param',1);
        optIMG   = 'COL';        
end

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing file.
%--------------
def_nbCodeOfColors = 255;
filename = I_1;
idx = findstr(filename,'.');
if isempty(idx) , filename = [filename '.mat']; end
pathname = utguidivX('WTB_DemoPath',filename);
[imgInfos_1,X_1,map,ok] = ...
    utguidivX('load_dem2D',hFig,pathname,filename,def_nbCodeOfColors,optIMG); %#ok<ASGLU>
if ~ok, return; end
% tst_ImageSize(hFig,1,imgInfos_1);

filename = I_2;
idx = findstr(filename,'.');
if isempty(idx) , filename = [filename '.mat']; end
[imgInfos_2,X_2,map,ok] = ...
    utguidivX('load_dem2D',hFig,pathname,filename,def_nbCodeOfColors,optIMG);
if ~ok, return; end
% tst_ImageSize(hFig,2,imgInfos_2);
flagIDX = length(imgInfos_1.size)<3;
setfigNAME(hFig,flagIDX)

% Cleaning.
%----------
wwaitingX('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'demo_FUN');

% Setting Analysis parameters
%----------------------------
cbanaparX('set',hFig,'wav',wname,'lev',level);
set_Fus_Methode('app',AfusMeth,eventdata,handles);
set_Fus_Methode('det',DfusMeth,eventdata,handles);

% Loading Images and Setting GUI.
%-------------------------------
img_Size_1 = imgInfos_1.size;
if isequal(imgInfos_1.true_name,'X')
    img_Name_1 = imgInfos_1.name;
else
    img_Name_1 = imgInfos_1.true_name;
end
wtbxappdataX('set',hFig,'Size_IMG_1',img_Size_1);
NB_ColorsInPal = size(map,1);
if imgInfos_1.self_map , arg = map; else arg = []; end
cbcolmapX('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
n_s = [img_Name_1 '  (' , int2str(img_Size_1(2)) 'x' int2str(img_Size_1(1)) ')'];
set(handles.Edi_Data_NS,'String',n_s);                
image(X_1,'Parent',handles.Axe_Image_1);
wguiutilsX('setAxesTitle',handles.Axe_Image_1,'Image 1');
%--------------------------------------------
if isequal(imgInfos_2.true_name,'X')
    img_Name_2 = imgInfos_2.name;
else
    img_Name_2 = imgInfos_2.true_name;
end
img_Size_2 = imgInfos_2.size;
wtbxappdataX('set',hFig,'Size_IMG_2',img_Size_2);
NB_ColorsInPal = size(map,1);
if imgInfos_2.self_map , arg = map; else arg = []; end
cbcolmapX('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
n_s = [img_Name_2 '  (' , int2str(img_Size_2(2)) 'x' int2str(img_Size_2(1)) ')'];
set(handles.Edi_Image_2,'String',n_s);                
image(X_2,'Parent',handles.Axe_Image_2);
wguiutilsX('setAxesTitle',handles.Axe_Image_2,'Image 2');
%--------------------------------------------
if length(size(X_2))>2 , vis_UTCOLMAP = 'Off'; else vis_UTCOLMAP = 'On'; end
cbcolmapX('visible',hFig,vis_UTCOLMAP);

% Decomposition and Fusion.
%--------------------------
Pus_Decompose_Callback(handles.Pus_Decompose,eventdata,handles,'demo');
Pus_Fusion_Callback(handles.Pus_Fusion,eventdata,handles);
%--------------------------------------------------------------------------
function set_Fus_Methode(type,fusMeth,eventdata,handles)

switch type
    case 'app'
        Pop = handles.Pop_Fus_App;
        Edi = handles.Edi_Fus_App;
    case 'det'
        Pop = handles.Pop_Fus_Det;
        Edi = handles.Edi_Fus_Det;
end
if ischar(fusMeth)
    fusMeth = struct('name',fusMeth,'param','');
end
methName = fusMeth.name;
tabMeth = get(Pop,'String');
numMeth = strmatch(methName,tabMeth);
set(Pop,'Value',numMeth);
switch type
    case 'app' , Pop_Fus_App_Callback(Pop,eventdata,handles);
    case 'det' , Pop_Fus_Det_Callback(Pop,eventdata,handles);
end
ediVAL = get(Edi,'String');
newVAL = num2str(fusMeth.param);
if isempty(newVAL) , newVAL = ediVAL; end
set(Edi,'String',newVAL);
%-------------------------------------------------------------------------
function save_FUN(hObject,eventdata,handles) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Getting Synthesized Image.
%---------------------------
axe = handles.Axe_Image_Fus;
img_Fus = findobj(axe,'Type','image');
X = round(get(img_Fus,'Cdata'));
utguidivX('save_img','Save Synthesized Image as',hFig,X);
%-------------------------------------------------------------------------%
function Export_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

hFig = handles.output;
wwaitingX('msg',hFig,'Wait ... exporting');
axe = handles.Axe_Image_Fus;
img_Fus = findobj(axe,'Type','image');
Xfus = round(get(img_Fus,'Cdata'));
wtbxexportX(Xfus,'name','Xfus','title','Export Wavelet');
wwaitingX('off',hFig);
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%
function CleanTOOL(hFig,eventdata,handles,callName,option,varargin) %#ok<INUSL>

tool_PARAMS = wtbxappdataX('get',hFig,'tool_PARAMS');
hdl_Menus   = wtbxappdataX('get',hFig,'hdl_Menus');
ena_LOAD_DEC = 'On';
switch callName
    case 'demo_FUN'
        tool_PARAMS.flagIMG_1 = true;
        tool_PARAMS.flagIMG_2 = true;
        tool_PARAMS.flagDEC   = false;
        tool_PARAMS.flagFUS   = false;
        tool_PARAMS.flagINS   = false;
        hAXE = [handles.Axe_ImgDec_1,  handles.Axe_ImgDec_2,...
                handles.Axe_Image_Fus, handles.Axe_ImgDec_Fus];
        hIMG = findobj(hAXE,'type','image');
        delete(hIMG);
                
    case 'Load_Img1_Callback'
        switch option
            case 'beg'
                tool_PARAMS.flagIMG_1 = true;
                tool_PARAMS.flagDEC   = false;
                tool_PARAMS.flagFUS   = false;
                tool_PARAMS.flagINS   = false;
                hAXE = [handles.Axe_ImgDec_1,handles.Axe_ImgDec_2 ...
                        handles.Axe_Image_Fus,handles.Axe_ImgDec_Fus ...
                        ];
                hIMG = findobj(hAXE,'type','image');
                delete(hIMG);
            case 'end'
        end
        
    case 'Load_Img2_Callback'
        switch option
            case 'beg' 
                tool_PARAMS.flagIMG_2 = true;
                tool_PARAMS.flagDEC   = false;
                tool_PARAMS.flagFUS   = false;
                tool_PARAMS.flagINS   = false;
                hAXE = [handles.Axe_ImgDec_1,handles.Axe_ImgDec_2 ...
                        handles.Axe_Image_Fus,handles.Axe_ImgDec_Fus ...
                        ];
                hIMG = findobj(hAXE,'type','image');
                delete(hIMG);
            case 'end'
        end
        
    case 'Pus_Decompose_Callback'
        switch option
            case 'beg' , 
                tool_PARAMS.flagDEC = true;
                tool_PARAMS.flagFUS = false;
                hAXE = [handles.Axe_Image_Fus,handles.Axe_ImgDec_Fus];
                hIMG = findobj(hAXE,'type','image');
                delete(hIMG);
            case 'end'
        end
        
    case 'Pus_Fusion_Callback'
        switch option
            case 'beg' ,
            case 'end' , tool_PARAMS.flagFUS = true;
        end
        
    case 'Tog_Inspect_Callback'
        Val_Inspect = varargin{1};
        flag_Enable = logical(1-Val_Inspect);
        switch option
            case 'beg' ,
                tool_PARAMS.flagDEC = false;
                ena_LOAD_DEC = 'Off';
                ena_FUS_PAR  = 'Off';
                ena_NOD_OPT  = 'Off';
            case 'end' ,
                tool_PARAMS.flagDEC = flag_Enable;
                if flag_Enable
                    ena_LOAD_DEC = 'On';
                    ena_FUS_PAR  = 'On';
                    ena_NOD_OPT  = 'Off';
                else
                    ena_LOAD_DEC = 'Off';
                    ena_FUS_PAR  = 'Off';
                    ena_NOD_OPT  = 'On';
                end
        end
        m_Load_Img1 = hdl_Menus.m_Load_Img1;
        m_Load_Img2 = hdl_Menus.m_Load_Img2;
        m_demo = hdl_Menus.m_demo;
        set([m_Load_Img1,m_Load_Img2,m_demo....
             handles.Pus_Decompose],'Enable',ena_LOAD_DEC);
        set([handles.Txt_Fus_Params, ...
             handles.Txt_Fus_App,handles.Pop_Fus_App,  ...
             handles.Txt_Edi_App,handles.Edi_Fus_App,  ...
             handles.Txt_Fus_Det,handles.Pop_Fus_Det,  ...
             handles.Txt_Edi_Det,handles.Edi_Fus_Det],  ...         
            'Enable',ena_FUS_PAR);
        set([handles.Txt_Nod_Lab,handles.Pop_Nod_Lab, ...
             handles.Txt_Nod_Act,handles.Pop_Nod_Act,], ...
            'Enable',ena_NOD_OPT);
end
Ok_DEC = tool_PARAMS.flagIMG_1 & tool_PARAMS.flagIMG_2;
if Ok_DEC && isequal(ena_LOAD_DEC,'On')
    set(handles.Pus_Decompose,'Enable','On');
else
    set(handles.Pus_Decompose,'Enable','Off');
end
if tool_PARAMS.flagDEC
    set(handles.Pus_Fusion,'Enable','On');
else
    set(handles.Pus_Fusion,'Enable','Off');
end

m_save = hdl_Menus.m_save;
m_exp_sig = hdl_Menus.m_exp_sig;
if tool_PARAMS.flagFUS
    set(handles.Tog_Inspect,'Enable','On');
    set([m_save,m_exp_sig],'Enable','On')
else
    set(handles.Tog_Inspect,'Enable','Off');
    set([m_save,m_exp_sig],'Enable','Off')
end

wtbxappdataX('set',hFig,'tool_PARAMS',tool_PARAMS);
%--------------------------------------------------------------------------
%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%



%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles) %#ok<INUSL>

% WTBX -- Install DynVTool
%-------------------------
dynvtoolX('Install_V3',hObject,handles);

% WTBX -- Initialize GUIDE Figure.
%---------------------------------
wfigmngrX('beg_GUIDE_FIG',hObject);

% WTBX -- Install ANAPAR FRAME
%-----------------------------
wnameDEF  = 'db1';
maxlevDEF = 5;
levDEF    = 2;
utanaparX('Install_V3_CB',hObject,'maxlev',maxlevDEF,'deflev',levDEF);
cbanaparX('set',hObject,'wav',wnameDEF,'lev',levDEF);

% WTBX -- Install COLORMAP FRAME
%-------------------------------
utcolmapX('Install_V3',hObject,'enable','On');
default_nbcolors = 128;
cbcolmapX('set',hObject,'pal',{'pink',default_nbcolors})
%-------------------------------------------------------------------------
% TOOL INITIALISATION
%-------------------------------------------------------------------------
% UIMENU INSTALLATION
%--------------------
hdl_Menus = Install_MENUS(hObject,handles);
wtbxappdataX('set',hObject,'hdl_Menus',hdl_Menus);
%------------------------------------------------
set(hObject,'DefaultAxesXtick',[],'DefaultAxesYtick',[])
hdl_Arrows = arrowfus(handles,'On');
wtbxappdataX('set',hObject,'hdl_Arrows',hdl_Arrows);
%-------------------------------------------------------------------------
axe_INI = [...
    handles.Axe_ImgDec_1 , handles.Axe_ImgDec_2 , handles.Axe_ImgDec_Fus ,...
    handles.Axe_Image_1  , handles.Axe_Image_2 ,  handles.Axe_Image_Fus...
    ];
axe_TREE = [...
    handles.Axe_Tree_Dec , ...
    handles.Axe_Tree_Img1  , handles.Axe_Tree_Img2 ,  handles.Axe_Tree_ImgF...
    ];
tool_hdl_AXES = struct('axe_INI',axe_INI,'axe_TREE',axe_TREE);
wtbxappdataX('set',hObject,'tool_hdl_AXES',tool_hdl_AXES);
set(hObject,'Visible','Off');drawnow
%-------------------------------------------------------------------------
wguiutilsX('setAxesTitle',handles.Axe_Image_1,'Image 1',hObject);
wguiutilsX('setAxesTitle',handles.Axe_Image_2,'Image 2',hObject);
wguiutilsX('setAxesXlabel',handles.Axe_Image_Fus,'Synthesized Image',hObject);
wguiutilsX('setAxesTitle',handles.Axe_ImgDec_1,'Decomposition 1',hObject);
wguiutilsX('setAxesTitle',handles.Axe_ImgDec_2,'Decomposition 2',hObject);
wguiutilsX('setAxesXlabel',handles.Axe_ImgDec_Fus,'Fusion of Decompositions',hObject);
%-------------------------------------------------------------------------
dwtX_ATTRB   = struct('type','lwtX','wname','','level',[]);
tool_PARAMS = struct(...
    'infoIMG_1',[],'infoIMG_2',[],...    
    'flagIMG_1',false,'flagIMG_2',false,...
    'flagDEC',false,'flagFUS',false, 'flagINS',false, ...
    'DecIMG_1',[],'DecIMG_2',[],'DecIMG_F',[], ...
    'dwtX_ATTRB',dwtX_ATTRB);
wtbxappdataX('set',hObject,'tool_PARAMS',tool_PARAMS);
%-------------------------------------------------------------
node_PARAMS = struct('nodeLab','Index','nodeAct','Visualize');
wtbxappdataX('set',hObject,'node_PARAMS',node_PARAMS);
%--------------------------------------------------------------

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngrX('end_GUIDE_FIG',hObject,mfilename);
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function hdl_Menus = Install_MENUS(hFig,handles)

m_files = wfigmngrX('getmenus',hFig,'file');
m_close = wfigmngrX('getmenus',hFig,'close');
cb_close = [mfilename '(''Pus_CloseWin_Callback'',gcbo,[],guidata(gcbo));'];
set(m_close,'Callback',cb_close);

m_Load_Img1 = uimenu(m_files, ...
    'Label','&Load or Import Image 1', ...
    'Position',1,'Enable','On'         ...
    );
m_Load_Img2 = uimenu(m_files, ...
    'Label','&Load or Import Image 2',   ...
    'Position',2,'Enable','On'            ...
    );
m_save = uimenu(m_files,...
    'Label','&Save Synthesized Image ', ...
    'Position',3, 'Enable','Off',  ...
    'Callback',[mfilename '(''save_FUN'',gcbo,[],guidata(gcbo));'] ...
    );
m_demo = uimenu(m_files,'Label','&Example ','Position',4,'Separator','Off');
m_exp_sig = uimenu(m_files, ...
    'Label','Export Image to Workspace','Position',5, ...
    'Enable','Off','Separator','On',...
    'Callback',[mfilename '(''Export_Callback'',gcbo,[],guidata(gcbo));']  ...
    );

uimenu(m_Load_Img1, ...
    'Label','Load Image',   ...
    'Position',1,              ...
    'Enable','On',             ...
    'Callback',                ...
    [mfilename '(''Load_Img1_Callback'',gcbo,[],guidata(gcbo));']  ...
    );
 uimenu(m_Load_Img1, ...
    'Label','Import from Workspace',   ...
    'Position',2,              ...
    'Enable','On',             ...
    'Callback',                ...
    [mfilename '(''Load_Img1_Callback'',gcbo,[],guidata(gcbo),1);']  ...
    );

uimenu(m_Load_Img2, ...
    'Label','Load Image',   ...
    'Position',1,              ...
    'Enable','On',             ...
    'Callback',                ...
    [mfilename '(''Load_Img2_Callback'',gcbo,[],guidata(gcbo));']  ...
    );
 uimenu(m_Load_Img2, ...
    'Label','Import from Workspace',   ...
    'Position',2,              ...
    'Enable','On',             ...
    'Callback',                ...
    [mfilename '(''Load_Img2_Callback'',gcbo,[],guidata(gcbo),1);']  ...
    );

m_demoIDX = uimenu(m_demo,'Label','Indexed Images ','Position',1);
m_demoCOL = uimenu(m_demo,'Label','Truecolor Images ','Position',2);
tab = char(9);
demoSET = {...
    ['Magic Square' tab '- wavelet: db1 - level: 2 - fusion method (max,max)'];       ...
    ['Catherine' tab  '- wavelet: db1 - level: 2 - fusion method (max,max)'];         ...
    ['Mask and Bust' tab  '- wavelet: db1 - level: 2 - fusion method (max,max)'];  ...
    ['Mask and Bust' tab  '- wavelet: bior6.8 - level: 3 - fusion method (rand,max)'];  ...
    ['Mask and Bust' tab  '- wavelet: db1 - level: 3 - fusion method (UD_fusion,UD_fusion)'];  ...    
    ['Mask and Bust' tab  '- wavelet: db1 - level: 3 - fusion method (DU_fusion,DU_fusion)'];  ... 
    ['Mask and Bust' tab  '- wavelet: db1 - level: 3 - fusion method (LR_fusion,LR_fusion)'];  ...    
    ['Mask and Bust' tab  '- wavelet: db1 - level: 3 - fusion method (RL_fusion,RL_fusion)'];   ...
    ['Mask and Bust' tab  '- wavelet: sym6 - level: 3 - fusion method ( [UD_fusion,2] , [UD_fusion,4] )'];  ...
    ['Texture (1) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method (mean,max)'];  ...
    ['Texture (2) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method (mean,max)'];  ...
    ['Texture (3) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method ( [UD_fusion,1] , max)']; ... 
    ['Texture (4) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method ( [UD_fusion,1] , max)']; ... 
    ['Texture (5) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method ( [UD_fusion,0.5] , max)']; ... 
    ['Texture (6) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method  ( [UD_fusion,0.5] , img1)'];  ...
    ['Texture (7) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method  ( [UD_fusion,0.5] , img1)'];  ...
    ['Texture (8) and Arms' tab  '- wavelet: sym4 - level: 3 - fusion method  (img1,max)'];  ...
    ['Texture (8) and Arms (COL)' tab  '- wavelet: sym4 - level: 3 - fusion method  (img1,max)'];  ...        
    ['Facets and Mask'  tab  '- wavelet: sym4 - level: 3 - fusion method  (img1,max)'];  ...        
    ['Mask and Texture (8)' tab  '- wavelet: sym4 - level: 3 - fusion method ( [LR_fusion,1] , [RL_fusion,1] )'],  ...
    };
nbDEM = size(demoSET,1);
sepSET = [3,10];
for k = 1:nbDEM
    strNUM = int2str(k);
    action = [mfilename '(''demo_FUN'',gcbo,[],guidata(gcbo),' strNUM ');'];
    if find(k==sepSET) , Sep = 'On'; else Sep = 'Off'; end
    if k<18 , md = m_demoIDX; else md = m_demoCOL; end
    uimenu(md,'Label',[demoSET{k,1}],'Separator',Sep,'Callback',action);
end
hdl_Menus = struct('m_files',m_files,'m_close',m_close,...
    'm_Load_Img1',m_Load_Img1,'m_Load_Img2',m_Load_Img2,...
    'm_save',m_save,'m_demo',m_demo,'m_exp_sig',m_exp_sig);

% Add Help for Tool.
%------------------
wfighelpX('addHelpTool',hFig,'&Image Fusion','WFUS_GUI');
hdl_FUS = [...
        handles.Txt_Edi_Det , handles.Txt_Edi_App , handles.Pop_Fus_Det , ...
        handles.Pop_Fus_App , handles.Txt_Fus_Params , handles.Pus_Fusion , ...
        handles.Txt_Fus_Det , handles.Txt_Fus_App , handles.Fra_Fus_Params ...
        ];
wfighelpX('add_ContextMenu',hFig,hdl_FUS,'WFUS_IMG');
%-------------------------------------------------------------------------

% BEGIN: Arrows for WTBX FUSION TOOL %
%------------------------------------%
function hdl_Arrows = arrowfus(handles,visible)
%ARROWFUS Plot the arrows for WFUSTOOL.

colArrowDir = [0.925 0.925 0.925]; % Gray 
colArrowRev = colArrowDir;
axe_arrow = handles.Axe_Utils;
Axe_Image_1    = handles.Axe_Image_1;
Axe_ImgDec_1   = handles.Axe_ImgDec_1;
Axe_Image_2    = handles.Axe_Image_2;
Axe_ImgDec_2   = handles.Axe_ImgDec_2;
Axe_Image_Fus  = handles.Axe_Image_Fus;
Axe_ImgDec_Fus = handles.Axe_ImgDec_Fus;
[ar1,t1] = PlotArrow('direct',axe_arrow, ...
    Axe_Image_1,Axe_ImgDec_1,colArrowDir,visible);
[ar2,t2] = PlotArrow('direct',axe_arrow, ...
    Axe_Image_2,Axe_ImgDec_2,colArrowDir,visible);
[ar3,t3] = PlotArrow('reverse',axe_arrow, ...
    Axe_Image_Fus,Axe_ImgDec_Fus,colArrowRev,visible);
[ar4,t4] = PlotArrowVER(axe_arrow, ...
    Axe_ImgDec_1,Axe_ImgDec_2,Axe_ImgDec_Fus,colArrowDir,visible);
set(axe_arrow,'Xlim',[0,1],'Ylim',[0,1])
hdl_Arrows = [ [ar1,t1] ; [ar2,t2] ; [ar3,t3] ; [ar4,t4]];        
%----------------------------------------------------------------
function [ar,t] = ...
    PlotArrow(option,axe_arrow,axeINI,axeEND,colArrow,visible)

pImg = get(axeINI,'Position');
pDec = get(axeEND,'Position');
xAR_ini = pImg(1) + pImg(3);
xAR_end = pDec(1);
dx      = (xAR_end - xAR_ini);
yAR     = pImg(2) + pImg(4)/2;
pt1 = [xAR_ini+dx/6 yAR];
pt2 = [xAR_end-dx/6 yAR];
if isequal(option,'reverse')
    rot = pi; Pini = pt2; strTXT = 'idwtX'; colorTXT = 'r';
else
    rot = 0;  Pini = pt1; strTXT = 'dwtX';  colorTXT = 'b';
end
ar = wtbarrowX('create','axes',axe_arrow,...
    'Scale',[pt2(1)-pt1(1) 1/9],'Trans',Pini,'Rotation',rot, ...
    'Color',colArrow,'Visible',visible);
t = text(...
    'Parent',axe_arrow,...
    'Position',[xAR_ini + dx/3 yAR],...
    'String',strTXT,'FontSize',12,'FontWeight','demi','Color',colorTXT);
%----------------------------------------------------------------
function [ar,t] = PlotArrowVER(axe_arrow,...
    Axe_ImgDec_1,Axe_ImgDec_2,Axe_ImgDec_Fus,colArrow,visible)

pDec1 = get(Axe_ImgDec_1,'Position');
pDec2 = get(Axe_ImgDec_2,'Position');
pDecF = get(Axe_ImgDec_Fus,'Position');
dy = pDec1(4)/4;
E  = 11*dy/60; 

xAR_ini = pDec1(1) + pDec1(3);
yAR_ini = pDec1(2) + pDec1(4)/2;
Pini  = [xAR_ini , yAR_ini];

x1 = 0;
x2 = pDec1(2)-pDec2(2);
x3 = pDec1(2)-pDecF(2);
XVal = [x1 , x2 , x3];
YVal = [E , 2.5*E , 6*E];

typeARROW_VER = 'special_1';
ar = wtbarrowX(typeARROW_VER,'axes',axe_arrow,...
    'XVal',XVal,'YVal',YVal, ...
    'HArrow',dy/4,'WArrow',dy/5,'Width',E, ...
    'Trans',Pini,'Rotation',pi/2, ...   
    'Color',colArrow,'Visible',visible);
xT = xAR_ini + 7*E;
yT = ((pDec1(2) + pDec1(2) + pDec1(4)/2)/2 + pDecF(2)+pDecF(4)/2)/2;
colorTXT = 'k';
t = text(...
    'Parent',axe_arrow,...    
    'Position',[xT yT],...
    'String','FUSION','Color',colorTXT,...
    'FontWeight','bold','FontSize',10,'Rotation',-90);
%-------------------------------------------------------------------------
% END: Arrows for WTBX FUSION TOOL 
%-------------------------------------------------------------------------

%--------------------------------------------------------------------------
function method = get_Fus_Param(type,handles)

switch type
    case 'app'
        Pop = handles.Pop_Fus_App;
        Edi = handles.Edi_Fus_App;
    case 'det'
        Pop = handles.Pop_Fus_Det;
        Edi = handles.Edi_Fus_Det;
end
numMeth = get(Pop,'Value');
tabMeth = get(Pop,'String');
methName = tabMeth{numMeth};
switch methName
    case {'max','min','mean','rand','img1','img2'} , 
        param = get(Edi,'String');
    case 'linear' ,  
        param = str2double(get(Edi,'String'));
    case {'UD_fusion','DU_fusion','LR_fusion','RL_fusion'}
        param = str2double(get(Edi,'String'));
    case 'userDEF' 
        tst_Fus_Param(Pop,Edi,[],handles);
        param = get(Edi,'String');        
end
method  = struct('name',methName,'param',param);
%--------------------------------------------------------------------------
function set_Fus_Param(Pop,Edi,Txt,eventdata,handles) %#ok<INUSD>

numMeth = get(Pop,'Value');
tabMeth = get(Pop,'String');
methName = tabMeth{numMeth};
switch methName
    case {'max','min','mean','rand','img1','img2'} , 
        vis = 'Off'; ediVAL = ''; txtSTR = '';
    case 'linear' ,  
        vis = 'On'; ediVAL = 0.5; txtSTR = '0 <= Param. <= 1';
    case {'UD_fusion','DU_fusion','LR_fusion','RL_fusion'}
        vis = 'On'; ediVAL = 1;   txtSTR = '0 <= Param.';
    case 'userDEF' 
        vis = 'On'; ediVAL = '';  txtSTR = 'Func. Name';
end
set(Txt,'String',txtSTR);
set(Edi,'String',num2str(ediVAL));
set([Edi,Txt],'Visible',vis);
%--------------------------------------------------------------------------
function ok = tst_Fus_Param(Pop,Edi,eventdata,handles) %#ok<INUSD>

numMeth = get(Pop,'Value');
tabMeth = get(Pop,'String');
methName = tabMeth{numMeth};
switch methName
    case 'linear' ,  
        def_ediVAL = 0.5;
        param = str2double(get(Edi,'String'));
        ok = ~isnan(param);
        if ok , ok = (0 <= param) & (param <= 1); end
        
    case {'UD_fusion','DU_fusion','LR_fusion','RL_fusion'}
        def_ediVAL = 1;
        param = str2double(get(Edi,'String'));
        ok = ~isnan(param);
        if ok , ok = (0 <= param); end
        
    case 'userDEF' 
        def_ediVAL = 'wfusfunX';
        param = get(Edi,'String');
        ok = ~isempty(param) & ischar(param);
        if ok ,
            userFusFUN = which(param);
            ok = ~isempty(userFusFUN);
        end
        
    otherwise
        ok = true; param = get(Edi,'String');
end
if ok , def_ediVAL = param; end
set(Edi,'String',num2str(def_ediVAL));
%--------------------------------------------------------------------------
function okSize = tst_ImageSize(hFig,numIMG,info_IMG)

tool_PARAMS = wtbxappdataX('get',hFig,'tool_PARAMS');  
switch numIMG
    case 1 , info_OTHER = tool_PARAMS.infoIMG_2;
    case 2 , info_OTHER = tool_PARAMS.infoIMG_1;
end
if isempty(info_OTHER)
    okSize = true;
else
    okSize = isequal(info_IMG.size,info_OTHER.size);
end
if ~okSize , dispWarnMessage(hFig); end
switch numIMG
    case 1 , tool_PARAMS.infoIMG_1 = info_IMG;
    case 2 , if okSize , tool_PARAMS.infoIMG_2 = info_IMG; end
end
wtbxappdataX('set',hFig,'tool_PARAMS',tool_PARAMS);
%--------------------------------------------------------------------------
function dispWarnMessage(hFig)

warnMsg = ...
    sprintf('The two images must be of the same size and of the same type.');
h = warndlg(warnMsg,'Caution','modal');
waitfor(h);
wwaitingX('off',hFig);
%------------------------------------------------------------------------
function setfigNAME(fig,flagIDX)

if flagIDX
    figNAME = 'Wavelet 2-D -- Image Fusion : Indexed Image';
else
    figNAME = 'Wavelet 2-D -- Image Fusion : Truecolor Image';
end
set(fig,'Name',figNAME);
%-------------------------------------------------------------------------
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%


%=========================================================================%
%                      BEGIN Demo Utilities                               %
%                      ---------------------                              %
%=========================================================================%
function closeDEMO(hFig,eventdata,handles) %#ok<INUSD,DEFNU>

close(hFig);
%----------------------------------------------------------
function demoPROC(hFig,eventdata,handles,varargin) %#ok<INUSL,DEFNU>

handles = guidata(hFig);
numDEM  = varargin{1};
demo_FUN(hFig,eventdata,handles,numDEM);
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%
