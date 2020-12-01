function [ret1,ret2] = viewer3d_internal(handleStruct,dataStruct,commandStr,entryStr,dataValue)


ret1 = dataStruct;
ret2 = handleStruct;
if nargin==4
    dataValue = [];
end



if strcmp(commandStr,'database')
      dataStruct = local_set_dataStruct_entry(handleStruct,dataStruct,entryStr,dataValue);
      ret1 = dataStruct;

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  main local functions                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  dataStruct = local_set_dataStruct_entry(handleStruct,dataStruct,entryStr,dataValue)

persistent h;

if strcmp(entryStr,'input')
    dataStruct.data = dataValue;
    if length(size(dataValue))==4
        dataStruct.data3d = dataValue(:,:,:,1);
    else
        dataStruct.data3d = dataValue;
    end
    
elseif strcmp(entryStr,'pointer')
    if get(handleStruct.plot_ToggleButton, 'Value')
        if isempty(h) || ~ishandle(h) || ~strcmp(get(h,'Tag'),'viewer3D_plot_figure');
            h = figure('Tag','viewer3D_plot_figure');
        end
        if gcf~=h
            set(0,'CurrentFigure',h);
        end
        dataValue = round(dataValue);
        plot(squeeze(dataStruct.data(dataValue(1), dataValue(2), dataValue(3), dataStruct.PlotInterval)));
        printValue = dataValue;
        printValue(3) = size(dataStruct.data, 3) - dataValue(3) +1;
        title(num2str(printValue));
    else
        for k=1:3
            if dataValue(k)<1
                dataStruct.pointer(k) = 1;
            elseif dataValue(k)>dataStruct.size_data3d(k)
                dataStruct.pointer(k) = dataStruct.size_data3d(k);
            else
                dataStruct.pointer(k) = round(dataValue(k));
            end
        end
        dataStruct.xyz_coords = dataStruct.pointer./dataStruct.size_data3d;
        dataStruct.xyz_coords = 2*[dataStruct.xyz_coords(2), dataStruct.xyz_coords(1), dataStruct.xyz_coords(3)] - 1;
        dataStruct.xyz_coords = [dataStruct.xyz_coords(1), -dataStruct.xyz_coords(2), -dataStruct.xyz_coords(3)];
    end
else
    warning('Sorry, entry switch was not recognized, no action performed');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  more local functions  (utilities)                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function  dataStruct = local_do_something(handleStruct,dataStruct)


%function  aReturnValue = local_do_something_else(aSwitch)