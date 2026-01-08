function create_map_figure

global PP GV GV_H OSMDATA PLOTDATA MAP_OBJECTS APP

try
	
	% Open or clear map figure:
	if ~isfield(GV_H,'fig_2dmap')
		GV_H.fig_2dmap	= [];
	end
	if ~isfield(GV_H,'ax_2dmap')
		GV_H.ax_2dmap	= [];
	end
	create_fig		= false;
	if isempty(GV_H.fig_2dmap)
		create_fig		= true;
	else
		if ~isvalid(GV_H.fig_2dmap)
			create_fig		= true;
		end
	end
	if create_fig
		% open the map figure:
		% Create the figure with toolstrip:
		% GV_H.fig_2dmap				= figure;
		% Create the figure without toolstrip: This speeds up selection of map objects.
		switch GV.fig_2dmap_type
			case 1
				GV_H.fig_2dmap		= figure;
			case 2
				GV_H.fig_2dmap		= uifigure;
		end
		figure_theme(GV_H.fig_2dmap,'set',[],'light');
		% Figure size:
		fig_2dmap_pos				= GV_H.fig_2dmap.Position;
		fig_2dmap_pos(3)			= min(fig_2dmap_pos(3),APP.MapLab3D.Position(3)-100);
		fig_2dmap_pos(4)			= min(fig_2dmap_pos(4),APP.MapLab3D.Position(4)-100);
		GV_H.fig_2dmap.Position	= fig_2dmap_pos;
		% Figure position:
		maplab3d_pos				= APP.MapLab3D.Position;
		fig_2dmap_pos				= GV_H.fig_2dmap.Position;
		fig_2dmap_pos(1)			= maplab3d_pos(1)+maplab3d_pos(3)/2-fig_2dmap_pos(3)/2;
		fig_2dmap_pos(2)			= maplab3d_pos(2)+maplab3d_pos(4)/2-fig_2dmap_pos(4)/2;
		fig_2dmap_pos(2)			= min(fig_2dmap_pos(2),maplab3d_pos(2)+maplab3d_pos(4)-fig_2dmap_pos(4));
		fig_2dmap_pos(2)			= max(fig_2dmap_pos(2),50);
		GV_H.fig_2dmap.Position	= fig_2dmap_pos;
	end
	clf(GV_H.fig_2dmap,'reset');
	figure_theme(GV_H.fig_2dmap,'set',[],'light');
	drawnow;
	set(GV_H.fig_2dmap,'Tag','maplab3d_figure');
	set(GV_H.fig_2dmap,'Name','2D map');
	set(GV_H.fig_2dmap,'NumberTitle','off');
	set(GV_H.fig_2dmap,'SizeChangedFcn',@(src,event)SizeChangedFcn_fig_2dmap(src,event,1,0));
	set(GV_H.fig_2dmap,'Units','pixels');
	set(GV_H.fig_2dmap,'WindowButtonUpFcn',GV.fig_2dmap_WindowButtonUpFcn);
	set(GV_H.fig_2dmap,'WindowButtonDownFcn',GV.fig_2dmap_WindowButtonDownFcn);
	% If the figure type is uifigure, these values must be set to the default figure vales:
	% (https://de.mathworks.com/help/matlab/ref/matlab.ui.figure.html#mw_7ddd8cf0-2c8d-4d52-b1e5-9587dc7346cf)
	set(GV_H.fig_2dmap,'HandleVisibility','on');
	set(GV_H.fig_2dmap,'AutoResizeChildren','off');
	
	% cameratoolbar disabled, because it changes the axis position:
	% The modification of lines and polygons like "Move vertex" will not work.
	% cameratoolbar(GV_H.fig_2dmap,'Show');
	
	% Open axis:
	GV_H.ax_2dmap	= axes(GV_H.fig_2dmap);
	set(GV_H.ax_2dmap,'Units','pixels');
	hold(GV_H.ax_2dmap,'on');
	set(GV_H.ax_2dmap,'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
	grid(GV_H.ax_2dmap,'on');
	box(GV_H.ax_2dmap,'on');
	xlabel(GV_H.ax_2dmap,'x / mm');
	ylabel(GV_H.ax_2dmap,'y / mm');
	% The contour lines are deleted:
	APP.View_ShowContourLines_Menu.Checked	= 'off';
	
	toolbar_method	= 2;
	switch toolbar_method
		case 1
			% Control Chart Interactivity disabled, because it changes the axis position.
			GV_H.ax_2dmap_toolbar	= axtoolbar(GV_H.ax_2dmap,{'export','datacursor','pan'});
			% GV_H.ax_2dmap.Toolbar.Visible='off';
			% disableDefaultInteractivity(GV_H.ax_2dmap);
		case 2
			% Disabling GV_H.ax_2dmap_toolbar completely speeds up selection of objects with the mouse.
			% Creating and deleting prevents a default toolbar.
			GV_H.ax_2dmap_toolbar	= axtoolbar(GV_H.ax_2dmap,{'export','datacursor','pan'});
			delete(GV_H.ax_2dmap_toolbar);
	end
	
	% Set the base color:
	if ~isempty(PP)
		colno_base	= find([PP.color.prio]==0,1);
		if ~ishandle(GV_H.ax_2dmap)
			errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
		end
		set(GV_H.ax_2dmap,'Color',PP.color(colno_base,1).rgb/255);
	end
	
	% Plot limits and tiles:
	
	% tile_no = -1: Limits of the OSM data: These limits cannot be changed.
	if isfield(OSMDATA,'bounds')
		x	= [OSMDATA.bounds.xmin_mm OSMDATA.bounds.xmax_mm OSMDATA.bounds.xmax_mm OSMDATA.bounds.xmin_mm];
		y	= [OSMDATA.bounds.ymin_mm OSMDATA.bounds.ymin_mm OSMDATA.bounds.ymax_mm OSMDATA.bounds.ymax_mm];
		poly_map_maxdim_mm	= polyshape(x,y);
	else
		poly_map_maxdim_mm	= polyshape();
	end
	ud_tile.tile_no	= -1;
	GV_H.poly_limits_osmdata=plot(GV_H.ax_2dmap,poly_map_maxdim_mm,...
		'LineWidth',GV.plotsettings.poly_limits_osmdata.LineWidth,...
		'LineStyle',GV.plotsettings.poly_limits_osmdata.LineStyle,...
		'EdgeColor',GV.plotsettings.poly_limits_osmdata.EdgeColor,...
		'FaceAlpha',GV.plotsettings.poly_limits_osmdata.FaceAlpha,...
		'UserData',ud_tile);
	
	% tile_no = 0: Edges of the map to be printed:
	plot_poly_map_printout;
	
	% Plot the frame: First plot_poly_map_printout must be called!
	plot_2dmap_frame;
	
	% Plot the tiles: First plot_2dmap_frame must be called!
	% tile_no = i: Edges of the tiles:
	% The min and max values can be outside the edge of the entire map.
	plot_poly_tiles;
	
	% Create/modify legend:
	create_legend_mapfigure;
	
	% After plotting: set the axis position (before reset the zoom history!):
	SizeChangedFcn_fig_2dmap([],[],1,1);
	
	% Reset the zoom history;
	ax_2dmap_zoom('reset_zoom_history');
	
	% The map is created the first time or anew:
	% Delete all entries in OSMDATA.iobj:
	if isfield(OSMDATA,'iobj')
		OSMDATA.iobj.node			= zeros(size(OSMDATA.iobj.node));
		OSMDATA.iobj.way			= zeros(size(OSMDATA.iobj.way));
		OSMDATA.iobj.relation	= zeros(size(OSMDATA.iobj.relation));
	end
	
	% Clear PLOTDATA:
	PLOTDATA						= [];
	PLOTDATA.colno_v			= [];
	
	% Delete all entries in MAP_OBJECTS (MAP_OBJECTS contains information to every object in the map):
	MAP_OBJECTS					= [];
	
	% Update MAP_OBJECTS_TABLE:
	display_map_objects;
	
	% Clear OSMDATA_TABLE:
	filter_osmdata(1);
	
catch ME
	errormessage('',ME);
end

