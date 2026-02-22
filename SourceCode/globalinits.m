function globalinits
% Declares all variables as and assigns initial values

global APP SY PP OSMDATA ELE GV GV_H PLOTDATA PRINTDATA WAITBAR MAP_OBJECTS MAP_OBJECTS_TABLE I_OSMDATA_TABLE_TEMPPREV

%------------------------------------------------------------------------------------------------------------------
% Adjust these variables for compiling:

% Version number:
set_version_number;

% Save memory image for testing:
% Syntax: if GV.save_memory_dump&&~isdeployed ...
GV.save_memory_dump						= false;

%------------------------------------------------------------------------------------------------------------------
% Because these values and the diary are used in errormessage: assign at the beginning:

% Last errormessage:
GV.errormessage.errortext				= '';
GV.errormessage.errorlog				= '';
GV.errormessage.ST						= struct('file','','name','','line',[]);
GV.errormessage.ME						= MException('','');
GV.errormessage.diary					= '';

% Error ID for capturing error information:
GV.errID_general							= 'MapLab3D:error_ID_general';

% Clear the diary file and begin a new one:
[pathname,~,~]								= fileparts(mfilename('fullpath'));
% The value of GV.pathname_diary must be different from pathname for the diary to be started:
GV.pathname_diary							= '';
start_diary(pathname);

try
	
	%------------------------------------------------------------------------------------------------------------------
	
	% Because the size of individual figures can be set in the app:
	% Change the default setting so that figures are created individually and not "docked":
	set(0,'DefaultFigureWindowStyle','normal');
	
	% MATLAB version:
	GV.matlab_version												= ver;
	
	% Default figure settings:
	GV.defsettings.FigureColor.light							= [245 245 245]/255;
	GV.defsettings.FigureColor.dark							= [245 245 245]/255;
	% Default axes settings:
	% GV.defsettings.AxesXColor.light						= [33 33 33]/255;
	% GV.defsettings.AxesXColor.dark							= [33 33 33]/255;
	% GV.defsettings.AxesYColor.light						= [33 33 33]/255;
	% GV.defsettings.AxesYColor.dark							= [33 33 33]/255;
	% GV.defsettings.AxesZColor.light						= [33 33 33]/255;
	% GV.defsettings.AxesZColor.dark							= [33 33 33]/255;
	GV.defsettings.AxesColor.light							= [1 1 1];
	GV.defsettings.AxesColor.dark								= [1 1 1];
	GV.defsettings.AxesGridColor.light						= [33 33 33]/255;
	GV.defsettings.AxesGridColor.dark						= [33 33 33]/255;
	GV.defsettings.AxesGridAlpha.light						= 0.15;
	GV.defsettings.AxesGridAlpha.dark						= 0.15;
	GV.defsettings.AxesMinorGridColor.light				= [33 33 33]/255;
	GV.defsettings.AxesMinorGridColor.dark					= [33 33 33]/255;
	GV.defsettings.AxesMinorGridAlpha.light				= 0.15;
	GV.defsettings.AxesMinorGridAlpha.dark					= 0.15;
	% Default uicontrol settings:
	GV.defsettings.figure.color.light						= [245 245 245]/255;
	GV.defsettings.figure.color.dark							= fliplightness(GV.defsettings.figure.color.light);
	GV.defsettings.uibutton.BackgroundColor.light		= [245 245 245]/255;
	GV.defsettings.uibutton.BackgroundColor.dark			= fliplightness(GV.defsettings.uibutton.BackgroundColor.light);
	GV.defsettings.uibutton.FontColor.light				= [33 33 33]/255;
	GV.defsettings.uibutton.FontColor.dark					= fliplightness(GV.defsettings.uibutton.FontColor.light);
	GV.defsettings.axes.Color.light							= [1 1 1];
	GV.defsettings.axes.Color.dark							= [0 0 0];
	GV.defsettings.text.FontColor.light						= [33 33 33]/255;
	GV.defsettings.text.FontColor.dark						= fliplightness(GV.defsettings.text.FontColor.light);
	GV.defsettings.uieditfield.BackgroundColor.light	= [255 255 255]/255;
	GV.defsettings.uieditfield.BackgroundColor.dark		= fliplightness(GV.defsettings.uieditfield.BackgroundColor.light);
	GV.defsettings.uieditfield.FontColor.light			= [33 33 33]/255;
	GV.defsettings.uieditfield.FontColor.dark				= fliplightness(GV.defsettings.uieditfield.FontColor.light);
	GV.defsettings.uitab.BackgroundColor.light			= [245 245 245]/255;
	GV.defsettings.uitab.BackgroundColor.dark				= fliplightness(GV.defsettings.uitab.BackgroundColor.light);
	
	% -----------------------------------------------------------------------------------------------------------------
	% From 2025a: graphics theme:
	% - To avoid having to adjust all black plot object colors in the dark theme and
	% - to ensure that exported figures have a white background:
	
	% This does not work in 2025a (read only):
	% set(0,'DefaultFigureTheme','light');
	
	% THis affects also apps and dialog boxes:
	% set(0,'DefaultFigureColor',GV.defsettings.FigureColor.light);
	% set(0,'DefaultAxesXColor',GV.defsettings.AxesXColor.light);
	% set(0,'DefaultAxesYColor',GV.defsettings.AxesYColor.light);
	% set(0,'DefaultAxesZColor',GV.defsettings.AxesZColor.light);
	
	% Options for saving figures with a white background even in dark mode/dark theme:
	% 1)	Replace all calls to figure (338x) and clf (98x) with figure_local and clf_local
	%		clf(hf,'reset'); resets the background color!
	%		-	Set either the figure background color or the axis color
	%			fig.Color / ax.XColor / ax.YColor / ax.ZColor
	%		-	Or set Figure Theme property ==> no further changes to axis settings necessary
	% 2)	Check all occurrences of Color' (515x) and k' (248x), replace black with white if necessary
	%		with global variable GV.bw=[1 1 1] or GV.bw=[0 0 0]
	% 3)	Least amount of work, realized:
	%		-	Only selected figures: Manually set theme to light
	%			GV_H.fig_2dmap
	%			GV_H.fig_frame_crosssection
	%			GV_H.fig_frame_3dview
	%			GV_H.fig_stldata_map
	%			GV_H.fig_stldata_tile
	%			GV_H.fig_stldata_color
	%			GV_H.fig_topview_map
	%			GV_H.fig_latlonxy
	%			Also when using print/copygraphics/exportgraphics/saveas/savefig.
	%     Additionally:
	%     -    Always display axes with a white background.
	%     -    Menu: Current figure: change theme
	
	% With these default settings, axes are always displayed in light colors
	% and the plot colors do not need to be changed:
	set(0,'DefaultAxesColor',GV.defsettings.AxesColor.light);
	set(0,'DefaultAxesGridColor',GV.defsettings.AxesGridColor.light);
	set(0,'DefaultAxesGridAlpha',GV.defsettings.AxesGridAlpha.light);
	set(0,'DefaultAxesMinorGridColor',GV.defsettings.AxesMinorGridColor.light);
	set(0,'DefaultAxesMinorGridAlpha',GV.defsettings.AxesMinorGridAlpha.light);
	
	% -----------------------------------------------------------------------------------------------------------------
	
	% Project parameters:
	PP												= [];
	
	% Test samples:
	GV.testsample_no_max						= 35;		% before set_settings('init') !
	
	% Initialize SETTINGS:
	set_settings('init');
	
	% Matlab search path, Symbols, Settings:
	SY												= [];
	[pathname,~,~]	= fileparts(mfilename('fullpath'));
	cd(pathname);				% necessary after compiling the app
	addpath(pathname);		% necessary to avoid "Warning: File 'UnDo.png' is not on the MATLAB or specified path."
	try
		load([pathname '\symbols.mat'],'-mat','SY');
	catch
		errormessage(sprintf([...
			'It was not possible to load the file "symbols.mat".\n',...
			'The program should be reinstalled.']));
	end
	
	% OSM data:
	OSMDATA										= [];
	OSMDATA.node								= [];
	OSMDATA.way									= [];
	OSMDATA.relation							= [];
	OSMDATA.keys.k								= '';
	OSMDATA.keys.N								= [];
	OSMDATA.keys.in							= [];
	OSMDATA.keys.iw							= [];
	OSMDATA.keys.ir							= [];
	OSMDATA.keys.int							= [];
	OSMDATA.keys.iwt							= [];
	OSMDATA.keys.irt							= [];
	OSMDATA.values.v							= '';
	OSMDATA.values.N							= [];
	OSMDATA.values.in							= [];
	OSMDATA.values.iw							= [];
	OSMDATA.values.ir							= [];
	OSMDATA.values.int						= [];
	OSMDATA.values.iwt						= [];
	OSMDATA.values.irt						= [];
	OSMDATA.no_tags							= 0;
	% Do not initialize OSMDATA.bounds: isfield(OSMDATA,'bounds') is a test if the OSM data is loaded
	
	% Clear the table:
	filter_osmdata(1);
	
	% lon,lat-x,y-calculator reset:
	calculator_latlonxy_reset;										% lon,lat-x,y-calculator reset
	
	% Elevation data:
	ELE											= [];
	
	% Global variables:
	
	GV.map_origin								= [];
	GV.ele_filtset_lon_filtersize			= 1;
	GV.ele_filtset_lat_filtersize			= 1;
	GV.ele_filtset_lon_sigma				= 1;
	GV.ele_filtset_lat_sigma				= 1;
	GV.nmax_elevation_data_reduction		= 1000;
	GV.map_is_saved							= 0;
	
	GV.iobj_testplot_simplify_v											= [];
	GV.colno_testplot_simplify_v											= [];
	APP.CreatemapSettingsShowTestplotsMenu.Checked					= 'off';
	APP.MapEdit_SimplifyMapSettings_ShowTestplots_Menu.Checked	= 'off';
	
	GV.pp_general_origin_user_lat				= [];
	GV.pp_general_origin_user_lon				= [];
	GV.pp_general_scale							= [];
	GV.pp_general_superelevation				= [];
	GV.pp_colorspec_ele_filtset_filtersize	= [];
	GV.pp_colorspec_ele_filtset_sigma		= [];
	GV.pp_general_dxy_ele_mm					= [];
	GV.pp_general_interpolation_method		= [];
	
	% do not initialize these paths and filenames:
	% GV.map_filename
	% GV.mapdata_filename
	% GV.pp_projectfilename
	% GV.pp_pathfilename
	% GV.projectdirectory
	% GV.projectdirectory_stl
	% GV.projectdirectory_stl_repaired
	% GV.symbols_pathfilename
	% GV.symbolsdirectory
	% GV.projectdirectory_ts
	% GV.savecurrfigdirectory
	
	% OSM and elevation data path and filenames:
	GV.osm_filename							= '';
	GV.osm_pathname							= '';
	GV.osm_pathfilename						= '';
	GV.ele_pathname							= '';
	
	% Global handles:
	% Do not initialize the rest of GV_H
	GV_H.map_tempprevobjects				= [];
	GV_H.warndlg								= [];
	
	% Data for creating the map: lines, areas, texts:
	PLOTDATA										= [];
	
	% Data when creating the stl files:
	PRINTDATA									= [];
	
	% Plot settings:
	GV.plotsettings.poly_limits_osmdata.LineWidth		= 5;
	GV.plotsettings.poly_limits_osmdata.LineStyle		= '-';
	GV.plotsettings.poly_limits_osmdata.EdgeColor		= 'k';
	GV.plotsettings.poly_limits_osmdata.FaceAlpha		= 0;
	
	% Preview plot settings:
	GV.preview.Color				= [1 0 0];			% 'r'
	GV.preview.EdgeColor			= [1 0 0];			% 'r'
	GV.preview.FaceColor			= [1 0 0];			% 'r'
	GV.preview.LineStyle			= '-';
	GV.preview.LineWidth			= 3;
	GV.preview.Marker				= '.';
	GV.preview.MarkerSize		= 30;
	GV.preview.MarkerSizeFlash	= 50;					% disappears after 1s
	GV.tempprev.Color				= [1 0 1];			% 'm'
	GV.tempprev.LineStyle		= '-';
	GV.tempprev.LineWidth		= 3;
	GV.tempprev.Marker			= '.';
	GV.tempprev.MarkerSize		= 30;
	
	% Visibilty plot settings:
	GV.visibility.show.facealpha		= 0.35;
	GV.visibility.show.edgealpha		= 1;
	GV.visibility.grayout.facealpha	= 0;
	GV.visibility.grayout.edgealpha	= 0.25;
	
	% Plots linewidth :
	GV.colorno_e0_linewidth		= 1;				% Linewidth for plots with color number equal to 0
	GV.colorno_g0_linewidth		= 0.5;			% Linewidth for plots with color number greater than 0
	
	% jointtype when creating the stl-files and enlarging the holes to be able to insert other parts:
	GV.jointtype_bh				= 'square';		% 'miter', 'square', ('round')
	GV.miterlimit_bh				= 2;				% relevant if jointtype_bh='miter'
	GV.jointtype_frame			= 'miter';		% 'miter', 'square', ('round')
	GV.miterlimit_frame			= 2;				% relevant if jointtype_bh='miter'
	
	% For testing:
	GV.test_readosm				= [];
	
	% Contour plots level step size:
	GV.contour_stepsize(1,1)	= 2;
	GV.contour_stepsize(2,1)	= 0.5;
	
	% Command for calling osmfilter.exe:
	GV.osmfilter_command			= '';
	
	% Distance between the fore- and background of plot objects.
	% The outlines must not overlap (less problems in map2stl.m).
	GV.d_forebackgrd_plotobj				= 0.01;				% >> GV.tol_1 !!!
	
	% Tolerances:
	GV.tol_1										= 1e-6;				% Tolerance for comparison of vertex coordinates
	GV.tol_2										= 1e-3;				% Tolerance for plausibility questions
	GV.tol_tp									= 1e-4;				% Tolerance for vertex coordinates distances in T.Points
	%																		  << GV.d_forebackgrd_plotobj
	%																		  >> GV.tol_1
	GV.tol_angle								= 1e-3;				% Tolerance for angles between vertices
	%																		  Too small a value can lead to missing surfaces
	%																		  in the triangulation
	GV.tol_connectways_manually			= 0.1;				% Tolerance for connecting ways manually (button "Connect")
	
	% Waitbar:
	GV.waitbar_dtupdate						= 1;					% Time between two waitbar updates
	GV.waitbar_color_userinput				= [1 0.95 0];		% Waitbar background color when waiting for user input
	
	% Execution times:
	GV.exec_time.create_map.dt					= 0;
	GV.exec_time.load_project.dt				= 0;
	GV.exec_time.map2stl.dt						= 0;
	GV.exec_time.open_osm.dt					= 0;
	GV.exec_time.open_pp.dt						= 0;
	GV.exec_time.plotosmdata_simplify.dt	= 0;
	GV.exec_time.save_project.dt				= 0;
	
	% 2D map figure type
	% 1	figure
	% 2	uifigure: faster selection of map objects, probably because there are no figure tools.
	GV.fig_2dmap_type								= 2;
	
	% Handling interactions with the mouse:
	GV.mouse_interaction_method				= 2;
	switch GV.mouse_interaction_method
		case 1
			% Create a axis ButtonDownFcd callback for every map object and use the rbbox command.
			GV.ax_2dmap_ButtonDownFcd			= @ButtonDownFcn_ax_2dmap;
			GV.fig_2dmap_WindowButtonUpFcn	= '';
			GV.fig_2dmap_WindowButtonDownFcn	= '';
		case 2
			% Create a figure WindowButtonDownFcn and WindowButtonUpFcn callback to get the selected area.
			% Do not create a ButtonDownFcd callback for every map object and do not use the rbbox command.
			% This is faster.
			GV.ax_2dmap_ButtonDownFcd			= '';
			GV.fig_2dmap_WindowButtonUpFcn	= @WindowButtonUpFcn_fig_2dmap;
			GV.fig_2dmap_WindowButtonDownFcn	= @WindowButtonDownFcn_fig_2dmap;
	end
	
	% Settings for the 2d map context menu (funktion ButtonDownFcn_ax_2dmap):
	GV_H.fig_2dmap_cm.lc_xmin					= 1;
	GV_H.fig_2dmap_cm.lc_xmax					= -1;
	GV_H.fig_2dmap_cm.lc_ymin					= 1;
	GV_H.fig_2dmap_cm.lc_ymax					= -1;
	GV_H.fig_2dmap_cm.clicked_object			= [];
	GV_H.fig_2dmap_cm.poly_outside_spec		= polyshape();
	GV_H.fig_2dmap_cm.poly_dzmax				= polyshape();
	
	% Legend: background z-value:
	GV.legend_z_topside_bgd						= 0;
	
	% plotosmdata_simplify settings:
	% Change resolution of lines and areas:
	% dmin to small: possibly numerical problems in map2stl.m
	GV.plotosmdata_simplify.dmax_changeresolution	= [];
	GV.plotosmdata_simplify.dmin_changeresolution	= 0.01;
	GV.plotosmdata_simplify.nmin_changeresolution	= [];
	
	% 2d Map figure handle: previous zoom level: do not initialize:
	% GV.ax_2dmap_xlim_last
	% GV.ax_2dmap_ylim_last
	% GV.ax_2dmap_i_xylim_last
	
	% Edit map: Faktor between fast/normal/slow move/rotate steps and move mapview steps
	GV.pp_stepwidth_move_object_factor		= 10;				% = PP.general.change_map_stepwidth.move_object_factor
	GV.pp_stepwidth_rotate_object_factor	= 10;				% = PP.general.change_map_stepwidth.rotate_object_factor
	GV.pp_stepwidth_move_mapview_small		= 10;				% = PP.general.change_map_stepwidth.move_mapview_small
	GV.pp_stepwidth_move_mapview_medium		= 30;				% = PP.general.change_map_stepwidth.move_mapview_medium
	GV.pp_stepwidth_move_mapview_large		= 90;				% = PP.general.change_map_stepwidth.move_mapview_large
	set_tooltips('move_mapobject');								% set tooltips of move map objects buttons
	set_tooltips('rotate_mapobject');							% set tooltips of rotate map objects buttons
	set_tooltips('move_mapview');									% set tooltips of move mapview buttons
	
	% Maximum number of include and exclude tags:
	GV.pp_obj_incltags_no_row_max				= 5;
	GV.pp_obj_incltags_no_col_max				= 5;
	GV.pp_obj_excltags_no_row_max				= 5;
	GV.pp_obj_excltags_no_col_max				= 5;
	GV.pp_obj_inclexcltags_no_row_min		= 5;
	GV.pp_obj_inclexcltags_no_col_min		= 5;
	
	% During "Create map," the dimensions of map objects are displayed in the Command Window (development mode) or 
	% in the Log (deployed) if they are greater than the minimum dimensions defined in the project parameters 
	% divided by this value. This value should be greater than 1, for example 10.
	GV.testout_minvalues_divisor				= 10;
	
	% Logical arrays: true if the legend element has a symbol or text specified:
	GV.pp_legend_element_is_empty_m			= true(0,0);
	GV.pp_legend_element_row_is_empty_v		= true(0,0);
	GV.pp_legend_element_col_is_empty_v		= true(0,0);
	
	% Initialize the include and exclude tags table:
	set_inclexcltags_table('reset');
	
	% Set the object numbers dropdown menu:
	set_inclexcltags_table('init_objno_dropdown');
	
	% Number of selected plot objects:
	GV.no_selected_plotobjects					= 0;
	GV.selected_plotobjects						= [];
	
	% Log:
	GV.log.create_map.pathfilename			= '';
	GV.log.create_map.text						= '';
	GV.log.create_map.line_str					= sprintf([...
		'--------------------------------------------------',...	% 50
		'--------------------------------------------------',...	% 50
		'----------------------']);
	
	% User command:
	GV.user_command								= '';
	
	% Select by filter default settings:
	GV.selbyfilt.def_val.Visible_CheckBox.Value												= true;
	GV.selbyfilt.def_val.GrayedOut_CheckBox.Value											= true;
	GV.selbyfilt.def_val.Hidden_CheckBox.Value												= true;
	GV.selbyfilt.def_val.TempHidden_CheckBox.Value											= true;
	GV.selbyfilt.def_val.Lines_CheckBox.Value													= true;
	GV.selbyfilt.def_val.Areas_CheckBox.Value													= true;
	GV.selbyfilt.def_val.Texts_CheckBox.Value													= true;
	GV.selbyfilt.def_val.Symbols_CheckBox.Value												= true;
	GV.selbyfilt.def_val.ConnectionLines_CheckBox.Value									= true;
	GV.selbyfilt.def_val.PreviewObjects_CheckBox.Value										= true;
	GV.selbyfilt.def_val.PreviewCuttingLines_CheckBox.Value								= false;
	GV.selbyfilt.def_val.CuttingLines_CheckBox.Value										= false;
	GV.selbyfilt.def_val.KeywordSearchDescription_EditField.Value						= '';
	GV.selbyfilt.def_val.KeywordSearchTextTag_EditField.Value							= '';
	GV.selbyfilt.def_val.MinDiag_EditField.Value												= 0;
	GV.selbyfilt.def_val.MaxDiag_EditField.Value												= 1e10;
	GV.selbyfilt.def_val.MinArea_EditField.Value												= 0;
	GV.selbyfilt.def_val.MaxArea_EditField.Value												= 1e10;
	GV.selbyfilt.def_val.ObjectNumbers_ListBox.Value										= {'---'};
	GV.selbyfilt.def_val.ColorNumbers_ListBox.Value											= {'---'};
	GV.selbyfilt.def_val.CharacterStyleNumbers_ListBox.Value								= {'---'};
	GV.selbyfilt.def_val.Symbols_ListBox.Value												= {'---'};
	GV.selbyfilt.def_val.SelectObjects_ThatMeetTheCond_CheckBox.Value					= true;
	GV.selbyfilt.def_val.SelectObjects_ExceptThoseThatMeetTheCond_CheckBox.Value	= false;
	GV.selbyfilt.val																					= GV.selbyfilt.def_val;
	
	% input dialog boxes: default inputs:
	% function plot_modify:
	GV.plotmodify.entercircle_definput		= {...
		'1';...								% radius
		'0';...								% phi_start
		'360';...							% phi_end
		'15';...								% phi_step
		'';...								% centerpoint_x
		''};									% centerpoint_y
	GV.plotmodify.enterrectangle_definput		= {...
		'100';...							% rect_width
		'100';...							% rect_height
		'';...								% rect_center_x
		''};									% rect_center_y
	% function analyze_unitedcolors:
	GV.analyze_unitedcolors.detect_holes									= [];
	GV.analyze_unitedcolors.detect_holes.definput{1,1}					= [];		% colno_uec_v
	% GV.analyze_unitedcolors.detect_holes.definput{2,1}				= 4;		% hole_mindiag
	% GV.analyze_unitedcolors.detect_holes.definput{3,1}				= 5;		% hole_minarea
	GV.analyze_unitedcolors.detect_small_pieces							= [];
	GV.analyze_unitedcolors.detect_small_pieces.definput{1,1}		= [];		% colno_uec_v
	% GV.analyze_unitedcolors.detect_small_pieces.definput{2,1}		= 6;		% mindiag
	% GV.analyze_unitedcolors.detect_small_pieces.definput{3,1}		= 8;		% minarea
	GV.analyze_unitedcolors.detect_fragile_pieces						= [];
	GV.analyze_unitedcolors.detect_fragile_pieces.definput{1,1}		= [];		% colno_uec_v
	% GV.analyze_unitedcolors.detect_fragile_pieces.definput{2,1}	= 1;		% possbreakpoint_minwidth
	GV.analyze_unitedcolors.detect_misstextsymb							= [];
	GV.analyze_unitedcolors.detect_misstextsymb.definput{1,1}		= [];		% colno_uec_v
	GV.analyze_unitedcolors.detect_misstextsymb.definput{2,1}		= [];		% iobj_misstext_v
	GV.analyze_unitedcolors.detect_misstextsymb.definput{3,1}		= 1;		% nmin_overlapping_texts
	GV.analyze_unitedcolors.detect_misstextsymb.definput{4,1}		= 1;		% nmax_overlapping_texts
	GV.analyze_unitedcolors.detect_misstextsymb.definput{5,1}		= 1;		% search_texts_without_overlap
	GV.analyze_unitedcolors.detect_misstextsymb.definput{6,1}		= [];		% iobj_misssymb_v
	GV.analyze_unitedcolors.detect_misstextsymb.definput{7,1}		= 1;		% nmin_overlapping_symbs
	GV.analyze_unitedcolors.detect_misstextsymb.definput{8,1}		= 1;		% nmax_overlapping_symbs
	GV.analyze_unitedcolors.detect_misstextsymb.definput{9,1}		= 1;		% search_symbs_without_overlap
	GV.open_ele.definput_res{1,1}												= 3600;	% ppdlon
	GV.open_ele.definput_res{2,1}												= 3600;	% ppdlat
	GV.open_ele.definput_bb														= [];
	
	% Adding elements in OSMDATA_TABLE to the plot data:
	% -	GV.get_nodes_ways_repeatedly=false:
	%		If a node or way is already part of a relation, it is no longer added to the data.
	%		This should prevent holes from being filled again.
	%		However, if a closed way is a hole in a relation and at the same time an area with
	%		slightly different properties, this way must be used multiple times.
	%		Example: An area in a forest area where other trees are standing, but which still belongs to the forest.
	% -	GV.get_nodes_ways_repeatedly=true:
	%		Nodes and ways with the same ID can be added from relations and also individually to the plot data.
	%		Because the plot data now stores whether an area belongs to a relation or not, a distinction can be made
	%		between the use of addboundary (relations) and union (closed ways, after relations) when creating polygons
	%		(in the connwaysarea2polyarea function). This prevents addboundary from being used twice with the same area.
	% Problem with GV.get_nodes_ways_repeatedly=true:
	% Relations of rivers consist of ways that also have the tag waterway=river.
	% Rivers are therefore always created twice with GV.get_nodes_ways_repeatedly=true.
	% Solution:
	% -	In different relations, the multiple use of nodes and ways is always permitted.
	% -	For individual ways, a distinction is made depending on the type of display:
	%		-	When displayed as an area, the repeated use of ways is also permitted in certain cases if they are
	%			already part of a relation, because it could be an area within a hole in a relation.
	%			Therefore, repeated use as a single way is only permitted for members with role=inner, 
	%			but not for all other members of a relation: see plotosmdata_getdata.m.
	%		-	When displayed as a line (not as an area), the repeated use of ways is not permitted if they are
	%			already part of a relation, because otherwise the way would exist twice.
	%		-	The parameter GV.get_nodes_ways_repeatedly is retained nonetheless in order to identify 
	%			where in the program these measures are taken.
	% -	Nodes are used for text and symbols and have their own parameters:
	%		If a text or symbol has already been generated for a relation, the same text or symbol does not
	%		need to be created for individual ways that are part of this relation:
	
	GV.get_nodes_ways_repeatedly				= true;
	GV.get_nodes_ways_repeatedly_texts		= false;
	GV.get_nodes_ways_repeatedly_symbols	= false;
	
	% Copy and save figure view:
	GV.current_figure_view					= [];
	
	% Switch warnings off:
	GV.warnings_off							= true;
	
	% Collect the objects for user interactions: see startupFcn(app)
	
	% handle of the waitbar:
	WAITBAR										= [];
	
	% plot object handles of the 2d-map:
	MAP_OBJECTS									= [];
	% table with relevant information to all objects in the map:
	MAP_OBJECTS_TABLE							= [];
	% Clear the table:
	display_map_objects;
	
	% current Indices of temporary preview objects in OSMDATA_TABLE:
	I_OSMDATA_TABLE_TEMPPREV				= [];
	
	% Set the selectable color numbers for creating cutting lines (after initialization of MAP_OBJECTS):
	PRINTDATA.obj_union_equalcolors		= [];
	set_previewtype_dropdown(1);
	
	% Clear the map:
	if isfield(GV_H,'ax_2dmap')
		if ~isempty(GV_H.ax_2dmap)
			if ishandle(GV_H.ax_2dmap)
				cla(GV_H.ax_2dmap,'reset');
			end
		end
	end
	
catch ME
	errormessage('',ME);
end

