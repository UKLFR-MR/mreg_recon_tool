function viewer3d_tool(data)

% A tool to display 3d data.
%
% 30.09.2011
% Thimo Hugger
%


%---------------------------------------%
% close windows/tools if already opened %
%---------------------------------------%
fig = findobj('tag','viewer3d_figure');
if ~isempty(fig)
   close(fig);
end

%--------------------------------%
% create GUI and init structures %
%--------------------------------%
fig=openfig('viewer3d.fig'); 
viewer3d_model('init','input',data);


%--------------------------------------------------------------%
% read data structure and return value of interest if expected %
%--------------------------------------------------------------%
if nargout~=0
   waitfor(fig);
   dataStruct  = viewer3d_model('return');
   if ~isempty(dataStruct)
      %ret = dataStruct.data;
   end
end