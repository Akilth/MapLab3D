function [fig_2dmap,ax_2dmap]=create_map_figure(fig_2dmap,ax_2dmap,create_figure_only,figvisible)
% Syntax example:
% 1)	Normal usage:
%		create_map_figure;
% 2)	Load project: Do not overwrite the existing figure when opening the new figure:
%		[fig_2dmap,ax_2dmap]	= create_map_figure([],[],true,'off');

global PP GV GV_H OSMDATA PLOTDATA MAP_OBJECTS APP

try
	
	% Initializations:
	if nargin==0
		if ~isfield(GV_H,'fig_2dmap')
			GV_H.fig_2dmap	= [];
		end
		if ~isfield(GV_H,'ax_2dmap')
			GV_H.ax_2dmap	= [];
		end
		fig_2dmap	= GV_H.fig_2dmap;
		ax_2dmap		= GV_H.ax_2dmap;
	end
	if nargin<3
		create_figure_only	= false;
	end
	if nargin<4
		figvisible	= 'on';
	end
	
	% Open or clear map figure:
	create_fig		= false;
	if isempty(fig_2dmap)
		create_fig		= true;
	else
		if ~isvalid(fig_2dmap)
			create_fig		= true;
		end
	end
	if create_fig
		% open the map figure:
		% Create the figure with toolstrip:
		% fig_2dmap				= figure;
		% Create the figure without toolstrip: This speeds up selection of map objects.
		switch GV.fig_2dmap_type
			case 1
				fig_2dmap		= figure('Visible',figvisible);
			case 2
				fig_2dmap		= uifigure('Visible',figvisible);
		end
		figure_theme(fig_2dmap,'set',[],'light');
		% Figure size:
		fig_2dmap_pos				= fig_2dmap.Position;
		fig_2dmap_pos(3)			= min(fig_2dmap_pos(3),APP.MapLab3D.Position(3)-100);
		fig_2dmap_pos(4)			= min(fig_2dmap_pos(4),APP.MapLab3D.Position(4)-100);
		fig_2dmap.Position	= fig_2dmap_pos;
		% Figure position:
		maplab3d_pos				= APP.MapLab3D.Position;
		fig_2dmap_pos				= fig_2dmap.Position;
		fig_2dmap_pos(1)			= maplab3d_pos(1)+maplab3d_pos(3)/2-fig_2dmap_pos(3)/2;
		fig_2dmap_pos(2)			= maplab3d_pos(2)+maplab3d_pos(4)/2-fig_2dmap_pos(4)/2;
		fig_2dmap_pos(2)			= min(fig_2dmap_pos(2),maplab3d_pos(2)+maplab3d_pos(4)-fig_2dmap_pos(4));
		fig_2dmap_pos(2)			= max(fig_2dmap_pos(2),50);
		fig_2dmap.Position	= fig_2dmap_pos;
	end
	clf(fig_2dmap,'reset');
	fig_2dmap.Visible		= figvisible;			% clf makes an invisible figure visible
	figure_theme(fig_2dmap,'set',[],'light');
	drawnow;
	set(fig_2dmap,'WindowStyle','normal');		% open in a standalone window (not docked)
	set(fig_2dmap,'Tag','maplab3d_figure');
	set(fig_2dmap,'Name','2D map');
	set(fig_2dmap,'NumberTitle','off');
	set(fig_2dmap,'Units','pixels');
	set(fig_2dmap,'WindowButtonUpFcn',GV.fig_2dmap_WindowButtonUpFcn);
	set(fig_2dmap,'WindowButtonDownFcn',GV.fig_2dmap_WindowButtonDownFcn);
	% If the figure type is uifigure, these values must be set to the default figure vales:
	% (https://de.mathworks.com/help/matlab/ref/matlab.ui.figure.html#mw_7ddd8cf0-2c8d-4d52-b1e5-9587dc7346cf)
	set(fig_2dmap,'HandleVisibility','on');
	set(fig_2dmap,'AutoResizeChildren','off');
	% 'SizeChangedFcn' callback will not execute while 'AutoResizeChildren' is set to 'on':
	set(fig_2dmap,'SizeChangedFcn',@(src,event)SizeChangedFcn_fig_2dmap(src,event,1,0));
	set(fig_2dmap,'Color',[1 1 1]);			% Background color: white
	
	% cameratoolbar disabled, because it changes the axis position:
	% The modification of lines and polygons like "Move vertex" will not work.
	% cameratoolbar(fig_2dmap,'Show');
	
	% Open axis:
	ax_2dmap	= axes(fig_2dmap);
	set(ax_2dmap,'Units','pixels');
	hold(ax_2dmap,'on');
	set(ax_2dmap,'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);
	grid(ax_2dmap,'on');
	box(ax_2dmap,'on');
	xlabel(ax_2dmap,'x / mm');
	ylabel(ax_2dmap,'y / mm');
	% The contour lines are deleted:
	APP.View_ShowContourLines_Menu.Checked	= 'off';
	
	toolbar_method	= 2;
	switch toolbar_method
		case 1
			% Control Chart Interactivity disabled, because it changes the axis position.
			ax_2dmap_toolbar	= axtoolbar(ax_2dmap,{'export','datacursor','pan'});
			% ax_2dmap.Toolbar.Visible='off';
			% disableDefaultInteractivity(ax_2dmap);
		case 2
			% Disabling ax_2dmap_toolbar completely speeds up selection of objects with the mouse.
			% Creating and deleting prevents a default toolbar.
			ax_2dmap_toolbar	= axtoolbar(ax_2dmap,{'export','datacursor','pan'});
			delete(ax_2dmap_toolbar);
	end
	
	% Set the base color:
	if ~isempty(PP)
		colno_base	= find([PP.color.prio]==0,1);
		if ~ishandle(ax_2dmap)
			errormessage(sprintf('There exists no map where to plot the objects.\nCreate the map first.'));
		end
		set(ax_2dmap,'Color',PP.color(colno_base,1).rgb/255);
	end
	
	% Plot limits and tiles:
	if ~create_figure_only
		
		% Assign figure and axis handles:
		GV_H.fig_2dmap		= fig_2dmap;
		GV_H.ax_2dmap		= ax_2dmap;
		
		% tile_no = -1: Limits of the OSM data: These limits cannot be changed.
		if isfield(OSMDATA,'bounds')
			x	= [OSMDATA.bounds.xmin_mm OSMDATA.bounds.xmax_mm OSMDATA.bounds.xmax_mm OSMDATA.bounds.xmin_mm];
			y	= [OSMDATA.bounds.ymin_mm OSMDATA.bounds.ymin_mm OSMDATA.bounds.ymax_mm OSMDATA.bounds.ymax_mm];
			poly_map_maxdim_mm	= polyshape(x,y);
		else
			poly_map_maxdim_mm	= polyshape();
		end
		ud_tile.tile_no	= -1;
		GV_H.poly_limits_osmdata=plot(ax_2dmap,poly_map_maxdim_mm,...
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
		
	end
	
catch ME
	errormessage('',ME);
end

