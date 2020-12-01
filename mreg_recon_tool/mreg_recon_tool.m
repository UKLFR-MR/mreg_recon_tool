function varargout = mreg_recon_tool(varargin)

% function varargout = mreg_recon_tool(varargin)
%
% Graphical user interface for the reconstruction of undersampled
% noncartesian multi coil data.
%
% Thimo Hugger
% 23.09.2011

% BR: modified some code for the DORK correction. The actual implementation only works for single segment trajectories!


% inititalize the data structure

%%% For the grid engine
%setenv('PATH',[getenv('PATH') ':/usr/local/sge_amd/bin/lx24-amd64']);
%setenv('SGE_ROOT','/usr/local/sge_amd');

delay = [-3.7 -3 -3]; %PRISMA in Freiburg
%delay = [0 0 0];

D = struct;

D.gui_data.select_operator_string = {'Identity','Total Variation','Wavelet Transform'};
D.gui_data.sensmode_pm_string = {'adapt','sos','lowres','unknown'};
D.gui_data.select_view_reference_string = {''};
D.gui_data.temporal_recon_type_string = {'standard','sliding window','KWIC'};
D.gui_data.recon_output_format_string = {'mat','nifti'};
D.gui_data.select_norm_string = {'L2-norm','L1-norm'};
D.gui_data.lambda_default = 0.2;
D.gui_data.z0 = 0;
D.gui_data.z0_details = [];
D.gui_data.add_penalty_counter = 0;
D.gui_data.default_folder = pwd;
D.gui_data.working_directory = pwd;
D.gui_data.save_folder_name = '';
D.gui_data.rawdata_filename = '';
D.gui_data.reference_filename = '';
D.gui_data.trajectory_filename = '';

D.check.rawdata_loaded_flag = 0;
D.check.reference_loaded_flag = 0;
D.check.trajectory_loaded_flag = 0;
D.check.adjust_reference_and_trajectory_flag = 0;
D.check.recon_finished_flag = 0;
D.check.save_during_recon = 0;

D.recon.recon_details.timeframes = [];
D.recon.recon_details.timeframes_string = '';
D.recon.recon_details.cg_method = 'fr+pr';
D.recon.recon_details.recon_resolution = [];
D.recon.recon_details.recon_voxel_size = [];
D.recon.recon_details.trajectory_scaling = [];
D.recon.recon_details.nCoils = 0;
D.recon.recon_details.pname = [];
D.recon.recon_details.z0 = 0;
D.recon.recon_details.z0_details = [];
D.recon.recon_details.DORK_frequency = [];
D.recon.recon_details.DORK_k0 = [];
D.recon.recon_details.global_frequency_shift = 0;
D.recon.recon_details.DeltaT = 0;

D.param.recon_dimension = 3; % by default it is assumed that the reconstructed image will be 3D
D.param.sensmode = 'adapt';
    

% misc
active_flag_color = [0.5 1 0.5];
not_active_flag_color = [0.7 0.7 0.7];

% create gui objects and their handles
pb_width   = 120; % width of a push button
pb_height  = 25; % push button height
tb_height  = 15; % textbox height
knob_width = 20; % width of some smaller push buttons
cb_width   = pb_width; % width of a checkbox
cb_height  = 15; % push button height
spacing    = 5; % typical spacing inbetween gui elements
panel_height = 225; % height of the upper panels
panel_height2 = 430; % height of the recon panel
border_spacing = 3*spacing;
font_size = 10;
font_units = 'pixels';

H.main_fig = figure('Position',[380, 320, 2*border_spacing+5*pb_width+14*spacing, panel_height2+2*border_spacing+3*spacing+2*pb_height],'NumberTitle','off','Name','mreg_recon_tool','MenuBar','none','Color',[0.8 0.8 0.8],'Interruptible','off','BusyAction','queue');
p_main = get(H.main_fig,'Position');

H.set_path_pb = uicontrol(H.main_fig,'Style','PushButton','Units','pixels','String','Set Working Dir','Position',[border_spacing+spacing, p_main(4)-pb_height-border_spacing, pb_width, pb_height],'Callback',{@set_path_pb_cb});
p = get(H.set_path_pb,'Position');
H.set_path_e = uicontrol(H.main_fig,'Style','Edit','Units','pixels','String',D.gui_data.working_directory,'Position',[p(1)+p(3)+3*spacing, p(2), p_main(3)-2*pb_width-8*spacing-2*border_spacing, pb_height],'BackgroundColor','white','HorizontalAlignment','left');
p = get(H.set_path_e,'Position');
H.set_path_e = uicontrol(H.main_fig,'Style','PushButton','Units','pixels','String','Export Settings','Position',[p(1)+p(3)+3*spacing, p(2), pb_width, pb_height],'Callback',{@export_settings_pb_cb});

% rawdata panel
p = get(H.set_path_e,'Position');
H.load_rawdata_panel = uipanel('Units','pixels','Position',[border_spacing, p(2)-panel_height-spacing, pb_width+2*spacing, panel_height]);
p = [spacing,panel_height,pb_width,pb_height];
H.load_rawdata_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.load_rawdata_panel,'String','Load RawData','Position',[spacing,p(2)-pb_height-spacing,pb_width-knob_width,pb_height],'Callback',{@load_rawdata_pb_cb});
H.clear_rawdata_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.load_rawdata_panel,'String','X','Position',[spacing+pb_width-knob_width,p(2)-pb_height-spacing,knob_width,pb_height],'Callback',{@clear_rawdata_pb_cb});
p = get(H.load_rawdata_pb,'Position');
H.rawdata_info_label_t = uicontrol(H.main_fig,'Style','Text','Parent',H.load_rawdata_panel,'String','Parameters','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.rawdata_info_t = uicontrol(H.main_fig,'Style','Text','Parent',H.load_rawdata_panel,'String',{''},'Position',[spacing,spacing,pb_width,p(2)-2*spacing],'BackgroundColor','white');

% reference panel
p = get(H.load_rawdata_panel,'Position');
H.load_reference_panel = uipanel('Units','pixels','Position',[p(1)+p(3)+spacing, p(2), pb_width+2*spacing, panel_height]);
p = [spacing,panel_height,pb_width,pb_height];
H.load_reference_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.load_reference_panel,'String','Load Reference','Position',[spacing,p(2)-pb_height-spacing,pb_width-knob_width,pb_height],'Callback',{@load_reference_pb_cb});
H.clear_reference_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.load_reference_panel,'String','X','Position',[spacing+pb_width-knob_width,p(2)-pb_height-spacing,knob_width,pb_height],'Callback',{@clear_reference_pb_cb});
p = get(H.load_reference_pb,'Position');
H.reference_info_label_t = uicontrol(H.main_fig,'Style','Text','Parent',H.load_reference_panel,'String','Parameters','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.reference_info_t = uicontrol(H.main_fig,'Style','Text','Parent',H.load_reference_panel,'String',{''},'Position',[spacing,p(2)-2*tb_height-tb_height-spacing,pb_width,2*tb_height],'BackgroundColor','white');
p = get(H.reference_info_t,'Position');
H.sensmode_t = uicontrol(H.main_fig,'Style','Text','Parent',H.load_reference_panel,'String','Sens. Mode','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.sensmode_pm = uicontrol(H.main_fig,'Style','PopupMenu','Parent',H.load_reference_panel,'String',D.gui_data.sensmode_pm_string,'Position',[spacing,p(2)-pb_height-tb_height-spacing,pb_width,pb_height],'Callback',{@sensmode_pm_cb});
p = get(H.sensmode_pm,'Position');
H.select_view_reference_t = uicontrol(H.main_fig,'Style','Text','Parent',H.load_reference_panel,'String','Select View','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.select_view_reference_pm = uicontrol(H.main_fig,'Style','PopupMenu','Parent',H.load_reference_panel,'String',D.gui_data.select_view_reference_string,'Position',[spacing,p(2)-pb_height-tb_height-spacing,pb_width,pb_height],'Callback',{@select_view_reference_pm_cb});
p = get(H.select_view_reference_pm,'Position');
H.save_reference_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.load_reference_panel,'String','Save','Position',[spacing,p(2)-pb_height-spacing,pb_width/2,pb_height],'Callback',{@save_reference_pb_cb});
H.view_reference_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.load_reference_panel,'String','View','Position',[spacing+pb_width/2,p(2)-pb_height-spacing,pb_width/2,pb_height],'Callback',{@view_reference_pb_cb});

% trajectory panel
p = get(H.load_reference_panel,'Position');
H.load_trajectory_panel = uipanel('Units','pixels','Position',[p(1)+p(3)+spacing, p(2), pb_width+2*spacing, panel_height]);
p = [spacing,panel_height,pb_width,pb_height];
H.load_trajectory_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.load_trajectory_panel,'String','Load Trajectory','Position',[spacing,p(2)-pb_height-spacing,pb_width-knob_width,pb_height],'Callback',{@load_trajectory_pb_cb});
H.clear_trajectory_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.load_trajectory_panel,'String','X','Position',[spacing+pb_width-knob_width,p(2)-pb_height-spacing,knob_width,pb_height],'Callback',{@clear_trajectory_pb_cb});
p = get(H.load_trajectory_pb,'Position');
H.trajectory_info_label_t = uicontrol(H.main_fig,'Style','Text','Parent',H.load_trajectory_panel,'String','Parameters','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.trajectory_info_t = uicontrol(H.main_fig,'Style','Text','Parent',H.load_trajectory_panel,'String',{''},'Position',[spacing,p(2)-2*tb_height-tb_height-spacing,pb_width,2*tb_height],'BackgroundColor','white');
p = get(H.trajectory_info_t,'Position');
H.select_range_trajectory_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.load_trajectory_panel,'String','Select Range','Position',[spacing,p(2)-pb_height-spacing,pb_width,pb_height],'Callback',{@select_range_trajectory_pb_cb});
p = get(H.select_range_trajectory_pb,'Position');
H.trajectory_range_info_pm = uicontrol(H.main_fig,'Style','PopupMenu','Parent',H.load_trajectory_panel,'String',{''},'Position',[spacing,p(2)-pb_height-spacing,pb_width,pb_height],'BackgroundColor','white');
p = get(H.trajectory_range_info_pm,'Position');
H.interleaves_t = uicontrol(H.main_fig,'Style','Text','Parent',H.load_trajectory_panel,'String','#Interleaves','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.interleaves_e = uicontrol(H.main_fig,'Style','Edit','Parent',H.load_trajectory_panel,'String','1','Position',[spacing,p(2)-pb_height-tb_height-spacing,pb_width,pb_height],'BackgroundColor','white','Callback',{@interleaves_e_cb});
p = get(H.interleaves_e,'Position');
H.save_trajectory_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.load_trajectory_panel,'String','Save','Position',[spacing,p(2)-pb_height-spacing,pb_width/2,pb_height],'Callback',{@save_trajectory_pb_cb});
H.view_trajectory_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.load_trajectory_panel,'String','View','Position',[spacing+pb_width/2,p(2)-pb_height-spacing,pb_width/2,pb_height],'Callback',{@view_trajectory_pb_cb});

% recon parameters panel 1
p = get(H.load_trajectory_panel,'Position');
H.recon_parameters_panel_1 = uipanel('Units','pixels','Position',[p(1)+p(3)+spacing, p(2), pb_width+2*spacing, panel_height]);
p = [spacing,panel_height,pb_width,pb_height];
H.tolerance_t = uicontrol(H.main_fig,'Style','Text','Parent',H.recon_parameters_panel_1,'String','CG Tolerance','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.tolerance_e = uicontrol(H.main_fig,'Style','Edit','Parent',H.recon_parameters_panel_1,'String','1e-5','Position',[spacing,p(2)-pb_height-tb_height-spacing,pb_width,pb_height],'BackgroundColor','white','Callback',{@tolerance_e_cb});
p = get(H.tolerance_e,'Position');
H.max_iterations_t = uicontrol(H.main_fig,'Style','Text','Parent',H.recon_parameters_panel_1,'String','Max. Iterations','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.max_iterations_e = uicontrol(H.main_fig,'Style','Edit','Parent',H.recon_parameters_panel_1,'String','20','Position',[spacing,p(2)-pb_height-tb_height-spacing,pb_width,pb_height],'BackgroundColor','white','Callback',{@max_iterations_e_cb});
p = get(H.max_iterations_e,'Position');
p(2)=p(2)-10;
H.recon_resolution_t = uicontrol(H.main_fig,'Style','Text','Parent',H.recon_parameters_panel_1,'String','Recon Size','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.recon_resolution_e = uicontrol(H.main_fig,'Style','Edit','Parent',H.recon_parameters_panel_1,'Enable','off','String','','Position',[spacing,p(2)-pb_height-tb_height-spacing,pb_width,pb_height],'BackgroundColor','white','Callback',{@recon_resolution_e_cb});
p = get(H.recon_resolution_e,'Position');
H.recon_voxel_size_t = uicontrol(H.main_fig,'Style','Text','Parent',H.recon_parameters_panel_1,'String','Voxel Size [mm]','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.recon_voxel_size_e = uicontrol(H.main_fig,'Style','Edit','Parent',H.recon_parameters_panel_1,'Enable','off','String','','Position',[spacing,p(2)-pb_height-tb_height-spacing,pb_width,pb_height],'BackgroundColor','white','Callback',{@recon_voxel_size_e_cb});
p = get(H.recon_voxel_size_e,'Position');
H.adjust_reference_and_trajectory_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.recon_parameters_panel_1,'Enable','off','String','Adjust','Position',[spacing,p(2)-pb_height-spacing,pb_width,pb_height],'Callback',{@adjust_reference_and_trajectory_pb_cb});

% recon panel
p = get(H.recon_parameters_panel_1,'Position');
H.recon_panel = uipanel('Units','pixels','Position',[p(1)+p(3)+spacing, p_main(4)-panel_height2-border_spacing-spacing-pb_height, pb_width+2*spacing, panel_height2]);
p = [spacing,panel_height2,pb_width,pb_height];
H.temporal_recon_type_t = uicontrol(H.main_fig,'Style','Text','Parent',H.recon_panel,'String','Recon Type','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.temporal_recon_type_pm = uicontrol(H.main_fig,'Style','PopupMenu','Parent',H.recon_panel,'String',D.gui_data.temporal_recon_type_string,'Position',[spacing,p(2)-pb_height-tb_height-spacing,pb_width,pb_height],'Callback',{@temporal_recon_type_pm_cb});
p = get(H.temporal_recon_type_pm,'Position');
H.offresonance_correction_cb = uicontrol(H.main_fig,'Style','CheckBox','Parent',H.recon_panel,'String','Off-Res. Corr.','Value',0,'Position',[spacing,p(2)-cb_height-spacing,cb_width,cb_height],'Callback',{@offresonance_correction_cb_cb});
p = get(H.offresonance_correction_cb,'Position');
H.z0_cb = uicontrol(H.main_fig,'Style','CheckBox','Parent',H.recon_panel,'String','z0','Value',0,'Position',[spacing,p(2)-cb_height-spacing,cb_width,cb_height],'Enable', 'off', 'Callback',{@z0_cb_cb});
p = get(H.z0_cb,'Position');
H.DORK_cb = uicontrol(H.main_fig,'Style','CheckBox','Parent',H.recon_panel,'String','DORK','Value',0,'Position',[spacing,p(2)-cb_height-spacing,cb_width,cb_height],'Enable', 'on', 'Callback',{@DORK_cb_cb});
p = get(H.DORK_cb,'Position');
H.global_or_shift_t = uicontrol(H.main_fig,'Style','Text','Parent',H.recon_panel,'String','4D Global ORC [rad/s]','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.global_or_shift_e = uicontrol(H.main_fig,'Style','Edit','Parent',H.recon_panel,'String','0','Position',[spacing,p(2)-pb_height-tb_height-spacing,pb_width,pb_height],'BackgroundColor','white','Callback',{@global_or_shift_e_cb},'Callback',{@global_or_shift_e_cb});
p = get(H.global_or_shift_e,'Position');
%H.use_gridengine_cb = uicontrol(H.main_fig,'Style','CheckBox','Parent',H.recon_panel,'String','Use GridEngine','Value',0,'Position',[spacing,p(2)-cb_height-spacing,cb_width,cb_height],'Callback',{@use_gridengine_cb_cb});
%p = get(H.use_gridengine_cb,'Position');
H.use_slurm_cb = uicontrol(H.main_fig,'Style','CheckBox','Parent',H.recon_panel,'String','Use Slurm','Value',0,'Position',[spacing,p(2)-cb_height-spacing,cb_width,cb_height],'Callback',{@use_slurm_cb_cb});
p = get(H.use_slurm_cb,'Position');
H.frames_per_job_t = uicontrol(H.main_fig,'Style','Text','Parent',H.recon_panel,'String','Frames per Job','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.frames_per_job_e = uicontrol(H.main_fig,'Style','Edit','Parent',H.recon_panel,'String','20','Position',[spacing,p(2)-pb_height-tb_height-spacing,pb_width,pb_height],'BackgroundColor','white','Callback',{@frames_per_job_e_cb},'Callback',{@frames_per_job_e_cb});
p = get(H.frames_per_job_e,'Position');
H.recon_range_t = uicontrol(H.main_fig,'Style','Text','Parent',H.recon_panel,'String','Timeframe Range','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.recon_range_e = uicontrol(H.main_fig,'Style','Edit','Parent',H.recon_panel,'String','','Position',[spacing,p(2)-pb_height-tb_height-spacing,pb_width,pb_height],'BackgroundColor','white','Callback',{@recon_range_e_cb});
p = get(H.recon_range_e,'Position');
H.recon_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.recon_panel,'String','Start Recon','Position',[spacing,p(2)-pb_height-spacing,pb_width,pb_height],'Callback',{@recon_pb_cb});
p = get(H.recon_pb,'Position');
H.save_during_recon_cb = uicontrol(H.main_fig,'Style','CheckBox','Parent',H.recon_panel,'String','Save during recon','Value',D.check.save_during_recon,'Position',[spacing,p(2)-pb_height-spacing,pb_width,pb_height],'Callback',{@save_during_recon_cb_cb});
p = get(H.save_during_recon_cb,'Position');
H.recon_output_format_t = uicontrol(H.main_fig,'Style','Text','Parent',H.recon_panel,'String','Save as ...','Position',[spacing,p(2)-tb_height-spacing,pb_width,tb_height],'HorizontalAlignment','left');
H.recon_output_format_pm = uicontrol(H.main_fig,'Style','PopupMenu','Parent',H.recon_panel,'String',D.gui_data.recon_output_format_string,'Position',[spacing,p(2)-pb_height-spacing-tb_height,(pb_width-spacing)/2,pb_height],'Callback',{@recon_output_format_pm_cb});
H.save_where_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.recon_panel,'String','Where','Position',[spacing+pb_width/2,p(2)-pb_height-spacing-tb_height,pb_width/2,pb_height],'Callback',{@save_where_pb_cb});
p = get(H.recon_output_format_pm,'Position');
H.save_recon_as_file_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.recon_panel,'String','Save File','Position',[spacing,p(2)-pb_height-spacing,(pb_width-spacing)/2,pb_height],'Callback',{@save_recon_as_file_pb_cb});
H.save_recon_in_workspace_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.recon_panel,'String','Save WS','Position',[spacing+pb_width/2,p(2)-pb_height-spacing,pb_width/2,pb_height],'Callback',{@save_recon_in_workspace_pb_cb});
p = get(H.save_recon_as_file_pb,'Position');
H.view_recon_pb = uicontrol(H.main_fig,'Style','PushButton','Parent',H.recon_panel,'String','View','Position',[spacing,p(2)-pb_height-spacing,pb_width,pb_height],'Callback',{@view_recon_pb_cb});

% p = get(H.recon_panel,'Position');
% set(H.main_fig,'Position',[p_main(1), p_main(2), p(1)+p(3)+border_spacing, p_main(4)]);
% p_main = get(H.main_fig,'Position');
% p = get(H.set_path_e,'Position');
% set(H.set_path_e,'Position',[p(1) p(2) p_main(3)-2*pb_width-8*spacing-2*border_spacing p(4)]);

p = get(H.load_rawdata_panel,'Position');
H.penalities_t = uicontrol(H.main_fig,'Style','Text','String','Penalties','Position',[p(1)+spacing, p(2)-tb_height-spacing, pb_width, tb_height]);
H.add_penalty_pb = uicontrol(H.main_fig,'Style','PushButton','String','Add','Position',[p(1)+pb_width/2+spacing, p(2)-pb_height-tb_height-spacing, pb_width/2, pb_height],'Callback',{@add_penalty_pb_cb});

% remaining elements
p = get(H.recon_panel,'Position');
H.status_t = uicontrol(H.main_fig,'Style','Edit','String','','Position',[border_spacing, p(2)-pb_height-spacing, 4*pb_width+3*3*spacing+2*spacing pb_height],'BackgroundColor','white','Callback',{@status_t_cb});
p = get(H.status_t,'Position');
H.quit_pb = uicontrol(H.main_fig,'Style','PushButton','String','Quit','Tag','closeb','Position',[p(1)+p(3)+2*spacing, p(2), pb_width, pb_height],'Callback',{@quit_pb_cb});


% initialize objects
D.recon.recon_details.nInterleaves = str2num(get(H.interleaves_e,'String'));
D.recon.recon_details.tolerance = str2num(get(H.tolerance_e,'String'));
D.recon.recon_details.max_iterations = str2num(get(H.max_iterations_e,'String'));
D.recon.recon_details.offresonance_correction_flag = get(H.offresonance_correction_cb,'Value');
D.recon.recon_details.recon_output_format = D.gui_data.recon_output_format_string{get(H.recon_output_format_pm,'Value')};
set(H.sensmode_pm,'Value',2);

D.param.frames_per_job = str2num(get(H.frames_per_job_e,'String'));
%D.param.use_gridengine = get(H.use_gridengine_cb,'Value');
D.param.use_slurm = get(H.use_slurm_cb,'Value');

use_slurm_cb_cb;
select_view_reference_pm_cb;
sensmode_pm_cb([],[],D.param.sensmode);
temporal_recon_type_pm_cb;

local_set_gui_font_size(font_size);


if nargin==1
    if exist(varargin{1},'file')
        L = load(varargin{1});
        settings = L.settings;
        clear L;
    else
        settings = varargin{1};
    end
    
    if ~isempty(settings.gui_data.rawdata_filename)
        load_rawdata_pb_cb([],[],settings.gui_data.rawdata_filename);
    end
    if ~isempty(settings.gui_data.reference_filename)
        load_reference_pb_cb([],[],settings.gui_data.reference_filename);
        sensmode_pm_cb([],[],settings.param.sensmode);
    end
    if ~isempty(settings.gui_data.trajectory_filename)
        load_trajectory_pb_cb([],[],settings.gui_data.trajectory_filename,settings.recon.recon_details.nInterleaves);
    end
    if ~isempty(settings.gui_data.rawdata_filename) && ~isempty(settings.gui_data.reference_filename) && ~isempty(settings.gui_data.trajectory_filename)
        tolerance_e_cb([],[],settings.recon.recon_details.tolerance);
        max_iterations_e_cb([],[],settings.recon.recon_details.max_iterations);
        recon_resolution_e_cb([],[],settings.recon.recon_details.recon_resolution);
        recon_voxel_size_e_cb([],[],settings.recon.recon_details.recon_voxel_size);
        adjust_reference_and_trajectory_pb_cb([],[]);
        temporal_recon_type_pm_cb([],[],settings.recon.recon_details.recon_type);
        offresonance_correction_cb_cb([],[],settings.recon.recon_details.offresonance_correction_flag);
%        use_gridengine_cb_cb([],[],settings.param.use_gridengine);
        use_slurm_cb_cb([],[],settings.param.use_slurm);
        frames_per_job_e_cb([],[],settings.param.frames_per_job);
        recon_range_e_cb([],[],settings.recon.recon_details.timeframes_string);
        for k=1:(settings.gui_data.add_penalty_counter-D.gui_data.add_penalty_counter)
            add_penalty_pb_cb([],[]);
        end
        for k=1:settings.gui_data.add_penalty_counter
            lambda_e_cb([],[],k,settings.recon.recon_details.penalty(k).lambda);
            select_norm_pm_cb([],[],k,settings.recon.recon_details.penalty(k).norm_string);
            select_operator_pm_cb([],[],k,settings.recon.recon_details.penalty(k).operator_string);
        end
        
        recon_output_format_pm_cb([],[],settings.recon.recon_details.recon_output_format);
        save_where_pb_cb([],[],settings.gui_data.save_folder_name);
        save_during_recon_cb_cb([],[],settings.check.save_during_recon);
        local_set_status('Import of settings finished.');
    else
        local_set_status('Not all necessary data available. Stopping import of settings.');
    end
    
end


% check for Jeff Fessler's IRT Toolbox
if ~exist('nufft_init.m','file')
    warning('NUFFT not found. Please install Fessler''s Image Reconstruction Toolbox to use all features.');
    local_set_status('NUFFT not found. Please install Fessler''s Image Reconstruction Toolbox to use all features.');
    h0 = [get(H.recon_parameters_panel_1,'Children'); get(H.recon_panel,'Children'); H.penalities_t; H.add_penalty_pb]; 
    for k=1:length(h0)
        set(h0,'Enable','off');
    end        
    clear h0;
end

% check for grid engine
%[sgenotfound,sgefoundpath] = unix('which qsub');
%if sgenotfound
%    warning('Grid engine not installed.');
%    local_set_status('Grid engine not installed.');
%    set(H.use_gridengine_cb,'Enable','off');
%end
%clear sgenotfound sgefoundpath;

% check for grid engine
[slurmnotfound,slurmfoundpath] = unix('which sbatch');
if slurmnotfound
    warning('Slurm not installed.');
    local_set_status('Slurm not installed.');
    set(H.use_slurm_cb,'Enable','off');
end
clear slurmnotfound slurmfoundpath;


%%%%%%%%%%%%
    function set_path_pb_cb(hobj,eventdata,pname)
        if nargin<=2
            pname = uigetdir(D.gui_data.working_directory);
        end
        if isstr(pname) && exist(pname,'dir')==7
            D.gui_data.working_directory = pname;
            set(H.set_path_e,'String',D.gui_data.working_directory);
        end        
    end

%%%%%%%%%%%%
    function export_settings_pb_cb(hobj,eventdata)
        [fname, pname] = uiputfile({'*.mat','mat files (*.mat)'},[],'settings.mat');
        if isstr(fname)
            settings = D;
            if isfield(settings,'rawdata')
                settings = rmfield(settings,'rawdata');
            end
            if isfield(settings,'reference')
                settings = rmfield(settings,'reference');
            end
            if isfield(settings,'trajectory')
                settings = rmfield(settings,'trajectory');
            end
            if isfield(settings.recon,'data')
                settings.recon = rmfield(settings.recon,'data');
            end
            if isfield(settings.recon,'recon')
                settings.recon = rmfield(settings.recon,'recon');
            end
            save(fullfile(pname,fname),'settings');
            local_set_status('Settings exported.');
        else
            local_set_status('Export of settings canceled.');
            return;
        end
    end

%%%%%%%%%%%%
    function load_rawdata_pb_cb(hobj,eventdata,filename)

        if nargin<=2
            [fname, pname] = uigetfile({'*.dat','Data files (*.dat)';'*.dat;*.mat','Data and mat files (*.dat,*.mat)';'*.mat','mat files (*.mat)'},[],D.gui_data.default_folder);
        else
            [pname,fname,ext] = fileparts(filename);
            fname = [fname, ext];
        end
        if isstr(fname)
            D.gui_data.default_folder = pname;
        else
            local_set_status('Loading canceled.');
            return;
        end
        drawnow;
        refresh;
        
        local_clear_rawdata; % clear rawdata

        [~,~,ext] = fileparts(fname);
        if strcmp(ext,'.mat')
            local_set_status('Loading raw data from .mat file ...');
            D.rawdata = mat2variable(fullfile(pname,f.name));
        elseif strcmp(ext,'.dat');
            local_set_status('Loading raw data from .dat file ...');
            [~,header] = loadData(fullfile(pname,fname),1);
            D.recon.recon_details.noise_meas = header.noise.meas;
            D.rawdata = header;
        end
        D.gui_data.rawdata_filename = D.rawdata.rawdata_filename;

        D.check.rawdata_loaded_flag = 1;

        local_check;
        local_update('rawdata');
        
        % loads automatically the trajectory when the raw data is loaded
        try
            path = fileparts(D.rawdata.rawdata_filename);
            tname = find_trajectory(D.rawdata.trajectory, path);
            load_trajectory_pb_cb([],[],{tname}, []);
        catch
            clear_trajectory_pb_cb;
        end
        
        DORK_cb_cb
        
    end

%%%%%%%%%%%%
    function clear_rawdata_pb_cb(hobj,eventdata)
        local_clear_rawdata;
    end

%%%%%%%%%%%%
    function load_reference_pb_cb(hobj,eventdata,filename)
        % reference in a struct with the following fields:
        % smaps = sensitivity maps
        % anatomical = sum of all coil images
        % wmap = off-resonance map from Fesslers 'mri_field_map_reg3D.m'
        % dim = dimension of the a coil profile
        % reference_mid
        % reference_filename

        
        if nargin<=2
            [fname, pname] = uigetfile({'*.dat;*.mat','Data and mat files (*.dat,*.mat)';'*.dat','Data files (*.dat)';'*.mat','mat files (*.mat)'},[],D.gui_data.default_folder);
        else
            [pname,fname,ext] = fileparts(filename);
            fname = [fname, ext];
        end
        if isstr(fname)
            D.gui_data.default_folder = pname;
        else
            local_set_status('Loading canceled.');
            return;
        end
        refresh;
        drawnow;
        
        if fname==0
            local_set_status('Loading canceled.');
            return;
        end
        
        local_clear_reference; % clear reference

        [~,~,ext] = fileparts(fname);
        if strcmp(ext,'.mat')
            local_set_status('Loading reference from .mat file ...');
            D.reference = mat2variable(fullfile(pname,fname));
            if isfield(D.reference,'sensmode')
                sensmode_pm_cb([],[],D.reference.sensmode);
            else
                sensmode_pm_cb([],[],'unknown');
            end
            
        elseif strcmp(ext,'.dat')
            local_set_status('Loading reference from raw data ...');
            D.reference = loadReference(fullfile(pname,fname));
        else
            local_set_status('Unknown file extension.');
            return;
        
        end
        
        D.reference.reference_filename = fullfile(pname,fname);
        D.gui_data.reference_filename = D.reference.reference_filename;
        
        switch D.reference.raw.mode
            case '2d'
                D.param.recon_dimension = 2;
                D.reference.raw.fov = D.reference.raw.fov(1:2);
            case {'3d','multi_slice'}
                D.param.recon_dimension = 3;
            otherwise
                local_set_status('Error when loading the reference data. No mode specified.');
        end
        
        D.check.reference_loaded_flag = 1;
        
        local_check;
        local_update('reference');
        
    end

%%%%%%%%%%%%
    function clear_reference_pb_cb(hobj,eventdata)
        local_clear_reference;
    end

%%%%%%%%%%%%
    function sensmode_pm_cb(hobj,eventdata,str)
        if nargin==3
            for n=1:length(D.gui_data.sensmode_pm_string)
                if strcmp(D.gui_data.sensmode_pm_string{n},str)
                    set(H.sensmode_pm,'Value',n);
                    tmp = str;
                end
            end
        else
            tmp = D.gui_data.sensmode_pm_string{get(H.sensmode_pm,'Value')};
        end
        
        if ~strcmp(tmp,D.param.sensmode)
            D.param.sensmode = tmp;
            if D.check.adjust_reference_and_trajectory_flag
                local_set_status(['Computing sensitiviy maps with mode "', D.param.sensmode,'".']);
                D.reference.smaps = coilSensitivities(D.reference.cmaps(:,:,:,:,1),D.param.sensmode);
                local_set_status('Done.');
            end
        end
    end

%%%%%%%%%%%%
    function select_view_reference_pm_cb(hobj,eventdata,val)
        if nargin<=2
            D.param.select_view_reference = get(H.select_view_reference_pm,'Value');
        else
            set(H.select_view_reference_pm,'Value',val);
            D.param.select_view_reference = val;
        end
    end

%%%%%%%%%%%%
    function save_reference_pb_cb(hobj,eventdata,filename)
        if D.check.reference_loaded_flag
            if nargin<=2
                [~,refname] = fileparts(D.reference.reference_filename);
                [fname,pname] = uiputfile('*.mat','Save reference ...',['reference_mid', num2str(midByFilename(refname)), '.mat']);
            else
                [pname,fname,ext] = fileparts(filename);
                fname = [fname, ext];
            end
            if ~isstr(fname)
                local_set_status('Saving canceled.');
                return;
            end
            reference = D.reference;
            local_set_status('Saving reference ...');
            save(fullfile(pname,fname),'reference','-v7.3');
            local_set_status('Reference saved.');
        else
            local_set_status('Reference must be loaded first.');
        end
    end

%%%%%%%%%%%%
    function view_reference_pb_cb(hobj,eventdata)
        if D.check.adjust_reference_and_trajectory_flag
            if D.param.select_view_reference==1
                viewer3d_tool(abs(D.reference.anatomical));
            elseif D.param.select_view_reference==2
                viewer3d_tool(abs(D.reference.cmaps(:,:,:,:,1)));
            elseif D.param.select_view_reference==3
                viewer3d_tool(abs(D.reference.smaps));
            elseif D.param.select_view_reference==4
                if strcmp(D.reference.mode,'2d')
                    figure;
                    imagesc(D.reference.wmap);
                    colorbar;
                else
                    viewer3d_tool(D.reference.wmap);
                end
            end
        elseif D.check.reference_loaded_flag
            if D.param.select_view_reference==1
                viewer3d_tool(abs(D.reference.raw.anatomical));
            elseif D.param.select_view_reference==2
                viewer3d_tool(abs(D.reference.raw.cmaps(:,:,:,:,1)));
            end
        else
            local_set_status('Reference must be loaded first.');
        end
    end

%%%%%%%%%%%%
    function load_trajectory_pb_cb(hobj,eventdata,filename,Ni)
        % trajectory is a struct with the follwoing fields:
        % trajectory = cell array with trajectories of all interleaves
        % idx = cell array of indices of valid trajectory points
        % resolution = resolution of the trajectory
        % fov = field of view of the trajectory
        

        local_set_status('Loading trajectory ...');
                
        if nargin < 3 || isempty(filename)
            [D.trajectory, status] = loadTrajectory([], D.gui_data.default_folder, delay);
%            [D.trajectory, status] = loadTrajectory([], D.gui_data.default_folder);
            pname = fileparts(D.trajectory.trajectory_filename);
            D.gui_data.default_folder = pname;
        else
            [D.trajectory, status] = loadTrajectory(filename, [], delay);
%            [D.trajectory, status] = loadTrajectory(filename, []);
        end
        local_set_status(status);
        if isempty(D.trajectory), return; end
        
        D.gui_data.trajectory_filename = D.trajectory.trajectory_filename;
        D.check.trajectory_loaded_flag = 1;
        
        [~,idx_k0]=min(makesos(D.trajectory.trajectory{1}(D.trajectory.idx{1},:),2));
        D.recon.recon_details.DORK_k0 = D.trajectory.idx{1}(idx_k0);        % this implementation only works for 1 segment/identical segments!

        local_check;
        local_update('trajectory');
        local_set_trajectory_range_string;
        
        
    end

%%%%%%%%%%%%
    function clear_trajectory_pb_cb(hobj,eventdata)
        local_clear_trajectory;
    end

%%%%%%%%%%%%
    function interleaves_e_cb(hobj,eventdata,Ni)
        if nargin==3
            assert(check_input(Ni,'numeric','scalar','int'));
            set(H.interleaves_e,'String',num2str(Ni));
        else
            Ni = str2num(get(H.interleaves_e,'String'));
            if ~check_input(Ni,'numeric','scalar','int')
                local_set_status('Number of interleaves needs to be a scalar, integer value.');
                set(H.interleaves_e,'String',num2str(D.recon.recon_details.nInterleaves,'%i'));
                return;
            end
        end
        D.recon.recon_details.nInterleaves = Ni;
        local_set_status(['Number of interleaves set to ',num2str(D.recon.recon_details.nInterleaves),'.']);
    end

%%%%%%%%%%%%
    function save_trajectory_pb_cb(hobj,eventdata,filename)
        if D.check.trajectory_loaded_flag == 1
            if nargin<=2
                if isfield(D.trajectory, 'trajectory_filename')
                    [~, fname, ~] = fileparts(D.trajectory.trajectory_filename);
                    tname = ['trajectory_', fname];
                elseif D.check.rawdata_loaded_flag==1
                    tname = ['trajectory_mid', num2str(midByFilename(D.rawdata.rawdata_filename)), '.mat'];
                else
                    tname = ['trajectory.mat'];
                end
                [fname,pname] = uiputfile('*.mat','Save trajectory ...',tname);
            else
                [pname,fname,ext] = fileparts(filename);
                fname = [fname, ext];
            end
            if ~isstr(fname)
                local_set_status('Saving canceled.');
                return;
            end
            local_set_status('Saving trajectory ...');
            trajectory = D.trajectory;
            save(fullfile(pname,fname),'trajectory');
            clear trajectory;
            local_set_status('Trajectory saved.');
        else
            local_set_status('Trajectory must be loaded first.');
        end
    end

%%%%%%%%%%%%
    function view_trajectory_pb_cb(hobj,eventdata)
        if D.check.trajectory_loaded_flag == 1
            c = lines(D.recon.recon_details.nInterleaves);
            figure;
            hold on;
            for n=1:D.recon.recon_details.nInterleaves
                if D.param.recon_dimension==2
                    plot(D.trajectory.trajectory{n}(D.trajectory.idx{n},1), ...
                         D.trajectory.trajectory{n}(D.trajectory.idx{n},2),'-','Color',c(n,:));
                elseif D.param.recon_dimension==3
                    plot3(D.trajectory.trajectory{n}(D.trajectory.idx{n},1), ...
                          D.trajectory.trajectory{n}(D.trajectory.idx{n},2), ...
                          D.trajectory.trajectory{n}(D.trajectory.idx{n},3),'-','Color',c(n,:));
                    view(45,30);
                end
            end
        else
            local_set_status('Trajectory must be loaded first.');
        end
    end

%%%%%%%%%%%%
    function select_range_trajectory_pb_cb(hobj,eventdata)
        if ~isfield(D,'trajectory')
            local_set_status('Trajectory not loaded yet.');
            return;
        end
        D.trajectory.trajectory_select_range = cell(1,D.recon.recon_details.nInterleaves);
        tmp = D.trajectory.idx;
        for n=1:D.recon.recon_details.nInterleaves
            hf = figure('NumberTitle','off','Name','Select part of the trajectory');
            h = axes;
            plot(sqrt(sum(abs(D.trajectory.trajectory{n}).^2,2)));
            title(['Interleaf #',num2str(n)]);
            hold on;
            set(get(h,'Children'),'ButtonDownFcn',@select_range); % set the bdf on the plot itself
            xtight;
            scaleX;
            zoom(h,'reset');
            waitfor(hf);
            if length(D.trajectory.trajectory_select_range{n})~=2
                D.trajectory.idx = tmp;
                local_set_status('Range selection aborted.');
                return;
            end
            D.trajectory.idx{n} = [D.trajectory.trajectory_select_range{n}(1):D.trajectory.trajectory_select_range{n}(2)];
        end
      
        local_set_trajectory_range_string;
        
%%%%%%%%%%%%
        function select_range(hobj2,eventdata2)
            range_pt = get(h,'CurrentPoint');
            range_pt = range_pt(1,1:2);
            plot(range_pt(1),range_pt(2),'r*');
            range_pt = round(range_pt(1));
            D.trajectory.trajectory_select_range{n} = [D.trajectory.trajectory_select_range{n} range_pt];
            if length(D.trajectory.trajectory_select_range{n})==2
                zoom(h,'out');
                backgroundMarkers(D.trajectory.trajectory_select_range{n});
                choice = questdlg('Selection OK?','','Yes','No','Yes');
                if strcmp(choice,'Yes')
                    close(hf);
                elseif strcmp(choice,'No')
                    D.trajectory.trajectory_select_range{n} = [];
                    hc = get(h,'Children');
                    delete(hc(1:end-1));
                else
                end
            end
        end
    end

%%%%%%%%%%%%
    function tolerance_e_cb(hobj,eventdata,tol)
        if nargin<=2
            tol = str2num(get(H.tolerance_e,'String'));
        else
            set(H.tolerance_e,'String',num2str(tol,'%1.1e'));
        end
        if ~check_input(tol,'numeric','scalar');
            local_set_status('Tolerance needs to be a scalar value.');
            set(H.tolerance_e,'String',num2str(D.recon.recon_details.tolerance,'%1.1e'));
            return;
        end
        D.recon.recon_details.tolerance = tol;
        local_set_status(['Stopping tolerance of CG set to ',num2str(D.recon.recon_details.tolerance),'.']);
    end

%%%%%%%%%%%%
    function max_iterations_e_cb(hobj,eventdata,maxit)
        if nargin<=2
            maxit = str2num(get(H.max_iterations_e,'String'));
        else
            set(H.max_iterations_e,'String',num2str(maxit,'%i'));
        end
        if ~check_input(maxit,'numeric','scalar','int')
            local_set_status('Maximum number of interations needs to be a scalar, integer value.');
            set(H.max_iterations_e,'String',num2str(D.recon.recon_details.max_iterations,'%i'));
            return;
        end
        D.recon.recon_details.max_iterations = maxit;
        local_set_status(['Maximum number of CG iterations set to ',num2str(D.recon.recon_details.max_iterations),'.']);
    end

%%%%%%%%%%%%
    function recon_resolution_e_cb(hobj,eventdata,resolution)
        if nargin<=2
            resolution = str2num(get(H.recon_resolution_e,'String'));
        else
            set(H.recon_resolution_e,'String',['[',num2str(resolution,'%i '),']']);
        end
        if ~check_input(resolution,'numeric','1d','length',D.param.recon_dimension,'int');
            local_set_status(['Resolution must be an integer 1d-array with ',num2str(D.param.recon_dimension),' entries.']);
            set(H.recon_resolution_e,'String',['[',num2str(D.recon.recon_details.recon_resolution,'%i '),']']);
            return;
        end
        
        D.recon.recon_details.recon_resolution = resolution;
        local_set_status(['Image dimension set to [',num2str(D.recon.recon_details.recon_resolution,'%i '),'].']);
        set(H.recon_resolution_e,'String',['[',num2str(D.recon.recon_details.recon_resolution,'%i '),']']);
        D.check.adjust_reference_and_trajectory_flag = 0;
        set(H.adjust_reference_and_trajectory_pb,'BackgroundColor',not_active_flag_color);
        local_check;
    end

%%%%%%%%%%%%
    function recon_voxel_size_e_cb(hobj,eventdata,voxel_size)
        if nargin<=2
            voxel_size = 1e-3 * str2num(get(H.recon_voxel_size_e,'String'));
        else
            set(H.recon_voxel_size_e,'String',['[',num2str(1e3*voxel_size,'%.1f '),']']);
        end
        
        if ~check_input(voxel_size,'numeric','1d','length',D.param.recon_dimension);
            local_set_status(['Recon voxel size must be a 1d-array with ',num2str(D.param.recon_dimension),' entries.']);
            set(H.recon_voxel_size_e,'String',['[',num2str(1e3*D.recon.recon_details.recon_voxel_size,'%.1f '),']']);
            return;
        end
        
        D.recon.recon_details.recon_voxel_size = voxel_size;
        local_set_status(['Recon voxel size set to [',num2str(1e3 * D.recon.recon_details.recon_voxel_size,'%.1f '),'].']);
        set(H.recon_voxel_size_e,'String',['[',num2str(1e3*D.recon.recon_details.recon_voxel_size,'%.1f '),']']);
        D.check.adjust_reference_and_trajectory_flag = 0;
        set(H.adjust_reference_and_trajectory_pb,'BackgroundColor',not_active_flag_color);
    end

%%%%%%%%%%%%
    function adjust_reference_and_trajectory_pb_cb(hobj,eventdata)
        local_adjust_ref_traj;
    end

%%%%%%%%%%%%
    function temporal_recon_type_pm_cb(hobj, eventdata, str)
        if nargin<=2
            val = get(H.temporal_recon_type_pm,'Value');
            str = D.gui_data.temporal_recon_type_string{val};
        else
            for n=1:length(D.gui_data.temporal_recon_type_string)
                if strcmp(D.gui_data.temporal_recon_type_string{n},str)
                    set(H.temporal_recon_type_pm,'Value',n);
                end
            end
        end
        D.recon.recon_details.recon_type = str;
    end

%%%%%%%%%%%%
    function offresonance_correction_cb_cb(hobj, eventdata, val)
        if nargin<=2
            D.recon.recon_details.offresonance_correction_flag = get(H.offresonance_correction_cb,'Value');
        else
            set(H.offresonance_correction_cb,'Value',val);
            D.recon.recon_details.offresonance_correction_flag = val;
        end
    end

%%%%%%%%%%%%
    function z0_cb_cb(hobj,eventdata)
        if get(H.z0_cb,'Value') ~= 1
            D.recon.recon_details.z0_details = [];
            D.recon.recon_details.z0 = 0;
        else
            if D.gui_data.z0 == 0
                calc = 1;
            else
                new_z0 = questdlg(['There is an old z0 withe the parameters: ', D.gui_data.z0_details.penalty.norm_string, ...
                    ', Lambda = ', num2str(D.gui_data.z0_details.penalty.lambda), ...
                    ', Operator = ', D.gui_data.z0_details.penalty.operator_string, ...
                    ', Tolerance = ', num2str(D.gui_data.z0_details.tolerance), ...
                    ', Max. Iterations = ' num2str(D.gui_data.z0_details.max_iterations)], ...
                    'z0', 'Calculate new one', 'Take old one', 'Cancel', 'Take old one');
                switch new_z0
                    case 'Calculate new one'
                        calc = 1;
                    case 'Take old one'
                        calc = 0;
                    case 'Cancel'
                        local_set_status('Canceled.');
                        set(H.z0_cb, 'Value', 0);
                        return;
                end
            end
            
            if calc == 1
                try
                    z0_pb_cb;
                catch
                    D.gui_data.z0 = 0;
                    D.gui_data.z0_details = [];
                    local_set_status('Not all necessary data loaded yet.');
                    drawnow;
                    return;
                end
            end
            
            D.recon.recon_details.z0 = D.gui_data.z0;
            D.recon.recon_details.z0_details = D.gui_data.z0_details;
        end
    end

%%%%%%%%%%%%
    function z0_pb_cb(hobj,eventdata)
        if all([D.check.rawdata_loaded_flag, D.check.reference_loaded_flag, D.check.trajectory_loaded_flag])
            if D.gui_data.add_penalty_counter==0
                local_set_status('At least one penalty has to be added first.');
                drawnow;
                return;
            end
            local_set_status('Reconstructing starting point for CG ...');
            drawnow;

            recon_details = D.recon.recon_details;
            recon_details.timeframes = ceil(D.rawdata.Nt/2);
            recon_details.z0 = 0;
            recon_details.z0_details = [];
            recon_details.recon_output_format = 'not';
            
            data.smaps      = D.reference.smaps;
            data.wmap       = D.reference.wmap;
            data.shift      = D.reference.shift;
            data.trajectory = D.trajectory;
            
            D.gui_data.z0 = double(mreg_recon_tool_recon('local',data,recon_details));
            D.gui_data.z0_details = recon_details;
            local_set_status('Done.');
            drawnow;
        else
            local_set_status('Not all necessary data loaded yet.');
            drawnow;
            return;
        end
    end


%%%%%%%%%%%%
    function DORK_cb_cb(hobj, eventdata, val)
        if get(H.DORK_cb,'Value') ~= 1
            D.recon.recon_details.DORK_frequency = [];
        elseif isempty(D.recon.recon_details.DORK_k0)
            local_set_status('DORK frequencies not set. Load trajectory first!');    
            set(H.DORK_cb,'Value',0)
        else
            local_set_status('Calculating DORK frequencies...');
            [D.recon.recon_details.DORK_frequency,D.recon.recon_details.DORK_phi_offset] = ...
                DORK_frequency(D.rawdata.rawdata_filename,D.recon.recon_details.DORK_k0,D.rawdata.trajectorySegments);
           
            local_set_status('Done.');
        end
    end


%%%%%%%%%%%%
    function global_or_shift_e_cb(hobj,eventdata,val)
        if nargin<=2
            shift = str2num(get(H.global_or_shift_e,'String'));
        else
            set(H.global_or_shift_e,'String',num2str(val,'%i'));
            shift = val;
        end
        
        if ~check_input(shift,'numeric','scalar','int')
            local_set_status('Global off-resonance shift must be a scalar, integer value.');
            set(H.global_or_shift_e,'String',num2str(D.recon.recon_details.global_frequency_shift,'%i'));
        else
            D.recon.recon_details.global_frequency_shift = shift;
            local_set_status(['Global off-resonance shift set to ',num2str(D.recon.recon_details.global_frequency_shift),'/s.']);
        end
    end

% %%%%%%%%%%%%
%     function use_gridengine_cb_cb(hobj, eventdata, val)
%         if nargin<=2
%             D.param.use_gridengine = get(H.use_gridengine_cb,'Value');
%         else
%             set(H.use_gridengine_cb,'Value',val);
%             D.param.use_gridengine = val;
%         end
%         
%         if D.param.use_gridengine==1
%             set(H.frames_per_job_e,'Enable','on');
%             set(H.save_during_recon_cb,'Enable','off','Visible','off');
%         else
%             set(H.frames_per_job_e,'Enable','off');
%             set(H.save_during_recon_cb,'Enable','on','Visible','on');
%         end
%     end

%%%%%%%%%%%%
    function use_slurm_cb_cb(hobj, eventdata, val)
        if nargin<=2
            D.param.use_slurm = get(H.use_slurm_cb,'Value');
        else
            set(H.use_slurm_cb,'Value',val);
            D.param.use_slurm = val;
        end
        
        if D.param.use_slurm==1
            set(H.frames_per_job_e,'Enable','on');
            set(H.save_during_recon_cb,'Enable','off','Visible','off');
        else
            set(H.frames_per_job_e,'Enable','off');
            set(H.save_during_recon_cb,'Enable','on','Visible','on');
        end
    end

%%%%%%%%%%%%
    function frames_per_job_e_cb(hobj,eventdata,val)
        if nargin<=2
            frames_per_job = str2num(get(H.frames_per_job_e,'String'));
        else
            set(H.frames_per_job_e,'String',num2str(val,'%i'));
            frames_per_job = val;
        end
        
        if ~check_input(frames_per_job,'numeric','scalar','int')
            local_set_status(['Frames per grid engine job must be a scalar, integer value.']);
            set(H.frames_per_job_e,'String',num2str(D.param.frames_per_job,'%i'));
            return;
        end
        
        D.param.frames_per_job = frames_per_job;
        local_set_status(['Frames per job set to ',num2str(D.param.frames_per_job),'.']);
    end

%%%%%%%%%%%%
    function recon_range_e_cb(hobj,eventdata,str)
        if nargin<=2
            range_str = get(H.recon_range_e,'String');
            range = str2num(range_str);
        else
            range_str = str;
            range = str2num(range_str);
            set(H.recon_range_e,'String',str);
        end
        
        if ~check_input(range,'numeric','vector','int','ge',1,'le',D.rawdata.Nt)
            local_set_status(['Recon range must be a scalar, integer vector within the bounds [1,',num2str(D.rawdata.Nt),'].']);
            set(H.recon_range_e,'String',D.recon.recon_details.timeframes_string);
            return;
        end
        
        D.recon.recon_details.timeframes = range;
        D.recon.recon_details.timeframes_string = range_str;
        local_set_status(['Recon range set to ',D.recon.recon_details.timeframes_string]);
    end

%%%%%%%%%%%%
    function recon_pb_cb(hobj,eventdata)
        if all([D.check.rawdata_loaded_flag, D.check.reference_loaded_flag, D.check.trajectory_loaded_flag, D.check.adjust_reference_and_trajectory_flag])
            if D.gui_data.add_penalty_counter==0
                local_set_status('At least one penalty has to be added first.');
                return;
            end
            
            if D.check.adjust_reference_and_trajectory_flag==0
                local_set_status('Trajectory and Reference properties don''t match. Adjust first.');
                return;                
            end

            
            recon_details = D.recon.recon_details;
            if isempty(D.gui_data.save_folder_name)
                dstr = ['recon_',datestr(now,'dd.mm.yyyy-HH-MM-SS')];
            else
                dstr = D.gui_data.save_folder_name;
            end
            recon_details.pname = fullfile(D.gui_data.working_directory,dstr);
            
            data.smaps      = D.reference.smaps;
            data.wmap       = D.reference.wmap;
            data.anatomical = D.reference.anatomical;
            data.shift      = D.reference.shift;
            data.Cor_angle  = D.reference.Cor_angle;
            data.InPlaneRot_now  = D.reference.InPlaneRot_now;
            data.ref_header = D.reference.header;
            data.sensmode   = D.reference.sensmode;
            data.trajectory = D.trajectory;
                               
%            if D.param.use_gridengine==1
%                local_set_status('Submitting jobs to gridengine ...');
            if D.param.use_slurm==1
                local_set_status('Submitting jobs to slurm ...');
                try
%                    mreg_recon_tool_sge_init(data,recon_details,D.param.frames_per_job);
                    mreg_recon_tool_slurm_init(data,recon_details,D.param.frames_per_job);
                    local_set_status('Jobs submitted.');
                catch err
%                    if strcmp(err.identifier, 'mreg_recon_tool_sge_init:Dir_exists')
                    if strcmp(err.identifier, 'mreg_recon_tool_slurm_init:Dir_exists')
                        local_set_status('Directory already exists. Please choose another one under ''Where''.');
                    else
                        rethrow(err);
                    end
                end
            else
                local_set_status('Reconstructing ...');
                
                if D.check.save_during_recon==0
                    recon_details.recon_output_format = 'not';
                else
                    recon_details.fname = 'recon';
                end
                
                D.recon.recon = mreg_recon_tool_recon('local',data,recon_details);
                D.check.recon_finished_flag = 1;
                local_set_status('Done.');
            end
            
        else
            local_set_status('Not all necessary data loaded yet or reference not adjusted yet.');
            return;
        end
    end

%%%%%%%%%%%%
    function save_during_recon_cb_cb(hobj,eventdata,val)
        if nargin<=2
            D.check.save_during_recon = get(H.save_during_recon_cb,'Value');
        else
            set(H.save_during_recon_cb,'Value',val);
            D.check.save_during_recon = val;
        end
    end

%%%%%%%%%%%%
    function recon_output_format_pm_cb(hobj,eventdata,str)
        if nargin<=2
            val = get(H.recon_output_format_pm,'Value');
            tmp = D.gui_data.recon_output_format_string{val};
        else
            for n=1:length(D.gui_data.recon_output_format_string)
                if strcmp(D.gui_data.recon_output_format_string{n},str)
                    set(H.recon_output_format_pm,'Value',n);
                end
            end
            tmp = str;
        end
        
        if strcmp(tmp,'nifti')
            if exist('spm_write_vol.m')~=2
                set(H.recon_output_format_pm,'Value',1);
                D.recon.recon_details.recon_output_format = D.gui_data.recon_output_format_string{1};
                local_set_status(['SPM does not seem to be available. Output format reset to ',D.recon.recon_details.recon_output_format,'.']);
            else
                D.recon.recon_details.recon_output_format = tmp;
                local_set_status('Output format set to nifti. Only the absolute value will be used!');
            end
        else
            D.recon.recon_details.recon_output_format = tmp;
        end
    end

%%%%%%%%%%%%
    function save_where_pb_cb(hobj,eventdata,pathname)
        if nargin<=2
            answer = inputdlg({'Enter folder name:'}, 'Specify folder name ...', 1, {D.gui_data.save_folder_name});
        else
            answer = {pathname};
        end
        if ~isempty(answer)
            D.gui_data.save_folder_name = answer{1};
        end
    end

%%%%%%%%%%%%
    function save_recon_as_file_pb_cb(hobj,eventdata)
        if D.check.recon_finished_flag == 1
            recon = D.recon.recon;
            
            switch D.recon.recon_details.recon_output_format
                case 'mat'
                    [fname, pname] = uiputfile('*','Save as mat file ...',['recon_mid',num2str(D.rawdata.mid)]);
                    if ~isstr(fname)
                        local_set_status('Saving canceled.');
                        return;
                    end
                    [~,fname,ext] = fileparts(fname);
                    for k=1:length(D.recon.recon_details.timeframes)
                        mreg_recon_tool_write_file('mat',recon(:,:,:,k),D.recon.recon_details.timeframes(k),pname,fname,D.rawdata.Nt);
                    end
                    local_set_status('Reconstruction exported as mat-file.');
                    
                case 'nifti'
                    [fname, pname] = uiputfile('*','Save as nifti ...',['recon_mid',num2str(D.rawdata.mid)]);
                    if ~isstr(fname)
                        local_set_status('Saving canceled.');
                        return;
                    end
                    [~,fname,ext] = fileparts(fname);                    
                    for k=1:length(D.recon.recon_details.timeframes)
                        mreg_recon_tool_write_file('nifti',recon(:,:,:,k),D.recon.recon_details.timeframes(k),pname,fname,D.rawdata.Nt);
                    end
                    local_set_status('Reconstruction exported as nifti files.');
            end
        
        else
            local_set_status('Time series must be reconstructed first.');
            
        end
        
    end

%%%%%%%%%%%%
    function save_recon_in_workspace_pb_cb(hobj,eventdata)
        if D.check.recon_finished_flag == 1
            recon = D.recon.recon;
            answer = inputdlg({'Enter name for variable:'}, 'Assign recon to workspace', 1, {'recon'});
            if isempty(answer)
                local_set_status('Saving canceled.');
                return;
            end
            assignin('base',answer{1},recon);
            local_set_status('Time series saved.');
        else
            local_set_status('Time series must be reconstructed first.');
        end
    end

%%%%%%%%%%%%
    function view_recon_pb_cb(hobj,eventdata)
        if D.check.recon_finished_flag==1
            viewer3d_tool(abs(D.recon.recon));
        else
            local_set_status('No reconstruction performed yet.');
        end
    end

%%%%%%%%%%%%
    function add_penalty_pb_cb(hobj,eventdata)
        D.gui_data.add_penalty_counter = D.gui_data.add_penalty_counter + 1;
        
        if D.gui_data.add_penalty_counter==1            
            p = get(H.add_penalty_pb,'Position');
            H.lambda_t = uicontrol(H.main_fig,'Style','Text','String','lambda','Position',[p(1)+p(3)+3*spacing,p(2)+pb_height,pb_width,tb_height],'FontUnits',font_units,'FontSize',font_size);
            p = get(H.lambda_t(D.gui_data.add_penalty_counter),'Position');
            H.select_norm_t = uicontrol(H.main_fig,'Style','Text','String','Select Norm','Position',[p(1)+p(3)+3*spacing,p(2),pb_width,tb_height],'FontUnits',font_units,'FontSize',font_size);
            p = get(H.select_norm_t(D.gui_data.add_penalty_counter),'Position');
            H.select_operator_t = uicontrol(H.main_fig,'Style','Text','String','Select Operator','Position',[p(1)+p(3)+3*spacing,p(2),pb_width,tb_height],'FontUnits',font_units,'FontSize',font_size);
        end
        
        p = get(H.add_penalty_pb,'Position');
        set(H.add_penalty_pb,'Position',[p(1) p(2)-pb_height-spacing p(3) p(4)]);
        H.lambda_e(D.gui_data.add_penalty_counter) = uicontrol(H.main_fig,'Style','Edit','String',num2str(D.gui_data.lambda_default),'Position',[p(1)+p(3)+3*spacing,p(2),pb_width,pb_height],'BackgroundColor','white','Callback',{@lambda_e_cb,D.gui_data.add_penalty_counter},'FontUnits',font_units,'FontSize',font_size);
        D.recon.recon_details.penalty(D.gui_data.add_penalty_counter).lambda = D.gui_data.lambda_default;
        
        p = get(H.lambda_e(D.gui_data.add_penalty_counter),'Position');
        H.select_norm_pm(D.gui_data.add_penalty_counter) = uicontrol(H.main_fig,'Style','PopupMenu','String',D.gui_data.select_norm_string,'Position',[p(1)+p(3)+3*spacing,p(2),pb_width,pb_height],'Callback',{@select_norm_pm_cb,D.gui_data.add_penalty_counter},'FontUnits',font_units,'FontSize',font_size);

        p = get(H.select_norm_pm(D.gui_data.add_penalty_counter),'Position');
        H.select_operator_pm(D.gui_data.add_penalty_counter) = uicontrol(H.main_fig,'Style','PopupMenu','String',D.gui_data.select_operator_string,'Position',[p(1)+p(3)+3*spacing,p(2),pb_width,pb_height],'Callback',{@select_operator_pm_cb,D.gui_data.add_penalty_counter},'FontUnits',font_units,'FontSize',font_size);
        
        if D.gui_data.add_penalty_counter==1
            p = get(H.add_penalty_pb(D.gui_data.add_penalty_counter),'Position');
            H.delete_penalty_pb(D.gui_data.add_penalty_counter) = uicontrol(H.main_fig,'Style','PushButton','String','Delete','Position',[p(1)-pb_width/2,p(2),pb_width/2,pb_height],'Callback',{@delete_penalty_pb_cb},'FontUnits',font_units,'FontSize',font_size);
        else
            p = get(H.delete_penalty_pb,'Position');
            set(H.delete_penalty_pb,'Position',[p(1) p(2)-pb_height-spacing p(3) p(4)]);
        end

        select_norm_pm_cb([],[],D.gui_data.add_penalty_counter);
        lambda_e_cb([],[],D.gui_data.add_penalty_counter);
        select_operator_pm_cb([],[],D.gui_data.add_penalty_counter);
    end

%%%%%%%%%%%%
    function delete_penalty_pb_cb(hobj,eventdata)
        p = get(H.add_penalty_pb,'Position');
        set(H.add_penalty_pb,'Position',[p(1) p(2)+pb_height+spacing p(3) p(4)]);

        delete(H.select_norm_pm(D.gui_data.add_penalty_counter));
        delete(H.lambda_e(D.gui_data.add_penalty_counter));
        delete(H.select_operator_pm(D.gui_data.add_penalty_counter));
        
        D.recon.recon_details.penalty(D.gui_data.add_penalty_counter) = [];
        
        H.select_norm_pm(D.gui_data.add_penalty_counter) = [];
        H.lambda_e(D.gui_data.add_penalty_counter) = [];
        H.select_operator_pm(D.gui_data.add_penalty_counter) = [];
        
        if D.gui_data.add_penalty_counter==1
            delete(H.delete_penalty_pb);
            delete(H.lambda_t);
            delete(H.select_norm_t);
            delete(H.select_operator_t);
        else
            p = get(H.delete_penalty_pb,'Position');
            set(H.delete_penalty_pb,'Position',[p(1) p(2)+pb_height+spacing p(3) p(4)]);            
        end
        
        D.gui_data.add_penalty_counter = D.gui_data.add_penalty_counter - 1;
    end

%%%%%%%%%%%%
    function lambda_e_cb(hobj,eventdata,counter,val)
        if nargin<=3
            lambda = str2num(get(H.lambda_e(counter),'String'));
        else
            lambda = val;
            set(H.lambda_e(counter),'String',num2str(val,'%1.1e'));
        end
        
        if ~check_input(lambda,'numeric','scalar')
            local_set_status(['The regularization parameter must be a scalar value.']);
            set(H.lambda_e(counter),'String',num2str(D.recon.recon_details.penalty(counter).lambda,'%1.1e'));
            return;
        end
        D.recon.recon_details.penalty(counter).lambda = lambda;
        local_set_status(['Regularization parameter set to ',num2str(D.recon.recon_details.penalty(counter).lambda),'.']);
    end

%%%%%%%%%%%%
    function select_norm_pm_cb(hobj,eventdata,counter,str)
        if nargin<=3
            val = get(H.select_norm_pm(counter),'Value');
            str = D.gui_data.select_norm_string{val};
        else
            for n=1:length(D.gui_data.select_norm_string)
                if strcmp(D.gui_data.select_norm_string{n},str)
                    set(H.select_norm_pm(counter),'Value',n);
                end
            end
        end
        
        D.recon.recon_details.penalty(counter).norm_string = str;
        
        switch str
            case 'L2-norm'
                D.recon.recon_details.penalty(counter).norm = @L2Norm;
            case 'L1-norm'
                D.recon.recon_details.penalty(counter).norm = @L1Norm;
        end
    end

%%%%%%%%%%%%
    function select_operator_pm_cb(hobj,eventdata,counter,str)
        if nargin<=3
            val = get(H.select_operator_pm(counter),'Value');
            str = D.gui_data.select_operator_string{val};
        else
            for n=1:length(D.gui_data.select_operator_string)
                if strcmp(D.gui_data.select_operator_string{n},str)
                    set(H.select_operator_pm(counter),'Value',n);
                end
            end
        end

        D.recon.recon_details.penalty(counter).operator_string = str;

        D.recon.recon_details.penalty(counter).operator = [];
        switch str
            case 'Identity'
                D.recon.recon_details.penalty(counter).operator(1).handle = @identityOperator;
                D.recon.recon_details.penalty(counter).operator(1).args = {};
            case 'Total Variation'
                D.recon.recon_details.penalty(counter).operator(1).handle = @finiteDifferenceOperator;
                D.recon.recon_details.penalty(counter).operator(1).args = {1};
                D.recon.recon_details.penalty(counter).operator(2).handle = @finiteDifferenceOperator;
                D.recon.recon_details.penalty(counter).operator(2).args = {2};
                D.recon.recon_details.penalty(counter).operator(3).handle = @finiteDifferenceOperator;
                D.recon.recon_details.penalty(counter).operator(3).args = {3};
            case 'Wavelet Transform'
                D.recon.recon_details.penalty(counter).operator(1).handle = @waveletDecompositionOperator;
                D.recon.recon_details.penalty(counter).operator(1).args = {D.recon.recon_details.recon_resolution,3,'db2'};
        end
    end

%%%%%%%%%%%%
    function status_t_cb(hobj,eventdata,msg)
        if nargin<=2
            msg = 'OK';
        end
        local_set_status(msg);
    end

%%%%%%%%%%%%
    function quit_pb_cb(hobj,eventdata)
        close(H.main_fig);
        clear H D;
    end



%%%%%%%%%%%%%%%%%%%
% local functions %
%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%
    function local_set_status(str)
        set(H.status_t,'String',str);
        drawnow;
    end

%%%%%%%%%%%%
    function local_adjust_ref_traj
        
        local_set_status('Trajectory and reference have different parameters. Resizing sensitivity maps ...');
        drawnow;

        
        fov_recon = D.recon.recon_details.recon_resolution .* D.recon.recon_details.recon_voxel_size;
        D.reference = resizeReference(D.reference, fov_recon, D.recon.recon_details.recon_resolution, D.rawdata, D.param.sensmode);
        local_set_status('Resizing reference data finished.');
        
        % if a different voxel size is desired than that specified by the trajectory, the trajectory has to be scaled accordingly
        voxel_size_org = D.trajectory.fov ./ D.trajectory.resolution;
        
        D.recon.recon_details.trajectory_scaling = D.recon.recon_details.recon_voxel_size ./ voxel_size_org;
        D.check.adjust_reference_and_trajectory_flag = 1;
        
        D.gui_data.z0 = 0;
        D.gui_data.z0_details = [];
        D.recon.recon_details.z0 = 0;
        D.recon.recon_details.z0_details = [];
        set(H.z0_cb, 'Value', 0);

        set(H.adjust_reference_and_trajectory_pb,'BackgroundColor',active_flag_color);
        
        local_update('adjust');
        drawnow;
    end

%%%%%%%%%%%%
    function local_clear_rawdata
        D.check.rawdata_loaded_flag = 0;

        set(H.load_rawdata_pb,'BackgroundColor',not_active_flag_color);
        
        D.rawdata = [];
        D.recon.recon_details.dwelltime = [];
        D.recon.recon_details.Nt = [];
        D.recon.recon_details.rawdata_filename = [];
        D.recon.recon_details.TR = [];
        D.recon.recon_details.DORK_frequency = [];
        D.check.trajectory_loaded_flag = 0;
        D.gui_data.rawdata_filename = '';
        
        set(H.rawdata_info_t,'String','');
        set(H.recon_range_e,'String','');
        local_set_status('Rawdata cleared.');
    end

%%%%%%%%%%%%
    function local_clear_reference
        D.check.reference_loaded_flag = 0;
        D.check.adjust_reference_and_trajectory_flag = 0;

        set(H.load_reference_pb,'BackgroundColor',not_active_flag_color);
        set(H.adjust_reference_and_trajectory_pb,'BackgroundColor',not_active_flag_color);
        
        D.reference = [];
        D.recon.recon_details.nCoils = [];
        D.recon.recon_details.recon_resolution = [];
        D.recon.recon_details.recon_voxel_size = [];
        D.param.recon_dimension = 3;
        D.gui_data.reference_filename = '';
        
        set(H.reference_info_t,'String','');
        set(H.recon_resolution_e,'String','');
        set(H.recon_voxel_size_e,'String','');
        set(H.recon_resolution_e,'Enable','off');
        set(H.recon_voxel_size_e,'Enable','off');
        set(H.adjust_reference_and_trajectory_pb,'Enable','off');
        local_set_status('Reference cleared.');
    end

%%%%%%%%%%%%
    function local_clear_trajectory
        D.check.trajectory_loaded_flag = 0;
        D.check.adjust_reference_and_trajectory_flag = 0;

        set(H.load_trajectory_pb,'BackgroundColor',not_active_flag_color);
        set(H.adjust_reference_and_trajectory_pb,'BackgroundColor',not_active_flag_color);
        
        D.trajectory = [];
        D.param.trajectory_range_string = {''};
        D.recon.recon_details.trajectory_scaling = [];
        D.recon.recon_details.nInterleaves = [];
        D.gui_data.trajectory_filename = '';
        
        set(H.interleaves_e,'String','');
        set(H.trajectory_info_t,'String','');        
        set(H.recon_resolution_e,'String','');
        set(H.recon_voxel_size_e,'String','');
        set(H.trajectory_range_info_pm,'String',{''});
        set(H.recon_resolution_e,'Enable','off');
        set(H.recon_voxel_size_e,'Enable','off');
        set(H.adjust_reference_and_trajectory_pb,'Enable','off');
        local_set_status('Trajectory cleared.');
    end

%%%%%%%%%%%%
    function local_set_trajectory_range_string
        for k=1:length(D.trajectory.idx)
            D.param.trajectory_range_string{k} = [num2str(k),'.  [ ',num2str(D.trajectory.idx{k}(1)),' : ',num2str(D.trajectory.idx{k}(end)),' ]'];
        end
        set(H.trajectory_range_info_pm,'String',D.param.trajectory_range_string);
    end

%%%%%%%%%%%%
    function local_check
        
        % reduce dimension of trajectory if it's a 2d reconstruction
        if D.check.trajectory_loaded_flag==1 && D.check.reference_loaded_flag==1
            if D.param.recon_dimension==2
                D.trajectory.fov = D.trajectory.fov(1:2);
                D.trajectory.resolution = D.trajectory.resolution(1:2);
                for k=1:length(D.trajectory.trajectory)
                    D.trajectory.trajectory{k} = D.trajectory.trajectory{k}(:,1:2);
                end
            end
        end
        
        % If the following parameters are empty, they are initialized
        if D.check.trajectory_loaded_flag==1 && D.check.reference_loaded_flag==1
            if isempty(D.recon.recon_details.recon_resolution)
                D.recon.recon_details.recon_resolution = ceil(D.trajectory.resolution);
            end
            if isempty(D.recon.recon_details.recon_voxel_size)
                D.recon.recon_details.recon_voxel_size = D.trajectory.fov ./ D.trajectory.resolution;
            end
            if isempty(D.recon.recon_details.recon_voxel_size)
                D.recon.recon_details.recon_voxel_size = D.trajectory.fov ./ D.trajectory.resolution;
            end
            if isempty(D.recon.recon_details.trajectory_scaling)
                D.recon.recon_details.trajectory_scaling = ones(1, D.param.recon_dimension);
            end
            set(H.recon_resolution_e,'String',['[',num2str(D.recon.recon_details.recon_resolution,'%i '),']']);
            set(H.recon_voxel_size_e,'String',['[',num2str(1e3*D.recon.recon_details.recon_voxel_size,'%.1f '),']']);
        end
        
        % Enable adjustment of reference data when trajectory and reference are loaded
        if D.check.trajectory_loaded_flag==1 && D.check.reference_loaded_flag==1
            set(H.recon_resolution_e,'Enable','on');
            set(H.recon_voxel_size_e,'Enable','on');
            set(H.adjust_reference_and_trajectory_pb,'Enable','on');
            
            % this means it is a spin echo sequence
            % ToDo: Once, te[1] is the traj. te for all sequences, this can
            % be calculated without D.trajectory and moved to the update f.
            if isfield(D.rawdata, 'sequence') && strcmp(D.rawdata.sequence(end-3:end), 'diff') 
                if isfield(D.trajectory, 'TE_s')
                    D.recon.recon_details.DeltaT = - D.trajectory.TE_s + D.rawdata.trajectIndices(1)*D.rawdata.dwelltime;
                else
                    warning('trajectory was not loaded from grad file. Therefore it does not contain TE_s. DeltaT is set to 0. This can corrupt the reconstuction when Total Variation is used in combination with off-resonance correction');
                    D.recon.recon_details.DeltaT = 0;
                end
            else
                % This is for the gradient echo sequences
                % Till now te(1) is the time between the pulse and the
                % beginning of the trajectory for all GE-MREG sequences.
                D.recon.recon_details.DeltaT = D.rawdata.te(1) + D.rawdata.trajectIndices(1)*D.rawdata.dwelltime;
            end
                
            
            
        else
            set(H.recon_resolution_e,'Enable','off');
            set(H.recon_voxel_size_e,'Enable','off');
            set(H.adjust_reference_and_trajectory_pb,'Enable','off');
            
        end
        
        if D.check.trajectory_loaded_flag==1 && D.check.reference_loaded_flag==1
            if isfield(D.reference, 'dim') && all(D.reference.dim==D.recon.recon_details.recon_resolution) && all(D.reference.fov==D.recon.recon_details.recon_voxel_size.*D.recon.recon_details.recon_resolution) && D.reference.Cor_angle == D.rawdata.Cor_angle && all(D.reference.shift == D.rawdata.shift./D.recon.recon_details.recon_voxel_size)
                set(H.adjust_reference_and_trajectory_pb,'BackgroundColor',active_flag_color);
                D.check.adjust_reference_and_trajectory_flag = 1;
            else
                set(H.adjust_reference_and_trajectory_pb,'BackgroundColor',not_active_flag_color);
                D.check.adjust_reference_and_trajectory_flag = 0;
            end
        end
        
        drawnow;

        if D.check.rawdata_loaded_flag && D.check.reference_loaded_flag==1 && D.check.trajectory_loaded_flag==1 
            if D.gui_data.add_penalty_counter==0
                add_penalty_pb_cb;
            end
            set(H.z0_cb,   'Enable', 'On');
        else
            set(H.z0_cb,   'Enable', 'Off');
        end
        
        
    end

%%%%%%%%%%%%
    function local_update(that)
        
        if D.check.adjust_reference_and_trajectory_flag
            D.gui_data.select_view_reference_string = {'Anatomical', 'Single Coil Images', 'Sensitivity Maps', 'Off-Resonance Map'};
            set(H.select_view_reference_pm, 'String', D.gui_data.select_view_reference_string);
        elseif D.check.reference_loaded_flag
            D.gui_data.select_view_reference_string = {'Anatomical', 'Single Coil Images'};
            if D.param.select_view_reference > 2;
                set(H.select_view_reference_pm,'Value',1);
                D.param.select_view_reference = 1;
            end
            set(H.select_view_reference_pm, 'String', D.gui_data.select_view_reference_string);
        else
            D.gui_data.select_view_reference_string = {''};
            set(H.select_view_reference_pm,'Value',1);
            D.param.select_view_reference = 1;
            set(H.select_view_reference_pm, 'String', D.gui_data.select_view_reference_string);
        end
        
        switch that
            case 'rawdata'
                if D.check.rawdata_loaded_flag==1
                    D.recon.recon_details.dwelltime = D.rawdata.dwelltime;
                    D.recon.recon_details.Nt = D.rawdata.Nt;
                    D.recon.recon_details.rawdata_filename = D.rawdata.rawdata_filename;
                    D.recon.recon_details.TR = D.rawdata.tr;
                    D.recon.recon_details.timeframes = 1:D.rawdata.Nt;
                    D.recon.recon_details.timeframes_string = ['1:',num2str(D.rawdata.Nt)];

                    set(H.rawdata_info_t,'String',{['MID = ',num2str(D.rawdata.mid)], ...
                                                   ['TR = ',num2str(1e3*D.rawdata.tr), 'ms'], ...
                                                   ['TE = ',num2str(1e3*D.rawdata.te(1)),'ms'], ...
                                                   ['FA = ',num2str(D.rawdata.flipAngle), 'deg'], ...
                                                   ['Nt = ', num2str(D.rawdata.Nt)],...
                                                   ['',D.rawdata.trajectory]});
                    set(H.recon_range_e,'String',D.recon.recon_details.timeframes_string);
                    set(H.load_rawdata_pb,'BackgroundColor',active_flag_color);
                    local_set_status('Data loaded.');
                else
                    D.recon.recon_details.dwelltime = [];
                    D.recon.recon_details.Nt = [];
                    D.recon.recon_details.rawdata_filename = [];
                    D.recon.recon_details.TR = [];
                    D.recon.recon_details.timeframes = [];
                    D.recon.recon_details.timeframes_string = '';
                    D.recon.recon_details.DeltaT = [];
                end
                
            case 'reference'
                if D.check.reference_loaded_flag==1
                    
                    
                    set(H.reference_info_t,'String',{['Res. = [',num2str(D.reference.raw.dim ,'%i '), ']'], ...
                                                     ['FOV = [',num2str(D.reference.raw.fov ,'%1.2f '), ']']});
                    set(H.load_reference_pb,'BackgroundColor',active_flag_color);
                    local_set_status('Reference loaded.');
                    
                    if D.param.recon_dimension==3
                        D.recon.recon_details.nCoils = size(D.reference.raw.cmaps,4);
                    else
                        D.recon.recon_details.nCoils = size(D.reference.raw.cmaps,3);
                    end
                else
                    D.reference.anatomical = [];
                    D.reference.smaps = [];
                    D.reference.wmap = [];
                    D.reference.shift = [];
                    D.recon.recon_details.nCoils = [];
                    D.check.adjust_reference_and_trajectory_flag = 0;
                end
                
            case 'adjust'
                
            case 'trajectory'
                if D.check.trajectory_loaded_flag==1
                    D.recon.recon_details.nInterleaves = length(D.trajectory.trajectory);
                    
                    set(H.load_trajectory_pb,'BackgroundColor',active_flag_color);
                    interleaves_e_cb([],[],length(D.trajectory.trajectory))
                    set(H.trajectory_info_t,'String',{['Res. = [',num2str(D.trajectory.resolution ,'%1.1f '), ']'], ...
                        ['FOV = [',num2str(D.trajectory.fov ,'%1.2f '), ']']});
                    local_set_status('Trajectory loaded.');
                else
                    D.recon.recon_details.nInterleaves = [];
                end
                
        end
        D.recon.recon_details.z0 = 0;
        D.gui_data.z0 = 0;
        D.recon.recon_details.z0_details = [];
        D.gui_data.z0_details = [];
        set(H.z0_cb, 'Value', 0);
        
    end

%%%%%%%%%%%%
    function nstr = local_framenumber2str(n)
        if isfield(D,'rawdata') && isfield(D.rawdata,'Nt') && ~isempty(D.rawdata.Nt)
            Nt = D.rawdata.Nt;
            Nd = floor(log10(Nt)) + 1;
            
            assert(n>=1, 'input of locale_framenumber2str must be greater than 1.');
            assert(n<=Nt, 'input of locale_framenumber2str must be smaller than Nt.');
            
            tmp = num2str(n);
            nstr = repmat('0',[1 Nd]);
            nstr([Nd-length(tmp)+1:Nd]) = tmp;
        else
            nstr = '';
        end
    end

%%%%%%%%%%%%
    function local_set_gui_font_size(n)
        for h0=get(H.main_fig,'Children').';
            set(h0,'FontUnits',font_units,'FontSize',n);
            if ~isempty(get(h0,'Children'))
                for h1 = get(h0,'Children').'
                    set(h1,'FontUnits',font_units,'FontSize',n);
                end
            end
        end
    end

end
