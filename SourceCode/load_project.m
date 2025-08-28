function load_project(map_pathname,map_filename)
% Load project:
% Syntax:
% - Ask for the filename of the " - MAP.fig"-file:
%   load_project;
% - Do not ask for the filename:
%   load_project(map_pathname,map_filename);

global APP GV GV_H PP ELE MAP_OBJECTS OSMDATA VER PLOTDATA PRINTDATA SETTINGS

try

	% Display state:
	t_start_statebusy	= clock;
	display_on_gui('state','Loading project ...','busy','add');

	% Ask for the map to be loaded:
	if nargin==0
		if ~isfield(GV,'projectdirectory')
			map_pathname					= SETTINGS.projectdirectory;
		else
			if isempty(GV.projectdirectory)
				map_pathname				= SETTINGS.projectdirectory;
			else
				map_pathname				= GV.projectdirectory;
			end
		end
		if isnumeric(map_pathname)
			map_pathname					= SETTINGS.default_pathname;
		else
			if exist(map_pathname,'dir')~=7
				% The directory does not exist:
				map_pathname				= SETTINGS.default_pathname;
			end
		end
		figure(APP.MapLab3D);	% This is a test to prevent the uiget window from being opened behind another window.
		[map_filename,map_pathname]	= uigetfile_local('*.fig',...
			sprintf('Select the map figure (... - v%1.0f.%1.0f - MAP.fig)',VER.no1,VER.no2),map_pathname);
		figure(APP.MapLab3D);	% This brings the app figure to the foreground.
		if isequal(map_filename,0)||isequal(map_pathname,0)
			display_on_gui('state',...
				sprintf('Loading project ... canceled (%s).',dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			return
		end
	else
		if exist([map_pathname map_filename],'file')~=2
			display_on_gui('state',...
				sprintf('Loading project ... error (%s).',dt_string(etime(clock,t_start_statebusy))),...
				'notbusy','replace');
			errortext	= sprintf([...
				' the file\n',...
				'%s\n',...
				'does not exist.'],[map_pathname map_filename]);
			errormessage(errortext)
		end
	end

	% Check the file extension:
	k					= find(map_filename=='.');
	if isempty(k)
		display_on_gui('state',...
			sprintf('Loading project ... done (%s).',dt_string(etime(clock,t_start_statebusy))),...
			'notbusy','replace');
		return
	end
	if k(end)<2
		display_on_gui('state',...
			sprintf('Loading project ... done (%s).',dt_string(etime(clock,t_start_statebusy))),...
			'notbusy','replace');
		return
	end
	map_filename_extension	= map_filename((k(end)+1):end);
	map_filename_withoutext	= map_filename(1:(k(end)-1));
	if ~strcmp(map_filename_extension,'fig')
		errortext	= sprintf([...
			'The file extension .%s is not supported.\n',...
			'The permitted file extension is: %s'],map_filename_extension,'.fig');
		errormessage(errortext)
	end
	mapdata_filename	= [map_filename_withoutext 'DATA.mat'];

	% Check whether the corresponding mapdata file exists:
	if exist([map_pathname mapdata_filename],'file')~=2
		errortext	= sprintf([...
			'The corresponding map data file\n',...
			'%s\n',...
			'does not exist in the path\n',...
			'%s.'],mapdata_filename,map_pathname);
		errormessage(errortext)
	end

	% Display message:
	set(GV_H.text_waitbar,'String',sprintf('Loading project. This may take some time ... '));

	% Load the map data file:
	mapdata	= load([map_pathname mapdata_filename],'-mat',...
		'OSMDATA',...
		'MAP_OBJECTS',...
		'GV_savedata',...
		'PLOTDATA',...
		'PRINTDATA',...
		'ver_mapdata',...
		'savetime_mapdata');
	if  ~(...
			isfield(mapdata,'OSMDATA'         ) &&...
			isfield(mapdata,'MAP_OBJECTS'     ) &&...
			isfield(mapdata,'GV_savedata'     ) &&...
			isfield(mapdata,'PLOTDATA'        ) &&...
			isfield(mapdata,'PRINTDATA'       ) &&...
			isfield(mapdata,'ver_mapdata'     ) &&...
			isfield(mapdata,'savetime_mapdata')      )
		errortext	= sprintf([...
			'The corresponding map data file\n',...
			'%s\n',...
			'does not contain the required data.'],mapdata_filename);
		errormessage(errortext)
	end

	% Open the figure:
	hf_map_new		= openfig([map_pathname map_filename],'invisible');
	figure_theme(hf_map_new,'set',[],'light');
	set(hf_map_new,'WindowStyle','normal');		% open in a standalone window (not docked)
	set(hf_map_new,'Tag','maplab3d_figure');

	% Check wether the figure contains the required userdata:
	ud_map_new		= hf_map_new.UserData;
	% cameratoolbar disabled, because it changes the axis position:
	% The modification of lines and polygons like "Move vertex" will not work.
	% cameratoolbar(hf_map_new,'Show');
	% e.g.:
	%               PP: [1×1 struct]
	%              ELE: [1×1 struct]
	%          ver_map: [1×1 struct]
	%     savetime_map: [2021 4 18 12 25 22.5800]
	if    ~isfield(ud_map_new,'PP'          )||...
			~isfield(ud_map_new,'ELE'         )||...
			~isfield(ud_map_new,'ver_map'     )||...
			~isfield(ud_map_new,'savetime_map')
		close(hf_map_new);
		errortext	= sprintf([...
			'The selected figure\n',...
			'%s\n',...
			'does not contain the required data.'],map_filename);
		errormessage(errortext)
	end

	% Check whether the two files have been saved at the same time:
	if ~isequal(ud_map_new.savetime_map,mapdata.savetime_mapdata)
		close(hf_map_new);
		errortext	= sprintf([...
			'The time at which the two files\n',...
			'%s and\n',...
			'%s\n',...
			'were saved is not identical.'],map_filename,mapdata_filename);
		errormessage(errortext)
	end

	% Check whether the two files have been saved with the same version number:
	if    ~isequal([ud_map_new.ver_map.no1  ud_map_new.ver_map.no2 ],[VER.no1 VER.no2])||...
			~isequal([mapdata.ver_mapdata.no1 mapdata.ver_mapdata.no2],[VER.no1 VER.no2])
		close(hf_map_new);
		errortext	= sprintf([...
			'The version number %1.0f.%1.0f at which the two files\n',...
			'%s and\n',...
			'%s\n',...
			'were saved is not identical to the current version number %1.0f.%1.0f.'],...
			mapdata.ver_mapdata.no1,mapdata.ver_mapdata.no2,...
			map_filename,mapdata_filename,...
			VER.no1,VER.no2);
		errormessage(errortext)
	end

	% Load the project:

	% Initializations:
	globalinits;

	% Assign the global variables:
	OSMDATA		= mapdata.OSMDATA;
	MAP_OBJECTS	= mapdata.MAP_OBJECTS;
	GV_savedata	= mapdata.GV_savedata;
	PLOTDATA		= mapdata.PLOTDATA;
	PRINTDATA	= mapdata.PRINTDATA;
	clear mapdata

	% Set OSMDATA_TABLE, I_OSMDATA_TABLE_TEMPPREV by updating the table:
	filter_osmdata(1);

	% PP:
	PP												= ud_map_new.PP;

	% ELE:
	ELE											= ud_map_new.ELE;

	% GV:
	GV.projectdirectory						= map_pathname;
	GV.map_filename							= map_filename;
	GV.mapdata_filename						= mapdata_filename;
	GV.map_is_saved							= 1;
	GV.no_selected_plotobjects				= 0;
	GV.selected_plotobjects					= [];

	% GV.projectdirectory maybe has been changed: Begin a new diary file:
	start_diary(GV.projectdirectory);

	% Create projectdirectory for the STL-files:
	testsample_no								= 0;
	[GV.projectdirectory_stl,GV.projectdirectory_stl_repaired]	= ...
		get_projectdirectory_stl(GV.projectdirectory,testsample_no);

	% Do not overwrite these fields of GV:
	fieldnames_no	= {...
		'projectdirectory';...
		'map_filename';...
		'mapdata_filename';...
		'map_is_saved';...
		'pathname_diary';...
		'projectdirectory_stl';...
		'projectdirectory_stl_repaired';...
		'no_selected_plotobjects';...
		'selected_plotobjects';...
		'selbyfilt';...
		'symbols_pathfilename';...
		'symbolsdirectory';...
		'projectdirectory_ts'};

	% Assign the other fields of GV:
	fn_sd			= fieldnames(GV_savedata);
	for ifn_sd=1:size(fn_sd,1)
		assign_field	= true;
		for ifn_no=1:size(fieldnames_no,1)
			if strcmp(fn_sd{ifn_sd,1},fieldnames_no{ifn_no,1})
				assign_field	= false;
				break
			end
		end
		if assign_field
			GV.(fn_sd{ifn_sd,1})		= GV_savedata.(fn_sd{ifn_sd,1});
		end
	end

	% Set menu checkboxes:
	if isempty(GV.iobj_testplot_simplify_v)
		APP.CreatemapSettingsShowTestplotsMenu.Checked='off';
	else
		APP.CreatemapSettingsShowTestplotsMenu.Checked='on';
	end
	if isempty(GV.colno_testplot_simplify_v)
		APP.MapEdit_SimplifyMapSettings_ShowTestplots_Menu.Checked='off';
	else
		APP.MapEdit_SimplifyMapSettings_ShowTestplots_Menu.Checked='on';
	end

	% Set the visibility of the map objects table:
	show_mapobjectstable('update');

	% Set variable elements of GV.tooltips after loading a project:
	set_tooltips('set_variable_tooltips');

	% GV_H.fig_2dmap:
	if isfield(GV_H,'fig_2dmap')
		if ishandle(GV_H.fig_2dmap)
			close(GV_H.fig_2dmap);
		end
	end
	GV_H.fig_2dmap						= hf_map_new;

	% GV_H.ax_2dmap:
	hc	= GV_H.fig_2dmap.Children;
	for i=1:length(hc)
		if strcmp(hc(i).Type,'axes')
			GV_H.ax_2dmap				= hc(i);
		elseif strcmp(hc(i).Type,'uicontrol')
			errormessage;
		end
	end

	% Handles of plot objects:
	map_objects_source		= struct([]);
	for imapobj=1:size(MAP_OBJECTS,1)
		MAP_OBJECTS(imapobj,1).h					= [];
		map_objects_source(imapobj,1).source_h	= [];
	end
	imax		= length(GV_H.ax_2dmap.Children);
	i_delete	= false(imax,1);
	GV_H.poly_tiles	= [];
	GV_H.poly_tileno	= [];

	% Assign the children handles only once: much faster!
	GV_H_ax_2dmap_Children		= GV_H.ax_2dmap.Children;

	for i=1:imax
		% The following commands have a long computation time inside the for-loop:
		% -	if isfield(GV_H.ax_2dmap.Children(i).UserData,'imapobj')
		% -	if isfield(GV_H.ax_2dmap.Children(i).UserData,'issource')
		% -	if ~GV_H.ax_2dmap.Children(i).UserData.issource

		GV_H_ax_2dmap_Children_i		= GV_H_ax_2dmap_Children(i);
		Children_i_assigned				= false;

		if isfield(GV_H_ax_2dmap_Children_i.UserData,'imapobj')

			% MAP_OBJECTS.h:
			if ~isfield(GV_H_ax_2dmap_Children_i.UserData,'issource')
				errormessage;
			end
			if ~GV_H_ax_2dmap_Children_i.UserData.issource
				% Visible plot object:
				imapobj											= GV_H_ax_2dmap_Children_i.UserData.imapobj;
				Children_i_assigned							= true;
				if isempty(MAP_OBJECTS(imapobj,1).h)
					MAP_OBJECTS(imapobj,1).h				= GV_H_ax_2dmap_Children_i;
				else
					MAP_OBJECTS(imapobj,1).h				= [MAP_OBJECTS(imapobj,1).h;GV_H_ax_2dmap_Children_i];
				end
			else
				% Invisible source data plot object:
				% The source plots are made visible, if the corresponding map object is selected.
				% This makes it easier to move the texts and symboles to the right place when editing the map.
				imapobj												= GV_H_ax_2dmap_Children_i.UserData.imapobj;
				Children_i_assigned							= true;
				if isempty(map_objects_source(imapobj,1).source_h)
					map_objects_source(imapobj,1).source_h	= GV_H_ax_2dmap_Children_i;
				else
					map_objects_source(imapobj,1).source_h	= ...
						[map_objects_source(imapobj,1).source_h;GV_H_ax_2dmap_Children_i];
				end
			end

		elseif isfield(GV_H_ax_2dmap_Children_i.UserData,'tile_no')
			tile_no												= GV_H_ax_2dmap_Children_i.UserData.tile_no;

			% GV_H.poly_frame:
			if tile_no==-3
				GV_H.poly_frame								= GV_H_ax_2dmap_Children_i;
				Children_i_assigned							= true;
			end

			% GV_H.poly_map_printout_obj_limits:
			if tile_no==-2
				GV_H.poly_map_printout_obj_limits		= GV_H_ax_2dmap_Children_i;
				Children_i_assigned							= true;
			end

			% GV_H.poly_limits_osmdata:
			if tile_no==-1
				GV_H.poly_limits_osmdata					= GV_H_ax_2dmap_Children_i;
				Children_i_assigned							= true;
			end

			% GV_H.poly_map_printout:
			if tile_no==0
				GV_H.poly_map_printout						= GV_H_ax_2dmap_Children_i;
				Children_i_assigned							= true;
			end

			% GV_H.poly_tiles:
			if tile_no>0
				GV_H.poly_tiles{tile_no,1}					= GV_H_ax_2dmap_Children_i;
				Children_i_assigned							= true;
			end

		elseif isfield(GV_H_ax_2dmap_Children_i.UserData,'tile_no_text')
			tile_no											= GV_H_ax_2dmap_Children_i.UserData.tile_no_text;

			% GV_H.poly_tileno:
			GV_H.poly_tileno{tile_no,1}				= GV_H_ax_2dmap_Children_i;
			Children_i_assigned							= true;

		else
			% temporary preview objects:
			i_delete(i,1)									= true;
			Children_i_assigned							= true;
		end

		if ~Children_i_assigned
			test=1;
		end

	end
	% Assign the source plots:
	for imapobj=1:size(MAP_OBJECTS,1)
		for i=1:size(MAP_OBJECTS(imapobj,1).h,1)
			for k=1:size(map_objects_source(imapobj,1).source_h,1)
				MAP_OBJECTS(imapobj,1).h(i,1).UserData.source(k,1).h	= map_objects_source(imapobj,1).source_h(k,1);
			end
		end
	end
	% Delete temporary preview objects:
	delete(GV_H.ax_2dmap.Children(i_delete));

	% Delete empty map objects:
	% This should should not happen. However, in the event of incorrect data, a crash is prevented.
	imapobj_delete	= false(size(MAP_OBJECTS,1),1);
	for imapobj=1:size(MAP_OBJECTS,1)
		if isempty(MAP_OBJECTS(imapobj,1).h)
			imapobj_delete(imapobj,1)	= true;
		end
	end
	MAP_OBJECTS(imapobj_delete,:)	= [];

	% Set the axis position:
	SizeChangedFcn_fig_2dmap([],[],1,1);

	% After assignment of GV_H.fig_2dmap and GV_H.ax_2dmap and the plot objects GV_H....:
	GV_H.fig_2dmap.Visible			= 'on';

	% Initialize the include and exclude tags table:
	set_inclexcltags_table('reset');

	% Set the object numbers dropdown menu:
	set_inclexcltags_table('init_objno_dropdown');

	% Set the value of the cutting lines dropdown menu to 'None' (make the map objects visible):
	set_previewtype_dropdown(1);

	% MAP_OBJECTS_TABLE:
	display_map_objects;

	% Display the paths and filenames:
	display_on_gui('pathfilenames');

	% Udate the legend:
	create_legend_mapfigure;

	% Update the lon,lat-x,y-calculator settings:
	calculator_latlonxy_reset;			% lon,lat-x,y-calculator reset

	% Check if the project parameter file exists on the saved path:
	if exist(GV.pp_pathfilename,'file')~=2
		if isfield(GV_H.warndlg,'load_project')
			if ishandle(GV_H.warndlg.load_project)
				close(GV_H.warndlg.load_project);
			end
		end
		GV_H.warndlg.load_project		= warndlg(sprintf([...
			'Load project:\n',...
			'The project parameter file\n',...
			'%s\n',...
			'does not exist.\n',...
			'\n',...
			'Reload the project parameters.'],GV.pp_pathfilename),'Warning');
		GV_H.warndlg.load_project.Tag	= 'maplab3d_figure';
	end

	% Execution time:
	t_end_statebusy					= clock;
	dt_statebusy						= etime(t_end_statebusy,t_start_statebusy);
	dt_statebusy_str					= dt_string(dt_statebusy);
	if dt_statebusy>GV.exec_time.load_project.dt
		GV.exec_time.load_project.name		= APP.LoadprojectMenu.Text;
		GV.exec_time.load_project.t_start	= t_start_statebusy;
		GV.exec_time.load_project.t_end		= t_end_statebusy;
		GV.exec_time.load_project.dt			= dt_statebusy;
		GV.exec_time.load_project.dt_str		= dt_statebusy_str;
	end

	% Display state:
	set(GV_H.text_waitbar,'String','');
	display_on_gui('state',...
		sprintf('Loading project ... done (%s).',dt_statebusy_str),...
		'notbusy','replace');

catch ME
	errormessage('',ME);
end


