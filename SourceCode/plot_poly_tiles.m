function plot_poly_tiles(tile_width,tile_height,tile_origin_x,tile_origin_y)
% Plots the tile polygon objects in the map with the axis GV_H.ax_2dmap.
% This can be necessary when creating the map or if the number of tiles has to be changed.
% tile_width			Tile width
% tile_height			Tile height/depth
% tile_origin_x		X-value of the position of a tile corner
% tile_origin_y		Y-value of the position of a tile corner

global GV GV_H OSMDATA APP PP

try

	if isempty(PP)
		return
	end

	if nargin==0
		tile_width		= PP.general.tile_width_preset;
		tile_height		= PP.general.tile_depth_preset;
		tile_origin_x	= PP.general.tile_origin_x_preset;
		tile_origin_y	= PP.general.tile_origin_y_preset;
	end

	% Delete existing polygon objects:
	if isfield(GV_H,'poly_tiles')
		if iscell(GV_H.poly_tiles)
			% tile_no_valid		= false(size(GV_H.poly_tiles,1),1);
			for tile_no=1:size(GV_H.poly_tiles,1)
				if isvalid(GV_H.poly_tiles{tile_no,1})
					delete(GV_H.poly_tiles{tile_no,1});
					% tile_no_valid(tile_no,1)	= true;
				end
			end
			% GV_H.poly_tiles(~tile_no_valid)	= [];
		end
		GV_H.poly_tiles	= {};
	end
	if isfield(GV_H,'poly_tileno')
		if iscell(GV_H.poly_tileno)
			% tile_no_valid		= false(size(GV_H.poly_tiles,1),1);
			for tile_no=1:size(GV_H.poly_tileno,1)
				if isvalid(GV_H.poly_tileno{tile_no,1})
					delete(GV_H.poly_tileno{tile_no,1});
					% tile_no_valid(tile_no,1)	= true;
				end
			end
			% GV_H.poly_tileno(~tile_no_valid)	= [];
		end
		GV_H.poly_tileno	= {};
	end

	% Map dimension:
	if isfield(OSMDATA,'bounds')
		xmin_mm	= OSMDATA.bounds.xmin_mm;
		xmax_mm	= OSMDATA.bounds.xmax_mm;
		ymin_mm	= OSMDATA.bounds.ymin_mm;
		ymax_mm	= OSMDATA.bounds.ymax_mm;
		if isfield(GV_H,'poly_map_printout')
			if isvalid(GV_H.poly_map_printout)
				xmin_mm	= min(GV_H.poly_map_printout.Shape.Vertices(:,1));
				xmax_mm	= max(GV_H.poly_map_printout.Shape.Vertices(:,1));
				ymin_mm	= min(GV_H.poly_map_printout.Shape.Vertices(:,2));
				ymax_mm	= max(GV_H.poly_map_printout.Shape.Vertices(:,2));
			end
		end
		if isfield(GV_H,'poly_frame')
			if isvalid(GV_H.poly_frame)
				xmin_mm	= min(GV_H.poly_frame.Shape.Vertices(:,1));
				xmax_mm	= max(GV_H.poly_frame.Shape.Vertices(:,1));
				ymin_mm	= min(GV_H.poly_frame.Shape.Vertices(:,2));
				ymax_mm	= max(GV_H.poly_frame.Shape.Vertices(:,2));
			end
		end
	else
		xmin_mm	= -0.45*tile_width;
		xmax_mm	= 0.45*tile_width;
		ymin_mm	= -0.45*tile_height;
		ymax_mm	= 0.45*tile_height;
	end

	% Create tile polygons:
	[poly_tiles_v,...
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
		ymax_mm);

	% tile_no = i: Edges of the tiles:
	% The min and max values can be outside the edge of the entire map.
	if ~isempty(tile_m_v)&&~isempty(tile_n_v)
		for tile_no=1:size(poly_tiles_v,1)

			% Plot tiles:
			ud_tile.tile_no				= tile_no;
			ud_tile.tile_m					= tile_m_v(tile_no,1);
			ud_tile.tile_n					= tile_n_v(tile_no,1);
			GV_H.poly_tiles{tile_no,1}	= plot(GV_H.ax_2dmap,poly_tiles_v(tile_no,1),...
				'LineWidth'    ,2,...
				'LineStyle'    ,'-',...
				'EdgeColor'    ,'c',...
				'FaceAlpha'    ,0,...
				'UserData'     ,ud_tile,...
				'ButtonDownFcn',GV.ax_2dmap_ButtonDownFcd);

			% Plot tile numbers:
			ud_tile_text.tile_no_text	= tile_no;
			[xcenter,ycenter] = centroid(poly_tiles_v(tile_no,1));
			GV_H.poly_tileno{tile_no,1}=text(GV_H.ax_2dmap,...
				xcenter,...
				ycenter,...
				sprintf('%g',tile_no));
			GV_H.poly_tileno{tile_no,1}.FontSize				= 30;
			GV_H.poly_tileno{tile_no,1}.FontWeight				= 'bold';
			GV_H.poly_tileno{tile_no,1}.Color					= 'c';
			GV_H.poly_tileno{tile_no,1}.HorizontalAlignment	= 'center';
			GV_H.poly_tileno{tile_no,1}.Interpreter			= 'none';
			if APP.View_ShowTileNo_Menu.Checked
				GV_H.poly_tileno{tile_no,1}.Visible				= 'on';
			else
				GV_H.poly_tileno{tile_no,1}.Visible				= 'off';
			end
			GV_H.poly_tileno{tile_no,1}.UserData				= ud_tile_text;

		end
	end

	% Create/modify legend:
	create_legend_mapfigure;

	% The map has been changed:
	GV.map_is_saved	= 0;

catch ME
	errormessage('',ME);
end

