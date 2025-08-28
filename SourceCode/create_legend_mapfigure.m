function create_legend_mapfigure(show_mapfigure_legend)
% Create/modify legend of the map figure:
% Must be executed after a new object is plotted in the axis GV_H.ax_2dmap,
% otherwise there will be a new entry in the existing legend.

global GV_H APP

try

	if nargin==0
		% Displaying the legend can slow down program execution significantly:
		show_mapfigure_legend		= APP.ShowMapfigureLegend_Menu.Checked;
	end

	if ~show_mapfigure_legend
		% Delete an existing legend:

		if isfield(GV_H,'ax_2dmap')
			if ~isempty(GV_H.ax_2dmap)
				if ishandle(GV_H.ax_2dmap)
					legend(GV_H.ax_2dmap,'off');
				end
			end
		end

	else
		% Update or show the legend:

		labels			= cell(1,0);
		subset			= [];
		if isfield(GV_H,'poly_limits_osmdata')
			if ishandle(GV_H.poly_limits_osmdata)
				labels{1,end+1}	= 'OSM data limits';
				subset(1,end+1)	= GV_H.poly_limits_osmdata;
			end
		end
		if isfield(GV_H,'poly_map_printout')
			if ishandle(GV_H.poly_map_printout)
				labels{1,end+1}	= 'printout limits: tile base';
				subset(1,end+1)	= GV_H.poly_map_printout;
			end
		end
		if isfield(GV_H,'poly_map_printout_obj_limits')
			if ishandle(GV_H.poly_map_printout_obj_limits)
				labels{1,end+1}	= 'printout limits: map objects';
				subset(1,end+1)	= GV_H.poly_map_printout_obj_limits;
			end
		end
		if isfield(GV_H,'poly_tiles')
			if iscell(GV_H.poly_tiles)
				if ishandle(GV_H.poly_tiles{1,1})
					labels{1,end+1}	= 'tile grid';
					subset(1,end+1)	= GV_H.poly_tiles{1,1};
				end
			end
		end
		if isfield(GV_H,'poly_frame')
			if ishandle(GV_H.poly_frame)
				labels{1,end+1}	= 'frame';
				subset(1,end+1)	= GV_H.poly_frame;
			end
		end

		if ~isempty(subset)
			GV_H.ax_2dmap_legend						= legend(GV_H.ax_2dmap,subset,labels,...
				'AutoUpdate','off');
		end

	end

catch ME
	errormessage('',ME);
end

