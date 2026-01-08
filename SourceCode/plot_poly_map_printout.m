function plot_poly_map_printout
% Plots the edges of the map to be printed als polygon object in the map with the axis GV_H.ax_2dmap.
% This can be necessary when creating the map or when resetting the printout limits after manual changes.

global GV GV_H OSMDATA PP

try

	% Delete existing polygon objects:
	if isfield(GV_H,'poly_map_printout')
		if ishandle(GV_H.poly_map_printout)
			delete(GV_H.poly_map_printout);
		end
	end
	if isfield(GV_H,'poly_map_printout_obj_limits')
		if ishandle(GV_H.poly_map_printout_obj_limits)
			delete(GV_H.poly_map_printout_obj_limits);
		end
	end

	% tile_no = 0: Edges of the map to be printed:
	if isfield(OSMDATA,'bounds')
		xmin_mm	= PP.general.map_printout.xmin_mm;
		xmax_mm	= PP.general.map_printout.xmax_mm;
		ymin_mm	= PP.general.map_printout.ymin_mm;
		ymax_mm	= PP.general.map_printout.ymax_mm;
		if xmin_mm<OSMDATA.bounds.xmin_mm
			xmin_mm	= OSMDATA.bounds.xmin_mm;
		end
		if xmax_mm>OSMDATA.bounds.xmax_mm
			xmax_mm	= OSMDATA.bounds.xmax_mm;
		end
		if ymin_mm<OSMDATA.bounds.ymin_mm
			ymin_mm	= OSMDATA.bounds.ymin_mm;
		end
		if ymax_mm>OSMDATA.bounds.ymax_mm
			ymax_mm	= OSMDATA.bounds.ymax_mm;
		end
		x	= [xmin_mm xmax_mm xmax_mm xmin_mm];
		y	= [ymin_mm ymin_mm ymax_mm ymax_mm];
		poly_map_mm					= polyshape(x,y);
	else
		poly_map_mm					= polyshape();
	end
	ud_tile.tile_no			= 0;
	GV_H.poly_map_printout	= plot(GV_H.ax_2dmap,poly_map_mm,...
		'LineWidth'    ,2,...
		'LineStyle'    ,'-',...
		'EdgeColor'    ,'b',...
		'FaceAlpha'    ,0,...
		'UserData'     ,ud_tile,...
		'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);

	% Distance between objects and printout limits:
	if numboundaries(GV_H.poly_map_printout.Shape)>0
		poly_obj_limits			= GV_H.poly_map_printout.Shape;
		dist_obj_printout			= max(0,PP.general.dist_obj_printout);
		if strcmp(GV.jointtype_bh,'miter')
			poly_obj_limits		= polybuffer(...
				poly_obj_limits,...
				-dist_obj_printout,'JointType',GV.jointtype_bh,'MiterLimit',GV.miterlimit_bh);
		else
			poly_obj_limits		= polybuffer(...
				poly_obj_limits,...
				-dist_obj_printout,'JointType',GV.jointtype_bh);
		end
	else
		poly_obj_limits	= polyshape();
	end
	ud_tile.tile_no			= -2;
	GV_H.poly_map_printout_obj_limits	= plot(GV_H.ax_2dmap,poly_obj_limits,...
		'LineWidth'    ,2,...
		'LineStyle'    ,':',...
		'EdgeColor'    ,'b',...
		'FaceAlpha'    ,0,...
		'UserData'     ,ud_tile,...
		'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);

	% Create/modify Frame:
	plot_2dmap_frame;

	% The number of tiles possibly changes:
	% First plot_2dmap_frame must be called!
	plot_poly_tiles;

	% Create/modify legend:
	create_legend_mapfigure;

	% The map has been changed:
	GV.map_is_saved	= 0;

catch ME
	errormessage('',ME);
end

