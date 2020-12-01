function ret = viewer3d_model(commandStr,entryStr,dataValue)



persistent handleStruct;       %---> handles to the gui controls
persistent dataStruct;         %---> Interessting data.
viewer3d_semaphore = 0; %---> used to block further calls to function when function is still active


if nargin<3
    dataValue = [];
else
    dataValue = dataValue(:,:,end:-1:1,:);
end
if nargin<2
    entryStr = '';
end
if nargin==0
    commandStr = 'init';
end



if strcmp(commandStr,'gui') & strcmp(entryStr,'gui_destroy') %---> free semaphore when gui will be destroyed
    viewer3d_semaphore=0;
end
if ~isempty(viewer3d_semaphore) & viewer3d_semaphore==1
    msgbox('Application is still busy. Please retry later ....');
    return;
else
    viewer3d_semaphore = 1;
end





if strcmp(commandStr,'init')
    dataStruct = viewer3d_internal(handleStruct,dataStruct,'database','input',dataValue);
    
    try                       %---> try/catch statements prevent termination of the program in case of an error
        handleStruct = local_init_handleStruct; %---> Note: local functions do not 'see' the persistent variables.
        dataStruct   = local_init_dataStruct(handleStruct,dataStruct);   %---> Therefore, dataStruct and handleStruct have to be set using the
    catch                                      %---> the local functions return values.
        warndlg(lasterr,'An error occured while initializing viewer3d_model');
    end
    
    handleStruct = updateAxes(handleStruct, dataStruct);
    set(handleStruct.status_TextBox, 'String', 'Status: OK');
    set(handleStruct.currentData_EditBox, 'String', dataStruct.currentData_EditBox);
    
    
elseif strcmp(commandStr,'struct')
    try
        if isempty(dataStruct)
            ret = local_init_dataStruct;
        else
            ret = dataStruct;
        end
    catch
        warning('An error occured while reading structure of viewer3d_model');
    end
    
    
    
elseif strcmp(commandStr,'get')
    try
        ret = local_get_dataStruct_entry(dataStruct,entryStr);
    catch
        warndlg(lasterr,'An error occured while reading an entry in viewer3d_model');
    end
    
    
    
elseif strcmp(commandStr,'set')
    try
        dataStruct = local_set_interface_entry(handleStruct,dataStruct,entryStr,dataValue);
    catch
        warndlg(lasterr,'An error occured while setting an entry in viewer3d_model');
    end
    
    
    
elseif strcmp(commandStr,'gui')
    [handleStruct, dataStruct] = local_handle_gui_event(handleStruct,dataStruct,entryStr);
    
    
    
elseif strcmp(commandStr,'return')
    try
        ret          = dataStruct;
        dataStruct   =[];
        handleStruct =[];
    catch
        warndlg(lasterr,'An error occured while returning results from viewer3d_model');
    end
    
    
    
else
    warning('Sorry, command switch was not recognized');
end


viewer3d_semaphore = 0;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  local functions  (main level)                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  handleStruct = local_init_handleStruct
handleStruct.viewer3d_figure = findobj('tag', 'viewer3d_figure');
handleStruct.d1d2_axes  = findobj('tag', 'viewer3d_d1d2_axes');
handleStruct.d2d3_axes  = findobj('tag', 'viewer3d_d2d3_axes');
handleStruct.d1d3_axes  = findobj('tag', 'viewer3d_d1d3_axes');
handleStruct.localizer_axes = findobj('tag', 'viewer3d_localizer_axes');
handleStruct.zoom_ToggleButton = findobj('tag', 'viewer3d_zoom_ToggleButton');
handleStruct.pan_ToggleButton = findobj('tag', 'viewer3d_pan_ToggleButton');
handleStruct.plot_ToggleButton = findobj('tag', 'viewer3d_plot_ToggleButton');
handleStruct.cursor_ToggleButton = findobj('tag', 'viewer3d_cursor_ToggleButton');
handleStruct.currentData_EditBox = findobj('tag', 'viewer3d_currentData_EditBox');
handleStruct.PlotInterval_EditBox = findobj('tag', 'viewer3d_PlotInterval_EditBox');
handleStruct.scaling_ToggleButton = findobj('tag', 'viewer3d_scaling_ToggleButton');
handleStruct.overlay_RadioButton = findobj('tag', 'viewer3d_overlay_RadioButton');
handleStruct.overlay_EditBox = findobj('tag', 'viewer3d_overlay_EditBox');
handleStruct.forth_dimension_slider = findobj('tag', 'viewer3d_forth_dimension_slider');
handleStruct.forth_dimension_textbox = findobj('tag', 'viewer3d_forth_dimension_textbox');
handleStruct.status_TextBox = findobj('tag', 'viewer3d_status_TextBox');
handleStruct.adjustAspectRatio_ToggleButton = findobj('tag', 'viewer3d_adjustAspectRatio_ToggleButton');

function  dataStruct = local_init_dataStruct(handleStruct,dataStruct)
dataStruct.pointer = round(size(dataStruct.data3d)/2);
dataStruct.xyz_coords = [0 0 0];
dataStruct.size_data3d = size(dataStruct.data3d);
dataStruct.crange_data3d = [min(dataStruct.data3d(:)), max(dataStruct.data3d(:))];
dataStruct.CameraPosition = [-3.6 -5.8 4.8];
dataStruct.overlayData = [];
dataStruct.crange_overlayData = [];
dataStruct.crange_overlayData = [];
[handleStruct, dataStruct] = local_handle_gui_event(handleStruct,dataStruct,'PlotInterval_EditBox');
[handleStruct, dataStruct] = local_handle_gui_event(handleStruct,dataStruct,'overlay_EditBox');
if length(size(dataStruct.data))==4
    set(handleStruct.forth_dimension_slider,'Min',1);
    set(handleStruct.forth_dimension_slider,'Max',size(dataStruct.data,4));
    set(handleStruct.forth_dimension_slider,'Value',1);
    set(handleStruct.forth_dimension_slider,'SliderStep',[1/(size(dataStruct.data,4)-1) 1/(size(dataStruct.data,4)-1)]);
    dataStruct.forth_dimension_slider = round(get(handleStruct.forth_dimension_slider,'Value'));
    set(handleStruct.forth_dimension_textbox,'String',{['Current 4d index: '],[num2str(dataStruct.forth_dimension_slider),'/',num2str(size(dataStruct.data,4))]});
    dataStruct.data3d = dataStruct.data(:,:,:,dataStruct.forth_dimension_slider);
else
    set(handleStruct.forth_dimension_slider,'Enable','off');
    set(handleStruct.forth_dimension_textbox,'Enable','off');
end

dataStruct.currentData_EditBox = '';

dataStruct.scaling_ToggleButton = get(handleStruct.scaling_ToggleButton, 'Value');
dataStruct.overlay_RadioButton = get(handleStruct.overlay_RadioButton, 'Value');
dataStruct.adjustAspectRatio_ToggleButton = get(handleStruct.adjustAspectRatio_ToggleButton, 'Value');

dataStruct.d1d2_axes_ButtonDownFcn = 'viewer3d_model(''gui'',''d1d2_axes_ButtonDownFcn'')';
dataStruct.d2d3_axes_ButtonDownFcn = 'viewer3d_model(''gui'',''d2d3_axes_ButtonDownFcn'')';
dataStruct.d1d3_axes_ButtonDownFcn = 'viewer3d_model(''gui'',''d1d3_axes_ButtonDownFcn'')';



function  dataEntry = local_get_dataStruct_entry(dataStruct,entryStr)

if strcmp(entryStr,'someSwitch')
    dataEntry = dataStruct.counts;
    
else
    warning('Sorry, entry switch was not recognized, no action performed');
end



function  dataStruct = local_set_interface_entry(handleStruct,dataStruct,entryStr,dataValue)

if strcmp(entryStr,'someSwitch') %---> the actual value is submitted in dataValue
    dataStruct = viewer3d_internal(handleStruct,dataStruct,'database',entryStr,dataValue);
    
    
else
    warning('Sorry, entry switch was not recognized, no action performed');
end



%--------------------%
% control gui events %
%--------------------%
function  [handleStruct, dataStruct] = local_handle_gui_event(handleStruct,dataStruct,entryStr)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(entryStr,'docancel')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    close(handleStruct.viewer3d_figure)
    h = findobj('tag','viewer3D_plot_figure');
    close(h);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr,'d1d2_axes_ButtonDownFcn')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p = getPosition;
    dataStruct = viewer3d_internal(handleStruct, dataStruct, 'database', 'pointer', [p(1),p(2),dataStruct.pointer(3)]);
    handleStruct = updateAxes(handleStruct, dataStruct);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr,'d2d3_axes_ButtonDownFcn')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p = getPosition;
    dataStruct = viewer3d_internal(handleStruct, dataStruct, 'database', 'pointer', [dataStruct.pointer(1),p(2),p(1)]);
    handleStruct = updateAxes(handleStruct, dataStruct);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr,'d1d3_axes_ButtonDownFcn')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p = getPosition;
    dataStruct = viewer3d_internal(handleStruct, dataStruct, 'database', 'pointer', [p(2),dataStruct.pointer(2),p(1)]);
    handleStruct = updateAxes(handleStruct, dataStruct);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'cursor_ToggleButton')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v = get(handleStruct.cursor_ToggleButton, 'Value');
    if v==1
        datacursormode on;
        if get(handleStruct.zoom_ToggleButton, 'Value')==1
            zoom off;
            set(handleStruct.zoom_ToggleButton, 'Value', 0);
        end
        if get(handleStruct.pan_ToggleButton, 'Value')==1
            pan off;
            set(handleStruct.pan_ToggleButton, 'Value', 0);
        end
        if get(handleStruct.plot_ToggleButton, 'Value')==1
            set(handleStruct.plot_ToggleButton, 'Value', 0);
        end
        set(handleStruct.status_TextBox, 'String', 'Cursor ON');
        drawnow;
    elseif v==0
        datacursormode off;
        set(handleStruct.status_TextBox, 'String', 'Cursor OFF');
        drawnow;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'zoom_ToggleButton')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v = get(handleStruct.zoom_ToggleButton, 'Value');
    if v==1
        zoom on;
        if get(handleStruct.pan_ToggleButton, 'Value')==1
            pan off;
            set(handleStruct.pan_ToggleButton, 'Value', 0);
        end
        if get(handleStruct.cursor_ToggleButton, 'Value')==1
            datacursormode off;
            set(handleStruct.cursor_ToggleButton, 'Value', 0);
        end
        if get(handleStruct.plot_ToggleButton, 'Value')==1
            set(handleStruct.plot_ToggleButton, 'Value', 0);
        end
        set(handleStruct.status_TextBox, 'String', 'Zoom ON');
        drawnow;
    elseif v==0
        zoom off;
        set(handleStruct.status_TextBox, 'String', 'Zoom OFF');
        drawnow;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'pan_ToggleButton')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v = get(handleStruct.pan_ToggleButton, 'Value');
    if v==1
        pan on;
        if get(handleStruct.zoom_ToggleButton, 'Value')==1
            zoom off;
            set(handleStruct.zoom_ToggleButton, 'Value', 0);
        end
        if get(handleStruct.cursor_ToggleButton, 'Value')==1
            datacursormode off;
            set(handleStruct.cursor_ToggleButton, 'Value', 0);
        end
        if get(handleStruct.plot_ToggleButton, 'Value')==1
            set(handleStruct.plot_ToggleButton, 'Value', 0);
        end
        set(handleStruct.status_TextBox, 'String', 'Pan ON');
        drawnow;
    elseif v==0
        pan off;
        set(handleStruct.status_TextBox, 'String', 'Pan OFF');
        drawnow;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'plot_ToggleButton')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v = get(handleStruct.plot_ToggleButton, 'Value');
    if v==1
        if get(handleStruct.pan_ToggleButton, 'Value')==1
            pan off;
            set(handleStruct.pan_ToggleButton, 'Value', 0);
        end
        if get(handleStruct.zoom_ToggleButton, 'Value')==1
            zoom off;
            set(handleStruct.zoom_ToggleButton, 'Value', 0);
        end
        if get(handleStruct.cursor_ToggleButton, 'Value')==1
            datacursormode off;
            set(handleStruct.cursor_ToggleButton, 'Value', 0);
        end
        set(handleStruct.status_TextBox, 'String', 'Plot ON');
        drawnow;
    elseif v==0
        set(handleStruct.status_TextBox, 'String', 'Plot OFF');
        drawnow;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'currentData_EditBox')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v = get(handleStruct.currentData_EditBox, 'String');
    try
        dataStruct.data = evalin('base', v);
        dataStruct.data = dataStruct.data(:,:,end:-1:1,:);
        if length(size(dataStruct.data))==4
            set(handleStruct.forth_dimension_slider,'Enable','on');
            set(handleStruct.forth_dimension_textbox,'Enable','on');
            set(handleStruct.forth_dimension_slider,'Min',1);
            set(handleStruct.forth_dimension_slider,'Max',size(dataStruct.data,4));
            set(handleStruct.forth_dimension_slider,'Value',1);
            set(handleStruct.forth_dimension_slider,'SliderStep',[1/(size(dataStruct.data,4)-1) 1/(size(dataStruct.data,4)-1)]);
            dataStruct.forth_dimension_slider = round(get(handleStruct.forth_dimension_slider,'Value'));
            set(handleStruct.forth_dimension_textbox,'String',['Current 4d index: ',num2str(dataStruct.forth_dimension_slider)]);
            dataStruct.data3d = dataStruct.data(:,:,:,dataStruct.forth_dimension_slider);
        else
            set(handleStruct.forth_dimension_slider,'Enable','off');
            set(handleStruct.forth_dimension_textbox,'Enable','off');
            dataStruct.data3d = dataStruct.data(:,:,:);
        end
        dataStruct.currentData_EditBox = v;
        dataStruct.size_data3d = size(dataStruct.data3d);
        dataStruct.crange_data3d = [min(dataStruct.data3d(:)), max(dataStruct.data3d(:))];
        handleStruct = updateAxes(handleStruct, dataStruct);
        [handleStruct, dataStruct] = local_handle_gui_event(handleStruct,dataStruct,'PlotInterval_EditBox');
        set(handleStruct.status_TextBox, 'String', 'Status: OK.');
    catch
        set(handleStruct.status_TextBox, 'String', 'Specified workspace variable does not exist.');
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'PlotInterval_EditBox')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v = get(handleStruct.PlotInterval_EditBox, 'String');
    try
        if strcmp(v(end-2:end), 'end')
            dataStruct.PlotInterval = str2double(v(1:end-4)):size(dataStruct.data, 4);
        else
            dataStruct.PlotInterval = evalin('base', v);
        end
        set(handleStruct.status_TextBox, 'String', 'Status: OK.');
    catch
        set(handleStruct.status_TextBox, 'String', 'Specified interval does not make sense.');
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'scaling_ToggleButton')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v = get(handleStruct.scaling_ToggleButton, 'Value');
    dataStruct.scaling_ToggleButton = v;
    handleStruct = updateAxes(handleStruct, dataStruct);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'overlay_EditBox')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v = get(handleStruct.overlay_EditBox, 'String');
    try
        dataStruct.overlayData = evalin('base', v);
        dataStruct.overlayData = dataStruct.overlayData(:,:,end:-1:1);
        dataStruct.overlay_EditBox = v;
        dataStruct.crange_overlayData = [min(dataStruct.overlayData(:)), max(dataStruct.overlayData(:))];
        handleStruct = updateAxes(handleStruct, dataStruct);
        set(handleStruct.status_TextBox, 'String', 'Status: OK.');
    catch
        set(handleStruct.status_TextBox, 'String', 'Specified workspace variable does not exist.');
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'forth_dimension_slider')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dataStruct.forth_dimension_slider = round(get(handleStruct.forth_dimension_slider, 'Value'));
    dataStruct.data3d = dataStruct.data(:,:,:,dataStruct.forth_dimension_slider);
    set(handleStruct.forth_dimension_textbox,'String',{['Current 4d index: '],[num2str(dataStruct.forth_dimension_slider), '/', num2str(size(dataStruct.data,4))]});
    handleStruct = updateAxes(handleStruct, dataStruct);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'overlay_RadioButton')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v = get(handleStruct.overlay_RadioButton, 'Value');
    dataStruct.overlay_RadioButton = v;
    handleStruct = updateAxes(handleStruct, dataStruct);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'adjustAspectRatio_ToggleButton')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v = get(handleStruct.adjustAspectRatio_ToggleButton, 'Value');
    dataStruct.adjustAspectRatio_ToggleButton = v;
    handleStruct = updateAxes(handleStruct, dataStruct);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(entryStr, 'close_PushButton')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    close(handleStruct.viewer3d_figure);
    h = findobj('tag','viewer3D_plot_figure');
    close(h);
    
else
    warning('Sorry, entry switch was not recognized, no action performed');
end



%-----------------%
% local functions %
%-----------------%

function handleStruct = updateAxes(handleStruct, dataStruct)

if ~isempty(dataStruct.data3d)
    axes(handleStruct.d1d2_axes);
    if dataStruct.overlay_RadioButton==1 && ~isempty(dataStruct.overlayData)
        image(overlay(squeeze(dataStruct.data3d(:,:,dataStruct.pointer(3))), squeeze(dataStruct.overlayData(:,:,dataStruct.pointer(3))), [dataStruct.crange_data3d(1) dataStruct.crange_data3d(2)], [dataStruct.crange_overlayData(1) dataStruct.crange_overlayData(2)] ));
    else
        imagesc(squeeze(dataStruct.data3d(:,:,dataStruct.pointer(3))));
        if dataStruct.scaling_ToggleButton~=1
            caxis(dataStruct.crange_data3d);
        end
        colormap gray;
    end
    if dataStruct.adjustAspectRatio_ToggleButton==1
        set(gca, 'PlotBoxAspectRatio', [dataStruct.size_data3d(2), dataStruct.size_data3d(1), 1]);
    end
    % The ButtonDownFcn has to be updated each time a new image is plotted!
    handleStruct.d1d2_cdata = get(gca, 'Children');
    set(handleStruct.d1d2_cdata, 'ButtonDownFcn', dataStruct.d1d2_axes_ButtonDownFcn);
    
    axes(handleStruct.d2d3_axes);
    if dataStruct.overlay_RadioButton==1 && ~isempty(dataStruct.overlayData)
        image(overlay(squeeze(dataStruct.data3d(dataStruct.pointer(1),:,:))' , squeeze(dataStruct.overlayData(dataStruct.pointer(1),:,:))', [dataStruct.crange_data3d(1) dataStruct.crange_data3d(2)], [dataStruct.crange_overlayData(1) dataStruct.crange_overlayData(2)] ));
    else
        imagesc(squeeze(dataStruct.data3d(dataStruct.pointer(1),:,:))');
        if dataStruct.scaling_ToggleButton~=1
            caxis(dataStruct.crange_data3d);
        end
        colormap gray;
    end
    if dataStruct.adjustAspectRatio_ToggleButton==1
        set(gca, 'PlotBoxAspectRatio', [dataStruct.size_data3d(2), dataStruct.size_data3d(3), 1]);
    end
    handleStruct.d2d3_cdata = get(gca, 'Children');
    set(handleStruct.d2d3_cdata, 'ButtonDownFcn', dataStruct.d2d3_axes_ButtonDownFcn);
    
    axes(handleStruct.d1d3_axes);
    if dataStruct.overlay_RadioButton==1 && ~isempty(dataStruct.overlayData)
        image(overlay(squeeze(dataStruct.data3d(:,dataStruct.pointer(2),:))' , squeeze(dataStruct.overlayData(:,dataStruct.pointer(2),:))', [dataStruct.crange_data3d(1) dataStruct.crange_data3d(2)], [dataStruct.crange_overlayData(1) dataStruct.crange_overlayData(2)]));
    else
        imagesc(squeeze(dataStruct.data3d(:,dataStruct.pointer(2),:))');
        if dataStruct.scaling_ToggleButton~=1
            caxis(dataStruct.crange_data3d);
        end
        colormap gray;
    end
    if dataStruct.adjustAspectRatio_ToggleButton==1
        set(gca, 'PlotBoxAspectRatio', [dataStruct.size_data3d(1), dataStruct.size_data3d(3), 1]);
    end
    handleStruct.d1d3_cdata = get(gca, 'Children');
    set(handleStruct.d1d3_cdata, 'ButtonDownFcn', dataStruct.d1d3_axes_ButtonDownFcn);
    
    axes(handleStruct.localizer_axes);
    cla;
    hold on;
    x = dataStruct.xyz_coords(1);
    y = dataStruct.xyz_coords(2);
    z = dataStruct.xyz_coords(3);
    line([x x], [-1 -1], [-1 1],'Color','r');
    line([x x], [1 1], [-1 1],'Color','r');
    line([x x], [-1 1], [-1 -1],'Color','r');
    line([x x], [-1 1], [1 1],'Color','r');
    line([x x], [-1 1], [z z],'Color','r');
    
    
    line([-1 -1], [y y], [-1 1],'Color','g');
    line([1 1], [y y], [-1 1],'Color','g');
    line([-1 1], [y y], [-1 -1],'Color','g');
    line([-1 1], [y y], [1 1],'Color','g');
    line([x x], [y y], [-1 1],'Color','g');
    
    line([-1 1], [-1 -1], [z z]);
    line([-1 1], [1 1], [z z]);
    line([-1 -1], [-1 1], [z z]);
    line([1 1], [-1 1], [z z]);
    line([-1 1], [y y], [z z]);
    
    line([1 1], [-1 -1], [-1 1], 'Color', 'k');
    line([-1 1], [1 1], [1 1], 'Color', 'k');
    line([1 1], [-1 1], [1 1], 'Color', 'k');
    line([1 1], [-1 1], [-1 -1], 'Color', [0.8 0.8 0.8]);
    line([-1 1], [1 1], [-1 -1], 'Color', [0.8 0.8 0.8]);
    line([1 1], [1 1], [-1 1], 'Color', [0.8 0.8 0.8]);
    
    set(gca, 'CameraPosition', dataStruct.CameraPosition);
    box off;
    set(gca, 'XTick', []); set(gca, 'YTick', []); set(gca, 'ZTick', []);
    set(gca, 'XLim', [-1 1]); set(gca, 'YLim', [-1 1]); set(gca, 'ZLim', [-1 1]);
    if dataStruct.adjustAspectRatio_ToggleButton==1
        set(gca, 'PlotBoxAspectRatio', [dataStruct.size_data3d(2), dataStruct.size_data3d(1), dataStruct.size_data3d(3)]);
    else
        set(gca, 'PlotBoxAspectRatioMode', 'auto');
    end
    
end

function pos = getPosition
pos = get(gca, 'CurrentPoint');
pos = pos(1,[2 1]);
