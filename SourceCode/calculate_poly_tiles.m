function [poly_tiles_v,...
	tile_m_v,...
	tile_n_v]=...
	calculate_poly_tiles(...
	tile_width,...
	tile_height,...
	tile_origin_x,...
	tile_origin_y,...
	xmin_mm,...
	xmax_mm,...
	ymin_mm,...
	ymax_mm)
% Calculation of the tile polygons
% xmin_mm..ymax_mm: frame included

global PP OSMDATA

try

	if nargin==0
		tile_width		= PP.general.tile_width_preset;
		tile_height		= PP.general.tile_depth_preset;
		tile_origin_x	= PP.general.tile_origin_x_preset;
		tile_origin_y	= PP.general.tile_origin_y_preset;
		xmin_mm			= OSMDATA.bounds.xmin_mm;
		xmax_mm			= OSMDATA.bounds.xmax_mm;
		ymin_mm			= OSMDATA.bounds.ymin_mm;
		ymax_mm			= OSMDATA.bounds.ymax_mm;
	end

	% Initializations:
	poly_tiles_v		= polyshape();
	tile_m_v				= zeros(0,1);
	tile_n_v				= zeros(0,1);

	% Tile origin:
	if tile_origin_x==999999
		ntiles_x			= ceil((xmax_mm-xmin_mm)/tile_width);
		tile_origin_x	= (xmin_mm+xmax_mm)/2-ntiles_x*tile_width/2;
	end
	if tile_origin_y==999999
		ntiles_y			= ceil((ymax_mm-ymin_mm)/tile_height);
		tile_origin_y	= (ymin_mm+ymax_mm)/2-ntiles_y*tile_height/2;
	end

	% tile_no = i: Edges of the tiles:
	% The min and max values can be outside the edge of the entire map.
	tile_no				= 0;
	tile_m				= 0;
	y_tile				= tile_origin_y+...
		floor((ymax_mm-tile_origin_y)/tile_height)*...
		tile_height;
	while (y_tile+tile_height)>ymin_mm
		if y_tile<ymax_mm
			tile_m	= tile_m+1;
			tile_n	= 0;
			x_tile	= tile_origin_x+...
				floor((xmin_mm-tile_origin_x)/tile_width)*...
				tile_width;
			while x_tile<xmax_mm
				if (x_tile+tile_width)>xmin_mm
					tile_n		= tile_n+1;
					tile_no		= tile_no+1;
					x	= [...
						x_tile,...
						x_tile+tile_width,...
						x_tile+tile_width,...
						x_tile];
					y	= [...
						y_tile,...
						y_tile,...
						y_tile+tile_height,...
						y_tile+tile_height];
					poly_tiles_v(tile_no,1)		= polyshape(x,y);
					tile_m_v(tile_no,1)			= tile_m;
					tile_n_v(tile_no,1)			= tile_n;
				end
				x_tile	= x_tile+tile_width;
			end
		end
		y_tile	= y_tile-tile_height;
	end

catch ME
	errormessage('',ME);
end

